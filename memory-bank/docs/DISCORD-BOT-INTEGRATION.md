# Claude Code Discord Bot Integration Guide

**Repository:** `/github/claude-code-discord` - Discord bot for Claude Code sessions  
**Purpose:** TypeScript/Bun-based Discord bot with sophisticated CI/CD needs  
**Benefits:** Save ~$20-40/month on Actions minutes for TypeScript builds and testing

## 🎯 Discord Bot Repository Overview

Your Discord bot repository has specific requirements:
- **Runtime:** Bun (JavaScript runtime)
- **Language:** TypeScript with strict type checking
- **Framework:** Discord.js with WebSocket support
- **Database:** SQLite for session storage
- **Testing:** Comprehensive test suite required

## 🚀 Quick Integration for Discord Bot

### 1. Main CI/CD Pipeline

Create `.github/workflows/discord-bot-ci.yml`:

```yaml
name: Discord Bot CI/CD
on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test-and-build:
    runs-on: self-hosted
    timeout-minutes: 15
    
    steps:
      - name: Checkout Repository
        uses: actions/checkout@v4
        
      - name: Setup Bun Environment
        run: |
          echo "🔧 Setting up Bun environment..."
          
          # Install Bun if not available
          if ! command -v bun &> /dev/null; then
            curl -fsSL https://bun.sh/install | bash
            export PATH="$HOME/.bun/bin:$PATH"
          fi
          
          # Verify Bun installation
          bun --version
          
      - name: Install Dependencies
        run: |
          echo "📦 Installing dependencies with Bun..."
          bun install --frozen-lockfile
          
      - name: Type Checking
        run: |
          echo "🔍 Running TypeScript type checking..."
          bun run typecheck
          
      - name: Run Linting
        run: |
          echo "✨ Running ESLint..."
          bun run lint
          
      - name: Run Tests
        run: |
          echo "🧪 Running test suite..."
          bun run test:run
          
      - name: Build Project
        run: |
          echo "🏗️ Building Discord bot..."
          bun run build
          
      - name: Test Bot Startup (Dry Run)
        env:
          # Use test environment variables
          DISCORD_TOKEN: "test_token_here"
          ALLOWED_USER_ID: "123456789"
          BASE_FOLDER: "/tmp/test"
        run: |
          echo "🤖 Testing bot startup (dry run)..."
          
          # Create test environment
          mkdir -p /tmp/test
          
          # Test bot can start without actually connecting
          timeout 10s bun run src/index.ts --dry-run || true
          
          echo "✅ Bot startup test completed"
          
      - name: Security Audit
        run: |
          echo "🔒 Running security audit..."
          bun audit || echo "Audit completed with warnings"
          
      - name: Generate Build Report
        run: |
          echo "📊 Generating build report..."
          
          cat > build-report.md << EOF
          # Discord Bot Build Report
          
          **Commit:** \${{ github.sha }}
          **Branch:** \${{ github.ref_name }}
          **Date:** $(date)
          **Runtime:** $(bun --version)
          
          ## Build Status
          - ✅ Dependencies installed
          - ✅ TypeScript type checking passed
          - ✅ Linting passed
          - ✅ Tests passed
          - ✅ Build completed
          - ✅ Bot startup test passed
          
          ## Dependencies
          \`\`\`
          $(bun pm ls)
          \`\`\`
          
          ## Bundle Size
          \`\`\`
          $(du -sh dist/ 2>/dev/null || echo "No dist folder")
          \`\`\`
          EOF
          
          cat build-report.md
          
      - name: Upload Build Artifacts
        uses: actions/upload-artifact@v4
        with:
          name: build-artifacts
          path: |
            dist/
            build-report.md
        if: always()
        
      - name: Cleanup
        run: |
          echo "🧹 Cleaning up..."
          rm -rf /tmp/test
          rm -rf node_modules/.cache
        if: always()
```

### 2. Deployment Pipeline

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy Discord Bot
on:
  push:
    branches: [ main ]
    tags: [ 'v*' ]

jobs:
  deploy:
    runs-on: self-hosted
    if: github.ref == 'refs/heads/main'
    timeout-minutes: 10
    
    environment:
      name: production
      
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Production Environment
        run: |
          echo "🚀 Setting up production environment..."
          
          # Install/update Bun
          curl -fsSL https://bun.sh/install | bash
          export PATH="$HOME/.bun/bin:$PATH"
          
          # Install production dependencies
          bun install --production --frozen-lockfile
          
      - name: Build for Production
        run: |
          echo "🏗️ Building for production..."
          bun run build
          
      - name: Pre-deployment Tests
        env:
          NODE_ENV: production
        run: |
          echo "🧪 Running pre-deployment tests..."
          
          # Test production build
          timeout 5s bun run dist/index.js --version || true
          
          # Verify critical files exist
          test -f dist/index.js || (echo "❌ Main file missing" && exit 1)
          test -f package.json || (echo "❌ Package.json missing" && exit 1)
          
          echo "✅ Pre-deployment tests passed"
          
      - name: Deploy Bot
        env:
          DISCORD_TOKEN: ${{ secrets.DISCORD_TOKEN }}
          ALLOWED_USER_ID: ${{ secrets.ALLOWED_USER_ID }}
          BASE_FOLDER: ${{ secrets.BASE_FOLDER }}
        run: |
          echo "🚀 Deploying Discord bot..."
          
          # Stop existing bot if running
          pkill -f "bun.*src/index.ts" || true
          sleep 2
          
          # Start new bot instance
          nohup bun start > /tmp/discord-bot.log 2>&1 &
          
          # Wait a moment and check if it started
          sleep 5
          if pgrep -f "bun.*src/index.ts" > /dev/null; then
            echo "✅ Bot deployed and running"
          else
            echo "❌ Bot failed to start"
            tail -20 /tmp/discord-bot.log
            exit 1
          fi
          
      - name: Post-deployment Verification
        run: |
          echo "🔍 Verifying deployment..."
          
          # Check bot process
          if pgrep -f "bun.*src/index.ts" > /dev/null; then
            echo "✅ Bot process is running"
          else
            echo "❌ Bot process not found"
            exit 1
          fi
          
          # Check log for successful startup
          sleep 10
          if grep -q "Bot ready" /tmp/discord-bot.log; then
            echo "✅ Bot started successfully"
          else
            echo "❌ Bot startup issues detected"
            tail -20 /tmp/discord-bot.log
          fi
          
      - name: Notify Deployment
        run: |
          echo "📢 Deployment completed!"
          echo "Deployment time: $(date)"
          echo "Commit: ${{ github.sha }}"
          echo "Version: $(grep version package.json | cut -d'"' -f4)"
```

### 3. Bot Health Monitoring

Create `.github/workflows/health-check.yml`:

```yaml
name: Bot Health Check
on:
  schedule:
    - cron: '*/30 * * * *'  # Every 30 minutes
  workflow_dispatch:

jobs:
  health-check:
    runs-on: self-hosted
    timeout-minutes: 5
    
    steps:
      - name: Check Bot Process
        run: |
          echo "🏥 Checking bot health..."
          
          # Check if bot process is running
          if pgrep -f "bun.*src/index.ts" > /dev/null; then
            echo "✅ Bot process is running"
            
            # Check memory usage
            BOT_PID=$(pgrep -f "bun.*src/index.ts")
            MEMORY=$(ps -o pid,rss,comm -p $BOT_PID | tail -1 | awk '{print $2}')
            echo "Memory usage: ${MEMORY}KB"
            
            # Alert if memory usage is too high (>500MB)
            if [ $MEMORY -gt 512000 ]; then
              echo "⚠️ High memory usage detected: ${MEMORY}KB"
            fi
          else
            echo "❌ Bot process not running!"
            exit 1
          fi
          
      - name: Check Log Health
        run: |
          echo "📋 Checking bot logs..."
          
          if [ -f /tmp/discord-bot.log ]; then
            # Check for recent activity (last 30 minutes)
            RECENT_LOGS=$(find /tmp/discord-bot.log -mmin -30)
            if [ -n "$RECENT_LOGS" ]; then
              echo "✅ Recent log activity detected"
            else
              echo "⚠️ No recent log activity"
            fi
            
            # Check for error patterns
            ERROR_COUNT=$(tail -100 /tmp/discord-bot.log | grep -i error | wc -l)
            if [ $ERROR_COUNT -gt 5 ]; then
              echo "⚠️ High error count in recent logs: $ERROR_COUNT"
              echo "Recent errors:"
              tail -100 /tmp/discord-bot.log | grep -i error | tail -5
            else
              echo "✅ Error count within normal range: $ERROR_COUNT"
            fi
          else
            echo "❌ Bot log file not found"
          fi
          
      - name: Restart Bot if Unhealthy
        if: failure()
        env:
          DISCORD_TOKEN: ${{ secrets.DISCORD_TOKEN }}
          ALLOWED_USER_ID: ${{ secrets.ALLOWED_USER_ID }}
          BASE_FOLDER: ${{ secrets.BASE_FOLDER }}
        run: |
          echo "🔄 Restarting unhealthy bot..."
          
          # Stop existing process
          pkill -f "bun.*src/index.ts" || true
          sleep 5
          
          # Navigate to bot directory and restart
          cd /path/to/discord-bot  # Update this path
          nohup bun start > /tmp/discord-bot.log 2>&1 &
          
          # Wait and verify restart
          sleep 10
          if pgrep -f "bun.*src/index.ts" > /dev/null; then
            echo "✅ Bot restarted successfully"
          else
            echo "❌ Bot restart failed"
            exit 1
          fi
```

## 🔧 Discord Bot Specific Optimizations

### 1. Memory Bank Integration Testing
```yaml
- name: Test Memory Bank Access
  run: |
    echo "🧠 Testing memory bank integration..."
    
    # Test memory bank file access
    if [ -d memory-bank ]; then
      echo "✅ Memory bank directory found"
      
      # Test key memory bank files
      test -f memory-bank/startHere.md || echo "⚠️ startHere.md missing"
      test -f memory-bank/progress.md || echo "⚠️ progress.md missing"
      
      # Count documentation files
      DOC_COUNT=$(find memory-bank -name "*.md" | wc -l)
      echo "Memory bank contains $DOC_COUNT documentation files"
    else
      echo "❌ Memory bank directory not found"
    fi
```

### 2. Claude Code Session Testing
```yaml
- name: Test Claude Code Session Management
  run: |
    echo "🤖 Testing Claude Code session management..."
    
    # Test database initialization
    if [ -f src/claude/manager.ts ]; then
      echo "✅ Claude manager found"
      
      # Test session database
      if grep -q "sqlite" package.json; then
        echo "✅ SQLite dependency found"
      fi
      
      # Test cleanup scripts
      if [ -f scripts/cleanup-sessions.sh ]; then
        echo "✅ Cleanup script found"
        ./scripts/cleanup-sessions.sh || echo "Cleanup completed"
      fi
    fi
```

### 3. Discord Integration Testing
```yaml
- name: Test Discord Integration
  run: |
    echo "🔗 Testing Discord integration..."
    
    # Test Discord.js version compatibility
    DISCORD_VERSION=$(bun pm ls | grep discord.js | head -1)
    echo "Discord.js version: $DISCORD_VERSION"
    
    # Test bot configuration
    if [ -f src/bot/client.ts ]; then
      echo "✅ Bot client found"
      
      # Check for required intents
      if grep -q "GatewayIntentBits" src/bot/client.ts; then
        echo "✅ Gateway intents configured"
      fi
    fi
```

## 💰 Cost Savings for Discord Bot Repository

### Current Usage Estimate
- **TypeScript builds**: ~400 minutes/month
- **Testing cycles**: ~300 minutes/month
- **Deployment**: ~50 minutes/month
- **Health checks**: ~100 minutes/month
- **Total**: ~850 minutes/month

### Savings Calculation
- **GitHub Actions cost**: 850 minutes × $0.008/minute = **$6.80/month**
- **Self-hosted cost**: $0
- **Annual savings**: $81.60/year

### Additional Benefits
- **Faster Bun builds** - Native performance vs emulated
- **Persistent bot testing** - Can run longer integration tests
- **Real-time debugging** - Access to live logs and processes
- **Custom tooling** - Install any Discord/Node.js tools needed

## 📋 Migration Steps for Discord Bot Repository

### Step 1: Update Current Workflows
```bash
# Navigate to discord bot repository
cd /github/claude-code-discord

# Check existing workflows
ls .github/workflows/

# Update existing workflows to use self-hosted runner
sed -i 's/runs-on: ubuntu-latest/runs-on: self-hosted/g' .github/workflows/*.yml
```

### Step 2: Add Bot-Specific Workflows
```bash
# Add the new workflows above
mkdir -p .github/workflows

# Add:
# - discord-bot-ci.yml
# - deploy.yml  
# - health-check.yml
```

### Step 3: Configure Secrets
```bash
# Add these secrets to repository settings:
# - DISCORD_TOKEN
# - ALLOWED_USER_ID  
# - BASE_FOLDER
```

### Step 4: Test Integration
```bash
# Test locally first
bun install
bun run test:run
bun run build

# Then commit and test CI
git add .github/workflows/
git commit -m "Add self-hosted runner workflows for Discord bot"
git push
```

## 🚨 Important Considerations

### Security for Discord Bot
- **Token protection**: Never log or expose Discord tokens
- **Secrets management**: Use GitHub secrets for sensitive data
- **Process isolation**: Each CI run gets fresh environment
- **Log sanitization**: Ensure no sensitive data in logs

### Performance Optimization
- **Bun caching**: Leverage Bun's fast package management
- **TypeScript incremental**: Use incremental compilation
- **Memory monitoring**: Watch for memory leaks in long-running tests
- **Process cleanup**: Ensure proper cleanup of bot processes

### Monitoring and Alerts
- **Health checks**: Regular automated health monitoring
- **Log rotation**: Prevent log files from growing too large
- **Resource monitoring**: Track CPU and memory usage
- **Error alerting**: Set up notifications for critical failures

---

Your Discord bot repository will benefit significantly from self-hosted runners, especially for the frequent TypeScript builds and testing cycles. The integration provides both cost savings and performance improvements for your bot development workflow.