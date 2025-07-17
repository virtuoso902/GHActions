# Repository Expansion Guide: Organization-Level Runner

**Purpose:** Step-by-step guide for adding new repositories to the organization-level runner  
**When to use:** Adding new repositories to use the shared runner infrastructure  
**Quick sections:** `## Prerequisites`, `## Integration Steps`, `## Testing Procedures`  
**Size:** 🟢 AI-friendly

## Prerequisites

### Repository Requirements
- Repository must be in the `virtuoso902` organization
- Repository must be private (for security with shared runner)
- Repository must have GitHub Actions enabled
- Repository must have workflow files in `.github/workflows/`

### Access Requirements
- Organization admin permissions to manage runner groups
- Repository admin permissions to modify workflow files
- Valid OAuth token with `admin:org` scope

## Integration Steps

### Step 1: Repository Preparation
```bash
# Clone the new repository
git clone https://github.com/virtuoso902/new-repo.git
cd new-repo

# Check for existing workflows
ls -la .github/workflows/
```

### Step 2: Workflow Configuration
```yaml
# Update existing workflow files
# Change from:
jobs:
  build:
    runs-on: ubuntu-latest

# To:
jobs:
  build:
    runs-on: self-hosted
    # OR with specific labels
    runs-on: [self-hosted, org-runner]
```

### Step 3: Runner Group Access (if needed)
```bash
# Check current runner group configuration
gh api "orgs/virtuoso902/actions/runner-groups" --jq '.runner_groups[]'

# Add repository to runner group (if not using default)
gh api "orgs/virtuoso902/actions/runner-groups/{group_id}/repositories" \
  --method PUT \
  --field repository_ids[]={repository_id}
```

## Quick Integration Examples

### Node.js/TypeScript Projects
```yaml
name: CI/CD Pipeline
on: [push, pull_request]

jobs:
  test:
    runs-on: self-hosted
    steps:
      - uses: actions/checkout@v4
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '18'
      - name: Install dependencies
        run: npm install
      - name: Run tests
        run: npm test
      - name: Build
        run: npm run build
```

### Python Projects
```yaml
name: Python CI
on: [push, pull_request]

jobs:
  test:
    runs-on: self-hosted
    steps:
      - uses: actions/checkout@v4
      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.9'
      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install -r requirements.txt
      - name: Run tests
        run: python -m pytest
```

### Docker Projects
```yaml
name: Docker Build
on: [push, pull_request]

jobs:
  build:
    runs-on: self-hosted
    steps:
      - uses: actions/checkout@v4
      - name: Build Docker image
        run: docker build -t ${{ github.repository }}:${{ github.sha }} .
      - name: Run tests
        run: docker run --rm ${{ github.repository }}:${{ github.sha }} npm test
      - name: Cleanup
        run: docker image prune -f
        if: always()
```

## Testing Procedures

### Step 1: Workflow Validation
```bash
# Test workflow syntax
gh workflow list --repo virtuoso902/new-repo

# Validate workflow files
gh workflow view workflow-name.yml --repo virtuoso902/new-repo
```

### Step 2: Test Job Execution
```bash
# Trigger a test workflow
gh workflow run "CI/CD Pipeline" --repo virtuoso902/new-repo

# Monitor job execution
gh run list --workflow="CI/CD Pipeline" --repo virtuoso902/new-repo --limit 1
```

### Step 3: Verify Runner Assignment
```bash
# Check runner status during job
./scripts/org-status.sh

# Verify job completion
gh run view --repo virtuoso902/new-repo --log
```

## Repository-Specific Configurations

### High-Security Repositories
```yaml
# For sensitive repositories, use specific runner labels
jobs:
  build:
    runs-on: [self-hosted, org-runner, secure]
    environment: production
```

### Resource-Intensive Repositories
```yaml
# For repositories needing more resources
jobs:
  build:
    runs-on: [self-hosted, org-runner, heavy-compute]
    timeout-minutes: 60
```

### Multi-Platform Repositories
```yaml
# For cross-platform testing
jobs:
  test:
    runs-on: [self-hosted, org-runner, ${{ matrix.os }}]
    strategy:
      matrix:
        os: [linux, macos, windows]
```

## Common Integration Patterns

### Microservices Architecture
```yaml
# For microservices with multiple services
jobs:
  test-services:
    runs-on: self-hosted
    strategy:
      matrix:
        service: [api, web, worker, scheduler]
    steps:
      - uses: actions/checkout@v4
      - name: Test ${{ matrix.service }}
        run: |
          cd services/${{ matrix.service }}
          npm test
```

### Monorepo Projects
```yaml
# For monorepo with path-based triggers
jobs:
  test:
    runs-on: self-hosted
    steps:
      - uses: actions/checkout@v4
      - name: Check changed files
        uses: dorny/paths-filter@v2
        id: changes
        with:
          filters: |
            frontend:
              - 'frontend/**'
            backend:
              - 'backend/**'
      - name: Test frontend
        if: steps.changes.outputs.frontend == 'true'
        run: cd frontend && npm test
      - name: Test backend
        if: steps.changes.outputs.backend == 'true'
        run: cd backend && npm test
```

## Security Considerations

### Repository Access Control
- Ensure repository is private
- Limit repository access to necessary team members
- Use environment protection rules for sensitive deployments
- Implement proper secret management

### Workflow Security
```yaml
# Security best practices
jobs:
  build:
    runs-on: self-hosted
    permissions:
      contents: read
      pull-requests: read
    steps:
      - uses: actions/checkout@v4
      - name: Validate inputs
        run: |
          # Always validate inputs
          echo "Validating workflow inputs..."
```

## Troubleshooting

### Common Issues

#### Runner Not Available
```bash
# Check runner status
./scripts/org-status.sh

# Verify runner group access
gh api "orgs/virtuoso902/actions/runner-groups" --jq '.runner_groups[].repositories[]'
```

#### Job Queueing
```bash
# Check job queue
gh run list --repo virtuoso902/new-repo --status queued

# Check runner capacity
docker stats ghactions-runner-1
```

#### Permission Errors
```bash
# Check token permissions
gh auth status

# Verify repository access
gh api "repos/virtuoso902/new-repo"
```

## Maintenance

### Regular Checks
- Monthly review of repository access
- Quarterly security assessment
- Regular performance monitoring
- Backup and disaster recovery testing

### Monitoring
```bash
# Monitor runner usage across repositories
./scripts/org-status.sh

# Check resource usage
docker stats --no-stream

# Review job success rates
gh run list --status completed --limit 50
```

## Future Enhancements

### Scaling Considerations
- Multiple runner deployment
- Load balancing strategies
- Resource optimization
- Performance monitoring

### Advanced Features
- Custom runner images
- Specialized runner groups
- Advanced security configurations
- Integration with monitoring systems

This expansion guide provides a complete framework for adding new repositories to the organization-level runner infrastructure with proper security, testing, and maintenance procedures.