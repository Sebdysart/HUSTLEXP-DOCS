# OWNERSHIP — HUSTLEXP v1.0

**STATUS: JURISDICTIONAL AUTHORITY**
**PURPOSE: Define who owns what and what they can do**
**ENFORCEMENT: Layer violations are system failures**

---

## THE RULE

> Every layer has a job. Every layer has boundaries.
> If you're not in your layer, you're in the wrong place.
> Cross-layer violations are architectural failures, not bugs.

---

## LAYER HIERARCHY

```
Layer 0: Database (PostgreSQL)     ← HIGHEST AUTHORITY (Enforces truth)
Layer 1: Backend Services          ← ORCHESTRATION (Coordinates operations)
Layer 2: API Gateway (tRPC)        ← TRANSPORT (Routes and validates)
Layer 3: AI Systems                ← PROPOSALS ONLY (No authority)
Layer 4: Frontend Logic            ← UX STATE ONLY (No business logic)
Layer 5: UI / Animation            ← DISPLAY ONLY (Renders state)
Layer 6: Human Override            ← BOUNDED INTERVENTION (With audit)
```

**Lower number = Higher authority.**
**Higher layers CANNOT override lower layers.**

---

## LAYER 0: DATABASE (PostgreSQL)

### Identity

| Aspect | Value |
|--------|-------|
| **Name** | PostgreSQL with constitutional schema |
| **Owner** | Claude Code (Backend) |
| **Authority** | ABSOLUTE — Single source of truth |
| **Location** | `specs/02-architecture/schema.sql` |

### Can Do

- Reject invalid state transitions (via triggers)
- Enforce all 33 invariants (INV-1 through LIVE-7)
- Maintain append-only ledgers (xp_ledger, trust_ledger, etc.)
- Be the single source of truth for ALL canonical state
- Raise HX error codes on violation

### Cannot Do

- Be bypassed by ANY layer
- Have constraints relaxed at runtime
- Trust input from any layer without validation
- Allow silent failures (every violation is logged)

### Violation Behavior

- Invalid operations raise HX error codes
- Transactions roll back atomically
- No partial state corruption is possible
- Alert fires to monitoring

---

## LAYER 1: BACKEND SERVICES

### Identity

| Aspect | Value |
|--------|-------|
| **Name** | TypeScript services (Node.js) |
| **Owner** | Claude Code (Backend) |
| **Authority** | Orchestration and business logic |
| **Location** | `backend/src/services/` |

### Can Do

- Coordinate multi-step operations
- Call Layer 0 within transactions
- Validate inputs before submission to DB
- Compute derived values (XP formulas, trust calculations)
- Interface with external services (Stripe, AI providers)
- Trigger capability profile recomputation

### Cannot Do

- Store authoritative state (that's Layer 0)
- Override DB constraints
- Make irreversible decisions without DB confirmation
- Trust client input without validation
- Bypass the proof → release → XP chain

### Services Defined

| Service | Responsibility | Invariants Touched |
|---------|----------------|-------------------|
| `TaskService` | Task lifecycle orchestration | INV-3 |
| `EscrowService` | Payment state management | INV-2, INV-4 |
| `XPService` | XP calculation and award | INV-1, INV-5 |
| `ProofService` | Proof submission and review | — |
| `DisputeService` | Dispute lifecycle | — |
| `TrustService` | Trust tier management | AUDIT-2 |
| `CapabilityProfileService` | Recompute eligibility | INV-ELIGIBILITY-* |
| `VerificationService` | Credential verification | INV-ELIGIBILITY-* |
| `StripeWebhookHandler` | Payment event processing | Idempotency |

---

## LAYER 2: API GATEWAY (tRPC)

### Identity

| Aspect | Value |
|--------|-------|
| **Name** | tRPC router |
| **Owner** | Claude Code (Backend) |
| **Authority** | Transport and access control |
| **Location** | `backend/src/routers/` |

### Can Do

- Authenticate requests
- Route to appropriate services
- Validate request schemas (Zod)
- Rate limit
- Log access

### Cannot Do

- Contain business logic
- Make decisions about state
- Transform data beyond serialization
- Cache authoritative state

### The Test

> If you're writing an `if` statement in a router that isn't about auth or validation, you're in the wrong layer.

---

## LAYER 3: AI SYSTEMS

### Identity

| Aspect | Value |
|--------|-------|
| **Name** | LLM orchestration, classifiers, vision models |
| **Owner** | Claude Code (Backend) |
| **Authority** | PROPOSALS ONLY — No execution |
| **Location** | `backend/src/ai/` |

### Can Do

- Analyze inputs and generate proposals
- Compute confidence scores
- Process evidence (photos, text)
- Suggest dispute resolutions
- Infer user intent (onboarding)
- Read context for proposals (A1 authority)

### Cannot Do

- Write to any ledger (xp_ledger, trust_ledger, badges)
- Mutate task/escrow/proof state
- Make final decisions on money
- Operate without human-reviewable audit trail
- Execute actions above confidence threshold without confirmation
- Have database write credentials

### Authority Levels

| Level | Name | Capability |
|-------|------|------------|
| **A0** | Forbidden | Cannot access (money, core state) |
| **A1** | Read-Only | Can read for context |
| **A2** | Propose | Can generate proposals for review |
| **A3** | Auto-Execute | Can execute if confidence > threshold AND stakes < limit |

### Domain Mapping

| Domain | AI Level | Rationale |
|--------|----------|-----------|
| XP ledger | A0 | Permanent economic record |
| Escrow state | A0 | Money movement |
| Trust tier changes | A0 | Affects user capabilities |
| Badge grants | A0 | Permanent achievement |
| Task state | A1 | Can read, cannot change |
| Proof analysis | A2 | Can propose accept/reject |
| Dispute resolution | A2 | Can propose, human decides |
| Onboarding inference | A3 | Low stakes, high confidence |
| Content moderation | A2 | Can flag, human reviews |

---

## LAYER 4: FRONTEND LOGIC

### Identity

| Aspect | Value |
|--------|-------|
| **Name** | React Native state management |
| **Owner** | Cursor (Frontend) |
| **Authority** | UX state only |
| **Location** | Mobile app `state/` directory |

### Can Do

- Manage navigation state
- Cache server responses FOR DISPLAY ONLY
- Track UI interaction state (forms, modals)
- Optimistically update non-critical UI (with rollback)
- Validate inputs before submission

### Cannot Do

- Compute XP, trust, or badge state
- Assume server state without confirmation
- Make decisions about money
- Store authoritative business state
- Compute eligibility

### State Machines (Display Only)

| Machine | Purpose | Authority |
|---------|---------|-----------|
| `TaskStateMachine` | Display task state transitions | Read-only mirror of DB |
| `EscrowStateMachine` | Display escrow state | Read-only mirror of DB |
| `ProofStateMachine` | Track proof submission flow | Local UX only |
| `OnboardingStateMachine` | Guide onboarding screens | Local UX only |

### The Rule

> Frontend state machines are for **display logic**, not **business logic**. They reflect server truth; they do not create it.

---

## LAYER 5: UI / ANIMATION

### Identity

| Aspect | Value |
|--------|-------|
| **Name** | React Native components, Rive animations |
| **Owner** | Cursor (Frontend) |
| **Authority** | Visual representation only |
| **Location** | Mobile app `components/`, `screens/` |

### Can Do

- Render state received from Layer 4
- Play animations based on state changes
- Respect accessibility settings
- Apply visual styling

### Cannot Do

- Compute what to display (that's Layer 4)
- Trigger state changes (only request them)
- Assume meaning from visual state
- Animate without server-confirmed state change
- Make API calls (that's Layer 4)

---

## LAYER 6: HUMAN OVERRIDE

### Identity

| Aspect | Value |
|--------|-------|
| **Name** | Admin actions, founder escalation |
| **Owner** | Admin Dashboard |
| **Authority** | Bounded manual intervention |
| **Location** | Admin dashboard, manual DB operations |

### Can Do

- Resolve edge-case disputes
- Issue manual refunds (with audit)
- Suspend/ban users (with audit)
- Override AI decisions (with audit)
- Trigger capability profile recomputation

### Cannot Do

- Delete ledger entries (append-only)
- Modify historical XP awards
- Bypass DB constraints
- Act without audit trail

### Audit Requirement

Every admin action creates an entry in `admin_actions` table:

```sql
admin_actions {
  admin_id,      -- Who
  action_type,   -- What
  target_type,   -- On what entity type
  target_id,     -- Which entity
  reason,        -- Why
  metadata,      -- Details (JSONB)
  created_at     -- When
}
```

This table is append-only (trigger: `admin_actions_no_delete`).

---

## TOOL OWNERSHIP

### Claude Code (Backend)

| Owns | Boundary |
|------|----------|
| Layer 0 | Database schema, triggers, constraints |
| Layer 1 | Backend services, business logic |
| Layer 2 | API endpoints, routing |
| Layer 3 | AI infrastructure, proposals |

**Files Claude Code May Modify:**
```
✅ specs/02-architecture/schema.sql (with approval)
✅ backend/src/services/**
✅ backend/src/routers/**
✅ backend/src/ai/**
✅ specs/04-backend/**
```

**Files Claude Code May NOT Modify:**
```
❌ specs/03-frontend/** (Cursor's domain)
❌ screens-spec/** (Cursor's domain)
❌ reference/** (scaffold code)
❌ _archive/** (dead files)
```

### Cursor (Frontend)

| Owns | Boundary |
|------|----------|
| Layer 4 | Frontend state management |
| Layer 5 | UI components, screens, animations |

**Files Cursor May Modify:**
```
✅ screens-spec/** (screen implementations)
✅ reference/components/** (component library)
✅ reference/screens/** (screen shells)
✅ specs/03-frontend/** (frontend specs)
```

**Files Cursor May NOT Modify:**
```
❌ specs/02-architecture/** (Backend's domain)
❌ specs/04-backend/** (Backend's domain)
❌ backend/** (Backend's domain)
❌ .claude/** (Backend's domain)
```

---

## CROSS-TOOL COMMUNICATION

| From | To | Method | Example |
|------|-----|--------|---------|
| Claude Code | Cursor | Shared docs | SCREEN_REGISTRY.md, props interfaces |
| Cursor | Claude Code | NEVER | Frontend asks user to relay |
| Both | User | Stop and ask | On uncertainty |

**Rule:** Tools do not communicate directly. They communicate through documentation and user mediation.

---

## LAYER VIOLATION DETECTION

### How to Know You're in the Wrong Layer

**Backend developer writing UI code:**
- You're creating a React component
- You're defining CSS/styles
- You're thinking about animations

**Frontend developer writing business logic:**
- You're computing XP or trust
- You're making eligibility decisions
- You're writing `if (user.trustTier >= ...)` outside a display context

**AI system exceeding authority:**
- You're writing to a ledger table
- You're mutating escrow/task state
- You're executing without audit

**UI component doing logic:**
- You're making an API call
- You're computing derived state
- You're making decisions based on local state

---

## VIOLATION PROTOCOL

When a layer violation is detected:

### 1. Request Rejected
The operation is rejected, not silently failed.

### 2. Error Code Returned
HX error code indicates the violation type.

### 3. Transaction Rolled Back
No partial state corruption.

### 4. Audit Log Created
Violation is recorded for review.

### 5. Alert Sent
Monitoring is notified of the violation.

---

## AUTHORITY SUMMARY

| Layer | Can Write | Can Read | Can Decide |
|-------|-----------|----------|------------|
| **0 (Database)** | ✅ Everything | ✅ Everything | ✅ Final authority |
| **1 (Services)** | Via Layer 0 | ✅ Layer 0 | Business logic |
| **2 (API)** | Via Layer 1 | ✅ Layer 1 | Auth/routing only |
| **3 (AI)** | ❌ Nothing | ✅ Context | Proposals only |
| **4 (Frontend Logic)** | Via Layer 2 | ✅ Layer 2 | UX state only |
| **5 (UI)** | ❌ Nothing | ✅ Layer 4 | Display only |
| **6 (Human)** | Via Layer 1 | ✅ Everything | With audit |

---

**Every layer has a job.**
**Stay in your lane.**
**Cross-layer violations kill projects.**
