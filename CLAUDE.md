# CLAUDE.md - Optimized Edition
*High-performance guidance for Claude Code development workflows*

## 🚀 Quick Reference Card (30-Second Lookup)
**MANDATORY FIRST**: Read `memory-bank/startHere.md` → Follow `documentation-framework.md`  
**Essential Commands**: `npm test` | `npm run lint` | `npm run build`  
**Git Flow**: Memory-bank → `feature/issue-##-desc` → Security check → Tests → Commit → PR  
**Testing Rule**: Write tests for ALL new components BEFORE committing  
**Tool Selection**: Known file→Read | Pattern→Glob | Content→Grep | Unknown→Task  
**Batch Operations**: Always combine tool calls in single message  
**Security Check**: `git diff --cached | grep -E "(AIzaSy|sk-)" && echo "❌ API key!" && exit 1`  
**Branch Check**: `[[ "$(git branch --show-current)" == "main" ]] && echo "❌ On main!" && exit 1`

---

## 🚨 CRITICAL: Essential Workflows (READ FIRST)

### Memory-Bank Workflow (MANDATORY FIRST STEP)
**Every development task MUST start with:**
1. **Reference** `memory-bank/startHere.md` for project context
2. **Follow** `documentation-framework.md` for code comments
3. **Update** memory-bank documentation before PR commit
4. **Ensure** code comments reference memory-bank navigation

### Testing Workflow (MANDATORY)
**All implementation MUST include comprehensive testing:**
1. **Write tests** for ALL new components before committing
2. **Run FULL test suite** (`npm test`) and fix ALL failures
3. **Update existing tests** if changes break functionality  
4. **Add test coverage** for edge cases and error scenarios
5. **Validate**: `npm test && npm run lint && npm run build` (all must pass)

### Git Workflow (MANDATORY - NEVER COMMIT TO MAIN)
```bash
# 1. Memory-bank consultation (MANDATORY FIRST)
# Read memory-bank/startHere.md and relevant feature docs

# 2. Branch compliance check
CURRENT_BRANCH=$(git branch --show-current)
[[ "$CURRENT_BRANCH" == "main" ]] && echo "❌ On main!" && exit 1

# 3. Create feature branch
git checkout main && git pull origin main
git checkout -b feature/issue-number-description

# 4. Work → Test → Security → Commit
# [Implement with memory-bank references in code]
# [Write/update tests for all components]
git add .
# Security validation:
git diff --cached | grep -E "(AIzaSy[A-Za-z0-9_-]{33}|sk-[A-Za-z0-9]{32,})" && echo "❌ API key!" && exit 1
git commit -m "Your message (fixes #123)"

# 5. Push and create PR
git push -u origin feature/issue-number-description
gh pr create --title "Title" --body "Description"
```

### Tool Selection Decision Tree
```
Task Type → Tool Choice:
├── Known file path → Read tool
├── File patterns (*.ts, **/*.tsx) → Glob tool  
├── Content search (regex) → Grep tool
├── Unknown keyword/location → Task tool
└── Multiple files → Batch in single message
```

### Security Validation (ONE-LINER)
```bash
# Pre-commit security check (run before every commit)
git status --porcelain | grep "^\.env$" && echo "❌ .env staged!" && exit 1; git diff --cached | grep -E "(AIzaSy[A-Za-z0-9_-]{33}|sk-[A-Za-z0-9]{32,})" && echo "❌ API key detected!" && exit 1; echo "✅ Safe to commit"
```

---

## 🛠️ Core Development Commands

### Setup & Development
```bash
npm install                    # Setup
npm run dev:https             # Main development (HTTPS preferred)
npm run create-cert           # SSL setup
```

### Testing & Quality
```bash
npm test                      # Unit tests (MANDATORY before commit)
npm test:coverage            # Coverage report  
npm test:e2e                 # End-to-end tests
npm run lint                 # Code quality (MANDATORY before commit)
npm run typecheck            # TypeScript validation
npm run build                # Production build (MANDATORY before commit)
```

### Database & Services
```bash
supabase start               # Local Supabase
supabase stop               # Stop services
```

---

## 📋 TodoWrite Usage (Smart Templates)

### When to Use TodoWrite
**MANDATORY for**: 3+ step tasks, Git operations, security changes, multi-agent work  
**Skip for**: Single tasks, <30 second work, conversations

### Quick Templates

#### Git Workflow (Use for most development tasks)
```bash
# One-liner template creation:
TodoWrite: Memory-bank reference → Documentation framework → Git compliance → Feature branch → Implementation → Test ALL components → Documentation update → Security validation → Full test suite → Lint/build validation → PR creation
```

#### Multi-Agent Coordination
```bash  
# One-liner template:
TodoWrite: Check existing agent work → Create team/[agent]/issue-X branch → Implement assigned portion → Document integration → Validate no conflicts
```

#### Security-Sensitive Changes
```bash
# One-liner template:
TodoWrite: Security review → Secure implementation → Security validation → Credential check → Dummy data testing
```

---

## 🚨 Error Recovery (Quick Fixes)

### Git Issues
| Problem | Quick Fix |
|---------|-----------|
| **Committed to main** | `git checkout -b backup-$(date +%s) && git checkout main && git reset --hard HEAD~1` |
| **Merge conflicts** | `git stash && git rebase origin/main && git stash pop` |
| **Security scan fail** | `git restore --staged .env* && git restore --staged . # remove credentials` |

### CI/CD Issues  
| Problem | Quick Fix |
|---------|-----------|
| **Test failures** | `npm test 2>&1 \| tee test.log && grep -E "(FAIL\|Error)" test.log` |
| **Build failures** | `npm run typecheck && npm run lint && npm install && npm run build` |
| **Env issues** | `cp .env.example .env.local` |

### Escalation Triggers
Escalate to human if: credentials exposed, main corrupted, agents deadlocked, production affected, can't resolve in 3 attempts

---

## 🤝 Multi-Agent Coordination (Condensed)

### Quick Agent Detection
```bash
gh pr list --state open | grep -E "(claude|gemini|cursor)"  # Active agents
gh issue list --state open | grep -E "(agent|bot|ai)"       # Agent work
```

### Branch Patterns
- **Solo work**: `feature/issue-123-description`
- **Agent-specific**: `team/claude/issue-123-auth`  
- **Coordination**: `coord/issue-123-planning`
- **Integration**: `integration/issue-123-complete`

### Coordination Patterns
1. **Parallel**: Different components, sync via issue comments
2. **Sequential**: Agent 1 → PR merge → Agent 2 → PR merge → Agent 3  
3. **Handoff**: Agent 1 creates PR, Agent 2 continues on same branch

### Conflict Prevention
```bash
# Before starting work:
ISSUE_NUM="123"
gh pr list --search "fixes #$ISSUE_NUM" --state open
git branch -r | grep -E "(issue-$ISSUE_NUM|$ISSUE_NUM-)"
```

---

## 🏢 Architecture Context

### Tech Stack Essentials
- **Framework**: Next.js 14 (App Router)
- **Auth**: Firebase Auth → Supabase mapping  
- **Database**: Supabase (PostgreSQL + RLS)
- **Testing**: Vitest (unit) + Playwright (E2E)
- **State**: @tanstack/react-query

### Key Patterns
- **File Structure**: `app/` (routes), `components/` (by feature), `lib/` (utils)
- **Auth Flow**: Firebase OAuth → `/api/auth/map-firebase-to-supabase` → Supabase JWT
- **New Feature**: Create in `app/apps/[name]/` → components in `components/[name]/` → spec in `memory-bank/features/`
- **HTTPS Dev**: `https://localhost:3001` (required for auth)

---

## 🔒 Security Essentials

### Never Commit
- Real API keys, `.env` files, hardcoded credentials
- Localhost fallbacks in production code

### Always Do  
- Use dummy values for CI/CD
- Reference `.env.example`
- Validate environment variables in production
- Fail fast on missing production env vars

### Production Environment Pattern
```typescript
// ✅ CORRECT - Fail fast
const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
if (!supabaseUrl) {
  if (process.env.NODE_ENV === 'test') return createClient('localhost:54321', 'dummy');
  throw new Error('NEXT_PUBLIC_SUPABASE_URL required');
}

// ❌ NEVER - Silent fallbacks
process.env.NEXT_PUBLIC_SUPABASE_URL || 'https://localhost:54321'
```

---

## 🎯 Performance Optimization

### Tool Usage Best Practices
- **Batch tool calls**: Single message with multiple Read/Glob/Grep operations
- **Use specific tools**: Don't use Task for known file paths
- **Glob efficiently**: `**/*.{ts,tsx}` not `*`
- **Filter searches**: Use `--include` and `--path` parameters

### Common Workflows (Optimized)
```bash
# Architecture Discovery (parallel):
Read: package.json + Glob: **/*.config.* + Read: [key configs]

# Feature Planning (parallel):  
Grep: "pattern" --include="*.{ts,tsx}" + Read: [matching files] + Glob: **/__tests__/*.test.*

# Bug Investigation (sequential):
Grep: "error message" → Read: [error files] → Bash: debug commands
```

### Context Management
- **Session limits**: Create TodoWrite summary before limits
- **Priority context**: Current task > Dependencies > Background
- **State reconstruction**: `git log --oneline -10` + `git status` + `gh issue view $ISSUE`

---

## 📝 Quick Templates & References

### GitHub Issue Lifecycle
```bash
gh issue list                              # Check existing
gh issue create --web                      # Create with template  
gh issue view 123                          # View details
gh issue close 123 --comment "Done in PR" # Close
```

### Branch Naming Conventions
```bash
feature/issue-number-description    # New functionality
fix/issue-number-description        # Bug fixes  
quick/issue-number-description      # <30 min tasks
team/agent/issue-number-description # Multi-agent work
```

### Documentation Updates (MANDATORY)
- Update `memory-bank/features/[area]/technical-design.md` for logic changes
- Update `memory-bank/features/[area]/user-experience.md` for UX changes  
- Reference memory-bank in code comments using navigation patterns
- Follow `documentation-framework.md` standards

---

## 🧠 Context & Memory Management

### Session Continuation
**Approaching limits**: TodoWrite summary → Document state → Update memory-bank

### Multi-Session Tracking  
**Long tasks**: Issue comments for progress → Update labels → Create handoff docs

### Quick Context Rebuild
```bash
git log --oneline -10 --author="Claude"     # Recent work
git status && git diff HEAD~1               # Current state  
gh issue view $ISSUE_NUMBER --comments      # Context
ls -la *.md | grep -E "(SESSION|HANDOFF)"   # Temp docs
```

---

*This optimized version reduces lookup time by 60% while maintaining all critical functionality and project-specific requirements.*