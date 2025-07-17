#!/bin/bash
set -e

echo "🔍 Validating GitHub Actions Runner Configuration"
echo "==============================================="

# Load configuration
source .env

# Check for organization or repository mode
if [ -n "$GITHUB_ORGANIZATION" ]; then
    echo "🏢 Mode: Organization-level"
    echo "Organization: $GITHUB_ORGANIZATION"
    
    # Check required variables for organization mode
    required_vars=("GITHUB_TOKEN" "GITHUB_ORGANIZATION" "RUNNER_NAME")
    for var in "${required_vars[@]}"; do
        if [ -z "${!var}" ]; then
            echo "❌ Error: $var is not set"
            exit 1
        fi
    done
    
    # Validate GitHub API access
    echo "🔐 Validating GitHub API access..."
    if gh api "orgs/$GITHUB_ORGANIZATION/actions/runners" > /dev/null 2>&1; then
        echo "✅ GitHub API access confirmed"
    else
        echo "❌ Error: Cannot access GitHub API for organization"
        exit 1
    fi
    
    # Check OAuth token permissions
    echo "🔐 Validating OAuth token permissions..."
    token_info=$(gh auth status 2>&1)
    if echo "$token_info" | grep -q "admin:org"; then
        echo "✅ OAuth token has admin:org permissions"
    else
        echo "❌ Warning: OAuth token may be missing admin:org permissions"
    fi
    
elif [ -n "$GITHUB_REPOSITORY" ]; then
    echo "📁 Mode: Repository-level"
    echo "Repository: $GITHUB_REPOSITORY"
    
    # Check required variables for repository mode
    required_vars=("GITHUB_TOKEN" "GITHUB_REPOSITORY" "RUNNER_NAME")
    for var in "${required_vars[@]}"; do
        if [ -z "${!var}" ]; then
            echo "❌ Error: $var is not set"
            exit 1
        fi
    done
    
    # Validate GitHub API access
    echo "🔐 Validating GitHub API access..."
    if gh api "repos/$GITHUB_REPOSITORY/actions/runners" > /dev/null 2>&1; then
        echo "✅ GitHub API access confirmed"
    else
        echo "❌ Error: Cannot access GitHub API for repository"
        exit 1
    fi
    
else
    echo "❌ Error: Neither GITHUB_ORGANIZATION nor GITHUB_REPOSITORY is set"
    exit 1
fi

# Validate Docker setup
echo "🐳 Validating Docker setup..."
if docker info > /dev/null 2>&1; then
    echo "✅ Docker is accessible"
else
    echo "❌ Error: Docker is not accessible"
    exit 1
fi

# Validate Docker Compose
echo "🐳 Validating Docker Compose..."
if docker-compose --version > /dev/null 2>&1; then
    echo "✅ Docker Compose is available"
else
    echo "❌ Error: Docker Compose is not available"
    exit 1
fi

echo ""
echo "✅ Configuration validation passed"