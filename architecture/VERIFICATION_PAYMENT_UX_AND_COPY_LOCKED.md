# Verification Payment UX & Copy — LOCKED
## Status: APPROVED — MAX-Tier System Architecture
## Version: v1.0
## Authority: System Architecture — Non-Negotiable

---

**Verdict:** This is the last dangerous surface. If payment UX is sloppy, you undo everything you've built and drift into pay-to-play. If it's precise, monetization feels inevitable and clean. Money never buys access. Money only covers the cost of validating facts. Payment is downstream of eligibility and upstream of verification execution—never tied to feed access directly. This completes the closed, institutional loop.

---

## Core Law (Non-Negotiable)

**Money never buys access.**
**Money only covers the cost of validating facts.**

If this law is violated, trust leaks, monetization becomes pay-to-play, and the system becomes untrustworthy.

---

## Payment Position in Authority Chain

**Payment is downstream of eligibility and upstream of verification execution.**

**Authority Chain:**
1. **Eligibility Pre-Check** (must pass before payment)
2. **Payment** (unlocks verification processing)
3. **Verification Execution** (validates facts)
4. **Recomputation** (derives capability profile)
5. **Feed** (shows eligible tasks)

**Payment never tied to feed access directly.**

**Rule:**
> Payment unlocks verification processing, not capability profile updates.
> Capability profile is derived from verification records, not payment status.

---

## Where Payment Is Allowed to Appear (Strict)

**Payment UI may appear only in these locations:**

### 1. Settings → Work Eligibility → Verify / Renew

**Context:**
- User navigates to Settings → Work Eligibility
- User clicks "Verify license" or "Renew verification" button
- Payment screen appears (after eligibility pre-check passes)

**Flow:**
```
Settings → Work Eligibility
  → [Verify license] button
    → Eligibility Pre-Check (silent)
      → Payment Screen (if pre-check passes)
        → Verification Submission
          → Return to Settings
```

---

### 2. Onboarding → Post-Summary "Next Steps" Screen

**Context:**
- User completes onboarding (PHASE 7: Summary & Next Actions)
- User sees upgrade opportunities (computed, not estimated)
- User clicks "Start Verification" button
- Payment screen appears (after eligibility pre-check passes)

**Flow:**
```
Onboarding → Summary
  → [Start Verification] button (from upgrade opportunity)
    → Eligibility Pre-Check (silent)
      → Payment Screen (if pre-check passes)
        → Verification Submission
          → Return to Onboarding Summary (or Settings)
```

---

**Payment must never appear in:**
- ❌ Feed (feed shows only eligible tasks, no payment prompts)
- ❌ Task cards (task cards show task details, not payment)
- ❌ Apply flows (apply endpoint returns 403 if not eligible, no payment)
- ❌ Trust tier displays (trust tier is earned, not purchased)

**If users see money next to gigs, you've failed.**

---

## Payment Trigger Rules (Hard Gates)

**A payment option is shown only if all are true:**

### Gate 1: User Has Claimed a Regulated Capability

**Check:**
```typescript
const hasClaimedTrade = await hasClaimedRegulatedTrade(userId, trade);
if (!hasClaimedTrade) {
  return { showPayment: false, reason: 'No claimed trade' };
}
```

**Why:**
- Payment is for verification processing (not capability claims)
- User must claim capability first (onboarding or Settings)
- Cannot pay for verification without claimed capability

---

### Gate 2: Eligibility Pre-Check Has Passed

**Check:**
```typescript
const preCheckResult = await preCheckEligibility(userId, trade);
if (!preCheckResult.passed) {
  return { showPayment: false, reason: preCheckResult.failure_reason };
}
```

**Pre-Check Includes:**
- License format valid (if applicable)
- Trade allowed in state (if applicable)
- User identity already verified (required)

**Why:**
- Payment is for verification processing (not eligibility bypass)
- Pre-check must pass before payment (no payment if pre-check fails)
- Pre-check failure means verification will fail (no point in payment)

---

### Gate 3: Required Identity Verification Is Already Complete

**Check:**
```typescript
const identityVerified = await isUserIdentityVerified(userId);
if (!identityVerified) {
  return { showPayment: false, reason: 'Identity verification required' };
}
```

**Why:**
- Identity verification is prerequisite (cannot verify license without identity)
- Identity verification is free (not paid)
- Payment is for credential verification (not identity verification)

---

### Gate 4: No Active Verification Already Exists

**Check:**
```typescript
const activeVerification = await getActiveVerification(userId, trade);
if (activeVerification) {
  return { showPayment: false, reason: 'Active verification already exists' };
}
```

**Why:**
- Payment is per verification (not per capability)
- Cannot pay for duplicate verification (one active verification per trade/state)
- Active verification means payment already made (no duplicate charges)

---

### Pseudologic

```typescript
function shouldShowPayment(
  userId: string,
  trade: string
): { showPayment: boolean; reason?: string } {
  // Gate 1: User has claimed regulated capability
  const hasClaimedTrade = await hasClaimedRegulatedTrade(userId, trade);
  if (!hasClaimedTrade) {
    return { showPayment: false, reason: 'No claimed trade' };
  }

  // Gate 2: Eligibility pre-check has passed
  const preCheckResult = await preCheckEligibility(userId, trade);
  if (!preCheckResult.passed) {
    return { showPayment: false, reason: preCheckResult.failure_reason };
  }

  // Gate 3: Identity verification is complete
  const identityVerified = await isUserIdentityVerified(userId);
  if (!identityVerified) {
    return { showPayment: false, reason: 'Identity verification required' };
  }

  // Gate 4: No active verification exists
  const activeVerification = await getActiveVerification(userId, trade);
  if (activeVerification) {
    return { showPayment: false, reason: 'Active verification already exists' };
  }

  // All gates passed
  return { showPayment: true };
}
```

**If any condition fails → payment UI is hidden, not disabled.**

**Why Hidden (Not Disabled):**
- Disabled buttons suggest payment is possible (just blocked)
- Hidden buttons suggest payment is not applicable (correct behavior)
- No confusion about why payment is not shown

---

## Payment Is Always Item-Scoped (Never Bundled)

**Each verification has its own payment context.**

### Allowed Items

**1. Electrician License Verification**
- Payment: $5–$10 (one-time, per verification)
- Scope: Single trade (electrician), single state

**2. Plumber License Verification**
- Payment: $5–$10 (one-time, per verification)
- Scope: Single trade (plumber), single state

**3. Insurance Verification**
- Payment: $5 (one-time, per upload)
- Scope: Single insurance policy

**4. Background Check**
- Payment: Pass-through (actual cost from provider)
- Scope: Single background check

**5. Re-Verification (On Expiry)**
- Payment: Same as original verification
- Scope: Single renewal (same trade/state)

---

### Forbidden Bundles

**❌ "Pro Bundle"**
- Why: Suggests payment unlocks multiple capabilities (it doesn't)
- Correct: Each verification is separate payment

**❌ "Unlock All Trades"**
- Why: Suggests payment grants access (it doesn't)
- Correct: Each trade requires separate verification (and payment)

**❌ Subscription for Eligibility**
- Why: Suggests payment maintains eligibility (it doesn't)
- Correct: Eligibility is derived from verification records (not payment status)

**Rule:**
> Payment is per verification, not per capability or per time period.

---

## Pricing Model (Defensible)

**Purpose:** Pricing must be defensible (not exploitative, not pay-to-play).

### Recommended (Early Stage)

| Verification Type      | Fee           | Cadence          | Justification                          |
| ---------------------- | ------------- | ---------------- | -------------------------------------- |
| License verification   | $5–$10        | Per verification | Registry API costs + processing + monitoring |
| Insurance verification | $5            | Per upload       | OCR processing + validation + monitoring |
| Background check       | Pass-through  | Per check        | Actual provider cost (no markup)       |
| Re-verification        | Same as above | On expiry        | Same processing cost as original       |

**Rule:**
> **Price must be ≤ actual processing + monitoring cost × 2.**

This keeps you out of "selling credentials" territory.

**Why This Pricing:**
- Covers actual costs (registry API, OCR, monitoring)
- Small markup (2× cost) for operational overhead
- Not exploitative (users pay for processing, not access)
- Defensible (can explain pricing to regulators)

**Pricing Transparency:**
- Show itemized breakdown (optional, but recommended)
- Explain what payment covers (verification processing, not access)
- No hidden fees (all costs visible upfront)

---

## Copy Guidelines (This Matters More Than Code)

**Purpose:** Copy must be precise (no ambiguity, no pay-to-play language).

### ❌ Forbidden Copy

**Words/Phrases Never to Use:**
- "Unlock" (suggests payment grants access)
- "Get verified" (suggests payment guarantees verification)
- "Upgrade access" (suggests payment upgrades eligibility)
- "Become a pro" (suggests payment grants professional status)
- "Pay to qualify" (suggests payment grants qualification)

**Why Forbidden:**
- These phrases suggest payment grants access (it doesn't)
- These phrases create pay-to-play feeling (erodes trust)
- These phrases are misleading (payment is for processing, not access)

---

### ✅ Allowed Copy (Use These Patterns)

**Title:**
```
Verification Processing Fee
```

**Body:**
```
This fee covers the cost of validating your existing credentials and maintaining their active status.

Payment does not guarantee approval.
```

**Footer:**
```
If verification fails, you will not be charged.
```

**Why This Language:**
- "Processing Fee" (not "Unlock Fee") — payment is for processing, not access
- "Validating your existing credentials" (not "Get verified") — payment validates facts, doesn't grant status
- "Payment does not guarantee approval" (not "Pay to qualify") — payment is for processing, not guarantee
- "If verification fails, you will not be charged" (not "No refunds") — clear refund policy

**This language is deliberate. Do not improvise.**

---

## Payment Flow (Step-By-Step)

### Step 1 — Context Screen (No Payment Yet)

**Purpose:** Explain what is being verified before showing payment.

**Shows:**
- What is being verified (trade, state, license number)
- What documents/data are required (license document, COI, etc.)
- What this enables (plain, factual: "Required to see licensed gigs")
- Expiration behavior ("Verification expires when license expires")

**UI:**
```
[Context Screen]

Verify Electrician License
State: Washington (WA)
License Number: EL12345

Required Documents:
• License document (PDF, JPG, or PNG)
• License number (already provided)

What This Enables:
• Access to electrical gigs in Washington
• Verification expires when license expires

[Continue to verification] ← CTA (no payment yet)
```

**Behavioral Rules:**
- No payment shown yet (context first)
- Clear explanation of what's being verified
- Clear explanation of what this enables (factual, not marketing)

---

### Step 2 — Eligibility Confirmation (Silent)

**Purpose:** Re-check eligibility before showing payment.

**System Re-Checks:**
- Identity (must be verified)
- Claim validity (license format, trade allowed in state)
- Duplication (no active verification exists)

**If Fails:**
```typescript
// Return to Settings with explanation
return {
  success: false,
  reason: 'Eligibility pre-check failed',
  explanation: 'License format is invalid for Washington state',
  next_step: 'fix_inputs_and_resubmit',
};
```

**UI:**
```
[Settings → Work Eligibility]

⚠️ Verification cannot proceed
Reason: License format is invalid for Washington state
[Fix inputs and resubmit] ← Action button
```

**Behavioral Rules:**
- Pre-check is silent (user doesn't see it)
- If pre-check fails, return to Settings (no payment shown)
- Clear explanation of why pre-check failed
- Action button to fix inputs and resubmit

---

### Step 3 — Payment Screen

**Purpose:** Show payment details and collect payment.

**Shows:**
- Itemized fee (verification processing fee: $5–$10)
- Refund rule (binary: "If verification fails, you will not be charged")
- No urgency language (no "Limited time", no countdowns)
- No countdowns (no pressure to pay immediately)

**UI:**
```
[Payment Screen]

Verification Processing Fee
$8.00

This fee covers the cost of validating your existing credentials and maintaining their active status.

Payment does not guarantee approval.

If verification fails, you will not be charged.

[Pay & submit for verification] ← CTA
```

**Payment Methods:**
- Credit card (Stripe)
- Debit card (Stripe)
- No cryptocurrency (regulatory compliance)
- No cash (digital only)

**Behavioral Rules:**
- Clear fee amount (no hidden fees)
- Clear refund policy (binary, non-negotiable)
- No urgency language (no pressure)
- No countdowns (no time pressure)

---

### Step 4 — Submission + Pending State

**Purpose:** Confirm payment and show pending status.

**After Payment:**
1. Payment processed (Stripe)
2. Verification record created (`status = 'pending'`)
3. Capability profile unchanged (no recompute yet)
4. User returned to Settings

**Status Shown:**
```
[Settings → Work Eligibility]

[Electrician] ⏳ Verification in progress
This usually takes under 2 hours
```

**Behavioral Rules:**
- Verification record created immediately (after payment)
- Capability profile unchanged (no recompute until verification completes)
- User returned to Settings (not Feed)
- Status shown clearly (pending, not verified)

---

## Refund Rules (Binary, Non-Negotiable)

**Purpose:** Clear, binary refund policy (no ambiguity, no appeals).

### Refund Scenarios

**❌ Verification Fails → Full Refund**
```typescript
if (verification.status === 'failed') {
  await refundPayment(verification.payment_id, 'full');
  await notifyUserRefund(userId, {
    verification_id: verification.id,
    reason: 'Verification failed',
    refund_amount: verification.payment_amount,
  });
}
```

**Why:**
- Payment is for verification processing (not access)
- If verification fails, processing didn't succeed (refund is fair)
- Full refund (not partial, not credit)

---

**✅ Verification Succeeds → No Refund**
```typescript
if (verification.status === 'verified') {
  // No refund (verification succeeded, payment was for processing)
  // User got what they paid for (verification processing)
}
```

**Why:**
- Payment is for verification processing (not access)
- If verification succeeds, processing succeeded (no refund)
- User got what they paid for (verification processing)

---

**⏳ User Cancels Before Submission → No Charge**
```typescript
if (userCancelsBeforeSubmission) {
  // No charge (payment never processed)
  // No refund needed (no charge made)
}
```

**Why:**
- Payment is only charged on submission (not on payment screen)
- If user cancels before submission, no charge (no refund needed)
- User never paid (no refund to process)

---

**No Partial Refunds. No Credits. No Appeals.**

**Why:**
- Binary policy (refund or no refund, no middle ground)
- Operational sanity (no complex refund logic)
- Clear expectations (users know refund policy upfront)

**This is critical for operational sanity.**

---

## What Payment Does NOT Do (Explicitly)

**Purpose:** Explicitly state what payment does not do (prevent confusion).

**Payment does not:**
- ❌ Increase trust tier (trust tier is earned, not purchased)
- ❌ Override expiry (expiry is based on credential expiry, not payment)
- ❌ Unlock gigs directly (gigs are unlocked via capability profile recompute)
- ❌ Speed up feed appearance (feed appears after recompute, not payment)
- ❌ Reduce task requirements (task requirements are immutable)

**If users assume any of the above, your copy is wrong.**

**Correct Copy:**
```
Payment covers the cost of verifying your existing credentials.

Verification does not guarantee:
• Trust tier increase
• Immediate feed access
• Task requirement reduction

Verification only validates that your credentials are valid.
```

---

## UX Anti-Patterns (Never Ship These)

### ❌ "Pay to Retry" After Failure

**Why Forbidden:**
- Suggests payment can fix failed verification (it can't)
- Creates pay-to-play feeling (pay to try again)

**Correct Pattern:**
- ✅ Fix inputs and resubmit (free, after fixing inputs)
- ✅ Refund if verification fails (automatic, no retry fee)

---

### ❌ Discounting Verification

**Why Forbidden:**
- Suggests verification is a product to sell (it's not)
- Creates urgency (limited-time discount)

**Correct Pattern:**
- ✅ Fixed pricing (no discounts, no sales)
- ✅ Transparent pricing (cost-based, not market-based)

---

### ❌ Verification Subscriptions

**Why Forbidden:**
- Suggests payment maintains eligibility (it doesn't)
- Creates recurring revenue from eligibility (pay-to-play)

**Correct Pattern:**
- ✅ One-time payment per verification (not subscription)
- ✅ Re-verification on expiry (same fee, not subscription)

---

### ❌ Badges Tied to Payment

**Why Forbidden:**
- Suggests payment grants status (it doesn't)
- Creates pay-to-play feeling (pay for badge)

**Correct Pattern:**
- ✅ Badges tied to verification status (not payment status)
- ✅ Badges earned through verification (not purchased)

---

### ❌ "Limited Time" Pricing

**Why Forbidden:**
- Creates urgency (pressure to pay)
- Suggests pricing is negotiable (it's not)

**Correct Pattern:**
- ✅ Fixed pricing (no time limits, no urgency)
- ✅ Transparent pricing (cost-based, not market-based)

**These all scream scam, even if your system is solid.**

---

## Required Tests (Non-Optional)

### 1. Unqualified User Never Sees Payment

```typescript
it('hides payment for unqualified users', async () => {
  const user = await createUser({
    verified_trades: [],
    identity_verified: false,
  });

  const shouldShow = await shouldShowPayment(user.id, 'electrician');
  expect(shouldShow.showPayment).toBe(false);
  expect(shouldShow.reason).toBe('Identity verification required');
});
```

---

### 2. Failed Verification Auto-Refunds

```typescript
it('refunds payment when verification fails', async () => {
  const user = await createUser({ identity_verified: true });
  const verification = await submitVerification(user.id, 'electrician', { payment_id: 'pay_123' });

  // Fail verification
  await failVerification(verification.id, 'License not found in registry');

  // Payment should be refunded
  const refund = await getRefund(verification.payment_id);
  expect(refund.amount).toBe(verification.payment_amount);
  expect(refund.reason).toBe('Verification failed');
});
```

---

### 3. Paid Verification Does Not Modify Feed Until Recompute

```typescript
it('does not modify feed until recompute after payment', async () => {
  const user = await createUser({ verified_trades: [] });
  const task = await createTask({ required_trade: 'electrician' });

  // Feed should exclude task (no verified trade)
  const feedBefore = await getFeed(user.id);
  expect(feedBefore.tasks).not.toContainEqual(task);

  // Pay and submit verification
  await payAndSubmitVerification(user.id, 'electrician');
  
  // Feed should still exclude task (recompute not triggered yet)
  const feedAfterPayment = await getFeed(user.id);
  expect(feedAfterPayment.tasks).not.toContainEqual(task);

  // Complete verification (triggers recompute)
  await completeVerification(user.id, 'electrician');
  await recomputeCapabilityProfile(user.id);
  await invalidateFeedCache(user.id);

  // Feed should include task (recompute triggered)
  await wait(65); // Wait for cache TTL
  const feedAfterRecompute = await getFeed(user.id);
  expect(feedAfterRecompute.tasks).toContainEqual(task);
});
```

---

### 4. Expired Credential Requires New Payment

```typescript
it('requires new payment for expired credential renewal', async () => {
  const user = await createUser({
    verified_trades: [{ trade: 'electrician', expires_at: '2025-01-01' }]
  });

  // Expire credential
  await expireCredential(user.id, 'electrician');
  await recomputeCapabilityProfile(user.id);

  // Renewal should require new payment
  const shouldShow = await shouldShowPayment(user.id, 'electrician');
  expect(shouldShow.showPayment).toBe(true); // New payment required
});
```

---

### 5. Multiple Trades Require Separate Payments

```typescript
it('requires separate payments for multiple trades', async () => {
  const user = await createUser({ identity_verified: true });

  // Pay for electrician verification
  await payAndSubmitVerification(user.id, 'electrician');

  // Plumber verification should require separate payment
  const shouldShow = await shouldShowPayment(user.id, 'plumber');
  expect(shouldShow.showPayment).toBe(true); // Separate payment required
});
```

---

### 6. Payment Outage Does Not Grant Access

```typescript
it('does not grant access if payment fails', async () => {
  const user = await createUser({ identity_verified: true });

  // Attempt payment (payment fails)
  const result = await attemptPayment(user.id, 'electrician');
  expect(result.success).toBe(false);
  expect(result.reason).toBe('Payment failed');

  // Verification should not be created
  const verification = await getVerification(user.id, 'electrician');
  expect(verification).toBeNull();

  // Feed should not include tasks requiring trade
  const feed = await getFeed(user.id);
  const tradeTasks = feed.tasks.filter(t => t.required_trade === 'electrician');
  expect(tradeTasks).toHaveLength(0);
});
```

**If these tests pass, your payment UX is correct.**

---

## What You've Completed

**At this point, you have a closed, institutional loop:**

```
Onboarding
  → Capability Claims
    → Verification (paid, gated)
      → Recomputation
        → Feed
          → Settings explanation
```

**There is no surface left where trust can leak.**

**Most startups never reach this state.**

---

## Final Reality Check

**Ask yourself:**
> "Can money alone ever cause a gig to appear in someone's feed?"

**If the answer is no, you've won.**

**And in your system, the answer is no.**

**Why:**
- Payment unlocks verification processing (not capability profile)
- Capability profile is derived from verification records (not payment status)
- Feed query uses capability profile (not payment status)
- Money never buys access (money only covers validation costs)

---

## This Payment UX & Copy is LOCKED (v1.0)

Do not modify without explicit approval.

All implementations must follow this UX and copy exactly.

If inconsistencies are found, raise an issue for review.

---

**Last Updated:** 2025-01-17  
**Status:** LOCKED  
**Authority:** System Architecture — Non-Negotiable
