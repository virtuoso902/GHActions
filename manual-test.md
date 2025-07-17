# Manual Test Instructions

Since your GitHub token doesn't have the `workflow` scope, here's how to test the runner:

## Option 1: Update Token Scope (Recommended)

1. Go to: https://github.com/settings/tokens
2. Click on your token
3. Add these scopes:
   - `workflow` (Create and update GitHub Actions workflows)
   - `read:org` (Read organization membership)
4. Save changes
5. Update your `.env` file with the new token

## Option 2: Manual Workflow Creation

1. Go to your repository: https://github.com/virtuoso902/GHActions
2. Click "Actions" tab
3. Click "set up a workflow yourself"
4. Copy this workflow content:

```yaml
name: Test Self-Hosted Runner
on:
  workflow_dispatch:
  push:
    branches: [ main ]

jobs:
  test-runner:
    runs-on: self-hosted
    steps:
      - uses: actions/checkout@v4
      
      - name: 🏃 Runner Information
        run: |
          echo "✅ Running on self-hosted runner!"
          echo "Runner name: ${RUNNER_NAME:-unknown}"
          echo "Runner OS: ${RUNNER_OS:-Linux}"
          echo "Runner Arch: ${RUNNER_ARCH:-X64}"
          echo "Working Directory: $(pwd)"
          
      - name: 🐳 Test Docker Access
        run: |
          echo "Docker version:"
          docker --version
          echo ""
          echo "Docker info:"
          docker info | grep -E "(Server Version|Operating System|Architecture)"
          
      - name: 🎉 Success
        run: |
          echo "## Test Complete!"
          echo "✅ Self-hosted runner is working correctly!"
          echo "✅ Docker access verified!"
          echo "✅ Ready to save GitHub Actions minutes!"
```

5. Commit the workflow
6. Go to Actions tab and run "Test Self-Hosted Runner"

## Current Status

✅ **Runner is online and ready!**
- Docker container running
- Registered with GitHub as "ephemeral-runner"
- Status: Online
- Labels: self-hosted, Linux, ARM64, X64, ephemeral, docker

Your runner is actively listening for jobs and will execute any workflow that uses `runs-on: self-hosted`.