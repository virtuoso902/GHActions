#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}GitHub Actions Runner - Token Setup${NC}"
echo "===================================="
echo ""

# Check if .env already exists
if [ -f .env ]; then
    echo -e "${YELLOW}Warning: .env file already exists${NC}"
    read -p "Do you want to overwrite it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Setup cancelled"
        exit 0
    fi
fi

# Instructions for creating token
echo -e "${BLUE}To create a GitHub Personal Access Token:${NC}"
echo "1. Open: https://github.com/settings/tokens/new"
echo "2. Give it a descriptive name (e.g., 'Self-Hosted Runner')"
echo "3. Set expiration (recommend 90 days)"
echo "4. Select scopes:"
echo "   - For repository runner: Select 'repo' (Full control)"
echo "   - For organization runner: Select 'admin:org'"
echo "5. Click 'Generate token' and copy it"
echo ""

# Get token
echo -e "${YELLOW}Enter your GitHub Personal Access Token:${NC}"
read -s GITHUB_TOKEN
echo ""

# Validate token format
if [[ ! "$GITHUB_TOKEN" =~ ^(ghp_[a-zA-Z0-9]{36}|github_pat_[a-zA-Z0-9]{22}_[a-zA-Z0-9]{59})$ ]]; then
    echo -e "${RED}Error: Invalid token format${NC}"
    echo "GitHub tokens should start with 'ghp_' or 'github_pat_'"
    exit 1
fi

# Get repository or organization
echo -e "${YELLOW}Choose runner scope:${NC}"
echo "1) Repository-level runner"
echo "2) Organization-level runner"
read -p "Enter choice (1 or 2): " -n 1 -r
echo ""

if [[ $REPLY == "1" ]]; then
    echo -e "${YELLOW}Enter repository (format: owner/repo):${NC}"
    read GITHUB_REPOSITORY
    
    # Validate repository format
    if [[ ! "$GITHUB_REPOSITORY" =~ ^[a-zA-Z0-9._-]+/[a-zA-Z0-9._-]+$ ]]; then
        echo -e "${RED}Error: Invalid repository format${NC}"
        echo "Use format: owner/repo (e.g., virtuoso902/GHActions)"
        exit 1
    fi
    
    # Create .env file
    cat > .env << EOF
# GitHub Actions Self-Hosted Runner Configuration

# GitHub Personal Access Token
GITHUB_TOKEN=$GITHUB_TOKEN

# Repository runner
GITHUB_REPOSITORY=$GITHUB_REPOSITORY

# Runner configuration
RUNNER_NAME=ephemeral-runner
RUNNER_GROUP=default
LABELS=self-hosted,Linux,X64,ephemeral,docker
EPHEMERAL=true
EOF

elif [[ $REPLY == "2" ]]; then
    echo -e "${YELLOW}Enter organization name:${NC}"
    read GITHUB_ORGANIZATION
    
    # Create .env file
    cat > .env << EOF
# GitHub Actions Self-Hosted Runner Configuration

# GitHub Personal Access Token
GITHUB_TOKEN=$GITHUB_TOKEN

# Organization runner
GITHUB_ORGANIZATION=$GITHUB_ORGANIZATION

# Runner configuration
RUNNER_NAME=ephemeral-runner
RUNNER_GROUP=default
LABELS=self-hosted,Linux,X64,ephemeral,docker
EPHEMERAL=true
EOF

else
    echo -e "${RED}Invalid choice${NC}"
    exit 1
fi

# Set permissions
chmod 600 .env

echo ""
echo -e "${GREEN}✅ Configuration saved to .env${NC}"
echo -e "${GREEN}✅ File permissions set to 600 (read/write for owner only)${NC}"
echo ""
echo "Next step: Run ./scripts/start.sh to start the runner"