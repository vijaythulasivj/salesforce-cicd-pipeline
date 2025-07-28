import json
import pandas as pd
import os

# Load deployment validation JSON
with open("deploy-result.json", encoding="utf-8") as f:
    deploy_data = json.load(f)

# Load ApexTestResult JSON from REST API
with open("test-result.json", encoding="utf-8") as f:
    test_data = json.load(f)

# -------------------------
# Component Failures Sheet
# -------------------------
deploy_details = deploy_data.get("result", {}).get("details", {})
component_failures = deploy_details.get("componentFailures", [])

if component_failures:
    component_rows = [
        [fail.get("fileName", "Unknown"), fail.get("problem", "No details")]
        for fail in component_failures
    ]
    df_component_failures = pd.DataFrame(component_rows, columns=["FileName", "Problem"])
else:
    df_component_failures = pd.DataFrame([["✅ No component failures detected."]], columns=["Message"])

# -------------------------
# Test Results Sheet
# -------------------------
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

# -------------------------
# Code Coverage: Not available in REST API ApexTestResult by default
# You may need a separate query to Tooling API: ApexCodeCoverageAggregate
# For now, we'll stub this sheet with a message
# -------------------------
df_coverage = pd.DataFrame([["⚠️ Code coverage data not available via ApexTestResult API."]], columns=["Message"])
df_low_coverage = pd.DataFrame([["N/A"]], columns=["Message"])

# -------------------------
# Save Excel Report
# -------------------------
with pd.ExcelWriter("test-results.xlsx", engine="openpyxl") as writer:
    df_tests.to_excel(writer, sheet_name="Test Results", index=False)
    df_component_failures.to_excel(writer, sheet_name="Component Failures", index=False)
    df_coverage.to_excel(writer, sheet_name="Code Coverage", index=False)
    df_low_coverage.to_excel(writer, sheet_name="Low Coverage (<75%)", index=False)

print("test-results.xlsx generated with multiple sheets.")
