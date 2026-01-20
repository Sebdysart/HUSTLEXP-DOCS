# HustleXP — Product Execution Repository

> **The single source of truth for building HustleXP MVP**

---

## Quick Start for Cursor

### READ THESE FILES IN ORDER:
```
1. CURSOR_INSTRUCTIONS.md     ← Master guide for implementation
2. BUILD_READINESS.md         ← What's ready to build + build order
3. specs/04-backend/BUILD_GUIDE.md  ← Authority hierarchy
4. specs/02-architecture/schema.sql  ← All database tables
5. specs/04-backend/API_CONTRACT.md  ← All API endpoints
```

### THE ONE RULE:
```
IMPLEMENT EXACTLY WHAT THE SPECS SAY.
DO NOT INVENT. DO NOT IMPROVE. DO NOT ASSUME.
IF UNCLEAR, STOP AND ASK.
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

### Implementation Guides
| File | Purpose |
|------|---------|
| `CURSOR_INSTRUCTIONS.md` | Step-by-step guide for Cursor |
| `BUILD_READINESS.md` | Build order + completeness assessment |
| `.cursorrules` | Enforcement rules for Cursor |

### Constitutional Specs (Must Read)
| File | Purpose |
|------|---------|
| `specs/04-backend/BUILD_GUIDE.md` | Master authority hierarchy |
| `specs/02-architecture/schema.sql` | Database schema (31 tables) |
| `specs/04-backend/API_CONTRACT.md` | All API endpoints (35+ endpoints) |
| `specs/SPEC_CLARIFICATIONS.md` | Conflict resolutions |

### Backend Implementation
| File | Purpose |
|------|---------|
| `specs/04-backend/MATCHING_ALGORITHMS.md` | Task-hustler matching formulas |
| `specs/04-backend/AI_SERVICE_INTERFACES.md` | AI service I/O types |
| `specs/04-backend/STRIPE_INTEGRATION.md` | Payment implementation |
| `specs/04-backend/STORAGE_SPEC.md` | File upload patterns |

### Frontend Implementation
| File | Purpose |
|------|---------|
| `specs/03-frontend/HUSTLER_UI_SPEC.md` | Hustler role UI |
| `specs/03-frontend/POSTER_UI_SPEC.md` | Poster role UI |
| `specs/03-frontend/DESIGN_SYSTEM.md` | Colors, typography, spacing |
| `specs/03-frontend/ONBOARDING_FLOW.md` | Onboarding screens |

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
