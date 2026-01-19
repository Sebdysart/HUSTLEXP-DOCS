# HustleXP Onboarding Specification v1.3

**STATUS: CONSTITUTIONAL AUTHORITY**  
**Last Updated: January 2025**  
**Purpose: Role inference + authority priming before user sees feed**  
**Governed by:** [AI_INFRASTRUCTURE.md](./AI_INFRASTRUCTURE.md) §3–§8

---

## §0.1 Onboarding Invariants (CONSTITUTIONAL)

These invariants are **non-negotiable**. Violation degrades onboarding integrity.

| ID | Invariant | Enforcement |
|----|-----------|-------------|
| **ONB-1** | Users may NOT self-select role before inference | UI flow enforced |
| **ONB-2** | Onboarding contains ZERO rewards | No XP, badges, celebrations |
| **ONB-3** | Posters NEVER see gamification elements | Role-gated UI |
| **ONB-4** | Hustlers see gamification ONLY after first RELEASED escrow | DB trigger + UI gate |
| **ONB-5** | First XP celebration is single-use and server-tracked | `xp_first_celebration_shown_at` |
| **ONB-6** | Onboarding exits as soon as authority is established | Minimal screens |

**Cross-Reference:**
- ONB-4 enforcement: PRODUCT_SPEC §2 (INV-1)
- ONB-5 tracking: UI_SPEC §3.4
- Role authority: ARCHITECTURE.md §2

---

## §0. AI Governance (CONSTITUTIONAL)

This specification is governed by `AI_INFRASTRUCTURE.md`. The following constraints apply:

| Constraint | Value | Reference |
|------------|-------|-----------|
| Authority Level | **A2** (Proposal-Only) | AI_INFRASTRUCTURE §3.2 |
| Certainty Tiers | STRONG / MODERATE / WEAK | AI_INFRASTRUCTURE §8 |
| Logging Required | certainty_tier, confidence, anomaly_flags, schema_version | AI_INFRASTRUCTURE §8.3 |
| Fallback | Explicit user selection | AI_INFRASTRUCTURE §14.2 |
| Kill Switch | `ai.onboarding.enabled` | AI_INFRASTRUCTURE §14.1 |

**Rule:** AI proposes role confidence. Deterministic validators decide. Database enforces. UI reveals.

---

## §1. Design Philosophy

### 1.1 What This Is NOT

- ❌ Personalization
- ❌ Friendliness
- ❌ Feature discovery
- ❌ A chatbot
- ❌ A survey
- ❌ A quiz
- ❌ A funnel
- ❌ A tutorial

### 1.2 What This IS

> Establish *role*, *intent*, and *risk profile* **before** the user ever sees a feed.

This is:
- ✅ System calibration
- ✅ Professional intake
- ✅ Capability alignment
- ✅ Jurisdictional handshake

If role inference is wrong, **everything downstream degrades**:
- XP meaning
- Trust signals
- UI tone
- Pricing expectations
- Dispute behavior

### 1.3 Core Principle: Jurisdictional Handshake (MEMORIZE THIS)

> **Onboarding is not a funnel. It is a jurisdictional handshake.**

This means:

- **No excitement** — System authority, not marketing energy
- **No rewards** — All dopamine is deferred until earned
- **No progress bars** — This is measurement, not achievement
- **No "getting started" energy** — This is configuration, not celebration

Onboarding exists to:

1. **Measure intent** — Through behavioral inference
2. **Assign authority** — Role determines jurisdiction
3. **Explain guarantees** — What the system promises
4. **Exit immediately** — Minimal time-to-value

---

## §2. Core Principle: Implicit First, Explicit Second

Elite products **never ask role directly first**.

They:
1. Ask **behavioral questions**
2. Infer role probabilistically
3. Lock defaults
4. Allow override *after*

Why:
- Reduces bad actors
- Prevents gaming
- Increases trust legitimacy
- Sets tone: *the system is observant*

---

## §3. Onboarding Phases

### Phase 0: Silent Context Capture (No UI)

Before any questions, capture:

| Signal | Weight | Purpose |
|--------|--------|---------|
| Device type | 0.05 | Mobile slightly worker-leaning |
| Time of day | 0.03 | Evening slightly worker-leaning |
| Referral source | 0.10 | Direct referral = higher confidence |
| Locale | — | Copy localization |
| Signup velocity | — | Bot detection |

This feeds a **prior probability**.

---

### Phase 1: Calibration Prompts (5 screens)

Each screen:
- Single sentence prompt
- Binary or ternary choice
- No explanation
- No emojis
- No "why we ask"

#### Q1: Motivation (Weight: 0.25)
```
"Which matters more right now?"

[ ] Earning extra income        → worker: 0.85
[ ] Getting things done         → poster: 0.85
[ ] Both equally                → 0.50 / 0.50
```

#### Q2: Frustration (Weight: 0.20)
```
"What frustrates you most about getting help?"

[ ] Finding reliable people     → poster: 0.80
[ ] Getting paid fairly         → worker: 0.85
[ ] Poor communication          → neutral
```

#### Q3: Availability (Weight: 0.15)
```
"How much time can you commit weekly?"

[ ] Flexible, varies weekly     → worker: 0.75
[ ] Limited, specific hours     → worker: 0.60
[ ] Minimal, just oversight     → poster: 0.80
```

#### Q4: Price Orientation (Weight: 0.12)
```
"When it comes to price:"

[ ] I compete on value          → worker: 0.80
[ ] I pay for quality           → poster: 0.85
[ ] Fair rates matter most      → neutral
```

#### Q5: Control Preference (Weight: 0.10)
```
"Your preferred working style:"

[ ] Work independently          → worker: 0.80
[ ] Clear direction helps       → neutral
[ ] Delegate and verify         → poster: 0.85
```

---

### Phase 2: Silent Inference (No UI)

Compute:

```typescript
role_confidence = {
  worker: 0.XX,
  poster: 0.XX,
  confidence: 0.XX,      // distance from 50/50
  certaintyTier: 'STRONG' | 'MODERATE' | 'WEAK'
}
```

Also compute profile signals:
- Risk tolerance
- Price sensitivity
- Urgency bias
- Authority expectation

**Nothing shown yet.**

---

### Phase 3: Authority Confirmation (Critical)

UI behavior varies by **certainty tier** (see §11).

**STRONG (≥0.75):**
```
Based on your responses

We'll set you up as a

[WORKER / POSTER]

[ Continue ]
[ Adjust role ]
```

**MODERATE (0.60-0.74):**
```
Based on your responses, you seem like a

[WORKER / POSTER]

You can adjust this if it doesn't feel right.

[ Continue ]
[ Adjust role ]
```

**WEAK (<0.60):**
```
We couldn't determine your primary use case

Please select how you'll mainly use HustleXP:

[ Worker - Earn by completing tasks ]
[ Poster - Get things done by others ]
```

---

### Phase 4: Preference Lock-In

Now — and only now — ask role-specific preferences:

**Worker Preferences:**
- Task types (errands, cleaning, tech, etc.)
- Availability windows
- Price bands

**Poster Preferences:**
- Task categories
- Budget range
- Urgency preference

Why now? Because role context makes answers *truthful*.

---

## §4. Scoring Function

### 4.1 Signal Weights

```typescript
const SIGNAL_WEIGHTS = {
  // Context signals
  deviceType: 0.05,
  timeOfDay: 0.03,
  referralSource: 0.10,
  
  // Calibration signals
  motivation: 0.25,
  frustration: 0.20,
  availability: 0.15,
  priceOrientation: 0.12,
  controlPreference: 0.10,
};
```

### 4.2 Role Confidence Calculation

```typescript
function computeRoleConfidence(context, responses) {
  let workerScore = 0;
  let posterScore = 0;
  
  // Sum weighted signals from responses
  for (const question of CALIBRATION_QUESTIONS) {
    const response = responses[question.id];
    const option = question.options.find(o => o.id === response);
    const weight = SIGNAL_WEIGHTS[question.id];
    
    workerScore += option.signal.worker * weight;
    posterScore += option.signal.poster * weight;
  }
  
  // Normalize
  const total = workerScore + posterScore;
  let normalizedWorker = workerScore / total;
  let normalizedPoster = posterScore / total;
  
  // Apply inconsistency penalties (see §10)
  const inconsistencies = detectInconsistencies(responses);
  if (inconsistencies.hasInconsistencies) {
    const dampeningFactor = 1 - inconsistencies.totalPenalty;
    normalizedWorker = 0.5 + (normalizedWorker - 0.5) * dampeningFactor;
    normalizedPoster = 0.5 + (normalizedPoster - 0.5) * dampeningFactor;
  }
  
  // Confidence = distance from 50/50
  const confidence = Math.abs(normalizedWorker - 0.5) * 2;
  const certaintyTier = getCertaintyTier(Math.max(normalizedWorker, normalizedPoster));
  
  return { worker, poster, confidence, certaintyTier, inconsistencies };
}
```

### 4.3 Role Inference Threshold

```typescript
const THRESHOLD = 0.55;

function inferRole(roleConfidence) {
  if (roleConfidence.worker >= THRESHOLD) return 'worker';
  if (roleConfidence.poster >= THRESHOLD) return 'poster';
  
  // Tie-breaker: favor worker (more common)
  return roleConfidence.worker >= roleConfidence.poster ? 'worker' : 'poster';
}
```

---

## §5. Profile Signals

Beyond role, compute:

### 5.1 Risk Tolerance (0-1)
```
Base: 0.5
+ 0.20 if priceOrientation = 'competitive'
- 0.10 if priceOrientation = 'premium'
+ 0.15 if controlPreference = 'autonomous'
- 0.10 if controlPreference = 'delegator'
```

### 5.2 Urgency Bias (0-1)
```
Base: 0.5
+ 0.15 if availability = 'flexible'
- 0.20 if availability = 'minimal'
+ 0.10 if motivation = 'income'
```

### 5.3 Authority Expectation (0-1)
```
Base: 0.5
+ 0.20 if controlPreference = 'collaborative'
- 0.15 if controlPreference = 'autonomous'
+ 0.10 if frustration = 'communication'
```

---

## §6. Derived Settings

Onboarding directly writes to:

| Setting | Worker Value | Poster Value |
|---------|--------------|--------------|
| `defaultAppMode` | 'worker' | 'poster' |
| `xpVisibilityRules` | 'ledger' | 'outcome' |
| `trustUiDensity` | based on authorityExpectation | based on authorityExpectation |
| `copyToneVariant` | 'earner' | 'delegator' |

Example impact:
- Worker-first users see **ledger-style XP** (detailed tracking)
- Poster-first users see **outcome guarantees** (completion focus)

Same system. Different lens.

---

## §7. Data Model

### 7.1 Onboarding Result Schema

```typescript
interface OnboardingResult {
  // Metadata (IMMUTABLE)
  version: string;           // '1.2.0' — locked per user
  completedAt: string;       // ISO timestamp
  
  // Role determination
  roleConfidence: {
    worker: number;          // 0-1
    poster: number;          // 0-1
    confidence: number;      // 0-1 (distance from 50/50)
    certaintyTier: RoleCertainty;
  };
  inferredRole: 'worker' | 'poster';
  finalRole: 'worker' | 'poster';
  roleWasOverridden: boolean;
  
  // Gaming detection
  inconsistencies: {
    totalPenalty: number;
    flags: string[];
    hasInconsistencies: boolean;
  };
  
  // Profile signals
  profileSignals: {
    riskTolerance: number;
    urgencyBias: number;
    authorityExpectation: number;
    priceSensitivity: number;
  };
  
  // Enforcement rules (for server-side)
  enforcementRules: EnforcementRules;
  
  // Raw data (for analytics)
  context: ContextCapture;
  responses: Record<string, string>;
  
  // Derived settings
  settings: DerivedSettings;
  
  // Role-specific preferences
  preferences: WorkerPreferences | PosterPreferences;
}
```

### 7.2 Database Fields

```sql
ALTER TABLE users ADD COLUMN onboarding_version VARCHAR(20) NOT NULL;
ALTER TABLE users ADD COLUMN role_confidence_worker NUMERIC(5,4);
ALTER TABLE users ADD COLUMN role_confidence_poster NUMERIC(5,4);
ALTER TABLE users ADD COLUMN role_certainty_tier VARCHAR(20);
ALTER TABLE users ADD COLUMN role_was_overridden BOOLEAN DEFAULT FALSE;
ALTER TABLE users ADD COLUMN inconsistency_flags TEXT[]; -- Array of flag strings
ALTER TABLE users ADD COLUMN risk_tolerance NUMERIC(4,3);
ALTER TABLE users ADD COLUMN urgency_bias NUMERIC(4,3);
ALTER TABLE users ADD COLUMN authority_expectation NUMERIC(4,3);
ALTER TABLE users ADD COLUMN price_sensitivity NUMERIC(4,3);
ALTER TABLE users ADD COLUMN xp_visibility_rules VARCHAR(20);
ALTER TABLE users ADD COLUMN trust_ui_density VARCHAR(20);
ALTER TABLE users ADD COLUMN copy_tone_variant VARCHAR(20);
```

---

## §8. Forbidden Patterns

### 8.1 What NOT to Do

| Pattern | Why It's Wrong |
|---------|----------------|
| Ask "Are you a worker or poster?" on screen 1 | Direct role selection invites gaming |
| Chat-style onboarding | Reduces system authority |
| AI typing indicators | Suggests conversation, not calibration |
| Explain your intelligence | Creates false expectations |
| Allow unlimited toggling early | Reduces commitment signal |
| Store preferences without role confidence | Disconnects data from context |

### 8.2 Anti-Patterns in Copy

- ❌ "Tell us about yourself 😊"
- ❌ "Let's get to know you!"
- ❌ "What brings you here today?"
- ❌ Any emojis
- ❌ Any exclamation points in prompts

### 8.3 Correct Tone

- ✅ "Which matters more right now?"
- ✅ "Your preferred working style:"
- ✅ "Based on your responses"
- ✅ Neutral. Professional. Observant.

---

## §9. Success Metrics

### 9.1 Done Criteria

| Metric | Target |
|--------|--------|
| New user lands in correct default mode | ≥80% |
| Role switch rate after week 1 | <20% |
| Dispute rate (inferred-role users) | Lower than explicit-role users |
| Onboarding completion rate | ≥85% |
| Time to complete | <90 seconds |

### 9.2 Analytics Events

Track:
- `onboarding_started`
- `calibration_question_answered` (with question_id, option_id)
- `calibration_skipped` (with last_completed_question)
- `role_inferred` (with inferred_role, certainty_tier, confidence)
- `role_confirmed` (with final_role, was_overridden)
- `inconsistency_detected` (with flags[])
- `preferences_completed`
- `onboarding_completed` (with total_duration_ms, version)

---

## §10. Gaming Detection (Inconsistency Rules)

### 10.1 Why This Matters

Bad actors can answer strategically to spoof Worker credibility in under 30 seconds. We detect and penalize inconsistent signal patterns.

### 10.2 Inconsistency Rules

| Rule ID | Condition | Penalty | Flag |
|---------|-----------|---------|------|
| 1 | `autonomous` + `minimal` availability | 0.15 | `CONTRADICTORY_CONTROL_AVAILABILITY` |
| 2 | `competitive` price + `minimal` availability | 0.10 | `PRICE_URGENCY_INCONSISTENT` |
| 3 | `delegator` + `income` motivation | 0.20 | `DELEGATION_INCOME_CONFLICT` |
| 4 | All 5 answers = perfect Worker profile | 0.25 | `SUSPICIOUSLY_PERFECT_WORKER` |
| 5 | All 5 answers = perfect Poster profile | 0.25 | `SUSPICIOUSLY_PERFECT_POSTER` |

### 10.3 Penalty Application

```typescript
function detectInconsistencies(responses): InconsistencyResult {
  const flags = [];
  let totalPenalty = 0;

  for (const rule of INCONSISTENCY_RULES) {
    if (rule.check(responses)) {
      flags.push(rule.flag);
      totalPenalty += rule.penalty;
    }
  }

  return {
    totalPenalty: Math.min(totalPenalty, 0.40), // Cap at 40%
    flags,
    hasInconsistencies: flags.length > 0,
  };
}
```

Penalty dampens confidence toward 50/50, triggering lower certainty tier.

---

## §11. Role Certainty & Enforcement (CONSTITUTIONAL)

### 11.1 Certainty Tiers

```typescript
enum RoleCertainty {
  STRONG = 'STRONG',     // ≥ 0.75 confidence
  MODERATE = 'MODERATE', // 0.60 - 0.74 confidence
  WEAK = 'WEAK',         // < 0.60 confidence
}
```

### 11.2 UI Behavior Per Tier

| Tier | Headline Copy | Subtext | Requires Explicit Choice |
|------|---------------|---------|--------------------------|
| STRONG | "We'll set you up as a" | None | No |
| MODERATE | "Based on your responses, you seem like a" | "You can adjust this if it doesn't feel right." | No |
| WEAK | "We couldn't determine your primary use case" | "Please select how you'll mainly use HustleXP:" | **Yes** |

### 11.3 Logging Rules (AI_INFRASTRUCTURE §8.3)

All onboarding completions MUST log:
- `certainty_tier` (enum)
- `confidence` (numeric 0-1)
- `inconsistency_flags[]` (string array)
- `role_was_overridden` (boolean)
- `onboarding_version` (string, immutable)
- `schema_version` (string)

### 11.4 Enforcement Rules (Server-Side)

Role confidence affects downstream behavior:

```typescript
interface EnforcementRules {
  // XP accrual
  xpAccrualEnabled: boolean;      // Only workers accrue
  xpVisibilityLevel: 'detailed' | 'summary';
  
  // Task permissions
  canAcceptTasks: boolean;        // Workers only
  canPostTasks: boolean;          // Posters only
  
  // Dispute handling
  disputeReviewPriority: 'high' | 'normal';  // WEAK = high scrutiny
  
  // Trust building
  trustBuildingRate: number;      // STRONG=1.0, MODERATE=0.9, WEAK=0.75
}
```

**WEAK certainty users**:
- Get `disputeReviewPriority: 'high'`
- Get `trustBuildingRate: 0.75` (25% slower trust building)
- Are flagged for manual review if disputes occur

### 11.5 Re-Onboarding Rules

Re-onboarding is **rare** and controlled:

| Condition | Allowed? |
|-----------|----------|
| Within first 7 days | ❌ Never |
| Original certainty was WEAK | ✅ Yes |
| User overrode inferred role | ✅ Yes |
| Role switch requested | Requires admin approval |

```typescript
function canReOnboard(existingResult, daysSinceCompletion): boolean {
  if (daysSinceCompletion < 7) return false;
  if (existingResult.certaintyTier === RoleCertainty.WEAK) return true;
  if (existingResult.roleWasOverridden) return true;
  return false; // Requires admin
}
```

### 11.6 Version Lock (Non-Negotiable)

Every user stores:
```typescript
onboarding_version: "1.2.0"
```

**Rules:**
- Never recompute role confidence across versions
- Never change weights without incrementing version
- Analytics must segment by version
- A/B tests require version branching

---

## §12. Divergent Experience Tracks

After role confirmation (Phase 3), the onboarding experience **diverges by role**. This is not personalization — it is jurisdictional separation.

### 13.1 Poster Onboarding Feel

Posters should experience onboarding as:

- **Safe** — Money protection explained
- **In control** — Clear authority over approval
- **Unpressured** — No urgency, no upsells
- **Unentertained** — Professional, not playful

**Visual Language:**
- Static illustrations (no animation)
- Plain checkmarks for confirmation
- Neutral color palette (no XP green)
- Short, declarative copy

**Poster Onboarding MUST Feel Like:**
> *"Stripe + Notion had a child."*

**Allowed Elements:**

| Element | Allowed? |
|---------|----------|
| Static illustrations | ✅ |
| Plain checkmarks | ✅ |
| Clear guarantees | ✅ |
| Short copy | ✅ |
| Escrow explanation | ✅ |

**Forbidden Elements (ONB-3 Enforcement):**

| Element | Allowed? |
|---------|----------|
| XP display | ❌ |
| Levels | ❌ |
| Badges | ❌ |
| Streaks | ❌ |
| Progress bars | ❌ |
| Celebrations | ❌ |
| Animations beyond fades | ❌ |

**Poster Takeaway (Single Sentence):**
> "I fund tasks. I approve work. Money is protected."

### 13.2 Hustler Onboarding Feel

**Critical: Hustler onboarding is NOT heavily gamified.**

Why? Gamification before first payment trains fantasy, not trust. The system wants *earned* dopamine.

Hustlers should experience onboarding as:

- **Serious** — Real money, real work
- **Protective** — Escrow guarantees explained
- **Slightly aspirational** — Progression exists
- **Not yet playful** — Playfulness is earned

**Visual Language:**
- Clean, professional screens
- Gamification elements **visible but inactive**
- Gray/locked states for XP, badges, streaks
- Clear path to unlocking

**Allowed Elements:**

| Element | State | Purpose |
|---------|-------|---------|
| XP display | Greyed out / "0 XP" | Shows what exists |
| Level indicator | "Level 1 — Locked" | Aspirational |
| Streak counter | "Inactive" | Not started |
| Badge silhouettes | Locked/greyed | Future rewards visible |
| "Unlocks after first task" label | Active | Creates tension |

**Forbidden Elements (ONB-4 Pre-Release Enforcement):**

| Element | Allowed? |
|---------|----------|
| Animated XP gain | ❌ |
| Progress bar movement | ❌ |
| Numbers increasing | ❌ |
| Celebrations | ❌ |
| Unlocked badge visuals | ❌ |
| Active streak fire/glow | ❌ |

**Hustler Takeaway (Single Sentence):**
> "Accept tasks. Submit proof. Get paid. XP is real."

### 13.3 Dual-Mode Users

Users can operate in both modes, but:

- Initial onboarding configures **primary mode**
- Secondary mode unlocked via Settings
- Switching modes does **NOT** re-trigger onboarding
- Gamification rules apply **per mode context**

**Rule:** A poster switching to hustler for the first time:
- Still sees locked gamification
- Must complete a task to unlock XP visuals
- No shortcuts based on poster history

---

## §13. Gamification Timing Rules

### 14.1 The Unlock Event (Critical)

Gamification unlocks **only after the first RELEASED escrow**.

```
┌─────────────────────────────────────────────────────────┐
│  GAMIFICATION UNLOCK TRIGGER                            │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  REQUIRES:                                              │
│    escrow.state = 'RELEASED'                            │
│    xp_ledger row created                                │
│    user.role = 'worker' OR 'dual' (in worker context)   │
│                                                         │
│  UNLOCKS:                                               │
│    ✓ XP animation plays (once)                          │
│    ✓ Level progress bar activates                       │
│    ✓ Streak counter lights up                           │
│    ✓ First badge awarded (if criteria met)              │
│    ✓ Future gamification interactions enabled           │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

**Why This Matters:**
- XP is backed by real money (INV-1)
- Dopamine is truth-backed
- No fantasy progression
- Trust is earned, not granted

### 14.2 Pre-Unlock State (Hustler Dashboard)

Before first RELEASED escrow, hustler sees:

```
┌─────────────────────────────────────────────────────────┐
│  TOTAL XP                                               │
│  ───────                                                │
│  0                                                      │
│  Level 1 • Rookie                                       │
│                                                         │
│  ┌─────────────────────────────────────────────────┐   │
│  │  [░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░]   │   │
│  │  XP unlocks after your first completed task     │   │
│  └─────────────────────────────────────────────────┘   │
│                                                         │
│  STREAK: Inactive                                       │
│  BADGES: 🔒 🔒 🔒 🔒                                    │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

**Rules:**
- Numbers visible but static
- Progress bar empty (no fill)
- Streak shows "Inactive" not "0 days"
- Badges are silhouettes/locks
- No animations, no celebrations

### 14.3 Post-Unlock State (First Completion)

After first RELEASED escrow:

```
EVENT SEQUENCE (one-time):
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. Server: escrow.state → RELEASED
2. Server: xp_ledger row created
3. Server: user.xp_first_celebration_shown_at = NULL (not yet shown)
4. Client: Receives XP award event
5. Client: Checks xp_first_celebration_shown_at
6. Client: IF NULL → Play first-time celebration
7. Client: Mark animation shown (API call)
8. Server: user.xp_first_celebration_shown_at = NOW()
9. Client: All future XP gains use standard animation

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### 14.4 First XP Celebration Spec

**Duration:** 2000ms maximum (UI_SPEC §3.2)

**Visual Sequence:**

| Time | Element | Animation |
|------|---------|-----------|
| 0-300ms | XP number appears | Fade in + scale 1.0→1.1→1.0 |
| 300-800ms | Progress bar fills | Linear fill to new position |
| 800-1200ms | "First Task Complete!" | Fade in, hold |
| 1200-1800ms | Badge unlock (if earned) | Fade in with subtle glow |
| 1800-2000ms | All elements settle | Fade to static state |

**Constraints:**
- No confetti (UI_SPEC §3.1 M2)
- No sound effects
- No shake/vibrate
- Single celebration instance (tracked server-side)
- Reduced motion: All steps instant, no animation

**Tracking:**

```sql
-- User table addition
ALTER TABLE users ADD COLUMN xp_first_celebration_shown_at TIMESTAMPTZ;

-- Check before showing celebration
SELECT xp_first_celebration_shown_at IS NULL AS should_show_celebration
FROM users WHERE id = $user_id;

-- Mark as shown
UPDATE users SET xp_first_celebration_shown_at = NOW()
WHERE id = $user_id AND xp_first_celebration_shown_at IS NULL;
```

### 14.5 Poster Gamification (Never)

**ONB-3 Enforcement:**

Posters **never** see:
- XP counters (even at 0)
- Level indicators
- Streak counters
- Badge displays
- Progress bars
- Any gamification UI

**Poster dashboard shows:**
- Active tasks
- Pending reviews
- Completed tasks
- Payment history
- Wallet balance

**No progression narrative.**

---

## §14. Phase 0 Framing Screen (Exact Spec)

Before calibration questions, show one framing screen.

### 15.1 Visual Requirements

- White or neutral surface background
- No brand gradients
- No motion
- No progress indicator
- No loading animation
- Single CTA button

### 15.2 Copy (Exact)

```
HustleXP supports two ways to use the platform.

We'll configure your experience based on how you respond.

[ Continue ]
```

**Alternative (if legal requires):**

```
HustleXP works differently depending on how you use it.

Answer a few questions to set up your account.

[ Continue ]
```

### 15.3 Why This Screen Exists

This establishes **system authority** without asking permission.

- User knows they will be measured
- User knows the system decides
- User accepts the framing before proceeding
- No false choice ("Skip" not shown here)

---

## §15. Phase 3 Authority Confirmation (Exact Spec)

This is the most important screen in onboarding.

### 16.1 Design Principle

> **This must feel inevitable, not exciting.**

The system has decided. The user is informed. Override is possible but logged.

### 16.2 Copy by Certainty Tier

**STRONG (≥0.75):**

```
Based on your responses, your account is configured for:

POSTER

This means you'll be able to post tasks and review completed work.

[ Continue ]
[ Adjust role ]
```

**MODERATE (0.60-0.74):**

```
Based on your responses, you seem like a:

POSTER

You can adjust this if it doesn't feel right.

[ Continue ]
[ Adjust role ]
```

**WEAK (<0.60):**

```
We couldn't determine your primary use case.

Please select how you'll mainly use HustleXP:

[ Worker — Earn by completing tasks ]
[ Poster — Get things done by others ]
```

### 16.3 Visual Requirements

- No animation
- No celebration
- No "Nice!" or positive reinforcement
- Role displayed prominently (large text)
- Buttons equal visual weight
- Override must be logged to `onboarding_events`

### 16.4 Override Logging

```typescript
interface RoleOverrideEvent {
  user_id: string;
  inferred_role: 'worker' | 'poster';
  selected_role: 'worker' | 'poster';
  certainty_tier: 'STRONG' | 'MODERATE' | 'WEAK';
  confidence: number;
  overridden_at: Date;
  onboarding_version: string;
}
```

---

## §16. Stress Tests: Dual-Mode Abuse Scenarios

### 17.1 Scenario: Poster Tries to Farm XP

**Attack:** Poster creates tasks, accepts them on alt account, self-approves.

**Defenses:**
1. Same-device detection (fingerprint)
2. Same-IP flagging
3. Rapid task creation → dispute review priority HIGH
4. Self-dealing pattern detection (AI_INFRASTRUCTURE §11)

**Result:** Flagged for manual review, trust penalty if confirmed.

### 17.2 Scenario: Worker Switches to Poster to Avoid Bad Reviews

**Attack:** Worker with poor approval rate switches to poster mode.

**Defenses:**
1. Trust tier follows user, not mode
2. Switching does not reset metrics
3. `trust_ledger` is append-only
4. Prior violations visible to dispute resolution

**Result:** Bad reputation persists across modes.

### 17.3 Scenario: User Re-Onboards to Reset Role Confidence

**Attack:** User claims onboarding was wrong to reset certainty tier.

**Defenses:**
1. Re-onboarding blocked for 7 days (§11.5)
2. Only WEAK certainty allows re-onboarding
3. Admin approval required for forced re-onboard
4. Original inference logged permanently

**Result:** Cannot game certainty tier through repetition.

### 17.4 Scenario: User Skips Onboarding Questions

**Attack:** User taps through randomly to reach feed faster.

**Defenses:**
1. Inconsistency detection (§10)
2. Gaming flags reduce certainty
3. WEAK certainty = slower trust building (§11.4)
4. Higher dispute scrutiny

**Result:** Gaming attempt results in worse experience, not better.

---

## §17. Implementation Checklist

### Design
- [x] 5 calibration questions (binary/ternary)
- [x] Zero explanations in prompts
- [x] Neutral, professional copy
- [x] Certainty-tier-aware confirmation screen
- [x] Role-gated preference screen
- [ ] Phase 0 framing screen (§15)
- [ ] Divergent track visuals (§13)

### Frontend
- [x] CalibrationScreen.js
- [x] RoleConfirmationScreen.js (certainty-aware)
- [x] PreferenceLockScreen.js
- [x] OnboardingNavigator.js
- [ ] FramingScreen.js (§15)
- [ ] FirstXPCelebration component (§14.4)
- [ ] LockedGamificationUI component (§14.2)

### State Machine
- [x] OnboardingStateMachine.js
- [x] Scoring function with inconsistency penalties
- [x] Certainty tier computation
- [x] Enforcement rules generation

### Backend (TODO - Phase 11)
- [ ] `POST /onboarding/submitCalibration` (AI_INFRASTRUCTURE §15.1)
- [ ] `POST /onboarding/confirmRole` (AI_INFRASTRUCTURE §15.1)
- [ ] `POST /onboarding/lockPreferences` (AI_INFRASTRUCTURE §15.1)
- [ ] Server-side role confidence recomputation
- [ ] Enforcement rules stored per user
- [ ] Analytics events
- [ ] `xp_first_celebration_shown_at` column (§14.4)

---

## Amendment History

| Version | Date | Summary |
|---------|------|---------|
| 1.0 | Jan 2025 | Initial specification |
| 1.1 | Jan 2025 | Added: Role Certainty tiers (§11), Gaming detection (§10), Enforcement rules, Version lock, Re-onboarding rules |
| 1.2 | Jan 2025 | Added: AI Governance section (§0), cross-references to AI_INFRASTRUCTURE.md |
| 1.3 | Jan 2025 | Added: ONB invariants (§0.1), Jurisdictional Handshake principle (§1.3), Divergent Experience Tracks (§12), Gamification Timing Rules (§13), Phase 0/3 exact specs (§14-15), Dual-mode stress tests (§16), Expanded Implementation Checklist (§17), Standardized section numbering |

---

**END OF ONBOARDING SPECIFICATION v1.3**
