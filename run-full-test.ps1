# Full end-to-end test script
# 1. MySQL startup & init check
# 2. Backend startup
# 3. API tests
# 4. Demo endpoint tests (slow vs fast)
# 5. Backend stop
# 6. MySQL reset to initial state

$ErrorActionPreference = "Continue"
$projectRoot = $PSScriptRoot
$jarPath = "$projectRoot\backend\target\sql-tuning-demo-1.0.0.jar"
$passed = 0
$failed = 0

function Write-Step($msg) { Write-Host "`n==> $msg" -ForegroundColor Cyan }
function Write-OK($msg)   { Write-Host "  [OK] $msg" -ForegroundColor Green;  $script:passed++ }
function Write-NG($msg)   { Write-Host "  [NG] $msg" -ForegroundColor Red;    $script:failed++ }
function Write-Info($msg) { Write-Host "       $msg" -ForegroundColor Gray }

# --- STEP 1: Docker / MySQL ---
Write-Step "STEP 1: Docker start & MySQL init check"

wsl docker compose -f "/mnt/c/Users/charg/myWorkspace/db-performance-tuning/docker-compose.yml" up -d 2>&1 | Out-Null

$mysqlReady = $false
for ($i = 1; $i -le 40; $i++) {
    Start-Sleep -Seconds 3
    $ping = wsl docker exec sql-tuning-mysql mysqladmin ping -ppassword --silent 2>&1
    if ($ping -match "alive|mysqld is alive") { $mysqlReady = $true; break }
    Write-Info "Waiting for MySQL... $i/40"
}

if (-not $mysqlReady) { Write-NG "MySQL startup timeout"; exit 1 }
Write-OK "MySQL started"

# Check record counts
$counts = wsl docker exec sql-tuning-mysql mysql -uroot -ppassword sakila `
    -e "SELECT COUNT(*) FROM film; SELECT COUNT(*) FROM actor; SELECT COUNT(*) FROM customer;" 2>&1
$nums = $counts | Select-String '^\d+$' | ForEach-Object { $_.Line.Trim() }
$filmCount = [int]$nums[0]; $actorCount = [int]$nums[1]; $customerCount = [int]$nums[2]

if ($filmCount -ge 1000)    { Write-OK "film: $filmCount rows" }    else { Write-NG "film: $filmCount rows (expected 1000+)" }
if ($actorCount -ge 200)    { Write-OK "actor: $actorCount rows" }   else { Write-NG "actor: $actorCount rows (expected 200+)" }
if ($customerCount -ge 599) { Write-OK "customer: $customerCount rows" } else { Write-NG "customer: $customerCount rows (expected 599+)" }

# --- STEP 2: Backend startup ---
Write-Step "STEP 2: Backend (Spring Boot) startup"

# Get WSL2 IP to access MySQL running in Docker inside WSL2
$wslIp = (wsl hostname -I 2>&1).Trim().Split(' ')[0]
Write-Info "WSL2 IP: $wslIp"
$jdbcUrl = "jdbc:mysql://${wslIp}:3306/sakila?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true"

Get-Process -Name java -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 2

$javaArgs = "-jar `"$jarPath`" --spring.datasource.url=`"$jdbcUrl`""
$javaProc = Start-Process -FilePath "java" -ArgumentList $javaArgs `
    -WindowStyle Hidden -PassThru
Write-Info "PID: $($javaProc.Id)"

$backendReady = $false
for ($i = 1; $i -le 30; $i++) {
    Start-Sleep -Seconds 3
    try {
        $r = Invoke-WebRequest -Uri "http://localhost:8080/api/auth/test" `
            -TimeoutSec 2 -UseBasicParsing -ErrorAction Stop
        if ($r.StatusCode -eq 200) { $backendReady = $true; break }
    } catch {}
    Write-Info "Waiting for backend... $i/30"
}

if (-not $backendReady) { Write-NG "Backend startup timeout"; Stop-Process -Id $javaProc.Id -Force; exit 1 }
Write-OK "Backend started (http://localhost:8080)"

# --- STEP 3: Auth tests ---
Write-Step "STEP 3: Auth tests"

$authTest = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/test" -Method GET
Write-OK "/api/auth/test: $authTest"

$loginBody = '{"username":"demo","password":"password"}'
$loginHeaders = @{"Content-Type"="application/json"}
$loginResp = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/login" `
    -Method POST -Headers $loginHeaders -Body $loginBody
$token = $loginResp.token
$authHeaders = @{ "Authorization"="Bearer $token"; "Content-Type"="application/json" }
Write-OK "Login OK (user: $($loginResp.username))"
Write-Info "Token: $($token.Substring(0,40))..."

# --- STEP 4: API tests ---
Write-Step "STEP 4: API tests"

# actors
$actors = Invoke-RestMethod -Uri "http://localhost:8080/api/actors?page=1&size=5" `
    -Method GET -Headers $authHeaders
if ($actors.Count -gt 0) { Write-OK "/api/actors: $($actors.Count) rows (e.g. $($actors[0].first_name) $($actors[0].last_name))" }
else { Write-NG "/api/actors: 0 rows" }

# films
$films = Invoke-RestMethod -Uri "http://localhost:8080/api/films?page=1&size=5" `
    -Method GET -Headers $authHeaders
if ($films.Count -gt 0) { Write-OK "/api/films: $($films.Count) rows (e.g. $($films[0].title))" }
else { Write-NG "/api/films: 0 rows" }

# customers/fast (returns CustomerResponse object with .customers list)
$custResp = Invoke-RestMethod -Uri "http://localhost:8080/api/customers/fast" `
    -Method GET -Headers $authHeaders
if ($custResp.customers.Count -gt 0) { Write-OK "/api/customers/fast: $($custResp.customers.Count) rows" }
else { Write-NG "/api/customers/fast: 0 rows" }

# --- STEP 5: Demo endpoints (slow vs fast) ---
Write-Step "STEP 5: Demo endpoint speed comparison"

function Measure-Endpoint($label, $uri) {
    try {
        $r = Invoke-RestMethod -Uri $uri -Method GET -Headers $authHeaders -TimeoutSec 30
        # Responses are FilmResponse/CustomerResponse objects with .executionTimeMs and .films/.customers
        $dbMs = if ($r.executionTimeMs) { $r.executionTimeMs } else { 0 }
        $count = if ($r.films) { $r.films.Count } elseif ($r.customers) { $r.customers.Count } elseif ($r -is [array]) { $r.Count } else { 1 }
        Write-Info "${label}: ${dbMs}ms DB / ${count} rows"
        return $dbMs
    } catch {
        Write-NG "${label}: error - $($_.Exception.Message)"
        return -1
    }
}

Write-Info "--- Title search (LIKE) ---"
$slowSearch = Measure-Endpoint "slow /films/search/slow" "http://localhost:8080/api/films/search/slow?title=ACADEMY"
$fastSearch = Measure-Endpoint "fast /films/search/fast" "http://localhost:8080/api/films/search/fast?title=ACADEMY"
if ($slowSearch -gt 0 -and $fastSearch -gt 0) { Write-OK "Title search: slow=${slowSearch}ms / fast=${fastSearch}ms" }

Write-Info "--- Film with language (N+1 vs JOIN) ---"
$slowLang = Measure-Endpoint "slow /films/with-language/slow" "http://localhost:8080/api/films/with-language/slow"
$fastLang = Measure-Endpoint "fast /films/with-language/fast" "http://localhost:8080/api/films/with-language/fast"
if ($slowLang -gt 0 -and $fastLang -gt 0) { Write-OK "Film+language: slow=${slowLang}ms / fast=${fastLang}ms" }

Write-Info "--- Complex search (subquery vs JOIN) ---"
$slowComplex = Measure-Endpoint "slow /films/complex/slow" "http://localhost:8080/api/films/complex/slow?minLength=100"
$fastComplex = Measure-Endpoint "fast /films/complex/fast" "http://localhost:8080/api/films/complex/fast?minLength=100"
if ($slowComplex -gt 0 -and $fastComplex -gt 0) { Write-OK "Complex search: slow=${slowComplex}ms / fast=${fastComplex}ms" }

Write-Info "--- Customer fetch (JOIN optimization) ---"
$slowCust = Measure-Endpoint "slow /customers/slow" "http://localhost:8080/api/customers/slow"
$fastCust = Measure-Endpoint "fast /customers/fast" "http://localhost:8080/api/customers/fast"
if ($slowCust -gt 0 -and $fastCust -gt 0) { Write-OK "Customer fetch: slow=${slowCust}ms / fast=${fastCust}ms" }

# --- STEP 6: Stop backend ---
Write-Step "STEP 6: Stop backend"
Stop-Process -Id $javaProc.Id -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2
Write-OK "Backend stopped"

# --- STEP 7: MySQL reset ---
Write-Step "STEP 7: Reset MySQL to initial state"

wsl docker compose -f "/mnt/c/Users/charg/myWorkspace/db-performance-tuning/docker-compose.yml" down -v 2>&1 | Out-Null
Write-Info "Volume deleted"

wsl docker compose -f "/mnt/c/Users/charg/myWorkspace/db-performance-tuning/docker-compose.yml" up -d 2>&1 | Out-Null
Write-Info "Container recreated, running init scripts..."

$resetReady = $false
for ($i = 1; $i -le 60; $i++) {
    Start-Sleep -Seconds 5
    $ping = wsl docker exec sql-tuning-mysql mysqladmin ping -ppassword --silent 2>&1
    if ($ping -match "alive|mysqld is alive") { $resetReady = $true; break }
    Write-Info "Waiting for MySQL init... $i/60"
}

if (-not $resetReady) { Write-NG "MySQL reset timeout"; exit 1 }

# Poll until init scripts finish (film >= 1000 means data load is complete)
$initDone = $false
for ($i = 1; $i -le 60; $i++) {
    Start-Sleep -Seconds 5
    $resetCounts = wsl docker exec sql-tuning-mysql mysql -uroot -ppassword sakila `
        -e "SELECT COUNT(*) FROM film; SELECT COUNT(*) FROM actor; SELECT COUNT(*) FROM customer;" 2>&1
    $resetNums = $resetCounts | Select-String '^\d+$' | ForEach-Object { $_.Line.Trim() }
    if ($resetNums.Count -ge 3) {
        $rf = [int]$resetNums[0]; $ra = [int]$resetNums[1]; $rc = [int]$resetNums[2]
        Write-Info "Init check $i/60: film=$rf actor=$ra customer=$rc"
        if ($rf -ge 1000 -and $ra -ge 200 -and $rc -ge 599) {
            Write-OK "Reset complete: film=$rf / actor=$ra / customer=$rc"
            $initDone = $true; break
        }
    } else {
        Write-Info "Init check $i/60: tables not yet accessible"
    }
}
if (-not $initDone) { Write-NG "Init scripts did not complete in time" }

# --- Summary ---
Write-Host "`n================================================" -ForegroundColor Cyan
Write-Host "  Test complete  |  OK: $passed  NG: $failed" -ForegroundColor $(if ($failed -eq 0) { "Green" } else { "Yellow" })
Write-Host "================================================`n" -ForegroundColor Cyan
