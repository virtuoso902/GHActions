# Decisions: Organization-Level Runner

**Purpose:** Record key architectural decisions and rationale for organization-level runner implementation  
**When to use:** Understanding design choices, trade-offs, and decision history  
**Quick sections:** `## Architecture Decisions`, `## Security Decisions`, `## Implementation Decisions`  
**Size:** 🟢 AI-friendly

## Architecture Decisions

### Decision 1: Organization-Level vs Repository-Level Runner
**Date:** 2025-07-17  
**Status:** Approved  
**Decision:** Implement organization-level runner instead of multiple repository-level runners

**Context:**
- Current repository-level runner can only serve one repository at a time
- Need to support multiple repositories: coach, mcp, personal, ghActions
- Research showed organization-level runners are GitHub's 2024 best practice

**Options Considered:**
1. **Organization-Level Runner** (Selected)
   - Single runner serves all repositories
   - Centralized management
   - Cost efficient

2. **Multiple Repository Runners**
   - Dedicated runner per repository
   - Higher resource usage
   - More complex management

3. **Dynamic Repository Switching**
   - Manual switching between repositories
   - Operational overhead
   - Potential for workflow delays

**Decision Rationale:**
- **Cost Efficiency**: Single runner reduces infrastructure overhead
- **Operational Simplicity**: Centralized management and monitoring
- **Scalability**: Easy to add new repositories
- **Best Practice**: Aligns with GitHub's 2024 recommendations

**Consequences:**
- ✅ Reduced infrastructure costs
- ✅ Simplified operations
- ✅ Better resource utilization
- ⚠️ Requires organization-level permissions
- ⚠️ More complex rollback procedures

### Decision 2: Runner Groups Strategy
**Date:** 2025-07-17  
**Status:** Approved  
**Decision:** Use single "default" runner group with all repositories

**Context:**
- GitHub runner groups provide access control
- Need to balance security with operational simplicity
- All target repositories are private

**Options Considered:**
1. **Single Default Group** (Selected)
   - All repositories in one group
   - Simple configuration
   - Suitable for private repositories

2. **Multiple Runner Groups**
   - Repository-specific groups
   - Enhanced security isolation
   - Increased complexity

3. **No Runner Groups**
   - Organization-wide access
   - Minimal configuration
   - Reduced control

**Decision Rationale:**
- **Security**: All repositories are private (low risk)
- **Simplicity**: Single group easy to manage
- **Scalability**: Easy to add new repositories
- **Future-Ready**: Can evolve to multiple groups if needed

**Consequences:**
- ✅ Simple configuration and management
- ✅ Easy repository addition
- ✅ Adequate security for private repositories
- ⚠️ Less granular access control
- ⚠️ May need revision for public repositories

## Security Decisions

### Decision 3: Ephemeral Container Strategy
**Date:** 2025-07-17  
**Status:** Approved  
**Decision:** Maintain ephemeral containers for maximum security

**Context:**
- Current implementation uses ephemeral containers
- Organization-level runner increases security considerations
- Need to ensure job isolation between repositories

**Options Considered:**
1. **Ephemeral Containers** (Selected)
   - Fresh container per job
   - Maximum security isolation
   - No state persistence

2. **Persistent Containers**
   - Reuse containers between jobs
   - Better performance
   - Potential security risks

3. **Hybrid Approach**
   - Ephemeral for sensitive jobs
   - Persistent for safe jobs
   - Complex implementation

**Decision Rationale:**
- **Security**: Maximum isolation between jobs
- **Trust**: No state leakage between repositories
- **Best Practice**: Ephemeral is recommended for multi-tenant
- **Consistency**: Maintains current security model

**Consequences:**
- ✅ Maximum security isolation
- ✅ No cross-repository contamination
- ✅ Maintains current security standards
- ⚠️ Slightly longer job startup time
- ⚠️ No caching between jobs

### Decision 4: OAuth Token Requirements
**Date:** 2025-07-17  
**Status:** Approved  
**Decision:** Require admin:org scope for organization-level runner

**Context:**
- Organization-level runner needs organization permissions
- Current token has repo scope only
- Need to balance security with functionality

**Options Considered:**
1. **admin:org Scope** (Selected)
   - Full organization access
   - Can manage runner groups
   - Required for organization runners

2. **Minimal Scopes**
   - Limited permissions
   - Reduced security risk
   - Insufficient for organization runners

3. **Repository-Specific Tokens**
   - Per-repository authentication
   - Complex token management
   - Doesn't support organization runners

**Decision Rationale:**
- **Functionality**: Required for organization-level registration
- **Management**: Enables runner group management
- **Future-Ready**: Supports advanced features
- **Security**: OAuth token is already secure

**Consequences:**
- ✅ Enables organization-level functionality
- ✅ Supports advanced runner management
- ✅ Future-ready for enhancements
- ⚠️ Requires token scope update
- ⚠️ Higher privilege level

## Implementation Decisions

### Decision 5: Backward Compatibility Strategy
**Date:** 2025-07-17  
**Status:** Approved  
**Decision:** Maintain backward compatibility with repository-level configuration

**Context:**
- Need to support both organization and repository modes
- Existing configuration should continue to work
- Enable gradual migration

**Options Considered:**
1. **Dual Mode Support** (Selected)
   - Support both organization and repository
   - Automatic fallback logic
   - Gradual migration

2. **Organization Only**
   - Clean implementation
   - No backward compatibility
   - Requires immediate migration

3. **Repository Only**
   - Maintain current approach
   - No benefits of organization-level
   - Doesn't solve the problem

**Decision Rationale:**
- **Risk Mitigation**: Fallback to repository-level if needed
- **Flexibility**: Supports different use cases
- **Migration**: Enables gradual transition
- **Compatibility**: Doesn't break existing setup

**Consequences:**
- ✅ Reduced migration risk
- ✅ Flexible deployment options
- ✅ Maintains existing functionality
- ⚠️ Slightly more complex code
- ⚠️ Additional testing required

### Decision 6: Configuration File Strategy
**Date:** 2025-07-17  
**Status:** Approved  
**Decision:** Use separate configuration files with backup strategy

**Context:**
- Need to preserve current configuration
- Enable easy rollback
- Support different deployment modes

**Options Considered:**
1. **Separate Config Files** (Selected)
   - .env.organization for new config
   - .env.repository-backup for rollback
   - Clear separation of concerns

2. **Single Config File**
   - Modify existing .env
   - Simple configuration
   - Difficult rollback

3. **Environment Variables**
   - No configuration files
   - Runtime configuration
   - Difficult to manage

**Decision Rationale:**
- **Rollback**: Easy to revert to previous configuration
- **Clarity**: Clear separation between modes
- **Safety**: Preserves working configuration
- **Testing**: Can test both configurations

**Consequences:**
- ✅ Easy rollback capability
- ✅ Clear configuration separation
- ✅ Preserves working configuration
- ⚠️ Multiple configuration files to manage
- ⚠️ Need to keep files in sync

### Decision 7: Rollback Procedure Design
**Date:** 2025-07-17  
**Status:** Approved  
**Decision:** Implement automated rollback scripts with manual override

**Context:**
- Need quick rollback capability
- Support both automated and manual rollback
- Ensure rollback procedures are tested

**Options Considered:**
1. **Automated Scripts** (Selected)
   - Quick rollback scripts
   - Manual override capability
   - Tested procedures

2. **Manual Procedures**
   - Documentation-only rollback
   - Human error prone
   - Slower recovery

3. **No Rollback**
   - Move forward only
   - High risk approach
   - Difficult to recover

**Decision Rationale:**
- **Speed**: Quick rollback in emergency
- **Reliability**: Automated procedures reduce errors
- **Flexibility**: Manual override for special cases
- **Testing**: Rollback procedures can be tested

**Consequences:**
- ✅ Quick emergency recovery
- ✅ Reduced human error
- ✅ Tested rollback procedures
- ⚠️ Additional scripts to maintain
- ⚠️ Rollback testing required

## Trade-offs and Risks

### Accepted Trade-offs
1. **Complexity vs Functionality**: More complex configuration for multi-repository support
2. **Security vs Performance**: Ephemeral containers over persistent for security
3. **Permissions vs Security**: admin:org scope for functionality
4. **Maintenance vs Safety**: Multiple config files for rollback capability

### Identified Risks
1. **Token Compromise**: admin:org scope increases impact of token compromise
   - **Mitigation**: Regular token rotation, monitoring
2. **Single Point of Failure**: One runner for all repositories
   - **Mitigation**: Quick rollback procedures, monitoring
3. **Complex Rollback**: More complex than repository-level rollback
   - **Mitigation**: Automated scripts, testing

### Future Considerations
1. **Multiple Runner Groups**: May need repository-specific groups
2. **Scaling**: May need multiple runners for load
3. **Advanced Security**: May need enhanced isolation
4. **Monitoring**: May need advanced monitoring and alerting

## Decision Impact Assessment

### Positive Impacts
- **Cost Reduction**: Single runner reduces infrastructure costs
- **Operational Efficiency**: Centralized management and monitoring
- **Scalability**: Easy addition of new repositories
- **Best Practice Alignment**: Follows GitHub 2024 recommendations

### Negative Impacts
- **Increased Complexity**: More complex configuration and rollback
- **Higher Permissions**: Requires admin:org scope
- **Single Point of Failure**: All repositories depend on one runner
- **Migration Effort**: Requires careful migration planning

### Mitigation Strategies
- **Comprehensive Testing**: Thorough testing of all scenarios
- **Rollback Procedures**: Quick and reliable rollback capability
- **Documentation**: Clear documentation for all procedures
- **Monitoring**: Enhanced monitoring and alerting

This decision log provides a complete record of all architectural decisions, enabling future maintainers to understand the rationale and context behind the implementation choices.