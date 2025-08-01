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
print(" Waiting for test run to complete...")

query = f"SELECT Status FROM AsyncApexJob WHERE Id = '{TEST_RUN_ID}'"
status_url = f"{instance_url}/services/data/v58.0/tooling/query?q={requests.utils.quote(query)}"

MAX_RETRIES = 30
WAIT_SECONDS = 10

for attempt in range(1, MAX_RETRIES + 1):
    resp = requests.get(status_url, headers=headers)
    records = resp.json().get("records", [])

    if records:
        status = records[0]["Status"]
        print(f"  Attempt {attempt}: Test run status = {status}")
        if status == "Completed":
            print(" Test run completed.")
            break
        elif status in ("Aborted", "Failed"):
            raise RuntimeError(f" Test run ended with status: {status}")
    else:
        print(f"  Attempt {attempt}: No status returned yet.")

    time.sleep(WAIT_SECONDS)
else:
    raise RuntimeError(" Test run did not complete in time.")

# === Step 4: Parse destructiveChanges.xml ===
destructive_classes = []
tree = ET.parse("destructive/destructiveChanges.xml")
root = tree.getroot()
namespace = {"ns": "http://soap.sforce.com/2006/04/metadata"}

for type_tag in root.findall("ns:types", namespace):
    if type_tag.find("ns:name", namespace).text == "ApexClass":
        destructive_classes += [m.text for m in type_tag.findall("ns:members", namespace)]

print("Classes in destructiveChanges.xml:")
for c in destructive_classes:
    print(f" - {c}")

# === Step 5: Fetch class-level code coverage (aggregate) ===
print("📊 Waiting for ApexCodeCoverageAggregate to update...")
time.sleep(20)  # Allow Salesforce backend to update coverage

print("📊 Fetching ApexCodeCoverageAggregate results...")

coverage_map = {}

coverage_query = """
    SELECT ApexClassOrTrigger.Name, NumLinesCovered, NumLinesUncovered
    FROM ApexCodeCoverageAggregate
    ORDER BY ApexClassOrTrigger.Name
"""
coverage_url = f"{instance_url}/services/data/v58.0/tooling/query?q={requests.utils.quote(coverage_query)}"
resp = requests.get(coverage_url, headers=headers)

try:
    json_data = resp.json()
except ValueError:
    raise RuntimeError(f"Invalid JSON response from aggregate coverage query:\n{resp.text}")

if "records" not in json_data:
    raise RuntimeError(f"Unexpected response structure from coverage query:\n{json.dumps(json_data, indent=2)}")

print("\n📄 Classes returned by ApexCodeCoverageAggregate:")
for rec in json_data["records"]:
    apex_obj = rec.get("ApexClassOrTrigger")
    if apex_obj:
        print(f" - {apex_obj.get('Name')}")

# Map coverage for destructive classes
for rec in json_data["records"]:
    apex_obj = rec.get("ApexClassOrTrigger")
    if not apex_obj:
        continue

    name = apex_obj.get("Name")
    if name in destructive_classes:
        covered = rec.get("NumLinesCovered", 0)
        uncovered = rec.get("NumLinesUncovered", 0)
        coverage_map[name] = {"covered": covered, "uncovered": uncovered}

# === Step 6: Build coverage report ===
coverage_rows = []
for class_name in destructive_classes:
    data = coverage_map.get(class_name, {"covered": 0, "uncovered": 0})
    total = data["covered"] + data["uncovered"]
    percent = (data["covered"] / total * 100) if total > 0 else 0.0
    coverage_rows.append([class_name, data["covered"], data["uncovered"], f"{percent:.2f}%"])

    if class_name not in coverage_map:
        print(f" Warning: No coverage found for class '{class_name}'")

df_coverage = pd.DataFrame(coverage_rows, columns=["Class", "LinesCovered", "LinesUncovered", "CoveragePercent"])
df_low_coverage = df_coverage[df_coverage["CoveragePercent"].apply(lambda x: float(x.strip('%')) < 75)]

# === Step 7: Fetch ApexTestResult ===
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

# === Step 9: Write Excel report ===
print(" Writing test-results.xlsx...")
with pd.ExcelWriter("test-results.xlsx", engine="openpyxl") as writer:
    df_tests.to_excel(writer, sheet_name="Test Results", index=False)
    df_component_failures.to_excel(writer, sheet_name="Component Failures", index=False)
    df_coverage.to_excel(writer, sheet_name="Code Coverage", index=False)
    df_low_coverage.to_excel(writer, sheet_name="Low Coverage (<75%)", index=False)

print(" test-results.xlsx generated successfully.")

# === Step 10: Auto-fail if any destructive class has coverage < threshold ===
COVERAGE_THRESHOLD = 75.0

low_coverage_classes = df_coverage[df_coverage["CoveragePercent"].apply(lambda x: float(x.strip('%')) < COVERAGE_THRESHOLD)]

if not low_coverage_classes.empty:
    print("\n❌ Build failed due to low coverage:")
    for _, row in low_coverage_classes.iterrows():
        print(f"  - {row['Class']} has only {row['CoveragePercent']} coverage")
    raise SystemExit(1)
else:
    print("\n All destructive classes meet the minimum coverage threshold.")

