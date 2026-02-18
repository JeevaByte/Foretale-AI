################################################################################
# API Gateway Testing Script - us-east-2 Region
# Tests all four API Gateways with proper authentication
################################################################################

param(
    [string]$Region = "us-east-2",
    [string]$CognitoUsername = "",
    [string]$CognitoPassword = "",
    [switch]$SkipCognito = $false
)

$ErrorActionPreference = "Continue"

# API Configuration
$APIs = @{
    OldSQL = @{
        Name = "api-sql-procedure-invoker (OLD)"
        ID = "c52bhyyc4c"
        Stage = "prod"
        BaseURL = "https://c52bhyyc4c.execute-api.us-east-2.amazonaws.com/prod"
        RequiresAuth = $false
        Endpoints = @(
            @{Method="POST"; Path="/insert_record"; TestData='{"table":"test","data":{"test":"value"}}'}
            @{Method="GET"; Path="/read_record"; TestData=$null}
            @{Method="PUT"; Path="/update_record"; TestData='{"table":"test","data":{"test":"updated"}}'}
            @{Method="DELETE"; Path="/delete_record"; TestData='{"table":"test","id":1}'}
            @{Method="GET"; Path="/read_json_record"; TestData=$null}
        )
    }
    OldECS = @{
        Name = "api-ecs-task-invoker (OLD)"
        ID = "6pz582qld4"
        Stage = "prod"
        BaseURL = "https://6pz582qld4.execute-api.us-east-2.amazonaws.com/prod"
        RequiresAuth = $false
        Endpoints = @(
            @{Method="POST"; Path="/ecs_invoker_resource"; TestData='{"task":"test-task"}'}
        )
    }
    NewSQL = @{
        Name = "foretale-dev-api-sql (NEW)"
        ID = "wisvlsk9we"
        Stage = "dev"
        BaseURL = "https://wisvlsk9we.execute-api.us-east-2.amazonaws.com/dev"
        RequiresAuth = $true
        CognitoPoolId = "us-east-2_U1ygvI4IB"
        CognitoClientId = "51q2l852bfkr0hbneg6tg247g7"
        Endpoints = @(
            @{Method="POST"; Path="/insert_record"; TestData='{"table":"test","data":{"test":"value"}}'}
            @{Method="GET"; Path="/read_record"; TestData=$null}
            @{Method="PUT"; Path="/update_record"; TestData='{"table":"test","data":{"test":"updated"}}'}
            @{Method="DELETE"; Path="/delete_record"; TestData='{"table":"test","id":1}'}
            @{Method="GET"; Path="/read_json_record"; TestData=$null}
        )
    }
    NewECS = @{
        Name = "foretale-dev-api-ecs (NEW)"
        ID = "escemsrkl3"
        Stage = "dev"
        BaseURL = "https://escemsrkl3.execute-api.us-east-2.amazonaws.com/dev"
        RequiresAuth = $true
        CognitoPoolId = "us-east-2_U1ygvI4IB"
        CognitoClientId = "51q2l852bfkr0hbneg6tg247g7"
        Endpoints = @(
            @{Method="POST"; Path="/ecs_invoker_resource"; TestData='{"task":"test-task"}'}
            @{Method="GET"; Path="/get_ecs_status"; TestData=$null}
        )
    }
}

# Results tracking
$TestResults = @()

################################################################################
# Functions
################################################################################

function Get-CognitoToken {
    param(
        [string]$PoolId,
        [string]$ClientId,
        [string]$Username,
        [string]$Password
    )
    
    Write-Host "`n=== Authenticating with Cognito ===" -ForegroundColor Cyan
    Write-Host "User Pool: $PoolId" -ForegroundColor Gray
    Write-Host "Client ID: $ClientId" -ForegroundColor Gray
    
    try {
        # Initiate authentication
        $authResult = aws cognito-idp initiate-auth `
            --auth-flow USER_PASSWORD_AUTH `
            --client-id $ClientId `
            --auth-parameters USERNAME=$Username,PASSWORD=$Password `
            --region $Region 2>&1 | ConvertFrom-Json
        
        if ($authResult.AuthenticationResult) {
            Write-Host "Authentication successful" -ForegroundColor Green
            # Use ID token for API Gateway Cognito authorizers
            return $authResult.AuthenticationResult.IdToken
        }
        else {
            Write-Host "Authentication failed" -ForegroundColor Red
            Write-Host "Response: $($authResult | ConvertTo-Json -Depth 5)" -ForegroundColor Yellow
            return $null
        }
    }
    catch {
        Write-Host "Error during authentication: $_" -ForegroundColor Red
        return $null
    }
}

function Test-APIEndpoint {
    param(
        [string]$URL,
        [string]$Method,
        [string]$Body,
        [string]$Token = $null,
        [string]$APIName,
        [string]$Path
    )
    
    $headers = @{
        "Content-Type" = "application/json"
    }
    
    if ($Token) {
        $headers["Authorization"] = $Token
    }
    
    Write-Host "`n--- Testing: $Path ($Method) ---" -ForegroundColor Yellow
    
    try {
        $invokeParams = @{
            Uri = $URL
            Method = $Method
            Headers = $headers
            TimeoutSec = 30
        }
        
        if ($Body) {
            $invokeParams["Body"] = $Body
            Write-Host "Request Body: $Body" -ForegroundColor Gray
        }
        
        $startTime = Get-Date
        $response = Invoke-WebRequest @invokeParams -UseBasicParsing
        $duration = (Get-Date) - $startTime
        
        Write-Host "Status: $($response.StatusCode)" -ForegroundColor Green
        Write-Host "Response Time: $([math]::Round($duration.TotalMilliseconds, 2))ms" -ForegroundColor Cyan
        Write-Host "Content Length: $($response.Content.Length) bytes" -ForegroundColor Gray
        
        # Try to parse JSON response
        try {
            $jsonResponse = $response.Content | ConvertFrom-Json
            Write-Host "Response Body:" -ForegroundColor Gray
            Write-Host $($jsonResponse | ConvertTo-Json -Depth 5) -ForegroundColor DarkGray
        }
        catch {
            Write-Host "Response Body (raw):" -ForegroundColor Gray
            Write-Host $response.Content -ForegroundColor DarkGray
        }
        
        return @{
            API = $APIName
            Path = $Path
            Method = $Method
            Status = "PASS"
            StatusCode = $response.StatusCode
            DurationMs = [math]::Round($duration.TotalMilliseconds, 2)
            Error = $null
        }
    }
    catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        Write-Host "Failed: Status $statusCode" -ForegroundColor Red
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
        
        # Try to get error response body
        try {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $errorBody = $reader.ReadToEnd()
            Write-Host "Error Response: $errorBody" -ForegroundColor DarkRed
        }
        catch {}
        
        return @{
            API = $APIName
            Path = $Path
            Method = $Method
            Status = "FAIL"
            StatusCode = $statusCode
            DurationMs = 0
            Error = $_.Exception.Message
        }
    }
}

function Test-CORSPreflight {
    param(
        [string]$URL,
        [string]$APIName,
        [string]$Path
    )
    
    Write-Host "`n--- Testing CORS: $Path (OPTIONS) ---" -ForegroundColor Magenta
    
    try {
        $headers = @{
            "Origin" = "https://example.com"
            "Access-Control-Request-Method" = "POST"
            "Access-Control-Request-Headers" = "content-type,authorization"
        }
        
        $response = Invoke-WebRequest -Uri $URL -Method OPTIONS -Headers $headers -UseBasicParsing -TimeoutSec 10
        
        $corsHeaders = @{
            "Access-Control-Allow-Origin" = $response.Headers["Access-Control-Allow-Origin"]
            "Access-Control-Allow-Methods" = $response.Headers["Access-Control-Allow-Methods"]
            "Access-Control-Allow-Headers" = $response.Headers["Access-Control-Allow-Headers"]
        }
        
        Write-Host "CORS Enabled" -ForegroundColor Green
        Write-Host "  Allow-Origin: $($corsHeaders.'Access-Control-Allow-Origin')" -ForegroundColor Gray
        Write-Host "  Allow-Methods: $($corsHeaders.'Access-Control-Allow-Methods')" -ForegroundColor Gray
        Write-Host "  Allow-Headers: $($corsHeaders.'Access-Control-Allow-Headers')" -ForegroundColor Gray
        
        return $true
    }
    catch {
        Write-Host "CORS check failed or not configured" -ForegroundColor Yellow
        return $false
    }
}

################################################################################
# Main Testing Flow
################################################################################

Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "        API Gateway Testing Suite - us-east-2 Region                 " -ForegroundColor Cyan
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host ""

# Get Cognito token if needed
$CognitoToken = $null
if (-not $SkipCognito) {
    if (-not $CognitoUsername) {
        $CognitoUsername = Read-Host "Enter Cognito username (or press Enter to skip Cognito-protected APIs)"
    }
    
    if ($CognitoUsername) {
        if (-not $CognitoPassword) {
            $securePassword = Read-Host "Enter Cognito password" -AsSecureString
            $CognitoPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
                [Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePassword)
            )
        }
        
        $CognitoToken = Get-CognitoToken -PoolId "us-east-2_U1ygvI4IB" -ClientId "51q2l852bfkr0hbneg6tg247g7" -Username $CognitoUsername -Password $CognitoPassword
    }
}

# Test each API
foreach ($apiKey in @("OldSQL", "OldECS", "NewSQL", "NewECS")) {
    $api = $APIs[$apiKey]
    
    Write-Host "`n======================================================================" -ForegroundColor Green
    Write-Host "  Testing: $($api.Name)" -ForegroundColor Green
    Write-Host "======================================================================" -ForegroundColor Green
    Write-Host "API ID: $($api.ID)" -ForegroundColor Gray
    Write-Host "Base URL: $($api.BaseURL)" -ForegroundColor Gray
    Write-Host "Requires Auth: $($api.RequiresAuth)" -ForegroundColor Gray
    
    # Check if authentication is required but not available
    if ($api.RequiresAuth -and -not $CognitoToken) {
        Write-Host "Warning: Skipping - Requires Cognito authentication (not provided)" -ForegroundColor Yellow
        continue
    }
    
    # Test each endpoint
    foreach ($endpoint in $api.Endpoints) {
        $url = "$($api.BaseURL)$($endpoint.Path)"
        $token = if ($api.RequiresAuth) { $CognitoToken } else { $null }
        
        # Test CORS preflight first
        Test-CORSPreflight -URL $url -APIName $api.Name -Path $endpoint.Path | Out-Null
        
        # Test actual endpoint
        $result = Test-APIEndpoint `
            -URL $url `
            -Method $endpoint.Method `
            -Body $endpoint.TestData `
            -Token $token `
            -APIName $api.Name `
            -Path $endpoint.Path
        
        $TestResults += $result
        
        Start-Sleep -Milliseconds 500
    }
}

################################################################################
# Results Summary
################################################################################

Write-Host "`n`n======================================================================" -ForegroundColor Cyan
Write-Host "                       Test Results Summary                           " -ForegroundColor Cyan
Write-Host "======================================================================" -ForegroundColor Cyan

$TestResults | Format-Table -Property API, Path, Method, Status, StatusCode, DurationMs, Error -AutoSize

$passCount = ($TestResults | Where-Object { $_.Status -eq "PASS" }).Count
$failCount = ($TestResults | Where-Object { $_.Status -eq "FAIL" }).Count
$totalCount = $TestResults.Count

Write-Host "`nTotal Tests: $totalCount" -ForegroundColor White
Write-Host "Passed: $passCount" -ForegroundColor Green
Write-Host "Failed: $failCount" -ForegroundColor Red

if ($failCount -eq 0 -and $totalCount -gt 0) {
    Write-Host "`nAll tests passed!" -ForegroundColor Green
}
elseif ($totalCount -eq 0) {
    Write-Host "`nNo tests were executed" -ForegroundColor Yellow
}
else {
    Write-Host "`nSome tests failed" -ForegroundColor Red
}

# Export results to CSV
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$resultsFile = "api_test_results_$timestamp.csv"
$TestResults | Export-Csv -Path $resultsFile -NoTypeInformation
Write-Host "`nResults exported to: $resultsFile" -ForegroundColor Cyan
