# EXECUTION_TODO.md Generation Prompt — MAX-Tier

**STATUS: EXECUTION AUTHORITY**  
**Purpose:** Generate a MASSIVELY DETAILED, END-TO-END TODO / EXECUTION CHECKLIST  
**Output:** `HUSTLEXP-DOCS/EXECUTION_TODO.md`

---

## Instructions for AI Agent

You are working inside the `HUSTLEXP-DOCS` repository. Your task is to generate a MASSIVELY DETAILED, END-TO-END TODO / EXECUTION CHECKLIST that takes HustleXP from its CURRENT STATE to a FULLY COMPLETE, PRODUCTION-READY APP.

---

## CRITICAL RULES (DO NOT VIOLATE)

### Rule 1: Repo-Anchored Tasks (Non-Negotiable)

**EVERY TODO ITEM MUST:**
- Specify the EXACT FILE PATH in `HUSTLEXP-DOCS` or `hustlexp-ai-backend` repo to work in
- Reference the SPEC SECTION NUMBER or DOCUMENT that defines the requirement
- State the GOAL in concrete, verifiable terms

**FORBIDDEN:**
- Vague tasks ("implement eligibility system")
- Tasks without file paths ("add verification logic")
- Tasks without spec references ("build onboarding")

**REQUIRED FORMAT:**
```
- [ ] **Task Name**
  - **File:** `path/to/file.ts` or `path/to/directory/`
  - **Spec:** `PRODUCT_SPEC.md` §X.X or `architecture/SPEC_LOCKED.md` §Y
  - **Goal:** Concrete, verifiable outcome
  - **Prerequisites:** List required completed tasks
```

---

### Rule 2: Strict Dependency Ordering (No Parallel Ambiguity)

**PHASES MUST:**
- Be strictly sequential (Phase N cannot start until Phase N-1 is complete)
- Have explicit completion criteria
- List all dependencies between phases

**TASK ORDERING:**
- Tasks within a phase must have explicit dependencies
- No task can be started until all prerequisites are marked `[x] COMPLETE`
- Circular dependencies are FORBIDDEN

**REQUIRED FORMAT:**
```
## Phase X: Phase Name

**Completion Criteria:** [Explicit criteria that must be met]
**Depends On:** Phase X-1 (ALL tasks complete)

### Section X.1: Subsection Name

- [ ] **Task A** (depends on: Phase X-1 completion)
  - ...
- [ ] **Task B** (depends on: Task A)
  - ...
```

---

### Rule 3: Exhaustive Coverage (No Gaps)

The TODO list MUST cover ALL of the following domains:

**Backend Services:**
- Capability Profile Service
- Verification Pipeline Services (License, Insurance, Background)
- Feed Query & Eligibility Resolver Service
- Risk Classification Service
- Task Service (with requirements enforcement)
- Trust Service (with risk clearance mapping)
- Onboarding Service (capability-driven)
- Settings Service (eligibility display)

**Database:**
- Schema migrations (if any beyond v1.2.0)
- Constraint verification
- Index optimization
- Trigger testing

**API Endpoints:**
- Feed endpoints (normal, urgent, nearby)
- Eligibility check endpoints (defense-in-depth)
- Verification endpoints (create, status, renew)
- Settings endpoints (eligibility display, verification initiation)
- Apply endpoint (with recheck)

**Frontend:**
- Settings → Work Eligibility screen (all states)
- Onboarding screens (capability-driven flow)
- Feed screens (with eligibility filtering)
- Task detail screens (with eligibility pre-check)
- Verification initiation screens (payment gating)

**Admin:**
- Verification review tools
- Capability profile audit tools
- Eligibility debugging tools
- Feed query testing tools

**Testing:**
- Invariant tests (all 8 eligibility invariants)
- Integration tests (verification → recompute → feed)
- E2E tests (onboarding → verification → feed → apply)
- Performance tests (feed query, recompute speed)

**Security:**
- Verification endpoint authorization
- Feed query authorization
- Capability profile read/write permissions
- Payment gating enforcement

**Deployment:**
- Database migration scripts
- Environment variable configuration
- Feature flag setup
- Rollout plan

**Monitoring:**
- Capability profile recompute metrics
- Feed query performance metrics
- Eligibility violation alerts
- Verification pipeline metrics

**Post-Launch:**
- User onboarding analytics
- Verification completion rates
- Feed eligibility accuracy
- Support ticket reduction metrics

---

### Rule 4: Authority Lock (Never Re-Open Decisions)

**FORBIDDEN PHRASES:**
- "decide how eligibility works"
- "define trust logic"
- "choose verification approach"
- "determine feed filtering strategy"
- "design capability profile schema"

**REASON:**
All of these decisions are LOCKED in:
- `PRODUCT_SPEC.md` §17 (Capability-Driven Eligibility System)
- `ARCHITECTURE.md` §11, §12, §13 (Authority boundaries)
- `architecture/CAPABILITY_PROFILE_SCHEMA_AND_INVARIANTS_LOCKED.md`
- `architecture/VERIFICATION_PIPELINE_LOCKED.md`
- `architecture/FEED_QUERY_AND_ELIGIBILITY_RESOLVER_LOCKED.md`

**REQUIRED PHRASES:**
- "implement §X.X from PRODUCT_SPEC.md"
- "enforce INV-ELIGIBILITY-X from schema.sql"
- "build service matching ARCHITECTURE.md §Y.Z authority boundaries"
- "create UI matching `architecture/SETTINGS_VERIFICATION_AND_ELIGIBILITY_LOCKED.md` spec"

---

### Rule 5: Mark Completed Work (No Duplication)

**ALREADY COMPLETE (Mark as `[x] COMPLETE`):**
- Database schema v1.2.0 (eligibility system tables)
- PRODUCT_SPEC.md §17 (Capability-Driven Eligibility System)
- ARCHITECTURE.md §11, §12, §13 (Authority boundaries)
- All 8 LOCKED architecture specs in `architecture/` directory
- UI stitch prompts in `ui-specs/stitch-prompts/` (all LOCKED)
- Component specs in `ui-specs/components/` (glass-card, primary-action-button, section-header)
- Design tokens in `ui-specs/tokens/` (colors, spacing, typography)
- iOS app screens (all 17 screens implemented)

**DO NOT RE-SPECIFY:**
- Schema definitions (already in `schema.sql` v1.2.0)
- Invariant definitions (already in `PRODUCT_SPEC.md` §2)
- Authority boundaries (already in `ARCHITECTURE.md` §11-13)
- UI specifications (already in `ui-specs/stitch-prompts/`)

**DO SPECIFY:**
- Service implementations that enforce the locked specs
- API endpoints that expose the locked architecture
- UI screens that render the locked specs
- Tests that verify the locked invariants

---

### Rule 6: Spec-Driven Implementation (No Invention)

**EVERY TASK MUST DERIVE FROM:**
- `PRODUCT_SPEC.md` (product behavior, user experience)
- `ARCHITECTURE.md` (authority boundaries, data flow)
- `BUILD_GUIDE.md` (implementation patterns, tooling)
- `AI_INFRASTRUCTURE.md` (AI authority levels, containment)
- `schema.sql` (database constraints, invariants)
- `architecture/*_LOCKED.md` (system architecture specs)
- `ui-specs/stitch-prompts/*.md` (UI screen specs)
- `ui-specs/components/*.md` (UI component specs)
- `ui-specs/tokens/*.json` (design tokens)

**FORBIDDEN:**
- "Implement [feature] based on best practices"
- "Add [feature] for better UX"
- "Create [component] with modern design"

**REQUIRED:**
- "Implement PRODUCT_SPEC.md §X.X requirement"
- "Enforce ARCHITECTURE.md §Y.Z authority boundary"
- "Create UI matching `ui-specs/stitch-prompts/SCREEN_NAME-LOCKED.md` spec"

---

### Rule 7: Verifiable Completion (No Ambiguity)

**EVERY TASK MUST HAVE:**
- Clear "done" criteria (what does completion look like?)
- Verification method (how do we confirm it's done?)
- Acceptance test (what test proves it works?)

**REQUIRED FORMAT:**
```
- [ ] **Task Name**
  - **File:** `path/to/file.ts`
  - **Spec:** `PRODUCT_SPEC.md` §X.X
  - **Goal:** [Concrete outcome]
  - **Done Criteria:**
    - [ ] Code implemented
    - [ ] Tests written
    - [ ] Tests passing
    - [ ] Spec compliance verified
  - **Verification:** [How to verify completion]
  - **Prerequisites:** [Required tasks]
```

---

### Rule 8: Phase Structure (Strict Sequencing)

**REQUIRED PHASES (In Order):**

1. **Phase 0: Schema & Infrastructure** (COMPLETE)
   - Database schema v1.2.0 ✅
   - Eligibility system tables ✅
   - Invariant constraints ✅

2. **Phase 1: Core Backend Services**
   - Capability Profile Service (recompute engine)
   - Verification Pipeline Services
   - Feed Query & Eligibility Resolver Service
   - Risk Classification Service

3. **Phase 2: Supporting Services**
   - Trust Service (risk clearance mapping)
   - Task Service (requirements enforcement)
   - Onboarding Service (capability-driven)

4. **Phase 3: API Layer**
   - Feed endpoints
   - Eligibility check endpoints
   - Verification endpoints
   - Settings endpoints

5. **Phase 4: Frontend Integration**
   - Settings → Work Eligibility screen
   - Onboarding flow (capability-driven)
   - Feed screens (eligibility filtering)

6. **Phase 5: Testing & Hardening**
   - Invariant tests
   - Integration tests
   - E2E tests
   - Performance tests

7. **Phase 6: Admin & Ops**
   - Admin verification tools
   - Monitoring & alerting
   - Debugging tools

8. **Phase 7: Deployment & Launch**
   - Migration scripts
   - Feature flags
   - Rollout plan
   - Post-launch monitoring

---

## Output Format Requirements

**SINGLE MARKDOWN FILE:**
- Location: `HUSTLEXP-DOCS/EXECUTION_TODO.md`
- Format: GitHub-flavored markdown with checkboxes
- Structure: Phases → Sections → Tasks → Subtasks

**HEADER STRUCTURE:**
```markdown
# HustleXP Execution TODO — Production Readiness

**Status:** IN PROGRESS  
**Last Updated:** [Date]  
**Current Phase:** [Phase Number]  
**Completion:** [X/Y tasks complete]

## Phase 0: Schema & Infrastructure ✅ COMPLETE

[All tasks marked complete]

## Phase 1: Core Backend Services

[Tasks with dependencies]

...
```

---

## Quality Checks (Before Output)

**VERIFY:**
1. ✅ Every task has file path
2. ✅ Every task has spec reference
3. ✅ Every task has explicit prerequisites
4. ✅ No tasks re-open locked decisions
5. ✅ All completed work marked `[x] COMPLETE`
6. ✅ Phases strictly sequential
7. ✅ Dependencies acyclic
8. ✅ Completion criteria explicit

---

## Final Instruction

**Generate `EXECUTION_TODO.md` NOW.**

Your output must be:
- STRICT (no vagueness)
- DRY (no duplication)
- ENGINEERING-GRADE (executable)
- REPO-ANCHORED (every task has file path)
- SPEC-DRIVEN (every task references spec)
- AUTHORITY-LOCKED (no re-opening decisions)

**NO MARKETING LANGUAGE. NO OPINIONS. NO FLUFF.**

---

**END OF PROMPT**
