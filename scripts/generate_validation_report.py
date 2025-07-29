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

ALIAS = os.getenv("SF_ALIAS") or "myAlias"  # Jenkins env variable or default alias

# Full path to sf.cmd (Option 1)
SF_CMD_PATH = r"C:\Program Files\sf\bin\sf.cmd"

# === Step 1: Load deployment validation JSON ===
with open("deploy-result.json", encoding="utf-8") as f:
    deploy_data = json.load(f)

# === Step 2: Fetch Apex test result via REST API with retry ===
def fetch_test_results(test_run_id, alias):
    print(f"Getting access token from alias: {alias}...")
    sf_cmd = [SF_CMD_PATH, "org", "display", "--target-org", alias, "--json"]
    sf_output = subprocess.run(sf_cmd, capture_output=True, text=True, check=True)
    sf_info = json.loads(sf_output.stdout)

    access_token = sf_info['result']['accessToken']
    instance_url = sf_info['result']['instanceUrl']

    print("Querying ApexTestResult from Tooling API...")

    query = f"""
        SELECT Id, ApexClass.Name, MethodName, Outcome, Message, StackTrace, AsyncApexJobId
        FROM ApexTestResult
        WHERE AsyncApexJobId = '{test_run_id}'
    """

    encoded_query = requests.utils.quote(query)
    url = f"{instance_url}/services/data/v58.0/tooling/query?q={encoded_query}"
    headers = {"Authorization": f"Bearer {access_token}"}

    # Retry logic
    for attempt in range(5):
        print(f"🔁 Attempt {attempt + 1} to fetch test results...")
        response = requests.get(url, headers=headers)

        if response.status_code == 200:
            print(" Test results retrieved.")
            return response.json()

        print(f" Failed (status {response.status_code}): {response.text.strip()}")
        time.sleep(5)

    print(" Failed to retrieve test results after multiple attempts.")
    response.raise_for_status()

# === Step 3: Call the function to get test results ===
test_data = fetch_test_results(TEST_RUN_ID, ALIAS)

# === Step 4: Component Failures Sheet ===
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

# === Step 5: Test Results Sheet ===
records = test_data.get("records", [])

test_rows = []
for rec in records:
    test_rows.append([
        rec.get("ApexClass", {}).get("Name", ""),
        rec.get("MethodName", ""),
        rec.get("Outcome", ""),
        rec.get("Message", "") or "",
        rec.get("StackTrace", "") or ""
    ])

df_tests = pd.DataFrame(test_rows, columns=["TestClass", "Method", "Outcome", "Message", "StackTrace"])

# === Step 6: Code Coverage Stub Sheet ===
df_coverage = pd.DataFrame([["Code coverage data not available via ApexTestResult API."]], columns=["Message"])
df_low_coverage = pd.DataFrame([["N/A"]], columns=["Message"])

# === Step 7: Save Excel Report ===
with pd.ExcelWriter("test-results.xlsx", engine="openpyxl") as writer:
    df_tests.to_excel(writer, sheet_name="Test Results", index=False)
    df_component_failures.to_excel(writer, sheet_name="Component Failures", index=False)
    df_coverage.to_excel(writer, sheet_name="Code Coverage", index=False)
    df_low_coverage.to_excel(writer, sheet_name="Low Coverage (<75%)", index=False)

print("test-results.xlsx generated with multiple sheets.")
