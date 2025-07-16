# GitHub Actions Self-Hosted Runner

**Purpose:** Ephemeral Docker-based GitHub Actions runner to save Actions minutes  
**Architecture:** Security-first containerized runners with automatic cleanup  
**Quick Start:** Copy `.env.example` to `.env`, configure, run `./scripts/start.sh`

## Overview

This project provides a secure, ephemeral GitHub Actions self-hosted runner implementation using Docker. Each job runs in a fresh container that is destroyed after completion, ensuring no state persistence between runs.

## Features

- 🔒 **Security-First**: Ephemeral containers with no persistent state
- 🐳 **Docker-Based**: Easy deployment and consistent environment
- 🚀 **Auto-Scaling**: Support for multiple concurrent runners
- 🧹 **Self-Cleaning**: Automatic cleanup after each job
- 📊 **Cost Savings**: Reduce GitHub Actions minutes usage

## Quick Start

```bash
# 1. Clone and configure
cd /github/GHActions
cp .env.example .env
# Edit .env with your GitHub token and repository/org

# 2. Start runner
./scripts/start.sh

# 3. Verify in GitHub
# Go to Settings > Actions > Runners in your repo/org
```

## Requirements

- Docker and Docker Compose installed
- GitHub Personal Access Token with appropriate permissions:
  - For repository runners: `repo` scope
  - For organization runners: `admin:org` scope

## Configuration

Edit `.env` file with your settings:

```env
GITHUB_TOKEN=your_token_here
GITHUB_REPOSITORY=owner/repo  # For repo-level runner
# OR
GITHUB_ORGANIZATION=org-name   # For org-level runner
```

## Commands

```bash
./scripts/start.sh   # Start runner(s)
./scripts/stop.sh    # Stop all runners
./scripts/status.sh  # Check runner status

# Scale to multiple runners
docker-compose up -d --scale runner=3
```

## Architecture

- **Ephemeral Design**: Each runner container is destroyed after job completion
- **Docker-outside-of-Docker**: Mounts host Docker socket for container operations
- **No State Persistence**: Ensures clean environment for each job
- **Automatic Registration**: Self-registers with GitHub on startup

## Security Considerations

- Runners are ephemeral - destroyed after each job
- No persistent storage between runs
- Suitable for public repositories when properly configured
- Uses non-root user inside containers
- Automatic cleanup on container exit

## Documentation

See [memory-bank/](memory-bank/) for comprehensive documentation following the Domain-Driven Documentation framework.