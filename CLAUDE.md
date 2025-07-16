# CLAUDE.md - GitHub Actions Self-Hosted Runner

**Purpose:** Claude Code development guidance for GitHub Actions runner project  
**Documentation:** Complete project documentation in [memory-bank/](memory-bank/) following framework standards  
**Size:** 🟢 AI-friendly

This file provides guidance to Claude Code (claude.ai/code) when working with the GitHub Actions self-hosted runner project.

## Project Overview

This is a **Docker-based ephemeral GitHub Actions runner** designed to save GitHub Actions minutes by running workflows on local infrastructure. Each job runs in a fresh container that is destroyed after completion, ensuring maximum security.

## Quick Reference

**Start Runner:** `./scripts/start.sh`  
**Stop Runner:** `./scripts/stop.sh`  
**Check Status:** `./scripts/status.sh`  
**Scale Runners:** `docker-compose up -d --scale runner=3`  
**View Logs:** `docker-compose logs -f`

## Architecture Highlights

- **Ephemeral Containers**: Each job gets a fresh environment
- **Docker-outside-of-Docker**: Secure container operations
- **Auto-Registration**: Self-registers with GitHub
- **Self-Cleanup**: Automatic deregistration on exit

## Development Workflow

### 1. Memory Bank First
Always start by reading:
- `memory-bank/startHere.md` - Navigation hub
- `memory-bank/projectbrief.md` - Core requirements
- Relevant feature documentation in `memory-bank/features/`

### 2. Configuration
```bash
# Copy and configure
cp .env.example .env
# Add GITHUB_TOKEN and GITHUB_REPOSITORY/ORGANIZATION
```

### 3. Testing Changes
```bash
# Build image
docker-compose build

# Test locally
docker-compose up

# Verify registration in GitHub
# Settings > Actions > Runners
```

### 4. Documentation Updates
- Update relevant files in `memory-bank/features/`
- Follow Domain-Driven Documentation structure
- Use file size indicators (🟢🟡🔴)

## Security Guidelines

### Never Commit
- `.env` files with real tokens
- Hardcoded credentials
- Production secrets

### Always Do
- Use `.env.example` as template
- Validate environment variables
- Test with dummy values in CI

### Token Management
```bash
# Validate token format (not value)
[[ "$GITHUB_TOKEN" =~ ^gh[ps]_[a-zA-Z0-9]{36}$ ]] || echo "Invalid token format"
```

## Tool Usage Patterns

### File Operations
```bash
# Read configuration
Read: .env.example, docker-compose.yml, Dockerfile

# Find scripts
Glob: scripts/*.sh

# Search for patterns
Grep: "GITHUB_TOKEN" --include="*.{sh,yml}"
```

### Docker Operations
```bash
# Check running containers
docker-compose ps

# View real-time logs
docker-compose logs -f runner

# Inspect container
docker-compose exec runner bash
```

## Common Tasks

### Adding New Features
1. Create feature branch: `git checkout -b feature/runner-enhancement`
2. Update Docker configuration if needed
3. Test thoroughly with ephemeral runners
4. Update memory-bank documentation
5. Create PR with testing evidence

### Troubleshooting
1. Check `./scripts/status.sh` output
2. Review `docker-compose logs`
3. Verify GitHub token permissions
4. Check network connectivity to GitHub

### Scaling Runners
```bash
# Scale to 5 runners
docker-compose up -d --scale runner=5

# Monitor resource usage
docker stats

# Adjust based on workload
```

## Project Structure

```
/github/GHActions/
├── docker/
│   ├── Dockerfile          # Runner container definition
│   └── entrypoint.sh      # Container startup script
├── scripts/
│   ├── start.sh           # Start runners
│   ├── stop.sh            # Stop runners
│   └── status.sh          # Check status
├── docker-compose.yml     # Service orchestration
├── .env.example          # Configuration template
└── memory-bank/          # Documentation
    ├── startHere.md      # Navigation hub
    └── features/         # Feature-specific docs
```

## Integration with CI/CD

### Using in Workflows
```yaml
jobs:
  build:
    runs-on: self-hosted  # Or use labels
    steps:
      - uses: actions/checkout@v4
      - run: echo "Running on self-hosted runner!"
```

### Label Strategy
- `self-hosted` - Required label
- `linux` - OS identifier  
- `x64` - Architecture
- `ephemeral` - Indicates single-use
- `docker` - Container-based

## Performance Considerations

- **Startup Time**: ~20-30 seconds per container
- **No Caching**: Each job starts fresh (security trade-off)
- **Concurrent Jobs**: Limited by host resources
- **Network**: Requires stable GitHub connectivity

## Best Practices

1. **Always use ephemeral mode** for security
2. **Monitor resource usage** when scaling
3. **Rotate tokens** every 90 days
4. **Test workflows** on self-hosted before production
5. **Document runner-specific** requirements in workflows

---

This project prioritizes **security** and **simplicity** over performance optimizations like caching. The ephemeral nature ensures a clean, secure environment for every job execution.