import json
import xml.etree.ElementTree as ET
import pandas as pd
import os
import subprocess
import requests
import time

# === CONFIG ===
TEST_RUN_ID = os.getenv("TEST_RUN_ID")
if not TEST_RUN_ID:
    raise ValueError("Missing TEST_RUN_ID environment variable. Pass it from Jenkins.")

ALIAS = os.getenv("SF_ALIAS") or "myAlias"
SF_CMD_PATH = r"C:\Program Files\sf\bin\sf.cmd"

# === Step 1: Load deploy-result.json ===
with open("deploy-result.json", encoding="utf-8") as f:
    deploy_data = json.load(f)

# === Step 2: Get access token and instance URL ===
sf_cmd = [SF_CMD_PATH, "org", "display", "--target-org", ALIAS, "--json"]
sf_output = subprocess.run(sf_cmd, capture_output=True, text=True, check=True)
sf_info = json.loads(sf_output.stdout)

access_token = sf_info['result']['accessToken']
instance_url = sf_info['result']['instanceUrl']
headers = {"Authorization": f"Bearer {access_token}"}

# === Step 3: Wait for test run to complete ===
print("⏳ Waiting for test run to complete...")
query = f"SELECT Status FROM ApexTestQueueItem WHERE ParentJobId = '{TEST_RUN_ID}' LIMIT 1"
status_url = f"{instance_url}/services/data/v58.0/tooling/query?q={requests.utils.quote(query)}"
for _ in range(10):
    resp = requests.get(status_url, headers=headers)
    records = resp.json().get("records", [])
    if records and records[0]["Status"] == "Completed":
        break
    time.sleep(5)
else:
    raise RuntimeError("Test run did not complete in time.")

# === Step 4: Parse destructiveChanges.xml ===
destructive_classes = []
tree = ET.parse("destructive/destructiveChanges.xml")
root = tree.getroot()
namespace = {"ns": "http://soap.sforce.com/2006/04/metadata"}

for type_tag in root.findall("ns:types", namespace):
    if type_tag.find("ns:name", namespace).text == "ApexClass":
        destructive_classes += [m.text for m in type_tag.findall("ns:members", namespace)]

# === Step 5: Fetch code coverage with retry ===
print(" Fetching ApexCodeCoverageAggregate...")
coverage_query = "SELECT ApexClassOrTrigger.Name, NumLinesCovered, NumLinesUncovered FROM ApexCodeCoverageAggregate"
coverage_url = f"{instance_url}/services/data/v58.0/tooling/query?q={requests.utils.quote(coverage_query)}"

coverage_map = {}
for attempt in range(10):
    resp = requests.get(coverage_url, headers=headers)
    records = resp.json().get("records", [])
    if records:
        print(f" Retrieved {len(records)} coverage records on attempt {attempt+1}")
        for rec in records:
            apex_obj = rec.get("ApexClassOrTrigger")
            if apex_obj:
                name = apex_obj.get("Name")
                covered = rec.get("NumLinesCovered", 0)
                uncovered = rec.get("NumLinesUncovered", 0)
                coverage_map[name] = {"covered": covered, "uncovered": uncovered}
        break
    else:
        print(f" Attempt {attempt+1}: No coverage data yet, retrying...")
        time.sleep(5)
else:
    print(" No coverage data found after retries.")

# === Step 6: Build coverage report ===
coverage_rows = []
for class_name in destructive_classes:
    data = coverage_map.get(class_name, {"covered": 0, "uncovered": 0})
    total = data["covered"] + data["uncovered"]
    percent = (data["covered"] / total * 100) if total > 0 else 0.0
    coverage_rows.append([class_name, data["covered"], data["uncovered"], f"{percent:.2f}%"])

df_coverage = pd.DataFrame(coverage_rows, columns=["Class", "LinesCovered", "LinesUncovered", "CoveragePercent"])
df_low_coverage = df_coverage[df_coverage["CoveragePercent"].apply(lambda x: float(x.strip('%')) < 75)]

# === Step 7: Fetch ApexTestResult from Tooling API ===
print(" Fetching test method results...")
test_query = f"""
    SELECT ApexClass.Name, MethodName, Outcome, Message, StackTrace
    FROM ApexTestResult
    WHERE AsyncApexJobId = '{TEST_RUN_ID}'
"""
test_url = f"{instance_url}/services/data/v58.0/tooling/query?q={requests.utils.quote(test_query)}"
test_resp = requests.get(test_url, headers=headers)
test_records = test_resp.json().get("records", [])

test_rows = [
    [
        rec.get("ApexClass", {}).get("Name", ""),
        rec.get("MethodName", ""),
        rec.get("Outcome", ""),
        rec.get("Message", "") or "",
        rec.get("StackTrace", "") or ""
    ]
    for rec in test_records
]
df_tests = pd.DataFrame(test_rows, columns=["TestClass", "Method", "Outcome", "Message", "StackTrace"])

# === Step 8: Extract Component Failures ===
deploy_details = deploy_data.get("result", {}).get("details", {})
component_failures = deploy_details.get("componentFailures", [])

if component_failures:
    component_rows = [
        [fail.get("fileName", "Unknown"), fail.get("problem", "No details")]
        for fail in component_failures
    ]
    df_component_failures = pd.DataFrame(component_rows, columns=["FileName", "Problem"])
else:
    df_component_failures = pd.DataFrame([["No component failures detected."]], columns=["Message"])

# === Step 9: Write everything to Excel ===
print("📤 Writing test-results.xlsx...")
with pd.ExcelWriter("test-results.xlsx", engine="openpyxl") as writer:
    df_tests.to_excel(writer, sheet_name="Test Results", index=False)
    df_component_failures.to_excel(writer, sheet_name="Component Failures", index=False)
    df_coverage.to_excel(writer, sheet_name="Code Coverage", index=False)
    df_low_coverage.to_excel(writer, sheet_name="Low Coverage (<75%)", index=False)

print(" test-results.xlsx generated with full report.")
