# SQLチューニングデモアプリケーション起動スクリプト

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "SQLチューニングデモ起動中..." -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# 1. Dockerコンテナの起動
Write-Host "[1/3] MySQLコンテナを起動しています..." -ForegroundColor Yellow
docker-compose up -d

if ($LASTEXITCODE -ne 0) {
    Write-Host "エラー: Dockerコンテナの起動に失敗しました" -ForegroundColor Red
    exit 1
}

# MySQLが完全に起動するまで待機
Write-Host "MySQLの起動を待機中..." -ForegroundColor Yellow
$maxRetries = 30
$retryCount = 0
$isReady = $false

while (-not $isReady -and $retryCount -lt $maxRetries) {
    $retryCount++
    Start-Sleep -Seconds 2
    
    $result = docker exec sql-tuning-mysql mysqladmin ping -ppassword 2>$null
    if ($result -like "*mysqld is alive*") {
        $isReady = $true
        Write-Host "MySQL起動完了！" -ForegroundColor Green
    } else {
        Write-Host "待機中... ($retryCount/$maxRetries)" -ForegroundColor Gray
    }
}

if (-not $isReady) {
    Write-Host "エラー: MySQLの起動タイムアウト" -ForegroundColor Red
    exit 1
}

Write-Host ""

# 2. バックエンドの起動
Write-Host "[2/3] バックエンド（Spring Boot）を起動しています..." -ForegroundColor Yellow

# 既存のJavaプロセスを停止
$javaProcesses = Get-Process -Name java -ErrorAction SilentlyContinue
if ($javaProcesses) {
    Write-Host "既存のJavaプロセスを停止中..." -ForegroundColor Gray
    $javaProcesses | Stop-Process -Force
    Start-Sleep -Seconds 2
}

# JARファイルの存在確認
$jarPath = "$PSScriptRoot\backend\target\sql-tuning-demo-1.0.0.jar"
if (-not (Test-Path $jarPath)) {
    Write-Host "JARファイルが見つかりません。ビルドを実行します..." -ForegroundColor Yellow
    Set-Location "$PSScriptRoot\backend"
    mvn clean package -DskipTests
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "エラー: ビルドに失敗しました" -ForegroundColor Red
        Set-Location $PSScriptRoot
        exit 1
    }
    Set-Location $PSScriptRoot
}

# バックエンドを起動
Start-Process -NoNewWindow powershell -ArgumentList "java -jar `"$jarPath`""
Start-Sleep -Seconds 3

# バックエンドの起動確認
$backendReady = $false
$maxRetries = 20
$retryCount = 0

while (-not $backendReady -and $retryCount -lt $maxRetries) {
    $retryCount++
    Start-Sleep -Seconds 2
    
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8080/api/auth/test" -TimeoutSec 2 -UseBasicParsing -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) {
            $backendReady = $true
            Write-Host "バックエンド起動完了！" -ForegroundColor Green
        }
    } catch {
        Write-Host "待機中... ($retryCount/$maxRetries)" -ForegroundColor Gray
    }
}

if (-not $backendReady) {
    Write-Host "警告: バックエンドの起動確認がタイムアウトしました（起動は継続しています）" -ForegroundColor Yellow
}

Write-Host ""

# 3. フロントエンドの起動
Write-Host "[3/3] フロントエンド（React）を起動しています..." -ForegroundColor Yellow

# 既存のNodeプロセスを確認
$nodeProcesses = Get-Process -Name node -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowTitle -like "*3000*" }
if ($nodeProcesses) {
    Write-Host "既存のNodeプロセスが検出されました" -ForegroundColor Gray
}

# フロントエンドを起動
Set-Location "$PSScriptRoot\frontend"
Start-Process powershell -ArgumentList "npm start"
Set-Location $PSScriptRoot

Start-Sleep -Seconds 5

Write-Host ""
Write-Host "==================================" -ForegroundColor Green
Write-Host "起動完了！" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Green
Write-Host ""
Write-Host "アクセスURL:" -ForegroundColor Cyan
Write-Host "  フロントエンド: http://localhost:3000" -ForegroundColor White
Write-Host "  バックエンドAPI: http://localhost:8080/api" -ForegroundColor White
Write-Host "  MySQL: localhost:3306" -ForegroundColor White
Write-Host ""
Write-Host "ログイン情報:" -ForegroundColor Cyan
Write-Host "  ユーザー名: demo" -ForegroundColor White
Write-Host "  パスワード: password" -ForegroundColor White
Write-Host ""
Write-Host "停止するには stop-all.ps1 を実行してください" -ForegroundColor Yellow
