import json
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
print(f"Getting access token from alias: {ALIAS}...")
sf_cmd = [SF_CMD_PATH, "org", "display", "--target-org", ALIAS, "--json"]
sf_output = subprocess.run(sf_cmd, capture_output=True, text=True, check=True)
sf_info = json.loads(sf_output.stdout)

access_token = sf_info['result']['accessToken']
instance_url = sf_info['result']['instanceUrl']
headers = {"Authorization": f"Bearer {access_token}"}

# === Step 3: Wait until test run is completed ===
print("⏳ Waiting for test run to complete...")
for i in range(10):
    status_cmd = [
        SF_CMD_PATH, "apex", "get", "test",
        "--test-run-id", TEST_RUN_ID,
        "--target-org", ALIAS,
        "--json"
    ]
    status_output = subprocess.run(status_cmd, capture_output=True, text=True)
    status_json = json.loads(status_output.stdout)
    status = status_json.get("result", {}).get("status")

    print(f"🔁 Poll {i + 1}: Test run status = {status}")
    if status == "Completed":
        break
    time.sleep(5)
else:
    raise RuntimeError("Test run did not complete after waiting.")

# === Step 4: Fetch ApexTestResult ===
print("📥 Querying ApexTestResult...")
query = f"""
    SELECT Id, ApexClass.Name, MethodName, Outcome, Message, StackTrace, AsyncApexJobId
    FROM ApexTestResult
    WHERE AsyncApexJobId = '{TEST_RUN_ID}'
"""
encoded_query = requests.utils.quote(query)
url = f"{instance_url}/services/data/v58.0/tooling/query?q={encoded_query}"

for attempt in range(5):
    print(f"🔁 Attempt {attempt + 1} to fetch test results...")
    response = requests.get(url, headers=headers)
    if response.status_code == 200:
        test_data = response.json()
        break
    print(f"Failed (status {response.status_code}): {response.text.strip()}")
    time.sleep(5)
else:
    raise RuntimeError("Failed to retrieve ApexTestResult after multiple attempts.")

# === Step 5: Fetch Code Coverage ===
print("📥 Querying ApexCodeCoverageAggregate...")
coverage_query = """
    SELECT ApexClassOrTrigger.Name, NumLinesCovered, NumLinesUncovered
    FROM ApexCodeCoverageAggregate
"""
encoded_coverage_query = requests.utils.quote(coverage_query)
coverage_url = f"{instance_url}/services/data/v58.0/tooling/query?q={encoded_coverage_query}"
response = requests.get(coverage_url, headers=headers)

coverage_rows = []
if response.status_code == 200:
    coverage_records = response.json().get("records", [])
    for rec in coverage_records:
        name = rec.get("ApexClassOrTrigger", {}).get("Name", "Unknown")
        covered = rec.get("NumLinesCovered", 0)
        uncovered = rec.get("NumLinesUncovered", 0)
        total = covered + uncovered
        percent = (covered / total * 100) if total > 0 else 0
        coverage_rows.append([name, covered, uncovered, f"{percent:.2f}%"])
else:
    print(f"Failed to fetch code coverage: {response.status_code} - {response.text}")
    coverage_rows = []

# === Step 6: Populate Excel sheets ===

# Component Failures
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

# Test Results
records = test_data.get("records", [])
test_rows = [
    [
        rec.get("ApexClass", {}).get("Name", ""),
        rec.get("MethodName", ""),
        rec.get("Outcome", ""),
        rec.get("Message", "") or "",
        rec.get("StackTrace", "") or ""
    ]
    for rec in records
]
df_tests = pd.DataFrame(test_rows, columns=["TestClass", "Method", "Outcome", "Message", "StackTrace"])

# Code Coverage
if coverage_rows:
    df_coverage = pd.DataFrame(coverage_rows, columns=["Class", "LinesCovered", "LinesUncovered", "CoveragePercent"])
    df_low_coverage = df_coverage[df_coverage["CoveragePercent"].apply(lambda x: float(x.strip('%')) < 75)]
else:
    df_coverage = pd.DataFrame([["No coverage data found."]], columns=["Message"])
    df_low_coverage = pd.DataFrame([["N/A"]], columns=["Message"])

# === Step 7: Save Excel file ===
with pd.ExcelWriter("test-results.xlsx", engine="openpyxl") as writer:
    df_tests.to_excel(writer, sheet_name="Test Results", index=False)
    df_component_failures.to_excel(writer, sheet_name="Component Failures", index=False)
    df_coverage.to_excel(writer, sheet_name="Code Coverage", index=False)
    df_low_coverage.to_excel(writer, sheet_name="Low Coverage (<75%)", index=False)

print(" test-results.xlsx generated with full results.")
