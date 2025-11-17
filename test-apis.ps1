# API Test Script for SQL Tuning Demo
Write-Host "`n================================================"
Write-Host "  SQL Tuning Demo - API Test Suite"
Write-Host "================================================`n"

# 1. Test Auth Test Endpoint
Write-Host "[ 1 ] Testing /api/auth/test endpoint..."
try {
    $response = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/test" -Method GET
    Write-Host "  ✓ Success: $response`n" -ForegroundColor Green
} catch {
    Write-Host "  ✗ Failed: $($_.Exception.Message)`n" -ForegroundColor Red
    exit 1
}

# 2. Test Login
Write-Host "[ 2 ] Testing Login (demo/password)..."
$headers = @{"Content-Type"="application/json"}
$body = '{"username":"demo","password":"password"}'
try {
    $response = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/login" -Method POST -Headers $headers -Body $body
    Write-Host "  ✓ Login Success!" -ForegroundColor Green
    Write-Host "    Username: $($response.username)"
    Write-Host "    Token: $($response.token.Substring(0,40))...`n"
    $global:token = $response.token
    $global:authHeaders = @{
        "Authorization"="Bearer $($global:token)"
        "Content-Type"="application/json"
    }
} catch {
    Write-Host "  ✗ Login Failed: $($_.Exception.Message)`n" -ForegroundColor Red
    exit 1
}

# 3. Test Actor Endpoints
Write-Host "[ 3 ] Testing /api/actors endpoint..."
try {
    $response = Invoke-RestMethod -Uri "http://localhost:8080/api/actors?page=1&size=5" -Method GET -Headers $global:authHeaders
    Write-Host "  ✓ Retrieved $($response.Count) actors" -ForegroundColor Green
    if ($response.Count -gt 0) {
        Write-Host "    Sample: $($response[0].first_name) $($response[0].last_name)`n"
    }
} catch {
    Write-Host "  ✗ Failed: $($_.Exception.Message)`n" -ForegroundColor Red
}

# 4. Test Film Endpoints
Write-Host "[ 4 ] Testing /api/films endpoint..."
try {
    $response = Invoke-RestMethod -Uri "http://localhost:8080/api/films?page=1&size=5" -Method GET -Headers $global:authHeaders
    Write-Host "  ✓ Retrieved $($response.Count) films" -ForegroundColor Green
    if ($response.Count -gt 0) {
        Write-Host "    Sample: $($response[0].title)`n"
    }
} catch {
    Write-Host "  ✗ Failed: $($_.Exception.Message)`n" -ForegroundColor Red
}

# 5. Test Customer Endpoints
Write-Host "[ 5 ] Testing /api/customers/fast endpoint..."
try {
    $response = Invoke-RestMethod -Uri "http://localhost:8080/api/customers/fast" -Method GET -Headers $global:authHeaders
    Write-Host "  ✓ Retrieved $($response.Count) customers" -ForegroundColor Green
    if ($response.Count -gt 0) {
        Write-Host "    Sample: $($response[0].first_name) $($response[0].last_name)`n"
    }
} catch {
    Write-Host "  ✗ Failed: $($_.Exception.Message)`n" -ForegroundColor Red
}

Write-Host "================================================"
Write-Host "  Test Suite Completed!"
Write-Host "================================================`n"
