# Technical Design: Organization-Level Runner

**Purpose:** System architecture and technical implementation details for organization-level runner  
**When to use:** Understanding system changes, API modifications, and technical architecture  
**Quick sections:** `## Component Architecture`, `## API Integration`, `## Security Model`  
**Size:** 🟡 Large file with section navigation

## Component Architecture

### Current Architecture (Repository-Level)
```
GitHub Repository (virtuoso902/mcp)
         ↓
Registration Token API Call
         ↓
Runner Registration (Single Repository)
         ↓
Job Execution (Repository-Specific)
```

### New Architecture (Organization-Level)
```
GitHub Organization (virtuoso902)
         ↓
Registration Token API Call
         ↓
Runner Registration (Organization-Wide)
         ↓
Runner Groups (Repository Access Control)
         ↓
Job Distribution (Multi-Repository)
```

### Key Components

#### 1. Registration Service
- **Current**: `https://api.github.com/repos/{owner}/{repo}/actions/runners/registration-token`
- **New**: `https://api.github.com/orgs/{org}/actions/runners/registration-token`
- **Change**: API endpoint modification in `docker/entrypoint.sh`

#### 2. Runner Configuration
- **Current**: Repository-specific labels and naming
- **New**: Organization-wide labels with repository identification
- **Change**: Environment variable structure and labeling strategy

#### 3. Access Control
- **Current**: Implicit repository access through registration
- **New**: Explicit runner group access control
- **Change**: Runner group configuration and repository permissions

## API Integration

### GitHub Actions Runner API Changes

#### Registration Token Request
```bash
# Current (Repository-Level)
curl -X POST \
  -H "Authorization: token ${GITHUB_TOKEN}" \
  -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/repos/${GITHUB_REPOSITORY}/actions/runners/registration-token"

# New (Organization-Level)
curl -X POST \
  -H "Authorization: token ${GITHUB_TOKEN}" \
  -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/orgs/${GITHUB_ORGANIZATION}/actions/runners/registration-token"
```

#### Runner Registration
```bash
# Current Configuration
./config.sh \
  --url "https://github.com/${GITHUB_REPOSITORY}" \
  --token "${REGISTRATION_TOKEN}" \
  --name "${RUNNER_NAME}" \
  --labels "self-hosted,Linux,X64,ephemeral,docker"

# New Configuration
./config.sh \
  --url "https://github.com/${GITHUB_ORGANIZATION}" \
  --token "${REGISTRATION_TOKEN}" \
  --name "${RUNNER_NAME}" \
  --labels "self-hosted,Linux,X64,ephemeral,docker,org-runner" \
  --runnergroup "${RUNNER_GROUP}"
```

### Environment Variable Changes

#### Current Configuration (.env)
```bash
GITHUB_TOKEN=oauth_token
GITHUB_REPOSITORY=virtuoso902/mcp
RUNNER_NAME=ephemeral-runner
LABELS=self-hosted,Linux,X64,ephemeral,docker
```

#### New Configuration (.env)
```bash
GITHUB_TOKEN=oauth_token
GITHUB_ORGANIZATION=virtuoso902
RUNNER_NAME=ephemeral-org-runner
RUNNER_GROUP=default
LABELS=self-hosted,Linux,X64,ephemeral,docker,org-runner
```

## Security Model

### Runner Groups Architecture

#### Default Runner Group
```
virtuoso902 Organization
├── Default Runner Group
│   ├── ephemeral-org-runner
│   └── Repository Access:
│       ├── coach (private)
│       ├── mcp (private)
│       ├── personal (private)
│       └── ghActions (private)
```

#### Security Boundaries
- **Job Isolation**: Each job runs in ephemeral container
- **Repository Isolation**: Runner groups control repository access
- **Credential Isolation**: Secrets are job-specific and time-limited
- **Network Isolation**: Containers have isolated networking

### OAuth Token Requirements
```bash
# Required Token Scopes
- repo (full repository access)
- admin:org (organization administration)
- workflow (workflow management)
```

## Data Flow & State Management

### Job Assignment Flow
```
1. Workflow Trigger (any repository)
         ↓
2. GitHub Job Queue
         ↓
3. Runner Group Selection
         ↓
4. Available Runner Assignment
         ↓
5. Job Execution (ephemeral container)
         ↓
6. Container Cleanup
```

### State Management
- **Runner State**: Managed by GitHub Actions service
- **Job State**: Isolated per container execution
- **Configuration State**: Centralized in organization settings
- **Monitoring State**: Aggregated across all job executions

## Integration Architecture

### File System Changes

#### Configuration Files
```
/config/
├── .env.example → Updated with organization variables
├── .env.repository-backup → Backup of repository-level config
└── .env → New organization-level configuration
```

#### Scripts Updates
```
/scripts/
├── start.sh → Modified for organization registration
├── stop.sh → Enhanced cleanup for organization runner
├── status.sh → Organization-aware status reporting
├── rollback.sh → NEW: Rollback to repository-level
└── org-status.sh → NEW: Organization runner monitoring
```

#### Docker Configuration
```
/docker/
├── entrypoint.sh → Modified for organization API endpoints
├── Dockerfile → Enhanced labels for organization runner
└── docker-compose.yml → Updated environment variables
```

### Repository Integration Points

#### Workflow Configuration Changes
```yaml
# Minimal Change Required
jobs:
  build:
    runs-on: self-hosted  # Works unchanged
    # OR with specific labels
    runs-on: [self-hosted, org-runner]
```

#### Repository-Specific Customization
```yaml
# For repository-specific requirements
jobs:
  build:
    runs-on: [self-hosted, org-runner, ${{ github.repository }}]
    # Allows repository-specific runner selection if needed
```

## Performance Considerations

### Scaling Characteristics
- **Single Runner**: Handles one job at a time
- **Job Queueing**: GitHub manages job distribution
- **Resource Sharing**: Efficient use of host resources
- **Startup Time**: ~20-30 seconds per job (unchanged)

### Monitoring Points
- **Runner Status**: Online/offline state
- **Job Distribution**: Which repositories are using the runner
- **Resource Usage**: CPU, memory, disk per job
- **Performance Metrics**: Job execution time, queue time

## Error Handling & Recovery

### Failure Scenarios
1. **Registration Failure**: Automatic retry with exponential backoff
2. **Token Expiration**: Automatic token refresh
3. **Network Issues**: Graceful degradation and retry
4. **Container Failure**: Automatic cleanup and restart

### Recovery Procedures
```bash
# Automatic Recovery
- Container restart on failure
- Automatic re-registration
- Health check monitoring
- Graceful shutdown handling

# Manual Recovery
- Rollback to repository-level runner
- Emergency stop procedures
- Configuration validation
- Status verification
```

## Testing Strategy Integration

### Unit Testing
- Configuration validation scripts
- API endpoint testing
- Environment variable validation
- Docker container health checks

### Integration Testing
- Multi-repository job execution
- Runner group access control
- Security isolation verification
- Performance benchmarking

### End-to-End Testing
- Complete workflow execution across all repositories
- Rollback procedure validation
- Monitoring and alerting verification
- Documentation accuracy testing