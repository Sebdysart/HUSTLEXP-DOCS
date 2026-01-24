# HustleXP Application Overview

**Purpose:** AI-generated structural truth document proving comprehensive understanding of the HustleXP project.

**Generated:** 2025-01-23
**Version:** 1.0.0
**Status:** BOOTSTRAP Phase

---

## What Is HustleXP?

HustleXP is a **task marketplace** connecting people who need work done (Posters) with people who do the work (Hustlers). Think of it as a local gig economy platform with:

- **Instant Mode:** Real-time task matching with 30-second acceptance windows
- **Trust Tiers:** 6-level progression system (T0-T5) gating task complexity
- **XP System:** Gamified progression tied to escrow completion
- **Proof System:** Photo/video verification before payment release

---

## Tech Stack

```
┌─────────────────────────────────────────────────────────────┐
│                      FRONTEND                                │
├─────────────────────────────────────────────────────────────┤
│  React Native + Expo (TypeScript)                           │
│  ├── React Query (server state)                             │
│  ├── Zustand (UI state only)                                │
│  └── 38 screens defined                                     │
├─────────────────────────────────────────────────────────────┤
│  iOS Native (SwiftUI)                                       │
│  ├── Swift Package Manager                                  │
│  ├── iOS 17+ / macOS 14+                                    │
│  └── 15 screens implemented                                 │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                      BACKEND                                 │
├─────────────────────────────────────────────────────────────┤
│  Node.js + TypeScript                                       │
│  ├── tRPC (type-safe APIs)                                  │
│  ├── PostgreSQL (31 tables)                                 │
│  ├── Redis (caching, pub/sub)                               │
│  └── Temporal (workflow orchestration)                      │
├─────────────────────────────────────────────────────────────┤
│  External Services                                          │
│  ├── Firebase Auth                                          │
│  ├── Stripe Connect (escrow)                                │
│  └── Cloudflare R2 (storage)                                │
└─────────────────────────────────────────────────────────────┘
```

---

## Current Phase: BOOTSTRAP

**What's Allowed:**
- Database schema implementation
- Core service scaffolding
- Foundation endpoints
- Type definitions

**What's Frozen (FEATURE_FREEZE.md):**
- 38 screens (no new screens)
- 31 database tables (no new tables)
- 33 invariants (no new rules)
- 5 core financial invariants (immutable)

---

## Screen Inventory

| Category | Count | Location | iOS Status |
|----------|-------|----------|------------|
| Auth | 3 | `screens/auth/` | 0/3 |
| Hustler | 9 | `screens/hustler/` | 7/9 |
| Poster | 4 | `screens/poster/` | 1/4 |
| Onboarding | 12 | `screens/onboarding/` | 0/12 |
| Settings | 3 | `screens/settings/` | 0/3 |
| Shared | 4 | `screens/shared/` | 4/4 |
| Edge | 3 | `screens/edge/` | 3/3 |
| **Total** | **38** | — | **15/38** |

---

## Database Summary (31 Tables)

### Core Entities
- `users` — Account data
- `profiles` — User profiles (hustler/poster)
- `tasks` — Task definitions
- `task_assignments` — Task-to-hustler matching
- `escrow_transactions` — Payment holds

### Trust & Progression
- `trust_tiers` — T0-T5 definitions
- `trust_history` — Trust change audit log
- `xp_ledger` — XP transactions
- `capability_profiles` — Work eligibility

### Verification
- `proof_submissions` — Photo/video proofs
- `verification_results` — AI/human verification
- `disputes` — Dispute records

### Operational
- `notifications` — Push notification queue
- `messages` — In-task messaging
- `audit_log` — System-wide audit trail

---

## Invariant Summary (33 Rules)

### Core Financial (5) — IMMUTABLE
| Code | Rule |
|------|------|
| INV-1 | XP requires RELEASED escrow |
| INV-2 | RELEASED requires COMPLETED task |
| INV-3 | COMPLETED requires ACCEPTED proof |
| INV-4 | Escrow amount immutable after funding |
| INV-5 | XP issuance idempotent per escrow |

### Eligibility (8)
- Trust tier gating
- Capability profile requirements
- Background check requirements
- Insurance verification

### Architectural (4)
- Layer boundaries
- State machine transitions
- Temporal enforcement

### Data Flow (4)
- Read/write permissions
- Audit requirements

### Audit (5)
- Logging requirements
- Retention policies

### Live Mode (7)
- Real-time matching rules
- Acceptance windows
- Timeout behaviors

---

## Authority Hierarchy

```
Layer 0: PostgreSQL Constraints    ← HIGHEST (immutable)
    │
    ▼
Layer 1: Backend State Machines
    │
    ▼
Layer 2: Temporal Enforcement
    │
    ▼
Layer 3: Stripe Integration
    │
    ▼
Layer 4: AI Proposals
    │
    ▼
Layer 5: Frontend State
    │
    ▼
Layer 6: Client Rendering          ← LOWEST
```

**The Golden Rule:** Higher layers cannot override lower layers. Database constraints are constitutional.

---

## Key File Locations

### Enforcement (AI Tools)
| File | Purpose |
|------|---------|
| `.cursorrules` | Cursor enforcement policy |
| `.claude/instructions.md` | Claude Code enforcement |
| `AI_GUARDRAILS.md` | Universal AI governance |
| `PER/PER_MASTER_INDEX.md` | Pre-Execution Requirements root |

### Execution
| File | Purpose |
|------|---------|
| `EXECUTION_QUEUE.md` | Step-by-step build order |
| `CURRENT_PHASE.md` | Phase gate (BOOTSTRAP) |
| `FEATURE_FREEZE.md` | Scope lock |
| `FINISHED_STATE.md` | What "done" means |

### Specifications
| Directory | Contents |
|-----------|----------|
| `specs/01-product/` | Product requirements |
| `specs/02-architecture/` | Database schema, AI infrastructure |
| `specs/03-frontend/` | UI specs, STITCH prompts |
| `specs/04-backend/` | API contracts, algorithms |
| `screens-spec/` | Per-screen specifications |

### Implementation
| Directory | Contents |
|-----------|----------|
| `ios-swiftui/HustleXP/` | iOS SwiftUI package (15 screens) |
| `hustlexp-app/` | React Native app (future) |

---

## PER System (Pre-Execution Requirements)

Every code change must pass through 7 gates:

| Gate | Name | Rule |
|------|------|------|
| PER-0 | Scope | Is this in FINISHED_STATE.md? |
| PER-1 | Existence | Do all referenced files exist? |
| PER-2 | Plan | Is there an approved execution plan? |
| PER-3 | Simulation | Do invariants pass simulation? |
| PER-4 | Tests | Do tests exist and pass? |
| PER-5 | Blast Radius | Is change contained? |
| PER-6 | Audit | Has human reviewed diff? |
| PER-Ω | Omega | Emergency recovery protocol |

---

## Quick Reference: What I Cannot Do

1. **Invent features** — Everything is specified
2. **Create new screens** — 38 screens are frozen
3. **Add database tables** — 31 tables are frozen
4. **Modify invariants** — 33 rules are constitutional
5. **Skip PER gates** — Enforcement is mechanical
6. **Compute business logic in frontend** — Backend only
7. **Store state in frontend** — Server-authoritative

---

## Quick Reference: What I Must Do

1. **Read specs before coding** — Implementation follows specification
2. **Use exact design tokens** — No inventing colors/fonts
3. **Follow screen contracts** — Props interface pattern
4. **Write tests** — 24 kill tests minimum
5. **Respect layer boundaries** — Frontend is Layer 5-6 only
6. **Audit all changes** — Human reviews every diff

---

## Understanding Verification

This document proves AI comprehension of:

- [x] Tech stack (React Native, SwiftUI, Node.js, PostgreSQL)
- [x] Current phase (BOOTSTRAP)
- [x] Scope freeze (38 screens, 31 tables, 33 invariants)
- [x] Authority hierarchy (7 layers)
- [x] PER system (7 gates)
- [x] iOS implementation status (15/38 screens)
- [x] Key file locations

If any of the above is incorrect, this document should be regenerated.

---

## Cross-References

- `CURSOR_INSTRUCTIONS.md` — Frontend implementation guide
- `BUILD_READINESS.md` — Build order
- `screens-spec/SCREEN_REGISTRY.md` — Screen inventory
- `PER/INVARIANTS.md` — All 33 invariants
- `specs/02-architecture/schema.sql` — Database schema
