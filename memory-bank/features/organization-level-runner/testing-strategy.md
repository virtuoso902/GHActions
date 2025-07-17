# Testing Strategy: Organization-Level Runner

**Purpose:** Comprehensive testing approach for organization-level runner implementation  
**When to use:** Testing procedures, validation steps, and quality assurance processes  
**Quick sections:** `## Test Cases & Scenarios`, `## Performance Testing`, `## Rollback Testing`  
**Size:** 🟡 Large file with section navigation

## Test Cases & Scenarios

### Pre-Implementation Testing

#### Configuration Validation Tests
```bash
# Test 1: Environment Variable Validation
./scripts/validate-config.sh

# Expected: All required variables present and valid
# Variables: GITHUB_TOKEN, GITHUB_ORGANIZATION, RUNNER_NAME
# Result: ✅ Configuration validation passed
```

#### API Access Tests
```bash
# Test 2: GitHub API Access
gh api "orgs/virtuoso902/actions/runners"

# Expected: Successful API response with runner list
# Permissions: admin:org scope required
# Result: ✅ API access confirmed
```

#### Token Permissions Tests
```bash
# Test 3: OAuth Token Validation
gh auth status | grep -E "(admin:org|repo|workflow)"

# Expected: All required scopes present
# Scopes: admin:org, repo, workflow
# Result: ✅ Token permissions validated
```

### Implementation Testing

#### Registration Tests
```bash
# Test 4: Organization Registration
source .env.organization
./scripts/start.sh

# Expected: Runner registers with organization
# Verification: Check GitHub Settings > Actions > Runners
# Result: ✅ Organization runner online
```

#### Multi-Repository Access Tests
```bash
# Test 5: Repository Access Validation
for repo in coach mcp personal ghActions; do
    gh api "repos/virtuoso902/$repo" > /dev/null && echo "✅ $repo accessible"
done

# Expected: All target repositories accessible
# Repositories: coach, mcp, personal, ghActions
# Result: ✅ All repositories accessible
```

### Functional Testing

#### Job Execution Tests
```bash
# Test 6: Single Repository Job
# Trigger workflow in virtuoso902/ghActions
gh workflow run "Test Self-Hosted Runner" --repo virtuoso902/ghActions

# Expected: Job runs successfully on organization runner
# Verification: Check workflow run logs
# Result: ✅ Job executed successfully
```

#### Concurrent Job Tests
```bash
# Test 7: Multiple Repository Jobs
# Trigger workflows in multiple repositories simultaneously
gh workflow run "test-workflow" --repo virtuoso902/mcp &
gh workflow run "test-workflow" --repo virtuoso902/personal &
gh workflow run "test-workflow" --repo virtuoso902/ghActions &

# Expected: Jobs queue and execute in order
# Verification: Check job execution sequence
# Result: ✅ Jobs executed in proper sequence
```

#### Job Isolation Tests
```bash
# Test 8: Security Isolation
# Create test files in different repository workflows
# Verify no cross-contamination between jobs

# Expected: Each job starts with clean environment
# Verification: No artifacts from previous jobs
# Result: ✅ Job isolation maintained
```

## Performance Testing

### Startup Time Tests
```bash
# Test 9: Runner Startup Performance
time ./scripts/start.sh

# Expected: Startup time <60 seconds
# Measurement: Time from start to "Runner online"
# Baseline: Repository-level startup time
# Result: ✅ Startup time within acceptable range
```

### Job Execution Performance
```bash
# Test 10: Job Execution Speed
# Run identical workflow on repository vs organization runner
# Measure execution time difference

# Expected: <10% performance difference
# Measurement: Total workflow execution time
# Comparison: Repository-level vs organization-level
# Result: ✅ Performance maintained
```

### Resource Usage Tests
```bash
# Test 11: Resource Consumption
docker stats ghactions-runner-org --no-stream

# Expected: Memory usage <1GB, CPU <50%
# Measurement: Container resource consumption
# Duration: During job execution
# Result: ✅ Resource usage within limits
```

### Concurrent Load Tests
```bash
# Test 12: Multiple Job Handling
# Queue 5 jobs simultaneously across different repositories
# Measure queue time and execution performance

# Expected: Jobs execute in order without failures
# Measurement: Queue time, execution time, failure rate
# Load: 5 concurrent jobs from different repositories
# Result: ✅ Handles concurrent load effectively
```

## Security Testing

### Access Control Tests
```bash
# Test 13: Runner Group Access
# Verify only authorized repositories can use the runner
# Test with unauthorized repository

# Expected: Only whitelisted repositories can access
# Verification: Job assignment only to authorized repos
# Security: Unauthorized access blocked
# Result: ✅ Access control working correctly
```

### Credential Isolation Tests
```bash
# Test 14: Secret Isolation
# Run jobs with different secrets in different repositories
# Verify no secret leakage between jobs

# Expected: Each job receives only its own secrets
# Verification: No cross-repository secret access
# Security: Secrets properly isolated
# Result: ✅ Credential isolation maintained
```

### Container Security Tests
```bash
# Test 15: Container Isolation
# Run potentially conflicting jobs in sequence
# Verify no state persistence between containers

# Expected: Each job gets fresh container
# Verification: No state carryover between jobs
# Security: Container isolation maintained
# Result: ✅ Container security validated
```

## Rollback Testing

### Quick Rollback Tests
```bash
# Test 16: Emergency Rollback
time ./config/rollback/rollback.sh

# Expected: Rollback completes in <5 minutes
# Measurement: Time to restore repository-level operation
# Verification: Repository runner online and functional
# Result: ✅ Quick rollback successful
```

### Complete Rollback Tests
```bash
# Test 17: Full Restoration
./config/rollback/restore-repository.sh

# Expected: All files restored to original state
# Verification: Original functionality fully restored
# Files: All modified files restored from backup
# Result: ✅ Complete restoration successful
```

### Rollback Verification Tests
```bash
# Test 18: Post-Rollback Functionality
# After rollback, verify repository-level runner works
./scripts/status.sh
gh workflow run "Test Self-Hosted Runner"

# Expected: Repository-level runner fully functional
# Verification: Jobs execute on repository runner
# Functionality: All original features working
# Result: ✅ Post-rollback functionality confirmed
```

## Edge Case Testing

### Configuration Error Tests
```bash
# Test 19: Invalid Configuration
# Test with invalid organization name
export GITHUB_ORGANIZATION="invalid-org"
./scripts/start.sh

# Expected: Clear error message and graceful failure
# Verification: Proper error handling
# Recovery: Configuration validation prevents startup
# Result: ✅ Error handling working correctly
```

### Network Failure Tests
```bash
# Test 20: Network Disconnection
# Simulate network failure during job execution
# Verify graceful handling and recovery

# Expected: Proper error handling and retry logic
# Verification: Job resumes after network recovery
# Recovery: No data loss or corruption
# Result: ✅ Network failure handled gracefully
```

### Token Expiration Tests
```bash
# Test 21: Token Expiration
# Test behavior with expired or invalid tokens
# Verify proper error messages and recovery

# Expected: Clear error messages and recovery guidance
# Verification: Proper token validation
# Recovery: Instructions for token refresh
# Result: ✅ Token expiration handled properly
```

## User Acceptance Testing

### Developer Experience Tests
```bash
# Test 22: Workflow Compatibility
# Test existing workflows without modifications
# Verify backward compatibility

# Expected: All existing workflows work unchanged
# Verification: No workflow modifications required
# Compatibility: Seamless transition for developers
# Result: ✅ Backward compatibility maintained
```

### Documentation Tests
```bash
# Test 23: Documentation Accuracy
# Follow documentation to perform common tasks
# Verify all procedures work as documented

# Expected: All documented procedures work correctly
# Verification: Step-by-step validation
# Coverage: All common use cases covered
# Result: ✅ Documentation accurate and complete
```

### Repository Integration Tests
```bash
# Test 24: New Repository Integration
# Add a new repository to the organization
# Verify it can use the runner without configuration

# Expected: New repositories automatically get access
# Verification: Workflow runs without additional setup
# Scalability: Easy addition of new repositories
# Result: ✅ Repository integration seamless
```

## Automated Testing

### Continuous Integration Tests
```yaml
# Test 25: CI Pipeline Integration
name: Organization Runner Tests
on:
  push:
    branches: [feature/organization-level-runner-implementation]
  pull_request:
    branches: [main]

jobs:
  test-organization-runner:
    runs-on: self-hosted
    steps:
      - name: Validate Configuration
        run: ./scripts/validate-config.sh
      
      - name: Test Multi-Repository Access
        run: ./scripts/test-multi-repo.sh
      
      - name: Performance Benchmark
        run: ./scripts/performance-test.sh
```

### Monitoring Tests
```bash
# Test 26: Monitoring Integration
# Verify monitoring scripts work correctly
./scripts/org-status.sh

# Expected: Clear status reporting
# Verification: Accurate runner status information
# Monitoring: Real-time status updates
# Result: ✅ Monitoring working correctly
```

## Success Criteria

### Technical Acceptance Criteria
- [ ] **Configuration Validation**: All configuration tests pass
- [ ] **API Integration**: GitHub API calls work correctly
- [ ] **Multi-Repository Support**: All target repositories can use runner
- [ ] **Job Execution**: Jobs execute successfully across all repositories
- [ ] **Performance**: No significant performance degradation
- [ ] **Security**: Job isolation and access control working
- [ ] **Rollback**: Rollback procedures tested and working

### Operational Acceptance Criteria
- [ ] **Documentation**: All procedures documented and tested
- [ ] **Monitoring**: Status monitoring and alerting working
- [ ] **Troubleshooting**: Common issues identified and resolved
- [ ] **Team Training**: Team members can operate the system

### Business Acceptance Criteria
- [ ] **Cost Reduction**: Single runner reduces infrastructure costs
- [ ] **Scalability**: New repositories can be added easily
- [ ] **Reliability**: System meets uptime requirements
- [ ] **User Experience**: Developers can use the system effectively

## Test Execution Schedule

### Phase 1: Pre-Implementation (Day 1)
- Configuration validation tests
- API access tests
- Token permission tests
- Environment setup validation

### Phase 2: Implementation (Day 2)
- Registration tests
- Multi-repository access tests
- Basic job execution tests
- Security isolation tests

### Phase 3: Integration (Day 3)
- Performance testing
- Concurrent job tests
- Load testing
- Edge case testing

### Phase 4: Acceptance (Day 4)
- User acceptance testing
- Documentation validation
- Rollback testing
- Final verification

## Quality Assurance

### Test Coverage Requirements
- **Unit Tests**: 100% of configuration validation
- **Integration Tests**: 100% of API interactions
- **End-to-End Tests**: 100% of user workflows
- **Performance Tests**: All critical performance metrics
- **Security Tests**: All security boundaries

### Test Data Management
- **Test Repositories**: Use non-production repositories for testing
- **Test Secrets**: Use test-specific secrets and tokens
- **Test Workflows**: Create dedicated test workflows
- **Test Cleanup**: Automatic cleanup of test artifacts

### Continuous Testing
- **Automated Tests**: Run on every commit
- **Regression Tests**: Daily execution of full test suite
- **Performance Tests**: Weekly performance benchmarks
- **Security Tests**: Monthly security validation