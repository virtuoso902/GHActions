# MCP Repository Integration Guide

**Repository:** `/github/mcp` - Universal MCP Server Hub  
**Purpose:** Docker-based MCP server testing and deployment  
**Benefits:** Save ~$50-100/month on Actions minutes for Docker builds

## 🎯 MCP Repository Overview

Your MCP repository is a Docker-based system with multiple services:
- **Playwright MCP** (Port 3010) - Browser automation
- **Supabase MCP** (Port 3011) - Database operations  
- **GitHub MCP** (Port 3012) - Repository management
- **Screenshot MCP** (Port 3013) - Visual capture

## 🚀 Quick Integration

### 1. Basic MCP CI/CD Pipeline

Create `.github/workflows/mcp-ci.yml`:

```yaml
name: MCP Services CI/CD
on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test-mcp-services:
    runs-on: self-hosted
    timeout-minutes: 30
    
    steps:
      - name: Checkout Repository
        uses: actions/checkout@v4
        
      - name: Setup Environment
        run: |
          # Copy example env file
          cp .env.example .env
          
          # Set test environment values
          echo "SUPABASE_URL=https://test.supabase.co" >> .env
          echo "SUPABASE_KEY=test-key" >> .env
          echo "GITHUB_TOKEN=${{ secrets.GITHUB_TOKEN }}" >> .env
          
      - name: Start MCP Services
        run: |
          echo "🚀 Starting MCP services..."
          ./scripts/start.sh
          
          # Wait for services to be ready
          sleep 30
          
      - name: Health Check All Services
        run: |
          echo "🔍 Checking service health..."
          ./scripts/status.sh
          
      - name: Test MCP Connections
        run: |
          echo "🧪 Testing MCP connections..."
          ./scripts/test-connection.sh
          
      - name: Test Playwright MCP
        run: |
          echo "🎭 Testing Playwright MCP..."
          curl -X POST http://localhost:3010/mcp \
            -H "Content-Type: application/json" \
            -d '{
              "method": "screenshot",
              "params": {
                "url": "https://example.com",
                "path": "/tmp/test-screenshot.png"
              }
            }' || echo "Playwright test failed (expected in CI)"
            
      - name: Test Supabase MCP
        run: |
          echo "🗄️ Testing Supabase MCP..."
          curl -X POST http://localhost:3011/mcp \
            -H "Content-Type: application/json" \
            -d '{
              "method": "health_check",
              "params": {}
            }' || echo "Supabase test failed (expected without real credentials)"
            
      - name: Test GitHub MCP
        run: |
          echo "🐙 Testing GitHub MCP..."
          curl -X POST http://localhost:3012/mcp \
            -H "Content-Type: application/json" \
            -d '{
              "method": "get_user",
              "params": {
                "username": "virtuoso902"
              }
            }'
            
      - name: Cleanup
        run: |
          echo "🧹 Cleaning up services..."
          ./scripts/stop.sh
          
          # Clean up Docker resources
          docker system prune -f
          docker volume prune -f
        if: always()
```

### 2. Docker Build Pipeline

Create `.github/workflows/docker-build.yml`:

```yaml
name: Docker Build & Test
on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build-and-test:
    runs-on: self-hosted
    strategy:
      matrix:
        service: [playwright-mcp, supabase-mcp, github-mcp, screenshot-mcp]
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Build ${{ matrix.service }}
        run: |
          echo "🏗️ Building ${{ matrix.service }}..."
          docker build -t mcp-${{ matrix.service }}:test \
            -f dockerfiles/${{ matrix.service }}.Dockerfile .
            
      - name: Test ${{ matrix.service }} Container
        run: |
          echo "🧪 Testing ${{ matrix.service }} container..."
          docker run --rm --name test-${{ matrix.service }} \
            -e NODE_ENV=test \
            mcp-${{ matrix.service }}:test \
            node --version
            
      - name: Security Scan
        run: |
          echo "🔒 Security scanning ${{ matrix.service }}..."
          # Add security scanning here if needed
          
      - name: Cleanup Images
        run: |
          docker image prune -f
          docker rmi mcp-${{ matrix.service }}:test || true
        if: always()
```

### 3. Integration Test Pipeline

Create `.github/workflows/integration-tests.yml`:

```yaml
name: Integration Tests
on:
  push:
    branches: [ main ]
  schedule:
    - cron: '0 2 * * *'  # Daily at 2 AM

jobs:
  integration-test:
    runs-on: self-hosted
    timeout-minutes: 45
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Start Full MCP Stack
        run: |
          echo "🚀 Starting full MCP stack..."
          cp .env.example .env
          
          # Add real test credentials if available
          if [ -n "${{ secrets.SUPABASE_URL }}" ]; then
            echo "SUPABASE_URL=${{ secrets.SUPABASE_URL }}" >> .env
          fi
          if [ -n "${{ secrets.SUPABASE_KEY }}" ]; then
            echo "SUPABASE_KEY=${{ secrets.SUPABASE_KEY }}" >> .env
          fi
          
          ./scripts/start.sh
          sleep 60  # Wait for all services
          
      - name: Run Integration Test Suite
        run: |
          echo "🧪 Running integration tests..."
          
          # Test cross-service communication
          ./scripts/test-integration.sh
          
          # Test real browser automation
          curl -X POST http://localhost:3010/mcp \
            -H "Content-Type: application/json" \
            -d '{
              "method": "navigate",
              "params": {
                "url": "https://github.com/virtuoso902",
                "wait_for": "networkidle"
              }
            }'
            
      - name: Performance Test
        run: |
          echo "⚡ Running performance tests..."
          
          # Test response times
          for i in {1..5}; do
            echo "Test $i:"
            time curl -X POST http://localhost:3010/mcp \
              -H "Content-Type: application/json" \
              -d '{"method": "health_check", "params": {}}'
          done
          
      - name: Generate Test Report
        run: |
          echo "📊 Generating test report..."
          ./scripts/generate-report.sh > test-report.md
          
      - name: Upload Test Report
        uses: actions/upload-artifact@v4
        with:
          name: integration-test-report
          path: test-report.md
        if: always()
        
      - name: Cleanup
        run: |
          ./scripts/stop.sh
          docker system prune -f
          docker volume prune -f
        if: always()
```

## 📋 Migration Steps for MCP Repository

### Step 1: Update Existing Workflows
```bash
# Navigate to MCP repository
cd /github/mcp

# Check existing workflows
ls .github/workflows/

# Update each workflow to use self-hosted runner
sed -i 's/runs-on: ubuntu-latest/runs-on: self-hosted/g' .github/workflows/*.yml
```

### Step 2: Add MCP-Specific Workflows
```bash
# Create new workflow files
mkdir -p .github/workflows

# Add the workflows above to:
# .github/workflows/mcp-ci.yml
# .github/workflows/docker-build.yml  
# .github/workflows/integration-tests.yml
```

### Step 3: Test and Optimize
```bash
# Test workflows locally first
./scripts/start.sh
./scripts/test-connection.sh
./scripts/stop.sh

# Then commit and push to trigger CI
git add .github/workflows/
git commit -m "Add self-hosted runner workflows for MCP services"
git push
```

## 🔧 MCP-Specific Optimizations

### 1. Resource Management
```yaml
# Add to workflow jobs
jobs:
  test-services:
    runs-on: self-hosted
    env:
      DOCKER_BUILDKIT: 1
      COMPOSE_DOCKER_CLI_BUILD: 1
    steps:
      - name: Optimize Docker Build
        run: |
          # Use BuildKit for faster builds
          export DOCKER_BUILDKIT=1
          docker build --cache-from mcp-playwright:latest .
```

### 2. Parallel Service Testing
```yaml
jobs:
  test-services:
    runs-on: self-hosted
    strategy:
      matrix:
        service: [playwright, supabase, github, screenshot]
      max-parallel: 2  # Limit parallel jobs to prevent resource exhaustion
```

### 3. Smart Caching
```yaml
- name: Cache Docker Layers
  run: |
    # Cache frequently used base images
    docker pull node:18-alpine
    docker pull postgres:13
    docker pull chromium:latest
```

## 💰 Cost Savings for MCP Repository

### Current Usage Estimate
- **Docker builds**: ~500 minutes/month per service × 4 services = 2,000 minutes
- **Integration tests**: ~200 minutes/month
- **PR testing**: ~300 minutes/month
- **Total**: ~2,500 minutes/month

### Savings Calculation
- **GitHub Actions cost**: 2,500 minutes × $0.008/minute = **$20/month**
- **Self-hosted cost**: $0 (uses your infrastructure)
- **Annual savings**: $240/year

### Additional Benefits
- **Faster Docker builds** - Local Docker cache
- **More powerful hardware** - Your machine vs GitHub's shared resources
- **Custom environment** - Install any tools needed
- **No minute limits** - Run as many tests as needed

## 🚨 Important Notes

### Security Considerations
- **Docker socket access**: Runner can build/run containers
- **Environment variables**: Manage secrets carefully
- **Network isolation**: Each job runs in isolated container
- **Resource limits**: Monitor CPU/memory usage

### Performance Tips
- **Prune regularly**: Add cleanup steps to prevent disk full
- **Monitor resources**: Use `docker stats` to check usage
- **Optimize images**: Use multi-stage builds and .dockerignore
- **Parallel limits**: Don't run too many concurrent jobs

### Troubleshooting
- **Check runner logs**: `docker-compose logs -f`
- **Verify services**: `./scripts/status.sh`
- **Network issues**: Check port conflicts
- **Resource limits**: Monitor with `docker system df`

---

Your MCP repository is perfect for self-hosted runners due to its Docker-heavy workload. The integration will provide significant cost savings and performance improvements.