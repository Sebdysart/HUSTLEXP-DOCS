# HustleXP — Product Execution Repository

> **The single source of truth for building HustleXP MVP**

---

## ⚠️ EXECUTION AUTHORITY NOTICE

**This README is NOT an advisory document.**

This file is governed by:
- `PER/PER_MASTER_INDEX.md` — Root authority
- `PER/EXECUTION_CONSTITUTION.md` — How AI operates
- `PER/INVOCATION_COMMAND.md` — HIC v1.1 syscall
- `PER/EXECUTION_COMMITMENT_PROTOCOL.md` — ECP (COMMIT or REFUSE)

**Any action taken without passing HIC verification is INVALID, even if described here.**

If any instruction in this README conflicts with PER, **PER always wins**.

---

## CANONICAL START SEQUENCE (NON-NEGOTIABLE)

Before ANY action:

```
1. Execute HUSTLEXP_INVOCATION()
2. Read PER/PROJECT_STATE.md
3. Read PER/EXECUTION_CONSTITUTION.md
4. Follow the NEXT_LEGAL_ACTION exactly
```

**Any other order is forbidden.**

See `PER/INVOCATION_COMMAND.md` for full HIC specification.

---

## THE ONE RULE (Frontend)

```
YOU BUILD UI SHELLS THAT DISPLAY DATA FROM PROPS.
YOU DO NOT FETCH DATA.
YOU DO NOT COMPUTE BUSINESS LOGIC.
YOU DO NOT INVENT FEATURES.
IF UNCLEAR, STOP AND ASK.
```

### UI QUALITY ENFORCEMENT

All frontend output MUST pass:
- `PER/UI_ACCEPTANCE_PROTOCOL.md` — 5 UAP gates
- `PER/DESIGN_AUTHORITY.md` — Layout ownership
- `PER/DONE_DEFINITION.md` — Binary completion criteria

**A screen that builds but fails UAP is INVALID.**

### Files Cursor CANNOT Touch:
```
❌ specs/01-product/**        ← Backend concern
❌ specs/02-architecture/**   ← Backend concern
❌ specs/04-backend/**        ← Backend concern
❌ PER/**                     ← Constitutional documents
```

---

## REPOSITORY STATUS (INFORMATIONAL ONLY)

**This section does NOT grant permission to execute.**
Only `PER/PROJECT_STATE.md` defines what is legal to build.

| Metric | Value |
|--------|-------|
| Spec Completeness | **92%** |
| Cursor Buildability | **90%** |
| Critical Blockers | **0** |
| Ready for MVP | **YES** |

---

## Key Files

### For Cursor (Frontend Only)
| File | Purpose |
|------|---------|
| `.cursorrules` | Enforcement rules (auto-loaded by Cursor) |
| `specs/03-frontend/DESIGN_SYSTEM.md` | Colors, typography, spacing |
| `specs/03-frontend/HUSTLER_UI_SPEC.md` | Hustler role screens |
| `specs/03-frontend/POSTER_UI_SPEC.md` | Poster role screens |
| `specs/03-frontend/WALLET_UI_SPEC.md` | Wallet & payment screens |
| `specs/03-frontend/LIVE_MODE_UI_SPEC.md` | Live mode UI (hustler) |
| `specs/03-frontend/MESSAGING_UI_SPEC.md` | In-task messaging |
| `specs/03-frontend/ONBOARDING_FLOW.md` | Onboarding flow |
| `specs/03-frontend/NOTIFICATION_UX.md` | Push notification templates |
| `specs/03-frontend/SOUND_DESIGN.md` | Audio feedback specs |
| `specs/03-frontend/stitch-prompts/` | Individual screen specs |

### For Claude Code (Backend Only)
| File | Purpose |
|------|---------|
| `.claude/instructions.md` | Enforcement rules |
| `specs/04-backend/BUILD_GUIDE.md` | Authority hierarchy |
| `specs/02-architecture/schema.sql` | Database schema (31 tables) |
| `specs/04-backend/API_CONTRACT.md` | All API endpoints |
| `specs/04-backend/MATCHING_ALGORITHMS.md` | Matching formulas |
| `specs/04-backend/AI_SERVICE_INTERFACES.md` | AI service I/O |
| `specs/04-backend/STRIPE_INTEGRATION.md` | Payment integration |
| `specs/SPEC_CLARIFICATIONS.md` | Conflict resolutions |

---

## Repository Structure

```
HUSTLEXP-DOCS/
│
├── 🔒 PER/                       ← CONSTITUTIONAL AUTHORITY
│   ├── PER_MASTER_INDEX.md       ← Root authority (START HERE)
│   ├── INVOCATION_COMMAND.md     ← HIC v1.1 syscall
│   ├── EXECUTION_COMMITMENT_PROTOCOL.md ← ECP
│   ├── PROJECT_STATE.md          ← Current build state
│   └── [24 more PER documents]
│
├── 📚 SPECIFICATIONS
│   └── specs/
│       ├── 01-product/           ← Product requirements
│       ├── 02-architecture/      ← Database + architecture
│       │   ├── schema.sql        ← THE database schema
│       │   └── AI_INFRASTRUCTURE.md
│       ├── 03-frontend/          ← UI specifications
│       │   ├── HUSTLER_UI_SPEC.md
│       │   ├── POSTER_UI_SPEC.md
│       │   ├── DESIGN_SYSTEM.md
│       │   └── stitch-prompts/
│       └── 04-backend/           ← Backend specifications
│           ├── BUILD_GUIDE.md    ← Authority hierarchy
│           ├── API_CONTRACT.md   ← All endpoints
│           ├── MATCHING_ALGORITHMS.md
│           ├── AI_SERVICE_INTERFACES.md
│           └── STRIPE_INTEGRATION.md
│
├── 🤖 AI INFRASTRUCTURE
│   ├── .cursorrules              ← Cursor enforcement
│   ├── .claude/instructions.md   ← Claude Code enforcement
│   ├── AI_GUARDRAILS.md          ← Universal AI governance
│   ├── APP_OVERVIEW.md           ← AI understanding proof
│   ├── CONTEXT_MANAGEMENT_GUIDE.md
│   ├── AGENT_AUTONOMY_BOUNDARIES.md
│   ├── ARCHITECTURE_DIAGRAMS.md
│   ├── MCP_INTEGRATION_GUIDE.md
│   └── ITERATION_PATTERNS.md
│
├── 📦 reference/                 ← Scaffold code
├── 🗄️ _archive/                  ← Historical specs
└── 📱 ios-swiftui/               ← iOS SwiftUI package
```

---

## Tech Stack

```
Frontend (React Native):
  - React Native + Expo
  - TypeScript
  - React Query
  - Zustand (UI state only)

Frontend (iOS Native):
  - SwiftUI (iOS 17+)
  - Swift Package Manager
  - Converted from STITCH HTML specs

Backend:
  - Node.js + TypeScript
  - tRPC
  - PostgreSQL
  - Redis

Auth: Firebase
Payments: Stripe Connect
Storage: Cloudflare R2
```

### FRONTEND SOURCE OF TRUTH (LOCKED)

```
- React Native specs (specs/03-frontend) are the CANONICAL UI source.
- SwiftUI is a DERIVED implementation converted from STITCH HTML.
- Cursor may NOT invent SwiftUI layouts.
- SwiftUI must visually and structurally match frontend specs.
- Any SwiftUI deviation requires explicit approval.

If conflict exists:
Frontend spec wins.
```

---

## iOS SwiftUI Package

Location: `ios-swiftui/HustleXP/`

Production-ready SwiftUI screens converted from STITCH HTML specifications.

| Metric | Value |
|--------|-------|
| Screens Implemented | 15/38 |
| iOS Version | 17.0+ |
| Build Status | ✅ Compiles |

```swift
// Add to your Xcode project
dependencies: [
    .package(path: "./ios-swiftui/HustleXP")
]
```

See `ios-swiftui/HustleXP/README.md` for full documentation.

**SwiftUI Implementation Rules:**
- Must match STITCH HTML spec exactly
- Use HustleColors, HustleTypography only
- Cannot invent layouts or features
- Deviations require explicit approval

---

## Build Order (Summary)

```
Phase 1: Foundation      → Database + basic endpoints
Phase 2: Task Flow       → Create, accept, proof, complete
Phase 3: Escrow          → Stripe integration
Phase 4: XP & Trust      → Gamification
Phase 5: Onboarding      → Capability claims
Phase 6: Feed & Matching → Personalized task feed
Phase 7: Live Mode       → Real-time broadcasts
Phase 8: Messaging       → In-app chat
Phase 9: Disputes        → Resolution system
Phase 10: Polish         → AI integration + optimization
```

**Current phase is defined in `PER/PROJECT_STATE.md` — not here.**

---

## Key Counts

| Artifact | Count |
|----------|-------|
| Database Tables | 31 |
| API Endpoints | 35+ |
| Frontend Screens | ~40 (15 iOS SwiftUI) |
| Invariants | 33 (5 core + 8 eligibility + 20 UI/behavior) |
| PER Documents | 27 |

---

## Critical Rules

### 1. Authority Hierarchy
```
Layer 0: PostgreSQL constraints  ← HIGHEST (immutable)
Layer 1: Backend state machines
Layer 2: Temporal enforcement
Layer 3: Stripe integration
Layer 4: AI proposals
Layer 5: Frontend state
Layer 6: Client rendering         ← LOWEST
```

### 2. Frontend Rules
```
- Screens NEVER fetch data (props only)
- Screens NEVER compute eligibility
- Screens NEVER compute XP or trust
- All business logic lives in backend
```

### 3. AI Rules
```
AI proposes → Deterministic systems decide → Database enforces
```

---

## Invariants (Enforced by Database)

| Code | Rule |
|------|------|
| INV-1 | XP requires RELEASED escrow |
| INV-2 | RELEASED requires COMPLETED task |
| INV-3 | COMPLETED requires ACCEPTED proof |
| INV-4 | Escrow amount is immutable after funding |
| INV-5 | XP issuance is idempotent per escrow |

### INVARIANT ENFORCEMENT RULE

```
Frontend UIs must NEVER imply a state
that violates backend invariants.

If invariant compliance is unclear:
STOP and ask.
```

A UI that shows "XP awarded" before escrow release is INVALID.

---

## AI Development Infrastructure

### PER v2.2 System (27 documents)

The Prevention/Enforcement/Recovery system ensures AI tools produce MAX-TIER output:

| Document | Purpose |
|----------|---------|
| `PER/PER_MASTER_INDEX.md` | Root authority + HIC v1.1 |
| `PER/INVOCATION_COMMAND.md` | HIC syscall specification |
| `PER/EXECUTION_COMMITMENT_PROTOCOL.md` | ECP (COMMIT or REFUSE) |
| `PER/PROJECT_STATE.md` | Current build state |
| `PER/INVARIANTS.md` | 33 mechanically enforced rules |
| `PER/UI_ACCEPTANCE_PROTOCOL.md` | 5 UAP gates |

### AI Infrastructure Documents

| Document | Purpose |
|----------|---------|
| `.cursorrules` | Cursor enforcement (file-specific rules) |
| `.claude/instructions.md` | Claude Code enforcement |
| `AI_GUARDRAILS.md` | Universal AI governance |
| `APP_OVERVIEW.md` | AI-generated understanding proof |
| `CONTEXT_MANAGEMENT_GUIDE.md` | Progressive context loading |
| `AGENT_AUTONOMY_BOUNDARIES.md` | Decision matrices |
| `ARCHITECTURE_DIAGRAMS.md` | Mermaid visualizations |
| `MCP_INTEGRATION_GUIDE.md` | Tool capabilities |
| `ITERATION_PATTERNS.md` | Self-review workflows |

---

## Contact

**Owner:** Sebastian Dysart
**Project:** HustleXP v1.0

---

## HIC REQUIREMENT (NON-NEGOTIABLE)

```
Any Cursor or Claude session that does NOT begin
with HUSTLEXP_INVOCATION() is INVALID.

This README may not be used as a substitute for HIC.

In IMPLEMENTATION_MODE or REFACTOR_MODE:
- Must COMMIT (produce real artifact) or REFUSE (cite blocker)
- Conceptual-only responses are INVALID
- See PER/EXECUTION_COMMITMENT_PROTOCOL.md
```

---

**This README is a routing table into the execution OS.**
**PER is the law. HIC is the syscall. ECP is the guarantee.**
**Execute exactly what specs say. No exceptions.**
