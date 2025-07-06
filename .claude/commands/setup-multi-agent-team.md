# 🚀 Multi-Agent Team - Complete Automated Setup

Execute the full multi-agent development team setup automatically.

## 🎯 What This Command Does

1. **Creates Git Worktrees** for 4 agents (Alpha, Beta, Gamma, Delta)
2. **Sets up Communication System** with shared developer_coms/ directory
3. **Configures Monitoring & Recovery** scripts and commands
4. **Initializes Cost Tracking** and budget management
5. **Creates Emergency Protocols** and health monitoring
6. **Generates Team Dashboard** and metrics collection

## 🔧 Execution Steps

```bash
# 1. Verify prerequisites
echo "🔍 Verifying setup prerequisites..."
if [ ! -d ".git" ]; then
  echo "❌ Error: Not in a git repository"
  exit 1
fi

if ! command -v npm &> /dev/null; then
  echo "❌ Error: npm not found"
  exit 1
fi

echo "✅ Prerequisites verified"

# 2. Create directory structure
echo "📁 Creating directory structure..."
mkdir -p developer_coms scripts

# 3. Setup Git worktrees
echo "🌳 Creating Git worktrees..."
for agent in alpha beta gamma delta; do
  branch_name="feature/${agent}-agent-development"
  worktree_path="../coach-agent-${agent}"
  
  echo "Creating worktree for Agent ${agent^}..."
  
  # Create branch if it doesn't exist
  git checkout -b "$branch_name" 2>/dev/null || git checkout "$branch_name"
  git push -u origin "$branch_name" 2>/dev/null || true
  
  # Create worktree
  git worktree add "$worktree_path" "$branch_name" 2>/dev/null || {
    echo "Worktree already exists, removing and recreating..."
    git worktree remove "$worktree_path" --force
    git worktree add "$worktree_path" "$branch_name"
  }
  
  # Configure agent identity
  cd "$worktree_path"
  echo "Agent ${agent^} - Multi-Agent Development Team" > .agent_identity
  git config user.name "Agent ${agent^}"
  git config user.email "agent.${agent}@coach.dev"
  cd - > /dev/null
  
  echo "✅ Agent ${agent^} worktree ready"
done

# 4. Create communication system
echo "💬 Setting up communication system..."
cat > developer_coms/team_briefing_initial.md << 'BRIEF'
# Coach Project - Multi-Agent Development Sprint

## 🚀 Mission
Collaborative development of NoCapLife Coach platform using specialized agent roles.

## 📁 Project Structure
- **Main Repo**: `/Users/teamlift/GitHub/Coach/Coach`
- **Tech Stack**: Next.js 14, TypeScript, Supabase, Tailwind CSS
- **Development**: HTTPS local development at `https://localhost:3001`
- **Testing**: Vitest (unit) + Playwright (E2E)

## 🔧 Key Commands
```bash
# Development
npm run dev:https

# Testing  
npm test
npm run test:e2e

# Linting
npm run lint
```

## 🤝 Communication Protocol
- Check `developer_coms/` after every `git pull`
- Create files using format: `[YourName]_[YYYYMMDD]_[Topic].md`
- Vote on proposals: `+1` (agree), `-1` (disagree), `0` (abstain)

## 🎯 Current Sprint Goals
1. **Cholesterol Insights Enhancements** (Alpha)
2. **API Route Optimization** (Beta)  
3. **Testing Infrastructure** (Gamma)
4. **Code Quality Improvements** (Delta)
BRIEF

# 5. Create monitoring scripts
echo "📊 Creating monitoring and management scripts..."

# Team status dashboard
cat > scripts/generate-dashboard.sh << 'DASHBOARD'
#!/bin/bash
# Real-time Team Dashboard

DASHBOARD="developer_coms/DASHBOARD_$(date +%Y%m%d_%H%M).md"

cat > "$DASHBOARD" << 'DASH'
# 🚀 Multi-Agent Team Dashboard

**Last Updated**: $(date)

## 🤖 Agent Status

| Agent | Status | Branch | Commits Today | Files Modified | Last Activity |
|-------|--------|--------|---------------|----------------|--------------|
DASH

# Agent status table
for agent in Alpha Beta Gamma Delta; do
  agent_lower=$(echo $agent | tr '[:upper:]' '[:lower:]')
  worktree_path="../coach-agent-$agent_lower"
  
  if [ -d "$worktree_path" ]; then
    cd "$worktree_path"
    
    status="🟢 Active"
    branch=$(git branch --show-current)
    commits=$(git log --oneline --since='1 day ago' | wc -l)
    files=$(git status --porcelain | wc -l)
    
    # Check for recent activity
    if [ -f "/tmp/agent_${agent_lower}_last_activity" ]; then
      last_activity=$(cat "/tmp/agent_${agent_lower}_last_activity")
      time_diff=$(($(date +%s) - last_activity))
      if [ $time_diff -gt 3600 ]; then  # 1 hour
        status="🟡 Idle"
      fi
      if [ $time_diff -gt 7200 ]; then  # 2 hours
        status="🔴 Stale"
      fi
      last_time="$((time_diff / 60))m ago"
    else
      last_time="Unknown"
    fi
    
    echo "| $agent | $status | $branch | $commits | $files | $last_time |" >> "/Users/teamlift/GitHub/Coach/Coach/$DASHBOARD"
    cd - > /dev/null
  else
    echo "| $agent | ❌ Missing | - | - | - | - |" >> "/Users/teamlift/GitHub/Coach/Coach/$DASHBOARD"
  fi
done

# System metrics
cd /Users/teamlift/GitHub/Coach/Coach
cat >> "$DASHBOARD" << 'METRICS'

## 📊 System Metrics

- **🖥️ CPU Usage**: $(top -l 1 | grep 'CPU usage' | awk '{print $3}' | cut -d% -f1)%
- **💾 Memory Free**: $(memory_pressure | grep 'percentage' | awk '{print $5}')
- **🔗 API Calls Today**: $(grep "$(date +%Y-%m-%d)" .api_calls.log 2>/dev/null | wc -l)
- **💬 Communications**: $(find developer_coms/ -name "*.md" -mtime -1 | wc -l) files today
- **🧪 Tests**: $(npm test > /dev/null 2>&1 && echo '✅ Passing' || echo '❌ Failing')
- **🎨 Lint**: $(npm run lint > /dev/null 2>&1 && echo '✅ Clean' || echo '⚠️ Issues')

## 🚨 Active Issues

METRICS

# Check for urgent files
urgent_count=$(find developer_coms/ -name "URGENT_*.md" -mtime -1 | wc -l)
if [ $urgent_count -gt 0 ]; then
  echo "⚠️ **$urgent_count urgent issues** require attention:" >> "$DASHBOARD"
  find developer_coms/ -name "URGENT_*.md" -mtime -1 | while read file; do
    echo "- 📄 $(basename "$file")" >> "$DASHBOARD"
  done
else
  echo "✅ No urgent issues" >> "$DASHBOARD"
fi

echo "📊 Dashboard generated: $DASHBOARD"
DASHBOARD

chmod +x scripts/generate-dashboard.sh

# Cost monitoring
cat > scripts/monitor-costs.sh << 'COSTS'
#!/bin/bash
# API Cost Monitor

DAILY_BUDGET=50  # $50/day budget
WARNING_THRESHOLD=40  # Warn at $40

# Estimate costs (rough calculation)
api_calls_today=$(grep "$(date +%Y-%m-%d)" .api_calls.log 2>/dev/null | wc -l)
estimated_cost=$(echo "scale=2; $api_calls_today * 0.02" | bc)  # $0.02 per call estimate

echo "📊 Daily API Cost Estimate: \$${estimated_cost}"
echo "📅 Calls today: $api_calls_today"
echo "💰 Budget remaining: \$$(echo "scale=2; $DAILY_BUDGET - $estimated_cost" | bc)"

if [ "$(echo "$estimated_cost > $WARNING_THRESHOLD" | bc)" -eq 1 ]; then
  echo "⚠️ WARNING: Approaching daily budget limit!"
  
  # Create budget warning
  cat > developer_coms/BUDGET_WARNING_$(date +%Y%m%d_%H%M).md << WARNING
# 💰 Budget Warning

**Current Usage**: \$${estimated_cost}
**Daily Budget**: \$${DAILY_BUDGET}
**Remaining**: \$$(echo "scale=2; $DAILY_BUDGET - $estimated_cost" | bc)

## Recommended Actions
- Reduce agent activity frequency
- Focus on highest priority tasks only
- Consider pausing non-critical agents

**Auto-generated**: $(date)
WARNING
fi
COSTS

chmod +x scripts/monitor-costs.sh

# 6. Initialize tracking files
echo "📝 Initializing tracking files..."
touch .api_calls.log
echo "0" > .cost_tracker

# 7. Update .gitignore
echo "🔒 Updating .gitignore..."
if ! grep -q ".agent_identity" .gitignore; then
  echo "" >> .gitignore
  echo "# Multi-Agent System" >> .gitignore
  echo ".agent_identity" >> .gitignore
  echo ".api_calls.log" >> .gitignore
  echo ".cost_tracker" >> .gitignore
  echo "/tmp/agent_*" >> .gitignore
fi

# 8. Commit setup
echo "💾 Committing setup..."
git add developer_coms/ scripts/ .gitignore .claude/
git commit -m "Setup multi-agent development environment

- Add 4 agent worktrees with specialized roles
- Create communication and monitoring systems
- Implement cost tracking and emergency protocols
- Add automated health checks and recovery procedures

🤖 Ready for multi-agent collaboration!"

git push origin mvp-1.6-features

# 9. Generate initial dashboard
echo "📊 Generating initial dashboard..."
./scripts/generate-dashboard.sh

echo ""
echo "🎉 MULTI-AGENT TEAM SETUP COMPLETE!"
echo ""
echo "📋 Next Steps:"
echo "1. Open 4 terminal sessions"
echo "2. In each session, run one of these commands:"
echo "   /agent-alpha-init"
echo "   /agent-beta-init"
echo "   /agent-gamma-init"
echo "   /agent-delta-init"
echo ""
echo "📊 Monitor progress with: /team-status"
echo "🚨 Emergency stop with: /emergency-stop"
echo "💰 Check costs with: ./scripts/monitor-costs.sh"
echo ""
echo "💡 The team is ready to collaborate! 🤖👥"
```

**Execute this command and your entire multi-agent team will be ready in minutes!**