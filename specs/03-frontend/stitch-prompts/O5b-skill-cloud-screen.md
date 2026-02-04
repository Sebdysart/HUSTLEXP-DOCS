# Screen O5b: Skill Cloud (Bubble-Tap Selection)
## Status: IMPLEMENTATION SPEC
**Authority:** SKILL_TAXONOMY.md, DESIGN_SYSTEM.md, ONBOARDING_SPEC.md
**Cursor-Ready:** YES
**Role:** Hustler Only
**Archetype:** D. Calibration/Capability
**Predecessor:** O5 (Category Selection) → O5b (this screen)
**Successor:** O6 (Location Setup)

---

## Overview

Bubble-tap interface for selecting individual skills within chosen categories.
Workers tap everything they can do. Gated skills show requirements without hiding them (Chosen-State).

**Legal significance:** Self-selection from 100+ skills is documented evidence of IC status.

---

## Layout

```
┌─────────────────────────────────────────┐
│ ←                              3 of 12  │
│                                         │
│      Tap everything you can do          │  ← typography.h2
│      More skills = more tasks           │  ← typography.bodySmall, neutral[500]
│                                         │
├─ Category Tabs (Scrollable) ────────────┤
│  [📦 Physical] [🔧 Handy] [🚗 Trans]  │
│  [💻 Tech] [🏠 Personal] [📋 Pro]     │
│                                         │
├─ Skill Bubbles (FlexWrap) ─────────────┤
│                                         │
│  ┌──────────┐ ┌──────────┐ ┌────────┐  │
│  │ Moving   │ │ Hauling  │ │ Packing│  │  ← Unselected: outline
│  │ Help     │ │          │ │        │  │     border: neutral[300]
│  └──────────┘ └──────────┘ └────────┘  │
│  ┌──────────┐ ┌──────────┐ ┌────────┐  │
│  │✓Cleaning │ │ Yard     │ │ Snow   │  │  ← Selected: filled
│  │          │ │ Work     │ │ Removal│  │     bg: primary[500], text: white
│  └──────────┘ └──────────┘ └────────┘  │
│                                         │
│  ── Requires Verification ──────────── │  ← Section divider, amber text
│  ┌──────────┐ ┌──────────┐             │
│  │🔒Plumbing│ │🔒HVAC    │             │  ← Gated: muted bg, lock icon
│  │ License  │ │ License  │             │     text: neutral[400]
│  └──────────┘ └──────────┘             │
│                                         │
├─────────────────────────────────────────┤
│  ✓ 12 skills selected                  │  ← Live counter
│                                         │
│  ┌─────────────────────────────────────┐│
│  │         Continue                     ││  ← Primary CTA
│  └─────────────────────────────────────┘│
│                                         │
│       I'll add skills later             │  ← Link, neutral[500]
│                                         │
└─────────────────────────────────────────┘
```

---

## Props Interface

```typescript
interface SkillCloudScreenProps {
  selectedCategories: string[];  // From O5
  onComplete: (selectedSkills: string[]) => void;
  onSkip: () => void;
  onBack: () => void;
}

interface SkillBubble {
  skill_id: string;
  display_name: string;
  category: string;
  base_risk: 'low' | 'medium' | 'high' | 'critical';
  regulated: boolean;
  min_trust_tier: number;
  is_gated: boolean;       // Computed: min_trust_tier > user.trust_tier
  gate_reason?: string;    // "Verify ID" | "Trust Tier 4" | "License Required"
}
```

---

## Visual Spec

| Element | Style |
|---------|-------|
| Title | `typography.h2`, `colors.neutral[900]` |
| Subtitle | `typography.bodySmall`, `colors.neutral[500]` |
| Category tabs | Pill shape, `borderRadius: 20`, horizontal scroll |
| Active tab | `bg: primary[100]`, `text: primary[700]`, `border: primary[300]` |
| Inactive tab | `bg: neutral[50]`, `text: neutral[600]`, `border: neutral[200]` |
| Bubble (unselected) | `border: neutral[300]`, `bg: white`, `borderRadius: 12`, `paddingH: 16`, `paddingV: 10` |
| Bubble (selected) | `bg: primary[500]`, `text: white`, checkmark prefix |
| Bubble (gated) | `bg: neutral[100]`, `text: neutral[400]`, lock icon prefix |
| Bubble (regulated) | Amber left border: `borderLeft: 3px solid warning[500]` |
| Section divider | `typography.caption`, `colors.warning[600]`, horizontal rule |
| Counter | `typography.bodySmall`, `colors.primary[600]`, checkmark prefix |
| Continue button | `buttonStyles.primary`, full width |
| Skip link | `typography.body`, `colors.neutral[500]`, centered |

---

## Bubble States

| State | Visual | Tap Behavior |
|-------|--------|-------------|
| Unselected (available) | Outline, neutral border | Select → fill primary |
| Selected | Filled primary, white text, ✓ | Deselect → return to outline |
| Gated (trust) | Muted bg, lock icon, gray text | Toast: requirement message |
| Gated (regulated) | Muted + amber border, lock | Bottom sheet: verification info |
| Long press (any) | — | Tooltip: 1-line skill description |

---

## Gated Bubble Interactions

**Trust-Gated Tap:**
```
Toast (2s): "Complete [N] more tasks to unlock [Skill Name]"
```

**Regulated-Gated Tap:**
```
Bottom Sheet:
┌─────────────────────────────────────────┐
│  🔒 Plumbing Work                       │
│                                         │
│  This skill requires a valid            │
│  Plumber License to claim.              │
│                                         │
│  You can add this skill after           │
│  verifying your license in Settings.    │
│                                         │
│  [Remind Me Later]     [Got It]         │
└─────────────────────────────────────────┘
```

---

## Category Tab Behavior

- Tabs correspond to categories from `SKILL_TAXONOMY.md §3-§8`
- Only categories selected in O5 are shown (if O5 selection exists)
- If user came directly (skipped O5 or from Settings), show all 6 tabs
- Selected skills persist across tab switches
- Tab shows count badge: `📦 Physical (4)` when skills selected

---

## Data Flow

```
1. Load skill_catalog WHERE category IN (selectedCategories) AND active = TRUE
2. Compute is_gated per skill (compare min_trust_tier vs user.trust_tier)
3. Sort: available first, then gated (within each subcategory)
4. User taps bubbles → local state tracks selected skill_ids[]
5. On Continue → POST capability_claims batch
6. Navigate to O6 (Location Setup)
```

---

## Backend Contract

**On Continue:**
```typescript
POST /api/onboarding/claim-skills
{
  user_id: string,
  skill_ids: string[],          // Array of selected skill_id values
  selection_source: "onboarding"
}

Response: {
  claimed_count: number,
  gated_skipped: number,        // Skills user saw but couldn't claim
  next_step: "location_setup"
}
```

---

## Chosen-State Compliance

| Requirement | Implementation |
|-------------|----------------|
| User feels selected | "Tap everything you can do" (not "prove what you know") |
| System feels active | Live counter updates on each tap |
| Outcome feels likely | "More skills = more tasks" (direct benefit) |
| No empty/zero state | Categories pre-populated, gated skills visible |
| No testing language | No quiz, no assessment, no "verify" during selection |

---

## Accessibility

- Bubbles: `accessibilityRole="checkbox"`, `accessibilityState={{ checked: selected }}`
- Gated bubbles: `accessibilityHint="Locked. [gate_reason]"`
- Counter: `accessibilityLiveRegion="polite"` (announces changes)
- Category tabs: `accessibilityRole="tablist"` with `accessibilityRole="tab"` children

---

**This screen is Cursor-ready. Build exactly as specified.**
