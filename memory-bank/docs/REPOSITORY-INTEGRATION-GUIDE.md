# Repository Integration Guide: Self-Hosted GitHub Actions

**Purpose:** Complete guide for integrating self-hosted runners across all your repositories  
**Target:** All repositories in the virtuoso902 organization  
**Prerequisites:** Self-hosted runner running from GHActions repository

## 🚀 Quick Start for Any Repository

### 1. Basic Integration (30 seconds)

Add this to any workflow file in `.github/workflows/`:

```yaml
name: Example Workflow
on: [push, pull_request]

jobs:
  build:
    runs-on: self-hosted  # 👈 This line uses your runner
    steps:
      - uses: actions/checkout@v4
      - run: echo "Running on self-hosted runner!"
```

### 2. Advanced Integration with Labels

```yaml
name: Advanced Workflow
on: [push, pull_request]

jobs:
  build:
    runs-on: [self-hosted, linux, x64, ephemeral]  # 👈 Specific runner labels
    steps:
      - uses: actions/checkout@v4
      - run: echo "Running on ephemeral self-hosted runner!"
```

## 📊 Cost Savings Analysis

### Current GitHub Actions Limits
- **Free Plan**: 2,000 minutes/month
- **Pro Plan**: 3,000 minutes/month
- **Team Plan**: 10,000 minutes/month

### Self-Hosted Runner Savings
- **Cost**: $0 (uses your infrastructure)
- **Limits**: Unlimited minutes
- **Performance**: Faster for Docker operations
- **Customization**: Full control over environment

### Estimated Monthly Savings
- **Light Usage** (5,000 minutes): $0.008/min × 3,000 excess = **$24/month**
- **Medium Usage** (10,000 minutes): $0.008/min × 8,000 excess = **$64/month**
- **Heavy Usage** (20,000 minutes): $0.008/min × 18,000 excess = **$144/month**

## 🏗️ Repository-Specific Integration

### Universal MCP Server Hub (`/mcp`)
**Perfect for**: Docker builds, multi-service testing, database operations

```yaml
name: MCP CI/CD Pipeline
on: [push, pull_request]

jobs:
  test-services:
    runs-on: self-hosted
    steps:
      - uses: actions/checkout@v4
      
      - name: Start MCP Services
        run: |
          cp .env.example .env
          ./scripts/start.sh
          
      - name: Run Integration Tests
        run: |
          ./scripts/test-connection.sh
          
      - name: Test Playwright MCP
        run: |
          curl -X POST http://localhost:3010/mcp \
            -H "Content-Type: application/json" \
            -d '{"method": "screenshot", "params": {"url": "https://example.com"}}'
            
      - name: Cleanup
        run: ./scripts/stop.sh
        if: always()
```

### Personal Repository (`/Personal`)
**Perfect for**: Development tools, personal projects, experimentation

```yaml
name: Personal Project CI
on: [push, pull_request]

jobs:
  build-and-test:
    runs-on: self-hosted
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Environment
        run: |
          # Install dependencies based on project type
          if [ -f package.json ]; then
            npm install
          elif [ -f requirements.txt ]; then
            pip install -r requirements.txt
          elif [ -f go.mod ]; then
            go mod download
          fi
          
      - name: Run Tests
        run: |
          # Run tests based on project type
          if [ -f package.json ]; then
            npm test
          elif [ -f requirements.txt ]; then
            python -m pytest
          elif [ -f go.mod ]; then
            go test ./...
          fi
```

### Claude Code Discord Bot (`/claude-code-discord`)
**Perfect for**: TypeScript/Node.js builds, bot testing, dependency management

```yaml
name: Discord Bot CI/CD
on: [push, pull_request]

jobs:
  test-and-build:
    runs-on: self-hosted
    steps:
      - uses: actions/checkout@v4
      
      - name: Install Dependencies
        run: |
          # Using bun as specified in CLAUDE.md
          bun install
          
      - name: Run Tests
        run: |
          bun run test:run
          
      - name: Type Check
        run: |
          bun run typecheck
          
      - name: Build
        run: |
          bun run build
          
      - name: Test Bot Startup (Dry Run)
        run: |
          # Test bot can start without actually connecting
          timeout 10s bun run src/index.ts --dry-run || true
```

## 🔧 Common Workflow Patterns

### 1. Docker-Based Projects
```yaml
name: Docker Build and Test
on: [push, pull_request]

jobs:
  docker-build:
    runs-on: self-hosted
    steps:
      - uses: actions/checkout@v4
      
      - name: Build Docker Image
        run: |
          docker build -t ${{ github.repository }}:${{ github.sha }} .
          
      - name: Run Container Tests
        run: |
          docker run --rm ${{ github.repository }}:${{ github.sha }} npm test
          
      - name: Cleanup
        run: |
          docker image prune -f
        if: always()
```

### 2. Multi-Service Projects
```yaml
name: Multi-Service Integration
on: [push, pull_request]

jobs:
  integration-test:
    runs-on: self-hosted
    steps:
      - uses: actions/checkout@v4
      
      - name: Start All Services
        run: |
          docker-compose up -d
          sleep 30  # Wait for services to start
          
      - name: Run Integration Tests
        run: |
          ./scripts/test-integration.sh
          
      - name: Cleanup Services
        run: |
          docker-compose down
          docker volume prune -f
        if: always()
```

### 3. Database-Dependent Projects
```yaml
name: Database Testing
on: [push, pull_request]

jobs:
  db-test:
    runs-on: self-hosted
    steps:
      - uses: actions/checkout@v4
      
      - name: Start Test Database
        run: |
          docker run -d --name test-db \
            -e POSTGRES_PASSWORD=testpass \
            -e POSTGRES_DB=testdb \
            -p 5432:5432 postgres:13
          sleep 10
          
      - name: Run Database Tests
        run: |
          export DATABASE_URL=postgresql://postgres:testpass@localhost:5432/testdb
          npm test
          
      - name: Cleanup Database
        run: |
          docker stop test-db
          docker rm test-db
        if: always()
```

## 📋 Migration Checklist

### For Each Repository:

- [ ] **Review Current Workflows**
  - List all existing `.github/workflows/*.yml` files
  - Identify which use `runs-on: ubuntu-latest`
  - Note any special requirements (specific OS, tools, etc.)

- [ ] **Update Runner Configuration**
  - Change `runs-on: ubuntu-latest` to `runs-on: self-hosted`
  - Add specific labels if needed: `[self-hosted, linux, x64, ephemeral]`

- [ ] **Test Docker Dependencies**
  - Ensure Docker commands work in workflows
  - Test Docker socket mounting if needed
  - Verify container cleanup in workflows

- [ ] **Verify Environment Variables**
  - Check that all required env vars are available
  - Update secrets if needed
  - Test with production-like data

- [ ] **Performance Testing**
  - Run workflows and measure execution time
  - Compare with GitHub-hosted runners
  - Optimize resource usage

- [ ] **Update Documentation**
  - Update README with self-hosted runner info
  - Document any new requirements
  - Add troubleshooting section

## 🚨 Important Considerations

### Security
- **Ephemeral runners**: Each job gets fresh environment
- **No secrets persistence**: Secrets are injected per job
- **Network isolation**: Each container is isolated
- **Docker socket access**: Containers can build/run other containers

### Performance
- **Startup time**: ~20-30 seconds vs ~10 seconds for GitHub-hosted
- **No caching**: Fresh environment each time (security trade-off)
- **Resource limits**: Based on your host machine specs
- **Concurrent jobs**: Limited by your runner scaling

### Monitoring
- **Runner status**: Check with `docker-compose ps`
- **Job logs**: Available in Actions tab
- **Resource usage**: Monitor with `docker stats`
- **Failures**: Check runner logs with `docker-compose logs`

## 🔄 Workflow Templates

### Repository-Specific Templates

#### MCP Repository Template
```yaml
name: MCP Server Tests
on: [push, pull_request]
jobs:
  test-mcp-servers:
    runs-on: self-hosted
    steps:
      - uses: actions/checkout@v4
      - run: ./scripts/start.sh
      - run: ./scripts/test-connection.sh
      - run: ./scripts/stop.sh
        if: always()
```

#### Personal Repository Template
```yaml
name: Personal Project Build
on: [push, pull_request]
jobs:
  build:
    runs-on: self-hosted
    steps:
      - uses: actions/checkout@v4
      - run: echo "Add your build steps here"
```

#### Discord Bot Template
```yaml
name: Discord Bot CI
on: [push, pull_request]
jobs:
  test:
    runs-on: self-hosted
    steps:
      - uses: actions/checkout@v4
      - run: bun install
      - run: bun run test:run
      - run: bun run build
```

## 🎯 Next Steps

1. **Start with one repository** - Test integration with a simple workflow
2. **Monitor performance** - Compare execution times and resource usage
3. **Scale gradually** - Add more complex workflows once basics work
4. **Optimize as needed** - Adjust runner configuration based on usage patterns

---

Your self-hosted runner is ready to handle all these scenarios. The key is to start simple and gradually add complexity as you become more comfortable with the setup.