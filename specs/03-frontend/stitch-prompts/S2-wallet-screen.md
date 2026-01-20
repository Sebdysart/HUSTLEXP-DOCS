# Screen S2: Wallet Screen
## Status: IMPLEMENTATION SPEC
**Authority:** DESIGN_SYSTEM.md, WALLET_UI_SPEC.md
**Cursor-Ready:** YES
**Role:** Hustler Only

---

## Overview

Hustler's earnings dashboard showing available balance, pending amounts, and transaction history. Entry point for withdrawals.

---

## Layout

```
┌─────────────────────────────────────────┐
│ ←  Wallet                               │
├─────────────────────────────────────────┤
│                                         │
│  ┌─────────────────────────────────────┐│
│  │                                     ││
│  │         Available Balance           ││  ← typography.bodySmall
│  │                                     ││
│  │           $847.50                   ││  ← typography.display
│  │                                     ││
│  │    Pending: $125.00                 ││  ← Pending amount
│  │                                     ││
│  │  ┌─────────────────────────────────┐││
│  │  │         Withdraw                │││  ← Primary button
│  │  └─────────────────────────────────┘││
│  │                                     ││
│  └─────────────────────────────────────┘│
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ 📊 This Week                        ││
│  │                                     ││
│  │ Earned: $324.00     Tasks: 8        ││
│  │                                     ││
│  │ ▁▂▄▆█▇▅▃                            ││  ← Mini chart
│  │ M T W T F S S                       ││
│  │                                     ││
│  └─────────────────────────────────────┘│
│                                         │
│  Recent Transactions                    │  ← Section header
│  ─────────────────────────────────────  │
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ ↓ Task Payment               +$75.00││  ← Incoming
│  │   Move furniture                    ││
│  │   Today, 3:45 PM                    ││
│  └─────────────────────────────────────┘│
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ ↑ Withdrawal               -$500.00 ││  ← Outgoing
│  │   To Bank •••• 4521                 ││
│  │   Jan 18, 2025                      ││
│  └─────────────────────────────────────┘│
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ ↓ Task Payment               +$25.00││
│  │   Grocery delivery                  ││
│  │   Jan 18, 2025                      ││
│  └─────────────────────────────────────┘│
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ ↓ Tip Received               +$10.00││  ← Tip
│  │   From Sarah M.                     ││
│  │   Jan 17, 2025                      ││
│  └─────────────────────────────────────┘│
│                                         │
│  [View All Transactions]                │
│                                         │
└─────────────────────────────────────────┘
```

---

## Props Interface

```typescript
interface WalletScreenProps {
  // Balance
  balance?: {
    available: number;      // cents
    pending: number;        // cents
    total: number;          // cents
  };

  // Weekly stats
  weeklyStats?: {
    earned: number;         // cents
    taskCount: number;
    dailyEarnings: number[]; // 7 days, cents
  };

  // Recent transactions
  transactions?: Transaction[];

  // State
  isLoading?: boolean;
  error?: Error | null;

  // Callbacks
  onWithdraw?: () => void;
  onViewAllTransactions?: () => void;
  onTransactionPress?: (transactionId: string) => void;
  onBack?: () => void;
}

interface Transaction {
  id: string;
  type: 'TASK_PAYMENT' | 'TIP' | 'WITHDRAWAL' | 'REFUND' | 'FEE';
  amount: number;           // cents, positive for incoming, negative for outgoing
  description: string;
  metadata?: string;        // Task title, bank last four, etc.
  createdAt: string;
  status: 'COMPLETED' | 'PENDING' | 'FAILED';
}
```

---

## Visual Spec

| Element | Style |
|---------|-------|
| Header | Back button + title |
| Balance card | `colors.primary[500]` gradient bg |
| Balance label | `typography.bodySmall`, white 70% |
| Balance amount | `typography.display`, white |
| Pending text | `typography.bodySmall`, white 70% |
| Withdraw button | White bg, `colors.primary[500]` text |
| Stats card | `cardStyles.default` |
| Stats label | `typography.bodySmall`, `colors.neutral[600]` |
| Stats value | `typography.body`, `fontWeight: 600` |
| Mini chart | Bars, `colors.primary[500]` |
| Section header | `typography.bodySmall`, `colors.neutral[500]` |
| Transaction cards | `cardStyles.outlined`, subtle |
| Direction icon | ↓ `colors.success`, ↑ `colors.neutral[500]` |
| Transaction type | `typography.body`, `fontWeight: 500` |
| Amount (incoming) | `typography.body`, `colors.success`, `fontWeight: 600` |
| Amount (outgoing) | `typography.body`, `colors.neutral[700]`, `fontWeight: 600` |
| Metadata | `typography.bodySmall`, `colors.neutral[600]` |
| Timestamp | `typography.caption`, `colors.neutral[500]` |
| View all link | `typography.body`, `colors.primary[500]`, centered |

---

## Transaction Types

| Type | Icon | Label |
|------|------|-------|
| TASK_PAYMENT | ↓ (green) | Task Payment |
| TIP | ↓ (green) | Tip Received |
| WITHDRAWAL | ↑ (gray) | Withdrawal |
| REFUND | ↓ (green) | Refund |
| FEE | ↑ (gray) | Platform Fee |

---

## Balance States

### Has Balance
- Show full UI with withdraw button enabled

### Zero Balance
```
Available Balance
$0.00

Complete tasks to start earning!

[Withdraw] ← Disabled
```

### Pending Only
```
Available Balance
$0.00

Pending: $125.00
Funds available after task completion

[Withdraw] ← Disabled
```

---

## Withdraw Button

- Enabled when `available > 0`
- Disabled when `available === 0`
- Minimum withdrawal: $5.00

---

**This screen is Cursor-ready. Build exactly as specified.**
