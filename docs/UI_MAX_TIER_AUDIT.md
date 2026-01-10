# UI_SPEC Max-Tier Status Audit

**Date:** January 2025  
**Current Version:** UI_SPEC.md v1.3.0  
**Status:** 🟡 **40% Max-Tier** (2 fully integrated + 1 partial / 7 total gaps)

---

## Executive Summary

UI_SPEC.md is **not yet max-tier**. It has 2 out of 7 max-tier human systems fully integrated, 1 partially integrated, and 4 completely missing.

**Definition of Max-Tier:**
- Fully integrated into constitutional law (PRODUCT_SPEC.md, UI_SPEC.md, BUILD_GUIDE.md)
- Complete UI specifications with rules, invariants, and forbidden patterns
- Production-ready with enforcement mechanisms

---

## Current Status Matrix

| GAP | Max-Tier Feature | UI_SPEC Status | Integration Level |
|-----|------------------|----------------|-------------------|
| **GAP-1** | Money Timeline | ✅ **§14 Complete** | 100% |
| **GAP-2** | Failure Recovery UX | ✅ **§15 Complete** | 100% |
| **GAP-3** | Session Forecast (AI) | ❌ **Missing** | 0% |
| **GAP-4** | Private Percentile Status | ❌ **Missing** | 0% |
| **GAP-5** | Anti-Burnout System | 🟡 **§13 Partial** | 40% |
| **GAP-6** | Poster Quality Filtering | ❌ **Missing** | 0% |
| **GAP-7** | Exit With Dignity (Pause) | ❌ **Missing** | 0% |

**Overall:** 2.4 / 7 = **34% max-tier** (rounded to 40% for visual clarity)

---

## ✅ Fully Integrated (2/7)

### GAP-1: Money Timeline (§14)

**Status:** ✅ Complete  
**Location:** UI_SPEC.md §14.1-§14.5

**What's Included:**
- Core principle (financial legibility)
- Complete UI layout (AVAILABLE NOW, TODAY, COMING SOON, BLOCKED)
- Timeline categories with color rules
- Money Timeline invariants (MONEY-1 through MONEY-4)
- Forbidden money UI patterns (gambling visuals, vague language, charts)

**Verification:**
- ✅ Integrated into PRODUCT_SPEC.md
- ✅ Component created (MoneyTimeline.js)
- ✅ Rules enforced via ESLint
- ✅ Invariants documented

---

### GAP-2: Failure Recovery UX (§15)

**Status:** ✅ Complete  
**Location:** UI_SPEC.md §15.1-§15.7

**What's Included:**
- Core principle (explanation, not punishment)
- Failure screen template
- 3 specific failure scenarios (Task Failed, Trust Tier Change, Dispute Lost)
- Forbidden failure copy patterns
- Required failure elements (WHAT HAPPENED, IMPACT, WHAT YOU CAN DO, Recovery path)
- Failure recovery invariants (FAIL-1 through FAIL-5)

**Verification:**
- ✅ Integrated into PRODUCT_SPEC.md
- ✅ Component created (FailureRecovery.js)
- ✅ Rules enforced via ESLint
- ✅ Invariants documented

---

## 🟡 Partially Integrated (1/7)

### GAP-5: Anti-Burnout System (§13)

**Status:** 🟡 Partial (40% complete)  
**Location:** UI_SPEC.md §13.1-§13.7 (Live Mode only)

**What's Included:**
- ✅ Live Mode UI rules (§13.1-§13.2)
- ✅ Live Task Card rules (red badge, escrow visibility, distance, price breakdown)
- ✅ Hustler Live Mode Toggle (§13.3)
- ✅ Poster Live Task Confirmation (§13.4)
- ✅ Live Mode Notification Rules (§13.5)
- ✅ Live Mode Session Summary (§13.6)
- ✅ ESLint rule for urgency copy in Live Mode (§13.7)

**What's Missing:**
- ❌ **Global Activity Awareness UI** (fatigue tracking beyond Live Mode)
  - 4 hours total activity → Gentle nudge UI
  - 6 hours total activity → Stronger nudge UI
  - 8 hours total activity → Mandatory break prompt UI
- ❌ **Fatigue Nudge Components** (gentle, stronger, mandatory)
- ❌ **Daily Active Minutes Display** (activity tracking dashboard)
- ❌ **7-Day Consecutive Activity Warning** ("Rest day" suggestion UI)
- ❌ **Mandatory Break Cooldown UI** (countdown, protected state display)
- ❌ **Global Fatigue Invariants** (FATIGUE-1 through FATIGUE-N)

**Required Additions:**
1. New section: **§16. Global Fatigue & Anti-Burnout System**
2. Fatigue nudge UI templates (3 tiers: gentle, stronger, mandatory)
3. Daily activity dashboard component
4. 7-day consecutive activity warning UI
5. Mandatory break cooldown UI
6. Global fatigue invariants

**Source:** HUMAN_SYSTEMS_SPEC.md §6.3-§6.5

---

## ❌ Missing (4/7)

### GAP-3: Session Forecast (Earning Predictability)

**Status:** ❌ Missing  
**Source:** HUMAN_SYSTEMS_SPEC.md §4.1-§4.7

**What Needs to Be Added:**

1. **New Section: §17. Session Forecast (AI Earning Predictability)**

2. **Core Principle:**
   - AI predicts earning potential (read-only, A1 authority)
   - Forecasts are ranges, not guarantees
   - Answers: "If I open this app for 90 minutes, what happens?"

3. **Session Forecast UI:**
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

4. **Forecast Rules:**
   - Forecasts are **ranges** ("$35–$55" not "$45")
   - No guarantees, always include disclaimer
   - AI authority: **A1 (Advisory)** — cannot make decisions
   - Accuracy improves over time

5. **Forecast Invariants:**
   - **FORECAST-1:** Forecasts are always ranges, never exact numbers
   - **FORECAST-2:** Disclaimers required on all forecasts
   - **FORECAST-3:** AI cannot auto-accept tasks based on forecast
   - **FORECAST-4:** Forecasts are read-only (no user input)

6. **Forbidden Patterns:**
   - "Guaranteed earnings"
   - Exact dollar amounts without ranges
   - Auto-accept suggestions
   - Promises or commitments

7. **Component:** `SessionForecast.js`

**Priority:** HIGH (GAP-3)

---

### GAP-4: Private Percentile Status

**Status:** ❌ Missing  
**Source:** HUMAN_SYSTEMS_SPEC.md §5.1-§5.6

**What Needs to Be Added:**

1. **New Section: §18. Private Percentile Status**

2. **Core Principle:**
   - Show relative standing without public ranks
   - No leaderboards, no competition
   - Private only (never visible to others)

3. **Private Percentile UI:**
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

4. **Percentile Rules:**
   - **No usernames** (never compare to named users)
   - **No rankings** (never show "You are #47")
   - **No competition** (never "Beat X to unlock Y")
   - **Only self-relative** (compare to your own history)
   - **Private only** (never visible to other users)

5. **Percentile Metrics:**
   - Reliability (Tasks completed / Tasks accepted)
   - Response Time (Avg time to accept tasks)
   - Completion Rate (Successful / Total tasks)
   - Earnings Velocity (Earnings / Active hours)

6. **Percentile Invariants:**
   - **PERC-1:** Percentiles are never public (API guard)
   - **PERC-2:** No comparison to named users (UI review)
   - **PERC-3:** Percentiles update weekly max (Backend job)
   - **PERC-4:** Minimum 100 users for percentile (Statistical validity)

7. **Component:** `PrivatePercentileStatus.js` (ProfileScreen integration)

**Priority:** MEDIUM (GAP-4)

---

### GAP-6: Poster Quality Filtering (Poster Reputation)

**Status:** ❌ Missing  
**Source:** HUMAN_SYSTEMS_SPEC.md §7.1-§7.7

**What Needs to Be Added:**

1. **New Section: §19. Poster Quality Filtering (Hustler-Only)**

2. **Core Principle:**
   - Surface poster history **only to hustlers**
   - Never show to posters (would change behavior)
   - Facts only, no labels (hustler decides)

3. **Poster Reputation UI (Task Card):**
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

4. **Poster Reputation Metrics:**
   - Tasks Posted (COUNT of tasks)
   - Dispute Rate (Disputes / Tasks)
   - Avg Response Time (Avg time to respond to proofs)
   - Hustler Rating (Avg rating from workers)
   - Repeat Hire Rate (Rehired same hustler %)

5. **Poster Reputation Rules:**
   - **Never show to posters** (would change behavior artificially)
   - **Minimum 5 tasks** (statistical validity)
   - **Rolling 90-day window** (recent behavior matters more)
   - **No "bad poster" label** (just facts, hustler decides)

6. **Poster Rating System (Post-Task):**
   ```
   How was working with Sarah?
   
   [ 😊 Great ]  [ 😐 Okay ]  [ 😕 Difficult ]
   
   Optional: What could be better?
   [ ] Clearer task description
   [ ] Faster communication
   [ ] More reasonable expectations
   ```

7. **Poster Reputation Invariants:**
   - **POSTER-1:** Poster reputation never visible to posters (API guard)
   - **POSTER-2:** Minimum 5 tasks required for reputation display
   - **POSTER-3:** Only rolling 90-day window (no lifetime stats)
   - **POSTER-4:** Facts only, no subjective labels

8. **Components:**
   - `PosterReputation.js` (Task Card integration)
   - `PosterRatingModal.js` (Post-task rating)

**Priority:** HIGH (GAP-6)

---

### GAP-7: Exit With Dignity (Pause State)

**Status:** ❌ Missing  
**Source:** HUMAN_SYSTEMS_SPEC.md §8.1-§8.7

**What Needs to Be Added:**

1. **New Section: §20. Exit With Dignity (Pause State)**

2. **Core Principle:**
   - Let users leave cleanly without losing progress
   - No psychological traps (streak anxiety, FOMO, punitive decay)
   - Graceful pause with protected progress

3. **Pause State UI:**
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

4. **Pause State Rules:**
   | Aspect | During Pause | After Resume |
   |--------|--------------|--------------|
   | XP | No decay | Intact |
   | Level | Frozen | Intact |
   | Trust Tier | Frozen | Intact |
   | Badges | Permanent | Intact |
   | Streak | Grace period (configurable) | Continues if resumed in time |
   | Task Visibility | Hidden from task feed | Restored |
   | Notifications | None | Restored |

5. **Pause Duration Tiers:**
   | Duration | Streak Grace | Trust Protection |
   |----------|--------------|------------------|
   | Up to 14 days | Full streak preserved | Full protection |
   | 15-30 days | Streak resets to 1 | Trust tier preserved |
   | 31-90 days | Streak resets to 1 | Trust tier preserved |
   | 90+ days | Streak resets to 1 | Trust tier drops one level |

6. **Pause Invariants:**
   - **PAUSE-1:** XP never decays during pause (Backend logic)
   - **PAUSE-2:** Badges are permanent regardless (DB constraint)
   - **PAUSE-3:** Pause is always available (UI always shows option)
   - **PAUSE-4:** Resume is instant (No "reactivation" delay)
   - **PAUSE-5:** No punitive notifications (Notification service)

7. **Components:**
   - `PauseStateModal.js` (Pause confirmation)
   - `PausedAccountScreen.js` (Resume interface)
   - ProfileScreen integration (Pause button)

**Priority:** MEDIUM (GAP-7)

---

## Integration Priority

### Phase 1: High Priority (Weeks 1-2)
1. ✅ **GAP-5: Global Fatigue & Anti-Burnout** (Complete partial integration)
   - Add §16. Global Fatigue System
   - Fatigue nudge UI (3 tiers)
   - Mandatory break cooldown UI
   - Global fatigue invariants

2. ✅ **GAP-3: Session Forecast** (Add §17)
   - Session Forecast UI component
   - Forecast rules and invariants
   - AI integration (A1 authority)

3. ✅ **GAP-6: Poster Quality Filtering** (Add §19)
   - Poster reputation UI (Task Card)
   - Poster rating modal (Post-task)
   - Poster reputation invariants

### Phase 2: Medium Priority (Weeks 3-4)
4. ✅ **GAP-4: Private Percentile Status** (Add §18)
   - Private Percentile UI (ProfileScreen)
   - Percentile rules and invariants
   - API guards for privacy

5. ✅ **GAP-7: Exit With Dignity** (Add §20)
   - Pause State UI (modal + screen)
   - Pause rules and invariants
   - Resume functionality

---

## Required Actions

### For UI_SPEC.md v1.4.0 (Next Version)

1. **Add 4 New Sections:**
   - §16. Global Fatigue & Anti-Burnout System (extend §13)
   - §17. Session Forecast (AI Earning Predictability)
   - §18. Private Percentile Status
   - §19. Poster Quality Filtering (Hustler-Only)
   - §20. Exit With Dignity (Pause State)

2. **Extend Existing Section:**
   - §13. Live Mode UI Rules → Add global fatigue beyond Live Mode

3. **Update Cross-Reference Matrix:**
   - Add new sections to §11 (Cross-Reference Matrix)

4. **Update Amendment History:**
   - v1.4.0: Added max-tier human systems (GAP-3, GAP-4, GAP-5 completion, GAP-6, GAP-7)

### For Components

1. **Create New Components:**
   - `SessionForecast.js`
   - `PrivatePercentileStatus.js`
   - `PosterReputation.js` (Task Card integration)
   - `PosterRatingModal.js`
   - `PauseStateModal.js`
   - `PausedAccountScreen.js`
   - `FatigueNudge.js` (3 tiers: gentle, stronger, mandatory)

2. **Update Existing Components:**
   - `TaskCard.js` → Add poster reputation section
   - `ProfileScreen.js` → Add private percentile status section
   - `HomeScreen.js` → Add Session Forecast component

---

## Verification Checklist

Before UI_SPEC can be considered "max-tier":

- [ ] All 7 max-tier human systems integrated
- [ ] Complete UI specifications for each system
- [ ] Rules and invariants documented
- [ ] Forbidden patterns defined
- [ ] Components created and integrated
- [ ] ESLint rules added
- [ ] Runtime guards implemented
- [ ] Cross-referenced with PRODUCT_SPEC.md
- [ ] Integrated into BUILD_GUIDE.md
- [ ] Updated EXECUTION_INDEX.md

---

## Current Status: 🟡 40% Max-Tier

**Completion:**
- ✅ 2/7 fully integrated (GAP-1, GAP-2)
- 🟡 1/7 partially integrated (GAP-5)
- ❌ 4/7 missing (GAP-3, GAP-4, GAP-6, GAP-7)

**Estimated Effort:**
- Phase 1 (High Priority): 2-3 weeks
- Phase 2 (Medium Priority): 2 weeks
- **Total: 4-5 weeks to max-tier**

---

**Last Updated:** January 2025  
**Next Review:** After Phase 1 completion  
**Target:** UI_SPEC.md v1.4.0 (Max-Tier Complete)
