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
query = f"""
    SELECT Status FROM ApexTestQueueItem WHERE ParentJobId = '{TEST_RUN_ID}' LIMIT 1
"""
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
tree = ET.parse("salesforce-cicd-pipeline/destructive/destructiveChanges.xml")
root = tree.getroot()
namespace = {"ns": "http://soap.sforce.com/2006/04/metadata"}

for type_tag in root.findall("ns:types", namespace):
    if type_tag.find("ns:name", namespace).text == "ApexClass":
        destructive_classes += [m.text for m in type_tag.findall("ns:members", namespace)]

# === Step 5: Fetch code coverage ===
coverage_query = """
    SELECT ApexClassOrTrigger.Name, NumLinesCovered, NumLinesUncovered
    FROM ApexCodeCoverageAggregate
"""
coverage_url = f"{instance_url}/services/data/v58.0/tooling/query?q={requests.utils.quote(coverage_query)}"
resp = requests.get(coverage_url, headers=headers)

coverage_map = {
    rec["ApexClassOrTrigger"]["Name"]: {
        "covered": rec["NumLinesCovered"],
        "uncovered": rec["NumLinesUncovered"]
    }
    for rec in resp.json().get("records", [])
}

# Fill in zero-coverage for missing ones
coverage_rows = []
for class_name in destructive_classes:
    data = coverage_map.get(class_name, {"covered": 0, "uncovered": 0})
    total = data["covered"] + data["uncovered"]
    percent = (data["covered"] / total * 100) if total > 0 else 0.0
    coverage_rows.append([class_name, data["covered"], data["uncovered"], f"{percent:.2f}%"])

# === Step 6: Export to Excel ===
df_coverage = pd.DataFrame(coverage_rows, columns=["Class", "LinesCovered", "LinesUncovered", "CoveragePercent"])
df_low_coverage = df_coverage[df_coverage["CoveragePercent"].apply(lambda x: float(x.strip('%')) < 75)]

with pd.ExcelWriter("test-results.xlsx", engine="openpyxl") as writer:
    df_coverage.to_excel(writer, sheet_name="Code Coverage", index=False)
    df_low_coverage.to_excel(writer, sheet_name="Low Coverage (<75%)", index=False)

print("✅ Coverage written to test-results.xlsx")
