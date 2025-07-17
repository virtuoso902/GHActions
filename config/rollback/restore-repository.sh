#!/bin/bash
set -e

# Complete restoration script
echo "🔄 Complete Repository-Level Restoration"
echo "======================================="

# Stop all containers
echo "⏹️  Stopping all containers..."
./scripts/stop.sh

# Restore all configuration files
echo "📁 Restoring configuration files..."
if [ -f ".env.repository-backup" ]; then
    cp .env.repository-backup .env
    echo "✅ Environment configuration restored"
else
    echo "❌ Error: No backup configuration found"
    exit 1
fi

if [ -f "docker/entrypoint.sh.backup" ]; then
    cp docker/entrypoint.sh.backup docker/entrypoint.sh
    echo "✅ Entrypoint script restored"
fi

# Rebuild with repository configuration
echo "🔨 Rebuilding with repository configuration..."
docker-compose build

echo "🚀 Starting repository-level runner..."
docker-compose up -d

echo ""
echo "✅ Complete restoration completed!"
echo "📊 Verify status with: ./scripts/status.sh"