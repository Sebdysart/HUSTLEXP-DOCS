# HustleXP Figma Design Prompts — MAX-TIER

**Status:** LOCKED  
**Date:** January 2025  
**Purpose:** Exact prompts for Figma to generate UI designs without hallucination or design drift

---

## Critical Rules (Non-Negotiable)

1. **Apple Glass aesthetic: controlled glass, minimal borders, real hierarchy**
2. **Deterministic language: non-emotional, factual, authority-driven**
3. **No "support-first" affordances: support is tertiary and visually subordinate**
4. **No hidden states: risk tier, trust tier, escrow/proof rules visible when required**
5. **No animations unless specified (static UI for now)**
6. **Accessibility: adequate contrast, readable sizes, touch targets >= 44px**

---

## Design Tokens (Reference)

### Colors
- Background: `#000000` (Pure black)
- Text Primary: `#FFFFFF` (White)
- Text Secondary: `#8E8E93` (System gray)
- Muted: `#3A3A3C` (Dark gray)
- Glass Primary: `rgba(28, 28, 30, 0.6)` (Semi-transparent dark)
- Glass Secondary: `rgba(44, 44, 46, 0.8)` (Semi-transparent darker)
- Glass Border Primary: `rgba(255, 255, 255, 0.1)` (Subtle white border)
- Glass Border Secondary: `rgba(255, 255, 255, 0.05)` (Minimal white border)
- Primary Action: `#0A84FF` (System blue)

### Spacing
- Section spacing: `24px`
- Card padding: `16px`

### Typography
- Header: `28px` bold, white
- Subheader: `14px` regular, gray (`#8E8E93`)
- Body: `14px` regular, white
- Caption: `12px` regular, gray, uppercase

---

## PROMPT 1: Settings → Work Eligibility Screen (CRITICAL)

**Execution Order:** Phase F-1, Task #1  
**Priority:** CRITICAL — Must be designed first  
**Reference:** `architecture/SETTINGS_VERIFICATION_AND_ELIGIBILITY_LOCKED.md`

---

### Exact Figma Prompt (Copy/Paste Verbatim)

```
Design the Settings → Work Eligibility screen for HustleXP iOS app.

DESIGN REQUIREMENTS:

1. APPLE GLASS AESTHETIC
   - Pure black background (#000000)
   - Glass cards with subtle blur: rgba(28, 28, 30, 0.6) background, 1px border rgba(255, 255, 255, 0.1)
   - Minimal borders (only where hierarchy demands)
   - Real visual hierarchy through spacing and typography (not decorative elements)
   - No shadows, no gradients, no decorative borders

2. DETERMINISTIC LANGUAGE (NON-NEGOTIABLE TONE)
   - Use EXACT wording from: architecture/SETTINGS_VERIFICATION_AND_ELIGIBILITY_LOCKED.md
   - NO emotional language ("Great job!", "You're doing amazing!")
   - NO "support-first" affordances (support contact is visually subordinate)
   - Factual only: "Verified", "Pending", "Expired", "Not verified"
   - Authority-driven: "You're eligible for:", "Not eligible for:"

3. PAGE STRUCTURE (EXACT ORDER FROM SPEC):

   SECTION 1: Eligibility Summary (Top, Read-Only)
   - Title: "Work Eligibility" (28px bold, white)
   - Current Trust Tier: Large number (e.g., "Tier 2") + label
   - Active Risk Clearance: "Low / Medium / High / Critical" badges
   - Work Location: State abbreviation (e.g., "WA")
   - Two-column list:
     * Left: "You're eligible for:" → Bullet list (Low-risk gigs, Medium-risk appliance installs)
     * Right: "Not eligible for:" → Bullet list (Electrical — license required, In-home care — background check required)
   - NO buttons, NO upsells, NO estimates here
   - Spacing: 24px between sections

   SECTION 2: Verified Trades
   - Section header: "Verified Trades" (14px uppercase, gray #8E8E93)
   - For each trade (show 3 states):
     * NOT VERIFIED:
       - Status icon: ❌ (red or gray)
       - Label: "Electrician" (14px white)
       - Subtext: "Not verified" (12px gray)
       - Button: "Verify license" (PrimaryActionButton style, but disabled state)
       - Glass card container
     * PENDING:
       - Status icon: ⏳ (yellow or gray)
       - Label: "Electrician" (14px white)
       - Subtext: "Verification in progress" (12px gray)
       - Note: "This usually takes under X hours" (12px gray, italic)
       - NO button
     * VERIFIED:
       - Status icon: ✅ (green)
       - Label: "Electrician" (14px white, bold)
       - State: "WA" (12px gray)
       - Expiration: "Expires: May 1, 2026" (12px gray)
       - NO button (read-only)
   - Rule: NO toggles. Verification status is truth (display-only).
   - Spacing: 16px between cards

   SECTION 3: Insurance Section (Conditional)
   - Shown ONLY if user has at least one verified trade
   - Section header: "Insurance" (14px uppercase, gray)
   - Same state pattern: ❌ Not on file, ⏳ Pending, ✅ Active, ⚠️ Expired
   - Button: "Add insurance" or "Renew insurance" (if expired)
   - Glass card container

   SECTION 4: Background Checks (Conditional)
   - Shown ONLY if user opted into critical tasks
   - Section header: "Background Checks" (14px uppercase, gray)
   - Same state pattern: ❌ Not completed, ⏳ Pending, ✅ Verified, ⚠️ Expired
   - Glass card container

   SECTION 5: Upgrade Opportunities (Computed Display Only)
   - Show card ONLY if opportunities exist
   - Glass card with subtle accent (blue border or icon)
   - Title: "Verify Electrician License" (14px white, bold)
   - Subtext: "Unlocks 7 active gigs near you" (12px gray)
   - Footer: "Average payout: $180" (12px gray)
   - Button: "Verify license" (PrimaryActionButton style)
   - NO "up to" language, NO hypothetical counts

   SECTION 6: System Notices (Expiry Only)
   - Badge/count indicator on "Work Eligibility" title if credentials expired
   - Inline alert at top of screen (if expired):
     - Background: rgba(255, 149, 0, 0.2) (Orange tint)
     - Text: "⚠️ Credential expired" (14px white)
     - Subtext: "Expired credentials remove access immediately" (12px gray)
   - Placement: Top of screen, below header

4. COMPONENT STYLES:

   Glass Card:
   - Background: rgba(28, 28, 30, 0.6)
   - Border: 1px solid rgba(255, 255, 255, 0.1)
   - Border radius: 12px
   - Padding: 16px
   - No shadow, no gradient

   Primary Action Button:
   - Background: #0A84FF (System blue)
   - Text: White, 14px, bold
   - Height: 44px (minimum touch target)
   - Border radius: 8px
   - Disabled state: Background rgba(255, 255, 255, 0.1), Text rgba(255, 255, 255, 0.3)

   Section Header:
   - Text: 14px, uppercase, gray (#8E8E93), letter-spacing 1px
   - Margin bottom: 8px

5. TYPOGRAPHY HIERARCHY:
   - Title (28px bold, white) → Section headers (14px uppercase, gray) → Body (14px white) → Caption (12px gray)
   - NO decorative fonts, NO emojis except status icons (❌ ⏳ ✅ ⚠️)

6. LAYOUT CONSTRAINTS:
   - Safe area: 24px top padding (for notch/Dynamic Island)
   - Side margins: 16px
   - Section spacing: 24px
   - Card spacing: 16px
   - Scrollable content (list can extend beyond viewport)

7. ACCESSIBILITY:
   - Touch targets: Minimum 44px height (buttons, interactive elements)
   - Contrast: White text on black background (maximum contrast)
   - Text sizes: Minimum 12px, body 14px minimum
   - Status icons: Color + icon (not color alone)

8. FORBIDDEN ELEMENTS:
   - ❌ Progress bars (spec explicitly forbids)
   - ❌ Countdown timers
   - ❌ Animated elements (unless specified)
   - ❌ Decorative borders or shadows
   - ❌ "Support" button in prominent position
   - ❌ "Contact us" links as primary actions
   - ❌ Emotional language or celebratory copy

9. REFERENCE FILES:
   - Read: architecture/SETTINGS_VERIFICATION_AND_ELIGIBILITY_LOCKED.md §6 "Page Structure"
   - Use exact wording from spec (do not paraphrase)

10. OUTPUT:
    - Single Figma frame: "Settings → Work Eligibility"
    - Size: iPhone 15 Pro (393 × 852px) or iPhone 17 Pro equivalent
    - Components: GlassCard, PrimaryActionButton, SectionHeader (as reusable components)
    - Design tokens: Colors, spacing, typography from tokens (reference provided above)

Design the screen now.
```

---

## PROMPT 2: Capability-Driven Onboarding Screens (HIGH)

**Execution Order:** Phase F-2, Task #3  
**Priority:** HIGH — Design after Settings screen  
**Reference:** `architecture/CAPABILITY_DRIVEN_ONBOARDING_LOCKED.md`

---

### Exact Figma Prompt (Copy/Paste Verbatim)

```
Design the 7-phase Capability-Driven Onboarding flow for HustleXP iOS app.

DESIGN REQUIREMENTS:

1. APPLE GLASS AESTHETIC
   - Same as PROMPT 1: Pure black background, glass cards, minimal borders
   - Consistent visual language across all 7 screens

2. DETERMINISTIC LANGUAGE
   - Use EXACT wording from: architecture/CAPABILITY_DRIVEN_ONBOARDING_LOCKED.md
   - NO emotional language
   - Factual only: "What types of work are you qualified to do?" (not "What skills do you have?")
   - Clear, direct questions (no fluff)

3. REQUIRED SCREENS (GENERATE ALL 7):

   SCREEN 1: Role Declaration (PHASE 0)
   - Title: "How do you want to use HustleXP?" (28px bold, white)
   - Subtitle: "Select one option" (14px gray)
   - Three options (glass cards, 44px height minimum):
     * "I want to earn money completing gigs" (with arrow →)
     * "I want to post gigs" (with arrow →)
     * "Both" (with arrow →)
   - Progress indicator: "Step 1 of 7" (12px gray, bottom)
   - Layout: Stacked cards, 16px spacing

   SCREEN 2: Location (PHASE 1)
   - Title: "Where will you be working?" (28px bold, white)
   - Subtitle: "Licenses, insurance, and task legality are state-scoped" (12px gray, italic)
   - State dropdown: Required field (14px white, with dropdown arrow)
   - City/ZIP input: Optional field (14px white, placeholder "City or ZIP code")
   - Button: "Continue" (PrimaryActionButton, bottom)
   - Progress: "Step 2 of 7"
   - Layout: Form layout, 24px spacing between fields

   SCREEN 3: Capability Declaration (PHASE 2)
   - Title: "What types of work are you qualified to do?" (28px bold, white)
   - Subtitle: "Select all that apply" (14px gray)
   - Multi-select checkboxes (glass cards, 44px height):
     * Low-risk options: "Moving help", "Yard work", "Cleaning", "Assembly", "Errands"
     * Trade/regulated options (visually marked): "Electrician — License required", "Plumber — License required", etc.
   - Visual marker: Badge or icon next to regulated trades (e.g., 🔒 or "License required" badge)
   - Button: "Continue" (bottom)
   - Progress: "Step 3 of 7"
   - Layout: Scrollable list of checkboxes

   SCREEN 4: Credential Claim (PHASE 3)
   - Title: "Do you currently hold a valid license?" (28px bold, white)
   - Subtitle: "Only shown if a regulated trade was selected" (12px gray, conditional)
   - Three options: "Yes" / "No" / "I'm not sure" (glass cards)
   - If No selected: Warning message (glass card, orange tint):
     - Text: "You won't see licensed gigs until verification is complete." (14px white)
   - Button: "Continue" (bottom)
   - Progress: "Step 4 of 7"

   SCREEN 5: License Metadata (PHASE 4)
   - Title: "License details" (28px bold, white)
   - Subtitle: "For each claimed licensed trade" (12px gray)
   - Trade type: Auto-filled from previous screen (14px gray, non-editable)
   - License number input: Required field (14px white, placeholder "Enter license number")
   - Issuing state dropdown: Required field (14px white)
   - Expiration date input: Optional field (14px white, placeholder "MM/DD/YYYY")
   - Button: "Continue" (bottom)
   - Progress: "Step 5 of 7"
   - Layout: Form layout

   SCREEN 6: Insurance (PHASE 5)
   - Title: "Do you currently carry active professional insurance?" (28px bold, white)
   - Two options: "Yes" / "No" (glass cards)
   - If Yes: Upload COI button (optional now, required later)
   - If No: Info message:
     - Text: "Insurance is required for certain higher-risk gigs. You'll still see eligible lower-risk work." (14px white, gray card)
   - Button: "Continue" (bottom)
   - Progress: "Step 6 of 7"

   SCREEN 7: Risk Willingness (PHASE 6)
   - Title: "Are you willing to do the following?" (28px bold, white)
   - Subtitle: "These answers affect what verification paths appear, not gigs" (12px gray, italic)
   - Three checkboxes:
     * "In-home work"
     * "Urgent / same-day gigs"
     * "High-value installs ($$$)"
   - Note: "These answers do NOT unlock work" (12px gray, italic)
   - Button: "Continue" (bottom)
   - Progress: "Step 7 of 7"

   SCREEN 8: Summary & Next Steps (PHASE 7)
   - Title: "You're set up to earn on HustleXP" (28px bold, white)
   - Summary section (glass card):
     * Role: "Hustler" (14px white)
     * Location: "WA, Seattle" (14px white)
     * Claimed trades: "Electrician, Moving" (14px white)
   - Locked sections (glass cards with accent):
     * "Verify Electrician License to unlock 14 gigs near you" (with verify button, disabled placeholder)
     * "Add insurance to qualify for higher-pay work" (with add button, disabled placeholder)
   - Button: "Complete onboarding" (PrimaryActionButton, bottom)
   - NO rejected tasks, NO disabled apply buttons, NO confusing errors

4. COMPONENT STYLES:
   - Same as PROMPT 1: GlassCard, PrimaryActionButton, SectionHeader
   - Checkbox component: Glass card with checkmark icon when selected
   - Progress indicator: Small text, bottom of screen (12px gray, centered)

5. TYPOGRAPHY & SPACING:
   - Same as PROMPT 1: 28px title, 14px body, 12px caption
   - Section spacing: 24px
   - Card spacing: 16px

6. NAVIGATION VISUAL ELEMENTS:
   - Back button: Top left (arrow icon, 44px touch target)
   - Progress indicator: Bottom center (text only, no progress bar per spec)
   - Continue button: Bottom, full width minus margins

7. FORBIDDEN ELEMENTS:
   - ❌ Progress bars (spec explicitly forbids)
   - ❌ "Skip" buttons (all steps required)
   - ❌ Decorative illustrations
   - ❌ Celebratory animations
   - ❌ "Support" prompts as primary actions

8. REFERENCE FILES:
   - Read: architecture/CAPABILITY_DRIVEN_ONBOARDING_LOCKED.md §2-8 (all phases)
   - Use exact wording from spec

9. OUTPUT:
    - 8 Figma frames: "Onboarding - Role", "Onboarding - Location", ..., "Onboarding - Summary"
    - Size: iPhone 15 Pro (393 × 852px) or iPhone 17 Pro equivalent
    - Components: GlassCard, PrimaryActionButton, Checkbox, ProgressIndicator (reusable)
    - All screens in single Figma file for flow review

Design all 8 screens now.
```

---

## PROMPT 3: Feed UI Shell (MEDIUM — Design Later)

**Execution Order:** Phase F-3, Task #5  
**Priority:** MEDIUM — Design after Settings + Onboarding  
**Reference:** `architecture/FEED_QUERY_AND_ELIGIBILITY_RESOLVER_LOCKED.md`

---

### Exact Figma Prompt (Copy/Paste Verbatim)

```
Design the Task Feed UI shell for HustleXP iOS app.

DESIGN REQUIREMENTS:

1. APPLE GLASS AESTHETIC
   - Same as PROMPT 1: Pure black background, glass cards, minimal borders
   - Feed cards: GlassCard style, scrollable list

2. DETERMINISTIC LANGUAGE
   - Use EXACT wording from: architecture/FEED_QUERY_AND_ELIGIBILITY_RESOLVER_LOCKED.md
   - Task titles: Factual, descriptive (not emotional)
   - No "Apply anyway" buttons (spec forbids)

3. FEED STRUCTURE:

   HEADER:
   - Title: "Available Tasks" (28px bold, white)
   - Feed mode selector (tabs): "Normal" / "Urgent" / "Nearby" (14px, active state: white, inactive: gray)
   - Active mode indicator: Subtle underline or accent

   FEED CONTENT:
   - Scrollable list of task cards
   - Each task card (GlassCard):
     * Task title: 14px bold, white
     * Task category: 12px gray, uppercase badge
     * Location: "📍 Seattle, WA" (12px gray, with icon)
     * Payout: "$180" (14px white, bold, prominent)
     * Time: "Posted 2 hours ago" (12px gray)
     * Button: "Accept" (PrimaryActionButton style, full width within card)
   - Card spacing: 16px
   - Side margins: 16px
   - Top padding: 24px (safe area)

   EMPTY STATE:
   - If no tasks: Large icon (or illustration placeholder)
   - Title: "No tasks available" (28px bold, white)
   - Subtext: "New tasks typically appear within 24 hours" (14px gray)
   - Button: "Refresh" (PrimaryActionButton, bottom)

   LOADING STATE:
   - Spinner: Activity indicator (iOS style, centered)
   - Text: "Loading tasks..." (14px gray, below spinner)

4. TASK CARD LAYOUT:
   - Title at top (14px bold, white)
   - Category badge below title (12px gray, uppercase)
   - Location and payout on same row (left: location, right: payout)
   - Time below location/payout (12px gray)
   - Accept button at bottom (full width, 44px height)

5. FORBIDDEN ELEMENTS:
   - ❌ Disabled task cards (spec: "No disabled card")
   - ❌ "Apply anyway" flows (spec forbids)
   - ❌ Upsell prompts inside feed (spec forbids)
   - ❌ Eligibility warnings ("You're not eligible for this task")
   - ❌ Trust logic in UI (all eligibility is backend-enforced)

6. KEY DESIGN PRINCIPLE:
   - If a task appears in feed, the user IS eligible (backend guarantees this)
   - No visual indication of eligibility (no checkmarks, no badges)
   - All tasks are treated equally (no disabled states)

7. REFERENCE FILES:
   - Read: architecture/FEED_QUERY_AND_ELIGIBILITY_RESOLVER_LOCKED.md §1-10
   - Focus on §7 "Forbidden Patterns" to ensure compliance

8. OUTPUT:
    - Single Figma frame: "Task Feed"
    - Size: iPhone 15 Pro (393 × 852px) or iPhone 17 Pro equivalent
    - Components: TaskCard, FeedHeader, EmptyState, LoadingState (reusable)
    - Show 3-5 task cards in list (enough to show scrollable pattern)

Design the feed screen now.
```

---

## Design Token Reference (Quick Copy)

### Colors
```
Background: #000000
Text Primary: #FFFFFF
Text Secondary: #8E8E93
Muted: #3A3A3C
Glass Primary: rgba(28, 28, 30, 0.6)
Glass Secondary: rgba(44, 44, 46, 0.8)
Glass Border: rgba(255, 255, 255, 0.1)
Primary Action: #0A84FF
```

### Spacing
```
Section: 24px
Card Padding: 16px
Side Margins: 16px
Card Spacing: 16px
```

### Typography
```
Title: 28px, bold, white
Subtitle: 14px, regular, gray (#8E8E93)
Body: 14px, regular, white
Caption: 12px, regular, gray, uppercase
```

---

## Execution Order Summary

1. **PROMPT 1** → Settings → Work Eligibility Screen (CRITICAL, Phase F-1)
2. **PROMPT 2** → Capability-Driven Onboarding Screens (HIGH, Phase F-2)
3. **PROMPT 3** → Feed UI Shell (MEDIUM, Phase F-3 — design later)

---

**END OF FIGMA DESIGN PROMPTS**
