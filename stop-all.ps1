# SQLチューニングデモアプリケーション停止スクリプト

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "SQLチューニングデモ停止中..." -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# 1. Javaプロセス（バックエンド）を停止
Write-Host "[1/3] バックエンドを停止しています..." -ForegroundColor Yellow
$javaProcesses = Get-Process -Name java -ErrorAction SilentlyContinue
if ($javaProcesses) {
    $javaProcesses | Stop-Process -Force
    Write-Host "バックエンドを停止しました" -ForegroundColor Green
} else {
    Write-Host "バックエンドは起動していません" -ForegroundColor Gray
}

Write-Host ""

# 2. Nodeプロセス（フロントエンド）を停止
Write-Host "[2/3] フロントエンドを停止しています..." -ForegroundColor Yellow
$nodeProcesses = Get-Process -Name node -ErrorAction SilentlyContinue
if ($nodeProcesses) {
    $nodeProcesses | Stop-Process -Force
    Write-Host "フロントエンドを停止しました" -ForegroundColor Green
} else {
    Write-Host "フロントエンドは起動していません" -ForegroundColor Gray
}

Write-Host ""

# 3. Dockerコンテナを停止
Write-Host "[3/3] MySQLコンテナを停止しています..." -ForegroundColor Yellow
docker-compose down

if ($LASTEXITCODE -eq 0) {
    Write-Host "MySQLコンテナを停止しました" -ForegroundColor Green
} else {
    Write-Host "警告: Dockerコンテナの停止に問題がありました" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "==================================" -ForegroundColor Green
Write-Host "停止完了！" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Green
