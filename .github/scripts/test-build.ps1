# Redis 构建测试脚本 (Windows PowerShell)
# 用于验证构建的 Redis 二进制文件是否正常工作

param(
    [string]$Version = "8.2.1",
    [string]$Platform = "windows-x64"
)

Write-Host "Testing Redis $Version for $Platform..." -ForegroundColor Green

# 解压构建包
if ($Platform -like "*windows*") {
    Expand-Archive -Path "redis-$Version-$Platform.zip" -DestinationPath "." -Force
} else {
    Write-Host "This script is for Windows builds only" -ForegroundColor Red
    exit 1
}

Set-Location "redis-$Version-$Platform"

# 检查二进制文件是否存在
Write-Host "Checking binary files..." -ForegroundColor Yellow
$requiredBinaries = @("redis-server.exe", "redis-cli.exe", "redis-benchmark.exe", "redis-check-aof.exe", "redis-check-rdb.exe", "redis-sentinel.exe")

foreach ($binary in $requiredBinaries) {
    if (Test-Path $binary) {
        Write-Host "✓ $binary found" -ForegroundColor Green
    } else {
        Write-Host "✗ $binary not found" -ForegroundColor Red
        exit 1
    }
}

# 检查配置文件
Write-Host "Checking configuration files..." -ForegroundColor Yellow
if (Test-Path "redis.conf") {
    Write-Host "✓ redis.conf found" -ForegroundColor Green
} else {
    Write-Host "✗ redis.conf not found" -ForegroundColor Red
    exit 1
}

if (Test-Path "sentinel.conf") {
    Write-Host "✓ sentinel.conf found" -ForegroundColor Green
} else {
    Write-Host "✗ sentinel.conf not found" -ForegroundColor Red
    exit 1
}

# 测试 Redis 版本
Write-Host "Testing Redis version..." -ForegroundColor Yellow
try {
    $versionOutput = & .\redis-server.exe --version 2>&1
    if ($versionOutput -like "*$Version*") {
        Write-Host "✓ Version check passed: $versionOutput" -ForegroundColor Green
    } else {
        Write-Host "✗ Version check failed. Expected: $Version, Got: $versionOutput" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "✗ Version check failed with error: $_" -ForegroundColor Red
    exit 1
}

# 测试 Redis CLI 帮助
Write-Host "Testing Redis CLI..." -ForegroundColor Yellow
try {
    $helpOutput = & .\redis-cli.exe --help 2>&1
    if ($helpOutput -like "*redis-cli*") {
        Write-Host "✓ Redis CLI test passed" -ForegroundColor Green
    } else {
        Write-Host "✗ Redis CLI test failed" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "✗ Redis CLI test failed with error: $_" -ForegroundColor Red
    exit 1
}

Write-Host "All tests passed for Redis $Version on $Platform!" -ForegroundColor Green
