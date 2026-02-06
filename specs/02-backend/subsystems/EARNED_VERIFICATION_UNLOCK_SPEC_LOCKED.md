# Earned Verification Unlock Specification

**Status:** 🔒 LOCKED
**Version:** 1.0
**Layer:** 1 (Service/Business Logic)
**Enforcement:** Constitutional (Database Triggers + Service Layer)

---

## 1. Purpose & Motivation

### The Problem
Identity verification (background checks, driver's license validation) costs the platform $15-$50 per hustler. If we require verification upfront:
- High barrier to entry → fewer hustlers sign up
- Platform pays verification costs for hustlers who never complete tasks
- Wasted money on low-commitment users

### The Solution: Earned Unlock
**Hustlers unlock FREE identity verification after earning the platform $40 net profit.**

**Formula:**
```
Net Profit = Total Task Payouts × Platform Fee (20%)
$40 profit = $200 in completed tasks × 20% = $40
```

**Key Insight:** If a hustler generates $40 profit, they've proven commitment and are worth investing in. The platform can afford to "pay back" the verification cost ($15-$50) as an earned reward.

---

## 2. Core Mechanics

### 2.1 Eligibility Criteria

| Requirement | Value | Notes |
|-------------|-------|-------|
| **Cumulative Net Earnings** | ≥ $40 | After platform fees (20%) deducted |
| **Task Completion** | ≥ 1 task | Must have completed at least one task |
| **Refunds Excluded** | Yes | Refunded tasks do NOT count toward threshold |
| **Account Status** | Active | Not banned or suspended |

### 2.2 Tracking System

**Two Tables:**

1. **`verification_earnings_tracking`** (snapshot table)
   - One row per user
   - Stores cumulative earnings, unlock status
   - Updated on every task completion

2. **`verification_earnings_ledger`** (append-only ledger)
   - One row per task completion
   - Immutable record of earnings
   - Idempotent via `UNIQUE(escrow_id)` constraint

### 2.3 Unlock Flow

```
1. Hustler completes task → EscrowService.release()
2. Service calls EarnedVerificationUnlockService.recordEarnings()
3. Ledger entry created (idempotent via escrow_id)
4. Trigger updates verification_earnings_tracking
5. If cumulative_earnings ≥ $40 → earned_unlock_achieved = TRUE
6. Notification sent: "Congrats! Free verification unlocked 🎉"
7. User navigates to Settings → Verification → Submit License
8. Router checks earned_unlock_achieved before allowing submission
```

---

## 3. Database Schema

### 3.1 Tracking Table

```sql
CREATE TABLE verification_earnings_tracking (
  user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,

  -- Cumulative earnings (post-fee)
  total_net_earnings_cents INTEGER NOT NULL DEFAULT 0 CHECK (total_net_earnings_cents >= 0),

  -- Unlock thresholds
  earned_unlock_threshold_cents INTEGER NOT NULL DEFAULT 4000, -- $40
  earned_unlock_achieved BOOLEAN NOT NULL DEFAULT FALSE,
  earned_unlock_achieved_at TIMESTAMPTZ,

  -- Task count for eligibility
  completed_task_count INTEGER NOT NULL DEFAULT 0 CHECK (completed_task_count >= 0),

  -- Audit
  last_updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_verification_earnings_unlocked
  ON verification_earnings_tracking(earned_unlock_achieved)
  WHERE earned_unlock_achieved = TRUE;
```

### 3.2 Ledger Table (Append-Only)

```sql
CREATE TABLE verification_earnings_ledger (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id),
  task_id UUID NOT NULL REFERENCES tasks(id),
  escrow_id UUID NOT NULL, -- Links to escrow release

  net_payout_cents INTEGER NOT NULL CHECK (net_payout_cents > 0),

  cumulative_earnings_before_cents INTEGER NOT NULL,
  cumulative_earnings_after_cents INTEGER NOT NULL,

  awarded_at TIMESTAMPTZ DEFAULT NOW(),

  UNIQUE(escrow_id) -- Idempotent: one entry per escrow release
);

CREATE INDEX idx_verification_earnings_ledger_user
  ON verification_earnings_ledger(user_id);
CREATE INDEX idx_verification_earnings_ledger_awarded
  ON verification_earnings_ledger(awarded_at DESC);
```

### 3.3 Trigger: Update Tracking on Ledger Insert

```sql
CREATE OR REPLACE FUNCTION update_verification_earnings_tracking()
RETURNS TRIGGER AS $$
BEGIN
  -- Update tracking table
  INSERT INTO verification_earnings_tracking (
    user_id,
    total_net_earnings_cents,
    completed_task_count
  )
  VALUES (
    NEW.user_id,
    NEW.cumulative_earnings_after_cents,
    1
  )
  ON CONFLICT (user_id) DO UPDATE SET
    total_net_earnings_cents = NEW.cumulative_earnings_after_cents,
    completed_task_count = verification_earnings_tracking.completed_task_count + 1,
    last_updated_at = NOW();

  -- Check if threshold achieved
  UPDATE verification_earnings_tracking
  SET
    earned_unlock_achieved = TRUE,
    earned_unlock_achieved_at = COALESCE(earned_unlock_achieved_at, NOW())
  WHERE user_id = NEW.user_id
    AND total_net_earnings_cents >= earned_unlock_threshold_cents
    AND earned_unlock_achieved = FALSE;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_verification_earnings_tracking
AFTER INSERT ON verification_earnings_ledger
FOR EACH ROW
EXECUTE FUNCTION update_verification_earnings_tracking();
```

---

## 4. Service Implementation

### 4.1 EarnedVerificationUnlockService

```typescript
export class EarnedVerificationUnlockService {
  /**
   * Record net earnings from task completion
   * Idempotent via escrow_id unique constraint
   */
  static async recordEarnings(
    userId: string,
    taskId: string,
    escrowId: string,
    netPayoutCents: number
  ): Promise<void> {
    // Get current cumulative earnings
    const tracking = await db.query(
      'SELECT total_net_earnings_cents FROM verification_earnings_tracking WHERE user_id = $1',
      [userId]
    );

    const cumulative_before = tracking.rows[0]?.total_net_earnings_cents || 0;
    const cumulative_after = cumulative_before + netPayoutCents;

    // Insert into ledger (idempotent via UNIQUE constraint on escrow_id)
    try {
      await db.query(
        `INSERT INTO verification_earnings_ledger (
          user_id, task_id, escrow_id, net_payout_cents,
          cumulative_earnings_before_cents, cumulative_earnings_after_cents
        ) VALUES ($1, $2, $3, $4, $5, $6)
        ON CONFLICT (escrow_id) DO NOTHING`,
        [userId, taskId, escrowId, netPayoutCents, cumulative_before, cumulative_after]
      );

      // Trigger handles updating verification_earnings_tracking
    } catch (error) {
      logger.error('Failed to record earnings', { userId, taskId, error });
      throw error;
    }
  }

  /**
   * Check if user has unlocked verification
   */
  static async checkUnlockEligibility(userId: string): Promise<boolean> {
    const result = await db.query(
      'SELECT earned_unlock_achieved FROM verification_earnings_tracking WHERE user_id = $1',
      [userId]
    );

    return result.rows[0]?.earned_unlock_achieved || false;
  }

  /**
   * Get unlock progress for UI display
   */
  static async getUnlockProgress(userId: string): Promise<{
    earned_cents: number;
    threshold_cents: number;
    percentage: number;
    unlocked: boolean;
    tasks_completed: number;
  }> {
    const result = await db.query(
      `SELECT
        total_net_earnings_cents,
        earned_unlock_threshold_cents,
        earned_unlock_achieved,
        completed_task_count
      FROM verification_earnings_tracking
      WHERE user_id = $1`,
      [userId]
    );

    if (!result.rows[0]) {
      return {
        earned_cents: 0,
        threshold_cents: 4000,
        percentage: 0,
        unlocked: false,
        tasks_completed: 0
      };
    }

    const row = result.rows[0];
    const percentage = Math.min(
      (row.total_net_earnings_cents / row.earned_unlock_threshold_cents) * 100,
      100
    );

    return {
      earned_cents: row.total_net_earnings_cents,
      threshold_cents: row.earned_unlock_threshold_cents,
      percentage,
      unlocked: row.earned_unlock_achieved,
      tasks_completed: row.completed_task_count
    };
  }

  /**
   * Grant verification access (called after unlock achieved)
   */
  static async unlockVerificationAccess(userId: string): Promise<void> {
    await db.query(
      `UPDATE users
       SET verification_unlocked = TRUE
       WHERE id = $1`,
      [userId]
    );

    // Send notification
    await NotificationService.send({
      user_id: userId,
      type: 'verification_unlocked',
      title: 'Free Verification Unlocked! 🎉',
      message: 'You've earned $40 for the platform! Submit your license for free identity verification.',
      action_url: '/settings/verification'
    });
  }
}
```

---

## 5. Integration Points

### 5.1 EscrowService.release() Integration

```typescript
// In EscrowService.release()
async release(escrowId: string): Promise<void> {
  // ... existing escrow release logic ...

  // Calculate net payout (after platform fee)
  const gross_payout_cents = escrow.amount_cents;
  const platform_fee_cents = Math.round(gross_payout_cents * 0.20); // 20% fee
  const net_payout_cents = gross_payout_cents - platform_fee_cents;

  // Record earnings for verification unlock tracking
  await EarnedVerificationUnlockService.recordEarnings(
    escrow.hustler_id,
    escrow.task_id,
    escrowId,
    net_payout_cents
  );

  // Check if unlock achieved (trigger handles this, but we notify here)
  const unlocked = await EarnedVerificationUnlockService.checkUnlockEligibility(
    escrow.hustler_id
  );

  if (unlocked) {
    await EarnedVerificationUnlockService.unlockVerificationAccess(escrow.hustler_id);
  }
}
```

### 5.2 Verification Router Gating

```typescript
// In verification/submitLicense route
router.procedure('submitLicense')
  .input(z.object({
    license_front_url: z.string(),
    license_back_url: z.string()
  }))
  .mutation(async ({ input, ctx }) => {
    // Check if user has unlocked verification
    const unlocked = await EarnedVerificationUnlockService.checkUnlockEligibility(
      ctx.user.id
    );

    if (!unlocked) {
      const progress = await EarnedVerificationUnlockService.getUnlockProgress(
        ctx.user.id
      );

      throw new TRPCError({
        code: 'FORBIDDEN',
        message: `Verification not unlocked. Earn $${(progress.threshold_cents - progress.earned_cents) / 100} more to unlock. Progress: ${progress.percentage.toFixed(0)}%`
      });
    }

    // Proceed with license submission
    // ...
  });
```

---

## 6. UI Integration

### 6.1 Profile Page: Progress Bar

```typescript
// In ProfileScreen.tsx
const { data: progress } = trpc.users.getVerificationUnlockProgress.useQuery();

return (
  <View>
    <Text>Identity Verification</Text>
    {!progress.unlocked ? (
      <View>
        <ProgressBar value={progress.percentage} />
        <Text>
          ${(progress.earned_cents / 100).toFixed(2)} / ${(progress.threshold_cents / 100).toFixed(2)} earned
        </Text>
        <Text>
          {progress.tasks_completed} tasks completed
        </Text>
        <Text style={{ color: 'gray' }}>
          Complete tasks to unlock FREE identity verification!
        </Text>
      </View>
    ) : (
      <View>
        <Text>✅ Verification Unlocked!</Text>
        <Button onPress={() => navigate('/settings/verification')}>
          Submit License
        </Button>
      </View>
    )}
  </View>
);
```

### 6.2 Settings: Verification Page

```typescript
// In VerificationScreen.tsx
const { data: progress } = trpc.users.getVerificationUnlockProgress.useQuery();

if (!progress.unlocked) {
  return (
    <View>
      <Icon name="lock" size={64} color="#888" />
      <Text>Verification Locked</Text>
      <Text>
        Earn ${((progress.threshold_cents - progress.earned_cents) / 100).toFixed(2)} more
        to unlock FREE identity verification.
      </Text>
      <ProgressBar value={progress.percentage} />
      <Button onPress={() => navigate('/tasks')}>
        Browse Tasks
      </Button>
    </View>
  );
}

return (
  <View>
    <Text>Identity Verification</Text>
    <Button onPress={() => openCamera()}>
      Submit Driver's License
    </Button>
  </View>
);
```

### 6.3 Notification: Unlock Achievement

```json
{
  "type": "verification_unlocked",
  "title": "Free Verification Unlocked! 🎉",
  "message": "You've earned $40 for the platform! Submit your license for free identity verification.",
  "action_url": "/settings/verification",
  "icon": "🎉",
  "priority": "high"
}
```

---

## 7. Edge Cases & Handling

### Edge Case 1: Refunded Task
**Scenario:** Task completed, earnings recorded, then task refunded

**Handling:**
```typescript
// In RefundService.processRefund()
async processRefund(taskId: string, reason: string) {
  // ... existing refund logic ...

  // Reverse earnings in ledger
  const ledger_entry = await db.query(
    'SELECT * FROM verification_earnings_ledger WHERE task_id = $1',
    [taskId]
  );

  if (ledger_entry.rows.length > 0) {
    // Create negative ledger entry (reversal)
    await db.query(
      `INSERT INTO verification_earnings_ledger (
        user_id, task_id, escrow_id, net_payout_cents,
        cumulative_earnings_before_cents, cumulative_earnings_after_cents
      ) VALUES ($1, $2, $3, $4, $5, $6)`,
      [
        ledger_entry.rows[0].user_id,
        taskId,
        `refund-${ledger_entry.rows[0].escrow_id}`, // Unique escrow_id for reversal
        -ledger_entry.rows[0].net_payout_cents, // Negative payout
        ledger_entry.rows[0].cumulative_earnings_after_cents,
        ledger_entry.rows[0].cumulative_earnings_after_cents - ledger_entry.rows[0].net_payout_cents
      ]
    );

    // If user dropped below $40 threshold, revoke unlock
    const updated_earnings = await db.query(
      'SELECT total_net_earnings_cents FROM verification_earnings_tracking WHERE user_id = $1',
      [ledger_entry.rows[0].user_id]
    );

    if (updated_earnings.rows[0].total_net_earnings_cents < 4000) {
      await db.query(
        `UPDATE verification_earnings_tracking
         SET earned_unlock_achieved = FALSE
         WHERE user_id = $1`,
        [ledger_entry.rows[0].user_id]
      );

      // Notify user
      await NotificationService.send({
        user_id: ledger_entry.rows[0].user_id,
        type: 'verification_revoked',
        title: 'Verification Access Revoked',
        message: 'A refunded task dropped you below $40 earnings. Complete more tasks to re-unlock.'
      });
    }
  }
}
```

### Edge Case 2: User Deletes Account Before Unlock
**Scenario:** User completes tasks, earns $35, then deletes account

**Handling:**
- `verification_earnings_tracking` has `ON DELETE CASCADE`
- Ledger data deleted automatically
- No recovery needed (user chose to delete)

### Edge Case 3: Platform Fee Changes
**Scenario:** Platform changes fee from 20% to 25%

**Handling:**
```typescript
// Store fee percentage in ledger for audit trail
ALTER TABLE verification_earnings_ledger
ADD COLUMN platform_fee_percentage DECIMAL(5,2) DEFAULT 20.00;

// Calculate net payout dynamically
const platform_fee_percentage = await ConfigService.getPlatformFee(); // 20% or 25%
const platform_fee_cents = Math.round(gross_payout_cents * (platform_fee_percentage / 100));
const net_payout_cents = gross_payout_cents - platform_fee_cents;
```

### Edge Case 4: Abuse: User Creates Multiple Accounts
**Scenario:** User creates 5 accounts, completes 1 task on each to unlock verification 5 times

**Detection:**
- Device fingerprinting (same device ID across accounts)
- IP address matching
- Payment method matching (same Stripe Connect account)

**Prevention:**
```typescript
// In verification submission
const similar_accounts = await db.query(`
  SELECT COUNT(DISTINCT u.id)
  FROM users u
  JOIN device_fingerprints df ON df.user_id = u.id
  WHERE df.device_id = $1
    AND u.verification_submitted = TRUE
    AND u.id != $2
`, [ctx.device_id, ctx.user.id]);

if (similar_accounts.rows[0].count > 2) {
  throw new TRPCError({
    code: 'FORBIDDEN',
    message: 'Multiple accounts detected from this device. Contact support.'
  });
}
```

---

## 8. Admin Tools

### 8.1 Admin Override: Grant Unlock Early

```typescript
router.procedure('adminGrantVerificationUnlock')
  .input(z.object({
    user_id: z.string(),
    reason: z.string()
  }))
  .mutation(async ({ input, ctx }) => {
    if (!ctx.user.is_admin) throw new TRPCError({ code: 'FORBIDDEN' });

    await db.query(
      `UPDATE verification_earnings_tracking
       SET earned_unlock_achieved = TRUE,
           earned_unlock_achieved_at = NOW()
       WHERE user_id = $1`,
      [input.user_id]
    );

    await AuditLogService.log({
      admin_id: ctx.user.id,
      action: 'grant_verification_unlock',
      target_user_id: input.user_id,
      reason: input.reason
    });
  });
```

### 8.2 Admin Dashboard: Unlock Metrics

```sql
-- Unlock achievement rate
SELECT
  COUNT(*) FILTER (WHERE earned_unlock_achieved = TRUE) as unlocked_users,
  COUNT(*) as total_users,
  (COUNT(*) FILTER (WHERE earned_unlock_achieved = TRUE)::FLOAT / COUNT(*)) * 100 as unlock_percentage
FROM verification_earnings_tracking;

-- Average earnings to unlock
SELECT AVG(total_net_earnings_cents) as avg_earnings_cents
FROM verification_earnings_tracking
WHERE earned_unlock_achieved = TRUE;

-- Time to unlock (days)
SELECT AVG(EXTRACT(EPOCH FROM (earned_unlock_achieved_at - created_at)) / 86400) as avg_days_to_unlock
FROM verification_earnings_tracking
WHERE earned_unlock_achieved = TRUE;
```

---

## 9. Testing Requirements

### Unit Tests

```typescript
describe('EarnedVerificationUnlockService', () => {
  it('should unlock after $40 net earnings', async () => {
    const user_id = 'test-user-1';

    // Simulate 2 tasks: $25 + $20 = $45 net
    await EarnedVerificationUnlockService.recordEarnings(user_id, 'task-1', 'escrow-1', 2500);
    await EarnedVerificationUnlockService.recordEarnings(user_id, 'task-2', 'escrow-2', 2000);

    const unlocked = await EarnedVerificationUnlockService.checkUnlockEligibility(user_id);
    expect(unlocked).toBe(true);
  });

  it('should not unlock before $40', async () => {
    const user_id = 'test-user-2';

    // Simulate 1 task: $30 net
    await EarnedVerificationUnlockService.recordEarnings(user_id, 'task-1', 'escrow-1', 3000);

    const unlocked = await EarnedVerificationUnlockService.checkUnlockEligibility(user_id);
    expect(unlocked).toBe(false);
  });

  it('should be idempotent via escrow_id', async () => {
    const user_id = 'test-user-3';

    // Try to record same escrow twice
    await EarnedVerificationUnlockService.recordEarnings(user_id, 'task-1', 'escrow-1', 2500);
    await EarnedVerificationUnlockService.recordEarnings(user_id, 'task-1', 'escrow-1', 2500);

    const progress = await EarnedVerificationUnlockService.getUnlockProgress(user_id);
    expect(progress.earned_cents).toBe(2500); // Not 5000 (duplicate prevented)
  });
});
```

### Integration Tests

```typescript
describe('Verification Unlock Integration', () => {
  it('should gate verification submission before unlock', async () => {
    const user_id = 'test-user-4';

    // User with $30 earnings (below threshold)
    await EarnedVerificationUnlockService.recordEarnings(user_id, 'task-1', 'escrow-1', 3000);

    // Attempt license submission
    await expect(
      VerificationService.submitLicense(user_id, 'license_front_url', 'license_back_url')
    ).rejects.toThrow('Verification not unlocked');
  });

  it('should allow verification submission after unlock', async () => {
    const user_id = 'test-user-5';

    // User with $50 earnings (above threshold)
    await EarnedVerificationUnlockService.recordEarnings(user_id, 'task-1', 'escrow-1', 5000);

    // Attempt license submission (should succeed)
    const result = await VerificationService.submitLicense(
      user_id,
      'license_front_url',
      'license_back_url'
    );

    expect(result.success).toBe(true);
  });
});
```

---

## 10. Deployment Checklist

- [ ] Migration 005 applied (verification_earnings_tracking + ledger tables)
- [ ] Trigger `update_verification_earnings_tracking` created and tested
- [ ] EarnedVerificationUnlockService implemented
- [ ] Integration with EscrowService.release() tested
- [ ] Verification router gating implemented
- [ ] UI progress bars deployed (Profile + Settings)
- [ ] Notification system configured for unlock achievement
- [ ] Admin override tools deployed
- [ ] Refund reversal logic tested
- [ ] Idempotency verified (duplicate escrow_id handling)
- [ ] Monitoring dashboard configured

---

## 11. Constitutional Enforcement Summary

| Rule | Enforced By | Bypass Possible? |
|------|-------------|------------------|
| $40 threshold | Database trigger | ❌ No (DB-enforced) |
| Idempotency (escrow_id) | UNIQUE constraint | ❌ No (DB-enforced) |
| Cumulative earnings calculation | Trigger logic | ⚠️ Yes (trigger bug only) |
| Verification gating | Router + Service layer | ⚠️ Yes (admin override) |
| Refund reversals | Application code | ⚠️ Yes (code bug) |

**Key Insight:** The $40 threshold is constitutionally enforced at Layer 0 (database trigger). Even if application code is compromised, users cannot bypass the earnings requirement.

---

**END OF SPECIFICATION**

_This specification is LOCKED and forms part of the constitutional layer of HustleXP. Changes require architectural review._
