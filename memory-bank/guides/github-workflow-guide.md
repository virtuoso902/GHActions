# GitHub Issues Workflow Guide

## Overview

This guide outlines the optimized GitHub Issues workflow for both Claude Code and Cursor, designed for efficient human-AI collaboration.

## Core Workflow Components

### Issue Templates
- **🚀 Feature Request** - AI-assisted feature development with complexity analysis
- **🐛 Bug Report** - Smart debugging with investigation hints  
- **⚡ Quick Task** - Sub-30-minute tasks with minimal overhead
- **📈 Enhancement** - Improvements to existing functionality
- **🔧 Refactor** - Code quality and technical debt cleanup

### Project Board
- **Location**: https://github.com/users/virtuoso902/projects/2
- **Columns**: Todo → In Progress → Review → Done
- **Auto-management**: Scripts handle issue assignment and updates

### Labels System
- **Type**: `bug`, `feature`, `enhancement`, `refactor`, `quick-task`
- **Priority**: `high-priority`, `medium-priority`, `low-priority`  
- **Status**: `needs-triage`, `in-progress`, `blocked`

## Essential Automation Scripts

### 1. Workflow Status & Triage
```bash
# Quick workflow overview
./scripts/github-automation/workflow-simple.sh status

# Auto-assign priorities to new issues
./scripts/github-automation/workflow-simple.sh triage
```

### 2. Feature Development Setup
```bash
# Creates branch, file structure, and TODO placeholders
./scripts/github-automation/feature-kickstart.sh [issue-number]
```

### 3. Issue Creation & Project Management
```bash
# Create issues with templates (works for both Claude Code & Cursor)
./scripts/github-automation/create-issue.sh feature "Feature name"
./scripts/github-automation/create-issue.sh bug "Bug description"
./scripts/github-automation/create-issue.sh quick "Quick task"

# Add existing issue to board  
./scripts/github-automation/project-helper.sh add [issue-number]
```

## Human-AI Collaboration Patterns

### Human Focus Areas
- **Architecture decisions** and system design
- **Product requirements** and UX design
- **Code review** and quality gates
- **Testing strategy** and deployment

### AI Focus Areas  
- **Boilerplate code** and repetitive tasks
- **Implementation** following established patterns
- **Unit test generation** and documentation
- **Code optimization** and refactoring

## Daily Development Workflow

### 1. Start Work Session
```bash
# Check current status
./scripts/github-automation/workflow-simple.sh status

# Triage any new issues
./scripts/github-automation/workflow-simple.sh triage
```

### 2. Select Work Type

**For Features:**
```bash
# Method 1: Use web interface (easiest)
gh issue create --web

# Method 2: CLI with template content  
gh issue create --title "[FEATURE] Your feature name" --body "$(cat .github/ISSUE_TEMPLATE/feature.md | tail -n +8)" --label "feature,needs-triage"

# Then run kickstart
./scripts/github-automation/feature-kickstart.sh [issue-number]
```

**For Quick Tasks:**
```bash
gh issue create --title "[QUICK] Your task" --body "$(cat .github/ISSUE_TEMPLATE/quick-task.md | tail -n +8)" --label "quick-task,needs-triage"
```

**For Bugs:**
```bash
gh issue create --title "[BUG] Bug description" --body "$(cat .github/ISSUE_TEMPLATE/bug.md | tail -n +8)" --label "bug,needs-triage"
```

### 3. Complete Work
```bash
# Commit with issue reference
git commit -m "feat: implement feature (fixes #123)"

# Close issue
gh issue close [number] --comment "Completed in commit [hash]"
```

## Best Practices

### Issue Creation
- **Use appropriate templates** for consistent structure
- **Check complexity boxes** for proper automation
- **Reference memory-bank** documentation when relevant
- **Include clear acceptance criteria**

### Development Process
- **One issue per task** - keep focused and actionable
- **Reference issue numbers** in all commits
- **Update labels** as work progresses  
- **Close promptly** when work completes

### AI Collaboration
- **Let AI handle boilerplate** after human designs architecture
- **Use kickstart scripts** to eliminate setup overhead
- **Focus human time** on decisions and quality gates
- **Review AI work** for correctness and patterns

## Integration Points

### Memory Bank References
- Link issues to relevant `memory-bank/features/` documentation
- Update memory bank after significant implementation changes
- Use memory bank context for architectural decisions

### CLAUDE.md Integration
- Quick command references in Task Management section
- Development command workflows
- Tool-specific usage patterns

### .cursorrules Integration  
- Coding standards and quick rules
- Issue workflow reminders
- AI collaboration guidelines

This workflow optimizes for rapid development while maintaining code quality through proper human-AI role separation and efficient automation.