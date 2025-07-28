param (
    [string]$TestRunId,
    [string]$Alias
)

$sfCmd = "C:\Program Files\sf\bin\sf.cmd"

Write-Host " Getting access token from SF alias: $Alias..."

# Fetch org info using sf CLI
$orgInfo = & "$sfCmd" org display --target-org $Alias --json | ConvertFrom-Json
$accessToken = $orgInfo.result.accessToken
$instanceUrl = $orgInfo.result.instanceUrl

Write-Host "`n Querying REST API for test run ID: $TestRunId..."

# Prepare authorization header
$headers = @{ Authorization = "Bearer $accessToken" }

# Define SOQL query
$query = @"
SELECT Id, Status, ApexClass.Name, MethodName, Outcome, Message, StackTrace, AsyncApexJobId 
FROM ApexTestResult 
WHERE AsyncApexJobId = '$TestRunId'
"@

# Debug: print the query
Write-Host "`n SOQL Query:"
Write-Host $query

# Encode query
$encodedQuery = [System.Uri]::EscapeDataString($query)

# Print encoded query
Write-Host "`n🔗 Encoded Query:"
Write-Host $encodedQuery

# Construct REST URL
$apiUrl = "$instanceUrl/services/data/v58.0/tooling/query/?q=$encodedQuery"
Write-Host "`n Final API URL:"
Write-Host $apiUrl

# Call REST API
$response = Invoke-RestMethod -Uri $apiUrl -Headers $headers -Method Get

# Save response to JSON
$response | ConvertTo-Json -Depth 100 | Out-File "test-result.json" -Encoding utf8
Write-Host "`n test-result.json saved from API.`n"
