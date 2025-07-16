# Project Brief: GitHub Actions Self-Hosted Runner

**Last Updated:** 2025-07-16  
**Status:** Initial Implementation  
**Size:** 🟢 AI-friendly

## Project Overview

### What We're Building
A secure, Docker-based GitHub Actions self-hosted runner system that saves GitHub Actions minutes by running workflows on local infrastructure.

### Core Problem
GitHub Actions provides limited free minutes (2,000/month for free accounts, 3,000/month for Pro). Heavy CI/CD usage quickly exhausts these limits, resulting in either workflow failures or additional costs.

### Solution
Ephemeral, containerized self-hosted runners that:
- Run GitHub Actions workflows on local infrastructure
- Provide security through ephemeral containers
- Scale horizontally as needed
- Self-manage registration and cleanup

## Requirements

### Functional Requirements
1. **Runner Registration**
   - Automatic registration with GitHub
   - Support both repository and organization level
   - Self-cleanup on shutdown

2. **Security**
   - Ephemeral containers (destroyed after each job)
   - No persistent state between runs
   - Non-root execution
   - Isolated environments

3. **Operations**
   - Simple start/stop commands
   - Health checking
   - Log access
   - Horizontal scaling

### Non-Functional Requirements
1. **Performance**
   - Startup time <30 seconds
   - Minimal resource overhead
   - Support concurrent jobs

2. **Reliability**
   - Automatic recovery from failures
   - Clean shutdown handling
   - No orphaned resources

3. **Usability**
   - Setup in <5 minutes
   - Clear documentation
   - Minimal maintenance

## Success Criteria

1. **Cost Reduction**: 50%+ savings on GitHub Actions minutes
2. **Security**: Zero security incidents from runner usage
3. **Reliability**: 99%+ job success rate (excluding user errors)
4. **Adoption**: Easy enough for solo developers to use

## Technical Decisions

### Architecture Choice: Docker-based Ephemeral
- **Why**: Best balance of security and simplicity
- **Alternative Considered**: Kubernetes/ARC (too complex for target users)
- **Trade-off**: No caching between runs for maximum security

### Security Model: Ephemeral Containers
- **Why**: Prevents state persistence and cross-job contamination
- **Alternative Considered**: Persistent runners with cleanup
- **Trade-off**: Slightly slower job starts due to fresh environment

### Scaling Approach: Docker Compose
- **Why**: Simple, familiar tool for developers
- **Alternative Considered**: Custom orchestration
- **Trade-off**: Less sophisticated than Kubernetes but much simpler

## Constraints

1. **Docker Required**: Host must have Docker installed
2. **Linux/macOS Only**: Windows requires WSL2
3. **Network Access**: Must reach GitHub API
4. **Token Security**: Requires secure token management

## Out of Scope

1. **Windows Native Support**: Use WSL2 instead
2. **Advanced Orchestration**: Keep it simple with Docker Compose
3. **Multi-Region**: Single location deployment
4. **Custom Images**: Use official GitHub runner image

## MVP Features

1. ✅ Ephemeral Docker containers
2. ✅ Automatic registration/deregistration  
3. ✅ Simple start/stop scripts
4. ✅ Environment configuration
5. ✅ Basic health checking
6. ✅ Scaling support

## Future Enhancements

1. **Monitoring**: Prometheus metrics export
2. **Caching**: Optional cache volumes
3. **Multi-Architecture**: ARM64 support
4. **Web UI**: Simple status dashboard

---

This project brief serves as the source of truth for all implementation decisions and guides the development of the GitHub Actions self-hosted runner system.