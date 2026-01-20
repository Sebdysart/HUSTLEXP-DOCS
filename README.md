# HustleXP — Product Execution Repository

> **The single source of truth for building HustleXP MVP**

---

## Quick Start for Cursor (Frontend)

### READ THESE FILES IN ORDER:
```
1. CURSOR_INSTRUCTIONS.md              ← MASTER GUIDE (frontend only)
2. specs/03-frontend/DESIGN_SYSTEM.md  ← Colors, typography, spacing
3. specs/03-frontend/HUSTLER_UI_SPEC.md ← Hustler screens
4. specs/03-frontend/POSTER_UI_SPEC.md  ← Poster screens
5. specs/03-frontend/ONBOARDING_FLOW.md ← Onboarding screens
```

### THE ONE RULE:
```
YOU BUILD UI SHELLS THAT DISPLAY DATA FROM PROPS.
YOU DO NOT FETCH DATA.
YOU DO NOT COMPUTE BUSINESS LOGIC.
YOU DO NOT INVENT FEATURES.
IF UNCLEAR, STOP AND ASK.
```

### Files Cursor CANNOT Touch:
```
❌ specs/01-product/**        ← Backend concern
❌ specs/02-architecture/**   ← Backend concern
❌ specs/04-backend/**        ← Backend concern
```

---

## Repository Status

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
| `CURSOR_INSTRUCTIONS.md` | **START HERE** — Frontend implementation guide |
| `.cursorrules` | Enforcement rules (auto-loaded by Cursor) |
| `specs/03-frontend/DESIGN_SYSTEM.md` | Colors, typography, spacing |
| `specs/03-frontend/HUSTLER_UI_SPEC.md` | Hustler role screens |
| `specs/03-frontend/POSTER_UI_SPEC.md` | Poster role screens |
| `specs/03-frontend/ONBOARDING_FLOW.md` | Onboarding flow |
| `specs/03-frontend/NOTIFICATION_UX.md` | Push notification templates |
| `specs/03-frontend/SOUND_DESIGN.md` | Audio feedback specs |
| `specs/03-frontend/stitch-prompts/` | Individual screen specs |
| `prompts/CURSOR_FRONTEND.md` | Copy-paste execution prompts |

### For Claude Code (Backend Only)
| File | Purpose |
|------|---------|
| `BUILD_READINESS.md` | Full-stack build order |
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
├── 🎯 IMPLEMENTATION GUIDES
│   ├── CURSOR_INSTRUCTIONS.md    ← Start here
│   ├── BUILD_READINESS.md        ← Build order
│   └── .cursorrules              ← Enforcement
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
├── 📋 CLARIFICATIONS
│   └── specs/SPEC_CLARIFICATIONS.md
│
├── 🤖 prompts/                   ← Cursor execution prompts
├── 📦 reference/                 ← Scaffold code
└── 🗄️ _archive/                  ← Historical specs
```

---

## Tech Stack

```
Frontend:
  - React Native + Expo
  - TypeScript
  - React Query
  - Zustand (UI state only)

Backend:
  - Node.js + TypeScript
  - tRPC
  - PostgreSQL
  - Redis

Auth: Firebase
Payments: Stripe Connect
Storage: Cloudflare R2
```

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

See `BUILD_READINESS.md` for detailed breakdown.

---

## Key Counts

| Artifact | Count |
|----------|-------|
| Database Tables | 31 |
| API Endpoints | 35+ |
| Frontend Screens | ~40 |
| Invariants | 5 core + 8 eligibility |

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

---

## Contact

**Owner:** Sebastian Dysart
**Project:** HustleXP v1.0

---

## Getting Started

1. Clone this repo
2. Read `CURSOR_INSTRUCTIONS.md`
3. Read `BUILD_READINESS.md`
4. Start with Phase 1 in the build order
5. Implement exactly what specs say
6. If unclear, ask — don't guess

**The specs are complete. Execute them exactly.**
