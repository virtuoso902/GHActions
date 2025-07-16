# System Patterns: GitHub Actions Self-Hosted Runner

**Purpose:** Architecture patterns and design decisions for the runner system  
**When to use:** Understanding system design, making architectural decisions  
**Quick sections:** `## Core Architecture`, `## Security Patterns`, `## Operational Patterns`  
**Size:** 🟢 AI-friendly

## Core Architecture

### Container Lifecycle Pattern
```
GitHub Workflow Triggered
         ↓
Runner Container Created (Fresh)
         ↓
Job Executed in Container
         ↓
Container Destroyed (Cleanup)
```

**Key Principles:**
- One container per job
- No state persistence
- Automatic lifecycle management
- Clean environment guarantee

### Registration Pattern
```
Container Start
      ↓
Request Registration Token (API)
      ↓
Configure Runner (Ephemeral Flag)
      ↓
Register with GitHub
      ↓
Start Listening for Jobs
      ↓
Deregister on Exit (Trap)
```

**Implementation:**
- Uses GitHub API for token exchange
- Ephemeral flag ensures single-job execution
- Trap ensures cleanup even on failure

## Security Patterns

### Ephemeral Security Model
```
┌─────────────────────────┐
│   Host System           │
├─────────────────────────┤
│ Docker Daemon           │
├─────────────────────────┤
│ ┌─────────────────────┐ │
│ │ Runner Container 1  │ │ ← Destroyed after Job 1
│ └─────────────────────┘ │
│ ┌─────────────────────┐ │
│ │ Runner Container 2  │ │ ← Destroyed after Job 2
│ └─────────────────────┘ │
└─────────────────────────┘
```

**Security Benefits:**
- No secrets persist between jobs
- No build artifacts contamination
- No malicious code persistence
- Fresh dependencies each run

### Docker-outside-of-Docker (DooD)
```
Runner Container
      ↓
Mounts /var/run/docker.sock
      ↓
Docker CLI in Container
      ↓
Operations on Host Docker
```

**Why Not Docker-in-Docker:**
- DinD requires privileged mode (security risk)
- DooD provides same functionality safely
- Better performance and resource usage

## Operational Patterns

### Scaling Pattern
```
docker-compose up -d --scale runner=N
         ↓
N Runner Containers Created
         ↓
Each Registers Independently
         ↓
GitHub Distributes Jobs
```

**Characteristics:**
- Horizontal scaling only
- Each runner handles one job
- No inter-runner communication
- Simple load distribution

### Health Monitoring Pattern
```
Status Check Script
      ↓
Docker Container Status
      ↓
Registration Verification
      ↓
Health Report
```

**Monitoring Points:**
- Container running state
- Registration with GitHub
- Recent job execution
- Resource usage

## Configuration Patterns

### Environment Variable Hierarchy
```
.env File (Git Ignored)
      ↓
docker-compose.yml References
      ↓
Container Environment
      ↓
Runner Configuration
```

**Best Practices:**
- Never commit .env file
- Use .env.example as template
- Validate required variables
- Provide sensible defaults

### Token Management Pattern
```
Personal Access Token (PAT)
      ↓
Exchange for Registration Token
      ↓
Configure Runner
      ↓
Token Expires (1 hour)
```

**Security Notes:**
- PAT never stored in container
- Registration token is temporary
- No long-lived credentials

## Error Handling Patterns

### Graceful Shutdown
```bash
trap cleanup EXIT
# Main process
cleanup() {
    # Deregister runner
    # Clean resources
}
```

**Ensures:**
- Runner deregistration
- Resource cleanup
- No orphaned registrations

### Failure Recovery
```
Container Fails
      ↓
Docker Restart Policy
      ↓
New Container Created
      ↓
Fresh Registration
```

**Characteristics:**
- Automatic recovery
- No manual intervention
- Clean state on restart

## Integration Patterns

### GitHub Integration
```
GitHub Repository/Org
      ↓
Settings > Actions > Runners
      ↓
Self-Hosted Runner Pool
      ↓
Job Distribution
```

**Workflow Usage:**
```yaml
jobs:
  build:
    runs-on: self-hosted
    # OR with labels
    runs-on: [self-hosted, linux, x64, ephemeral]
```

### CI/CD Pipeline Pattern
```
Code Push → GitHub → Runner Selection → Job Execution → Cleanup
```

**Benefits:**
- Seamless integration
- No workflow changes needed
- Transparent to developers

---

These patterns ensure the GitHub Actions self-hosted runner system is secure, scalable, and maintainable while providing a simple operational model.