# HustleXP UI Specification v1.5.0

**STATUS: CONSTITUTIONAL AUTHORITY — MAX-TIER COMPLETE + LAYERED HIERARCHY**  
**Owner:** HustleXP Core  
**Last Updated:** January 2025  
**Governance:** This document governs all visual expression. Violations are build failures.

**Max-Tier Status:** ✅ All 7 human systems gaps integrated (GAP-1 through GAP-7, excluding global fatigue for GAP-5 per product decision)

**Layered Hierarchy:** ✅ The UI Stack (Apple Glass → Duolingo → COD/Clash Royale) is now constitutional law (§2). This non-negotiable order is enforced with 7 invariants (LAYER-1 through LAYER-7).

---

## §1. Foundational Principles

### 1.1 UI Authority

The UI has **zero decision authority**.

Per ARCHITECTURE.md §2.5:
- UI may render state
- UI may request actions
- UI may **never** compute, decide, or assume

If the UI displays something the server didn't confirm, the UI is lying.

### 1.2 Expression vs Authority

| Layer | Role | Example |
|-------|------|---------|
| Database | Truth | `escrow.state = 'RELEASED'` |
| Backend | Decision | "Release escrow because task completed" |
| UI | Expression | Green checkmark + "Payment sent" |

The UI **expresses** decisions made elsewhere. It does not make them.

### 1.3 What This Spec Is Not

This spec does **not** define:
- ❌ Component libraries
- ❌ CSS frameworks
- ❌ Design system tokens
- ❌ Marketing aesthetics
- ❌ Brand guidelines

Those are implementation details. This spec defines **behavioral constraints**.

---

## §2. Layered Influence Hierarchy (The UI Stack)

**THIS IS NON-NEGOTIABLE ORDER. VIOLATION DEGRADES PRODUCT.**

The UI must stack three design influences **in strict hierarchy**, never blend or average them:

> **Apple Glass → Duolingo → Call of Duty / Clash Royale**

### 2.1 Core Principle

> **Trust is communicated through restraint.  
> Progress is communicated through motion.  
> Status is communicated through permanence.**

If any screen violates that mapping, it's not max tier.

**Most teams fail because they *average* these influences. You must **stack them**, not blend them.**

### 2.2 Layer 1: Apple Glass — Authority Layer (Always On)

This is the **base coat**. It is never turned off.

#### What Apple Glass Means Here

* Visual restraint
* Optical clarity
* Confidence without animation
* "This system knows what it's doing"

#### Where It Applies

* Poster UI (100% — Apple Glass only)
* Hustler UI (background, chrome, structure — always present)
* Onboarding (foundational layer)
* Payments (financial authority)
* Disputes (neutral, trustworthy)
* AI copy tone (professional, precise)

#### Hard Rules

* ❌ No visual noise
* ❌ No decorative animation
* ❌ No playful copy
* ❌ No "assistant personality"
* ❌ No emojis in functional UI
* ✅ Clean typography
* ✅ Generous whitespace
* ✅ System fonts preferred
* ✅ Subtle, professional color palette

**If Apple Glass breaks, trust collapses.**

### 2.3 Layer 2: Duolingo — Micro-Feedback Layer (Conditional)

This is **not gamification**. This is *acknowledgment*.

#### What Duolingo Contributes

* Timing discipline
* Micro-confirmations
* Gentle progress cues
* Emotional regulation

#### Where It's Allowed

* Button confirmations (after action)
* Task accepted (state transition)
* Proof submitted (acknowledgment)
* State transitions (smooth, brief)
* First-time success moments (single-use)
* Form validation (immediate, clear)

#### Strict Constraints

* ≤150ms micro-feedback (brief, not extended)
* No loops (animation plays once)
* No streak obsession language ("Don't break your streak!" is forbidden)
* No loss framing (positive framing only)
* No countdowns (creates anxiety)
* No urgency copy (remains calm)

**Duolingo here is UX polish, not motivation.**

### 2.4 Layer 3: COD / Clash Royale — Status & Artifact Layer (Earned Only)

This layer is **locked** behind economic truth.

#### What This Layer Is

* Badges (material-based, permanent)
* Trust tiers (VERIFIED, TRUSTED, ELITE)
* XP displays (earned value)
* Levels (progression markers)
* Materials (visual weight: matte → alloy → gold → obsidian)
* Permanence (never downgraded)
* Rarity (earned, not purchased)

#### Where It's Allowed

* Hustler side only (posters never see this layer)
* After first RELEASED escrow (unlocks after economic truth)
* Profile screen (achievements, progression)
* Badge unlock moments (one-time celebration)
* Trust tier displays (status markers)

#### What It Must Feel Like

* Military insignia (earned, serious)
* Competitive achievement (meaningful)
* Serious accomplishment (not trivial)

**Not:**
* Toys (no playful animations)
* Stickers (no decorative elements)
* Emojis (no cartoon characters)
* Slot machines (no randomized rewards)

### 2.5 The Stack by User Type

#### Poster UI — Apple Glass Only

Posters should **never** see:
* ❌ XP
* ❌ Levels
* ❌ Badges
* ❌ Animations beyond fades
* ❌ AI "personality"
* ❌ Gamification elements
* ❌ Status markers

Poster UI is:

> **"Infrastructure you trust with money."**

If a poster ever thinks:

> **"This feels like a game"**

You failed.

**Poster UI Invariant:** POSTER-UI-1 — Posters never see any Layer 3 (COD/Clash) elements. Violation: Build failure.

#### Hustler UI — Stacked, Not Blended

**Pre-Earning Hustler (Before First RELEASED):**
* ✅ Apple Glass (structure, authority)
* ✅ Duolingo (micro-feedback on actions)
* ❌ No badges
* ❌ No XP motion
* ❌ No status displays

This creates **anticipation without reward**.

**First Completion Moment (Single-Use):**
* ✅ Single Duolingo-style celebration (≤2000ms)
* ✅ Brief XP count-up (smooth, not bouncy)
* ✅ One-time haptic (system default)
* ✅ Server-tracked (never repeat)

No repeats. No spam.

**Ongoing Hustler (Post-Unlock):**
Now the full stack activates:
* ✅ **Apple Glass** → structure, layout, authority (always present)
* ✅ **Duolingo** → confirmations, pacing, micro-wins (conditional, brief)
* ✅ **COD / Clash** → badges, tiers, materials (earned only)

**But never all at once on the same surface.**

Each layer has its domain:
* Apple Glass: Background, chrome, structure
* Duolingo: Micro-interactions, state transitions
* COD/Clash: Status displays, achievements, progression

### 2.6 Badge System: Where COD / Clash Actually Matters

Badges are **objects**, not UI decorations.

#### Max-Tier Badge Rules

* **Material-based progression:**
  * Matte (common) → Alloy (uncommon) → Gold (rare) → Obsidian (legendary)
* **One-time unlock animation:**
  * Server-tracked (`badge_unlocked_at`)
  * Never animated again (static after first view)
  * Maximum 2000ms duration
* **Never downgraded:**
  * Badges are permanent (append-only)
  * Once earned, always displayed
* **Always server-verified:**
  * UI never shows unearned badges
  * Server confirms before display

These are **identity artifacts**. People screenshot these.

#### Badge Display Rules

* ✅ Profile screen (permanent display)
* ✅ Badge unlock moment (single-use animation)
* ✅ Achievement summary (static list)
* ❌ Task cards (not relevant context)
* ❌ Wallet (financial context, not achievement)
* ❌ Onboarding (nothing earned yet)

### 2.7 Layered Influence Invariants

| ID | Invariant | Enforcement |
|----|-----------|-------------|
| **LAYER-1** | Apple Glass layer always present (never disabled) | UI structure review |
| **LAYER-2** | Duolingo layer only in allowed contexts (state transitions, confirmations) | Animation guard |
| **LAYER-3** | COD/Clash layer only after first RELEASED escrow | Backend flag check |
| **LAYER-4** | Poster UI: Apple Glass only (no Layer 2 or 3) | Role-based UI guard |
| **LAYER-5** | Layers stack, never blend (each in its domain) | UI component review |
| **LAYER-6** | Badge animations: one-time only, server-tracked | Animation guard + DB flag |
| **LAYER-7** | No averaging of influences (strict hierarchy enforced) | Design review |

### 2.8 Why This Combination Works

* **Apple Glass** makes it credible (trust foundation)
* **Duolingo** makes it humane (smooth, respectful)
* **COD / Clash** makes it aspirational (earned status)

Most apps pick **one**. HustleXP uses **all three — but in different layers**.

That's why this works without becoming a casino.

### 2.9 Forbidden Violations

**Blending Layers (FORBIDDEN):**
```javascript
// ❌ FORBIDDEN: Mixing Apple Glass with playful elements
<Button style={appleGlassStyle}>
  🎉 Click here! 🎉  // Violates Apple Glass restraint
</Button>

// ❌ FORBIDDEN: Duolingo layer without restraint
<TaskCard>
  <CelebrationAnimation loop={true} />  // Violates Duolingo constraints
</TaskCard>

// ❌ FORBIDDEN: COD/Clash before economic truth
{user.firstEscrowReleased ? (
  <BadgeDisplay />  // ✅ OK
) : (
  <BadgeDisplay locked={true} />  // ✅ OK (locked)
  <BadgeDisplay />  // ❌ FORBIDDEN (showing unearned)
)}
```

**Averaging Influences (FORBIDDEN):**
```javascript
// ❌ FORBIDDEN: Averaging Apple Glass + Duolingo
const blendedStyle = {
  ...appleGlassStyle,      // Clean, restrained
  animation: 'bounce',     // Playful (violates Apple Glass)
  color: '#FF6B6B'         // Energetic (violates Apple Glass)
};

// ✅ CORRECT: Stacked, not blended
const stackedStyle = {
  ...appleGlassStyle,      // Base layer (always)
  transition: 'fade 150ms' // Duolingo layer (brief, conditional)
};
```

### 2.10 Enforcement

**ESLint Rules:**
* `enforce-layer-hierarchy` — Error if layers violate stacking order
* `no-poster-gamification` — Error if Layer 3 elements appear in Poster UI
* `no-unearned-status` — Error if Layer 3 displays before first RELEASED
* `badge-animation-once` — Error if badge animation repeats

**Runtime Guards:**
* `LayerHierarchyGuard` — Checks role and economic state before rendering Layer 3
* `BadgeAnimationGuard` — Prevents repeat badge animations (server flag check)
* `PosterUIGuard` — Blocks Layer 2 and Layer 3 in Poster UI context

---

## §3. Color Authority

### 3.1 Semantic Color Categories

Colors in HustleXP have **meaning**. They are not decorative.

| Category | Semantic Meaning | Usage |
|----------|------------------|-------|
| **XP** | Earned value, progression | XP displays, level indicators, streak counters |
| **MONEY** | Financial state | Escrow status, payment amounts, wallet |
| **STATUS** | System state | Success, warning, error, info |
| **NEUTRAL** | No semantic meaning | Backgrounds, borders, disabled states |

### 3.2 XP Colors

```
XP_PRIMARY:    #10B981 (Emerald 500)
XP_SECONDARY:  #34D399 (Emerald 400)
XP_BACKGROUND: #D1FAE5 (Emerald 100)
XP_ACCENT:     #059669 (Emerald 600)
```

**Allowed Contexts:**
- XP amount displays
- Level badges
- Streak indicators
- Progression bars
- Level-up celebrations

**Forbidden Contexts:**
- Task cards (before completion)
- Escrow states
- Navigation elements
- Generic buttons
- Error states

**Violation:** Using XP colors outside XP context implies unearned value.

### 3.3 Money Colors

```
MONEY_POSITIVE: #10B981 (Green - incoming)
MONEY_NEGATIVE: #EF4444 (Red - outgoing)
MONEY_NEUTRAL:  #6B7280 (Gray - pending)
MONEY_LOCKED:   #F59E0B (Amber - disputed)
```

**Allowed Contexts:**
- Escrow state indicators
- Payment amounts
- Wallet balances
- Transaction history

**Forbidden Contexts:**
- XP displays
- Task descriptions
- User profiles (except earnings)
- Decorative elements

**Violation:** Using money colors decoratively trivializes financial state.

### 3.4 Status Colors

```
SUCCESS: #10B981 (Confirmation, completion)
WARNING: #F59E0B (Attention needed, caution)
ERROR:   #EF4444 (Failure, rejection, danger)
INFO:    #3B82F6 (Neutral information)
```

**Usage Rules:**
- SUCCESS: Only after server confirms positive outcome
- WARNING: Only for actionable caution states
- ERROR: Only for actual failures, never for emphasis
- INFO: Only for neutral system messages

**Forbidden:**
- Using ERROR for visual emphasis
- Using SUCCESS before server confirmation
- Using WARNING for non-actionable decoration

### 3.5 Color Authority Violations

| Violation | Example | Consequence |
|-----------|---------|-------------|
| XP color in non-XP context | Green task card | ESLint error |
| Money color decoratively | Green "Post Task" button | ESLint error |
| Success before confirmation | Optimistic green checkmark | Runtime guard blocks |
| Error for emphasis | Red "limited time" text | ESLint error |

---

## §4. Animation Constraints

### 4.1 Animation Authority

Animations may **never**:
- Imply state changes that haven't occurred
- Play without server-confirmed trigger
- Create false urgency
- Manipulate user decisions

Animations may:
- Acknowledge confirmed state changes
- Provide feedback for user actions
- Guide attention appropriately
- Enhance comprehension

### 4.2 Forbidden Animation Patterns

| Pattern | Why Forbidden | Alternative |
|---------|---------------|-------------|
| **Confetti** | Casino psychology, dopamine manipulation | Subtle glow or pulse |
| **Infinite loops** | Attention hijacking | Single-play with natural end |
| **Randomized motion** | Unpredictable = untrustworthy | Deterministic easing |
| **Shake/vibrate** | Aggressive, anxiety-inducing | Color change or border |
| **Slot machine reveals** | Gambling association | Direct state display |
| **Countdown urgency** | False scarcity manipulation | Static deadline display |

### 4.3 Animation Duration Limits

| Animation Type | Maximum Duration | Notes |
|----------------|------------------|-------|
| Micro-feedback | 150ms | Button press, toggle |
| State transition | 300ms | Screen change, modal |
| Celebration | 2000ms | Level up, badge unlock |
| Loading | Indefinite | But must show progress |

**Rule:** No animation may exceed 2 seconds without user-initiated continuation.

### 4.4 Animation Sequencing

When multiple animations could occur:

1. **Priority order:** Error → Success → Info → Celebration
2. **Queue limit:** Maximum 2 queued animations
3. **Interruption:** Errors interrupt celebrations, never reverse

**Example:**
```
User completes task (celebration queued)
  → Server returns error (error displays immediately)
  → Celebration cancelled (not queued behind error)
```

### 4.5 Celebration Constraints

Celebrations are permitted for:
- Level up (first time only)
- Badge unlock (first time only)
- Trust tier promotion
- Milestone completion (10th task, etc.)

Celebrations are **forbidden** during:
- Active disputes
- Pending payments
- Error states
- Onboarding (before role lock)

**First-Time Rule:** Celebration animations play **exactly once** per achievement per user. Server tracks via `animation_shown_at` field.

### 4.6 Reduced Motion

When user has `prefers-reduced-motion: reduce`:

- All animations become instant state changes
- No exceptions for "important" animations
- Loading spinners become progress bars
- Celebrations become static badges

**Enforcement:** Runtime guard checks system setting before any animation.

---

## §5. Badge Visual System

### 5.1 Tier-Material Binding

Badge visuals are **permanently bound** to trust tiers.

| Tier | Material | Visual Treatment |
|------|----------|------------------|
| ROOKIE | Matte | Flat color, no effects |
| VERIFIED | Metallic | Subtle gradient, soft shine |
| TRUSTED | Holographic | Animated gradient, premium |

**Rule:** A ROOKIE badge may **never** have metallic or holographic treatment, regardless of "design preference."

### 5.2 Badge State Rules

| State | Visual | Animation |
|-------|--------|-----------|
| Locked | Grayscale silhouette | None |
| Unlocked (new) | Full color + glow | Unlock animation (once) |
| Unlocked (seen) | Full color | None |
| Highlighted | Full color + subtle pulse | On hover/focus only |

### 5.3 Badge Permanence

Per ARCHITECTURE.md §5.2, badges cannot be revoked.

**UI implication:** There is no "lost badge" or "revoked badge" visual state. The concept does not exist.

If a badge was granted in error:
- Backend marks it with `revoked_reason`
- UI shows badge with small indicator
- Tooltip explains correction
- Badge remains visible (transparency)

### 5.4 Animation Replay Prevention

Badge unlock animations are controlled server-side:

```
badges.animation_shown_at = NULL  → Animation plays, then client confirms
badges.animation_shown_at = <ts>  → No animation, static display
```

**Flow:**
1. Client fetches badge with `animation_shown_at = NULL`
2. Client plays unlock animation
3. Client calls `confirmBadgeAnimation(badgeId)`
4. Server sets `animation_shown_at = NOW()`
5. Future loads show static badge

This prevents:
- Animation on every app launch
- Animation on multiple devices
- Animation without actual unlock

---

## §5. Copy & Language

### 5.1 Tone Requirements

HustleXP copy is:
- **Clear:** No jargon, no ambiguity
- **Respectful:** No condescension, no shame
- **Honest:** No manipulation, no false urgency
- **Professional:** No slang, no excessive enthusiasm

### 5.2 Forbidden Copy Patterns

| Pattern | Example | Why Forbidden | Alternative |
|---------|---------|---------------|-------------|
| **Shame** | "You haven't completed any tasks yet 😢" | Psychological manipulation | "0 tasks completed" |
| **False urgency** | "Complete NOW before it's gone!" | Manufactured pressure | "Deadline: Jan 15" |
| **Guilt** | "Don't let them down!" | Emotional manipulation | "Task awaiting completion" |
| **Excessive praise** | "AMAZING!!! You're incredible!!!" | Hollow, patronizing | "Task completed" |
| **Vague threats** | "Your account may be affected" | Anxiety without clarity | Specific consequence |
| **Dark patterns** | "Are you sure you want to miss out?" | Manipulation | "Cancel task?" |

### 5.3 Error Message Standards

Error messages must be:
- **Specific:** What failed
- **Actionable:** What user can do
- **Blameless:** No "you did X wrong"

**Bad:**
```
"Error: Invalid input. Please try again."
```

**Good:**
```
"Task price must be at least $5. Current: $3."
```

### 5.4 Confirmation Message Standards

Confirmations must:
- State what happened
- Not over-celebrate
- Include relevant details

**Bad:**
```
"🎉 AWESOME!!! You did it! You're amazing!"
```

**Good:**
```
"Payment sent: $42.50 to @worker_jane"
```

### 5.5 Empty State Standards

Empty states must:
- Acknowledge the empty state clearly
- Provide next action (if applicable)
- Not shame or guilt

**Bad:**
```
"Looks lonely here... 😢 Why not post a task?"
```

**Good:**
```
"No tasks yet. [Post a Task]"
```

---

## §6. Screen-Specific Rules

### 6.1 Screen Context Matrix

| Screen | XP Colors | Money Colors | Celebrations | Disputes Visible |
|--------|-----------|--------------|--------------|------------------|
| Home/Dashboard | ✅ Allowed | ✅ Allowed | ✅ Allowed | ❌ Hidden |
| Task Feed | ❌ Forbidden | ❌ Forbidden | ❌ Forbidden | ❌ Hidden |
| Task Detail | ❌ Forbidden | ✅ Allowed | ❌ Forbidden | ⚠️ If applicable |
| Wallet | ❌ Forbidden | ✅ Required | ❌ Forbidden | ❌ Hidden |
| Profile | ✅ Allowed | ✅ Allowed | ✅ Allowed | ❌ Hidden |
| Dispute | ❌ Forbidden | ✅ Allowed | ❌ Forbidden | ✅ Required |
| Onboarding | ❌ Forbidden | ❌ Forbidden | ❌ Forbidden | ❌ Hidden |

### 6.2 Onboarding Screen Rules

During onboarding (before role lock):
- No XP colors (user hasn't earned anything)
- No money colors (no transactions yet)
- No celebrations (nothing to celebrate)
- No badges (none unlocked)
- Minimal animation (professional tone)

**Rationale:** Onboarding sets expectations. Premature rewards teach users to expect unearned dopamine.

### 6.3 Dispute Screen Rules

During active disputes:
- No celebrations (inappropriate context)
- No XP displays (outcome uncertain)
- Neutral color palette
- Clear, factual copy only
- Evidence displayed without editorializing

### 6.4 Task Feed Rules

Task feed is **neutral territory**:
- No XP colors (tasks aren't XP)
- No success colors (nothing succeeded yet)
- Price displayed in neutral gray
- No urgency indicators
- No "hot" or "trending" manipulation

---

## §7. Accessibility Requirements

### 7.1 Non-Negotiable Standards

| Requirement | Standard | Enforcement |
|-------------|----------|-------------|
| Color contrast | WCAG 2.1 AA (4.5:1 text, 3:1 UI) | Automated testing |
| Touch targets | Minimum 44×44 points | Component constraint |
| Focus indicators | Visible on all interactive elements | Runtime check |
| Screen reader | All content accessible | Manual audit |
| Reduced motion | Respected system-wide | Runtime guard |

### 7.2 Color Independence

Information must **never** be conveyed by color alone.

**Bad:**
```
● Green = Success
● Red = Error
(No other indicator)
```

**Good:**
```
✓ Success (green)
✗ Error (red)
(Icon + color)
```

### 7.3 Animation Alternatives

Every animation must have a non-animated equivalent:

| Animation | Reduced Motion Alternative |
|-----------|---------------------------|
| Loading spinner | Progress bar with percentage |
| Success checkmark animation | Static checkmark |
| Badge unlock | Static badge with "New" label |
| Level up celebration | Static level display |

---

## §8. Enforcement Mechanisms

### 8.1 ESLint Rules

The following custom ESLint rules **must** be implemented:

| Rule | Enforces | Error Level |
|------|----------|-------------|
| `no-xp-color-outside-context` | §3.2 | Error |
| `no-money-color-decorative` | §3.3 | Error |
| `no-success-without-confirmation` | §3.4 | Error |
| `no-forbidden-animation` | §4.2 | Error |
| `max-animation-duration` | §4.3 | Warning |
| `enforce-layer-hierarchy` | §2 | Error |
| `no-poster-gamification` | §2.5 | Error |
| `no-unearned-status` | §2.5 | Error |
| `badge-animation-once` | §2.6 | Error |
| `no-shame-copy` | §6.2 | Error |
| `no-false-urgency` | §6.2 | Error |
| `badge-tier-material-match` | §5.1 | Error |
| `touch-target-minimum` | §8.1 | Error |
| `color-contrast-minimum` | §8.1 | Warning |

### 8.2 Runtime Guards

The following runtime guards **must** be implemented:

| Guard | Enforces | Behavior on Violation |
|-------|----------|----------------------|
| `LayerHierarchyGuard` | §2.7 | Checks role and economic state before rendering Layer 3 |
| `BadgeAnimationGuard` | §2.6 | Prevents repeat badge animations (server flag check) |
| `PosterUIGuard` | §2.5 | Blocks Layer 2 and Layer 3 in Poster UI context |
| `AnimationContextGuard` | §4.5 (no celebration during dispute) | Block animation |
| `ReducedMotionGuard` | §4.6 | Replace with static |
| `FirstTimeAnimationGuard` | §4.5 | Check server flag before animating |
| `ColorContextGuard` | §7.1 | Log warning, allow (soft enforcement) |
| `StateConfirmationGuard` | §1.1 | Block render until server confirms |

### 8.3 Build-Time Checks

| Check | Fails Build If |
|-------|----------------|
| Contrast audit | Any text below 4.5:1 ratio |
| Touch target audit | Any target below 44×44 |
| Copy audit | Forbidden patterns detected |
| Animation audit | Duration exceeds limits |

### 8.4 Violation Tracking

All runtime violations are logged:

```typescript
interface UIViolation {
  type: 'COLOR' | 'ANIMATION' | 'COPY' | 'ACCESSIBILITY';
  rule: string;
  component: string;
  context: object;
  timestamp: Date;
  severity: 'WARNING' | 'ERROR';
}
```

Violations are:
- Logged locally (development)
- Reported to monitoring (production)
- Aggregated for audit (weekly)

---

## §9. State Display Rules

### 9.1 Never Display Unconfirmed State

**Rule:** UI may not display state that the server has not confirmed.

**Bad:**
```javascript
// Optimistic update
setTaskState('COMPLETED');
await api.task.complete(taskId);
```

**Good:**
```javascript
const result = await api.task.complete(taskId);
setTaskState(result.state); // Server-confirmed
```

### 9.2 Loading States

When awaiting server response:
- Show loading indicator (spinner, skeleton)
- Disable interactive elements
- Never show "assumed" state

**Minimum loading time:** 100ms (prevent flash)
**Maximum before timeout UI:** 10s

### 9.3 Error States

When server returns error:
- Display error immediately
- Clear any optimistic state
- Provide retry action (if applicable)
- Log violation if optimistic state was shown

### 9.4 Stale State Indicators

If data may be stale (offline, cached):
- Show subtle "Last updated: X" indicator
- Disable actions that require fresh state
- Provide manual refresh action

---

## §10. Component Behavioral Constraints

### 10.1 Buttons

| Constraint | Requirement |
|------------|-------------|
| Minimum size | 44×44 points |
| Disabled state | Visually distinct, non-interactive |
| Loading state | Spinner replaces text, remains same size |
| Success state | Only after server confirmation |
| Double-tap prevention | Disabled during request |

### 10.2 Forms

| Constraint | Requirement |
|------------|-------------|
| Validation | Show errors inline, after blur |
| Submission | Disable form during request |
| Error recovery | Preserve valid input on error |
| Success | Clear form only after confirmation |

### 10.3 Lists

| Constraint | Requirement |
|------------|-------------|
| Empty state | Always show message, never blank |
| Loading | Show skeleton, not spinner |
| Error | Show error with retry |
| Pagination | Load more, never infinite scroll |

### 10.4 Modals

| Constraint | Requirement |
|------------|-------------|
| Dismissal | Always provide close action |
| Confirmation | Require explicit action, never auto-dismiss |
| Backdrop | Tap to dismiss (unless confirmation required) |
| Focus trap | Focus stays within modal |

---

## §11. Cross-Reference Matrix

| UI_SPEC Section | PRODUCT_SPEC | ARCHITECTURE | ONBOARDING_SPEC | schema.sql |
|-----------------|--------------|--------------|-----------------|------------|
| §2 Layered Influence Hierarchy | — | §2 (Layer Hierarchy) | — | — |
| §3 Color Authority | §5 (XP) | §3 (XP Authority) | — | — |
| §4 Animation | — | §2.5 (Layer 5) | §13.4 (First XP) | — |
| §5 Badges | §5.4 | §5 (Badge Authority) | — | L464 |
| §6 Copy | — | — | §12 (Divergent) | — |
| §7 Screen Rules | §3, §4, §7 | — | §12, §13 | — |
| §8 Accessibility | — | — | — | — |
| §9 Enforcement | — | §9 (Invariants) | §0.1 (ONB-*) | — |
| §10 State Display | — | §1.2 (Authority) | — | — |
| §11 Component Constraints | — | — | — | — |
| §13 Onboarding | — | §2 (Layer Hierarchy) | §12-15 | — |
| §14 Live Mode | §7.2 | — | — | — |
| §15 Money Timeline | §6.2 | — | — | escrows, tasks |
| §16 Failure Recovery | §4.3 | — | — | disputes, proofs |
| §17 Session Forecast | §6.3 | AI_INFRASTRUCTURE §3 | — | users, tasks |
| §18 Private Percentile | §5.5 | — | — | users, tasks |
| §19 Poster Reputation | §4.5 | — | — | poster_ratings |
| §20 Pause State | §11 | — | — | users (account_status) |

---

## §12. Onboarding Visual Rules

### 12.1 Constitutional Constraints

Onboarding visuals are governed by ONBOARDING_SPEC.md §0.1 invariants:

| Invariant | UI Implication |
|-----------|----------------|
| **ONB-2** | Zero rewards during onboarding |
| **ONB-3** | Posters never see gamification |
| **ONB-4** | Hustlers see locked gamification until first RELEASED |
| **ONB-5** | First XP celebration is single-use |

### 12.2 Role-Gated UI Elements

**Poster Dashboard (ONB-3 Enforcement):**

| Element | Visibility |
|---------|------------|
| XP counter | ❌ NEVER |
| Level indicator | ❌ NEVER |
| Streak counter | ❌ NEVER |
| Badge display | ❌ NEVER |
| Progress bars (gamification) | ❌ NEVER |

**Hustler Dashboard Pre-Unlock (ONB-4 Enforcement):**

| Element | State |
|---------|-------|
| XP counter | Visible, "0 XP", static |
| Level indicator | "Level 1 • Locked" |
| Streak counter | "Inactive" |
| Badges | Greyed silhouettes |
| Progress bar | Empty, no fill |
| "Unlocks after first task" | Visible label |

**Hustler Dashboard Post-Unlock:**

| Element | State |
|---------|-------|
| XP counter | Active, animated on change |
| Level indicator | Active, progress shown |
| Streak counter | Active, fire/glow if active |
| Badges | Full color when earned |
| Progress bar | Filled to current XP |

### 12.3 Onboarding Screen Visual Language

**Phase 0 (Framing Screen):**
- White or neutral surface background
- No brand gradients
- No motion
- No progress indicator
- Single CTA button

**Phase 1 (Calibration):**
- Minimal progress indicator (thin bar)
- ≤150ms transition between questions
- No loading spinners
- No "you're doing great" feedback

**Phase 3 (Authority Confirmation):**
- No animation
- No celebration
- No positive reinforcement copy
- Role displayed in large text
- Equal visual weight for Continue/Adjust

### 12.4 First XP Celebration (ONB-5 Enforcement)

**Triggers when:**
- `xp_first_celebration_shown_at IS NULL`
- AND first XP awarded
- AND user role = 'worker' OR 'dual'

**Visual Sequence:**

| Time | Element |
|------|---------|
| 0-300ms | XP number fade in + scale 1.0→1.1→1.0 |
| 300-800ms | Progress bar linear fill |
| 800-1200ms | "First Task Complete!" fade in |
| 1200-1800ms | Badge unlock (if earned) |
| 1800-2000ms | Settle to static |

**Constraints:**
- No confetti (M2 forbidden)
- No sound
- No shake/vibrate
- Server-tracked: `xp_first_celebration_shown_at`
- Reduced motion: All instant, no animation

### 12.5 ESLint Rule: `no-gamification-for-poster`

```javascript
// Rule: Gamification UI components forbidden in poster context
// Error: "Gamification elements cannot render for poster role (ONB-3)"

// FORBIDDEN in poster context:
<XPCounter />
<LevelBadge />
<StreakIndicator />
<ProgressBar variant="xp" />
<BadgeGrid />

// ALLOWED in poster context:
<TaskList />
<PaymentHistory />
<WalletBalance />
<ReviewQueue />
```

### 12.6 ESLint Rule: `no-animated-gamification-pre-unlock`

```javascript
// Rule: Gamification animations forbidden before first RELEASED escrow
// Error: "Cannot animate gamification before first task completion (ONB-4)"

// Context check:
const hasCompletedFirstTask = user.xp_first_celebration_shown_at !== null;

// FORBIDDEN if !hasCompletedFirstTask:
<XPCounter animated />
<ProgressBar animated />
<BadgeUnlock animated />

// ALLOWED if !hasCompletedFirstTask:
<XPCounter static value={0} />
<ProgressBar static value={0} locked />
<BadgeGrid locked />
```

---

## §13. Live Mode UI Rules

Live Mode requires distinct visual treatment to communicate real-time state without creating panic or exploitation.

### 13.1 Mode Indicator Colors

| Token | Value | Usage |
|-------|-------|-------|
| `LIVE_INDICATOR` | `#EF4444` (Red-500) | Live badge, active broadcast |
| `STANDARD_INDICATOR` | `#6B7280` (Gray-500) | Standard mode, neutral |
| `LIVE_ACTIVE` | `#22C55E` (Green-500) | Hustler Live Mode active |
| `LIVE_COOLDOWN` | `#F59E0B` (Amber-500) | Hustler in cooldown |

### 13.2 Live Task Card Rules

```
┌─────────────────────────────────────────────────────────┐
│  🔴 LIVE                    ← Red badge, top-left       │
├─────────────────────────────────────────────────────────┤
│  Task title                                             │
│  Poster name • VERIFIED                                 │
│                                                         │
│  💰 $35.00 (you receive ~$29.75)  ← Clear breakdown    │
│  📍 1.2 miles away                ← Distance visible   │
│  ✅ Escrow: FUNDED               ← Trust signal        │
│                                                         │
│  [ Accept Task ]                                        │
└─────────────────────────────────────────────────────────┘
```

**REQUIRED:**
- Red "🔴 LIVE" badge in top-left
- Escrow state always visible
- Distance always visible
- Clear price breakdown (poster pays / hustler receives)

**FORBIDDEN:**
- Countdown timers (creates panic)
- Urgency copy ("Act now!", "Limited time!", "Hurry!")
- Pulsing or flashing animations
- Sound effects beyond system default

### 13.3 Hustler Live Mode Toggle

The toggle must be **prominent**, not buried in settings.

```
┌─────────────────────────────────────────────────────────┐
│  LIVE MODE                                              │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  [ ● ACTIVE ]   ← Green when active                    │
│                                                         │
│  🟢 Actively available                                  │
│  Session: 47 min • Tasks: 2 • Earned: $52              │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

**REQUIRED:**
- Toggle visible on home screen or persistent header
- Session stats visible when active
- Cooldown countdown visible when in cooldown
- State change requires confirmation tap

**FORBIDDEN:**
- Auto-enable on app open
- Hidden toggle (must be prominent)
- Ambiguous state (always clear ON/OFF/COOLDOWN)

### 13.4 Poster Live Task Confirmation

When a hustler accepts:

```
┌─────────────────────────────────────────────────────────┐
│  🟢 HUSTLER ON THE WAY                                  │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  Marcus                                                 │
│  ⭐ VERIFIED • 47 tasks completed                       │
│                                                         │
│  ETA: ~12 minutes                                       │
│  Distance: 1.2 miles                                    │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

**This is the screenshot moment.**

**REQUIRED:**
- Green status indicator
- Hustler name and trust tier
- ETA (not "searching...")
- Certainty, not animation

**FORBIDDEN:**
- Confetti or celebration
- Animation spam
- Fake "searching" states

### 13.5 Live Mode Notification Rules

Notifications are **state signals**, not advertisements.

**Format:**
```
LIVE TASK nearby
$35 • 1.2 miles • Escrow funded
```

**REQUIRED:**
- Price (hustler take-home)
- Distance
- Escrow confirmation

**FORBIDDEN:**
- Urgency language ("Act now!", "Don't miss out!")
- Custom sound effects
- Custom vibration patterns
- Notification spam (max 1 per task)

### 13.6 Live Mode Session Summary

After session ends:

```
┌─────────────────────────────────────────────────────────┐
│  Session Complete                                       │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  2 tasks • $52 earned • 1.5 hours                      │
│                                                         │
│  Live Mode performance: ⭐ Excellent                    │
│                                                         │
│  [ Share ]  [ View Details ]                           │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

**This is shareable because:**
- Concrete earnings
- Time efficiency visible
- Skill validation (performance rating)

### 13.7 ESLint Rule: `no-urgency-copy-live-mode`

```javascript
// Rule: Urgency copy forbidden in Live Mode contexts
// Error: "Urgency language violates Live Mode UI rules (§13.2)"

// FORBIDDEN strings in Live Mode UI:
const FORBIDDEN_LIVE_COPY = [
  'Act now',
  'Hurry',
  'Limited time',
  'Don\'t miss',
  'Last chance',
  'Expires in',
  'Only X left',
  'ASAP',
  'Urgent',
  'Rush'
];

// ALLOWED:
'LIVE TASK nearby'
'Escrow funded'
'ETA: ~12 minutes'
```

---

## §14. Money Timeline (Financial Legibility)

The Money Timeline transforms HustleXP from a gig app into a **financial planning tool**.

### 14.1 Core Principle

Users don't churn because of UX. They churn because they feel **financially blind**.

The Money Timeline answers:
- What money do I have **now**?
- What money is **coming**?
- What money is **blocked**?

### 14.2 Money Timeline UI

```
┌─────────────────────────────────────────────────────────┐
│  YOUR MONEY                                             │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  AVAILABLE NOW                                          │
│  $127.50                                                │
│  [ Transfer to Bank ]                                   │
│                                                         │
│  ─────────────────────────────────────────────────────  │
│                                                         │
│  TODAY                                                  │
│  + $21.25   Couch move — Released 2:34 PM              │
│  + $15.00   Grocery pickup — Released 11:20 AM         │
│                                                         │
│  COMING SOON                                            │
│  + $40.00   Deep cleaning — In escrow (task active)    │
│  + $25.00   Package delivery — In escrow (proof sent)  │
│                                                         │
│  BLOCKED                                                │
│  ⚠️ $15.00   Furniture assembly — Under review          │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### 14.3 Timeline Categories

| Category | Meaning | Color | Criteria |
|----------|---------|-------|----------|
| **AVAILABLE NOW** | Withdrawable | Green | `escrow.state = RELEASED` AND transferred |
| **TODAY** | Recent releases | Green | Released in last 24h |
| **COMING SOON** | Earned not released | Amber | `escrow.state = FUNDED` AND task in progress |
| **BLOCKED** | Frozen in dispute | Red | `escrow.state = LOCKED_DISPUTE` |

### 14.4 Money Timeline Invariants

| ID | Invariant | Enforcement |
|----|-----------|-------------|
| **MONEY-1** | Timeline reflects actual escrow states | DB query |
| **MONEY-2** | No charts, no graphs, no gambling visuals | UI review |
| **MONEY-3** | Time + certainty only | UI review |
| **MONEY-4** | COMING SOON shows expected release context | Backend |

### 14.5 Forbidden Money UI Patterns

```javascript
const FORBIDDEN_MONEY_UI = [
  // Gambling visuals
  'Spin', 'Jackpot', 'Bonus', 'Lucky', 'Win',
  
  // Charts that obscure clarity
  'Pie chart', 'Line graph', 'Bar chart',
  
  // Vague language
  'Pending', 'Processing', 'Soon',
  
  // Over-optimism
  'Potential earnings', 'Could earn', 'Up to'
];
```

---

## §15. Failure Recovery UX

When things go wrong, users need **explanation, not punishment**.

### 15.1 Core Principle

Every negative outcome has:
1. Clear explanation of what happened
2. Concrete impact (if any)
3. Specific next step
4. **No shame language**

### 15.2 Failure Screen Template

```
┌─────────────────────────────────────────────────────────┐
│  [NEUTRAL HEADER]                                       │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  WHAT HAPPENED                                          │
│  [Clear, factual explanation]                           │
│                                                         │
│  IMPACT                                                 │
│  • [Specific consequence 1]                             │
│  • [Specific consequence 2]                             │
│                                                         │
│  WHAT YOU CAN DO                                        │
│  [ Primary Action ]                                     │
│  [ Secondary Action ]                                   │
│                                                         │
│  [Recovery context / encouragement]                     │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### 15.3 Task Failed (Hustler View)

```
┌─────────────────────────────────────────────────────────┐
│  This task didn't complete successfully                 │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  WHAT HAPPENED                                          │
│  The poster reported the task wasn't completed          │
│  as described.                                          │
│                                                         │
│  IMPACT                                                 │
│  • No payment for this task                             │
│  • Trust score: No change (first occurrence)            │
│                                                         │
│  WHAT YOU CAN DO                                        │
│  [ Dispute This Decision ]                              │
│  [ Accept and Move On ]                                 │
│                                                         │
│  Your next completed task restores normal standing.     │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### 15.4 Trust Tier Change

```
┌─────────────────────────────────────────────────────────┐
│  Your trust tier has changed                            │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  VERIFIED → STANDARD                                    │
│                                                         │
│  WHY THIS HAPPENED                                      │
│  2 tasks weren't completed successfully in the          │
│  past 30 days.                                          │
│                                                         │
│  WHAT THIS MEANS                                        │
│  • Some task types may be less visible to you           │
│  • Your earnings potential is unchanged                 │
│                                                         │
│  HOW TO RECOVER                                         │
│  Complete 5 tasks successfully to restore VERIFIED.     │
│                                                         │
│  Progress: 0 / 5                                        │
│  ○ ○ ○ ○ ○                                              │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### 15.5 Dispute Lost

```
┌─────────────────────────────────────────────────────────┐
│  Dispute resolved                                       │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  DECISION: In favor of poster                           │
│                                                         │
│  WHAT THIS MEANS                                        │
│  • Payment of $25.00 refunded to poster                 │
│  • This counts as an incomplete task                    │
│                                                         │
│  WHY THIS DECISION                                      │
│  The submitted proof didn't match the task              │
│  requirements. [View Details]                           │
│                                                         │
│  MOVING FORWARD                                         │
│  This is one outcome. Your overall record still         │
│  shows 47 successful completions.                       │
│                                                         │
│  [ Got It ]                                             │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### 15.6 Forbidden Failure Copy

```javascript
const FORBIDDEN_FAILURE_COPY = [
  // Shame language
  'You failed', 'Your fault', 'Mistake',
  
  // Punitive language
  'Penalty', 'Punished', 'Strike', 'Warning',
  'Demotion', 'Banned',
  
  // Vague impact
  'Consequences', 'Action taken', 'Noted',
  
  // Passive aggressive
  'Unfortunately', 'Regrettably', 'We had to'
];

const REQUIRED_FAILURE_ELEMENTS = [
  'WHAT HAPPENED',      // Always explain
  'IMPACT',             // Always specify
  'WHAT YOU CAN DO',    // Always provide action
  'Recovery path'       // Always show hope
];
```

### 15.7 Failure Recovery Invariants

| ID | Invariant | Enforcement |
|----|-----------|-------------|
| **FAIL-1** | Every negative outcome has explanation | UI review |
| **FAIL-2** | Every explanation has next step | UI review |
| **FAIL-3** | No shame language | Copy review |
| **FAIL-4** | Recovery path always visible | UI component |
| **FAIL-5** | Impact is specific, not vague | Copy review |

---

## §16. Session Forecast (AI Earning Predictability)

Hustlers earn and progress, but they don't **predict**. Best gig money apps answer: "If I open this app for 90 minutes, what happens?"

### 16.1 Core Principle

AI predicts earning potential based on:
- Current location
- Historical performance
- Current demand
- Time of day

**AI authority: A1 (Advisory)** — forecasts are read-only, cannot make decisions.

### 16.2 Session Forecast UI

```
┌─────────────────────────────────────────────────────────┐
│  🧠 SESSION FORECAST                                    │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  Based on your location & history:                      │
│                                                         │
│  EXPECTED EARNINGS                                      │
│  $35 – $55 in the next 90 minutes                      │
│                                                         │
│  BEST OPPORTUNITIES                                     │
│  • Delivery tasks (high demand nearby)                  │
│  • Moving help ($40+ tasks available)                   │
│                                                         │
│  CONDITIONS                                             │
│  🟢 Good — 12 active posters within 3 miles            │
│                                                         │
│  This is an estimate, not a guarantee.                  │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### 16.3 Forecast Rules

| Rule | Description |
|------|-------------|
| **Forecasts are ranges** | "$35–$55" not "$45" (always show range) |
| **No guarantees** | Always include disclaimer ("This is an estimate, not a guarantee.") |
| **Accuracy improves** | More history = better predictions |
| **AI is advisory** | Cannot auto-accept tasks, cannot change task visibility |

### 16.4 Forecast Display Rules

**REQUIRED:**
- Always show earnings as a range (low-high)
- Always include disclaimer
- Show confidence level (LOW, MEDIUM, HIGH)
- Show best opportunities (task categories)
- Show conditions (POOR, FAIR, GOOD, EXCELLENT)

**FORBIDDEN:**
- Exact dollar amounts without ranges ("You will earn $45")
- Guarantees or promises ("Guaranteed earnings", "You will definitely...")
- Auto-accept suggestions ("Accept these tasks now!")
- Manipulation ("Limited time forecast", "Act now!")

### 16.5 Forecast Invariants

| ID | Invariant | Enforcement |
|----|-----------|-------------|
| **FORECAST-1** | Forecasts are always ranges, never exact numbers | UI component |
| **FORECAST-2** | Disclaimers required on all forecasts | Copy review |
| **FORECAST-3** | AI cannot auto-accept tasks based on forecast | Backend guard |
| **FORECAST-4** | Forecasts are read-only (no user input) | UI component |
| **FORECAST-5** | No guarantees or promises in forecast copy | Copy review |

### 16.6 Session Forecast Component Rules

**Display Context:**
- ✅ HomeScreen (Hustler view, post-unlock)
- ✅ Task Feed (optional, can be collapsed)
- ❌ Task Detail (not relevant)
- ❌ Wallet (financial context, not forecast)

**Color Rules:**
- Use INFO color (#3B82F6) for forecast header
- Use neutral gray for earnings range (not XP or Money colors)
- Use status colors for conditions (🟢 GOOD, 🟡 FAIR, 🔴 POOR)

### 16.7 Forbidden Forecast Patterns

```javascript
const FORBIDDEN_FORECAST_COPY = [
  // Guarantees
  'Guaranteed', 'Definitely', 'Will earn', 'Promise',
  
  // Exact amounts
  'You will earn $45', 'Exact earnings: $50',
  
  // Auto-suggestions
  'Accept now', 'Take these tasks', 'Auto-accept',
  
  // Manipulation
  'Limited time', 'Act now', 'Hurry', 'Don't miss'
];

const REQUIRED_FORECAST_ELEMENTS = [
  'Earnings range',     // Always show low-high
  'Disclaimer',         // Always include
  'Best opportunities', // Task categories
  'Conditions',         // Demand level
  'Confidence level'    // LOW, MEDIUM, HIGH
];
```

---

## §17. Private Percentile Status

Leaderboards destroy gig platforms through toxic competition. But **status** still matters for motivation.

### 17.1 Core Principle

Show users their relative standing **without** public ranks, usernames, or competition.

**Private only** — never visible to other users.

### 17.2 Private Percentile UI

```
┌─────────────────────────────────────────────────────────┐
│  YOUR STANDING (Private)                                │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  RELIABILITY                                            │
│  Top 12% this week                                      │
│  ████████████░░░░░░░░                                   │
│                                                         │
│  RESPONSE TIME                                          │
│  Top 25% this week                                      │
│  ████████░░░░░░░░░░░░                                   │
│                                                         │
│  COMPLETION RATE                                        │
│  Top 8% all time                                        │
│  █████████████░░░░░░░                                   │
│                                                         │
│  Only you can see this.                                 │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### 17.3 Private Percentile Rules

| Rule | Description |
|------|-------------|
| **No usernames** | Never compare to named users ("You're better than @username") |
| **No rankings** | Never show "You are #47" or "Rank: 47th" |
| **No competition** | Never "Beat X to unlock Y" or "Compete with others" |
| **Only self-relative** | Compare to your own history, not others |
| **Private only** | Never visible to other users (API guard) |

### 17.4 Percentile Metrics

| Metric | Calculation | Shown To |
|--------|-------------|----------|
| **Reliability** | Tasks completed / Tasks accepted | Hustler only |
| **Response Time** | Avg time to accept tasks | Hustler only |
| **Completion Rate** | Successful / Total tasks | Hustler only |
| **Earnings Velocity** | Earnings / Active hours | Hustler only |

**Display Format:**
- "Top X%" (never "Bottom X%" or "Xth percentile")
- Progress bar visualization (visual only, no numbers on bar)
- "this week", "this month", "all time" context

### 17.5 Percentile Invariants

| ID | Invariant | Enforcement |
|----|-----------|-------------|
| **PERC-1** | Percentiles are never public | API guard (403 if not own user) |
| **PERC-2** | No comparison to named users | UI review |
| **PERC-3** | Percentiles update weekly max | Backend job (not real-time) |
| **PERC-4** | Minimum 100 users for percentile | Statistical validity (backend) |
| **PERC-5** | No rankings or position numbers | UI component |

### 17.6 Private Percentile Display Rules

**Display Context:**
- ✅ ProfileScreen (Hustler view, post-unlock)
- ✅ HomeScreen (optional, can be collapsed)
- ❌ Task Feed (not relevant)
- ❌ Task Detail (not relevant)
- ❌ Any public view (never visible to others)

**Color Rules:**
- Use XP_PRIMARY (#10B981) for progress bars (this is XP-related status)
- Use neutral gray for text labels
- Use SUCCESS color for "Top X%" text when X < 25 (high percentile)

**Forbidden:**
- Leaderboard-style lists
- Comparison to other users
- Competitive language
- Public visibility

### 17.7 Forbidden Percentile Patterns

```javascript
const FORBIDDEN_PERCENTILE_COPY = [
  // Rankings
  'You are #47', 'Rank: 47th', 'Position: 47',
  
  // Comparisons
  'Better than @username', 'Top of your class', 'Beat others',
  
  // Competition
  'Compete', 'Challenge', 'Leaderboard', 'Tournament',
  
  // Public visibility
  'Visible to others', 'Public ranking', 'Your rank'
];

const REQUIRED_PERCENTILE_ELEMENTS = [
  'Top X% format',       // Always "Top X%", never "Bottom X%"
  'Privacy notice',      // "Only you can see this"
  'Time context',        // "this week", "this month", "all time"
  'Progress bar',        // Visual representation (no numbers on bar)
  'Self-relative only'   // Compare to own history, not others
];
```

---

## §18. Poster Quality Filtering (Hustler-Only)

Escrow protects hustlers from non-payment. But not yet from **bad posters** who dispute unfairly, communicate poorly, or create unclear tasks.

### 18.1 Core Principle

Surface poster history **only to hustlers**, not to posters themselves.

**Never show to posters** — would change their behavior artificially.

### 18.2 Poster Reputation UI (Task Card)

```
┌─────────────────────────────────────────────────────────┐
│  Deep cleaning needed                                   │
│  Sarah K. • VERIFIED                                    │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  💰 $45.00 (you receive ~$38.25)                        │
│  📍 2.1 miles away                                      │
│  ✅ Escrow: FUNDED                                      │
│                                                         │
│  POSTER HISTORY                                         │
│  • 12 tasks posted                                      │
│  • 0 disputes                                           │
│  • Avg response: 2h                                     │
│  ⭐ Hustlers rate: Excellent                            │
│                                                         │
│  [ Accept Task ]                                        │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### 18.3 Poster Reputation Metrics

| Metric | Calculation | Visible To |
|--------|-------------|------------|
| **Tasks Posted** | COUNT(tasks) where poster_id = user.id | Hustlers only |
| **Dispute Rate** | Disputes / Tasks (rolling 90-day) | Hustlers only |
| **Avg Response Time** | Avg time to respond to proofs (hours) | Hustlers only |
| **Hustler Rating** | Avg rating from workers (GREAT, OKAY, DIFFICULT) | Hustlers only |
| **Repeat Hire Rate** | Rehired same hustler % | Hustlers only |

**Display Format:**
- Factual, neutral language ("12 tasks posted", not "12 successful tasks")
- Hustler rating shown as emoji + text ("⭐ Excellent", "😐 Okay", "😕 Difficult")
- No subjective labels ("bad poster", "problematic", etc.)

### 18.4 Poster Reputation Rules

| Rule | Rationale |
|------|-----------|
| **Never show to posters** | Would change their behavior artificially (gaming the system) |
| **Minimum 5 tasks** | Statistical validity (don't show if < 5 tasks) |
| **Rolling 90-day window** | Recent behavior matters more than lifetime |
| **No "bad poster" label** | Just facts, hustler decides |
| **Hustler-only visibility** | API guard (403 if poster tries to view own reputation) |

### 18.5 Poster Rating System (Post-Task)

After task completion (COMPLETED state), hustler can rate poster:

```
┌─────────────────────────────────────────────────────────┐
│  How was working with Sarah?                            │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  [ 😊 Great ]  [ 😐 Okay ]  [ 😕 Difficult ]          │
│                                                         │
│  Optional: What could be better?                        │
│  [ ] Clearer task description                           │
│  [ ] Faster communication                               │
│  [ ] More reasonable expectations                       │
│  [ ] Better task location                               │
│                                                         │
│  [ Submit Rating ]                                      │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

**Rating Options:**
- **😊 Great** — Smooth experience, would work with again
- **😐 Okay** — Acceptable, no major issues
- **😕 Difficult** — Issues with communication, clarity, or expectations

**Feedback Flags (Optional):**
- Clearer task description
- Faster communication
- More reasonable expectations
- Better task location
- Fair payment
- Respectful interaction

**Rating Rules:**
- Only after task COMPLETED (not during dispute)
- 7-day window (auto-rate as "Okay" after 7 days if no rating)
- One rating per task per hustler
- Poster never sees individual ratings (only aggregated reputation)

### 18.6 Poster Reputation Invariants

| ID | Invariant | Enforcement |
|----|-----------|-------------|
| **POSTER-1** | Poster reputation never visible to posters | API guard (403) |
| **POSTER-2** | Minimum 5 tasks required for reputation display | Backend query |
| **POSTER-3** | Only rolling 90-day window (no lifetime stats) | Backend query |
| **POSTER-4** | Facts only, no subjective labels | UI component |
| **POSTER-5** | Poster ratings are aggregated, never individual | Backend aggregation |
| **POSTER-6** | Rating only available after task COMPLETED | State machine guard |

### 18.7 Poster Reputation Display Rules

**Display Context:**
- ✅ Task Card (Task Feed, Search results)
- ✅ Task Detail Screen (before accepting)
- ❌ ProfileScreen (posters never see own reputation)
- ❌ Public views (never visible to anyone except hustlers viewing tasks)

**Color Rules:**
- Use INFO color (#3B82F6) for "POSTER HISTORY" header
- Use neutral gray for metrics (tasks posted, disputes, response time)
- Use status colors for hustler rating:
  - 😊 Great → SUCCESS (#10B981)
  - 😐 Okay → INFO (#3B82F6)
  - 😕 Difficult → WARNING (#F59E0B)

**Forbidden:**
- Subjective labels ("bad poster", "problematic", "avoid this poster")
- Lifetime stats (only 90-day rolling window)
- Individual ratings (only aggregated)
- Public visibility

### 18.8 Forbidden Poster Reputation Patterns

```javascript
const FORBIDDEN_POSTER_COPY = [
  // Subjective labels
  'Bad poster', 'Problematic', 'Avoid', 'Unreliable',
  
  // Lifetime stats
  'All-time stats', 'Lifetime reputation', 'Total history',
  
  // Individual ratings
  'User X rated this poster', 'Individual feedback',
  
  // Public visibility
  'Public reputation', 'Visible to all'
];

const REQUIRED_POSTER_ELEMENTS = [
  'Tasks posted count',     // Always show if >= 5 tasks
  'Dispute rate',           // Always show (0 disputes is good info)
  'Avg response time',      // Always show
  'Hustler rating',         // Aggregated (Great/Okay/Difficult)
  '90-day window notice'    // "Based on last 90 days" (optional, subtle)
];
```

---

## §19. Exit With Dignity (Pause State)

Most gig apps trap users psychologically through streak anxiety, FOMO notifications, and punitive decay. This destroys trust and increases churn.

### 19.1 Core Principle

Let users leave **cleanly** without losing progress. No psychological traps.

**Your progress is safe** — XP, levels, trust tier, and badges are protected.

### 19.2 Pause State UI

```
┌─────────────────────────────────────────────────────────┐
│  Taking a break?                                        │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  Your progress is safe.                                 │
│                                                         │
│  WHAT'S PROTECTED                                       │
│  ✅ XP total: 1,247 (no decay)                         │
│  ✅ Level: 5 (locked in)                               │
│  ✅ Trust tier: VERIFIED (preserved)                    │
│  ✅ Badges: 12 earned (permanent)                       │
│                                                         │
│  WHAT PAUSES                                            │
│  ⏸️  Current streak: 14 days                            │
│      Grace period: 14 days from now                     │
│                                                         │
│  Resume anytime to continue where you left off.         │
│                                                         │
│  [ Pause My Account ]  [ Stay Active ]                  │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### 19.3 Pause State Rules

| Aspect | During Pause | After Resume |
|--------|--------------|--------------|
| **XP** | No decay | Intact |
| **Level** | Frozen | Intact |
| **Trust Tier** | Frozen | Intact |
| **Badges** | Permanent (no change) | Intact |
| **Streak** | Grace period (configurable) | Continues if resumed in time |
| **Task Visibility** | Hidden from task feed | Restored |
| **Notifications** | None | Restored |

### 19.4 Pause Duration Tiers

| Duration | Streak Grace | Trust Protection |
|----------|--------------|------------------|
| **Up to 14 days** | Full streak preserved | Full protection |
| **15-30 days** | Streak resets to 1 | Trust tier preserved |
| **31-90 days** | Streak resets to 1 | Trust tier preserved |
| **90+ days** | Streak resets to 1 | Trust tier drops one level (max) |

**Note:** Even after 90+ days, XP, Level, and Badges remain intact. Only streak and trust tier are affected.

### 19.5 Paused Account Screen

When account is paused, show:

```
┌─────────────────────────────────────────────────────────┐
│  Account Paused                                         │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  Your account is on pause.                              │
│                                                         │
│  PROTECTED PROGRESS                                     │
│  ✅ XP: 1,247                                           │
│  ✅ Level: 5                                            │
│  ✅ Trust Tier: VERIFIED                                │
│  ✅ Badges: 12                                          │
│                                                         │
│  PAUSED SINCE                                           │
│  January 8, 2025 (3 days ago)                          │
│                                                         │
│  STREAK STATUS                                          │
│  ⏸️  Streak: 14 days (preserved until Jan 22)          │
│                                                         │
│  [ Resume Account ]                                     │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

**Resume Rules:**
- Resume is instant (no "reactivation" delay)
- All protected progress restored immediately
- Task visibility restored
- Notifications restored
- Streak continues if within grace period

### 19.6 Pause Invariants

| ID | Invariant | Enforcement |
|----|-----------|-------------|
| **PAUSE-1** | XP never decays during pause | Backend logic (no XP decay job runs for paused users) |
| **PAUSE-2** | Badges are permanent regardless | DB constraint (badges table has no expiry) |
| **PAUSE-3** | Pause is always available | UI always shows option (Settings or Profile) |
| **PAUSE-4** | Resume is instant | No "reactivation" delay, immediate restoration |
| **PAUSE-5** | No punitive notifications | Notification service skips paused users |
| **PAUSE-6** | Task visibility hidden during pause | Backend query filter (WHERE account_status != 'PAUSED') |

### 19.7 Pause State Display Rules

**Display Context:**
- ✅ ProfileScreen (Pause button, always visible)
- ✅ SettingsScreen (Pause option)
- ✅ PausedAccountScreen (when paused)
- ❌ HomeScreen (when paused, show paused screen instead)
- ❌ Task Feed (hidden when paused)

**Color Rules:**
- Use SUCCESS color (#10B981) for "✅ Protected" items (XP, Level, Trust Tier, Badges)
- Use INFO color (#3B82F6) for "⏸️ Paused" items (Streak)
- Use neutral gray for paused account status
- Use primary color for action buttons ("Resume Account", "Pause My Account")

**Forbidden:**
- Urgency language ("Act now to preserve your streak!", "Hurry!")
- FOMO notifications ("You're missing out on tasks!")
- Punitive language ("Your streak will expire", "Progress will decay")
- Shame language ("You're taking a break", "You're inactive")

### 19.8 Forbidden Pause Patterns

```javascript
const FORBIDDEN_PAUSE_COPY = [
  // Urgency
  'Act now', 'Hurry', 'Limited time', 'Expires soon',
  
  // FOMO
  'Missing out', 'Others are earning', 'You're falling behind',
  
  // Punitive
  'Progress will decay', 'Streak will expire', 'Lose your status',
  
  // Shame
  'You're inactive', 'Taking a break', 'Not participating'
];

const REQUIRED_PAUSE_ELEMENTS = [
  'Protected progress list',  // XP, Level, Trust Tier, Badges
  'Paused items list',        // Streak (with grace period)
  'Resume option',            // Always visible and accessible
  'No urgency',               // Calm, supportive language
  'Clear grace periods'       // When streak grace expires
];
```

---

## Amendment History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | Jan 2025 | HustleXP Core | Initial visual contract |
| 1.1.0 | Jan 2025 | HustleXP Core | Added: Onboarding Visual Rules (§12), cross-refs to ONBOARDING_SPEC |
| 1.2.0 | Jan 2025 | HustleXP Core | Added: Live Mode UI Rules (§13), mode indicator colors, notification rules |
| 1.3.0 | Jan 2025 | HustleXP Core | Added: Money Timeline (§14), Failure Recovery UX (§15) |
| 1.4.0 | Jan 2025 | HustleXP Core | Added: Session Forecast (§17), Private Percentile Status (§18), Poster Quality Filtering (§19), Exit With Dignity/Pause State (§20). UI_SPEC now MAX-TIER complete. |
| 1.5.0 | Jan 2025 | HustleXP Core | Added: Layered Influence Hierarchy (§2) — The UI Stack (Apple Glass → Duolingo → COD/Clash Royale). Non-negotiable order enforced with 7 invariants. This is the foundational design philosophy for all UI. |

---

**END OF UI_SPEC v1.5.0 (MAX-TIER + LAYERED HIERARCHY)**
