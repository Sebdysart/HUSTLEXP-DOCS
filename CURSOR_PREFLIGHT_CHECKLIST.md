# Cursor Preflight Checklist

> **⚠️ TECH STACK NOTE:** This checklist was written for a React Native / Expo scaffold. The active iOS app (HUSTLEXPFINAL1) is **native Swift/SwiftUI**. Map React Native patterns (React Navigation, Expo, etc.) to SwiftUI equivalents (NavigationStack, native APIs). Design tokens and spec references remain authoritative.

**PURPOSE:** Verification checklist before Cursor begins frontend implementation.
**TARGET:** 100% specification coverage with zero ambiguity.

---

## ✅ Pre-Build Verification

Before starting implementation, verify ALL boxes are checked:

### 1. Core Specifications

| Document | Location | Status |
|----------|----------|--------|
| Product Spec | `specs/01-product/PRODUCT_SPEC.md` | ✅ |
| Architecture | `specs/02-architecture/ARCHITECTURE.md` | ✅ |
| API Contracts | `specs/04-backend/API_CONTRACT.md` | ✅ |
| Database Schema | `specs/02-architecture/schema.sql` | ✅ |
| UI Spec | `specs/03-frontend/UI_SPEC.md` | ✅ |
| Onboarding Spec | `specs/01-product/ONBOARDING_SPEC.md` | ✅ |
| Frontend Architecture | `FRONTEND_ARCHITECTURE.md` | ✅ |

### 2. Type System

| Artifact | Location | Coverage |
|----------|----------|----------|
| TypeScript Definitions | `src/types/index.ts` | 100% |
| Enums | TaskState, EscrowState, ProofState, UserTier, etc. | ✅ |
| Interfaces | UserProfile, Task, Escrow, Proof, etc. | ✅ |
| Component Props | ButtonProps, CardProps, InputProps, etc. | ✅ |
| API Types | Request/Response types for all endpoints | ✅ |

### 3. Component Library

| Component | Spec Location | Props Defined |
|-----------|---------------|---------------|
| Button | `specs/03-frontend/COMPONENT_LIBRARY.md` §1 | ✅ |
| Card | `specs/03-frontend/COMPONENT_LIBRARY.md` §2 | ✅ |
| HXText | `specs/03-frontend/COMPONENT_LIBRARY.md` §3 | ✅ |
| Input | `specs/03-frontend/COMPONENT_LIBRARY.md` §4 | ✅ |
| Avatar | `specs/03-frontend/COMPONENT_LIBRARY.md` §5 | ✅ |
| Badge | `specs/03-frontend/COMPONENT_LIBRARY.md` §6 | ✅ |
| TaskCard | `specs/03-frontend/COMPONENT_LIBRARY.md` §7 | ✅ |
| SearchBar | `specs/03-frontend/COMPONENT_LIBRARY.md` §8 | ✅ |
| Modal | `specs/03-frontend/COMPONENT_LIBRARY.md` §9 | ✅ |
| BottomSheet | `specs/03-frontend/COMPONENT_LIBRARY.md` §10 | ✅ |
| List | `specs/03-frontend/COMPONENT_LIBRARY.md` §11 | ✅ |
| ProgressBar | `specs/03-frontend/COMPONENT_LIBRARY.md` §12 | ✅ |
| Skeleton | `specs/03-frontend/COMPONENT_LIBRARY.md` §13 | ✅ |
| Toast | `specs/03-frontend/COMPONENT_LIBRARY.md` §14 | ✅ |
| TabBar | `specs/03-frontend/COMPONENT_LIBRARY.md` §15 | ✅ |
| Header | `specs/03-frontend/COMPONENT_LIBRARY.md` §16 | ✅ |
| FirstXPCelebration | `specs/03-frontend/COMPONENT_LIBRARY.md` §17 | ✅ |
| LockedGamificationUI | `specs/03-frontend/COMPONENT_LIBRARY.md` §18 | ✅ |
| MoneyTimeline | `specs/03-frontend/COMPONENT_LIBRARY.md` §19 | ✅ |
| FailureRecovery | `specs/03-frontend/COMPONENT_LIBRARY.md` §20 | ✅ |
| LiveModeUI | `specs/03-frontend/COMPONENT_LIBRARY.md` §21 | ✅ |

### 4. Validation Patterns

| Pattern | Spec Location | Regex Defined |
|---------|---------------|---------------|
| Email | `specs/03-frontend/VALIDATION_PATTERNS.md` §1 | ✅ |
| Password | `specs/03-frontend/VALIDATION_PATTERNS.md` §2 | ✅ |
| Phone | `specs/03-frontend/VALIDATION_PATTERNS.md` §3 | ✅ |
| Name | `specs/03-frontend/VALIDATION_PATTERNS.md` §4 | ✅ |
| Task Title | `specs/03-frontend/VALIDATION_PATTERNS.md` §5 | ✅ |
| Task Description | `specs/03-frontend/VALIDATION_PATTERNS.md` §6 | ✅ |
| Price | `specs/03-frontend/VALIDATION_PATTERNS.md` §7 | ✅ |
| Location | `specs/03-frontend/VALIDATION_PATTERNS.md` §8 | ✅ |
| Date/Time | `specs/03-frontend/VALIDATION_PATTERNS.md` §9 | ✅ |
| Photo | `specs/03-frontend/VALIDATION_PATTERNS.md` §10 | ✅ |

### 5. State Management

| Pattern | Spec Location | Implementation Guide |
|---------|---------------|---------------------|
| Server-Authoritative | `specs/03-frontend/STATE_MANAGEMENT_PATTERNS.md` §1 | ✅ |
| Context Providers | `specs/03-frontend/STATE_MANAGEMENT_PATTERNS.md` §2 | ✅ |
| Screen State Patterns | `specs/03-frontend/STATE_MANAGEMENT_PATTERNS.md` §3 | ✅ |
| State Machines | `specs/03-frontend/STATE_MANAGEMENT_PATTERNS.md` §4 | ✅ |
| Optimistic Updates | `specs/03-frontend/STATE_MANAGEMENT_PATTERNS.md` §5 | ✅ |
| Error Recovery | `specs/03-frontend/STATE_MANAGEMENT_PATTERNS.md` §6 | ✅ |

### 6. API Pagination

| Endpoint | Pagination Type | Spec Location |
|----------|-----------------|---------------|
| task.getFeed | Cursor-based | `specs/03-frontend/API_PAGINATION.md` §2.1 |
| task.list | Offset-based | `specs/03-frontend/API_PAGINATION.md` §2.2 |
| user.getHistory | Cursor-based | `specs/03-frontend/API_PAGINATION.md` §2.3 |
| wallet.getTransactions | Cursor-based | `specs/03-frontend/API_PAGINATION.md` §2.4 |
| message.getConversations | Cursor-based | `specs/03-frontend/API_PAGINATION.md` §2.5 |
| message.getMessages | Cursor-based | `specs/03-frontend/API_PAGINATION.md` §2.6 |

### 7. Platform Specifics

| Screen | Safe Area Edges | Spec Location |
|--------|-----------------|---------------|
| TaskFeed | top, bottom | `specs/03-frontend/PLATFORM_SPECIFIC.md` §1 |
| TaskDetail | top | `specs/03-frontend/PLATFORM_SPECIFIC.md` §1 |
| CreateTask | top, bottom | `specs/03-frontend/PLATFORM_SPECIFIC.md` §1 |
| Profile | top | `specs/03-frontend/PLATFORM_SPECIFIC.md` §1 |
| Wallet | top | `specs/03-frontend/PLATFORM_SPECIFIC.md` §1 |
| Messages | top, bottom | `specs/03-frontend/PLATFORM_SPECIFIC.md` §1 |
| Onboarding | top, bottom | `specs/03-frontend/PLATFORM_SPECIFIC.md` §1 |

### 8. Assets

| Asset Type | Location | Count |
|------------|----------|-------|
| Placeholders | `assets/placeholders/` | 3 |
| Badges | `assets/badges/` | 10 |
| Illustrations | `assets/illustrations/` | 9 |
| Manifest | `assets/ASSET_MANIFEST.md` | ✅ |

### 9. Development Infrastructure

| Artifact | Location | Status |
|----------|----------|--------|
| ESLint Config | `.eslintrc.json` | ✅ |
| Custom ESLint Rules | `specs/03-frontend/ESLINT_CUSTOM_RULES.md` | ✅ |
| Jest Config | `jest.config.js` | ✅ |
| Jest Setup | `jest.setup.js` | ✅ |
| Test Examples | `__tests__/` | ✅ |

---

## 🔍 Quick Reference Lookup

### "What type should X be?"
→ Check `src/types/index.ts`

### "How should component X behave?"
→ Check `specs/03-frontend/COMPONENT_LIBRARY.md`

### "What validation rules for field X?"
→ Check `specs/03-frontend/VALIDATION_PATTERNS.md`

### "How does state flow for screen X?"
→ Check `specs/03-frontend/STATE_MANAGEMENT_PATTERNS.md`

### "How to handle pagination for endpoint X?"
→ Check `specs/03-frontend/API_PAGINATION.md`

### "What safe areas for screen X?"
→ Check `specs/03-frontend/PLATFORM_SPECIFIC.md`

### "What API endpoint for action X?"
→ Check `specs/04-backend/API_CONTRACT.md`

### "What color for element X?"
→ Check `COLOR_AUTHORITY_RESOLUTION.md` (authoritative)
→ Or `.cursorrules` SECTION 7 (quick reference)

### "What typography for element X?"
→ Check `TYPOGRAPHY_AUTHORITY_RESOLUTION.md` (authoritative)
→ Or `.cursorrules` SECTION 7 (quick reference)

### "What animation for state X?"
→ Check `specs/03-frontend/UI_SPEC.md` §3

### "What copy for message X?"
→ Check `specs/03-frontend/UI_SPEC.md` §15

---

## ⚠️ Critical Rules - Never Violate

### 1. Server-Authoritative State
```typescript
// ❌ NEVER assume state
setTaskState('completed');
await api.complete();

// ✅ ALWAYS wait for server
const result = await api.complete();
if (result.success) {
  setTaskState(result.task.state);
}
```

### 2. XP Colors Only in XP Context
```typescript
// ❌ NEVER use XP green for non-XP elements
<View style={{ backgroundColor: '#1FAD7E' }}>
  <Text>Task Card</Text>
</View>

// ✅ ONLY in XP components (brand primary #1FAD7E or Apple green #34C759)
<XPDisplay>
  <Text style={{ color: '#1FAD7E' }}>{xpAmount}</Text>
</XPDisplay>

// NOTE: #10B981 is DEPRECATED — use #1FAD7E (brand) or #34C759 (Apple green)
```

### 3. No Gamification for Posters
```typescript
// ❌ NEVER show XP to posters
{user.role === 'poster' && <XPDisplay />}

// ✅ Posters never see gamification
{user.role === 'doer' && <XPDisplay />}
```

### 4. Gamification Locked Until First Released Escrow
```typescript
// ❌ NEVER show animated XP before unlock
<FirstXPCelebration xpAmount={100} />

// ✅ ALWAYS check unlock state
{hasFirstReleasedEscrow ? (
  <FirstXPCelebration xpAmount={100} />
) : (
  <LockedGamificationUI />
)}
```

### 5. No Shame Language
```typescript
// ❌ FORBIDDEN phrases
"You failed to complete the task"
"Your task was rejected"
"Unfortunately, the task expired"

// ✅ APPROVED alternatives
"Task not completed"
"Task needs revision"
"Task time has ended"
```

### 6. No False Urgency
```typescript
// ❌ FORBIDDEN in Live Mode
"Hurry! Only 5 minutes left!"
"Act now before it's too late!"

// ✅ APPROVED: Factual time display
"Time remaining: 4:32"
```

### 7. Minimum Prices
```typescript
// STANDARD tasks: $5.00 minimum (500 cents)
// LIVE tasks: $15.00 minimum (1500 cents)
```

### 8. Trust Tier Numbers
```typescript
// ALWAYS use numeric format
tier: 1 | 2 | 3 | 4

// NEVER use strings
tier: 'NEW' | 'VERIFIED' | 'TRUSTED' | 'ELITE' // ❌
```

---

## 📁 File Structure Reference

```
HUSTLEXP-DOCS/
├── specs/
│   ├── 01-product/
│   │   ├── PRODUCT_SPEC.md
│   │   └── ONBOARDING_SPEC.md
│   ├── 02-architecture/
│   │   ├── ARCHITECTURE.md
│   │   └── schema.sql
│   ├── 03-frontend/
│   │   ├── API_PAGINATION.md
│   │   ├── ASSETS_STRATEGY.md
│   │   ├── COMPONENT_LIBRARY.md
│   │   ├── DESIGN_SYSTEM.md
│   │   ├── ESLINT_CUSTOM_RULES.md
│   │   ├── PLATFORM_SPECIFIC.md
│   │   ├── STATE_MANAGEMENT_PATTERNS.md
│   │   ├── UI_SPEC.md
│   │   ├── VALIDATION_PATTERNS.md
│   │   └── stitch-prompts/              ← PIXEL-PERFECT HTML SPECS
│   └── 04-backend/
│       └── API_CONTRACT.md
├── src/
│   └── types/
│       └── index.ts
├── assets/
│   ├── ASSET_MANIFEST.md
│   ├── badges/
│   ├── illustrations/
│   └── placeholders/
├── reference/
│   └── components/
│       └── *.tsx (reference implementations)
├── __tests__/
│   ├── components/
│   ├── state/
│   └── utils/
├── __mocks__/
├── .eslintrc.json
├── jest.config.js
├── jest.setup.js
└── CURSOR_PREFLIGHT_CHECKLIST.md  ← YOU ARE HERE
```

---

## 🚀 Implementation Order

Recommended build sequence:

### Phase 1: Foundation
1. Set up Xcode project with Swift/SwiftUI (NOTE: originally Expo — active app is native iOS)
2. Copy `src/types/index.ts` to project (adapt TypeScript types to Swift structs/enums)
3. Configure SwiftLint (NOTE: ESLint is for the legacy scaffold; active app uses SwiftLint)
4. Configure XCTest (NOTE: Jest is for the legacy scaffold; active app uses XCTest)

### Phase 2: Design System
1. Implement color constants from UI_SPEC §2
2. Implement typography from UI_SPEC §2.4
3. Implement spacing scale from UI_SPEC §2.5
4. Build primitive components (Button, Card, HXText, Input)

### Phase 3: Core Components
1. Build Avatar, Badge components
2. Build TaskCard, SearchBar
3. Build Modal, BottomSheet
4. Build List, ProgressBar, Skeleton

### Phase 4: Navigation & Screens
1. Set up NavigationStack / TabView (NOTE: originally React Navigation — active app uses SwiftUI navigation)
2. Implement TabBar, Header
3. Build screen shells with safe areas
4. Implement screen-specific state patterns

### Phase 5: Features
1. Implement authentication flow
2. Build onboarding screens
3. Build task feed with pagination
4. Build task detail and actions
5. Build messaging system
6. Build wallet and transactions

### Phase 6: Gamification
1. Implement LockedGamificationUI
2. Build XPDisplay, LevelBadge
3. Implement FirstXPCelebration
4. Wire up gamification unlock logic

### Phase 7: Polish
1. Add all animations per UI_SPEC §3
2. Implement error states per FAILURE_MESSAGING.md
3. Add accessibility labels
4. Performance optimization

---

## ✅ Final Verification

Before considering implementation complete:

- [ ] All TypeScript compiles with no errors
- [ ] ESLint passes with no warnings
- [ ] All tests pass
- [ ] No XP colors outside XP contexts
- [ ] No gamification visible to posters
- [ ] No gamification before first released escrow
- [ ] No shame language in any copy
- [ ] No false urgency messaging
- [ ] All safe areas properly applied
- [ ] All animations within duration limits
- [ ] All API calls have loading and error states
- [ ] All forms have proper validation
- [ ] All lists have empty and loading states

---

**REPO READINESS: 100%**

All specifications, types, patterns, assets, and infrastructure are in place.
Cursor can proceed with implementation without backtracking or hallucination.

---

**END OF PREFLIGHT CHECKLIST**
