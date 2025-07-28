param (
    [string]$TestRunId,
    [string]$Alias
)

Write-Host "🔑 Getting access token from SF alias: $Alias..."

# Get Salesforce org details
$orgInfoJson = sf org display $Alias --json
$orgInfo = $orgInfoJson | ConvertFrom-Json
$accessToken = $orgInfo.result.accessToken
$instanceUrl = $orgInfo.result.instanceUrl

Write-Host "📡 Querying REST API for test run ID: $TestRunId..."

# Prepare REST API query
$headers = @{ Authorization = "Bearer $accessToken" }

# ✅ Correctly quoted SOQL query
$query = "SELECT Id, Status, ApexClass.Name, MethodName, Outcome, Message, StackTrace, AsyncApexJobId FROM ApexTestResult WHERE AsyncApexJobId = '$TestRunId'"
$encodedQuery = [System.Web.HttpUtility]::UrlEncode($query)

# Full REST API URL
$apiUrl = "$instanceUrl/services/data/v58.0/tooling/query/?q=$encodedQuery"

# Call REST API
$response = Invoke-RestMethod -Uri $apiUrl -Headers $headers -Method Get

# Save result to JSON file
$response | ConvertTo-Json -Depth 100 | Out-File "test-result.json" -Encoding utf8

Write-Host "test-result.json saved from API."
