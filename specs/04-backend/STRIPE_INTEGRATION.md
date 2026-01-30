# HustleXP Stripe Integration Specification

**STATUS: CONSTITUTIONAL AUTHORITY**
**Owner:** Backend Team
**Last Updated:** January 2025
**Version:** v1.0.0
**Governance:** This document defines all Stripe integration patterns. Implementation must follow these specifications exactly.

---

## Table of Contents

1. [Overview](#1-overview)
2. [Architecture](#2-architecture)
3. [Stripe Connect Setup](#3-stripe-connect-setup)
4. [Payment Flow](#4-payment-flow)
5. [Payout Flow](#5-payout-flow)
6. [Refund Flow](#6-refund-flow)
7. [Webhook Handling](#7-webhook-handling)
8. [Error Recovery](#8-error-recovery)
9. [Testing](#9-testing)
10. [Security](#10-security)

---

## 1. Overview

### 1.1 Payment Model

HustleXP uses **Stripe Connect** with the **Direct Charges** model:

```
Poster → Platform (HustleXP) → Worker
         ↓
    15% Platform Fee
```

- **Poster** pays full task price
- **Platform** holds funds in escrow (Stripe PaymentIntent)
- **Worker** receives 85% via Stripe Transfer to Connected Account

### 1.2 Stripe Products Used

| Product | Purpose |
|---------|---------|
| **Stripe Connect** | Worker payouts via connected accounts |
| **PaymentIntents** | Capture poster payments |
| **Transfers** | Release funds to workers |
| **Refunds** | Return funds to posters |
| **Webhooks** | Async event processing |
| **Radar** | Fraud detection |

### 1.3 Key Amounts

| Amount | Calculation | Example ($50 task) |
|--------|-------------|-------------------|
| Task Price | Set by poster | $50.00 |
| Platform Fee | 15% of price | $7.50 |
| Worker Payout | 85% of price | $42.50 |
| Stripe Fee | ~2.9% + $0.30 | ~$1.75 |

---

## 2. Architecture

### 2.1 Data Flow

```
┌─────────────┐     ┌──────────────┐     ┌─────────────┐
│   Poster    │────▶│   HustleXP   │────▶│   Worker    │
│   (Card)    │     │   Backend    │     │ (Connected) │
└─────────────┘     └──────────────┘     └─────────────┘
       │                   │                    │
       │                   │                    │
       ▼                   ▼                    ▼
┌─────────────┐     ┌──────────────┐     ┌─────────────┐
│ PaymentIntent│────▶│   Escrow     │────▶│  Transfer   │
│   (Stripe)  │     │   (DB)       │     │  (Stripe)   │
└─────────────┘     └──────────────┘     └─────────────┘
```

### 2.2 Database Schema

```sql
-- Escrow table links to Stripe objects
CREATE TABLE escrows (
  id UUID PRIMARY KEY,
  task_id UUID NOT NULL REFERENCES tasks(id),
  amount INTEGER NOT NULL,  -- In cents
  state escrow_state NOT NULL DEFAULT 'PENDING',

  -- Stripe references
  stripe_payment_intent_id TEXT,
  stripe_transfer_id TEXT,
  stripe_refund_id TEXT,

  -- Partial refund fields
  refund_amount INTEGER,
  release_amount INTEGER,

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Worker connected accounts
CREATE TABLE stripe_connected_accounts (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES users(id),
  stripe_account_id TEXT NOT NULL,
  onboarding_complete BOOLEAN DEFAULT FALSE,
  charges_enabled BOOLEAN DEFAULT FALSE,
  payouts_enabled BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Processed Stripe events (idempotency)
CREATE TABLE processed_stripe_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id TEXT NOT NULL UNIQUE,
  event_type TEXT NOT NULL,
  processed_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

## 3. Stripe Connect Setup

### 3.1 Worker Onboarding Flow

```typescript
/**
 * Create Stripe Connect account for worker
 * Called during worker onboarding
 */
async function createConnectedAccount(userId: string, email: string) {
  // 1. Create Express account
  const account = await stripe.accounts.create({
    type: 'express',
    email: email,
    capabilities: {
      transfers: { requested: true },
    },
    business_type: 'individual',
    metadata: {
      hustlexp_user_id: userId,
    },
  });

  // 2. Store in database
  await supabase.from('stripe_connected_accounts').insert({
    user_id: userId,
    stripe_account_id: account.id,
    onboarding_complete: false,
  });

  // 3. Create onboarding link
  const accountLink = await stripe.accountLinks.create({
    account: account.id,
    refresh_url: `${APP_URL}/settings/payments?refresh=true`,
    return_url: `${APP_URL}/settings/payments?success=true`,
    type: 'account_onboarding',
  });

  return accountLink.url;
}
```

### 3.2 Check Onboarding Status

```typescript
async function checkConnectedAccountStatus(userId: string) {
  const { data: connectedAccount } = await supabase
    .from('stripe_connected_accounts')
    .select('stripe_account_id')
    .eq('user_id', userId)
    .single();

  if (!connectedAccount) {
    return { status: 'NOT_STARTED' };
  }

  const account = await stripe.accounts.retrieve(
    connectedAccount.stripe_account_id
  );

  return {
    status: account.details_submitted ? 'COMPLETE' : 'INCOMPLETE',
    charges_enabled: account.charges_enabled,
    payouts_enabled: account.payouts_enabled,
  };
}
```

---

## 4. Payment Flow

### 4.1 Create Payment Intent

**Triggered:** When poster confirms task creation

```typescript
/**
 * Create PaymentIntent for task escrow
 * SPEC: PRODUCT_SPEC.md §4, §18.3
 */
async function createTaskPaymentIntent(
  taskId: string,
  amount: number,  // In cents
  posterUserId: string
) {
  // 1. Validate minimum price
  if (amount < 500) {  // $5.00 minimum
    throw new HXError('HX_PRICE_TOO_LOW', 'Minimum task price is $5.00');
  }

  // 2. Create escrow record
  const { data: escrow } = await supabase
    .from('escrows')
    .insert({
      task_id: taskId,
      amount: amount,
      state: 'PENDING',
    })
    .select()
    .single();

  // 3. Create PaymentIntent
  const paymentIntent = await stripe.paymentIntents.create({
    amount: amount,
    currency: 'usd',
    metadata: {
      escrow_id: escrow.id,
      task_id: taskId,
      poster_user_id: posterUserId,
    },
    // Automatic capture (not manual)
    capture_method: 'automatic',
    // Enable Radar fraud detection
    radar_options: {
      session: posterUserId,  // Link to user session
    },
  });

  // 4. Update escrow with PaymentIntent ID
  await supabase
    .from('escrows')
    .update({
      stripe_payment_intent_id: paymentIntent.id,
    })
    .eq('id', escrow.id);

  return {
    clientSecret: paymentIntent.client_secret,
    escrowId: escrow.id,
  };
}
```

### 4.2 Confirm Payment (Frontend)

```typescript
// Frontend: Confirm payment with Stripe Elements
const { error } = await stripe.confirmPayment({
  elements,
  clientSecret,
  confirmParams: {
    return_url: `${APP_URL}/tasks/${taskId}/confirmed`,
  },
});
```

### 4.3 Handle Payment Success (Webhook)

```typescript
/**
 * Handle payment_intent.succeeded webhook
 * Transitions escrow: PENDING → FUNDED
 */
async function handlePaymentIntentSucceeded(
  paymentIntent: Stripe.PaymentIntent
) {
  const escrowId = paymentIntent.metadata.escrow_id;

  await supabase
    .from('escrows')
    .update({
      state: 'FUNDED',
      updated_at: new Date().toISOString(),
    })
    .eq('id', escrowId)
    .eq('state', 'PENDING');  // Only if still PENDING

  // Notify poster
  await notificationService.send({
    user_id: paymentIntent.metadata.poster_user_id,
    type: 'ESCROW_FUNDED',
    task_id: paymentIntent.metadata.task_id,
  });
}
```

---

## 5. Payout Flow

### 5.1 Release Escrow to Worker

**Triggered:** When task reaches COMPLETED state

```typescript
/**
 * Release escrow to worker via Stripe Transfer
 * SPEC: PRODUCT_SPEC.md §4.3
 * Prerequisite: Task state = COMPLETED (enforced by INV-2)
 */
async function releaseEscrow(escrowId: string) {
  // 1. Get escrow and task details
  const { data: escrow } = await supabase
    .from('escrows')
    .select(`
      *,
      tasks!inner (
        worker_id,
        state
      )
    `)
    .eq('id', escrowId)
    .single();

  // 2. Validate task is COMPLETED (defense in depth)
  if (escrow.tasks.state !== 'COMPLETED') {
    throw new HXError('HX201', 'Task must be COMPLETED to release escrow');
  }

  // 3. Get worker's connected account
  const { data: connectedAccount } = await supabase
    .from('stripe_connected_accounts')
    .select('stripe_account_id')
    .eq('user_id', escrow.tasks.worker_id)
    .single();

  if (!connectedAccount) {
    throw new HXError('HX_NO_PAYOUT_ACCOUNT', 'Worker has no connected account');
  }

  // 4. Calculate payout amount (85% of escrow)
  const payoutAmount = Math.floor(escrow.amount * 0.85);

  // 5. Create Transfer
  const transfer = await stripe.transfers.create({
    amount: payoutAmount,
    currency: 'usd',
    destination: connectedAccount.stripe_account_id,
    metadata: {
      escrow_id: escrowId,
      task_id: escrow.task_id,
      worker_user_id: escrow.tasks.worker_id,
    },
  });

  // 6. Update escrow state
  await supabase
    .from('escrows')
    .update({
      state: 'RELEASED',
      stripe_transfer_id: transfer.id,
      updated_at: new Date().toISOString(),
    })
    .eq('id', escrowId);

  // 7. Award XP (triggers INV-1 validation)
  await xpService.awardXP(
    escrow.tasks.worker_id,
    escrow.task_id,
    escrowId
  );

  return transfer;
}
```

---

## 6. Refund Flow

### 6.1 Full Refund

**Triggered:** Task cancelled or expired

```typescript
/**
 * Refund escrow to poster
 * SPEC: PRODUCT_SPEC.md §4.3
 */
async function refundEscrow(escrowId: string, reason: string) {
  const { data: escrow } = await supabase
    .from('escrows')
    .select('*')
    .eq('id', escrowId)
    .single();

  // Only refund FUNDED escrows
  if (escrow.state !== 'FUNDED') {
    throw new HXError('HX_INVALID_STATE', 'Escrow must be FUNDED to refund');
  }

  // Create refund
  const refund = await stripe.refunds.create({
    payment_intent: escrow.stripe_payment_intent_id,
    reason: 'requested_by_customer',
    metadata: {
      escrow_id: escrowId,
      refund_reason: reason,
    },
  });

  // Update escrow
  await supabase
    .from('escrows')
    .update({
      state: 'REFUNDED',
      stripe_refund_id: refund.id,
      updated_at: new Date().toISOString(),
    })
    .eq('id', escrowId);

  return refund;
}
```

### 6.2 Partial Refund (Dispute Resolution)

```typescript
/**
 * Partial refund for dispute resolution
 * SPEC: PRODUCT_SPEC.md §4.5
 */
async function partialRefundEscrow(
  escrowId: string,
  workerPercent: number  // 0-100
) {
  // Fetch escrow with task relation to get worker_id
  const { data: escrow } = await supabase
    .from('escrows')
    .select(`
      *,
      tasks!inner (
        worker_id
      )
    `)
    .eq('id', escrowId)
    .single();

  const releaseAmount = Math.floor(escrow.amount * (workerPercent / 100));
  const refundAmount = escrow.amount - releaseAmount;

  // 1. Refund poster portion
  const refund = await stripe.refunds.create({
    payment_intent: escrow.stripe_payment_intent_id,
    amount: refundAmount,
  });

  // 2. Transfer worker portion (via task relation)
  const { data: connectedAccount } = await supabase
    .from('stripe_connected_accounts')
    .select('stripe_account_id')
    .eq('user_id', escrow.tasks.worker_id)
    .single();

  const transfer = await stripe.transfers.create({
    amount: Math.floor(releaseAmount * 0.85),  // After platform fee
    currency: 'usd',
    destination: connectedAccount.stripe_account_id,
  });

  // 3. Update escrow
  await supabase
    .from('escrows')
    .update({
      state: 'REFUND_PARTIAL',
      stripe_refund_id: refund.id,
      stripe_transfer_id: transfer.id,
      refund_amount: refundAmount,
      release_amount: releaseAmount,
      updated_at: new Date().toISOString(),
    })
    .eq('id', escrowId);
}
```

---

## 7. Webhook Handling

### 7.1 Webhook Endpoint

```typescript
// src/webhooks/stripe.webhook.ts
export async function handleStripeWebhook(req: Request): Promise<Response> {
  const sig = req.headers.get('stripe-signature');
  const body = await req.text();

  let event: Stripe.Event;

  try {
    event = stripe.webhooks.constructEvent(
      body,
      sig!,
      env.STRIPE_WEBHOOK_SECRET
    );
  } catch (err) {
    console.error('Webhook signature verification failed:', err);
    return new Response('Invalid signature', { status: 400 });
  }

  // Idempotency check
  const { data: existing } = await supabase
    .from('processed_stripe_events')
    .select('id')
    .eq('event_id', event.id)
    .single();

  if (existing) {
    return new Response('Already processed', { status: 200 });
  }

  // Process event
  try {
    await processStripeEvent(event);

    // Record as processed
    await supabase.from('processed_stripe_events').insert({
      event_id: event.id,
      event_type: event.type,
    });

    return new Response('OK', { status: 200 });
  } catch (err) {
    console.error('Webhook processing failed:', err);
    return new Response('Processing failed', { status: 500 });
  }
}
```

### 7.2 Event Handlers

| Event | Handler | Action |
|-------|---------|--------|
| `payment_intent.succeeded` | `handlePaymentIntentSucceeded` | Escrow → FUNDED |
| `payment_intent.payment_failed` | `handlePaymentFailed` | Notify poster, log |
| `transfer.created` | `handleTransferCreated` | Log payout |
| `transfer.failed` | `handleTransferFailed` | Alert, retry queue |
| `account.updated` | `handleAccountUpdated` | Update onboarding status |
| `charge.dispute.created` | `handleDisputeCreated` | Lock escrow, alert |

---

## 8. Error Recovery

### 8.1 Payment Failures

```typescript
async function handlePaymentFailed(paymentIntent: Stripe.PaymentIntent) {
  const escrowId = paymentIntent.metadata.escrow_id;

  // Log failure
  await supabase.from('payment_failures').insert({
    escrow_id: escrowId,
    payment_intent_id: paymentIntent.id,
    error_code: paymentIntent.last_payment_error?.code,
    error_message: paymentIntent.last_payment_error?.message,
  });

  // Notify poster
  await notificationService.send({
    user_id: paymentIntent.metadata.poster_user_id,
    type: 'PAYMENT_FAILED',
    data: {
      error: paymentIntent.last_payment_error?.message,
    },
  });
}
```

### 8.2 Transfer Failures

```typescript
async function handleTransferFailed(transfer: Stripe.Transfer) {
  // Add to retry queue
  await supabase.from('transfer_retry_queue').insert({
    transfer_id: transfer.id,
    escrow_id: transfer.metadata.escrow_id,
    retry_count: 0,
    next_retry_at: new Date(Date.now() + 60 * 60 * 1000), // 1 hour
  });

  // Alert operations
  await alertService.critical('Transfer failed', {
    transfer_id: transfer.id,
    destination: transfer.destination,
  });
}
```

### 8.3 Retry Logic

```typescript
// Background job: Retry failed transfers
async function retryFailedTransfers() {
  const { data: retries } = await supabase
    .from('transfer_retry_queue')
    .select('*')
    .lt('next_retry_at', new Date().toISOString())
    .lt('retry_count', 3);  // Max 3 retries

  for (const retry of retries ?? []) {
    try {
      // Attempt new transfer
      await releaseEscrow(retry.escrow_id);

      // Remove from queue
      await supabase
        .from('transfer_retry_queue')
        .delete()
        .eq('id', retry.id);
    } catch (err) {
      // Update retry count
      await supabase
        .from('transfer_retry_queue')
        .update({
          retry_count: retry.retry_count + 1,
          next_retry_at: new Date(Date.now() + 60 * 60 * 1000 * (retry.retry_count + 1)),
          last_error: err.message,
        })
        .eq('id', retry.id);
    }
  }
}
```

---

## 9. Testing

### 9.1 Test Card Numbers

| Card | Number | Use Case |
|------|--------|----------|
| Success | `4242424242424242` | Happy path |
| Decline | `4000000000000002` | Generic decline |
| Insufficient | `4000000000009995` | Insufficient funds |
| Fraud | `4100000000000019` | Radar block |

### 9.2 Test Connected Accounts

```typescript
// Create test connected account
const account = await stripe.accounts.create({
  type: 'express',
  country: 'US',
  email: 'test@example.com',
  capabilities: {
    transfers: { requested: true },
  },
});

// Manually complete onboarding in test mode
await stripe.accounts.update(account.id, {
  tos_acceptance: {
    date: Math.floor(Date.now() / 1000),
    ip: '127.0.0.1',
  },
});
```

### 9.3 Webhook Testing

```bash
# Install Stripe CLI
brew install stripe/stripe-cli/stripe

# Login
stripe login

# Forward webhooks to local server
stripe listen --forward-to localhost:3001/webhooks/stripe

# Trigger test events
stripe trigger payment_intent.succeeded
stripe trigger transfer.created
```

---

## 10. Security

### 10.1 API Key Management

- **Never** commit API keys to git
- Use environment variables only
- Rotate keys quarterly
- Use restricted keys in production (limit permissions)

### 10.2 Webhook Security

- **Always** verify webhook signatures
- Use HTTPS endpoints only
- Implement idempotency (process each event once)
- Log all webhook events for audit

### 10.3 PCI Compliance

HustleXP uses Stripe Elements, which:
- Keeps card data off our servers
- Handles PCI compliance via iframe
- Tokenizes card data before transmission

**Never** store or log:
- Full card numbers
- CVV codes
- Card PINs

### 10.4 Fraud Prevention

```typescript
// Enable Radar for all PaymentIntents
const paymentIntent = await stripe.paymentIntents.create({
  // ...
  radar_options: {
    session: userId,
  },
});

// Check Radar score in webhook
async function handlePaymentIntentSucceeded(pi: Stripe.PaymentIntent) {
  const charge = await stripe.charges.retrieve(pi.latest_charge as string);

  if (charge.outcome?.risk_level === 'elevated') {
    // Flag for manual review
    await flagForFraudReview(pi.metadata.escrow_id);
  }
}
```

---

## Quick Reference

### Environment Variables

```bash
STRIPE_SECRET_KEY=sk_test_...      # API key
STRIPE_WEBHOOK_SECRET=whsec_...     # Webhook signing secret
STRIPE_CONNECT_CLIENT_ID=ca_...     # Connect OAuth client
```

### Key Endpoints

| Endpoint | Purpose |
|----------|---------|
| `POST /api/escrows/create-payment-intent` | Create PI for task |
| `POST /api/escrows/:id/release` | Release to worker |
| `POST /api/escrows/:id/refund` | Refund to poster |
| `POST /webhooks/stripe` | Webhook receiver |

### State Transitions

```
Escrow: PENDING → FUNDED → RELEASED
                        ↘ REFUNDED
                        ↘ REFUND_PARTIAL
                        ↘ LOCKED_DISPUTE → RELEASED/REFUNDED/PARTIAL
```

---

**END OF STRIPE_INTEGRATION v1.0.0**
