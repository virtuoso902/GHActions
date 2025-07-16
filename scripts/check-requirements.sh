#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}GitHub Actions Runner - Requirements Check${NC}"
echo "=========================================="
echo ""

REQUIREMENTS_MET=true

# Check Docker
echo -n "Docker: "
if command -v docker &> /dev/null; then
    DOCKER_VERSION=$(docker --version | cut -d' ' -f3 | tr -d ',')
    echo -e "${GREEN}✓ Installed (${DOCKER_VERSION})${NC}"
    
    # Check if Docker daemon is running
    echo -n "Docker Daemon: "
    if docker info &> /dev/null; then
        echo -e "${GREEN}✓ Running${NC}"
    else
        echo -e "${RED}✗ Not running${NC}"
        echo -e "${YELLOW}  Fix: Start Docker Desktop or run 'sudo systemctl start docker'${NC}"
        REQUIREMENTS_MET=false
    fi
else
    echo -e "${RED}✗ Not installed${NC}"
    echo -e "${YELLOW}  Fix: Install Docker Desktop from https://www.docker.com/products/docker-desktop${NC}"
    REQUIREMENTS_MET=false
fi

# Check Docker Compose
echo -n "Docker Compose: "
if command -v docker-compose &> /dev/null || docker compose version &> /dev/null 2>&1; then
    if command -v docker-compose &> /dev/null; then
        COMPOSE_VERSION=$(docker-compose --version | cut -d' ' -f3 | tr -d ',')
    else
        COMPOSE_VERSION=$(docker compose version | cut -d' ' -f4)
    fi
    echo -e "${GREEN}✓ Installed (${COMPOSE_VERSION})${NC}"
else
    echo -e "${RED}✗ Not installed${NC}"
    echo -e "${YELLOW}  Fix: Docker Compose is usually included with Docker Desktop${NC}"
    REQUIREMENTS_MET=false
fi

# Check .env file
echo -n ".env file: "
if [ -f .env ]; then
    echo -e "${GREEN}✓ Exists${NC}"
    
    # Check if token is configured
    echo -n "GitHub Token: "
    if grep -q "YOUR_GITHUB_TOKEN_HERE" .env; then
        echo -e "${RED}✗ Not configured${NC}"
        echo -e "${YELLOW}  Fix: Run ./scripts/setup-token.sh to configure${NC}"
        REQUIREMENTS_MET=false
    else
        echo -e "${GREEN}✓ Configured${NC}"
    fi
else
    echo -e "${RED}✗ Not found${NC}"
    echo -e "${YELLOW}  Fix: Run ./scripts/setup-token.sh to create${NC}"
    REQUIREMENTS_MET=false
fi

# Check network connectivity
echo -n "GitHub API Access: "
if curl -s -o /dev/null -w "%{http_code}" https://api.github.com/meta | grep -q "200"; then
    echo -e "${GREEN}✓ Connected${NC}"
else
    echo -e "${RED}✗ Cannot reach GitHub${NC}"
    echo -e "${YELLOW}  Fix: Check internet connection and firewall settings${NC}"
    REQUIREMENTS_MET=false
fi

echo ""
if [ "$REQUIREMENTS_MET" = true ]; then
    echo -e "${GREEN}✅ All requirements met! You can run ./scripts/start.sh${NC}"
    exit 0
else
    echo -e "${RED}❌ Some requirements are missing. Please fix the issues above.${NC}"
    exit 1
fi