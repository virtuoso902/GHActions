#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}GitHub Actions Self-Hosted Runner - Startup Script${NC}"
echo "=================================================="

# Check if .env exists
if [ ! -f .env ]; then
    echo -e "${RED}Error: .env file not found${NC}"
    echo "Please copy .env.example to .env and configure it:"
    echo "  cp .env.example .env"
    exit 1
fi

# Load environment variables
source .env

# Validate required variables
if [ -z "$GITHUB_TOKEN" ]; then
    echo -e "${RED}Error: GITHUB_TOKEN is not set in .env${NC}"
    exit 1
fi

if [ -z "$GITHUB_REPOSITORY" ] && [ -z "$GITHUB_ORGANIZATION" ]; then
    echo -e "${RED}Error: Either GITHUB_REPOSITORY or GITHUB_ORGANIZATION must be set${NC}"
    exit 1
fi

# Display configuration
echo -e "${YELLOW}Configuration:${NC}"
if [ -n "$GITHUB_REPOSITORY" ]; then
    echo "  Repository: $GITHUB_REPOSITORY"
else
    echo "  Organization: $GITHUB_ORGANIZATION"
fi
echo "  Runner Name: ${RUNNER_NAME:-ephemeral-runner}"
echo "  Ephemeral: ${EPHEMERAL:-true}"
echo ""

# Check Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Error: Docker is not installed${NC}"
    exit 1
fi

if ! docker info &> /dev/null; then
    echo -e "${RED}Error: Docker daemon is not running${NC}"
    exit 1
fi

# Build and start runner
echo -e "${GREEN}Building Docker image...${NC}"
docker-compose build

echo -e "${GREEN}Starting runner...${NC}"
docker-compose up -d

echo ""
echo -e "${GREEN}Runner started successfully!${NC}"
echo "Commands:"
echo "  View logs: docker-compose logs -f"
echo "  Stop runner: docker-compose down"
echo "  Scale runners: docker-compose up -d --scale runner=3"