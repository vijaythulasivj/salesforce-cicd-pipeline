import json
import pandas as pd

# Load the JSON data
with open("deploy-result.json", encoding="utf-8") as f:
    data = json.load(f)

details = data.get("result", {}).get("details", {})
run_test_result = details.get("runTestResult", {})
successes = run_test_result.get("successes", [])
failures = run_test_result.get("failures", [])
component_failures = details.get("componentFailures", [])
code_coverage = run_test_result.get("codeCoverage", [])

# Test Results Sheet
test_rows = []
for test in successes:
    test_rows.append([
        test.get("name", ""),
        test.get("methodName", ""),
        test.get("time", 0),
        "Success"
    ])
for test in failures:
    test_rows.append([
        test.get("name", ""),
        test.get("methodName", ""),
        test.get("time", "N/A"),
        "Failure"
    ])
df_tests = pd.DataFrame(test_rows, columns=["TestClass", "Method", "Time(ms)", "Status"])

# Component Failures Sheet
if component_failures:
    component_rows = [
        [fail.get("fileName", "Unknown"), fail.get("problem", "No details")]
        for fail in component_failures
    ]
    df_component_failures = pd.DataFrame(component_rows, columns=["FileName", "Problem"])
else:
    df_component_failures = pd.DataFrame([["✅ No component failures detected."]], columns=["Message"])

# Code Coverage Sheet
coverage_rows = []
low_coverage_rows = []

for coverage in code_coverage:
    class_name = coverage.get("name") or coverage.get("id", "Unknown")
    locations_not_covered = coverage.get("locationsNotCovered", [])
    locations_covered = coverage.get("locationsCovered", 0)
    total = locations_covered + len(locations_not_covered)
    coverage_pct = (locations_covered / total) * 100 if total > 0 else 100.0
    coverage_rows.append([class_name, f"{coverage_pct:.2f}"])
    if coverage_pct < 75:
        low_coverage_rows.append([class_name, f"{coverage_pct:.2f}"])

df_coverage = pd.DataFrame(coverage_rows, columns=["Class Name", "Coverage %"])
df_low_coverage = (
    pd.DataFrame(low_coverage_rows, columns=["Class Name", "Coverage %"])
    if low_coverage_rows
    else pd.DataFrame([["✅ All classes have coverage >= 75%."]], columns=["Message"])
)

# Save all to an Excel file with multiple sheets
with pd.ExcelWriter("test-results.xlsx", engine="openpyxl") as writer:
    df_tests.to_excel(writer, sheet_name="Test Results", index=False)
    df_component_failures.to_excel(writer, sheet_name="Component Failures", index=False)
    df_coverage.to_excel(writer, sheet_name="Code Coverage", index=False)
    df_low_coverage.to_excel(writer, sheet_name="Low Coverage (<75%)", index=False)

print("✅ test-results.xlsx generated with multiple sheets.")
