import json
import csv

# Load the CLI JSON output
with open("deploy-result.json") as f:
    data = json.load(f)

result = data["result"]

# ---------- 1. TEST RESULTS ----------
with open("test-results.csv", "w", newline="") as csvfile:
    fieldnames = ["TestClass", "Method", "Time(ms)", "Status"]
    writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
    writer.writeheader()

    for test in result.get("successes", []):
        writer.writerow({
            "TestClass": test["name"],
            "Method": test["methodName"],
            "Time(ms)": test["time"],
            "Status": "Success"
        })

    for test in result.get("failures", []):
        writer.writerow({
            "TestClass": test["name"],
            "Method": test["methodName"],
            "Time(ms)": test.get("time", "N/A"),
            "Status": "Failure"
        })

# ---------- 2. COMPONENT FAILURES ----------
component_failures = result.get("componentFailures", [])
if component_failures:
    with open("component-failures.csv", "w", newline="") as csvfile:
        fieldnames = ["FullName", "Type", "Problem", "FileName", "LineNumber", "ColumnNumber"]
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
        for failure in component_failures:
            writer.writerow({
                "FullName": failure.get("fullName", ""),
                "Type": failure.get("componentType", ""),
                "Problem": failure.get("problem", ""),
                "FileName": failure.get("fileName", ""),
                "LineNumber": failure.get("lineNumber", ""),
                "ColumnNumber": failure.get("columnNumber", "")
            })

# ---------- 3. CODE COVERAGE WARNINGS ----------
coverage_warnings = result.get("codeCoverageWarnings", [])
if coverage_warnings:
    with open("code-coverage-warnings.csv", "w", newline="") as csvfile:
        fieldnames = ["Name", "Message"]
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
        for warning in coverage_warnings:
            writer.writerow({
                "Name": warning.get("name", ""),
                "Message": warning.get("message", "")
            })

# ---------- 4. FLOW COVERAGE WARNINGS ----------
flow_warnings = result.get("flowCoverageWarnings", [])
if flow_warnings:
    with open("flow-coverage-warnings.csv", "w", newline="") as csvfile:
        fieldnames = ["FlowName", "Message"]
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
        for warning in flow_warnings:
            writer.writerow({
                "FlowName": warning.get("flowName", ""),
                "Message": warning.get("message", "")
            })

print(" CSV reports generated:")
print("- test-results.csv")
if component_failures:
    print("- component-failures.csv")
if coverage_warnings:
    print("- code-coverage-warnings.csv")
if flow_warnings:
    print("- flow-coverage-warnings.csv")
