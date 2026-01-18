# Figma Work Eligibility Screen Code — Design Reference

**Status:** DESIGN REFERENCE (Web React → React Native Adaptation Needed)  
**Date:** January 2025  
**Source:** Figma Export - [Work Eligibility Screen Design](https://www.figma.com/make/j2Bz26ckzSKI1dU7V8xkbz/Work-Eligibility-Screen-Design?t=WZBZYRo4AgknExg0-1)  
**Figma Code Bundle:** `/Users/sebastiandysart/Downloads/Work Eligibility Screen Design (1).zip`

---

## ⚠️ Important Note

**This is a Web React implementation exported from Figma.**

HustleXP is building a **React Native iOS app**, not a web app. This code serves as a **design reference** but must be adapted to React Native using:

- **FRONTEND_EXECUTION_PROMPTS.md** PROMPT 1 (Settings → Work Eligibility Screen)
- **Existing React Native components** in `hustlexp-app/ui/` (GlassCard, PrimaryActionButton, SectionHeader)
- **Design tokens** from `ui-specs/tokens/` (colors.json, spacing.json, typography.json)

---

## Figma Component Structure

### Main Component: `WorkEligibility.tsx`

**File Path (Figma Export):** `src/app/components/WorkEligibility.tsx`

**Structure:** 6 sections (matches spec exactly)

1. **System Notice** (Expired Credential Alert) — Top, conditional
2. **Eligibility Summary** (Read-Only) — Trust tier, risk clearance, location, eligibility lists
3. **Verified Trades** — 3 states: NOT VERIFIED, PENDING, VERIFIED
4. **Insurance Section** (Conditional) — 4 states: Not on file, Pending, Active, Expired
5. **Background Checks** (Conditional) — Same 4 states
6. **Upgrade Opportunities** (Computed Display Only) — Card with verify button

---

## Component Details

### 1. System Notice (Expired Credential Alert)

```tsx
<div className="bg-[rgba(255,149,0,0.2)] border border-[rgba(255,149,0,0.3)] rounded-xl p-4 mb-6">
  <span>⚠️</span>
  <p>Credential expired</p>
  <p>Expired credentials remove access immediately</p>
</div>
```

**React Native Equivalent:**
- Use `View` instead of `div`
- Use `rgba(255, 149, 0, 0.2)` for background (from design tokens)
- Use `Text` components instead of `p` tags

---

### 2. Eligibility Summary

**Web (Tailwind CSS):**
```tsx
<h1 className="text-[28px] font-bold text-white">Work Eligibility</h1>
<GlassCard>
  <div className="text-4xl font-bold text-white">Tier 2</div>
  <div className="text-xs text-[#8E8E93]">Current Trust Tier</div>
  // ... two-column eligibility lists
</GlassCard>
```

**React Native Equivalent:**
- Use `Text` with `style={{ fontSize: 28, fontWeight: 'bold', color: '#FFFFFF' }}`
- Use `GlassCard` from `hustlexp-app/ui/GlassCard.tsx`
- Use `View` with `flexDirection: 'row'` for two-column layout
- Use `colors.textPrimary` and `colors.textSecondary` from design tokens

---

### 3. Verified Trades Section

**Web (Tailwind CSS):**
```tsx
<SectionHeader>Verified Trades</SectionHeader>
<GlassCard>
  <span>❌</span> // or ⏳ or ✅
  <div>Plumber</div>
  <div>Not verified</div>
  <PrimaryActionButton disabled>Verify license</PrimaryActionButton>
</GlassCard>
```

**React Native Equivalent:**
- Use `SectionHeader` from `hustlexp-app/ui/SectionHeader.tsx`
- Use `GlassCard` from `hustlexp-app/ui/GlassCard.tsx`
- Use `PrimaryActionButton` from `hustlexp-app/ui/PrimaryActionButton.tsx`
- Use `Text` for status icons (❌ ⏳ ✅ ⚠️)
- Map state to props: `verifiedTrades` array from parent

---

### 4. Insurance Section

**Same structure as Verified Trades** — conditional rendering based on `hasVerifiedTrade` prop.

---

### 5. Background Checks Section

**Same structure as Insurance** — conditional rendering based on `optedIntoCriticalTasks` prop.

---

### 6. Upgrade Opportunities

**Web (Tailwind CSS):**
```tsx
<GlassCard className="border-[rgba(10,132,255,0.3)]">
  <span>💼</span>
  <div>Verify Plumber License</div>
  <div>Unlocks 7 active gigs near you</div>
  <div>Average payout: $180</div>
  <PrimaryActionButton>Verify license</PrimaryActionButton>
</GlassCard>
```

**React Native Equivalent:**
- Use `GlassCard` with custom border style (blue accent)
- Display what `props.upgradeOpportunities` provides (no computation)
- Button is placeholder (disabled or `console.log` handler)

---

## Figma Components (Web → React Native Mapping)

### GlassCard.tsx (Figma)

**Web Implementation:**
```tsx
<div className="bg-[rgba(28,28,30,0.6)] border border-[rgba(255,255,255,0.1)] rounded-xl p-4 backdrop-blur-sm">
```

**React Native Equivalent:** 
Already exists in `hustlexp-app/ui/GlassCard.tsx`
- Uses `BlurView` for backdrop blur
- Uses `rgba(28, 28, 30, 0.6)` for background
- Uses `rgba(255, 255, 255, 0.1)` for border

**Status:** ✅ Component already exists, can be used directly

---

### PrimaryActionButton.tsx (Figma)

**Web Implementation:**
```tsx
<button className="w-full h-11 rounded-lg text-sm font-bold bg-[#0A84FF]">
```

**React Native Equivalent:**
Already exists in `hustlexp-app/ui/PrimaryActionButton.tsx`
- Uses `TouchableOpacity` for button
- Height: 44px (minimum touch target)
- Background: `#0A84FF` (System blue)
- Disabled state: `rgba(255, 255, 255, 0.1)`

**Status:** ✅ Component already exists, can be used directly

---

### SectionHeader.tsx (Figma)

**Web Implementation:**
```tsx
<h2 className="text-sm uppercase text-[#8E8E93] tracking-wider">
```

**React Native Equivalent:**
Already exists in `hustlexp-app/ui/SectionHeader.tsx`
- Uses `Text` with `fontSize: 14`, `textTransform: 'uppercase'`, `color: '#8E8E93'`

**Status:** ✅ Component already exists, can be used directly

---

## Content & Copy (Exact from Figma)

### System Notice
- Title: "Credential expired"
- Subtext: "Expired credentials remove access immediately"

### Eligibility Summary
- Title: "Work Eligibility"
- Trust Tier: "Tier 2" (display number from props)
- Risk Clearance: "Medium" (badge display)
- Location: "WA" (state abbreviation)
- "You're eligible for:" / "Not eligible for:" (two-column lists)

### Verified Trades
- Status icons: ❌ (Not verified), ⏳ (Pending), ✅ (Verified), ⚠️ (Expired)
- Labels: Trade name (e.g., "Electrician", "Plumber")
- States: "Not verified", "Verification in progress", "WA", "Expires: May 1, 2026"
- Button: "Verify license" (disabled if not verified, active if expired)

### Insurance
- Same structure as Verified Trades
- Button: "Add insurance" (if not on file) or "Renew insurance" (if expired)

### Background Checks
- Same structure as Insurance

### Upgrade Opportunities
- Icon: 💼
- Title: "Verify [Trade] License"
- Subtext: "Unlocks [number] active gigs near you"
- Footer: "Average payout: $[amount]"
- Button: "Verify license"

---

## Design Tokens (Figma → React Native)

### Colors (Already in `ui-specs/tokens/colors.json`)

| Figma Value | React Native Token | Usage |
|-------------|-------------------|-------|
| `#000000` | `colors.background` | Main background |
| `#FFFFFF` | `colors.textPrimary` | Primary text |
| `#8E8E93` | `colors.textSecondary` | Secondary text / muted |
| `rgba(28,28,30,0.6)` | `colors.glassPrimary` | Glass card background |
| `rgba(255,255,255,0.1)` | `colors.glassBorderPrimary` | Glass card border |
| `#0A84FF` | `colors.primaryAction` | Primary button background |

### Spacing (Already in `ui-specs/tokens/spacing.json`)

| Figma Value | React Native Token | Usage |
|-------------|-------------------|-------|
| `24px` | `spacing.section` | Between sections |
| `16px` | `spacing.card` | Card padding, spacing between cards |

### Typography (Already in `ui-specs/tokens/typography.json`)

| Figma Value | React Native Token | Usage |
|-------------|-------------------|-------|
| `28px bold` | `typography.header` | Page title |
| `14px` | `typography.body` | Body text |
| `12px` | Caption | Labels, subtext |

---

## React Native Adaptation Checklist

- [ ] Replace `div` with `View`
- [ ] Replace `p` / `h1` / `h2` with `Text`
- [ ] Replace Tailwind classes with StyleSheet styles
- [ ] Use existing React Native components (GlassCard, PrimaryActionButton, SectionHeader)
- [ ] Use design tokens (colors, spacing, typography)
- [ ] Replace `className` with `style` prop
- [ ] Use `SafeAreaView` for notch/Dynamic Island handling
- [ ] Convert two-column layout to `flexDirection: 'row'`
- [ ] Use `ScrollView` for scrollable content
- [ ] Replace `disabled` prop with `disabled={true}` for buttons
- [ ] Remove hover states (not applicable in React Native)
- [ ] Add props interface for data (no hardcoded values)

---

## Props Interface (React Native Implementation)

```typescript
interface WorkEligibilityProps {
  currentTrustTier?: number;
  riskClearance?: 'low' | 'medium' | 'high' | 'critical';
  workLocation?: string; // State abbreviation, e.g., "WA"
  eligibleFor?: string[]; // e.g., ["Low-risk gigs", "Medium-risk appliance installs"]
  notEligibleFor?: string[]; // e.g., ["Electrical — license required"]
  verifiedTrades?: Array<{
    trade: string;
    status: 'not_verified' | 'pending' | 'verified' | 'expired';
    state?: string;
    expiresAt?: string;
  }>;
  insurance?: {
    status: 'not_on_file' | 'pending' | 'active' | 'expired';
    expiresAt?: string;
  };
  backgroundCheck?: {
    status: 'not_completed' | 'pending' | 'verified' | 'expired';
    expiresAt?: string;
  };
  upgradeOpportunities?: Array<{
    trade: string;
    activeGigs: number;
    averagePayout: number;
  }>;
  hasExpiredCredentials?: boolean;
}
```

---

## Next Steps

1. **Use FRONTEND_EXECUTION_PROMPTS.md PROMPT 1** to generate React Native implementation
2. **Reference this Figma code** for exact layout and content structure
3. **Use existing React Native components** from `hustlexp-app/ui/`
4. **Use design tokens** from `ui-specs/tokens/`
5. **Follow spec** from `architecture/SETTINGS_VERIFICATION_AND_ELIGIBILITY_LOCKED.md`

---

**END OF FIGMA CODE REFERENCE**
