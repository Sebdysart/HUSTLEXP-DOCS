# HustleXP — Product Documentation

HustleXP is a **gamified local task marketplace** connecting workers ("Hustlers") and employers ("Posters") for short-form local task completion. Every completed task builds XP, trust tiers, and a verifiable platform reputation that compounds over time instead of resetting. Think TaskRabbit, but your reputation actually matters.

**The core thesis:** Workers who invest in building their trust tier — completing tasks, earning ratings, maintaining low dispute rates — unlock better tasks, higher XP multipliers, Live Mode access, and squad formation. The platform rewards consistency with compounding returns. Commoditized gig labor does not.

---

## ⚡ Current Status — Live Truth

| Metric | Value |
|--------|-------|
| **Phase** | 🟢 Private Beta — Launch Ready |
| **Ecosystem Health** | 100/100 |
| **Beta Gate** | 100/100 — all P0 blockers resolved |
| **iOS App** | 58 screens, SwiftUI (iOS 17+) |
| **Backend** | 38 tRPC routers, 290+ procedures |
| **Database** | 103 PostgreSQL tables + PostGIS |
| **Tests** | 5,448 passing, 239 files, 0 failures |
| **Coverage** | 89.6% statement, 77.6% branch |
| **API Contracts** | 219 bridges, 0 mismatches |
| **Background Workers** | 23 BullMQ workers |
| **AI Agents** | 4 live (Judge, Matchmaker, Dispute, Reputation) |
| **Last Updated** | 2026-03-14 |

---

## For New Contributors — Read This First

You can get oriented in 10 minutes by reading these in order:

1. **This file** — What the project is, current status, what's live
2. [`PROJECT-AUDIT-2026-03.md`](PROJECT-AUDIT-2026-03.md) — Complete in-depth audit: both user POVs, all 58 screens, full feature inventory, technical depth
3. [`CURRENT_PHASE.md`](CURRENT_PHASE.md) — What phase we're in, what work is allowed, what's frozen
4. [`specs/04-backend/API_CONTRACT.md`](specs/04-backend/API_CONTRACT.md) — The source of truth for all API shapes
5. [`private-beta/scorecard.json`](private-beta/scorecard.json) — Machine-readable gate status (check this first every session)

**Answer these 5 questions and you're oriented:**
1. What is HustleXP? → Gamified local task marketplace. Reputation compounds, doesn't reset.
2. What's the current state? → 100/100 health, private beta ready, iOS + Railway backend live.
3. What are the 3 differentiators? → Trust tier progression, Live Mode radar, proof-of-work chain.
4. What's the architecture? → SwiftUI iOS → Firebase JWT → Hono/tRPC → Neon Postgres + Upstash Redis + BullMQ.
5. What's not done? → Checkr (blocked), Rekognition liveness (planned), legal doc placeholders (Gate 1 hard block).

---

## What's Live Right Now

Everything below is implemented and deployed in production:

**Core Marketplace**
- ✅ Full task lifecycle (OPEN → ACCEPTED → PROOF_SUBMITTED → COMPLETED) with 9-state machine
- ✅ Stripe escrow (PENDING → FUNDED → RELEASED / REFUNDED / LOCKED_DISPUTE)
- ✅ Bidirectional ratings (Hustler ↔ Poster), auto-rating on inactivity
- ✅ In-app task-scoped messaging with photo attachments and FCM push

**Gamification**
- ✅ XP system with stacked multipliers (streak × trust tier × live mode)
- ✅ Trust tiers: Rookie → Verified → Trusted → Elite → Master
- ✅ Badge system (append-only, immutable, 4 tiers per badge type)
- ✅ Daily streaks with multiplier (1.0 + streak_days × 0.05, cap 2.0)
- ✅ Daily challenges (backend wired; iOS screen in progress)

**Features**
- ✅ Live Mode / ASAP task broadcasting with real-time SSE radar
- ✅ Squads (Elite+ team formation, shared XP + earnings, levels 1–6)
- ✅ Recurring tasks (template series, preferred worker assignment)
- ✅ Tipping (in-app, 100% to worker, min $1, max 50% of task price)
- ✅ Referral system (referral codes, bonuses on referee's first task)
- ✅ Featured task promotion ($2.99–$7.99, Stripe-wired)
- ✅ Batch quests (multi-task, AI route optimization)
- ✅ Heat map (geographic demand visualization)

**Trust & Safety**
- ✅ Fraud detection (real-time risk scoring, velocity checks, pattern detection)
- ✅ Content moderation (toxicity API, moderation queue, appeal workflow)
- ✅ Biometric proof (GPS + photo + device biometric at submission)
- ✅ KYC gate (payouts_enabled + stripe_connect_id before any escrow release)
- ✅ 6-tier rate limiting (Auth / AI / Financial / Mutation / Upload / General)
- ✅ Geofencing (GPS coordinates validated against task location radius)

**Compliance & Finance**
- ✅ Subscriptions (Free / Premium $14.99 / Pro $29.99 — Stripe recurring billing)
- ✅ XP tax (10% on offline payments; Stripe payment intent; DB trigger enforced)
- ✅ 1099-NEC generation (Stripe Tax API, workers >$600/year, annual filing)
- ✅ Insurance claims (self-insurance pool, file + review + pay workflow)
- ✅ GDPR data export + deletion rights

**AI Agents**
- ✅ Judge (proof verification: GPS + photo + biometric → APPROVE/REVIEW/REJECT)
- ✅ Matchmaker (worker ranking, price suggestions)
- ✅ Dispute (fault scoring, split ratio recommendations)
- ✅ Reputation (dynamic trust scoring, anomaly detection, tier eligibility)
- ✅ AIRouter cost governance (per-user daily budgets, provider fallback chains, $500/day global cap)

**Infrastructure**
- ✅ 23 BullMQ workers (payment, escrow, fraud, push, email, SMS, biometric, recurring, tax, etc.)
- ✅ SSE real-time broadcasting (`/realtime/stream`)
- ✅ CI pipeline: Zenith Codex (16 layers, PR classifier, readiness score, Greptile review)

---

## What's Deferred

| Feature | Status | Notes |
|---------|--------|-------|
| Checkr background checks | ⏸ Blocked | Account authorization pending — B3 post-beta |
| AWS Rekognition liveness | 🔵 Planned | Full biometric step-up auth. Amplify SDK not yet installed. |
| Dispute submission (iOS) | ✅ Complete | Wired to `dispute.create` / `dispute.getByTask` / `dispute.getMine` (backend commit `c6e9ce57`) |
| Android client | 📋 Roadmap | Post-iOS-beta |
| Video proof / LiDAR | 📋 Roadmap | Judge Agent Phase 2 |
| AI-dynamic insurance | 📋 Roadmap | Risk Engine Phase 2 |
| Background check freemium | 📋 Roadmap | "Earn enough tasks → platform covers your check" model |

---

## Repository Map

```
HUSTLEXP-DOCS/
├── PROJECT-AUDIT-2026-03.md      # ← Start here. Complete project audit.
├── CURRENT_PHASE.md              # What phase we're in. What's allowed.
├── PRIVATE_BETA_SPEC.md          # Beta gate definitions + journey specs
├── private-beta/
│   └── scorecard.json            # Machine-readable gate status (auto-updated)
├── specs/
│   ├── 01-product/               # Product requirements
│   ├── 04-backend/
│   │   └── API_CONTRACT.md       # SOURCE OF TRUTH for all API shapes
│   └── 05-ios/                   # iOS screen specs
├── docs/
│   └── plans/                    # Implementation design docs + plans
│       └── 2026-03-14-readme-vision-reset-design.md
├── tracking/                     # Sprint tracking, orbit state
├── _archive/                     # Legacy docs — DO NOT USE for current work
├── FINISHED_STATE.md             # ⚠️ STALE — reflects Jan 2025 scope (3x features have since shipped)
├── FEATURE_FREEZE.md             # ⚠️ STALE — original freeze list pre-dates live features
└── BUILD_READINESS.md            # ⚠️ STALE — predates SwiftUI pivot, 32-table era
```

> ⚠️ `FINISHED_STATE.md`, `FEATURE_FREEZE.md`, and `BUILD_READINESS.md` reflect the original Jan 2025 MVP scope. They explicitly exclude tipping, recurring tasks, referral, AI agents, and subscriptions — all of which are now live. These documents have not been updated. Use `PROJECT-AUDIT-2026-03.md` and `CURRENT_PHASE.md` as the source of current truth.

---

## Authority Hierarchy

When docs and code disagree, this is the resolution order:

```
1. private-beta/scorecard.json     (gate status — machine truth)
2. CURRENT_PHASE.md                (what phase + what's allowed — human truth)
3. specs/04-backend/API_CONTRACT.md (API shapes — contract truth)
4. Backend code                    (implementation truth)
5. iOS code                        (client truth)
```

If FINISHED_STATE.md or FEATURE_FREEZE.md conflict with the above — the above wins. Those docs are historical artifacts.

---

## The 2-Year North Star

HustleXP becomes a **skilled-labor credentialing network with a marketplace on top**, not a marketplace with badges bolted on.

A Master Hustler (100+ tasks, 4.95+ stars, $10k+ earned, zero disputes) holds a credential more verifiable than a resume. Squads of Elite workers can bid on commercial contracts ($500+) no individual can take alone. The XP economy extends into:
- Insurance discounts at higher trust tiers
- Earned wage advance at Trusted+
- Verified worker identity exportable to other platforms
- AI agents shift from assistive to predictive: demand forecasting, hot zone routing, pre-positioning

The long-term moat is not the marketplace — it's the identity layer. Workers who have invested years building trust on HustleXP won't start over somewhere else.

---

## AI Tool Instructions

> This section is for Cursor, Claude Code, and other AI coding agents.

**At session start:**
1. Read `private-beta/scorecard.json` — state the current score and top blocker
2. Read `CURRENT_PHASE.md` — confirm what work is allowed in this phase
3. Check `specs/04-backend/API_CONTRACT.md` before generating any API calls

**Iron laws:**
- `payloadDrift=11` is the irreducible floor — all type-repr artifacts. Do NOT chase these.
- `health=100/100` — do not regress this.
- Do NOT modify API contracts without running `/impact` first.
- Do NOT work on B3 items (Checkr, Squads insurance, video proof) — deferred post-beta.
- `FINISHED_STATE.md` is stale — do not use it to determine what features exist.

**Orbit config:** `~/.claude/omni-link/orbit-config.json`
**Workflow reference:** `/Users/sebastiandysart/omni-link-hustlexp/WORKFLOW.md`
