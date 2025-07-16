# Setup Feature - Navigation Hub

**Purpose:** Complete setup guide for GitHub Actions self-hosted runner  
**Scope:** From zero to running runner in production  
**Size:** 🟢 AI-friendly navigation

## Overview

This feature covers the complete setup process for the GitHub Actions self-hosted runner, from initial requirements through production deployment.

## Documentation Structure

- **requirements.md** (🟢) - Prerequisites and system requirements
- **user-experience.md** (🟢) - Step-by-step setup flow
- **technical-design.md** (🟢) - Configuration details and architecture
- **implementation.md** (🟢) - Scripts and automation details
- **decisions.md** (🟢) - Key setup decisions and rationale

## Quick Links

### For First-Time Setup
1. Check [requirements.md](requirements.md) for prerequisites
2. Follow [user-experience.md](user-experience.md) for step-by-step guide
3. Reference [technical-design.md](technical-design.md) for configuration options

### For Automation
1. See [implementation.md](implementation.md) for script details
2. Check [decisions.md](decisions.md) for setup choices

## Key Concepts

- **GitHub Token**: Personal Access Token for runner registration
- **Registration**: Process of connecting runner to GitHub
- **Ephemeral Mode**: Single-use runner containers
- **Environment Configuration**: Using .env files safely

## Common Tasks

- **Basic Setup**: Copy `.env.example`, add token, run `start.sh`
- **Organization Setup**: Use `GITHUB_ORGANIZATION` instead of repository
- **Multiple Runners**: Scale with Docker Compose
- **Verification**: Check GitHub Settings > Actions > Runners

---

**Next Step:** Start with [requirements.md](requirements.md) to ensure your system is ready.