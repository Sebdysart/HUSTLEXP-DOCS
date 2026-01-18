# HustleXP Figma Design References

**Status:** IN PROGRESS  
**Date:** January 2025  
**Purpose:** Track completed Figma designs and link to source files

---

## Design Status

| Screen | Prompt | Status | Figma Link | Notes |
|--------|--------|--------|------------|-------|
| Settings → Work Eligibility | PROMPT 1 | ✅ COMPLETE | [Figma Link](https://www.figma.com/make/j2Bz26ckzSKI1dU7V8xkbz/Work-Eligibility-Screen-Design?t=WZBZYRo4AgknExg0-1) | Phase F-1, Task #1 |
| Capability-Driven Onboarding (8 screens) | PROMPT 2 | ⏳ PENDING | TBD | Phase F-2, Task #3 |
| Feed UI Shell | PROMPT 3 | ⏳ PENDING | TBD | Phase F-3, Task #5 |

---

## Design References

### 1. Settings → Work Eligibility Screen

**Status:** ✅ COMPLETE  
**Figma File:** [Work Eligibility Screen Design](https://www.figma.com/make/j2Bz26ckzSKI1dU7V8xkbz/Work-Eligibility-Screen-Design?t=WZBZYRo4AgknExg0-1)  
**Figma Code:** `ui-specs/designs/FIGMA_WORK_ELIGIBILITY_CODE.md` (design reference)  
**Figma Source Code:** `ui-specs/designs/WorkEligibility.figma.tsx` (web React export)  
**Prompt Used:** FIGMA_DESIGN_PROMPTS.md — PROMPT 1  
**Spec Reference:** `architecture/SETTINGS_VERIFICATION_AND_ELIGIBILITY_LOCKED.md`  
**Design Tokens:** `ui-specs/tokens/colors.json`, `spacing.json`, `typography.json`  

**Sections Designed:**
1. Eligibility Summary (Read-Only)
2. Verified Trades
3. Insurance Section (Conditional)
4. Background Checks (Conditional)
5. Upgrade Opportunities (Computed Display Only)
6. System Notices (Expiry Only)

**Design Verification:**
- ✅ Apple Glass aesthetic (pure black background, glass cards)
- ✅ Deterministic language (exact wording from spec)
- ✅ 6-section structure (exact order from spec)
- ✅ Design tokens applied (colors, spacing, typography)
- ✅ Forbidden elements avoided (no progress bars, no emotional language)

**Code Status:**
- ⚠️ Figma exported **Web React** code (Tailwind CSS)
- ⚠️ Must be adapted to **React Native** using FRONTEND_EXECUTION_PROMPTS.md PROMPT 1
- ✅ React Native components already exist (GlassCard, PrimaryActionButton, SectionHeader)
- ✅ Design tokens already exist (colors, spacing, typography)

---

### 2. Capability-Driven Onboarding Screens (8 screens)

**Status:** ⏳ PENDING  
**Figma File:** TBD  
**Prompt Used:** FIGMA_DESIGN_PROMPTS.md — PROMPT 2  
**Spec Reference:** `architecture/CAPABILITY_DRIVEN_ONBOARDING_LOCKED.md`  
**Design Tokens:** `ui-specs/tokens/colors.json`, `spacing.json`, `typography.json`  

**Screens to Design:**
1. Role Declaration Screen (PHASE 0)
2. Location Screen (PHASE 1)
3. Capability Declaration Screen (PHASE 2)
4. Credential Claim Screen (PHASE 3)
5. License Metadata Screen (PHASE 4)
6. Insurance Screen (PHASE 5)
7. Risk Willingness Screen (PHASE 6)
8. Onboarding Summary Screen (PHASE 7)

---

### 3. Feed UI Shell

**Status:** ⏳ PENDING  
**Figma File:** TBD  
**Prompt Used:** FIGMA_DESIGN_PROMPTS.md — PROMPT 3  
**Spec Reference:** `architecture/FEED_QUERY_AND_ELIGIBILITY_RESOLVER_LOCKED.md`  
**Design Tokens:** `ui-specs/tokens/colors.json`, `spacing.json`, `typography.json`  

**Note:** Wait until backend Phase 1.3 (FeedQueryService) is complete before designing.

---

## Design Asset Links

All Figma designs are linked above. When a design is complete:
1. Update status to ✅ COMPLETE
2. Add Figma link
3. Verify against spec requirements
4. Note any deviations or clarifications

---

## Design → Code Translation

**Important:** Figma designs are visual specifications. Code implementation follows:
- Frontend prompts: `FRONTEND_EXECUTION_PROMPTS.md`
- Spec references: All LOCKED architecture specs in `architecture/`
- Component library: `ui-specs/components/`
- Design tokens: `ui-specs/tokens/`

**Design ≠ Code:** Designs validate visual hierarchy, layout, and language. Code implementation is separate and follows `FRONTEND_EXECUTION_PROMPTS.md`.

---

**END OF FIGMA DESIGN REFERENCES**
