# XP Tax System Specification

**Status:** 🔒 LOCKED
**Version:** 1.0
**Layer:** 0 (Constitutional Enforcement via Database Triggers)
**Authority:** Layer 0 trigger blocks XP insertion if tax unpaid

---

## 1. Purpose & Motivation

### The Problem
Hustlers complete tasks and get paid offline (cash, Venmo, Cash App) to avoid the 20% platform fee. This undermines the platform's business model and creates unfair advantages.

**Example Scenario:**
- Task priced at $100
- Platform fee: $20 (20%)
- Hustler gets paid $100 cash offline → avoids fee
- Platform loses $20 in revenue
- Hustler gains XP/levels as if the transaction happened on-platform

### The Solution: XP Tax
**XP is ONLY awarded for payments processed through the platform's escrow system.**

If a hustler accepts offline payment, they must **pay a 10% XP tax** before receiving XP rewards. The tax blocks XP award until paid, incentivizing on-platform transactions.

**Formula:**
```
Tax Rate (Offline):  10% of gross payout
Tax Rate (Escrow):   0% (already through platform)
```

**Enforcement:** Database trigger at Layer 0 prevents XP insertion if unpaid offline tax exists.

---

## 2. Core Mechanics

### 2.1 Payment Methods

| Method | Fee | XP Tax | XP Award Timing |
|--------|-----|--------|-----------------|
| **Escrow (On-Platform)** | 20% | 0% | Immediate (on task completion) |
| **Offline Cash** | 0% (user avoids fee) | 10% | Blocked until tax paid |
| **Offline Venmo** | 0% (user avoids fee) | 10% | Blocked until tax paid |
| **Offline Cash App** | 0% (user avoids fee) | 10% | Blocked until tax paid |

### 2.2 Tax Calculation Example

**Task completed with $100 offline cash payment:**
```
Gross Payout:  $100
XP Tax (10%):  $10
Net to Hustler: $100 (tax deducted from future XP, not payout)

XP Calculation:
Base XP:       10,000 (100 XP per $1)
Status:        HELD (blocked until $10 tax paid)
```

**After hustler pays $10 tax:**
```
Tax Paid:      $10 via Stripe
XP Released:   10,000 XP awarded
```

---

## 3. Database Schema

### 3.1 XP Tax Ledger

```sql
CREATE TABLE xp_tax_ledger (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id),
  task_id UUID NOT NULL REFERENCES tasks(id),

  -- Tax calculation
  gross_payout_cents INTEGER NOT NULL CHECK (gross_payout_cents > 0),
  tax_percentage DECIMAL(5,2) NOT NULL CHECK (tax_percentage >= 0),
  tax_amount_cents INTEGER NOT NULL CHECK (tax_amount_cents >= 0),
  net_payout_cents INTEGER NOT NULL CHECK (net_payout_cents > 0),

  -- Payment tracking
  payment_method TEXT NOT NULL CHECK (payment_method IN ('escrow', 'offline_cash', 'offline_venmo', 'offline_cashapp')),
  tax_paid BOOLEAN NOT NULL DEFAULT FALSE,
  tax_paid_at TIMESTAMPTZ,

  -- Enforcement
  xp_held_back BOOLEAN NOT NULL DEFAULT FALSE,
  xp_released BOOLEAN NOT NULL DEFAULT FALSE,
  xp_released_at TIMESTAMPTZ,

  created_at TIMESTAMPTZ DEFAULT NOW(),

  UNIQUE(task_id, user_id) -- One tax entry per task per user
);

CREATE INDEX idx_xp_tax_user ON xp_tax_ledger(user_id);
CREATE INDEX idx_xp_tax_unpaid ON xp_tax_ledger(user_id, tax_paid) WHERE tax_paid = FALSE;
CREATE INDEX idx_xp_tax_held_back ON xp_tax_ledger(user_id, xp_held_back) WHERE xp_held_back = TRUE;
```

### 3.2 User XP Tax Status (Summary Table)

```sql
CREATE TABLE user_xp_tax_status (
  user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,

  total_unpaid_tax_cents INTEGER NOT NULL DEFAULT 0 CHECK (total_unpaid_tax_cents >= 0),
  total_xp_held_back INTEGER NOT NULL DEFAULT 0 CHECK (total_xp_held_back >= 0),

  offline_payments_blocked BOOLEAN NOT NULL DEFAULT FALSE,

  last_updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_xp_tax_status_unpaid ON user_xp_tax_status(total_unpaid_tax_cents) WHERE total_unpaid_tax_cents > 0;
```

---

## 4. Constitutional Trigger: XP Blocking

### 4.1 Trigger Definition

```sql
CREATE OR REPLACE FUNCTION enforce_xp_tax_payment()
RETURNS TRIGGER AS $$
DECLARE
  v_unpaid_tax_cents INTEGER;
BEGIN
  -- Check for unpaid offline taxes
  SELECT COALESCE(SUM(tax_amount_cents), 0)
  INTO v_unpaid_tax_cents
  FROM xp_tax_ledger
  WHERE user_id = NEW.user_id
    AND tax_paid = FALSE
    AND payment_method IN ('offline_cash', 'offline_venmo', 'offline_cashapp');

  -- If unpaid tax exists, block XP award
  IF v_unpaid_tax_cents > 0 THEN
    RAISE EXCEPTION 'XP-TAX-BLOCK: Cannot award XP. User has $% in unpaid offline taxes. Task ID: %',
      (v_unpaid_tax_cents::DECIMAL / 100), NEW.task_id
      USING ERRCODE = 'HX201';
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply trigger to xp_ledger (existing table)
CREATE TRIGGER trigger_enforce_xp_tax_payment
BEFORE INSERT ON xp_ledger
FOR EACH ROW
EXECUTE FUNCTION enforce_xp_tax_payment();
```

### 4.2 Error Code: HX201

| Code | Message | Layer | Bypass? |
|------|---------|-------|---------|
| `HX201` | `XP-TAX-BLOCK: Cannot award XP. User has $X in unpaid offline taxes.` | Layer 0 (DB Trigger) | ❌ No |

**Enforcement:** Even if application code is compromised, the database trigger prevents XP insertion.

---

## 5. Implementation Flow

```
┌────────────────────┐
│ Task completed     │
│ (offline payment)  │
└─────────┬──────────┘
          │
          v
┌────────────────────────┐
│ EscrowService.release()│
└─────────┬──────────────┘
          │
          v
┌────────────────────────┐
│ Check payment method   │
│ (escrow vs offline)    │
└─────────┬──────────────┘
          │
     ┌────┴────┐
     │         │
  ESCROW    OFFLINE
     │         │
     v         v
┌──────────┐  ┌────────────────────────┐
│ No tax   │  │ XPTaxService.          │
│ 0% tax   │  │ recordOfflinePayment() │
└────┬─────┘  └───────┬────────────────┘
     │                │
     │                v
     │        ┌────────────────────────┐
     │        │ Create xp_tax_ledger   │
     │        │ entry (tax_paid=FALSE) │
     │        └───────┬────────────────┘
     │                │
     v                v
┌──────────────────────────┐
│ XPService.awardXP()      │
└──────────┬───────────────┘
           │
           v
┌──────────────────────────┐
│ INSERT INTO xp_ledger    │
└──────────┬───────────────┘
           │
           v
┌──────────────────────────┐
│ Trigger:                 │
│ enforce_xp_tax_payment() │
└──────────┬───────────────┘
           │
      ┌────┴────┐
      │         │
   PASS       FAIL
      │         │
      v         v
┌──────────┐  ┌───────────────┐
│ XP       │  │ EXCEPTION:    │
│ awarded  │  │ XP-TAX-BLOCK  │
└──────────┘  └───────┬───────┘
                      │
                      v
              ┌────────────────┐
              │ Notify user:   │
              │ "Pay $X tax"   │
              └────────────────┘
```

---

## 6. Service Implementation

### 6.1 XPTaxService

```typescript
export class XPTaxService {
  /**
   * Record offline payment and calculate tax
   */
  static async recordOfflinePayment(
    userId: string,
    taskId: string,
    paymentMethod: 'offline_cash' | 'offline_venmo' | 'offline_cashapp',
    grossPayoutCents: number
  ): Promise<void> {
    const tax_percentage = 10.0; // 10% tax on offline payments
    const tax_amount_cents = Math.round(grossPayoutCents * (tax_percentage / 100));
    const net_payout_cents = grossPayoutCents; // Tax doesn't reduce payout

    await db.query(
      `INSERT INTO xp_tax_ledger (
        user_id, task_id, gross_payout_cents, tax_percentage,
        tax_amount_cents, net_payout_cents, payment_method, xp_held_back
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, TRUE)
      ON CONFLICT (task_id, user_id) DO NOTHING`,
      [userId, taskId, grossPayoutCents, tax_percentage, tax_amount_cents, net_payout_cents, paymentMethod]
    );

    // Update summary table
    await db.query(
      `INSERT INTO user_xp_tax_status (user_id, total_unpaid_tax_cents)
       VALUES ($1, $2)
       ON CONFLICT (user_id) DO UPDATE SET
         total_unpaid_tax_cents = user_xp_tax_status.total_unpaid_tax_cents + $2,
         last_updated_at = NOW()`,
      [userId, tax_amount_cents]
    );

    logger.info('Offline payment recorded with XP tax', {
      userId,
      taskId,
      paymentMethod,
      tax_amount_cents
    });
  }

  /**
   * Check user's unpaid tax balance
   */
  static async checkTaxStatus(userId: string): Promise<{
    unpaid_tax_cents: number;
    xp_held_back: number;
    blocked: boolean;
  }> {
    const result = await db.query(
      'SELECT total_unpaid_tax_cents, total_xp_held_back FROM user_xp_tax_status WHERE user_id = $1',
      [userId]
    );

    if (!result.rows[0]) {
      return { unpaid_tax_cents: 0, xp_held_back: 0, blocked: false };
    }

    return {
      unpaid_tax_cents: result.rows[0].total_unpaid_tax_cents,
      xp_held_back: result.rows[0].total_xp_held_back,
      blocked: result.rows[0].total_unpaid_tax_cents > 0
    };
  }

  /**
   * Pay accumulated XP tax via Stripe
   */
  static async payTax(
    userId: string,
    stripePaymentIntentId: string
  ): Promise<{ xp_released: number }> {
    // Verify Stripe payment succeeded
    const payment = await stripe.paymentIntents.retrieve(stripePaymentIntentId);
    if (payment.status !== 'succeeded') {
      throw new Error('Payment not succeeded');
    }

    const amount_paid_cents = payment.amount;

    // Get unpaid tax entries
    const unpaid_taxes = await db.query(
      'SELECT * FROM xp_tax_ledger WHERE user_id = $1 AND tax_paid = FALSE ORDER BY created_at ASC',
      [userId]
    );

    let remaining_payment = amount_paid_cents;
    let total_xp_released = 0;

    // Pay taxes in FIFO order
    for (const tax of unpaid_taxes.rows) {
      if (remaining_payment >= tax.tax_amount_cents) {
        // Mark tax as paid
        await db.query(
          `UPDATE xp_tax_ledger
           SET tax_paid = TRUE,
               tax_paid_at = NOW(),
               xp_released = TRUE,
               xp_released_at = NOW()
           WHERE id = $1`,
          [tax.id]
        );

        // Award held XP
        const xp_amount = Math.round(tax.gross_payout_cents / 10); // 100 XP per $1
        await XPService.awardXP(userId, tax.task_id, xp_amount);

        remaining_payment -= tax.tax_amount_cents;
        total_xp_released += xp_amount;
      }
    }

    // Update summary table
    await db.query(
      `UPDATE user_xp_tax_status
       SET total_unpaid_tax_cents = GREATEST(total_unpaid_tax_cents - $1, 0),
           total_xp_held_back = GREATEST(total_xp_held_back - $2, 0),
           last_updated_at = NOW()
       WHERE user_id = $3`,
      [amount_paid_cents, total_xp_released, userId]
    );

    return { xp_released: total_xp_released };
  }

  /**
   * Get tax payment history
   */
  static async getTaxHistory(userId: string): Promise<Array<{
    task_id: string;
    gross_payout_cents: number;
    tax_amount_cents: number;
    payment_method: string;
    tax_paid: boolean;
    created_at: string;
  }>> {
    const result = await db.query(
      `SELECT task_id, gross_payout_cents, tax_amount_cents, payment_method, tax_paid, created_at
       FROM xp_tax_ledger
       WHERE user_id = $1
       ORDER BY created_at DESC`,
      [userId]
    );

    return result.rows;
  }
}
```

---

## 7. Integration with EscrowService

```typescript
// In EscrowService.release()
async release(escrowId: string): Promise<void> {
  const escrow = await this.getEscrow(escrowId);

  // Check payment method
  const task = await TaskService.getTask(escrow.task_id);
  const payment_method = task.payment_method; // 'escrow' | 'offline_cash' | etc.

  if (payment_method !== 'escrow') {
    // Record offline payment with tax
    await XPTaxService.recordOfflinePayment(
      escrow.hustler_id,
      escrow.task_id,
      payment_method,
      escrow.amount_cents
    );
  }

  // Attempt XP award (will throw XP-TAX-BLOCK if tax unpaid)
  try {
    const xp_amount = Math.round(escrow.amount_cents / 10); // 100 XP per $1
    await XPService.awardXP(escrow.hustler_id, escrow.task_id, xp_amount);
  } catch (error) {
    if (error.code === 'HX201') {
      // XP blocked due to unpaid tax
      logger.info('XP blocked due to unpaid tax', {
        user_id: escrow.hustler_id,
        task_id: escrow.task_id
      });

      // Notify user
      await NotificationService.send({
        user_id: escrow.hustler_id,
        type: 'xp_tax_payment_required',
        title: 'XP On Hold',
        message: `Your XP for this task is held until you pay the $${(tax_amount / 100).toFixed(2)} offline payment tax.`,
        action_url: '/settings/xp-tax'
      });
    } else {
      throw error; // Re-throw non-tax errors
    }
  }

  // Complete escrow release
  await db.query(
    'UPDATE escrows SET status = $1, released_at = NOW() WHERE id = $2',
    ['RELEASED', escrowId]
  );
}
```

---

## 8. tRPC Router

### 8.1 xpTax Router

```typescript
export const xpTaxRouter = router({
  /**
   * Get current tax status
   */
  getTaxStatus: protectedProcedure.query(async ({ ctx }) => {
    return XPTaxService.checkTaxStatus(ctx.user.id);
  }),

  /**
   * Pay accumulated tax
   */
  payTax: protectedProcedure
    .input(z.object({
      stripe_payment_intent_id: z.string()
    }))
    .mutation(async ({ input, ctx }) => {
      const result = await XPTaxService.payTax(ctx.user.id, input.stripe_payment_intent_id);
      return {
        success: true,
        xp_released: result.xp_released,
        message: `Tax paid! ${result.xp_released} XP released.`
      };
    }),

  /**
   * Get tax payment history
   */
  getTaxHistory: protectedProcedure.query(async ({ ctx }) => {
    return XPTaxService.getTaxHistory(ctx.user.id);
  })
});
```

---

## 9. UI Integration

### 9.1 Profile Page: Tax Warning Banner

```typescript
// In ProfileScreen.tsx
const { data: taxStatus } = trpc.xpTax.getTaxStatus.useQuery();

{taxStatus.blocked && (
  <View style={{ backgroundColor: '#ff9800', padding: 16 }}>
    <Icon name="warning" size={24} color="#fff" />
    <Text style={{ color: '#fff', fontWeight: 'bold' }}>
      XP On Hold
    </Text>
    <Text style={{ color: '#fff' }}>
      You have ${(taxStatus.unpaid_tax_cents / 100).toFixed(2)} in unpaid XP taxes.
      {taxStatus.xp_held_back} XP is held back.
    </Text>
    <Button onPress={() => navigate('/settings/xp-tax')}>
      Pay Tax Now
    </Button>
  </View>
)}
```

### 9.2 Settings: XP Tax Payment Page

```typescript
// In XPTaxScreen.tsx
const { data: taxStatus } = trpc.xpTax.getTaxStatus.useQuery();
const { data: history } = trpc.xpTax.getTaxHistory.useQuery();
const payTaxMutation = trpc.xpTax.payTax.useMutation();

return (
  <View>
    <Text>XP Tax Payment</Text>

    {taxStatus.blocked ? (
      <View>
        <Text>Unpaid Tax: ${(taxStatus.unpaid_tax_cents / 100).toFixed(2)}</Text>
        <Text>XP Held Back: {taxStatus.xp_held_back} XP</Text>

        <Button onPress={async () => {
          // Create Stripe payment intent
          const payment_intent = await stripe.createPaymentIntent({
            amount: taxStatus.unpaid_tax_cents,
            currency: 'usd'
          });

          // Confirm payment
          const { paymentIntent } = await stripe.confirmCardPayment(payment_intent.client_secret);

          // Submit to backend
          await payTaxMutation.mutateAsync({
            stripe_payment_intent_id: paymentIntent.id
          });

          alert(`Tax paid! ${payTaxMutation.data.xp_released} XP released!`);
        }}>
          Pay Tax via Credit Card
        </Button>
      </View>
    ) : (
      <Text>No unpaid taxes. All XP awarded!</Text>
    )}

    <Text>Tax History</Text>
    <FlatList
      data={history}
      renderItem={({ item }) => (
        <View>
          <Text>Task: {item.task_id}</Text>
          <Text>Payout: ${(item.gross_payout_cents / 100).toFixed(2)}</Text>
          <Text>Tax: ${(item.tax_amount_cents / 100).toFixed(2)}</Text>
          <Text>Status: {item.tax_paid ? '✅ Paid' : '⏳ Unpaid'}</Text>
        </View>
      )}
    />
  </View>
);
```

---

## 10. Edge Cases

### Edge Case 1: User Has No Money to Pay Tax
**Scenario:** Hustler owes $50 in XP taxes but has no payment method

**Handling:**
- XP remains held indefinitely
- User can earn more money on-platform (escrow) to pay tax later
- Notification reminder every 7 days

### Edge Case 2: Partial Payment
**Scenario:** User owes $50 in taxes, pays $30

**Handling:**
```typescript
// In payTax() method: FIFO payment allocation
- Tax 1 ($20) → PAID, XP released
- Tax 2 ($20) → PAID, XP released
- Tax 3 ($10) → UNPAID (remaining $10 debt)
```

### Edge Case 3: Task Refunded After Tax Paid
**Scenario:** User pays $10 tax, gets XP, then task is refunded

**Handling:**
```typescript
// In RefundService.processRefund()
- Refund task payout
- Deduct XP (existing refund logic)
- Refund XP tax ($10 credit toward future taxes)
- Update xp_tax_ledger: tax_paid = FALSE, refund_issued = TRUE
```

### Edge Case 4: User Deletes Account with Unpaid Tax
**Scenario:** User owes $100 in taxes, deletes account

**Handling:**
- `user_xp_tax_status` has `ON DELETE CASCADE`
- Unpaid tax data deleted
- Platform absorbs loss (acceptable since user is gone)

---

## 11. Admin Tools

### 11.1 Admin Forgive Tax

```typescript
router.procedure('adminForgiveTax')
  .input(z.object({
    user_id: z.string(),
    reason: z.string()
  }))
  .mutation(async ({ input, ctx }) => {
    if (!ctx.user.is_admin) throw new TRPCError({ code: 'FORBIDDEN' });

    // Mark all unpaid taxes as forgiven
    await db.query(
      `UPDATE xp_tax_ledger
       SET tax_paid = TRUE,
           tax_paid_at = NOW(),
           forgiven = TRUE
       WHERE user_id = $1 AND tax_paid = FALSE`,
      [input.user_id]
    );

    // Reset summary
    await db.query(
      `UPDATE user_xp_tax_status
       SET total_unpaid_tax_cents = 0,
           last_updated_at = NOW()
       WHERE user_id = $1`,
      [input.user_id]
    );

    await AuditLogService.log({
      admin_id: ctx.user.id,
      action: 'forgive_xp_tax',
      target_user_id: input.user_id,
      reason: input.reason
    });
  });
```

### 11.2 Admin Dashboard: Tax Metrics

```sql
-- Total unpaid taxes
SELECT SUM(total_unpaid_tax_cents) / 100.0 as total_unpaid_dollars
FROM user_xp_tax_status;

-- Users with blocked XP
SELECT COUNT(*) as users_with_blocked_xp
FROM user_xp_tax_status
WHERE total_unpaid_tax_cents > 0;

-- Average tax per user
SELECT AVG(total_unpaid_tax_cents) / 100.0 as avg_unpaid_tax_dollars
FROM user_xp_tax_status
WHERE total_unpaid_tax_cents > 0;
```

---

## 12. Testing Requirements

### Unit Tests

```typescript
describe('XPTaxService', () => {
  it('should block XP award if offline tax unpaid', async () => {
    const user_id = 'test-user-1';
    const task_id = 'test-task-1';

    // Record offline payment with tax
    await XPTaxService.recordOfflinePayment(user_id, task_id, 'offline_cash', 10000);

    // Attempt XP award (should throw)
    await expect(
      XPService.awardXP(user_id, task_id, 1000)
    ).rejects.toThrow('XP-TAX-BLOCK');
  });

  it('should allow XP award after tax paid', async () => {
    const user_id = 'test-user-2';
    const task_id = 'test-task-2';

    // Record offline payment
    await XPTaxService.recordOfflinePayment(user_id, task_id, 'offline_cash', 10000);

    // Pay tax
    const payment_intent = await stripe.createPaymentIntent({ amount: 1000 });
    await XPTaxService.payTax(user_id, payment_intent.id);

    // Attempt XP award (should succeed)
    const result = await XPService.awardXP(user_id, task_id, 1000);
    expect(result.success).toBe(true);
  });

  it('should calculate 10% tax on offline payments', () => {
    const gross = 10000; // $100
    const expected_tax = 1000; // $10
    const actual_tax = Math.round(gross * 0.10);
    expect(actual_tax).toBe(expected_tax);
  });
});
```

### Integration Tests

```typescript
describe('XP Tax Integration', () => {
  it('should create tax ledger entry on offline payment', async () => {
    const task_id = 'test-task-3';

    // Complete task with offline payment
    await TaskService.complete(task_id, { payment_method: 'offline_cash' });

    // Check tax ledger
    const tax_entry = await db.query(
      'SELECT * FROM xp_tax_ledger WHERE task_id = $1',
      [task_id]
    );

    expect(tax_entry.rows[0].payment_method).toBe('offline_cash');
    expect(tax_entry.rows[0].tax_paid).toBe(false);
    expect(tax_entry.rows[0].xp_held_back).toBe(true);
  });
});
```

---

## 13. Deployment Checklist

- [ ] Migration 006 applied (xp_tax_ledger + user_xp_tax_status tables)
- [ ] Trigger `enforce_xp_tax_payment` created and tested
- [ ] XPTaxService implemented
- [ ] Integration with EscrowService tested
- [ ] xpTax router deployed
- [ ] UI tax payment page deployed
- [ ] Stripe payment integration tested
- [ ] Admin forgiveness tools deployed
- [ ] Notification system configured
- [ ] Monitoring dashboard configured
- [ ] Error code HX201 documented

---

## 14. Constitutional Enforcement Summary

| Rule | Enforced By | Bypass Possible? |
|------|-------------|------------------|
| XP blocked if tax unpaid | Database trigger (Layer 0) | ❌ No (DB-enforced) |
| 10% tax rate on offline | Service layer calculation | ⚠️ Yes (admin override) |
| Payment via Stripe | Service layer | ⚠️ Yes (admin forgiveness) |
| FIFO tax payment | Service layer logic | ⚠️ Yes (code bug) |

**Key Insight:** The XP blocking trigger operates at Layer 0 (database constitutional layer). Even if application code is compromised or an attacker gains API access, they CANNOT bypass the trigger. XP insertion is blocked at the database level.

---

**END OF SPECIFICATION**

_This specification is LOCKED and forms part of the constitutional layer of HustleXP. Changes require architectural review._
