# Quick Start Guide

## 🚀 5-Minute Setup

### Prerequisites
- Docker Desktop installed and running
- GitHub Personal Access Token

### Setup Commands

```bash
# 1. Install Docker (if needed)
# macOS: Download Docker Desktop from docker.com
# Linux: curl -fsSL https://get.docker.com | sh

# 2. Configure your runner
./scripts/setup-token.sh
# Enter your GitHub token and repository

# 3. Start the runner
./scripts/start.sh

# 4. Verify it's working
./scripts/status.sh
```

### Test Your Runner

1. Push this repository to GitHub
2. Go to Actions tab
3. Run "Test Self-Hosted Runner" workflow
4. Watch it execute on your runner!

### Common Commands

```bash
# View logs
docker-compose logs -f

# Stop runner
./scripts/stop.sh

# Scale to 3 runners
docker-compose up -d --scale runner=3
```

## 📋 Checklist

- [ ] Docker Desktop installed
- [ ] Docker running (`docker ps` works)
- [ ] GitHub token created (with `repo` scope)
- [ ] `.env` file configured
- [ ] Runner started
- [ ] Visible in GitHub Settings > Actions > Runners
- [ ] Test workflow executed successfully

## 🆘 Troubleshooting

**Docker not found:**
- Install Docker Desktop
- Start Docker Desktop application

**Token error:**
- Ensure token has `repo` scope (or `admin:org` for org runners)
- Token format: starts with `ghp_` or `github_pat_`

**Runner not showing:**
- Check logs: `docker-compose logs`
- Verify repository name in `.env`
- Check internet connectivity

---

For detailed instructions, see [INSTALL.md](INSTALL.md)