# Installation Guide - GitHub Actions Self-Hosted Runner

## Prerequisites

### 1. Install Docker Desktop

**macOS:**
```bash
# Download from: https://www.docker.com/products/docker-desktop/
# Or use Homebrew:
brew install --cask docker
```

**Linux:**
```bash
# Ubuntu/Debian
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER
# Log out and back in for group changes

# Start Docker
sudo systemctl start docker
sudo systemctl enable docker
```

**Windows:**
- Install WSL2 first: https://docs.microsoft.com/en-us/windows/wsl/install
- Then install Docker Desktop: https://www.docker.com/products/docker-desktop/

### 2. Verify Docker Installation

```bash
# Check Docker
docker --version
docker run hello-world

# Check Docker Compose
docker compose version
```

## Setup Steps

### 1. Clone or Download This Repository

```bash
cd /github
git clone https://github.com/virtuoso902/GHActions.git
cd GHActions
```

### 2. Create GitHub Personal Access Token

1. Go to: https://github.com/settings/tokens/new
2. Name: "Self-Hosted Runner"
3. Expiration: 90 days (recommended)
4. Scopes:
   - **For repository runner:** Select `repo`
   - **For organization runner:** Select `admin:org`
5. Click "Generate token"
6. **COPY THE TOKEN NOW** (you won't see it again)

### 3. Configure the Runner

**Option A: Interactive Setup (Recommended)**
```bash
./scripts/setup-token.sh
```

**Option B: Manual Setup**
```bash
cp .env.example .env
# Edit .env and add your token and repository
nano .env  # or use your preferred editor
```

### 4. Start the Runner

```bash
# Check all requirements first
./scripts/check-requirements.sh

# Start the runner
./scripts/start.sh
```

### 5. Verify in GitHub

1. Go to your repository on GitHub
2. Navigate to: Settings → Actions → Runners
3. You should see your new runner listed as "ephemeral-runner"

## Testing the Runner

### Create a Test Workflow

Create `.github/workflows/test-runner.yml` in your repository:

```yaml
name: Test Self-Hosted Runner
on:
  workflow_dispatch:  # Manual trigger
  push:
    branches: [ main ]

jobs:
  test:
    runs-on: self-hosted
    steps:
      - uses: actions/checkout@v4
      
      - name: Runner Info
        run: |
          echo "Running on self-hosted runner!"
          echo "Runner name: $RUNNER_NAME"
          echo "Runner OS: $RUNNER_OS"
          echo "Runner Arch: $RUNNER_ARCH"
          
      - name: Test Docker Access
        run: docker --version
        
      - name: Test Build
        run: |
          echo "FROM alpine:latest" > Dockerfile.test
          echo "RUN echo 'Hello from self-hosted runner'" >> Dockerfile.test
          docker build -f Dockerfile.test -t test-image .
          docker run --rm test-image
```

### Trigger the Test

1. Go to Actions tab in your repository
2. Select "Test Self-Hosted Runner"
3. Click "Run workflow"
4. Watch it execute on your self-hosted runner

## Managing Runners

### View Status
```bash
./scripts/status.sh
```

### View Logs
```bash
docker-compose logs -f
```

### Stop Runners
```bash
./scripts/stop.sh
```

### Scale Runners
```bash
# Run 3 concurrent runners
docker-compose up -d --scale runner=3
```

## Troubleshooting

### Docker Not Running
```bash
# macOS: Start Docker Desktop app
# Linux:
sudo systemctl start docker
```

### Token Issues
- Tokens expire after set duration
- Create new token and update .env
- Restart runners after token update

### Runner Not Showing in GitHub
1. Check logs: `docker-compose logs`
2. Verify token has correct permissions
3. Check network access to GitHub
4. Ensure repository/org name is correct

### Permission Denied Errors
```bash
# Fix script permissions
chmod +x scripts/*.sh

# Fix Docker permissions (Linux)
sudo usermod -aG docker $USER
# Then log out and back in
```

## Security Notes

- **NEVER** commit .env file (it's in .gitignore)
- Rotate tokens every 90 days
- Use ephemeral mode for public repositories
- Monitor runner usage in GitHub settings

## Next Steps

1. Add runner to your CI/CD workflows
2. Monitor resource usage with `docker stats`
3. Set up monitoring/alerts for runner health
4. Consider implementing caching volumes for faster builds

---

For more documentation, see [memory-bank/startHere.md](memory-bank/startHere.md)