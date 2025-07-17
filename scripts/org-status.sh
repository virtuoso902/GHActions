#!/bin/bash
set -e

# Organization runner status script
source .env

echo "🏢 Organization Runner Status"
echo "============================"

# Check if we're in organization mode
if [ -n "$GITHUB_ORGANIZATION" ]; then
    echo "Organization: $GITHUB_ORGANIZATION"
    echo "Runner Group: ${RUNNER_GROUP:-default}"
    echo "Mode: Organization-level"
    echo ""
    
    # Check runner status via GitHub API
    echo "📊 GitHub API Status:"
    gh api "orgs/$GITHUB_ORGANIZATION/actions/runners" \
        --jq '.runners[] | select(.name | contains("'"${RUNNER_NAME:-ephemeral}"'")) | {name: .name, status: .status, busy: .busy, labels: [.labels[].name]}' \
        || echo "❌ No organization runners found or API error"
        
elif [ -n "$GITHUB_REPOSITORY" ]; then
    echo "Repository: $GITHUB_REPOSITORY"
    echo "Mode: Repository-level"
    echo ""
    
    # Check repository runner status
    echo "📊 GitHub API Status:"
    gh api "repos/$GITHUB_REPOSITORY/actions/runners" \
        --jq '.runners[] | select(.name | contains("'"${RUNNER_NAME:-ephemeral}"'")) | {name: .name, status: .status, busy: .busy, labels: [.labels[].name]}' \
        || echo "❌ No repository runners found or API error"
else
    echo "❌ Error: Neither GITHUB_ORGANIZATION nor GITHUB_REPOSITORY is set"
    exit 1
fi

echo ""
echo "🐳 Container Status:"
docker-compose ps

echo ""
echo "📈 Recent Activity:"
docker-compose logs --tail 10 | grep -E "(Listening|Running|Completed)" || echo "No recent activity"