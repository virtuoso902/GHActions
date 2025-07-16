#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}GitHub Actions Runner Status${NC}"
echo "============================"

# Check Docker status
if ! docker info &> /dev/null; then
    echo -e "${RED}Error: Docker is not running${NC}"
    exit 1
fi

# Check if runners are running
RUNNING_CONTAINERS=$(docker-compose ps -q 2>/dev/null | wc -l)

if [ "$RUNNING_CONTAINERS" -eq 0 ]; then
    echo -e "${YELLOW}No runners are currently running${NC}"
    echo "Start runners with: ./scripts/start.sh"
else
    echo -e "${GREEN}Active runners: $RUNNING_CONTAINERS${NC}"
    echo ""
    docker-compose ps
    echo ""
    echo "View logs with: docker-compose logs -f"
fi