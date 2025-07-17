#!/bin/bash
set -e

echo "🧪 Testing Multi-Repository Access"
echo "================================="

# Load configuration
source .env

if [ -z "$GITHUB_ORGANIZATION" ]; then
    echo "❌ Error: GITHUB_ORGANIZATION not set (required for multi-repo testing)"
    exit 1
fi

echo "Organization: $GITHUB_ORGANIZATION"
echo ""

# Test repositories
repositories=("coach" "mcp" "personal" "ghActions")

echo "🔍 Testing repository access..."
for repo in "${repositories[@]}"; do
    echo -n "Testing repository: virtuoso902/$repo... "
    
    # Check if repository exists and is accessible
    if gh api "repos/virtuoso902/$repo" > /dev/null 2>&1; then
        echo "✅ accessible"
    else
        echo "❌ not accessible"
    fi
done

echo ""
echo "🏃 Testing organization runner assignment..."
runner_info=$(gh api "orgs/$GITHUB_ORGANIZATION/actions/runners" \
    --jq '.runners[] | select(.name | contains("'"${RUNNER_NAME:-ephemeral}"'")) | {name: .name, status: .status, busy: .busy}')

if [ -n "$runner_info" ]; then
    echo "✅ Organization runner found:"
    echo "$runner_info"
else
    echo "❌ No organization runner found"
fi

echo ""
echo "🧪 Multi-repository test completed"