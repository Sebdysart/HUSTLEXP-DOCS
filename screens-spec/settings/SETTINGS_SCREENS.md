# Settings Screens Specification

**Location:** `src/screens/settings/`  
**Count:** 3 screens  
**Status:** ✅ All functional

---

## S1: ProfileScreen

**File:** `ProfileScreen.tsx`  
**Spec:** UI_SPEC §8.1

### Purpose
User profile management.

### Required Elements
- [ ] Profile photo (editable)
- [ ] Display name (editable)
- [ ] Email (read-only, change requires verification)
- [ ] Phone number (editable)
- [ ] Trust tier display (read-only)
- [ ] XP display (read-only)
- [ ] Account settings link
- [ ] Logout button

### Props Interface
```typescript
interface ProfileScreenProps {
  user?: {
    photo?: string;
    name: string;
    email: string;
    phone?: string;
    trustTier: number;
    xp: number;
  };
  onUpdatePhoto?: (uri: string) => void;
  onUpdateProfile?: (updates: Partial<User>) => void;
  onLogout?: () => void;
}
```

---

## S2: WalletScreen

**File:** `WalletScreen.tsx`  
**Spec:** UI_SPEC §8.2, PRODUCT_SPEC §4

### Purpose
Payment methods and earnings management.

### Required Elements
- [ ] Current balance display
- [ ] Pending earnings
- [ ] Payment methods list
- [ ] Add payment method button (USER ENTERS DETAILS)
- [ ] Withdrawal button
- [ ] Transaction history
- [ ] Earnings breakdown

### Props Interface
```typescript
interface WalletScreenProps {
  balance?: number;
  pendingEarnings?: number;
  paymentMethods?: PaymentMethod[];
  transactions?: Transaction[];
  onAddPaymentMethod?: () => void;
  onWithdraw?: () => void;
  isLoading?: boolean;
}
```

### Important
⚠️ **Never auto-fill payment details. User must enter card/bank info themselves.**

---

## S3: WorkEligibilityScreen (CRITICAL)

**File:** `WorkEligibilityScreen.tsx`  
**Spec:** UI_SPEC §8.3, PRODUCT_SPEC §17.5

### Purpose
**CRITICAL:** Explain why user can/cannot see certain tasks. This is the "interpretability" screen.

### Required Elements
- [ ] Current Trust Tier
- [ ] Active Risk Clearance level
- [ ] Work Location (state)
- [ ] Verified Trades list
- [ ] Insurance status
- [ ] Background Check status
- [ ] Upgrade opportunities
- [ ] System notices

### Props Interface
```typescript
interface WorkEligibilityProps {
  currentTrustTier?: number;
  riskClearance?: 'low' | 'medium' | 'high' | 'critical';
  workLocation?: string;
  verifiedTrades?: VerifiedTrade[];
  insuranceStatus?: 'verified' | 'pending' | 'expired' | 'none';
  backgroundCheckStatus?: 'passed' | 'pending' | 'failed' | 'none';
  upgradeOpportunities?: UpgradeOpportunity[];
  systemNotices?: Notice[];
}
```

### Page Structure (EXACT ORDER FROM SPEC)
1. Eligibility Summary (Read-Only)
   - Current Trust Tier
   - Active Risk Clearance
   - Work Location
2. Verified Trades
   - List of verified licenses/certifications
3. Insurance
   - Status and expiration
4. Background Checks
   - Status and date
5. Upgrade Opportunities
   - How to unlock more tasks
6. System Notices
   - Any pending actions or alerts

### Why This Screen Matters
This screen answers: "Why can't I see that task?"

Every eligibility decision made by the backend should be explainable here. The user should never be confused about why they're ineligible for something.

---

## Navigation

```
MainTabs
    │
    └──▶ SettingsTab
              │
              ├──▶ ProfileScreen
              │
              ├──▶ WalletScreen
              │
              └──▶ WorkEligibilityScreen
```
