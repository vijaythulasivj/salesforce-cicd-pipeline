param (
    [string]$TestRunId,
    [string]$Alias
)

$sfCmd = "C:\Program Files\sf\bin\sf.cmd"

Write-Host " Getting access token from SF alias: $Alias..."

$orgInfo = & "$sfCmd" org display --target-org $Alias --json | ConvertFrom-Json
$accessToken = $orgInfo.result.accessToken
$instanceUrl = $orgInfo.result.instanceUrl

Write-Host " Querying REST API for test run ID: $TestRunId..."

$headers = @{ Authorization = "Bearer $accessToken" }

$query = @"
SELECT Id, Status, ApexClass.Name, MethodName, Outcome, Message, StackTrace, AsyncApexJobId 
FROM ApexTestResult 
WHERE AsyncApexJobId = '$TestRunId'
"@

$encodedQuery = [System.Uri]::EscapeDataString($query)
$apiUrl = "$instanceUrl/services/data/v58.0/tooling/query/?q=$encodedQuery"

$response = Invoke-RestMethod -Uri $apiUrl -Headers $headers -Method Get
$response | ConvertTo-Json -Depth 100 | Out-File "test-result.json" -Encoding utf8

Write-Host " test-result.json saved from API."
