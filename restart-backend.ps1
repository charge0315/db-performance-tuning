# バックエンド再起動スクリプト

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "バックエンド再起動中..." -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# 既存のJavaプロセスを停止
Write-Host "[1/2] 既存のバックエンドを停止中..." -ForegroundColor Yellow
$javaProcesses = Get-Process -Name java -ErrorAction SilentlyContinue
if ($javaProcesses) {
    $javaProcesses | Stop-Process -Force
    Start-Sleep -Seconds 2
    Write-Host "停止完了" -ForegroundColor Green
} else {
    Write-Host "起動中のバックエンドはありません" -ForegroundColor Gray
}

Write-Host ""

# バックエンドを起動
Write-Host "[2/2] バックエンドを起動中..." -ForegroundColor Yellow
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

Start-Process -NoNewWindow powershell -ArgumentList "java -jar `"$jarPath`""
Start-Sleep -Seconds 3

# 起動確認
$maxRetries = 20
$retryCount = 0
$backendReady = $false

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
    Write-Host "警告: バックエンドの起動確認がタイムアウトしました" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "==================================" -ForegroundColor Green
Write-Host "再起動完了！" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Green
Write-Host "バックエンドAPI: http://localhost:8080/api" -ForegroundColor White
