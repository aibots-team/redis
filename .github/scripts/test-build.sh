#!/bin/bash

# Redis 构建测试脚本
# 用于验证构建的 Redis 二进制文件是否正常工作

set -e

REDIS_VERSION=${1:-"8.2.1"}
PLATFORM=${2:-"linux-x64"}

echo "Testing Redis $REDIS_VERSION for $PLATFORM..."

# 解压构建包
if [[ "$PLATFORM" == *"windows"* ]]; then
    unzip -q "redis-$REDIS_VERSION-$PLATFORM.zip"
else
    tar -xzf "redis-$REDIS_VERSION-$PLATFORM.tar.gz"
fi

cd "redis-$REDIS_VERSION-$PLATFORM"

# 检查二进制文件是否存在
echo "Checking binary files..."
required_binaries=("redis-server" "redis-cli" "redis-benchmark" "redis-check-aof" "redis-check-rdb" "redis-sentinel")
for binary in "${required_binaries[@]}"; do
    if [[ "$PLATFORM" == *"windows"* ]]; then
        binary="$binary.exe"
    fi
    
    if [[ -f "$binary" ]]; then
        echo "✓ $binary found"
    else
        echo "✗ $binary not found"
        exit 1
    fi
done

# 检查配置文件
echo "Checking configuration files..."
if [[ -f "redis.conf" ]]; then
    echo "✓ redis.conf found"
else
    echo "✗ redis.conf not found"
    exit 1
fi

if [[ -f "sentinel.conf" ]]; then
    echo "✓ sentinel.conf found"
else
    echo "✗ sentinel.conf not found"
    exit 1
fi

# 测试 Redis 版本
echo "Testing Redis version..."
if [[ "$PLATFORM" == *"windows"* ]]; then
    VERSION_OUTPUT=$(./redis-server.exe --version 2>&1 || true)
else
    VERSION_OUTPUT=$(./redis-server --version 2>&1 || true)
fi

if echo "$VERSION_OUTPUT" | grep -q "$REDIS_VERSION"; then
    echo "✓ Version check passed: $VERSION_OUTPUT"
else
    echo "✗ Version check failed. Expected: $REDIS_VERSION, Got: $VERSION_OUTPUT"
    exit 1
fi

# 测试 Redis CLI 帮助
echo "Testing Redis CLI..."
if [[ "$PLATFORM" == *"windows"* ]]; then
    HELP_OUTPUT=$(./redis-cli.exe --help 2>&1 || true)
else
    HELP_OUTPUT=$(./redis-cli --help 2>&1 || true)
fi

if echo "$HELP_OUTPUT" | grep -q "redis-cli"; then
    echo "✓ Redis CLI test passed"
else
    echo "✗ Redis CLI test failed"
    exit 1
fi

echo "All tests passed for Redis $REDIS_VERSION on $PLATFORM!"
