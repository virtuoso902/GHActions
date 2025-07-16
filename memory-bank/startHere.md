# GitHub Actions Runner - Navigation Hub

**Purpose:** Master navigation for GitHub Actions self-hosted runner documentation  
**When to use:** Start here when loading memory bank or beginning any task  
**Quick sections:** `## What This Does`, `## Quick Start`, `## Navigation Paths`  
**Size:** 🟢 AI-friendly

## What This Does

This project provides **ephemeral Docker-based GitHub Actions runners** that:
- Save GitHub Actions minutes by running jobs on your infrastructure
- Provide maximum security through ephemeral containers
- Scale horizontally with simple commands
- Self-register and self-cleanup automatically

## Quick Start (2 minutes)

```bash
# 1. Configure
cp .env.example .env
# Add your GITHUB_TOKEN and GITHUB_REPOSITORY

# 2. Start runner
./scripts/start.sh

# 3. Verify
# Check Settings > Actions > Runners in your GitHub repo
```

## File Size Categories

- **🟢 AI-Friendly (<400 lines)**: Direct use - configs, scripts, this file
- **🟡 Large (400-600 lines)**: Use sections - technical docs
- **🔴 Very Large (>600 lines)**: Start with summary - implementation guides

## Navigation Paths by Task

### 🚀 First-Time Setup
```
1. README.md → Quick overview
2. .env.example → Configure credentials  
3. scripts/start.sh → Launch runner
4. features/setup/requirements.md → Detailed requirements
```

### 🔧 Managing Runners
```
1. scripts/status.sh → Check health
2. docker-compose.yml → Scaling configuration
3. features/operations/README.md → Operations guide
```

### 🔒 Security Review
```
1. features/security/README.md → Security overview
2. features/security/technical-design.md → Architecture
3. docker/Dockerfile → Container configuration
```

### 🐛 Troubleshooting
```
1. scripts/status.sh → Current state
2. docker-compose logs → Error details
3. features/troubleshooting/README.md → Common issues
```

## Directory Structure

```
/github/GHActions/
├── README.md                    # 🟢 Project overview
├── docker-compose.yml          # 🟢 Service definition
├── .env.example               # 🟢 Configuration template
├── docker/
│   ├── Dockerfile             # 🟢 Runner container
│   └── entrypoint.sh         # 🟢 Container startup
├── scripts/
│   ├── start.sh              # 🟢 Start runners
│   ├── stop.sh               # 🟢 Stop runners
│   └── status.sh             # 🟢 Check status
└── memory-bank/
    ├── startHere.md          # 🎯 This file
    ├── projectbrief.md       # 🟢 Core requirements
    ├── systemPatterns.md     # 🟢 Architecture patterns
    └── features/             # Modular documentation
```

## Core Concepts

### Ephemeral Runners
- Each job gets a fresh container
- Container destroyed after job completes
- No state persists between jobs
- Maximum security and isolation

### Docker-outside-of-Docker
- Mounts host Docker socket
- Avoids privileged containers
- Better security than Docker-in-Docker
- Allows building container images

### Auto-Scaling
- Single command to add runners: `docker-compose up -d --scale runner=3`
- Each runner handles one job at a time
- Automatic registration with GitHub

## Success Metrics

- **Setup Time**: <5 minutes from clone to running
- **Security**: Zero state persistence between jobs
- **Cost Savings**: 50-90% reduction in Actions minutes
- **Maintenance**: <10 minutes per month

---

**Next Steps:** Follow the Quick Start above or explore specific navigation paths based on your needs.