# DICTIONARY — HUSTLEXP SEMANTIC DEFINITIONS

**STATUS: AUTHORITATIVE**
**PURPOSE: Ground AI in exact meanings — no interpretation, no drift**

---

## WHY THIS EXISTS

AI tools interpret words loosely. "Primary" could mean brand color, main screen, or first priority.

This document defines EXACTLY what terms mean in this project.

**If a word is not defined here, ask before assuming.**

---

## BRAND & IDENTITY

### Brand Colors
```
BRAND_BLACK:   #0B0B0F     The near-black premium background
BRAND_PURPLE:  #5B2DFF     The electric purple accent (primary)
NOT GREEN.     Green is SUCCESS-ONLY.
```

### Color Semantic Categories

| Term | Meaning | Hex Values |
|------|---------|------------|
| **Brand** | Identity colors (black + purple) | #0B0B0F, #5B2DFF |
| **Success** | Positive outcome AFTER it happens | #34C759, #1FAD7E |
| **Error** | Something failed | #FF3B30 |
| **Warning** | Caution required | #FF9500 |
| **Info** | Neutral information | #007AFF |

### Color Usage Rules

| Context | Use | NEVER Use |
|---------|-----|-----------|
| Entry screens | Black + Purple | Green |
| Onboarding | Black + Purple | Green |
| Task completed | Green | — |
| Money received | Green | — |
| Escrow released | Green | — |
| CTA buttons (entry) | Purple | Green |
| CTA buttons (success) | Green | — |

---

## PRODUCT TERMINOLOGY

### Users

| Term | Definition |
|------|------------|
| **Poster** | User who creates and funds tasks |
| **Hustler** | User who completes tasks for money |
| **User** | Generic term for any authenticated account |

### Tasks

| Term | Definition |
|------|------------|
| **Task** | A work item with payment attached |
| **Standard Task** | Posted task, hustlers browse and apply |
| **Instant Task (Live)** | Real-time broadcast to nearby hustlers |
| **Task State** | Current position in lifecycle |

### Task States (State Machine)

```
POSTED      → Task created, escrow funded, visible to hustlers
ACCEPTED    → Hustler claimed the task
EN_ROUTE    → Hustler traveling to task location
WORKING     → Hustler actively performing task
PROOF_SUBMITTED → Hustler submitted completion evidence
COMPLETED   → Poster approved, escrow releasing
REJECTED    → Poster rejected proof (returns to WORKING)
CANCELLED   → Task abandoned (escrow refunded)
DISPUTED    → Conflict escalated to platform
```

### Money

| Term | Definition |
|------|------------|
| **Escrow** | Held payment for a task |
| **FUNDED** | Money held in escrow |
| **RELEASED** | Money transferred to hustler |
| **REFUNDED** | Money returned to poster |
| **DISPUTED** | Escrow frozen pending resolution |

### Escrow States (State Machine)

```
PENDING     → Escrow record created, not yet funded
FUNDED      → Money held in escrow
HELD        → Synonym for FUNDED
RELEASED    → Money sent to hustler
REFUNDED    → Money returned to poster
DISPUTED    → Frozen pending resolution
```

---

## XP & PROGRESSION

### XP (Experience Points)

| Term | Definition |
|------|------------|
| **XP** | Non-monetary reward for task completion |
| **XP Ledger** | Append-only record of all XP changes |
| **XP Award** | Single grant of XP points |

### XP Rules
- XP is ONLY awarded when escrow state = RELEASED
- XP is NEVER modified (ledger is append-only)
- One escrow = one XP entry (INV-5)

### Trust Tiers

| Tier | Name | Risk Clearance | Numeric Value |
|------|------|----------------|---------------|
| 1 | ROOKIE | LOW | trust_tier = 1 |
| 2 | VERIFIED | MEDIUM | trust_tier = 2 |
| 3 | TRUSTED | HIGH | trust_tier = 3 |
| 4 | ELITE | CRITICAL | trust_tier = 4 |

### Trust Tier Colors

| Tier | Color | Hex |
|------|-------|-----|
| ROOKIE | Zinc Gray | #71717A |
| VERIFIED | Apple Blue | #007AFF |
| TRUSTED | Purple | #8B5CF6 |
| ELITE | Gold | #FFD700 |

---

## LIVE MODE

### Live Mode Terms

| Term | Definition |
|------|------------|
| **Live Mode** | Real-time task broadcast feature |
| **Live Session** | Time-bounded availability period |
| **Broadcast** | Push notification to nearby hustlers |
| **Geo-Bounded** | Limited by physical radius |
| **Time-Bounded** | Limited by TTL (time to live) |

### Live Mode Rules
- Requires $15 minimum (LIVE-2)
- Requires funded escrow (LIVE-1)
- Session-based, not permanent (LIVE-6)
- No AI auto-accept (LIVE-7)

---

## ARCHITECTURAL TERMS

### Layers

| Layer | Name | Role |
|-------|------|------|
| 0 | PostgreSQL | ENFORCES (triggers, constraints) |
| 1 | Backend Services | VALIDATES (business logic) |
| 2 | API Gateway | GUARDS (auth, rate limits) |
| 3 | AI Services | PROPOSES (suggestions only) |
| 4 | Frontend Logic | DERIVES (state management) |
| 5 | UI Components | DISPLAYS (rendering) |
| 6 | Native Shell | HOSTS (iOS/Android) |

### AI Authority Levels

| Level | Name | Meaning |
|-------|------|---------|
| A0 | Forbidden | Cannot access (money, core state) |
| A1 | Read-only | Can read but not write |
| A2 | Propose | Can suggest but not execute |
| A3 | Auto-execute | Can execute low-stakes, high-confidence |

### Invariant

| Term | Definition |
|------|------------|
| **Invariant** | Rule that MUST hold true at ALL times |
| **Mechanical enforcement** | Enforced by database trigger/constraint |
| **Kill test** | Test that FAILS if constraint removed |

---

## UI TERMINOLOGY

### Screen Types

| Type | Definition |
|------|------------|
| **Entry Screen** | First screen user sees (brand surface) |
| **Onboarding** | Account creation flow |
| **Dashboard** | Main hub after login |
| **Detail Screen** | Single item view |
| **Modal** | Overlay on top of current screen |
| **Sheet** | Bottom drawer UI |

### Layout Patterns

| Pattern | Definition |
|---------|------------|
| **Full-Canvas** | Content fills entire screen (UAP-5) |
| **Card-Based** | Content in floating cards (FORBIDDEN for entry) |
| **Glassmorphism** | Frosted glass effect |

### UAP Gates

| Gate | Meaning |
|------|---------|
| UAP-1 | Design tokens must match spec |
| UAP-2 | Animations under 300ms |
| UAP-3 | Accessibility (VoiceOver, contrast) |
| UAP-4 | Empty/error states handled |
| UAP-5 | Full-canvas composition (entry screens) |

---

## PHASE TERMINOLOGY

### Bootstrap Phase

| Term | Definition |
|------|------------|
| **Bootstrap** | Minimum viable app that builds + runs |
| **Bootstrap Passes** | App builds, launches, renders, doesn't crash |
| **Bootstrap Blocked** | Cannot proceed to next phase |

### What "Done" Means

| Context | Done Means |
|---------|------------|
| Bootstrap | Builds, launches, renders, no crash 30s |
| Screen | Matches spec pixel-perfect, passes UAP |
| Invariant | Has kill test that fails if removed |
| Feature | Not applicable (FEATURE_FREEZE active) |

---

## PER SYSTEM TERMS

| Term | Definition |
|------|------------|
| **PER** | Prevention, Enforcement, Recovery system |
| **PER Gate** | Checkpoint that must pass before proceeding |
| **HARD Gate** | Cannot be bypassed under any circumstances |
| **SOFT Gate** | Human can override with justification |
| **Omega Protocol** | Nuclear fallback when all else fails |

### PER Levels

| Level | Name | Type |
|-------|------|------|
| PER-0 | Authority & Scope | HARD |
| PER-1 | Existence Gate | HARD |
| PER-2 | Plan-First | HARD |
| PER-3 | Invariant Simulation | HARD |
| PER-4 | Test Harness | HARD |
| PER-5 | Blast Radius | SOFT |
| PER-6 | Diff Audit | SOFT |
| PER-Ω | Omega Protocol | NUCLEAR |

---

## DOCUMENT HIERARCHY

| Document | Authority |
|----------|-----------|
| `PRODUCT_SPEC.md` | What to build (feature definition) |
| `FINISHED_STATE.md` | What exists at v1.0 (scope boundary) |
| `FEATURE_FREEZE.md` | What cannot be added (scope lock) |
| `PER/INVARIANTS.md` | What must never break (constraints) |
| `COLOR_SEMANTICS_LAW.md` | What colors mean (brand law) |
| `.cursorrules` | How Cursor must behave |
| `.claude/instructions.md` | How Claude Code must behave |

---

## ANTI-PATTERNS (What Words Do NOT Mean)

### "Primary" Does NOT Mean
- ❌ "Use everywhere"
- ❌ "The only important color"
- ❌ "Background color for all screens"

### "Brand" Does NOT Mean
- ❌ "Green because we said brand = green somewhere"
- ❌ "Whatever looks nice"
- ✅ "Black + Purple per COLOR_SEMANTICS_LAW"

### "Success" Does NOT Mean
- ❌ "Good design"
- ❌ "User is happy"
- ✅ "A positive outcome has occurred (task completed, money received)"

### "Entry Screen" Does NOT Mean
- ❌ "Simple centered card"
- ❌ "Minimal text + button"
- ✅ "Full-canvas immersion with brand treatment (UAP-5)"

### "Bootstrap" Does NOT Mean
- ❌ "Make something work somehow"
- ✅ "Pass specific criteria in BOOTSTRAP.md"

---

## USAGE RULES

1. **Use terms as defined here** — do not interpret loosely
2. **If unsure about a term** — check this document first
3. **If term not defined** — ask before assuming
4. **Never conflate terms** — "primary" ≠ "brand" ≠ "success"

---

**This dictionary grounds all AI work in this repo.**
**Misusing terms produces wrong output.**
