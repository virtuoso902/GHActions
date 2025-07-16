# Setup Requirements

**Purpose:** System requirements and prerequisites for runner setup  
**Size:** 🟢 AI-friendly

## System Requirements

### Operating System
- **Linux**: Ubuntu 20.04+, Debian 10+, RHEL 8+, or compatible
- **macOS**: 11.0+ (Big Sur or later)
- **Windows**: Windows 10/11 with WSL2

### Software Prerequisites

#### Required
- **Docker**: Version 20.10.0 or higher
- **Docker Compose**: Version 2.0.0 or higher (usually included with Docker Desktop)
- **Git**: For cloning the repository

#### How to Verify
```bash
# Check Docker
docker --version
docker-compose --version

# Verify Docker daemon is running
docker info

# Check Git
git --version
```

### Hardware Requirements

#### Minimum
- **CPU**: 2 cores
- **RAM**: 4GB
- **Storage**: 10GB free space

#### Recommended
- **CPU**: 4+ cores (for concurrent jobs)
- **RAM**: 8GB+ (2GB per concurrent runner)
- **Storage**: 50GB+ (for Docker images and build artifacts)

## GitHub Requirements

### Access Token
You need a GitHub Personal Access Token (PAT) with appropriate permissions:

#### For Repository-Level Runners
Required scope: `repo` (Full control of private repositories)

#### For Organization-Level Runners  
Required scope: `admin:org` (Full control of orgs and teams)

#### Creating a Token
1. Go to GitHub Settings > Developer settings > Personal access tokens
2. Click "Generate new token (classic)"
3. Select required scopes
4. Set expiration (recommend 90 days)
5. Copy token immediately (won't be shown again)

### Repository/Organization Access
- **Repository**: Admin access to the target repository
- **Organization**: Owner or admin role in the organization

## Network Requirements

### Outbound Connections
The runner needs to connect to:
- `github.com` (HTTPS/443)
- `api.github.com` (HTTPS/443)
- `*.actions.githubusercontent.com` (HTTPS/443)
- Docker Hub or container registries (HTTPS/443)

### Firewall Rules
```bash
# Required outbound ports
- 443/tcp (HTTPS)
- 80/tcp (HTTP, for package downloads)
- 22/tcp (Git SSH, optional)
```

## Security Considerations

### Token Security
- Store tokens in `.env` file (never commit)
- Use environment variables, not hardcoded values
- Rotate tokens regularly (every 90 days)
- Use fine-grained tokens when possible

### Docker Security
- User must be in `docker` group or have sudo access
- Docker daemon must be running
- Consider Docker rootless mode for additional security

### File Permissions
```bash
# Ensure proper permissions
chmod 600 .env
chmod 755 scripts/*.sh
```

## Pre-Setup Checklist

- [ ] Docker installed and running
- [ ] Docker Compose available
- [ ] GitHub PAT created with correct scope
- [ ] Network access to GitHub
- [ ] Sufficient disk space
- [ ] User has Docker permissions

## Validation Commands

```bash
# Run all checks
./scripts/check-requirements.sh

# Manual checks
docker run hello-world
curl -s https://api.github.com/meta
```

---

**Next Step:** Once requirements are met, proceed to [user-experience.md](user-experience.md) for setup instructions.