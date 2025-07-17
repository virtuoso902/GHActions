# Self-Hosted Runner Troubleshooting Guide

**Purpose:** Comprehensive troubleshooting guide for self-hosted GitHub Actions runner issues  
**Scope:** Common problems, solutions, and preventive measures  
**Last Updated:** 2025-07-16

## 🚨 Quick Diagnostics

### Check Runner Status
```bash
# Check if runner is running
docker-compose ps

# Check runner logs
docker-compose logs -f

# Check GitHub registration
curl -H "Authorization: token YOUR_TOKEN" \
  https://api.github.com/repos/OWNER/REPO/actions/runners
```

### Check System Resources
```bash
# Check disk space
df -h

# Check memory usage
free -h

# Check Docker status
docker system df
docker system events --since 1h
```

## 🔧 Common Issues and Solutions

### 1. Runner Not Starting

#### Symptoms
- Container exits immediately
- "Failed to get registration token" error
- Container not visible in `docker ps`

#### Diagnosis
```bash
# Check container logs
docker-compose logs runner

# Check environment variables
cat .env

# Test GitHub API access
curl -H "Authorization: token $(grep GITHUB_TOKEN .env | cut -d'=' -f2)" \
  https://api.github.com/user
```

#### Solutions

**Issue: Invalid GitHub Token**
```bash
# Verify token format
echo $GITHUB_TOKEN | wc -c  # Should be 40+ characters

# Test token permissions
curl -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/repos/OWNER/REPO
```

**Issue: Repository Not Found**
```bash
# Check repository name in .env
grep GITHUB_REPOSITORY .env

# Verify repository exists
curl -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/repos/OWNER/REPO
```

**Issue: Network Connectivity**
```bash
# Test GitHub connectivity
curl -I https://api.github.com

# Check DNS resolution
nslookup github.com

# Test from container
docker run --rm alpine ping -c 3 github.com
```

### 2. Runner Connects But Jobs Fail

#### Symptoms
- Runner shows as "online" in GitHub
- Jobs start but fail immediately
- "No space left on device" errors

#### Diagnosis
```bash
# Check disk space
df -h

# Check Docker space usage
docker system df

# Check for orphaned containers
docker ps -a

# Check for large log files
du -sh /var/lib/docker/containers/*
```

#### Solutions

**Issue: Disk Space Full**
```bash
# Clean Docker resources
docker system prune -a -f
docker volume prune -f

# Remove old containers
docker container prune -f

# Remove unused images
docker image prune -a -f
```

**Issue: Memory Exhaustion**
```bash
# Check memory usage
free -h
docker stats

# Restart runner with memory limits
# Add to docker-compose.yml:
# deploy:
#   resources:
#     limits:
#       memory: 2G
```

**Issue: Permission Problems**
```bash
# Check Docker socket permissions
ls -la /var/run/docker.sock

# Add user to docker group (if needed)
sudo usermod -aG docker $USER

# Restart Docker service
sudo systemctl restart docker
```

### 3. Jobs Timeout or Hang

#### Symptoms
- Jobs run indefinitely
- Workflows timeout after 6 hours
- Runner becomes unresponsive

#### Diagnosis
```bash
# Check running processes in container
docker exec -it $(docker-compose ps -q runner) ps aux

# Check container resource usage
docker stats

# Check for deadlocks
docker exec -it $(docker-compose ps -q runner) top
```

#### Solutions

**Issue: Infinite Loops in Workflow**
```bash
# Add timeout to job
jobs:
  test:
    timeout-minutes: 30  # Add this line
    runs-on: self-hosted
```

**Issue: Resource Contention**
```bash
# Limit concurrent jobs
docker-compose up -d --scale runner=1

# Add resource limits to workflows
jobs:
  test:
    runs-on: self-hosted
    env:
      DOCKER_BUILDKIT: 1  # Faster builds
```

**Issue: Network Timeouts**
```bash
# Add retry logic to workflows
- name: Install Dependencies
  run: |
    for i in {1..3}; do
      npm install && break
      sleep 10
    done
```

### 4. Docker-in-Docker Issues

#### Symptoms
- "Cannot connect to Docker daemon" in workflows
- Docker commands fail in jobs
- Permission denied errors

#### Diagnosis
```bash
# Check Docker socket mount
docker-compose config

# Test Docker access from container
docker exec -it $(docker-compose ps -q runner) docker ps

# Check socket permissions
ls -la /var/run/docker.sock
```

#### Solutions

**Issue: Docker Socket Not Mounted**
```yaml
# Ensure this is in docker-compose.yml
volumes:
  - /var/run/docker.sock:/var/run/docker.sock:ro
```

**Issue: Permission Denied**
```bash
# Check runner user is in docker group
docker exec -it $(docker-compose ps -q runner) groups

# Update Dockerfile if needed:
# RUN usermod -aG docker runner
```

**Issue: SELinux/AppArmor Blocking**
```bash
# Check SELinux status
sestatus

# Temporarily disable for testing
sudo setenforce 0

# Or add proper labels
# volumes:
#   - /var/run/docker.sock:/var/run/docker.sock:Z
```

### 5. Performance Issues

#### Symptoms
- Slow job execution
- High CPU/memory usage
- Build timeouts

#### Diagnosis
```bash
# Monitor system resources
htop
iotop

# Check Docker performance
docker stats --no-stream

# Profile specific jobs
time docker run --rm node:18 npm --version
```

#### Solutions

**Issue: Slow Builds**
```bash
# Enable BuildKit
export DOCKER_BUILDKIT=1

# Use build cache
docker build --cache-from myapp:latest .

# Optimize Dockerfile
# Use multi-stage builds
# Minimize layers
# Use .dockerignore
```

**Issue: Memory Pressure**
```bash
# Add swap space
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Or limit container memory
docker run --memory=1g myapp
```

**Issue: I/O Bottleneck**
```bash
# Check disk I/O
iostat -x 1

# Use SSD for Docker root
# Move Docker to faster storage
sudo service docker stop
sudo mv /var/lib/docker /fast/storage/docker
sudo ln -s /fast/storage/docker /var/lib/docker
sudo service docker start
```

## 🛠️ Maintenance Tasks

### Daily Maintenance
```bash
#!/bin/bash
# daily-maintenance.sh

echo "🧹 Daily maintenance started at $(date)"

# Clean Docker resources
docker system prune -f
docker volume prune -f

# Check disk space
DISK_USAGE=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
if [ $DISK_USAGE -gt 80 ]; then
  echo "⚠️ Disk usage high: ${DISK_USAGE}%"
  # Add cleanup actions here
fi

# Check runner health
if ! docker-compose ps | grep -q "Up"; then
  echo "❌ Runner not running, restarting..."
  docker-compose restart
fi

echo "✅ Daily maintenance completed"
```

### Weekly Maintenance
```bash
#!/bin/bash
# weekly-maintenance.sh

echo "🔧 Weekly maintenance started at $(date)"

# Update base images
docker pull ghcr.io/actions/actions-runner:latest

# Rebuild runner image
docker-compose build --no-cache

# Restart with new image
docker-compose down
docker-compose up -d

# Clean up old images
docker image prune -a -f

echo "✅ Weekly maintenance completed"
```

### Monthly Maintenance
```bash
#!/bin/bash
# monthly-maintenance.sh

echo "📊 Monthly maintenance started at $(date)"

# Generate usage report
echo "Runner usage for $(date +%B):"
docker logs $(docker-compose ps -q runner) | grep -c "Listening for Jobs"

# Check for updates
echo "Checking for updates..."
curl -s https://api.github.com/repos/actions/runner/releases/latest | \
  jq -r .tag_name

# Backup configuration
tar -czf "runner-backup-$(date +%Y%m%d).tar.gz" \
  .env docker-compose.yml scripts/

echo "✅ Monthly maintenance completed"
```

## 📊 Monitoring and Alerting

### Health Check Script
```bash
#!/bin/bash
# health-check.sh

HEALTHY=true

# Check runner container
if ! docker-compose ps | grep -q "Up"; then
  echo "❌ Runner container not running"
  HEALTHY=false
fi

# Check GitHub registration
if ! curl -s -H "Authorization: token $(grep GITHUB_TOKEN .env | cut -d'=' -f2)" \
  https://api.github.com/repos/$(grep GITHUB_REPOSITORY .env | cut -d'=' -f2)/actions/runners | \
  jq -r '.runners[].status' | grep -q "online"; then
  echo "❌ Runner not registered with GitHub"
  HEALTHY=false
fi

# Check disk space
DISK_USAGE=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
if [ $DISK_USAGE -gt 90 ]; then
  echo "❌ Disk usage critical: ${DISK_USAGE}%"
  HEALTHY=false
fi

# Check memory
MEMORY_USAGE=$(free | grep Mem | awk '{printf("%.0f", $3/$2 * 100.0)}')
if [ $MEMORY_USAGE -gt 90 ]; then
  echo "❌ Memory usage critical: ${MEMORY_USAGE}%"
  HEALTHY=false
fi

if [ "$HEALTHY" = true ]; then
  echo "✅ All health checks passed"
  exit 0
else
  echo "❌ Health check failed"
  exit 1
fi
```

### Log Monitoring
```bash
#!/bin/bash
# monitor-logs.sh

# Monitor for error patterns
tail -f /var/log/docker.log | while read line; do
  if echo "$line" | grep -q "ERROR\|FATAL\|CRITICAL"; then
    echo "🚨 Error detected: $line"
    # Add alerting mechanism here
  fi
done
```

## 🆘 Emergency Procedures

### Complete Reset
```bash
#!/bin/bash
# emergency-reset.sh

echo "🚨 Performing emergency reset..."

# Stop everything
docker-compose down

# Remove all containers and images
docker system prune -a -f
docker volume prune -f

# Reset to clean state
docker-compose build --no-cache
docker-compose up -d

echo "✅ Emergency reset completed"
```

### Backup Recovery
```bash
#!/bin/bash
# restore-backup.sh

BACKUP_FILE=${1:-"latest-backup.tar.gz"}

echo "📁 Restoring from backup: $BACKUP_FILE"

# Stop current runner
docker-compose down

# Extract backup
tar -xzf "$BACKUP_FILE"

# Restart with restored config
docker-compose up -d

echo "✅ Backup restored successfully"
```

## 📞 Getting Help

### Information to Collect
When seeking help, gather this information:

```bash
# System info
uname -a
docker --version
docker-compose --version

# Runner status
docker-compose ps
docker-compose logs --tail=50

# Resource usage
df -h
free -h
docker system df

# Configuration (sanitized)
cat .env | sed 's/token.*/token=REDACTED/'
```

### Common Support Channels
- **GitHub Actions Documentation**: https://docs.github.com/actions
- **Docker Documentation**: https://docs.docker.com
- **GitHub Community**: https://github.community
- **Stack Overflow**: Tag `github-actions` + `self-hosted-runner`

---

This troubleshooting guide covers the most common issues you'll encounter with self-hosted GitHub Actions runners. Keep this reference handy and update it as you discover new issues and solutions.