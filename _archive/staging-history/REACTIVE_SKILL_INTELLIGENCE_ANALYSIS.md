# REACTIVE SKILL INTELLIGENCE — Analysis & Integration Spec

**STATUS: ✅ IMPLEMENTED — v1 enhancements synced, v2 deferred**
**Source: "Reactive Not Creepy" external spec proposal**
**Authority: PRODUCT_SPEC, FEATURE_FREEZE, CAPABILITY_PROFILE_SCHEMA, RISK_TRUST_ENGINE**
**Implementation Date: Feb 2026**

**Synced Files:**
- `specs/02-architecture/SKILL_TAXONOMY.md` — 130+ skill catalog (CREATED)
- `specs/03-frontend/stitch-prompts/O5b-skill-cloud-screen.md` — Bubble-tap stitch prompt (CREATED)
- `specs/01-product/PRODUCT_SPEC.md` — INV-PRIVACY-1 added
- `specs/02-architecture/schema.sql` — skill_id + claimed_skills columns added
- `SCREEN_ARCHETYPES.md` — O5/O5b split documented
- `screens-spec/SCREEN_REGISTRY.md` — O5b entry added
- `specs/02-architecture/ARCHITECTURE.md` — §19.2 SKILL_TAXONOMY authority reference
- `FINISHED_STATE.md` — v2 roadmap section added
- `specs/02-architecture/subsystems/RISK_TRUST_ENGINE_LOCKED.md` — Pillar 1 self-selection evidence + classification_audit evidence schema
- `specs/02-architecture/subsystems/VERIFICATION_PIPELINE_LOCKED.md` — $1.00 verification fee pricing

---

## §1. Triage: What to Adopt, Defer, and Reject

### ✅ ADOPT into v1 (Enhances existing architecture)

| Proposal Element | Repo Alignment | Action |
|-----------------|----------------|--------|
| **Skill Cloud / Bubble-Tap UI** | Enhances O5 (Capability Intro) — currently 4 broad categories | Upgrade O5 to granular multi-select within categories |
| **100+ Skills Taxonomy** | `capability_claims` + `verified_trades` exist but no enumerated catalog | Create `SKILL_TAXONOMY.md` — canonical skill list |
| **Pro Filter (Trust-Gated Skills)** | Already exists: trust tier gates + verification pipeline | Make explicit in O5 flow: amber badge → "Level X Required" |
| **IC Reinforcement via Self-Selection** | Worker Classification Fortress (6-pillar) already exists | Document self-selection as Pillar 1 evidence in classification_audit |
| **Reactive (not Creepy) Tracking** | GPS only during active task already enforced | Codify as invariant: INV-PRIVACY-1 |

### ⏳ DEFER to v2 (FEATURE_FREEZE blocks these)

| Proposal Element | Freeze Conflict | Roadmap |
|-----------------|-----------------|---------|
| **Adjacent Skill Prompt** | "AI task suggestions" explicitly frozen | v2: Post-task skill expansion notifications |
| **Market Demand Prompt** | "Smart pricing" adjacent, frozen | v2: Local demand signals in feed |
| **Quest Terminology** | "Gamified streaks" frozen | v2: Gamification language layer |

### ❌ REJECT (Conflicts with locked architecture)

| Proposal Element | Conflict | Why |
|-----------------|----------|-----|
| **30-second "Tap-and-Go" onboarding** | ONB-1 (role inference before selection), 12-screen flow exists for legal/safety reasons | Calibration, risk profiling, and jurisdictional handshake are non-negotiable |
| **"Type Name" splash** | Onboarding §1.2: "System calibration, not a signup form" | Auth screens (A1-A3) handle identity; onboarding handles authority |
| **FlutterFlow** | React Native is locked platform | Technology mismatch |
| **Apple Pay / Google Pay for payout** | Stripe Connect is locked (STRIPE_INTEGRATION.md) | Payment rail already decided |
| **Skip insurance/background** | O8/O9 are conditional but legally required for high-risk | Cannot skip for regulated trades |

---

## §2. v1 Enhancement: Skill Taxonomy (NEW)

### 2.1 The Gap

Current state: `capability_claims` stores free-text trades ("electrician", "plumber"). No canonical enumeration exists. The Risk Classifier references ~8 categories but no granular skill list.

The proposal's insight is correct: **100+ granular skills reinforce IC status** because workers self-select what services they offer as independent businesses.

### 2.2 Taxonomy Structure

```
SKILL_TAXONOMY (3-tier hierarchy):
  Category (4 broad groups — matches O5 current UI)
    └── Subcategory (domain clusters)
        └── Skill (specific capability — what workers claim)
```

**Categories (existing O5 groups):**

| Category | Icon | Subcategories | Skills |
|----------|------|---------------|--------|
| Physical Tasks | 📦 | Moving, Cleaning, Yard Work, General Labor | ~30 skills |
| Handy Work | 🔧 | Assembly, Repair, Installation, Renovation | ~35 skills |
| Transportation | 🚗 | Delivery, Errands, Driving | ~15 skills |
| Tech & Digital | 💻 | Setup, Troubleshooting, Teaching | ~15 skills |
| Personal Services | 🏠 | Care, Pet Services, Tutoring, Events | ~20 skills |
| Professional | 📋 | Admin, Organization, Photography | ~15 skills |

**Total: ~130 skills across 6 categories**

(Note: Categories expanded from 4 to 6 to accommodate the full range. O5 UI updated to 6 cards.)

### 2.3 Risk Classification Per Skill

Each skill inherits a **base risk level** from the Risk Classifier:

```typescript
interface SkillDefinition {
  skill_id: string;          // e.g., "tv_mounting"
  display_name: string;      // "TV Mounting"
  category: string;          // "handy_work"
  subcategory: string;       // "installation"
  base_risk: 'low' | 'medium' | 'high' | 'critical';
  regulated: boolean;        // Requires license/cert
  requires_insurance: boolean;
  requires_background: boolean;
  min_trust_tier: 1 | 2 | 3 | 4 | 5;
  verification_gate: string | null;  // e.g., "electrician_license"
  adjacent_skills: string[]; // For v2 skill expansion
}
```

### 2.4 Trust Tier Gating per Skill (The "Pro Filter")

This IS the existing system, made explicit per skill:

| Risk Level | Min Trust Tier | Gate UX |
|------------|---------------|---------|
| LOW | 1 (ROOKIE) | No gate — tap to claim |
| MEDIUM | 2 (VERIFIED) | Amber badge: "Verify ID to unlock" |
| HIGH | 4 (ELITE) | Lock icon: "Trust Tier 4 Required. Complete 100+ tasks." |
| CRITICAL | 5 (MASTER) | Lock + shield: "Trust Tier 5 Required. Background check + 500 tasks." |
| REGULATED (any risk) | Depends on risk + verification | Lock + license icon: "Verify [License Type] to Unlock" |

**UI Rule:** Workers see ALL skills but gated ones show requirements, not empty states. This is the Chosen-State requirement — they know what's ahead, not what's denied.

---

## §3. v1 Enhancement: O5 Capability Intro → Skill Cloud

### 3.1 Current O5 Problem

O5 shows 4 category cards with arrows (→) leading to sub-screens. This is functional but doesn't deliver the "tap everything you can do" experience that maximizes capability claims and IC evidence.

### 3.2 Enhanced O5: Category-First, Then Skill Cloud

**Flow:**
```
O5a: Category Selection (existing card UI — pick 1+ categories)
  ↓
O5b: Skill Cloud (NEW — bubble-tap within selected categories)
  ↓
O6: Location Setup (existing)
```

### 3.3 O5b Skill Cloud Screen Spec

```
┌─────────────────────────────────────────┐
│ ←                              2 of 12  │  ← Step indicator
│                                         │
│      Tap everything you can do          │  ← typography.h2
│      More skills = more tasks           │  ← typography.bodySmall, neutral[500]
│                                         │
├─ Category tabs ─────────────────────────┤
│  [📦 Physical] [🔧 Handy] [🚗 Trans]  │  ← Scrollable pill tabs
│                                         │
├─ Skill Bubbles (wrap layout) ──────────┤
│                                         │
│  ┌──────────┐ ┌──────────┐ ┌────────┐  │
│  │ Moving   │ │ Hauling  │ │ Packing│  │  ← Unselected: outline
│  │ Help     │ │          │ │        │  │
│  └──────────┘ └──────────┘ └────────┘  │
│  ┌──────────┐ ┌──────────┐ ┌────────┐  │
│  │✓Cleaning │ │ Yard     │ │ Snow   │  │  ← Selected: filled primary
│  │          │ │ Work     │ │ Removal│  │
│  └──────────┘ └──────────┘ └────────┘  │
│  ┌──────────┐ ┌──────────┐             │
│  │ Junk     │ │🔒Electri-│             │  ← Gated: lock icon + muted
│  │ Removal  │ │  cal     │             │
│  └──────────┘ └──────────┘             │
│                                         │
│  ── Regulated ──────────────────────── │  ← Section divider
│  ┌──────────┐ ┌──────────┐             │
│  │🔒Plumbing│ │🔒HVAC    │             │  ← Amber badge
│  │License Req│ │License Req│            │
│  └──────────┘ └──────────┘             │
│                                         │
├─────────────────────────────────────────┤
│  12 skills selected                     │  ← Live counter
│                                         │
│  ┌─────────────────────────────────────┐│
│  │         Continue                     ││  ← Primary button
│  └─────────────────────────────────────┘│
│                                         │
│            Skip for now                 │  ← Link (preserved)
│                                         │
└─────────────────────────────────────────┘
```

### 3.4 Bubble Interaction Rules

| Interaction | Behavior |
|-------------|----------|
| Tap unselected bubble | Select (fill primary, add checkmark) |
| Tap selected bubble | Deselect (return to outline) |
| Tap gated bubble (trust) | Toast: "Complete X more tasks to unlock" |
| Tap gated bubble (regulated) | Bottom sheet: verification requirement + "Remind me later" |
| Long-press any bubble | Tooltip: skill description (1 line) |
| Switch category tab | Show skills for that category (state preserved across tabs) |
| Continue with 0 selected | Same as "Skip for now" |

### 3.5 Backend: Skill Claims

```typescript
// On Continue, write to capability_claims
interface SkillClaimBatch {
  user_id: string;
  claimed_skills: string[];  // Array of skill_ids
  source: 'onboarding' | 'settings' | 'post_task_prompt';
  timestamp: string;
}
```

**Table Extension (capability_claims):**
```sql
-- Add to schema.sql or migration 004
ALTER TABLE capability_claims ADD COLUMN IF NOT EXISTS
  skill_id VARCHAR(100);

-- Index for feed filtering
CREATE INDEX IF NOT EXISTS idx_capability_claims_skill
  ON capability_claims(skill_id);
```

---

## §4. v1 Enhancement: Privacy Invariant

### INV-PRIVACY-1: Reactive Tracking Only

```
INVARIANT INV-PRIVACY-1:
  GPS/location tracking activates ONLY during:
    1. Active task (ACCEPTED → COMPLETED state)
    2. EN_ROUTE navigation (worker opted in)
    3. Liveness challenge (time-bounded, explicit consent)
  
  GPS tracking NEVER activates for:
    - Background skill suggestion
    - Market demand analysis
    - Feed personalization
    - Any passive monitoring

  ENFORCEMENT: Mobile SDK location permissions are
  requested ONLY at task acceptance, not onboarding.
  
  VIOLATION: If GPS fires outside active task window,
  this is a P0 bug requiring immediate hotfix.
```

**This codifies the proposal's "Reactive not Creepy" principle as a constitutional invariant.**

---

## §5. v1 Enhancement: IC Classification Evidence

### 5.1 Self-Selection as Legal Evidence

The Worker Classification Fortress (RISK_TRUST_ENGINE Pillar 2) already enforces 6 pillars of IC status. The Skill Cloud strengthens **Pillar 1: Non-Exclusivity** and **Pillar 4: Pricing Control**.

**Enhancement to classification_audit:**

```sql
-- classification_audit.evidence JSONB should include:
{
  "pillar_1_non_exclusivity": {
    "claimed_skills_count": 15,       -- Worker chose 15 different skills
    "skills_across_categories": 3,    -- Spanning 3 categories
    "self_selected": true,            -- Worker chose, platform didn't assign
    "selection_source": "onboarding", -- Or "settings"
    "selection_timestamp": "..."
  }
}
```

**Legal significance:** When a worker self-selects from 100+ skills across multiple categories, it documents that they are offering services as an independent business — not being "assigned" work by the platform. This is direct evidence for IC classification under the economic reality test.

---

## §6. v2 Roadmap: Deferred Features

### 6.1 Adjacent Skill Prompt (v2)

**FEATURE_FREEZE status:** "AI task suggestions" is frozen for v1.

**v2 Spec (for roadmap only, NOT for implementation):**

```
TRIGGER: Worker completes task in skill X with rating ≥ 4.0
ACTION: Post-task notification (not during task)
TEMPLATE: "Nice work on [Task Title]. You've earned [XP] in [Category].
           Workers like you also do [Adjacent Skill 1] and [Adjacent Skill 2].
           Tap to add to your profile."
DEEP LINK: Settings → Capability Management → Add Skills
DATA SOURCE: adjacent_skills[] from SKILL_TAXONOMY (pre-computed, not AI)
CONSTRAINT: Max 1 suggestion per completed task. Max 3 per day.
CONSTRAINT: Never suggest regulated skills without verification path.
```

### 6.2 Market Demand Prompt (v2)

**FEATURE_FREEZE status:** "Smart pricing" adjacent, frozen for v1.

**v2 Spec (for roadmap only):**

```
TRIGGER: Worker opens app in area with supply/demand imbalance
ACTION: Feed banner (not push notification)
TEMPLATE: "High demand for [Skill] in [Area] today.
           [N] tasks waiting. Add this skill?"
DATA SOURCE: Aggregated task creation data (not individual user data)
CONSTRAINT: Only show if worker doesn't already claim this skill.
CONSTRAINT: No earnings projections ("2x more" claims require regulatory review).
CONSTRAINT: Banner dismissable, max 1 per session.
```

---

## §7. Files to Create/Modify

### NEW FILES:
1. `specs/02-architecture/SKILL_TAXONOMY.md` — Canonical 130+ skill catalog
2. `specs/03-frontend/stitch-prompts/O5b-skill-cloud-screen.md` — New stitch prompt

### MODIFIED FILES:
3. `specs/01-product/PRODUCT_SPEC.md` — Add INV-PRIVACY-1, reference SKILL_TAXONOMY
4. `specs/01-product/ONBOARDING_SPEC.md` — Reference O5b in Hustler flow
5. `specs/03-frontend/stitch-prompts/O5-capability-intro-screen.md` — Update to O5a (category picker → O5b)
6. `specs/02-architecture/schema.sql` — Add skill_id to capability_claims
7. `SCREEN_ARCHETYPES.md` — Note O5a/O5b split (still 1 screen code O5, 2 sub-screens)
8. `FINISHED_STATE.md` — Add v2 roadmap section for deferred features
9. `specs/02-architecture/subsystems/RISK_TRUST_ENGINE_LOCKED.md` — Reference skill self-selection in Pillar 1 evidence

---

**END OF ANALYSIS — Ready for implementation of §2-§5 (v1 enhancements)**
