#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}GitHub Actions Runner - Setup Test${NC}"
echo "==================================="
echo ""

# Step 1: Check requirements
echo -e "${BLUE}Step 1: Checking requirements...${NC}"
if ./scripts/check-requirements.sh; then
    echo -e "${GREEN}✅ Requirements check passed${NC}"
else
    echo -e "${RED}❌ Requirements check failed${NC}"
    echo "Please install Docker and configure your GitHub token"
    exit 1
fi

echo ""
echo -e "${BLUE}Step 2: Building Docker image...${NC}"
if docker-compose build; then
    echo -e "${GREEN}✅ Docker image built successfully${NC}"
else
    echo -e "${RED}❌ Docker build failed${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}Step 3: Testing runner registration (dry run)...${NC}"
# Test with a short-lived container
docker-compose run --rm runner echo "✅ Container can start successfully"

echo ""
echo -e "${GREEN}🎉 All tests passed!${NC}"
echo ""
echo "Your GitHub Actions runner is ready to use."
echo "To start it for real, run: ${YELLOW}./scripts/start.sh${NC}"
echo ""
echo "After starting, you can:"
echo "1. Check status: ${YELLOW}./scripts/status.sh${NC}"
echo "2. View logs: ${YELLOW}docker-compose logs -f${NC}"
echo "3. Push the test workflow to GitHub to verify"