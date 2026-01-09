# HustleXP UI Specification v1.1.0

**STATUS: CONSTITUTIONAL AUTHORITY**  
**Owner:** HustleXP Core  
**Last Updated:** January 2025  
**Governance:** This document governs all visual expression. Violations are build failures.

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

## §2. Color Authority

### 2.1 Semantic Color Categories

Colors in HustleXP have **meaning**. They are not decorative.

| Category | Semantic Meaning | Usage |
|----------|------------------|-------|
| **XP** | Earned value, progression | XP displays, level indicators, streak counters |
| **MONEY** | Financial state | Escrow status, payment amounts, wallet |
| **STATUS** | System state | Success, warning, error, info |
| **NEUTRAL** | No semantic meaning | Backgrounds, borders, disabled states |

### 2.2 XP Colors

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

### 2.3 Money Colors

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

### 2.4 Status Colors

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

### 2.5 Color Authority Violations

| Violation | Example | Consequence |
|-----------|---------|-------------|
| XP color in non-XP context | Green task card | ESLint error |
| Money color decoratively | Green "Post Task" button | ESLint error |
| Success before confirmation | Optimistic green checkmark | Runtime guard blocks |
| Error for emphasis | Red "limited time" text | ESLint error |

---

## §3. Animation Constraints

### 3.1 Animation Authority

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

### 3.2 Forbidden Animation Patterns

| Pattern | Why Forbidden | Alternative |
|---------|---------------|-------------|
| **Confetti** | Casino psychology, dopamine manipulation | Subtle glow or pulse |
| **Infinite loops** | Attention hijacking | Single-play with natural end |
| **Randomized motion** | Unpredictable = untrustworthy | Deterministic easing |
| **Shake/vibrate** | Aggressive, anxiety-inducing | Color change or border |
| **Slot machine reveals** | Gambling association | Direct state display |
| **Countdown urgency** | False scarcity manipulation | Static deadline display |

### 3.3 Animation Duration Limits

| Animation Type | Maximum Duration | Notes |
|----------------|------------------|-------|
| Micro-feedback | 150ms | Button press, toggle |
| State transition | 300ms | Screen change, modal |
| Celebration | 2000ms | Level up, badge unlock |
| Loading | Indefinite | But must show progress |

**Rule:** No animation may exceed 2 seconds without user-initiated continuation.

### 3.4 Animation Sequencing

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

### 3.5 Celebration Constraints

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

### 3.6 Reduced Motion

When user has `prefers-reduced-motion: reduce`:

- All animations become instant state changes
- No exceptions for "important" animations
- Loading spinners become progress bars
- Celebrations become static badges

**Enforcement:** Runtime guard checks system setting before any animation.

---

## §4. Badge Visual System

### 4.1 Tier-Material Binding

Badge visuals are **permanently bound** to trust tiers.

| Tier | Material | Visual Treatment |
|------|----------|------------------|
| ROOKIE | Matte | Flat color, no effects |
| VERIFIED | Metallic | Subtle gradient, soft shine |
| TRUSTED | Holographic | Animated gradient, premium |

**Rule:** A ROOKIE badge may **never** have metallic or holographic treatment, regardless of "design preference."

### 4.2 Badge State Rules

| State | Visual | Animation |
|-------|--------|-----------|
| Locked | Grayscale silhouette | None |
| Unlocked (new) | Full color + glow | Unlock animation (once) |
| Unlocked (seen) | Full color | None |
| Highlighted | Full color + subtle pulse | On hover/focus only |

### 4.3 Badge Permanence

Per ARCHITECTURE.md §5.2, badges cannot be revoked.

**UI implication:** There is no "lost badge" or "revoked badge" visual state. The concept does not exist.

If a badge was granted in error:
- Backend marks it with `revoked_reason`
- UI shows badge with small indicator
- Tooltip explains correction
- Badge remains visible (transparency)

### 4.4 Animation Replay Prevention

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
| `no-xp-color-outside-context` | §2.2 | Error |
| `no-money-color-decorative` | §2.3 | Error |
| `no-success-without-confirmation` | §2.4 | Error |
| `no-forbidden-animation` | §3.2 | Error |
| `max-animation-duration` | §3.3 | Warning |
| `no-shame-copy` | §5.2 | Error |
| `no-false-urgency` | §5.2 | Error |
| `badge-tier-material-match` | §4.1 | Error |
| `touch-target-minimum` | §7.1 | Error |
| `color-contrast-minimum` | §7.1 | Warning |

### 8.2 Runtime Guards

The following runtime guards **must** be implemented:

| Guard | Enforces | Behavior on Violation |
|-------|----------|----------------------|
| `AnimationContextGuard` | §3.5 (no celebration during dispute) | Block animation |
| `ReducedMotionGuard` | §3.6 | Replace with static |
| `FirstTimeAnimationGuard` | §3.5 | Check server flag before animating |
| `ColorContextGuard` | §6.1 | Log warning, allow (soft enforcement) |
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
| §2 Color Authority | §5 (XP) | §3 (XP Authority) | — | — |
| §3 Animation | — | §2.5 (Layer 5) | §13.4 (First XP) | — |
| §4 Badges | §5.4 | §5 (Badge Authority) | — | L464 |
| §5 Copy | — | — | §12 (Divergent) | — |
| §6 Screen Rules | §3, §4, §7 | — | §12, §13 | — |
| §8 Enforcement | — | §9 (Invariants) | §0.1 (ONB-*) | — |
| §9 State Display | — | §1.2 (Authority) | — | — |
| §12 Onboarding | — | §2 (Layer Hierarchy) | §12-15 | — |

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

## Amendment History

| Version | Date | Author | Summary |
|---------|------|--------|---------|
| 1.0.0 | Jan 2025 | HustleXP Core | Initial visual contract |
| 1.1.0 | Jan 2025 | HustleXP Core | Added: Onboarding Visual Rules (§12), cross-refs to ONBOARDING_SPEC |

---

**END OF UI_SPEC v1.1.0**
