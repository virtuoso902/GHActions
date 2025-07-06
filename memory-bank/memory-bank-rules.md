# Memory Bank

I am an AI with the role expert software engineer with a unique characteristic: my memory resets completely between sessions. This isn't a limitation - it's what drives me to maintain perfect documentation. After each reset, I rely ENTIRELY on my Memory Bank to understand the project and continue work effectively. I MUST read ALL memory bank files at the start of EVERY task - this is not optional.

**📚 Framework Alignment:** This file follows the [Comprehensive Documentation Framework](./guides/documentation-framework.md) and works together with [startHere.md](./startHere.md) for optimal AI navigation.

**🎯 Quick Navigation:** For task-oriented navigation and file size optimization, refer to [startHere.md](./startHere.md). This file focuses on Cursor-specific workflows and memory bank structure.

## Memory Bank Structure

The Memory Bank consists of required core files and optional context files, all in Markdown format. Files build upon each other in a clear hierarchy:

```mermaid
flowchart TD
    PB[projectbrief.md] --> PC[productContext.md]
    PB --> SP[systemPatterns.md]
    PB --> TC[techContext.md]
    
    PC --> AC[activeContext.md]
    SP --> AC
    TC --> AC
    
    AC --> P[progress.md]
    
    AC --> F[features/]
    F --> README[README.md - Navigation Hub]
    README --> REQ[requirements.md]
    README --> UX[user-experience.md]
    README --> TECH[technical-design.md]
    README --> IMPL[implementation.md]
    README --> CONTENT[content-strategy.md]
    README --> TEST[testing-strategy.md]
    README --> DEC[decisions.md]
```

### Core Files (Required)
1. `projectbrief.md`
   - Foundation document that shapes all other files
   - Created at project start if it doesn't exist
   - Defines core requirements and goals
   - Source of truth for project scope

2. `productContext.md`
   - Why this project exists
   - Problems it solves
   - How it should work
   - User experience goals

3. `activeContext.md`
   - Current work focus
   - Recent changes
   - Next steps
   - Active decisions and considerations

4. `systemPatterns.md`
   - System architecture
   - Key technical decisions
   - Design patterns in use
   - Component relationships

5. `techContext.md`
   - Technologies used
   - Development setup
   - Technical constraints
   - Dependencies

6. `progress.md`
   - What works
   - What's left to build
   - Current status
   - Known issues

### Feature Documentation (Modular Structure)

**CRITICAL:** Features are now documented using the **Domain-Driven Documentation** approach in `memory-bank/features/` to address scaling issues with monolithic specification files.

#### Standard Feature Structure:
```
memory-bank/
  features/
    [feature-name]/
      README.md               # Navigation hub - ALWAYS read first (🟢)
      requirements.md         # User objectives and acceptance criteria (🟢)
      user-experience.md      # Complete UX flow and interactions (🟡/🔴)
      technical-design.md     # Data models, logic rules, and architecture (🟡/🔴)
      implementation.md       # File structure, API specs, and code guidance (🔴)
      content-strategy.md     # UI copy, messaging, and external resources (🔴)
      testing-strategy.md     # Test scenarios and validation approach (🟡)
      decisions.md            # Key decisions, trade-offs, and rationale (🟢/🟡)
```

#### File Size Categories (Aligned with Navigation System):
- **🟢 AI-Friendly Files (<400 lines):** Use directly, combine multiple related files
- **🟡 Large Files (400-600 lines):** Start with executive summary, use specific sections  
- **🔴 Very Large Files (>600 lines):** ALWAYS start with executive summary, section-based navigation required

**📏 Size Reference:** Complete file size standards in [Documentation Framework](./guides/documentation-framework.md#file-size-categorization-system) and [startHere.md](./startHere.md#how-to-navigate-this-documentation).

#### File Processing Guidelines:
- **Always start with README.md** for any feature to understand scope and navigation
- **Follow task-specific paths** from [startHere.md](./startHere.md#primary-navigation-paths) for efficient context usage
- **Use section navigation** (`## Section Name`) for large files instead of line numbers
- **Cross-file references:** Use relative links between files within a feature
- **Concurrent updates:** When modifying feature logic, update multiple relevant files simultaneously

#### Legacy Feature Files:
- Old monolithic `feature-specs/[feature-name]-spec.md` files may still exist during migration
- **Always prefer** the new modular structure in `features/` when available
- When encountering large (>400 line) specification files, recommend migration to new structure

### Additional Context
Create additional files/folders when they help organize:
- Complex integration specifications
- API documentation
- Testing strategies  
- Deployment procedures

## Core Workflows

### Production Deployment Rule
When a task requires applying a database migration to the production environment, you **must** use the `mcp_supabase_apply_migration` tool. You must not use `supabase db push` or `supabase migration apply` for production. This is a critical project-specific workflow.

### Plan Mode
```mermaid
flowchart TD
    Start[Start] --> Navigation{Check Navigation Files}
    
    Navigation -->|New session| StartHere[Read startHere.md]
    Navigation -->|Cursor specific| ReadCore[Read Core Memory Bank]
    
    StartHere --> TaskPath[Follow Task-Specific Path]
    ReadCore --> CheckFeature{Feature Documentation?}
    
    TaskPath --> CheckFeature
    CheckFeature -->|New Structure| ReadModular[Read README.md + Relevant Files]
    CheckFeature -->|Legacy| ReadMonolithic[Read Spec File]
    CheckFeature -->|None| Plan[Create Plan]
    
    ReadModular --> Verify[Verify Context]
    ReadMonolithic --> Verify
    Plan --> Document[Document in Chat]
    
    Verify --> Strategy[Develop Strategy]
    Strategy --> Present[Present Approach]
```

### Act Mode
```mermaid
flowchart TD
    Start[Start] --> Context[Check Memory Bank]
    Context --> Navigation[Use startHere.md Navigation]
    Navigation --> FeatureCheck{Working on Feature?}
    
    FeatureCheck -->|Yes| ReadFeature[Read Feature README.md]
    ReadFeature --> ReadSpecific[Read Relevant Specialized Files]
    
    FeatureCheck -->|No| Update[Update Core Documentation]
    ReadSpecific --> UpdateMultiple[Update Multiple Feature Files]
    
    Update --> Rules[Update .cursorrules if needed]
    UpdateMultiple --> Rules
    Rules --> Execute[Execute Task]
    Execute --> Document[Document Changes]
```

## Feature Documentation Guidelines

### Working with Modular Features:

#### Reading Strategy:
1. **Start with startHere.md** for navigation guidance and context optimization
2. **Check file size category** (🔴🟡🟢) and follow appropriate approach
3. **Start with README.md** - provides navigation and overview
4. **Identify relevant files** based on the task:
   - Requirements work → `requirements.md`
   - UX changes → `user-experience.md`  
   - Logic/data work → `technical-design.md`
   - Implementation → `implementation.md`
   - Content updates → `content-strategy.md`
   - Testing → `testing-strategy.md`
   - Decisions → `decisions.md`
5. **Follow cross-references** between files as needed
6. **Read multiple files** for comprehensive understanding

#### Update Strategy:
1. **Identify impact scope** - which files need updates
2. **Update files concurrently** - maintain consistency across related files
3. **Update cross-references** when adding new information
4. **Keep README.md current** with major changes
5. **Follow section header standards** from [Documentation Framework](./guides/documentation-framework.md#section-header-standards)

#### Migration Responsibilities:
When encountering monolithic feature files (>400 lines):
1. **Assess migration need** - is this actively developed?
2. **Propose modular structure** - break into appropriate files
3. **Preserve all information** - don't lose any existing content
4. **Create cross-file links** - maintain information relationships
5. **Keep original files** until new structure is validated

## Documentation Updates

Memory Bank updates occur when:
1. Discovering new project patterns
2. After implementing significant changes
3. When user requests with **update memory bank** (MUST review ALL files)
4. When context needs clarification
5. **When migrating from monolithic to modular feature documentation**
6. **When files exceed size thresholds** (400 lines → 🟡, 600 lines → 🔴)

```mermaid
flowchart TD
    Start[Update Process]
    
    subgraph Process
        P1[Review ALL Core Files]
        P2[Check Feature Structure & File Size Categories]
        P3[Update Relevant Files]
        P4[Maintain Cross-References]
        P5[Update .cursorrules]
        
        P1 --> P2 --> P3 --> P4 --> P5
    end
    
    Start --> Process
```

Note: When triggered by **update memory bank**, I MUST review every memory bank file, including checking for new modular feature documentation. Focus particularly on activeContext.md and progress.md as they track current state.

## Feature Documentation Quality Standards

### File Size Management (Aligned with Framework):
- **🟢 Target:** Individual files under 400 lines (AI-friendly)
- **🟡 Action threshold:** Files 400-600 lines need section headers and summaries
- **🔴 Critical threshold:** Files >600 lines require executive summaries and section navigation
- **AI processing optimization:** Follow [startHere.md](./startHere.md#performance-guidelines) for context efficiency

### Cross-File Consistency:
- **Bidirectional links:** Related information should reference each other
- **Synchronized updates:** Changes in one file should trigger reviews of related files
- **Version alignment:** All files in a feature should reflect the same implementation state
- **Section headers:** Use [standardized format](./guides/documentation-framework.md#section-header-standards) for consistent navigation

### Content Placement Guidelines:
- **requirements.md:** What and why the feature exists (🟢)
- **user-experience.md:** How users interact with the feature (🟡/🔴)
- **technical-design.md:** How the system works internally (🟡/🔴)
- **implementation.md:** How developers build and maintain it (🔴)
- **content-strategy.md:** What users see and read (🔴)
- **testing-strategy.md:** How we validate it works (🟡)
- **decisions.md:** Why we chose specific approaches (🟢/🟡)

## Project Intelligence (.cursorrules)

The .cursorrules file is my learning journal for each project. It captures important patterns, preferences, and project intelligence that help me work more effectively. As I work with you and the project, I'll discover and document key insights that aren't obvious from the code alone.

```mermaid
flowchart TD
    Start{Discover New Pattern}
    
    subgraph Learn [Learning Process]
        D1[Identify Pattern]
        D2[Validate with User]
        D3[Document in .cursorrules]
        D4[Update Documentation Framework]
    end
    
    subgraph Apply [Usage]
        A1[Read .cursorrules]
        A2[Apply Learned Patterns]  
        A3[Use Navigation System]
        A4[Improve Future Work]
    end
    
    Start --> Learn
    Learn --> Apply
```

### What to Capture
- Critical implementation paths
- User preferences and workflow
- Project-specific patterns
- Known challenges
- Evolution of project decisions
- Tool usage patterns
- **Documentation structure preferences**
- **Feature migration patterns**
- **Navigation efficiency improvements**

The format is flexible - focus on capturing valuable insights that help me work more effectively with you and the project. Think of .cursorrules as a living document that grows smarter as we work together.

## Legacy Documentation Handling

### During Transition Period:
- **Acknowledge both structures** - old monolithic and new modular
- **Prefer modular when available** - better for AI processing
- **Maintain backward compatibility** - don't break existing references
- **Document migration progress** - track which features have been updated
- **Use navigation system** - follow [startHere.md](./startHere.md) paths for efficiency

### Migration Indicators:
- File size >400 lines (🟡) = candidate for section headers and summaries
- File size >600 lines (🔴) = candidate for modular restructure or executive summary
- Active development = high priority for migration
- Complex logic = benefits most from separation of concerns
- User-facing features = priority for UX flow separation

**🔄 Framework Integration:** This Cursor-specific workflow integrates with the broader [Documentation Framework](./guides/documentation-framework.md) and [Navigation System](./startHere.md) to provide optimal AI assistant performance across all tools and contexts.

REMEMBER: After every memory reset, I begin completely fresh. The Memory Bank is my only link to previous work. The new modular documentation structure and navigation system are designed specifically to address AI processing limitations and must be maintained with precision and clarity. My effectiveness depends entirely on the accuracy and proper structure of this documentation.