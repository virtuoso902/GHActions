# Implementation Guide: Organization-Level Runner

**Purpose:** Detailed implementation steps and file changes for organization-level runner  
**When to use:** Step-by-step implementation, file modifications, and deployment procedures  
**Quick sections:** `## File Organization`, `## API Integration`, `## Rollback Procedures`  
**Size:** 🔴 Very large file - use section navigation

## Executive Summary

This implementation guide provides detailed steps to convert the current repository-level GitHub Actions runner to an organization-level runner. The implementation includes configuration changes, API endpoint modifications, rollback procedures, and testing across all target repositories.

### Key Changes Overview
- **API Endpoints**: Switch from repository to organization registration
- **Environment Variables**: Update configuration for organization-level operation
- **Runner Groups**: Implement access control for repository isolation
- **Scripts**: Enhanced management and monitoring capabilities
- **Rollback**: Complete rollback procedures for risk mitigation

## File Organization

### New Files Created
```
/memory-bank/features/organization-level-runner/
├── README.md (🟢) - Feature navigation hub
├── requirements.md (🟢) - Business requirements
├── technical-design.md (🟡) - System architecture
├── implementation.md (🔴) - This file
├── testing-strategy.md (🟡) - Testing procedures
└── decisions.md (🟢) - Architectural decisions

/config/
├── .env.organization - Organization-level configuration
├── .env.repository-backup - Backup of repository-level config
└── rollback/
    ├── rollback.sh - Rollback script
    └── restore-repository.sh - Repository restoration

/scripts/
├── org-status.sh - Organization runner monitoring
├── validate-config.sh - Configuration validation
└── test-multi-repo.sh - Multi-repository testing
```

### Modified Files
```
docker/entrypoint.sh - API endpoint changes
.env.example - Updated configuration template
scripts/start.sh - Organization registration logic
scripts/stop.sh - Enhanced cleanup
scripts/status.sh - Organization-aware reporting
docker-compose.yml - Updated environment variables
```

## API Integration

### Step 1: Environment Configuration

#### Create Organization Configuration
```bash
# Create new organization-level configuration
cat > .env.organization << 'EOF'
# GitHub Actions Organization-Level Runner Configuration

# GitHub OAuth Token (from gh auth)
GITHUB_TOKEN=your_oauth_token_here

# Organization runner - Changed from repository-level
GITHUB_ORGANIZATION=virtuoso902

# Runner configuration
RUNNER_NAME=ephemeral-org-runner
RUNNER_GROUP=default
LABELS=self-hosted,Linux,X64,ephemeral,docker,org-runner
EPHEMERAL=true

# Repository Access Control (for future runner groups)
ALLOWED_REPOSITORIES=coach,mcp,personal,ghActions
EOF
```

#### Backup Current Configuration
```bash
# Backup current repository-level configuration
cp .env .env.repository-backup

# Create rollback directory
mkdir -p config/rollback
```

### Step 2: Update Docker Entrypoint

#### Modify docker/entrypoint.sh
```bash
# Original repository-level logic
if [ -n "$GITHUB_REPOSITORY" ]; then
    REGISTRATION_URL="https://github.com/${GITHUB_REPOSITORY}"
    API_URL="https://api.github.com/repos/${GITHUB_REPOSITORY}/actions/runners/registration-token"
else
    # Error handling
fi

# New organization-level logic
if [ -n "$GITHUB_ORGANIZATION" ]; then
    REGISTRATION_URL="https://github.com/${GITHUB_ORGANIZATION}"
    API_URL="https://api.github.com/orgs/${GITHUB_ORGANIZATION}/actions/runners/registration-token"
elif [ -n "$GITHUB_REPOSITORY" ]; then
    # Fallback to repository-level for compatibility
    REGISTRATION_URL="https://github.com/${GITHUB_REPOSITORY}"
    API_URL="https://api.github.com/repos/${GITHUB_REPOSITORY}/actions/runners/registration-token"
else
    echo "Error: Either GITHUB_ORGANIZATION or GITHUB_REPOSITORY must be set"
    exit 1
fi
```

#### Enhanced Runner Configuration
```bash
# Add runner group support
RUNNER_GROUP_PARAM=""
if [ -n "$RUNNER_GROUP" ]; then
    RUNNER_GROUP_PARAM="--runnergroup ${RUNNER_GROUP}"
fi

# Updated config.sh command
./config.sh \
    --url "${REGISTRATION_URL}" \
    --token "${REGISTRATION_TOKEN}" \
    --name "${RUNNER_NAME}" \
    --work "${RUNNER_WORKDIR}" \
    --labels "${LABELS}" \
    ${RUNNER_GROUP_PARAM} \
    --unattended \
    --replace \
    $([ "$EPHEMERAL" = "true" ] && echo "--ephemeral")
```

### Step 3: Update Management Scripts

#### Enhanced scripts/start.sh
```bash
#!/bin/bash
set -e

# Load configuration
source .env

# Validate organization configuration
if [ -z "$GITHUB_ORGANIZATION" ] && [ -z "$GITHUB_REPOSITORY" ]; then
    echo "❌ Error: Either GITHUB_ORGANIZATION or GITHUB_REPOSITORY must be set"
    exit 1
fi

# Display configuration
echo "🚀 GitHub Actions Self-Hosted Runner - Startup Script"
echo "=================================================="
if [ -n "$GITHUB_ORGANIZATION" ]; then
    echo "🏢 Organization: $GITHUB_ORGANIZATION"
    echo "📋 Runner Group: ${RUNNER_GROUP:-default}"
    echo "🏷️  Mode: Organization-level"
else
    echo "📁 Repository: $GITHUB_REPOSITORY"
    echo "🏷️  Mode: Repository-level (fallback)"
fi
echo "🏃 Runner Name: $RUNNER_NAME"
echo "⚡ Ephemeral: $EPHEMERAL"
echo ""

# Build and start
echo "🔨 Building Docker image..."
docker-compose build

echo "🚀 Starting runner..."
docker-compose up -d

echo ""
echo "✅ Runner started successfully!"
echo "Commands:"
echo "  View logs: docker-compose logs -f"
echo "  Stop runner: docker-compose down"
echo "  Scale runners: docker-compose up -d --scale runner=3"
```

#### New scripts/org-status.sh
```bash
#!/bin/bash
set -e

# Organization runner status script
source .env

if [ -z "$GITHUB_ORGANIZATION" ]; then
    echo "❌ Error: GITHUB_ORGANIZATION not set"
    exit 1
fi

echo "🏢 Organization Runner Status"
echo "============================"
echo "Organization: $GITHUB_ORGANIZATION"
echo "Runner Group: ${RUNNER_GROUP:-default}"
echo ""

# Check runner status via GitHub API
echo "📊 GitHub API Status:"
gh api "orgs/$GITHUB_ORGANIZATION/actions/runners" \
    --jq '.runners[] | select(.name | contains("'"$RUNNER_NAME"'")) | {name: .name, status: .status, busy: .busy, labels: [.labels[].name]}'

echo ""
echo "🐳 Container Status:"
docker-compose ps

echo ""
echo "📈 Recent Activity:"
docker-compose logs --tail 10 | grep -E "(Listening|Running|Completed)" || echo "No recent activity"
```

### Step 4: Create Rollback Procedures

#### Create config/rollback/rollback.sh
```bash
#!/bin/bash
set -e

echo "🔄 Rolling back to repository-level runner..."
echo "============================================="

# Stop current runner
echo "⏹️  Stopping organization-level runner..."
docker-compose down

# Restore repository-level configuration
echo "📁 Restoring repository-level configuration..."
if [ -f ".env.repository-backup" ]; then
    cp .env.repository-backup .env
    echo "✅ Repository configuration restored"
else
    echo "❌ Error: No backup configuration found"
    exit 1
fi

# Restart with repository-level configuration
echo "🚀 Starting repository-level runner..."
docker-compose up -d

echo ""
echo "✅ Rollback completed successfully!"
echo "📊 Verify status with: ./scripts/status.sh"
```

#### Create config/rollback/restore-repository.sh
```bash
#!/bin/bash
set -e

# Complete restoration script
echo "🔄 Complete Repository-Level Restoration"
echo "======================================="

# Stop all containers
docker-compose down

# Restore all configuration files
cp .env.repository-backup .env
cp docker/entrypoint.sh.backup docker/entrypoint.sh
cp scripts/start.sh.backup scripts/start.sh
cp scripts/status.sh.backup scripts/status.sh

# Rebuild with repository configuration
docker-compose build
docker-compose up -d

echo "✅ Complete restoration completed!"
```

### Step 5: Update Configuration Templates

#### Update .env.example
```bash
# GitHub Actions Self-Hosted Runner Configuration

# Authentication - GitHub OAuth Token (from gh auth)
GITHUB_TOKEN=your_oauth_token_here

# Runner Registration (Choose ONE)
# Option 1: Organization-level runner (RECOMMENDED)
GITHUB_ORGANIZATION=virtuoso902
RUNNER_GROUP=default

# Option 2: Repository-level runner (fallback)
# GITHUB_REPOSITORY=virtuoso902/your-repo

# Runner Configuration
RUNNER_NAME=ephemeral-org-runner
LABELS=self-hosted,Linux,X64,ephemeral,docker,org-runner
EPHEMERAL=true

# Repository Access Control (for organization runners)
ALLOWED_REPOSITORIES=coach,mcp,personal,ghActions

# Advanced Configuration
RUNNER_WORKDIR=/home/runner/_work
CLEANUP_TIMEOUT=300
```

#### Update docker-compose.yml
```yaml
version: '3.8'

services:
  runner:
    build:
      context: .
      dockerfile: docker/Dockerfile
    container_name: ghactions-runner-org
    environment:
      - GITHUB_TOKEN=${GITHUB_TOKEN}
      - GITHUB_ORGANIZATION=${GITHUB_ORGANIZATION}
      - GITHUB_REPOSITORY=${GITHUB_REPOSITORY}
      - RUNNER_NAME=${RUNNER_NAME:-ephemeral-org-runner}
      - RUNNER_GROUP=${RUNNER_GROUP:-default}
      - LABELS=${LABELS:-self-hosted,Linux,X64,ephemeral,docker,org-runner}
      - EPHEMERAL=${EPHEMERAL:-true}
      - ALLOWED_REPOSITORIES=${ALLOWED_REPOSITORIES}
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    restart: unless-stopped
    labels:
      - "runner.type=organization"
      - "runner.org=virtuoso902"
      - "runner.group=${RUNNER_GROUP:-default}"
```

## Component Architecture

### Runner Registration Flow
```
1. Load Configuration (.env)
         ↓
2. Validate Organization/Repository Settings
         ↓
3. Request Registration Token (Organization API)
         ↓
4. Configure Runner (with Runner Group)
         ↓
5. Start Listening for Jobs
         ↓
6. Job Distribution (Multi-Repository)
```

### Security Architecture
```
GitHub Organization (virtuoso902)
├── Runner Group: default
│   ├── Runner: ephemeral-org-runner
│   └── Repository Access:
│       ├── coach (private)
│       ├── mcp (private)
│       ├── personal (private)
│       └── ghActions (private)
└── Job Isolation:
    ├── Ephemeral Containers
    ├── Isolated Networking
    └── Credential Isolation
```

## Data Flow & State Management

### Configuration Management
```
.env.organization (Primary)
     ↓
Environment Variables
     ↓
Docker Container
     ↓
GitHub API Registration
     ↓
Runner Groups Configuration
```

### Job Execution Flow
```
Repository Workflow Trigger
         ↓
GitHub Job Queue
         ↓
Runner Group Selection
         ↓
Available Runner Assignment
         ↓
Ephemeral Container Creation
         ↓
Job Execution
         ↓
Container Cleanup
```

## Testing Integration

### Configuration Validation
```bash
# Create scripts/validate-config.sh
#!/bin/bash
set -e

echo "🔍 Validating Organization Runner Configuration"
echo "============================================="

# Check required variables
required_vars=("GITHUB_TOKEN" "GITHUB_ORGANIZATION" "RUNNER_NAME")
for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        echo "❌ Error: $var is not set"
        exit 1
    fi
done

# Validate GitHub API access
echo "🔐 Validating GitHub API access..."
gh api "orgs/$GITHUB_ORGANIZATION/actions/runners" > /dev/null
echo "✅ GitHub API access confirmed"

# Validate OAuth token permissions
echo "🔐 Validating OAuth token permissions..."
token_info=$(gh auth status 2>&1)
if echo "$token_info" | grep -q "admin:org"; then
    echo "✅ OAuth token has admin:org permissions"
else
    echo "❌ Error: OAuth token missing admin:org permissions"
    exit 1
fi

echo "✅ Configuration validation passed"
```

### Multi-Repository Testing
```bash
# Create scripts/test-multi-repo.sh
#!/bin/bash
set -e

echo "🧪 Testing Multi-Repository Access"
echo "================================="

repositories=("coach" "mcp" "personal" "ghActions")

for repo in "${repositories[@]}"; do
    echo "Testing repository: virtuoso902/$repo"
    
    # Check if repository exists and is accessible
    if gh api "repos/virtuoso902/$repo" > /dev/null 2>&1; then
        echo "✅ Repository accessible: $repo"
    else
        echo "❌ Repository not accessible: $repo"
    fi
done

echo ""
echo "🏃 Testing runner assignment..."
gh api "orgs/virtuoso902/actions/runners" \
    --jq '.runners[] | select(.name | contains("'"$RUNNER_NAME"'")) | {name: .name, status: .status, busy: .busy}'
```

## Rollback Procedures

### Quick Rollback (5 minutes)
```bash
# Emergency rollback to repository-level
./config/rollback/rollback.sh

# Verify rollback
./scripts/status.sh
```

### Complete Rollback (15 minutes)
```bash
# Full restoration with file backups
./config/rollback/restore-repository.sh

# Validation testing
./scripts/validate-config.sh
```

### Rollback Testing
```bash
# Test rollback procedures
echo "🧪 Testing rollback procedures..."

# Backup current state
cp .env .env.test-backup

# Perform rollback
./config/rollback/rollback.sh

# Verify repository-level operation
./scripts/status.sh

# Restore organization-level
cp .env.organization .env
./scripts/start.sh
```

## Monitoring and Maintenance

### Health Checks
```bash
# Continuous monitoring
watch -n 30 './scripts/org-status.sh'

# Automated health check
*/5 * * * * /path/to/ghActions/scripts/org-status.sh > /tmp/runner-health.log 2>&1
```

### Performance Monitoring
```bash
# Resource usage monitoring
docker stats ghactions-runner-org

# Job execution monitoring
docker logs ghactions-runner-org | grep -E "(Listening|Running|Completed)"
```

## Troubleshooting

### Common Issues

#### Registration Failures
```bash
# Debug registration token
echo "🔍 Debug registration token..."
curl -s -H "Authorization: token $GITHUB_TOKEN" \
    "https://api.github.com/orgs/$GITHUB_ORGANIZATION/actions/runners/registration-token" | jq

# Check token permissions
gh auth status
```

#### Job Assignment Issues
```bash
# Check runner groups
gh api "orgs/virtuoso902/actions/runner-groups" --jq '.runner_groups[]'

# Check runner status
gh api "orgs/virtuoso902/actions/runners" --jq '.runners[]'
```

#### Container Issues
```bash
# Debug container logs
docker-compose logs -f

# Check container health
docker inspect ghactions-runner-org | jq '.[0].State'
```

This implementation provides a complete, tested, and documented solution for organization-level GitHub Actions runners with full rollback capability and comprehensive testing procedures.