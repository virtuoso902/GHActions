# Self-Hosted GitHub Actions Documentation

**Master Documentation Hub for Self-Hosted Runner Integration**

Your self-hosted GitHub Actions runner is ready to save costs and provide unlimited CI/CD minutes across all your repositories. This documentation provides everything you need to integrate and optimize workflows for your specific repositories.

## 📚 Documentation Index

### 🚀 Getting Started
- **[Repository Integration Guide](REPOSITORY-INTEGRATION-GUIDE.md)** - Universal guide for any repository
- **[Workflow Templates](WORKFLOW-TEMPLATES.md)** - Ready-to-use templates for common scenarios
- **[Troubleshooting](TROUBLESHOOTING.md)** - Solutions for common issues

### 🏗️ Repository-Specific Guides
- **[MCP Integration](MCP-INTEGRATION.md)** - Docker-based MCP server testing
- **[Personal Projects](PERSONAL-INTEGRATION.md)** - Development tools and experiments  
- **[Discord Bot](DISCORD-BOT-INTEGRATION.md)** - TypeScript/Bun bot CI/CD

## 💰 Cost Savings Overview

### Current GitHub Actions Limits
- **Free Plan**: 2,000 minutes/month
- **Pro Plan**: 3,000 minutes/month  
- **Team Plan**: 10,000 minutes/month
- **Overage Cost**: $0.008/minute

### Your Estimated Savings

| Repository | Monthly Usage | Monthly Savings | Annual Savings |
|------------|--------------|----------------|---------------|
| **MCP** | 2,500 minutes | $20/month | $240/year |
| **Discord Bot** | 850 minutes | $6.80/month | $81.60/year |
| **Personal** | 750 minutes | $6/month | $72/year |
| **Others** | 1,000 minutes | $8/month | $96/year |
| **Total** | **5,100 minutes** | **$40.80/month** | **$489.60/year** |

### Additional Benefits
- **Unlimited CI/CD** - No minute restrictions
- **Faster Docker builds** - Local cache and resources
- **Custom environments** - Install any tools needed
- **Real-time debugging** - Access to live processes and logs

## 🎯 Quick Migration Checklist

### For Any Repository:

1. **Update Existing Workflows**
   ```bash
   # Replace GitHub-hosted runners
   sed -i 's/runs-on: ubuntu-latest/runs-on: self-hosted/g' .github/workflows/*.yml
   ```

2. **Add Repository-Specific Workflows**
   - Copy templates from [Workflow Templates](WORKFLOW-TEMPLATES.md)
   - Customize for your project's needs
   - Test with small changes first

3. **Configure Secrets**
   - Add required environment variables
   - Update GitHub repository secrets
   - Test with non-sensitive data first

4. **Monitor and Optimize**
   - Check workflow execution times
   - Monitor resource usage
   - Optimize based on performance data

## 🔧 Common Integration Patterns

### 1. Simple CI/CD
```yaml
name: CI
on: [push, pull_request]
jobs:
  test:
    runs-on: self-hosted
    steps:
      - uses: actions/checkout@v4
      - run: # Your test commands
```

### 2. Docker-Based Projects
```yaml
name: Docker CI
on: [push, pull_request]
jobs:
  docker-build:
    runs-on: self-hosted
    steps:
      - uses: actions/checkout@v4
      - run: docker build -t myapp .
      - run: docker run --rm myapp npm test
```

### 3. Multi-Language Projects
```yaml
name: Multi-Language
on: [push, pull_request]
jobs:
  test:
    runs-on: self-hosted
    strategy:
      matrix:
        language: [nodejs, python, go]
    steps:
      - uses: actions/checkout@v4
      - run: ./scripts/test-${{ matrix.language }}.sh
```

## 📊 Performance Monitoring

### Check Runner Status
```bash
# Runner health
./scripts/status.sh

# Resource usage
docker stats

# GitHub registration
curl -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/repos/OWNER/REPO/actions/runners
```

### Optimization Tips
- **Use Docker BuildKit** for faster builds
- **Limit concurrent jobs** to prevent resource exhaustion
- **Clean up resources** in workflow cleanup steps
- **Monitor disk space** and set up automated cleanup

## 🚨 Important Security Considerations

### Self-Hosted Runner Security
- **Ephemeral containers** - Fresh environment for each job
- **No state persistence** - Containers destroyed after each job
- **Docker socket access** - Can build/run containers
- **Network isolation** - Each job runs in isolated environment

### Best Practices
- **Never commit secrets** - Use GitHub repository secrets
- **Monitor logs** - Check for sensitive data exposure
- **Regular updates** - Keep runner images updated
- **Resource limits** - Prevent resource exhaustion attacks

## 🔄 Maintenance Schedule

### Daily
- Check runner health
- Monitor disk space
- Review failed jobs

### Weekly  
- Update base images
- Clean Docker resources
- Review performance metrics

### Monthly
- Security audit
- Update documentation
- Performance optimization review

## 📞 Support and Resources

### Quick Help
- **Check troubleshooting guide** first
- **Review logs** with `docker-compose logs`
- **Test with simple workflow** to isolate issues

### Documentation Structure
```
docs/
├── README.md                     # This file - master index
├── REPOSITORY-INTEGRATION-GUIDE.md  # Universal integration guide
├── MCP-INTEGRATION.md            # MCP repository specific
├── PERSONAL-INTEGRATION.md       # Personal projects
├── DISCORD-BOT-INTEGRATION.md    # Discord bot specific
├── WORKFLOW-TEMPLATES.md         # Copy-paste templates
└── TROUBLESHOOTING.md           # Problem solving
```

### External Resources
- **GitHub Actions Docs**: https://docs.github.com/actions
- **Docker Documentation**: https://docs.docker.com  
- **Self-Hosted Runner Docs**: https://docs.github.com/actions/hosting-your-own-runners

## 🎉 Next Steps

1. **Start with one repository** - Begin with your most active project
2. **Use templates** - Copy appropriate workflow templates
3. **Test thoroughly** - Run workflows on feature branches first
4. **Monitor performance** - Track execution times and resource usage
5. **Scale gradually** - Add more repositories once comfortable

Your self-hosted runner infrastructure is ready to transform your CI/CD workflows while saving significant costs. The ephemeral, Docker-based architecture ensures security while providing the flexibility and performance you need for modern development workflows.

---

**Runner Status**: ✅ Online and ready  
**Documentation**: Complete  
**Cost Savings**: Active  
**Security**: Ephemeral containers with Docker isolation