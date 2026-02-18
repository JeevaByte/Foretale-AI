################################################################################
# Quick API Health Check Script
# Tests basic connectivity to all APIs in us-east-2
################################################################################

Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "           API Gateway Health Check - us-east-2                      " -ForegroundColor Cyan
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host ""

$results = @()

# Test OLD APIs (No Auth Expected - but may still return errors if no data)
Write-Host "Testing OLD APIs (No Authorization)..." -ForegroundColor Yellow
Write-Host ""

$oldApis = @(
    @{Name="api-sql-procedure-invoker"; URL="https://c52bhyyc4c.execute-api.us-east-2.amazonaws.com/prod/read_record"; Method="GET"}
    @{Name="api-ecs-task-invoker"; URL="https://6pz582qld4.execute-api.us-east-2.amazonaws.com/prod/ecs_invoker_resource"; Method="POST"}
)

foreach ($api in $oldApis) {
    Write-Host "  [OLD] $($api.Name)..." -NoNewline
    try {
        $response = Invoke-WebRequest -Uri $api.URL -Method $api.Method -TimeoutSec 5 -UseBasicParsing -ErrorAction Stop
        Write-Host " OK ($($response.StatusCode))" -ForegroundColor Green
        $results += @{API=$api.Name; Status="OK"; Code=$response.StatusCode}
    }
    catch {
        $code = $_.Exception.Response.StatusCode.value__
        if ($code -eq 403 -or $code -eq 400) {
            Write-Host " Warning Responded ($code) - May need valid request body" -ForegroundColor Yellow
            $results += @{API=$api.Name; Status="Warning Responded"; Code=$code}
        }
        else {
            Write-Host " Failed ($code)" -ForegroundColor Red
            $results += @{API=$api.Name; Status="Failed"; Code=$code}
        }
    }
}

Write-Host ""
Write-Host "Testing NEW APIs (Cognito Authorization Required)..." -ForegroundColor Yellow
Write-Host ""

$newApis = @(
    @{Name="foretale-dev-api-sql"; URL="https://wisvlsk9we.execute-api.us-east-2.amazonaws.com/dev/read_record"; Method="GET"}
    @{Name="foretale-dev-api-ecs"; URL="https://escemsrkl3.execute-api.us-east-2.amazonaws.com/dev/get_ecs_status"; Method="GET"}
)

foreach ($api in $newApis) {
    Write-Host "  [AUTH] $($api.Name)..." -NoNewline
    try {
        $response = Invoke-WebRequest -Uri $api.URL -Method $api.Method -TimeoutSec 5 -UseBasicParsing -ErrorAction Stop
        Write-Host " Warning - Unexpected - should require auth!" -ForegroundColor Yellow
        $results += @{API=$api.Name; Status="Warning No Auth Check"; Code=$response.StatusCode}
    }
    catch {
        $code = $_.Exception.Response.StatusCode.value__
        if ($code -eq 401) {
            Write-Host " OK - Protected (401 Unauthorized)" -ForegroundColor Green
            $results += @{API=$api.Name; Status="OK Auth Required"; Code=401}
        }
        elseif ($code -eq 403) {
            Write-Host " OK - Protected (403 Forbidden)" -ForegroundColor Green
            $results += @{API=$api.Name; Status="OK Auth Required"; Code=403}
        }
        else {
            Write-Host " Failed - Unexpected ($code)" -ForegroundColor Red
            $results += @{API=$api.Name; Status="Failed"; Code=$code}
        }
    }
}

Write-Host ""
Write-Host "Testing CORS Preflight (OPTIONS)..." -ForegroundColor Yellow
Write-Host ""

$corsTests = @(
    @{Name="NEW SQL CORS"; URL="https://wisvlsk9we.execute-api.us-east-2.amazonaws.com/dev/insert_record"}
    @{Name="NEW ECS CORS"; URL="https://escemsrkl3.execute-api.us-east-2.amazonaws.com/dev/ecs_invoker_resource"}
)

foreach ($test in $corsTests) {
    Write-Host "  [CORS] $($test.Name)..." -NoNewline
    try {
        $headers = @{
            "Origin" = "https://example.com"
            "Access-Control-Request-Method" = "POST"
        }
        $response = Invoke-WebRequest -Uri $test.URL -Method OPTIONS -Headers $headers -TimeoutSec 5 -UseBasicParsing -ErrorAction Stop
        
        $allowOrigin = $response.Headers["Access-Control-Allow-Origin"]
        if ($allowOrigin) {
            Write-Host " OK - Enabled (Origin: $allowOrigin)" -ForegroundColor Green
            $results += @{API=$test.Name; Status="OK CORS"; Code=200}
        }
        else {
            Write-Host " Warning - No CORS headers" -ForegroundColor Yellow
            $results += @{API=$test.Name; Status="Warning No CORS"; Code=200}
        }
    }
    catch {
        Write-Host " Failed" -ForegroundColor Red
        $results += @{API=$test.Name; Status="Failed"; Code=$_.Exception.Response.StatusCode.value__}
    }
}

Write-Host ""
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "                         Summary                                      " -ForegroundColor Cyan
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host ""

$okCount = ($results | Where-Object { $_.Status -like "*OK*" -or $_.Status -like "*Protected*" -or $_.Status -like "*Required*" }).Count
$totalCount = $results.Count

Write-Host "Total Checks: $totalCount" -ForegroundColor White
Write-Host "Passed: $okCount" -ForegroundColor Green
Write-Host ""

if ($okCount -eq $totalCount) {
    Write-Host "[OK] All APIs are healthy and properly configured!" -ForegroundColor Green
}
else {
    Write-Host "[Warning] Some checks need attention - see details above" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "  1. For full testing with Cognito auth, run: .\test_api_gateways.ps1" -ForegroundColor Gray
Write-Host "  2. See docs\reports\API_TESTING_GUIDE.md for detailed testing instructions" -ForegroundColor Gray
Write-Host ""
