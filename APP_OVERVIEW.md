# APP OVERVIEW — HUSTLEXP AI UNDERSTANDING PROOF

**STATUS: AI-GENERATED STRUCTURAL TRUTH**
**PURPOSE: Prove AI understands the project before executing**
**LAST UPDATED: 2026-01-24**
**VERSION: 2.0.0**

---

## WHAT THIS DOCUMENT IS

This document proves AI has correctly understood the HustleXP project by synthesizing information from multiple source documents into a coherent whole.

If AI cannot reproduce this understanding, it cannot produce correct output.

---

## PRODUCT IDENTITY

| Field | Value | Source |
|-------|-------|--------|
| **Name** | HustleXP | PROJECT_STATE.md |
| **Type** | Local task marketplace | PRODUCT_SPEC §1 |
| **Tagline** | "Uber meets TaskRabbit" | PRODUCT_SPEC §1 |
| **Target Users** | Task posters + Hustlers | PRODUCT_SPEC §1 |

### Core Value Proposition

```
POSTERS: "Get things done. Get paid."
         Post tasks, find help in minutes.

HUSTLERS: "Earn money completing tasks nearby."
          Turn free time into income.
```

---

## TECH STACK

### Frontend (Dual Platform)

| Platform | Stack | Status |
|----------|-------|--------|
| **React Native** | React Native + Expo + TypeScript | Bootstrap Phase |
| **iOS Native** | SwiftUI (iOS 17+) | 15/38 screens synced |

### Backend

| Component | Technology | Status |
|-----------|------------|--------|
| **API** | Node.js + TypeScript + tRPC | Spec complete |
| **Database** | PostgreSQL (31 tables) | Schema defined |
| **Cache** | Redis | Spec complete |
| **Auth** | Firebase Authentication | Spec complete |
| **Payments** | Stripe Connect | Spec complete |
| **Storage** | Cloudflare R2 | Spec complete |

### AI Services

| Service | Purpose | Authority Level |
|---------|---------|-----------------|
| Photo Verification | Accept/reject proof photos | A3 (auto-execute) |
| Task Categorization | Auto-categorize tasks | A3 (auto-execute) |
| AI Completion Assist | Suggest next actions | A2 (propose only) |
| Dispute Resolution | Propose outcomes | A2 (propose only) |

---

## CURRENT BUILD STATE

```
╔═══════════════════════════════════════════════════════════════════════════════╗
║  PHASE: BOOTSTRAP                                                              ║
║  FOCUS: EntryScreen must render in iOS Simulator                               ║
║  GATE:  Build + Launch + Render + No Crash                                     ║
╚═══════════════════════════════════════════════════════════════════════════════╝
```

### Phase Progression

```
[CURRENT]  Bootstrap (Frontend)        ← You are here
           ↓
           Phase 0: Schema Verification (Backend)
           ↓
           Phase 1: Navigation Shell (Frontend)
           ↓
           Phase 1: Core Services (Backend)
           ↓
           ...continues through Phase 10
```

---

## FEATURE SCOPE (FROZEN)

**FEATURE_FREEZE.md is active. No new features can be added.**

### Included Features

| Feature | Status |
|---------|--------|
| Task posting | Defined |
| Task discovery | Defined |
| Task acceptance | Defined |
| Proof submission | Defined |
| Escrow payments | Defined |
| XP system | Defined |
| Trust tiers | Defined |
| Live mode | Defined |
| Messaging | Defined |
| Disputes | Defined |
| Onboarding | Defined |
| Notifications | Defined |

### Excluded Features

- Social features (friends, followers)
- Reviews/ratings (beyond trust score)
- Task templates
- Recurring tasks
- Team tasks
- Bidding system
- Subscription tiers

---

## SCREEN INVENTORY

### Total Screens: 38

| Category | Count | Status |
|----------|-------|--------|
| Auth | 3 | Spec complete |
| Onboarding | 6 | Spec complete |
| Hustler | 12 | Spec complete |
| Poster | 10 | Spec complete |
| Shared | 4 | Spec complete |
| Settings | 3 | Spec complete |
| **Total** | **38** | **All specified** |

### iOS SwiftUI Status

| Metric | Value |
|--------|-------|
| Screens Implemented | 15/38 |
| Source | STITCH HTML specs |
| Build Status | ✅ Compiles |
| Location | `ios-swiftui/HustleXP/` |

### Key Screens

| Screen | Purpose | Phase |
|--------|---------|-------|
| EntryScreen | First-contact, app entry | Bootstrap |
| SignIn/SignUp | Authentication | Phase 1 |
| HustlerHome | Main feed for hustlers | Phase 2 |
| PosterHome | Task management for posters | Phase 2 |
| TaskDetail | Task information | Phase 2 |
| ProofSubmission | Photo/text proof | Phase 3 |
| WalletScreen | Earnings/payments | Phase 3 |
| LiveMode | Real-time task broadcast | Phase 7 |

---

## DATABASE SUMMARY

### Table Count: 31

| Category | Tables | Key Tables |
|----------|--------|------------|
| Users | 4 | users, profiles, capability_profiles |
| Tasks | 5 | tasks, task_assignments, proofs |
| Financial | 4 | escrows, payouts, xp_ledger |
| Trust | 3 | trust_ledger, badges, achievements |
| Messaging | 2 | conversations, messages |
| Location | 2 | locations, service_areas |
| Admin | 3 | admin_actions, ai_decisions |
| Other | 8 | notifications, disputes, etc. |

### Key Relationships

```
User
 ├── Profile
 ├── CapabilityProfile (derived, never direct edit)
 ├── Tasks (as poster)
 └── TaskAssignments (as hustler)
      ├── Proofs
      └── Escrows
           └── XPLedger (on release)
```

---

## INVARIANT SUMMARY

### Total Invariants: 33

| Category | Count | Purpose |
|----------|-------|---------|
| Core Financial | 5 | Money chain protection |
| Eligibility | 8 | Trust/verification system |
| Architectural | 4 | Layer hierarchy |
| Data Flow | 4 | State flow direction |
| Audit | 5 | Append-only logging |
| Live Mode | 7 | Real-time constraints |

### The Money Chain (INV-1 through INV-5)

```
Task Created
    ↓
Escrow Funded (INV-4: amount is IMMUTABLE)
    ↓
Work Done
    ↓
Proof Submitted
    ↓
Proof Accepted (INV-3: required for COMPLETED)
    ↓
Task Completed (INV-2: required for RELEASED)
    ↓
Escrow Released (INV-1: required for XP)
    ↓
XP Awarded (INV-5: one entry per escrow)
```

**Every arrow is enforced by database triggers. Steps cannot be skipped.**

---

## AUTHORITY HIERARCHY

```
Layer 0: PostgreSQL         ← ENFORCES (triggers, constraints)
Layer 1: Backend Services   ← VALIDATES (tRPC, state machines)
Layer 2: API Gateway        ← GUARDS (rate limits, auth)
Layer 3: AI Services        ← PROPOSES (never auto-decides money)
Layer 4: Frontend Logic     ← DERIVES (Zustand, React Query)
Layer 5: UI Components      ← DISPLAYS (React Native, SwiftUI)
Layer 6: Native Shell       ← HOSTS (iOS, Android)
```

### Key Rules

1. Layer N cannot bypass Layer N-1
2. Only Layer 0 enforces invariants
3. AI (Layer 3) cannot write to Layer 0
4. UI (Layer 5) cannot call Layer 0 directly

---

## DESIGN SYSTEM

### Brand Colors

| Name | Hex | Usage |
|------|-----|-------|
| **Brand Black** | #0B0B0F | Primary background |
| **Brand Purple** | #5B2DFF | CTAs, accents, brand energy |
| **Purple Light** | #7A4DFF | Hover states, gradients |
| **Purple Glow** | #8B5CF6 | Ambient glow effects |

### Color Semantics

| Context | Color | Rule |
|---------|-------|------|
| Entry/Welcome | Purple | ALWAYS (never green) |
| Success | Green | ONLY after positive outcome |
| Error | Red | System failures, rejections |
| Warning | Orange | Attention needed |
| Info | Blue | Neutral information |

### Entry Screen Gradient

```
['#1a0a2e', '#0B0B0F', '#000000']
locations: [0, 0.3, 1]
```

---

## PER SYSTEM (v2.1)

### Prevention/Enforcement/Recovery

| Document | Purpose |
|----------|---------|
| `PER_MASTER_INDEX.md` | Root authority + HIC |
| `PROJECT_STATE.md` | Current build state |
| `DICTIONARY.md` | Semantic definitions |
| `EXECUTION_CONSTITUTION.md` | How AI operates |
| `FORBIDDEN_OUTPUTS.md` | Explicit bans |
| `DONE_DEFINITION.md` | Binary completion criteria |
| `AUTHORITY_LADDER.md` | Ambiguity resolution |
| `DESIGN_AUTHORITY.md` | Layout ownership |
| `REJECTED_APPROACHES.md` | Anti-loop protection |
| `COMPLETION_LOCK.md` | Protect finished work |
| `INVOCATION_COMMAND.md` | HIC syscall |
| `SELF_CHECK.md` | Pre-output verification |
| `INVARIANTS.md` | 33 invariants |
| `UI_ACCEPTANCE_PROTOCOL.md` | 5 UAP gates |
| `OMEGA_PROTOCOL.md` | Nuclear fallback |

### HIC (HustleXP Invocation Command)

Every Cursor response must begin with:

```
┌─────────────────────────────────────────────────────────────────┐
│ HIC v1.0 — HUSTLEXP INVOCATION RESPONSE                         │
├─────────────────────────────────────────────────────────────────┤
│ STEP 0: REPO RE-ANCHOR        ✓ Complete                        │
│ STEP 1: COLD START VERIFICATION                                 │
│ STEP 2: CLASSIFICATION        [protocol]                        │
│ STEP 3: LEGALITY              [LEGAL/ILLEGAL]                   │
│ STEP 4: PLAN                  [if implementation]               │
│ STEP 5: EXECUTION             [proceed/stop]                    │
└─────────────────────────────────────────────────────────────────┘
```

---

## UAP GATES (UI Acceptance Protocol)

| Gate | Name | Description |
|------|------|-------------|
| UAP-1 | Design Token Compliance | All colors/fonts from DESIGN_SYSTEM.md |
| UAP-2 | 300ms Polish Gate | All animations ≤300ms |
| UAP-3 | Accessibility Baseline | VoiceOver, contrast, tap targets |
| UAP-4 | Empty/Error State Audit | All states have visual treatment |
| UAP-5 | Full-Canvas Immersion | Entry screens are destinations, not popups |

---

## KEY FILE LOCATIONS

### For AI Context Loading

| Need | File |
|------|------|
| Current state | `PER/PROJECT_STATE.md` |
| What's allowed | `CURRENT_PHASE.md` |
| What to do next | `EXECUTION_QUEUE.md` |
| Color rules | `COLOR_SEMANTICS_LAW.md` |
| UI patterns | `reference/components/EntryScreen.js` |
| Design tokens | `reference/constants/colors.js` |
| Database schema | `specs/02-architecture/schema.sql` |
| API contract | `specs/04-backend/API_CONTRACT.md` |
| All invariants | `PER/INVARIANTS.md` |
| UI gates | `PER/UI_ACCEPTANCE_PROTOCOL.md` |

### Frontend Specs

| Spec | Location |
|------|----------|
| Hustler screens | `specs/03-frontend/HUSTLER_UI_SPEC.md` |
| Poster screens | `specs/03-frontend/POSTER_UI_SPEC.md` |
| Wallet screens | `specs/03-frontend/WALLET_UI_SPEC.md` |
| Messaging UI | `specs/03-frontend/MESSAGING_UI_SPEC.md` |
| Live mode UI | `specs/03-frontend/LIVE_MODE_UI_SPEC.md` |
| Design system | `specs/03-frontend/DESIGN_SYSTEM.md` |
| Screen specs | `screens-spec/` |

### Backend Specs

| Spec | Location |
|------|----------|
| Build guide | `specs/04-backend/BUILD_GUIDE.md` |
| API contract | `specs/04-backend/API_CONTRACT.md` |
| Database | `specs/02-architecture/schema.sql` |
| Matching | `specs/04-backend/MATCHING_ALGORITHMS.md` |
| AI services | `specs/04-backend/AI_SERVICE_INTERFACES.md` |
| Stripe | `specs/04-backend/STRIPE_INTEGRATION.md` |

---

## ERROR CODES

| Range | Category |
|-------|----------|
| HX101-199 | XP invariants |
| HX201-299 | Escrow invariants |
| HX301-399 | Task/Proof invariants |
| HX401-499 | Immutability invariants |
| HX501-599 | Uniqueness invariants |
| HX901-999 | Live mode invariants |

---

## VERIFICATION CHECKLIST

AI must be able to answer all of these:

```
[ ] What is HustleXP? (Local task marketplace)
[ ] What phase are we in? (Bootstrap)
[ ] What is the current focus? (EntryScreen)
[ ] What are the brand colors? (Black #0B0B0F + Purple #5B2DFF)
[ ] What color on entry screens? (Purple gradient, NEVER green)
[ ] How many screens total? (38)
[ ] How many database tables? (31)
[ ] How many invariants? (33)
[ ] What is INV-1? (XP requires RELEASED escrow)
[ ] What is UAP-5? (Full-Canvas Immersion)
[ ] What is HIC? (Mandatory syscall for Cursor)
[ ] Where is the schema? (specs/02-architecture/schema.sql)
[ ] Where are color tokens? (reference/constants/colors.js)
```

---

## THE AI PROMISE

By producing this document, AI demonstrates:

1. **Structural Understanding** — Knows repo layout
2. **Semantic Understanding** — Knows what terms mean
3. **Phase Awareness** — Knows where we are in build
4. **Constraint Awareness** — Knows what's locked
5. **Authority Awareness** — Knows the hierarchy
6. **Quality Awareness** — Knows UAP gates

---

## CROSS-REFERENCES

- `CURSOR_INSTRUCTIONS.md` — Frontend implementation guide
- `BUILD_READINESS.md` — Build order
- `screens-spec/SCREEN_REGISTRY.md` — Screen inventory
- `PER/INVARIANTS.md` — All 33 invariants
- `specs/02-architecture/schema.sql` — Database schema

---

**This document is proof that AI understands HustleXP.**
**Understanding precedes execution.**
