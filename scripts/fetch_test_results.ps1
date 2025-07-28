param (
    [string]$TestRunId,
    [string]$Alias
)

Write-Host " Getting access token from SF alias: $Alias..."

$orgInfo = sf org display $Alias --json | ConvertFrom-Json
$accessToken = $orgInfo.result.accessToken
$instanceUrl = $orgInfo.result.instanceUrl

Write-Host " Querying REST API for test run ID: $TestRunId..."

$headers = @{ Authorization = "Bearer $accessToken" }

$query = @"
SELECT Id, Status, ApexClass.Name, MethodName, Outcome, Message, StackTrace, AsyncApexJobId 
FROM ApexTestResult 
WHERE AsyncApexJobId = "$TestRunId"
"@

$encodedQuery = [System.Web.HttpUtility]::UrlEncode($query)
$apiUrl = "$instanceUrl/services/data/v58.0/tooling/query/?q=$encodedQuery"

$response = Invoke-RestMethod -Uri $apiUrl -Headers $headers -Method Get
$response | ConvertTo-Json -Depth 100 | Out-File "test-result.json" -Encoding utf8

Write-Host " test-result.json saved from API."
