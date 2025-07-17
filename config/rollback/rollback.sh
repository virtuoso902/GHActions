#!/bin/bash
set -e

echo "🔄 Rolling back to repository-level runner..."
echo "============================================="

# Stop current runner
echo "⏹️  Stopping organization-level runner..."
./scripts/stop.sh

# Restore repository-level configuration
echo "📁 Restoring repository-level configuration..."
if [ -f ".env.repository-backup" ]; then
    cp .env.repository-backup .env
    echo "✅ Repository configuration restored"
else
    echo "❌ Error: No backup configuration found"
    exit 1
fi

# Restart with repository-level configuration
echo "🚀 Starting repository-level runner..."
./scripts/start.sh

echo ""
echo "✅ Rollback completed successfully!"
echo "📊 Verify status with: ./scripts/status.sh"