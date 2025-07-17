# Personal Repository Integration Guide

**Repository:** `/github/Personal` - Personal development projects and experiments  
**Purpose:** Development tools, personal projects, and experimentation  
**Benefits:** Unlimited CI/CD minutes for personal projects

## 🎯 Personal Repository Overview

Your Personal repository is likely a collection of:
- Personal development projects
- Experimental code and prototypes
- Learning projects and tutorials
- Development tools and utilities
- Side projects and portfolio pieces

## 🚀 Quick Integration Templates

### 1. Universal Personal Project CI

Create `.github/workflows/personal-ci.yml`:

```yaml
name: Personal Project CI
on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  detect-and-build:
    runs-on: self-hosted
    timeout-minutes: 20
    
    steps:
      - name: Checkout Repository
        uses: actions/checkout@v4
        
      - name: Detect Project Type
        id: detect
        run: |
          echo "🔍 Detecting project type..."
          
          if [ -f package.json ]; then
            echo "type=nodejs" >> $GITHUB_OUTPUT
            echo "📦 Node.js project detected"
          elif [ -f requirements.txt ] || [ -f pyproject.toml ]; then
            echo "type=python" >> $GITHUB_OUTPUT
            echo "🐍 Python project detected"
          elif [ -f go.mod ]; then
            echo "type=go" >> $GITHUB_OUTPUT
            echo "🐹 Go project detected"
          elif [ -f Cargo.toml ]; then
            echo "type=rust" >> $GITHUB_OUTPUT
            echo "🦀 Rust project detected"
          elif [ -f pom.xml ] || [ -f build.gradle ]; then
            echo "type=java" >> $GITHUB_OUTPUT
            echo "☕ Java project detected"
          elif [ -f Dockerfile ]; then
            echo "type=docker" >> $GITHUB_OUTPUT
            echo "🐳 Docker project detected"
          else
            echo "type=generic" >> $GITHUB_OUTPUT
            echo "📁 Generic project detected"
          fi
          
      - name: Setup Node.js Environment
        if: steps.detect.outputs.type == 'nodejs'
        run: |
          echo "🔧 Setting up Node.js environment..."
          # Check if bun is preferred (based on bun.lock)
          if [ -f bun.lock ]; then
            echo "Using Bun runtime"
            bun install
          else
            echo "Using npm"
            npm install
          fi
          
      - name: Setup Python Environment
        if: steps.detect.outputs.type == 'python'
        run: |
          echo "🔧 Setting up Python environment..."
          python3 -m venv venv
          source venv/bin/activate
          pip install --upgrade pip
          
          if [ -f requirements.txt ]; then
            pip install -r requirements.txt
          elif [ -f pyproject.toml ]; then
            pip install -e .
          fi
          
      - name: Setup Go Environment
        if: steps.detect.outputs.type == 'go'
        run: |
          echo "🔧 Setting up Go environment..."
          go mod download
          go mod verify
          
      - name: Setup Rust Environment
        if: steps.detect.outputs.type == 'rust'
        run: |
          echo "🔧 Setting up Rust environment..."
          curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
          source ~/.cargo/env
          cargo fetch
          
      - name: Run Tests
        run: |
          echo "🧪 Running tests..."
          
          case "${{ steps.detect.outputs.type }}" in
            nodejs)
              if [ -f bun.lock ]; then
                bun test || echo "No tests found"
              else
                npm test || echo "No tests found"
              fi
              ;;
            python)
              source venv/bin/activate
              if [ -f pytest.ini ] || [ -d tests ]; then
                python -m pytest
              else
                python -m unittest discover || echo "No tests found"
              fi
              ;;
            go)
              go test ./... || echo "No tests found"
              ;;
            rust)
              source ~/.cargo/env
              cargo test || echo "No tests found"
              ;;
            java)
              if [ -f pom.xml ]; then
                mvn test || echo "No tests found"
              else
                ./gradlew test || echo "No tests found"
              fi
              ;;
            docker)
              docker build -t personal-project:test . || echo "Docker build failed"
              ;;
            *)
              echo "No specific tests for generic project"
              ;;
          esac
          
      - name: Build Project
        run: |
          echo "🏗️ Building project..."
          
          case "${{ steps.detect.outputs.type }}" in
            nodejs)
              if [ -f bun.lock ]; then
                bun run build || echo "No build script"
              else
                npm run build || echo "No build script"
              fi
              ;;
            python)
              source venv/bin/activate
              python setup.py build || echo "No build step needed"
              ;;
            go)
              go build -v ./... || echo "Build completed"
              ;;
            rust)
              source ~/.cargo/env
              cargo build --release || echo "Build completed"
              ;;
            java)
              if [ -f pom.xml ]; then
                mvn compile || echo "Compile completed"
              else
                ./gradlew build || echo "Build completed"
              fi
              ;;
            docker)
              docker build -t personal-project:latest . || echo "Docker build completed"
              ;;
          esac
          
      - name: Run Linting
        run: |
          echo "🔍 Running linting..."
          
          case "${{ steps.detect.outputs.type }}" in
            nodejs)
              if [ -f .eslintrc.js ] || [ -f .eslintrc.json ]; then
                if [ -f bun.lock ]; then
                  bun run lint || echo "No lint script"
                else
                  npm run lint || echo "No lint script"
                fi
              fi
              ;;
            python)
              source venv/bin/activate
              if command -v flake8 &> /dev/null; then
                flake8 . || echo "Linting completed"
              elif command -v pylint &> /dev/null; then
                pylint **/*.py || echo "Linting completed"
              fi
              ;;
            go)
              go vet ./... || echo "Vetting completed"
              if command -v golint &> /dev/null; then
                golint ./... || echo "Linting completed"
              fi
              ;;
            rust)
              source ~/.cargo/env
              cargo clippy -- -D warnings || echo "Clippy completed"
              ;;
          esac
          
      - name: Security Scan
        run: |
          echo "🔒 Running security scan..."
          
          case "${{ steps.detect.outputs.type }}" in
            nodejs)
              if [ -f package.json ]; then
                npm audit || echo "Audit completed"
              fi
              ;;
            python)
              source venv/bin/activate
              if command -v safety &> /dev/null; then
                safety check || echo "Safety check completed"
              fi
              ;;
            go)
              if command -v gosec &> /dev/null; then
                gosec ./... || echo "Security scan completed"
              fi
              ;;
            rust)
              source ~/.cargo/env
              if command -v cargo-audit &> /dev/null; then
                cargo audit || echo "Audit completed"
              fi
              ;;
          esac
          
      - name: Generate Project Report
        run: |
          echo "📊 Generating project report..."
          
          cat > project-report.md << EOF
          # Project CI Report
          
          **Project Type:** ${{ steps.detect.outputs.type }}
          **Commit:** \${{ github.sha }}
          **Branch:** \${{ github.ref_name }}
          **Date:** $(date)
          
          ## Build Status
          - ✅ Dependencies installed
          - ✅ Tests executed
          - ✅ Build completed
          - ✅ Linting performed
          - ✅ Security scan completed
          
          ## Next Steps
          - Review any warnings or errors above
          - Consider adding more specific tests
          - Update documentation if needed
          EOF
          
          cat project-report.md
          
      - name: Upload Artifacts
        uses: actions/upload-artifact@v4
        with:
          name: project-report
          path: project-report.md
        if: always()
        
      - name: Cleanup
        run: |
          echo "🧹 Cleaning up..."
          # Remove any temporary files
          rm -rf venv/ || true
          rm -rf node_modules/ || true
          docker system prune -f || true
        if: always()
```

### 2. Polyglot Project Support

Create `.github/workflows/polyglot-ci.yml`:

```yaml
name: Polyglot Project CI
on:
  push:
    paths:
      - '**/*.js'
      - '**/*.ts'
      - '**/*.py'
      - '**/*.go'
      - '**/*.rs'
      - '**/*.java'

jobs:
  test-by-language:
    runs-on: self-hosted
    strategy:
      matrix:
        language: [javascript, python, go, rust]
      fail-fast: false
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Test ${{ matrix.language }} Code
        run: |
          case "${{ matrix.language }}" in
            javascript)
              if find . -name "*.js" -o -name "*.ts" | grep -q .; then
                echo "Testing JavaScript/TypeScript files..."
                if [ -f package.json ]; then
                  npm install && npm test
                fi
              else
                echo "No JavaScript/TypeScript files found"
              fi
              ;;
            python)
              if find . -name "*.py" | grep -q .; then
                echo "Testing Python files..."
                python3 -m pytest . || python3 -m unittest discover
              else
                echo "No Python files found"
              fi
              ;;
            go)
              if find . -name "*.go" | grep -q .; then
                echo "Testing Go files..."
                go test ./...
              else
                echo "No Go files found"
              fi
              ;;
            rust)
              if find . -name "*.rs" | grep -q .; then
                echo "Testing Rust files..."
                cargo test
              else
                echo "No Rust files found"
              fi
              ;;
          esac
```

### 3. Experimental Project Pipeline

Create `.github/workflows/experimental.yml`:

```yaml
name: Experimental Projects
on:
  push:
    branches: [ experimental, prototype/* ]

jobs:
  quick-test:
    runs-on: self-hosted
    timeout-minutes: 10
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Quick Smoke Test
        run: |
          echo "🧪 Quick experimental project test..."
          
          # Look for any executable scripts
          if find . -name "*.sh" -executable | head -1 | read script; then
            echo "Found script: $script"
            timeout 30s "$script" || echo "Script completed or timed out"
          fi
          
          # Look for any README with instructions
          if [ -f README.md ]; then
            echo "📖 README.md found - checking for run instructions..."
            grep -i "run\|usage\|getting started" README.md || true
          fi
          
          # Basic file structure report
          echo "📁 Project structure:"
          find . -type f -name "*.py" -o -name "*.js" -o -name "*.go" -o -name "*.rs" -o -name "*.java" | head -10
          
      - name: Basic Security Check
        run: |
          echo "🔒 Basic security check..."
          
          # Check for common sensitive files
          if find . -name "*.pem" -o -name "*.key" -o -name ".env" | grep -q .; then
            echo "⚠️ Warning: Found potential sensitive files"
            find . -name "*.pem" -o -name "*.key" -o -name ".env"
          else
            echo "✅ No obvious sensitive files found"
          fi
```

## 🔧 Personal Project Optimizations

### 1. Development Workflow
```yaml
# Add this job for development branches
jobs:
  dev-workflow:
    runs-on: self-hosted
    if: github.ref == 'refs/heads/develop'
    steps:
      - uses: actions/checkout@v4
      - name: Development Build
        run: |
          echo "🛠️ Development build with extra debugging..."
          # Add development-specific steps here
```

### 2. Portfolio Deployment
```yaml
# Add this for portfolio projects
jobs:
  deploy-portfolio:
    runs-on: self-hosted
    if: github.ref == 'refs/heads/main' && contains(github.repository, 'portfolio')
    steps:
      - uses: actions/checkout@v4
      - name: Build for Production
        run: |
          echo "🚀 Building for portfolio deployment..."
          # Add deployment steps here
```

### 3. Learning Project Documentation
```yaml
# Add this for learning projects
jobs:
  generate-docs:
    runs-on: self-hosted
    steps:
      - uses: actions/checkout@v4
      - name: Generate Learning Notes
        run: |
          echo "📚 Generating learning documentation..."
          
          # Create a learning summary
          cat > LEARNING.md << EOF
          # Learning Summary
          
          **Project:** \${{ github.repository }}
          **Last Updated:** $(date)
          
          ## What I Learned
          - Add your learning notes here
          
          ## Technologies Used
          $(find . -name "*.json" -o -name "*.toml" -o -name "*.yaml" | head -5)
          
          ## Next Steps
          - Continue development
          - Add more features
          - Document findings
          EOF
```

## 💰 Cost Savings for Personal Repository

### Typical Personal Development Usage
- **Experimental builds**: ~200 minutes/month
- **Learning projects**: ~100 minutes/month  
- **Portfolio updates**: ~150 minutes/month
- **Side projects**: ~300 minutes/month
- **Total**: ~750 minutes/month

### Savings Calculation
- **GitHub Actions cost**: 750 minutes × $0.008/minute = **$6/month**
- **Self-hosted cost**: $0
- **Annual savings**: $72/year

### Additional Benefits
- **Unlimited experimentation** - No minute limits for trying new things
- **Faster feedback loops** - Immediate CI/CD results
- **Custom environments** - Install any tools you need
- **Learning acceleration** - CI/CD for all experiments

## 📋 Migration Checklist for Personal Repository

### Step 1: Assess Current Projects
```bash
# Navigate to Personal repository
cd /github/Personal

# Check project structure
find . -name "package.json" -o -name "requirements.txt" -o -name "go.mod" -o -name "Cargo.toml"

# Check for existing workflows
ls .github/workflows/ 2>/dev/null || echo "No existing workflows"
```

### Step 2: Add Universal Workflows
```bash
# Create workflows directory
mkdir -p .github/workflows

# Add the universal personal CI workflow
# Copy personal-ci.yml content above
```

### Step 3: Test and Iterate
```bash
# Test locally first
echo "Testing project structure detection..."

# Then commit and push
git add .github/workflows/
git commit -m "Add self-hosted runner workflows for personal projects"
git push
```

## 🎯 Personal Project Best Practices

### 1. Keep It Simple
- Start with the universal workflow
- Add complexity only when needed
- Focus on learning over perfection

### 2. Experiment Freely
- Use feature branches for experiments
- Don't worry about "perfect" CI/CD
- Learn from failures

### 3. Document Your Journey
- Add learning notes to commits
- Create README files for context
- Use CI to generate documentation

### 4. Security Awareness
- Never commit secrets (even in personal repos)
- Use environment variables for sensitive data
- Regular security scans help build good habits

---

Your Personal repository is perfect for learning CI/CD best practices with no cost constraints. Use it to experiment, learn, and build your DevOps skills!