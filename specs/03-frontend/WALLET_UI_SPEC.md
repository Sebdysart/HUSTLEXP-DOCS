# HustleXP Wallet & Payments UI Specification v1.0.0

**STATUS: IMPLEMENTATION SPECIFICATION**
**Authority:** DESIGN_SYSTEM.md, STRIPE_INTEGRATION.md
**Cursor-Ready:** YES

---

## Table of Contents

1. [Overview](#overview)
2. [Hustler Wallet](#hustler-wallet)
3. [Poster Payment Management](#poster-payment-management)
4. [Shared Components](#shared-components)
5. [States & Flows](#states--flows)

---

## 1. Overview

### Role Differentiation

| Role | Primary Wallet Function |
|------|------------------------|
| **Hustler** | View earnings, withdraw funds, track payouts |
| **Poster** | Manage payment methods, view transaction history |

### Design Principles

- **Apple Glass Layer** (no gamification)
- **Factual, non-emotional copy**
- **Clear transaction states**
- **Security-first interactions**

---

## 2. Hustler Wallet

### 2.1 Wallet Home Screen

**Screen ID:** `HUSTLER_WALLET_HOME`
**Navigation:** Bottom Tab → Wallet

#### Layout Structure

```
┌─────────────────────────────────────────┐
│ ← Wallet                          ⚙️    │  ← Header
├─────────────────────────────────────────┤
│                                         │
│         Available Balance               │  ← Caption, textSecondary
│           $1,247.50                     │  ← Display, 48px, textPrimary
│                                         │
│     ┌─────────────────────────────┐     │
│     │      Withdraw Funds         │     │  ← PrimaryButton
│     └─────────────────────────────┘     │
│                                         │
├─────────────────────────────────────────┤
│  Pending                    $125.00     │  ← Row: label + amount
│  Processing                  $50.00     │
│  This Week                  $432.50     │
├─────────────────────────────────────────┤
│                                         │
│  Recent Transactions                    │  ← SectionHeader
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ ✓ Task: Furniture Assembly          ││  ← TransactionCard
│  │   Jan 19, 2025 • Completed          ││
│  │                          +$85.00    ││
│  └─────────────────────────────────────┘│
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ ⏳ Task: Grocery Delivery           ││
│  │   Jan 18, 2025 • Pending            ││
│  │                          +$35.00    ││
│  └─────────────────────────────────────┘│
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ ↗ Withdrawal to •••• 4242           ││
│  │   Jan 15, 2025 • Completed          ││
│  │                         -$500.00    ││
│  └─────────────────────────────────────┘│
│                                         │
│  View All Transactions →                │  ← TextLink
│                                         │
└─────────────────────────────────────────┘
```

#### Props Interface

```typescript
interface HustlerWalletHomeProps {
  balance: {
    available: number;      // cents
    pending: number;        // cents
    processing: number;     // cents
    thisWeek: number;       // cents
  };
  recentTransactions: Transaction[];
  isLoading?: boolean;
  error?: Error | null;
  onWithdraw?: () => void;
  onViewAllTransactions?: () => void;
  onTransactionPress?: (id: string) => void;
}

interface Transaction {
  id: string;
  type: 'earning' | 'withdrawal' | 'refund';
  status: 'completed' | 'pending' | 'processing' | 'failed';
  amount: number;           // cents (positive for earnings, negative for withdrawals)
  description: string;
  taskId?: string;
  createdAt: string;        // ISO 8601
}
```

#### States

| State | Condition | Display |
|-------|-----------|---------|
| Loading | `isLoading === true` | Skeleton cards |
| Error | `error !== null` | Error message + retry |
| Empty | `balance.available === 0 && transactions.length === 0` | "Complete tasks to earn" |
| Normal | Default | Full wallet UI |

---

### 2.2 Withdrawal Flow

**Screen ID:** `HUSTLER_WITHDRAWAL`
**Navigation:** Wallet Home → Withdraw Funds

#### Step 1: Amount Entry

```
┌─────────────────────────────────────────┐
│ ← Withdraw Funds                        │
├─────────────────────────────────────────┤
│                                         │
│  Available: $1,247.50                   │  ← Caption
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ $                                   ││  ← Amount Input
│  │            500.00                   ││  ← 32px, centered
│  └─────────────────────────────────────┘│
│                                         │
│  Quick amounts:                         │
│  ┌────┐ ┌────┐ ┌────┐ ┌────┐           │
│  │$50 │ │$100│ │$250│ │ All│           │  ← Chip buttons
│  └────┘ └────┘ └────┘ └────┘           │
│                                         │
│  To: Bank Account •••• 4242             │  ← Destination
│  Change →                               │
│                                         │
│  ───────────────────────────────────    │
│  Amount                    $500.00      │
│  Processing Fee              $0.00      │  ← Free for Stripe Express
│  ───────────────────────────────────    │
│  You'll Receive            $500.00      │
│                                         │
│     ┌─────────────────────────────┐     │
│     │       Continue              │     │  ← PrimaryButton
│     └─────────────────────────────┘     │
│                                         │
│  Funds typically arrive in 1-2 days     │  ← Caption, textTertiary
│                                         │
└─────────────────────────────────────────┘
```

#### Step 2: Confirmation

```
┌─────────────────────────────────────────┐
│ ← Confirm Withdrawal                    │
├─────────────────────────────────────────┤
│                                         │
│            💳                           │  ← Icon, 48px
│                                         │
│     Withdraw $500.00                    │  ← Title
│     to •••• 4242                        │  ← Subtitle
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ Amount              $500.00         ││
│  │ To                  Bank •••• 4242  ││
│  │ Estimated Arrival   Jan 22, 2025    ││
│  └─────────────────────────────────────┘│
│                                         │
│     ┌─────────────────────────────────┐ │
│     │    Confirm Withdrawal           │ │  ← PrimaryButton
│     └─────────────────────────────────┘ │
│                                         │
│     ┌─────────────────────────────────┐ │
│     │         Cancel                  │ │  ← SecondaryButton
│     └─────────────────────────────────┘ │
│                                         │
└─────────────────────────────────────────┘
```

#### Step 3: Success

```
┌─────────────────────────────────────────┐
│                                         │
│                                         │
│            ✓                            │  ← Success icon, green
│                                         │
│     Withdrawal Initiated                │  ← Title
│                                         │
│     $500.00 is on its way to            │
│     your bank account •••• 4242         │
│                                         │
│     Estimated arrival: Jan 22, 2025     │
│                                         │
│     ┌─────────────────────────────────┐ │
│     │      Back to Wallet             │ │  ← PrimaryButton
│     └─────────────────────────────────┘ │
│                                         │
└─────────────────────────────────────────┘
```

#### Props Interface

```typescript
interface WithdrawalFlowProps {
  availableBalance: number;     // cents
  bankAccounts: BankAccount[];
  selectedAccountId?: string;
  isProcessing?: boolean;
  error?: Error | null;
  onAmountChange?: (amount: number) => void;
  onAccountSelect?: (accountId: string) => void;
  onConfirm?: (amount: number, accountId: string) => void;
  onCancel?: () => void;
  onComplete?: () => void;
}

interface BankAccount {
  id: string;
  bankName: string;
  last4: string;
  isDefault: boolean;
}
```

---

### 2.3 Payout Settings

**Screen ID:** `HUSTLER_PAYOUT_SETTINGS`
**Navigation:** Wallet → ⚙️

```
┌─────────────────────────────────────────┐
│ ← Payout Settings                       │
├─────────────────────────────────────────┤
│                                         │
│  Payout Method                          │  ← SectionHeader
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ 🏦 Bank Account                     ││
│  │    Chase •••• 4242                  ││
│  │    Default                      ✓   ││
│  └─────────────────────────────────────┘│
│                                         │
│  + Add Bank Account                     │  ← TextButton
│                                         │
├─────────────────────────────────────────┤
│                                         │
│  Payout Schedule                        │  ← SectionHeader
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ Manual                          ○   ││
│  │ Withdraw when you want              ││
│  ├─────────────────────────────────────┤│
│  │ Daily                           ○   ││
│  │ Automatic daily payouts             ││
│  ├─────────────────────────────────────┤│
│  │ Weekly                          ●   ││  ← Selected
│  │ Every Monday                        ││
│  └─────────────────────────────────────┘│
│                                         │
├─────────────────────────────────────────┤
│                                         │
│  Tax Information                        │  ← SectionHeader
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ W-9 Status: Completed           ✓   ││
│  │ View/Update →                       ││
│  └─────────────────────────────────────┘│
│                                         │
│  1099 forms will be available in        │
│  January for earnings over $600.        │
│                                         │
└─────────────────────────────────────────┘
```

#### Props Interface

```typescript
interface PayoutSettingsProps {
  bankAccounts: BankAccount[];
  defaultAccountId: string;
  payoutSchedule: 'manual' | 'daily' | 'weekly';
  taxStatus: {
    w9Completed: boolean;
    lastUpdated?: string;
  };
  isLoading?: boolean;
  onAddBankAccount?: () => void;
  onSetDefaultAccount?: (accountId: string) => void;
  onChangeSchedule?: (schedule: 'manual' | 'daily' | 'weekly') => void;
  onViewTaxInfo?: () => void;
}
```

---

## 3. Poster Payment Management

### 3.1 Payment Methods Screen

**Screen ID:** `POSTER_PAYMENT_METHODS`
**Navigation:** Settings → Payment Methods

```
┌─────────────────────────────────────────┐
│ ← Payment Methods                       │
├─────────────────────────────────────────┤
│                                         │
│  Your Cards                             │  ← SectionHeader
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ 💳 Visa •••• 4242                   ││
│  │    Expires 12/26                    ││
│  │    Default                      ✓   ││
│  └─────────────────────────────────────┘│
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ 💳 Mastercard •••• 8888             ││
│  │    Expires 03/25                    ││
│  │    Set as Default →                 ││
│  └─────────────────────────────────────┘│
│                                         │
│  + Add Payment Method                   │  ← TextButton
│                                         │
├─────────────────────────────────────────┤
│                                         │
│  Payment Preferences                    │  ← SectionHeader
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ Save cards for faster checkout      ││
│  │                               [ON]  ││
│  └─────────────────────────────────────┘│
│                                         │
└─────────────────────────────────────────┘
```

#### Props Interface

```typescript
interface PaymentMethodsProps {
  cards: PaymentCard[];
  defaultCardId: string;
  saveCardsEnabled: boolean;
  isLoading?: boolean;
  onAddCard?: () => void;
  onSetDefault?: (cardId: string) => void;
  onRemoveCard?: (cardId: string) => void;
  onToggleSaveCards?: (enabled: boolean) => void;
}

interface PaymentCard {
  id: string;
  brand: 'visa' | 'mastercard' | 'amex' | 'discover';
  last4: string;
  expiryMonth: number;
  expiryYear: number;
  isDefault: boolean;
}
```

---

### 3.2 Transaction History Screen

**Screen ID:** `POSTER_TRANSACTION_HISTORY`
**Navigation:** Profile → Transaction History

```
┌─────────────────────────────────────────┐
│ ← Transaction History                   │
├─────────────────────────────────────────┤
│                                         │
│  Filter: All ▼        Sort: Newest ▼   │  ← Filters
│                                         │
├─────────────────────────────────────────┤
│                                         │
│  January 2025                           │  ← Month header
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ Task: Furniture Assembly            ││
│  │ Jan 19, 2025 • Completed            ││
│  │ Escrow released            -$85.00  ││
│  └─────────────────────────────────────┘│
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ Task: Grocery Delivery              ││
│  │ Jan 18, 2025 • Escrow held          ││
│  │ Pending release            -$35.00  ││
│  └─────────────────────────────────────┘│
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ Task: Moving Help                   ││
│  │ Jan 15, 2025 • Refunded             ││
│  │ Task cancelled             +$120.00 ││
│  └─────────────────────────────────────┘│
│                                         │
│  Load More                              │  ← Pagination
│                                         │
└─────────────────────────────────────────┘
```

#### Props Interface

```typescript
interface TransactionHistoryProps {
  transactions: PosterTransaction[];
  filter: 'all' | 'completed' | 'pending' | 'refunded';
  sortOrder: 'newest' | 'oldest' | 'amount_high' | 'amount_low';
  isLoading?: boolean;
  hasMore?: boolean;
  onFilterChange?: (filter: string) => void;
  onSortChange?: (sort: string) => void;
  onLoadMore?: () => void;
  onTransactionPress?: (id: string) => void;
}

interface PosterTransaction {
  id: string;
  taskId: string;
  taskTitle: string;
  status: 'escrow_held' | 'released' | 'refunded' | 'disputed';
  amount: number;           // cents
  createdAt: string;
}
```

---

## 4. Shared Components

### 4.1 TransactionCard

```typescript
interface TransactionCardProps {
  type: 'earning' | 'withdrawal' | 'escrow' | 'refund';
  status: 'completed' | 'pending' | 'processing' | 'failed';
  title: string;
  subtitle: string;
  amount: number;           // cents
  onPress?: () => void;
}
```

#### Visual Spec

| Property | Value |
|----------|-------|
| Background | `colors.surface` |
| Border Radius | `radius.md` (12px) |
| Padding | `spacing.md` (16px) |
| Icon Size | 24px |
| Title | `typography.body`, `textPrimary` |
| Subtitle | `typography.caption`, `textSecondary` |
| Amount (positive) | `typography.body`, `colors.success` |
| Amount (negative) | `typography.body`, `textPrimary` |

#### Status Icons

| Status | Icon | Color |
|--------|------|-------|
| completed | ✓ Checkmark | `colors.success` |
| pending | ⏳ Clock | `colors.warning` |
| processing | ↻ Spinner | `colors.textSecondary` |
| failed | ✕ X | `colors.error` |

---

### 4.2 BalanceDisplay

```typescript
interface BalanceDisplayProps {
  label: string;
  amount: number;           // cents
  size?: 'large' | 'medium' | 'small';
}
```

#### Visual Spec

| Size | Label Style | Amount Style |
|------|-------------|--------------|
| large | `caption`, `textSecondary` | 48px, `700`, `textPrimary` |
| medium | `caption`, `textSecondary` | 32px, `600`, `textPrimary` |
| small | `micro`, `textTertiary` | 20px, `500`, `textPrimary` |

---

### 4.3 QuickAmountChip

```typescript
interface QuickAmountChipProps {
  amount: number | 'all';   // cents or 'all'
  isSelected?: boolean;
  onPress?: () => void;
}
```

#### Visual Spec

| State | Background | Text Color | Border |
|-------|------------|------------|--------|
| Default | `transparent` | `textSecondary` | 1px `divider` |
| Selected | `primary` | `white` | none |
| Disabled | `transparent` | `textTertiary` | 1px `divider` opacity 50% |

---

## 5. States & Flows

### 5.1 Withdrawal State Machine

```
┌─────────────────────────────────────────────────────┐
│                WITHDRAWAL FLOW                       │
├─────────────────────────────────────────────────────┤
│                                                      │
│  [IDLE] ─── onWithdraw ───► [AMOUNT_ENTRY]          │
│                                    │                 │
│                              onContinue              │
│                                    │                 │
│                                    ▼                 │
│                             [CONFIRMATION]           │
│                                    │                 │
│                    ┌───────────────┼───────────────┐ │
│                    │               │               │ │
│              onCancel         onConfirm       onError│
│                    │               │               │ │
│                    ▼               ▼               ▼ │
│                 [IDLE]       [PROCESSING]     [ERROR]│
│                                    │               │ │
│                                    │          onRetry│
│                              onSuccess            │  │
│                                    │               │ │
│                                    ▼               │ │
│                              [SUCCESS] ◄───────────┘ │
│                                    │                 │
│                              onComplete              │
│                                    │                 │
│                                    ▼                 │
│                                 [IDLE]               │
│                                                      │
└─────────────────────────────────────────────────────┘
```

### 5.2 Error States

| Error | Message | Action |
|-------|---------|--------|
| Insufficient balance | "You don't have enough funds to withdraw this amount." | Adjust amount |
| No bank account | "Add a bank account to withdraw funds." | Add account |
| Processing error | "We couldn't process your withdrawal. Please try again." | Retry |
| Network error | "Check your connection and try again." | Retry |

### 5.3 Loading States

| Screen | Loading Display |
|--------|-----------------|
| Wallet Home | Skeleton cards for balance + transactions |
| Withdrawal | Button spinner during processing |
| Transaction History | Skeleton list items |
| Payment Methods | Skeleton cards |

---

## Amendment History

| Version | Date | Summary |
|---------|------|---------|
| 1.0.0 | Jan 2025 | Initial Wallet UI specification |

---

**END OF WALLET UI SPECIFICATION**
