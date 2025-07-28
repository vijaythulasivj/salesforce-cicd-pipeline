import json
import csv

with open("deploy-result.json", encoding="utf-8") as f:
    data = json.load(f)

details = data.get("result", {}).get("details", {})
run_test_result = details.get("runTestResult", {})
successes = run_test_result.get("successes", [])
failures = run_test_result.get("failures", [])
component_failures = details.get("componentFailures", [])
code_coverage = run_test_result.get("codeCoverage", [])

# Prepare test results rows
rows = []
rows.append(["TestClass", "Method", "Time(ms)", "Status"])
for test in successes:
    rows.append([
        test.get("name", ""),
        test.get("methodName", ""),
        test.get("time", 0),
        "Success"
    ])
for test in failures:
    rows.append([
        test.get("name", ""),
        test.get("methodName", ""),
        test.get("time", "N/A"),
        "Failure"
    ])

# Add a blank row before Component Failures
rows.append([])
rows.append(["Component Failures"])
if component_failures:
    rows.append(["FileName", "Problem"])
    for fail in component_failures:
        rows.append([
            fail.get("fileName", "Unknown"),
            fail.get("problem", "No details")
        ])
else:
    rows.append(["✅ No component failures detected."])

# Add Code Coverage Summary
rows.append([])
rows.append(["Code Coverage Report"])
rows.append(["Class Name", "Coverage %"])
low_coverage_classes = []

for coverage in code_coverage:
    class_name = coverage.get("name") or coverage.get("id", "Unknown")
    locations_not_covered = coverage.get("locationsNotCovered", [])
    locations_covered = coverage.get("locationsCovered", 0)
    total = locations_covered + len(locations_not_covered)

    coverage_pct = (locations_covered / total) * 100 if total > 0 else 100.0
    rows.append([class_name, f"{coverage_pct:.2f}"])
    
    if coverage_pct < 75:
        low_coverage_classes.append((class_name, coverage_pct))

# Add low coverage warning section
if low_coverage_classes:
    rows.append([])
    rows.append(["⚠️ Classes with Coverage < 75%"])
    rows.append(["Class Name", "Coverage %"])
    for class_name, pct in low_coverage_classes:
        rows.append([class_name, f"{pct:.2f}"])
else:
    rows.append([])
    rows.append(["✅ All classes have coverage >= 75%."])

# Write to test-results.csv
with open("test-results.csv", "w", newline="", encoding="utf-8") as csvfile:
    writer = csv.writer(csvfile)
    writer.writerows(rows)

print("test-results.csv generated with test results, component errors, and code coverage.")
