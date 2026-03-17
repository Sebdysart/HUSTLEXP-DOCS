# HustleXP AI Task Flow — Bulletproof Template System v2.1
## Design Document

> **Status:** Approved — ready for implementation plan
> **Reviewed by:** Internal + external LLM review (v1.0 → v2.0 → v2.1 iteration)
> **Date:** 2026-03-16

---

## Problem Statement

HustleXP is an IRL-only gig marketplace. The current task creation flow is generic:
- `TaskCategory` has 9 entries — everything unusual falls into `other`
- `TaskRiskClassifier` has 4 boolean rules, defaults unusual tasks to TIER_0
- `ScoperAIService` has one generic system prompt with no archetype awareness
- No illegal content detection exists — any description can be posted
- No structured completion criteria — "done" is undefined for non-commodity tasks
- Result: pricing errors, disputes, and abandoned tasks on any atypical request

---

## Architecture: 4-Layer System

### Layer 1 — Compliance Guardian (runs first, server-side only)
LLM-powered illegal content detection. Runs before template selection. iOS only surfaces results.

### Layer 2 — Poster Creation UX (template-guided form)
Category-specific guided creation replaces generic "what do you need done?" form.

### Layer 3 — ScoperAI Context Injection (template-aware pricing)
Each template injects an archetype-specific context block into ScoperAI. Deterministic flag multipliers applied post-LLM.

### Layer 4 — Proof + Completion Criteria (anti-dispute layer)
Template defines exactly what "done" means, what proof is required, and auto-release triggers.

---

## Layer 1: Compliance Guardian

### Implementation
- **Service:** `ComplianceGuardianService` (new backend service)
- **Endpoint:** `POST /tasks/draft/evaluate` — fires when Poster taps "Preview Task" (not per-keystroke)
- **Client:** iOS displays result only. Cannot bypass or proxy the check.
- **LLM call:** Single lightweight call with structured prohibited list injected as system prompt context. No fine-tuning.

### Scoring
```
IllegalRiskScore: 0–100
  0–20:  CLEAN → proceed to template picker
  21–60: SOFT_FLAG → task created, escrow frozen, admin queue
  61–100: HARD_BLOCK → no task record created, plain-English explanation shown
```

### Prohibited Categories (system prompt context)
- Controlled substances / alcohol delivery without license
- Adult/sexual services (including disguised: "modeling with benefits", "massage no license")
- Unlicensed professional work (medical, legal, notary, therapy)
- Fraud / counterfeit / "package no questions asked"
- Animal cruelty / illegal animal handling
- Violence / weapons ("security bring your own gun")
- Child exploitation risk vectors (care tasks get double-scan)
- Semantic patterns: "deliver downtown no address", "no questions", "discreet only"

### Violation Logging
- **Internal (Trust & Safety):** `user_id`, `ip_address`, `device_fingerprint`, `timestamp`, `raw_description`, `risk_score` — never anonymized internally
- **External (reporting):** Aggregated counts only, no PII

### compliance_guardian_notes schema
```json
{
  "score": 47,
  "tier": "soft_flag",
  "triggered_rules": ["unlicensed_medical", "physical_contact_ambiguous"],
  "suggested_alternative": "specialized_licensed",
  "admin_review_id": null,
  "appeal_status": "none"
}
```

### Precedence Rule (enforced in code, in this exact order)
```
1. ComplianceGuardian → hard block or soft flag
2. TaskRiskClassifier (template-aware, overrides template default tier)
3. ScoperAI (template context + deterministic flag multipliers)
4. Template assignment + creation form
```
Hard block (61–100): stop. No task record created.
Soft flag (21–60): task created, `state = 'pending_review'`, escrow frozen.

---

## The 8 Task Templates

### Template 1: Standard Physical
**Slug:** `standard_physical`
**Maps to existing categories:** delivery, moving, assembly, shopping

**Required creation fields:** physical effort (light/moderate/heavy), vehicle required, tools, estimated duration, location

**ScoperAI context:**
```
Market rate: light $15–$30/hr, moderate $25–$50/hr, heavy $40–$75/hr
Vehicle premium: +$10–$20 flat. Multi-person: multiply by count.
$15 floor for any task under 30 min.
```

**Completion criteria:** `photo_proof` — before/after photos, GPS check-in required, AI image diff check
**Auto-release:** Poster has 24 hours to review, then auto-releases
**Risk tier:** TIER_0 outdoor, TIER_2 if entering home

---

### Template 2: In-Home
**Slug:** `in_home`
**Maps to existing categories:** cleaning + new: repairs, handyman, painting

**Required creation fields:** task type, property type, square footage, specific rooms checklist, supplies source, access method, pets present

**ScoperAI context:**
```
Market rate: apartment cleaning $60–$100, house $100–$180, deep clean 1.5–2x
Handyman hourly: $40–$75/hr. Painting per room: $150–$300.
Never price below $40 for any in-home task.
Flag "licensed_required" for electrical/plumbing/structural.
```

**Completion criteria:** `photo_proof` per room — each room in checklist generates required photo
**Auto-release:** 24 hours after proof, then auto-releases
**Dispute gate:** Poster must identify specific room, cannot reject entire job for one item
**Risk tier:** TIER_2 (enters home), TIER_3 if people/pets present

---

### Template 3: Care
**Slug:** `care`
**Maps to existing categories:** petCare + new: childcare, elder_care

**Required creation fields:** care type, individuals count + ages/species, duration, location, special requirements (encrypted), emergency contact, background check required

**ScoperAI context:**
```
Babysitting 1 child: $18–$25/hr. Additional children: +$5/hr each.
Pet sitting 8hr: $40–$80. Dog walk 30min: $20–$35.
Elder care companion: $20–$30/hr. Personal assistant: $18–$28/hr.
ALWAYS TIER_3. Minimum 2-hour duration (30-min pet walks excepted).
```

**Completion criteria:** `check_in_check_out` — GPS-verified arrival and departure
**Auto-release:** releases on confirmed GPS checkout
**Risk tier:** TIER_3 always

---

### Template 4: Content & Creator
**Slug:** `content_creator`
**New category — currently falls into `other`**

**What this covers:** In-person stream guest, YouTube/TikTok appearance, podcast in-person, gaming collab IRL, reaction content, music video participant

**Required creation fields:**
- Content type (gaming stream / podcast / video / music video / reaction / other appearance)
- Platform (informational only: Twitch/YouTube/TikTok/Instagram/podcast/private)
- Duration: exact hours (required, not estimated)
- Location: home studio / rented studio / venue / public
- Audience size bracket: <1K / 1K–10K / 10K–100K / 100K+
- Activity specifics (500 char max, required — must describe what Hustler actually does)
- Equipment provided by Poster: all / partial / Hustler brings own
- **Content release consent checkbox** (required): "Hustler consents to appearing in content. Content may be edited, clipped, monetized by Poster. Hustler retains no revenue rights."
- Cancellation window: 2hr / 4hr / 24hr
- Late cancel protection: 75% of agreed rate if Poster cancels within window

**ScoperAI context:**
```
IMPORTANT: This is IRL in-person talent work, NOT digital labor.
Market rate by audience:
  <1K: $20–$50/hr (community value)
  1K–10K: $40–$80/hr (brand value)
  10K–100K: $75–$150/hr (influencer rate)
  100K+: $150–$400/hr (professional talent)
Minimum 1-hour billing floor. Travel premium: +$15–$30 if >30min travel.
Specialization: competitive gaming +20%, music performance +30%, subject expertise +25%.
DO NOT price like physical labor.
```

**Completion criteria — hybrid:**
- Primary (always): GPS check-in/check-out at agreed location, duration confirmed
- Secondary (optional Poster choice): screenshot showing both parties on stream, OR timestamp-verified photo
- Payment releases on confirmed check-out regardless of content outcome
- 75% releases immediately if Poster cancels within cancellation window

**Dispute objective standard (shown to both parties):**
> "Task is complete when the Hustler was GPS-verified at the agreed location for the agreed duration. Payment releases automatically on check-out. The Poster cannot withhold payment because the content 'didn't go well', audience didn't engage, or the stream had technical issues. The Hustler was hired for time and presence, not performance outcome."

**Mutual Consent Checklist:** Required gate at acceptance — both parties tap confirm on:
1. Exact activity description
2. Content release terms
3. Cancellation policy and late-cancel protection
4. Proof requirements (GPS + optional photo)
5. Auto-release trigger (check-out = payment released)

**Risk tier:** TIER_1 (at Poster's property), TIER_2 (at Poster's private home)
**Required trust tier:** Verified+

---

### Template 5: Event & Appearance
**Slug:** `event_appearance`
**New category**

**Covers:** brand ambassador, promotional model, party host, event staff, meet-and-greet support, product demo

**Required creation fields:** role type, event type, dress code (specific), physical requirements, estimated attendance, duration + schedule, uniform source, alcohol present (age gate trigger)

**ScoperAI context:**
```
General event staff: $18–$28/hr. Brand ambassador: $22–$35/hr.
Promo model: $30–$60/hr. Party host: $40–$80/hr. Product demo: $28–$45/hr.
Minimum 3-hour booking. Weekend/evening: +15%.
Dress code: Hustler-sourced professional attire +$10–$15 flat.
```

**Completion criteria:** GPS check-in/check-out at venue + timestamp photo at end
**Auto-release:** on confirmed check-out
**No-show protection:** 100% payment releases if Poster cancels day-of
**Risk tier:** TIER_1

---

### Template 6: Creative Production
**Slug:** `creative_production`
**New category**

**Covers:** photo shoot model/extra, video shoot participant, music recording session, film background

**Required creation fields:** production type, role, location, **usage rights** (personal / commercial / advertising — major price driver), image/likeness release for commercial, duration with hard end time, wardrobe source

**ScoperAI context:**
```
Photo shoot personal use: $50–$100. Commercial: $150–$400.
Video shoot extra half-day: $80–$150. Principal: $150–$300.
Music session: $40–$150. Film background: $100–$200/day.
Usage rights multiplier: personal 1x, social commercial 1.5x, advertising/broadcast 2–3x.
Never under $50 for any production task.
```

**Completion criteria:** GPS check-in + both-party in-app session confirmation
**Likeness release:** stored immutably on task record at acceptance
**Risk tier:** TIER_1 (studio/outdoor), TIER_2 (private property)

---

### Template 7: Specialized / Licensed
**Slug:** `specialized_licensed`
**Maps to existing categories:** tech + new: licensed trades, tutoring, coaching

**Covers:** licensed electrician, plumber, HVAC, notary, certified tutor, personal trainer, licensed massage, real estate

**Required creation fields:** trade/specialty (from enum, not free text), license required toggle, permit required toggle, materials source, work scope (min 100 chars), property type, estimated hours

**ScoperAI context:**
```
Electrician/plumber licensed: $75–$150/hr.
HVAC: $85–$150/hr. Notary: $15–$30/signing.
Certified personal trainer: $50–$100/session. Licensed massage: $60–$100/hr.
Tutor general: $30–$60/hr. Tutor specialized: $60–$120/hr.
NEVER under $30/hr for any specialized work.
Materials cost is separate — do not include in suggested price.
```

**Completion criteria:** photo_proof (before/after of work area) + GPS check-in/check-out
**License gate:** hard gate at claim time — `license_required: true` → only Hustlers with matching verified license badge can claim. Not a soft gate.
**Risk tier:** TIER_1 (outdoor), TIER_2 (in-home)

---

### Template 8: Wildcard Bizarre & Custom ⭐
**Slug:** `wildcard_bizarre`
**The catch-all for everything legal that doesn't fit templates 1–7**

**Covers:** human statue, live mannequin, escape room actor, flash mob mascot, private chef themed dinner, bachelor party surprise, art installation participant, anything genuinely novel

**3-question Poster creation UX:**
1. "What's the weirdest part of this task?" (helps AI generate criteria)
2. "What would make you 100% satisfied — describe the exact proof?" (drives completion criteria)
3. "Any content, rights, or safety concerns?" (routes to consent checklist)

**Auto-generated required fields:** exact script/dialogue if performance element, props list, safety parameters, audience size, explicit "no-go zones" the Hustler can set

**ScoperAI context:**
```
TEMPLATE: wildcard_bizarre
This is a true one-off IRL performance/participation gig. Price like talent, not labor.
Base rate: $25–$100/hr depending on complexity.
Apply deterministic flag multipliers below — DO NOT estimate a weirdness premium yourself.
Minimum 2-hour floor. $500 constitutional cap applies after multipliers.
```

**Deterministic Weirdness Flag Table (applied post-LLM, before validation):**
```typescript
const WILDCARD_MULTIPLIERS = {
  private_location_flag:    0.15,  // at Poster's private home/property
  props_required_flag:      0.10,  // Hustler must bring/wear props
  performance_element_flag: 0.20,  // acting, character, scripted behavior
  audience_present_flag:    0.10,  // task has live audience
  costume_or_attire_flag:   0.10,  // specific attire required
  travel_over_30min_flag:   0.20,  // estimated travel >30min
}
// Total premium capped at 50%
// Final price: Math.min(basePrice * (1 + totalMultiplier), MAX_PRICE_CENTS)
```

**Completion criteria — hybrid dynamic:**
- Always: GPS check-in/check-out + duration timer
- Poster chooses 1–2 bonus proof items at creation:
  - Timestamped photo of both parties at task
  - 15-second video clip of the activity
  - Sign-off selfie at task end
- AI image/timestamp validator on submitted proof

**Dispute objective standard:**
> "Task is complete when the Hustler was physically present for the agreed time + submitted the exact proof items specified at posting. Poster cannot dispute based on 'vibe', 'energy', or subjective performance quality — only missing proof items or GPS-confirmed early exit are valid dispute grounds."

**Mutual Consent Checklist:** Required gate for wildcard (same 5-item format as content_creator)

**Auto-release:** 48-hour Poster review window (longer than standard 24hr — bizarre tasks need more review time), then auto-releases
**Late cancel protection:** 75% releases if Poster cancels after Hustler has accepted
**Bizarre Badge:** Deferred to XP/badge sprint — not coupled to this implementation

**Risk tier:** TIER_1 default, auto-bumps to TIER_2 if `private_location_flag` present
**Required trust tier:** Verified+

---

## Cross-Cutting System Changes

### Database Migration: `task_template_system.sql`
```sql
ALTER TABLE tasks ADD COLUMN IF NOT EXISTS template_slug VARCHAR(50);
ALTER TABLE tasks ADD COLUMN IF NOT EXISTS completion_criteria JSONB;
ALTER TABLE tasks ADD COLUMN IF NOT EXISTS content_release BOOLEAN DEFAULT FALSE;
ALTER TABLE tasks ADD COLUMN IF NOT EXISTS cancellation_window_hours INTEGER DEFAULT 0;
ALTER TABLE tasks ADD COLUMN IF NOT EXISTS illegal_risk_score INTEGER DEFAULT 0;
ALTER TABLE tasks ADD COLUMN IF NOT EXISTS compliance_guardian_notes JSONB;
ALTER TABLE tasks ADD COLUMN IF NOT EXISTS mutual_consent_accepted BOOLEAN DEFAULT FALSE;
ALTER TABLE tasks ADD COLUMN IF NOT EXISTS late_cancel_pct INTEGER NOT NULL DEFAULT 0;

-- New violation log table
CREATE TABLE IF NOT EXISTS compliance_violations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id),
  ip_address INET,
  device_fingerprint TEXT,
  raw_description TEXT NOT NULL,
  risk_score INTEGER NOT NULL,
  triggered_rules JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

### New Backend Service: `ComplianceGuardianService`
- `evaluate(taskDraft: TaskDraft): Promise<ComplianceResult>`
- Called by new tRPC procedure `task.evaluateDraft`
- Fires server-side only — client sends draft, receives score + notes
- Hard blocks return before any task record is written

### ScoperAI Changes
- `analyzeTaskScope()` receives `templateSlug` + active flags array
- Template-specific context block injected into system prompt
- After LLM returns base price, deterministic multipliers applied in service layer
- `_validateProposal()` runs after multipliers — cap enforced post-multiplication:
  ```typescript
  const multipliedPrice = Math.min(
    proposal.suggested_price_cents * (1 + totalMultiplier),
    MAX_PRICE_CENTS
  )
  proposal.suggested_price_cents = multipliedPrice
  ```
- Heuristic fallback `_generateProposal()` also receives template context

### TaskRiskClassifier Changes
- Receives `templateSlug` as additional input
- Template defaults can set starting tier, but boolean flags can only increase (never decrease) risk
- `wildcard_bizarre` with `private_location_flag` → minimum TIER_2

### TaskCategory Enum Expansion (iOS AIPricing.swift + backend)
```
+ contentCreator    = "content_creator"
+ eventAppearance   = "event_appearance"
+ creativeProduction = "creative_production"
+ specializedLicensed = "specialized_licensed"
+ childcare         = "childcare"
+ elderCare         = "elder_care"
+ handyman          = "handyman"
+ wildcardBizarre   = "wildcard_bizarre"
```

### ProofService Changes
- `submitProof()` checks `completion_criteria.type`:
  - `photo_proof` → requires N photos per checklist
  - `check_in_check_out` → requires GPS timestamps
  - `session_completion` → requires both-party in-app confirm
  - `hybrid` → check-in/out + at least one bonus proof item

### Escrow Auto-Release Rules
- `check_in_check_out`: releases on confirmed GPS checkout
- `photo_proof`: releases 24hr after proof submission if Poster hasn't reviewed
- `wildcard_bizarre`: releases 48hr after proof if Poster hasn't reviewed
- `session_completion`: releases on both-party confirmation
- `soft_flag_freeze`: escrow frozen until `admin_review_id` is resolved
- Late cancel: `late_cancel_pct`% releases immediately on Poster cancel after acceptance

### New tRPC Procedures
- `task.evaluateDraft` — runs ComplianceGuardian, returns score + notes
- `task.acceptWithConsent` — requires mutual_consent checklist payload for wildcard + content_creator templates
- `task.getComplianceStatus` — Hustler-facing: surfaces existing score + notes at accept time (no new LLM call)

---

## Implementation Notes

1. `draft/evaluate` fires on "Preview Task" tap — not per-keystroke. 500ms minimum since last description edit before Preview button enables.
2. `TaskRiskClassifier` must receive `templateSlug` — template provides starting tier, flags only escalate.
3. ScoperAI heuristic fallback needs template awareness, not just the LLM path.
4. Licensed professional false positives (e.g., licensed massage therapist triggers `physical_contact_ambiguous`): `appeal_status` field in `compliance_guardian_notes` handles this — admin can green-light soft flags.
5. All wildcard and content_creator tasks require `mutual_consent_accepted = TRUE` before `state` can advance from `posted` to `claimed`.
