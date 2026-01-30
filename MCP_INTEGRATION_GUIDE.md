# MCP INTEGRATION GUIDE — AI TOOL CAPABILITIES

**STATUS: OPERATIONAL**
**PURPOSE: Define MCP server configurations and guardrails for AI tool integration**
**LAST UPDATED: 2026-01-24**
**VERSION: 2.0.0**

---

## What Is MCP?

Model Context Protocol (MCP) allows AI tools to connect to external servers that provide additional capabilities beyond basic file operations. Think of it as "plugins" for AI assistants.

---

## Current MCP Status

### Claude Code Configuration

**Location:** `.claude/settings.local.json`

```json
{
  "permissions": {
    "allow": [
      "Bash(swift build:*)",
      "Bash(npm:*)",
      "Bash(git status:*)",
      "Bash(git log:*)",
      "Bash(git diff:*)"
    ],
    "deny": [
      "Bash(rm -rf:*)",
      "Bash(git push:*)",
      "Bash(git commit:*)"
    ]
  }
}
```

### Available MCP Servers (Current)

| Server | Status | Purpose |
|--------|--------|---------|
| File System | Built-in | Read/write files |
| Bash | Built-in (restricted) | Command execution |
| Git | Built-in (read-only) | Version control |

### Planned MCP Servers (Future)

| Server | Purpose | Priority |
|--------|---------|----------|
| Figma API | Design-to-code extraction | P2 |
| Stripe Test | Payment flow testing | P3 |
| Firebase Emulator | Auth simulation | P3 |
| PostgreSQL | Direct DB queries | P4 |

---

## MCP Guardrails

### Rule 1: MCP Cannot Bypass PER Gates

```
MCP Server Request → PER-0 Check → If not in scope → REJECT
```

Even if an MCP server is capable of an action, it must pass PER gates:

- **PER-0:** Is the action in `FINISHED_STATE.md`?
- **PER-1:** Do referenced files exist?
- **PER-2:** Is there an approved plan?
- **HIC:** Has the invocation command been executed?

### Rule 2: External API Calls Require User Confirmation

```
❌ Auto-execute: mcp.figma.getDesign(fileId)
✅ Require approval: "Fetch Figma design {fileId}? [Yes/No]"
```

Any MCP call that leaves the local filesystem requires explicit user approval.

### Rule 3: No Production Data Access

```
FORBIDDEN via MCP:
- Production database connections
- Live Stripe API (test mode only)
- Production Firebase (emulator only)
- Any PII or financial data
```

### Rule 4: MCP Outputs Are Untrusted

```
MCP Response → Validate against spec → If deviation → FLAG
```

Data from MCP servers must be validated against existing specifications before use.

### Rule 5: MCP Respects Color Semantics

```
MCP design extraction → Validate against COLOR_SEMANTICS_LAW.md
Green on entry screen → REJECT even if from MCP source
```

---

## MCP Server Specifications

### File System Server (Built-in)

**Capabilities:**
- Read files: Autonomous
- Write files: Semi-Autonomous (existing files) / Approval (new files)
- Delete files: Approval Required
- Create directories: Semi-Autonomous

**Restrictions:**
- Cannot access paths outside `HUSTLEXP-DOCS/`
- Cannot modify `PER/` directory without explicit approval
- Cannot modify `.cursorrules` or `.claude/` without approval
- Cannot create screens not in `SCREEN_REGISTRY.md`

### Bash Server (Built-in, Restricted)

**Allowed Commands:**
```bash
# Build commands
swift build
npm run build
npm run test
npm run lint

# Git read commands
git status
git log
git diff
git branch

# Package management (read)
npm list
npm outdated
```

**Denied Commands:**
```bash
# Destructive
rm -rf
git clean -f
git reset --hard

# Write operations requiring approval
git commit
git push
git merge
npm install
```

### Figma Server (Planned)

**Capabilities:**
- Fetch design tokens
- Extract component specifications
- Export assets

**Guardrails:**
- Read-only access
- Rate limited (10 requests/minute)
- File ID whitelist required
- Output validated against `DESIGN_SYSTEM.md`
- Colors validated against `COLOR_SEMANTICS_LAW.md`

### Stripe Test Server (Planned)

**Capabilities:**
- Create test customers
- Simulate payment flows
- Verify webhook payloads

**Guardrails:**
- Test mode API key only (sk_test_*)
- No live transactions
- Amount limits ($100 max)
- Customer data is synthetic only

---

## MCP Integration Patterns

### Pattern 1: Design-to-Code

```
1. User: "Implement the login screen from Figma"
2. MCP: Fetch Figma file → Extract components
3. AI: Validate against DESIGN_SYSTEM.md
4. AI: Validate against COLOR_SEMANTICS_LAW.md
5. AI: Generate SwiftUI/React Native code
6. User: Review and approve
```

### Pattern 2: Database Schema Verification

```
1. User: "Verify schema matches spec"
2. MCP: Query PostgreSQL information_schema
3. AI: Compare against schema.sql
4. AI: Report discrepancies
5. User: Decide resolution
```

### Pattern 3: Payment Flow Testing

```
1. User: "Test escrow release flow"
2. MCP: Create test Stripe customer
3. MCP: Create test payment intent
4. MCP: Simulate charge and capture
5. AI: Verify webhook handling
6. AI: Report test results
```

---

## Adding New MCP Servers

### Proposal Template

```markdown
## MCP Server Proposal: {Server Name}

### Purpose
{Why is this server needed?}

### Capabilities
- {Capability 1}
- {Capability 2}

### Guardrails
- {Restriction 1}
- {Restriction 2}

### PER Compliance
- [ ] Respects PER-0 (scope check)
- [ ] Respects PER-1 (existence check)
- [ ] Respects HIC (invocation command)
- [ ] Cannot bypass FEATURE_FREEZE
- [ ] Cannot modify invariants
- [ ] Validates against COLOR_SEMANTICS_LAW.md

### Risk Assessment
- Data exposure risk: {Low/Medium/High}
- Side effect risk: {Low/Medium/High}
- Cost risk: {Low/Medium/High}
```

### Approval Process

1. Submit proposal via PR
2. Security review by owner
3. Test in isolated environment
4. Add to `.claude/mcp-config.json`
5. Document in this guide

---

## MCP Debugging

### Checking MCP Server Status

```bash
# Claude Code
claude mcp list

# Cursor (if using MCP extension)
cursor mcp status
```

### Common Issues

| Issue | Cause | Resolution |
|-------|-------|------------|
| MCP timeout | Server not responding | Check server process |
| Permission denied | Missing in allow list | Update settings.json |
| Invalid response | Schema mismatch | Validate server output |
| Rate limited | Too many requests | Implement backoff |

---

## Future MCP Roadmap

### Phase 1 (Current)
- Built-in File System
- Restricted Bash
- Git read-only

### Phase 2 (Next)
- Figma design extraction
- ESLint auto-fix integration

### Phase 3 (Future)
- Stripe test mode
- Firebase emulator
- GitHub Actions integration

### Phase 4 (Stretch)
- Visual regression testing
- Accessibility scanning
- Performance profiling

---

## Cross-References

- `AGENT_AUTONOMY_BOUNDARIES.md` — What MCP servers can do
- `PER/PER_MASTER_INDEX.md` — Gates MCP must respect
- `PER/INVOCATION_COMMAND.md` — HIC syscall
- `.claude/settings.local.json` — Current permissions
- `AI_GUARDRAILS.md` — Universal AI rules
- `COLOR_SEMANTICS_LAW.md` — Color validation rules

---

**MCP extends capabilities but cannot bypass constraints.**
**All MCP actions must pass PER gates and HIC verification.**
