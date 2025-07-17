# Self-Hosted Runner Workflow Templates

**Purpose:** Ready-to-use workflow templates for common scenarios  
**Target:** All repositories using self-hosted GitHub Actions  
**Usage:** Copy and customize templates for your specific needs

## 🚀 Quick Start Templates

### 1. Basic CI Template

```yaml
name: Basic CI
on: [push, pull_request]

jobs:
  test:
    runs-on: self-hosted
    steps:
      - uses: actions/checkout@v4
      - name: Run Tests
        run: echo "Add your test commands here"
```

### 2. Multi-Language Detection Template

```yaml
name: Multi-Language CI
on: [push, pull_request]

jobs:
  detect-and-build:
    runs-on: self-hosted
    steps:
      - uses: actions/checkout@v4
      
      - name: Detect Project Type
        id: detect
        run: |
          if [ -f package.json ]; then
            echo "type=nodejs" >> $GITHUB_OUTPUT
          elif [ -f requirements.txt ]; then
            echo "type=python" >> $GITHUB_OUTPUT
          elif [ -f go.mod ]; then
            echo "type=go" >> $GITHUB_OUTPUT
          elif [ -f Cargo.toml ]; then
            echo "type=rust" >> $GITHUB_OUTPUT
          else
            echo "type=generic" >> $GITHUB_OUTPUT
          fi
          
      - name: Build Project
        run: |
          case "${{ steps.detect.outputs.type }}" in
            nodejs) npm install && npm test ;;
            python) pip install -r requirements.txt && python -m pytest ;;
            go) go test ./... ;;
            rust) cargo test ;;
            *) echo "Generic project detected" ;;
          esac
```

## 🐳 Docker-Based Templates

### 3. Docker Build and Test

```yaml
name: Docker Build & Test
on: [push, pull_request]

jobs:
  docker-build:
    runs-on: self-hosted
    steps:
      - uses: actions/checkout@v4
      
      - name: Build Docker Image
        run: |
          docker build -t ${{ github.repository }}:${{ github.sha }} .
          
      - name: Test Container
        run: |
          docker run --rm ${{ github.repository }}:${{ github.sha }} echo "Container test passed"
          
      - name: Security Scan
        run: |
          # Add your security scanning here
          echo "Security scan placeholder"
          
      - name: Cleanup
        run: |
          docker image prune -f
        if: always()
```

### 4. Multi-Service Docker Stack

```yaml
name: Multi-Service Test
on: [push, pull_request]

jobs:
  integration-test:
    runs-on: self-hosted
    steps:
      - uses: actions/checkout@v4
      
      - name: Start Services
        run: |
          docker-compose up -d
          sleep 30  # Wait for services to start
          
      - name: Run Integration Tests
        run: |
          # Add your integration tests here
          docker-compose exec -T service1 curl http://service2:8080/health
          
      - name: Cleanup Services
        run: |
          docker-compose down
          docker volume prune -f
        if: always()
```

## 🔧 Language-Specific Templates

### 5. Node.js/Bun Template

```yaml
name: Node.js/Bun CI
on: [push, pull_request]

jobs:
  test:
    runs-on: self-hosted
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Runtime
        run: |
          if [ -f bun.lock ]; then
            echo "Using Bun runtime"
            bun install
          else
            echo "Using npm"
            npm install
          fi
          
      - name: Run Tests
        run: |
          if [ -f bun.lock ]; then
            bun test
          else
            npm test
          fi
          
      - name: Build
        run: |
          if [ -f bun.lock ]; then
            bun run build
          else
            npm run build
          fi
```

### 6. Python Template

```yaml
name: Python CI
on: [push, pull_request]

jobs:
  test:
    runs-on: self-hosted
    strategy:
      matrix:
        python-version: [3.9, 3.10, 3.11]
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Python ${{ matrix.python-version }}
        run: |
          python${{ matrix.python-version }} -m venv venv
          source venv/bin/activate
          pip install --upgrade pip
          
      - name: Install Dependencies
        run: |
          source venv/bin/activate
          if [ -f requirements.txt ]; then
            pip install -r requirements.txt
          elif [ -f pyproject.toml ]; then
            pip install -e .
          fi
          
      - name: Run Tests
        run: |
          source venv/bin/activate
          python -m pytest
          
      - name: Lint
        run: |
          source venv/bin/activate
          flake8 . || echo "Linting completed"
```

### 7. Go Template

```yaml
name: Go CI
on: [push, pull_request]

jobs:
  test:
    runs-on: self-hosted
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Go
        run: |
          go version
          go mod download
          
      - name: Run Tests
        run: |
          go test -v ./...
          
      - name: Build
        run: |
          go build -v ./...
          
      - name: Vet
        run: |
          go vet ./...
```

### 8. Rust Template

```yaml
name: Rust CI
on: [push, pull_request]

jobs:
  test:
    runs-on: self-hosted
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Rust
        run: |
          curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
          source ~/.cargo/env
          
      - name: Build
        run: |
          source ~/.cargo/env
          cargo build --verbose
          
      - name: Run Tests
        run: |
          source ~/.cargo/env
          cargo test --verbose
          
      - name: Lint
        run: |
          source ~/.cargo/env
          cargo clippy -- -D warnings
```

## 🚀 Deployment Templates

### 9. Simple Deployment

```yaml
name: Deploy
on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: self-hosted
    environment: production
    steps:
      - uses: actions/checkout@v4
      
      - name: Build
        run: |
          # Add your build commands
          echo "Building application..."
          
      - name: Deploy
        run: |
          # Add your deployment commands
          echo "Deploying application..."
          
      - name: Health Check
        run: |
          # Verify deployment
          sleep 10
          curl -f http://localhost:8080/health || exit 1
```

### 10. Blue-Green Deployment

```yaml
name: Blue-Green Deploy
on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: self-hosted
    steps:
      - uses: actions/checkout@v4
      
      - name: Build New Version
        run: |
          docker build -t app:green .
          
      - name: Test Green Environment
        run: |
          docker run -d --name app-green -p 8081:8080 app:green
          sleep 10
          curl -f http://localhost:8081/health
          
      - name: Switch Traffic
        run: |
          # Stop blue, start green on main port
          docker stop app-blue || true
          docker rm app-blue || true
          docker stop app-green
          docker run -d --name app-blue -p 8080:8080 app:green
          
      - name: Cleanup
        run: |
          docker rm app-green
          docker image prune -f
```

## 📊 Monitoring Templates

### 11. Health Check Template

```yaml
name: Health Check
on:
  schedule:
    - cron: '*/15 * * * *'  # Every 15 minutes
  workflow_dispatch:

jobs:
  health-check:
    runs-on: self-hosted
    steps:
      - name: Check Application Health
        run: |
          if curl -f http://localhost:8080/health; then
            echo "✅ Application is healthy"
          else
            echo "❌ Application health check failed"
            exit 1
          fi
          
      - name: Check Resources
        run: |
          echo "💾 Disk usage:"
          df -h
          echo "🧠 Memory usage:"
          free -h
          echo "🔥 CPU usage:"
          top -bn1 | grep "Cpu(s)"
          
      - name: Restart if Unhealthy
        if: failure()
        run: |
          echo "🔄 Restarting unhealthy application..."
          # Add restart commands here
```

### 12. Performance Monitoring

```yaml
name: Performance Monitor
on:
  schedule:
    - cron: '0 */6 * * *'  # Every 6 hours

jobs:
  performance-test:
    runs-on: self-hosted
    steps:
      - uses: actions/checkout@v4
      
      - name: Load Test
        run: |
          echo "⚡ Running performance tests..."
          
          # Basic load test with curl
          for i in {1..100}; do
            curl -s http://localhost:8080/api/test > /dev/null &
          done
          wait
          
      - name: Memory Profile
        run: |
          echo "🧠 Memory profiling..."
          ps aux --sort=-%mem | head -10
          
      - name: Generate Report
        run: |
          echo "📊 Performance report generated at $(date)"
```

## 🛡️ Security Templates

### 13. Security Scan Template

```yaml
name: Security Scan
on:
  push:
    branches: [ main ]
  schedule:
    - cron: '0 2 * * 0'  # Weekly on Sunday at 2 AM

jobs:
  security-scan:
    runs-on: self-hosted
    steps:
      - uses: actions/checkout@v4
      
      - name: Dependency Audit
        run: |
          if [ -f package.json ]; then
            npm audit
          elif [ -f requirements.txt ]; then
            pip install safety
            safety check -r requirements.txt
          elif [ -f go.mod ]; then
            go list -json -m all | nancy sleuth
          fi
          
      - name: Secret Scan
        run: |
          echo "🔍 Scanning for secrets..."
          # Add secret scanning tools here
          grep -r "password\|secret\|key" . --exclude-dir=.git || true
          
      - name: Container Security
        run: |
          if [ -f Dockerfile ]; then
            echo "🐳 Scanning Docker image..."
            docker build -t security-scan .
            # Add container security scanning here
          fi
```

## 📋 Template Usage Guide

### How to Use These Templates

1. **Copy Template**: Choose the appropriate template for your project
2. **Customize**: Update commands, paths, and variables for your needs
3. **Add Secrets**: Configure any required secrets in repository settings
4. **Test**: Run workflow on a test branch first
5. **Deploy**: Merge to main branch once tested

### Common Customizations

```yaml
# Customize timeout
jobs:
  test:
    timeout-minutes: 30  # Adjust based on your needs
    
# Add environment variables
env:
  NODE_ENV: test
  DATABASE_URL: sqlite://test.db
  
# Customize triggers
on:
  push:
    branches: [ main, develop ]
    paths: [ 'src/**', 'tests/**' ]  # Only run on specific file changes
```

### Template Categories

- **🔧 Basic CI/CD**: Simple build and test workflows
- **🐳 Docker**: Container-based development and deployment
- **🗣️ Language-Specific**: Optimized for specific programming languages
- **🚀 Deployment**: Production deployment strategies
- **📊 Monitoring**: Health checks and performance monitoring
- **🛡️ Security**: Security scanning and auditing

---

These templates provide a solid foundation for implementing self-hosted GitHub Actions across all your repositories. Choose the ones that match your project needs and customize as required.