# HustleXP Error Codes Reference

**STATUS: CONSTITUTIONAL AUTHORITY**
**Owner:** Engineering Team
**Last Updated:** January 2025
**Version:** v1.0.0
**Governance:** All error codes are defined here. Application code must use these codes exactly.

---

## Overview

HustleXP uses structured error codes to identify specific failure conditions. All codes follow the `HX` prefix pattern with numeric identifiers.

### Error Response Format

```typescript
interface ErrorResponse {
  success: false;
  error: {
    code: string;       // HX error code (e.g., "HX101")
    message: string;    // Human-readable message
    details?: object;   // Additional context (optional)
  };
  timestamp: string;    // ISO 8601 timestamp
}
```

### Example Error Response

```json
{
  "success": false,
  "error": {
    "code": "HX101",
    "message": "XP cannot be awarded: escrow state is FUNDED, must be RELEASED",
    "details": {
      "escrow_id": "esc_123",
      "current_state": "FUNDED",
      "required_state": "RELEASED"
    }
  },
  "timestamp": "2025-01-15T10:30:00Z"
}
```

---

## Error Code Categories

| Range | Category | Description |
|-------|----------|-------------|
| HX001-HX099 | **Terminal State** | State machine violations |
| HX101-HX199 | **XP System** | XP ledger violations |
| HX201-HX299 | **Escrow System** | Escrow state violations |
| HX301-HX399 | **Task System** | Task state violations |
| HX401-HX499 | **Badge System** | Badge violations |
| HX501-HX599 | **User System** | User/auth violations |
| HX601-HX699 | **Fatigue/Pause** | Fatigue and pause violations |
| HX701-HX799 | **AI System** | AI task completion violations |
| HX801-HX899 | **Messaging** | Message system violations |
| HX901-HX999 | **Live Mode/Fraud** | Live mode and fraud violations |

---

## Terminal State Errors (HX001-HX099)

### HX001 - Task Terminal State Violation

**Trigger:** Attempting to modify a task in terminal state (COMPLETED, CANCELLED, EXPIRED)

**Enforcement:** Database trigger `task_terminal_guard`

**Message:** `Task in terminal state ({state}) cannot be modified`

**HTTP Status:** 409 Conflict

**Resolution:** Terminal tasks are immutable. Create a new task if needed.

```typescript
// Violation example
await taskService.update(taskId, { title: 'New Title' });
// Task is COMPLETED → throws HX001
```

---

### HX002 - Escrow Terminal State Violation

**Trigger:** Attempting to modify an escrow in terminal state (RELEASED, REFUNDED, REFUND_PARTIAL)

**Enforcement:** Database trigger `escrow_terminal_guard`

**Message:** `Escrow in terminal state ({state}) cannot be modified`

**HTTP Status:** 409 Conflict

**Resolution:** Terminal escrows are immutable. Disputes must be opened before terminal state.

---

### HX003 - Escrow Amount Mismatch

**Trigger:** Escrow amount does not match task price

**Enforcement:** Database trigger

**Message:** `Escrow amount must match task price`

**HTTP Status:** 400 Bad Request

---

### HX004 - Escrow Amount Modification Attempt

**Trigger:** Attempting to modify escrow amount after creation (INV-4)

**Enforcement:** Database trigger `escrow_amount_immutable`

**Message:** `Escrow amount cannot be modified after creation`

**HTTP Status:** 409 Conflict

**Resolution:** Escrow amount is locked at creation. Cancel and recreate if price change needed.

---

### HX005 - Partial Refund Missing Amounts

**Trigger:** REFUND_PARTIAL state without both refund_amount and release_amount

**Enforcement:** Database trigger `escrow_partial_sum_check`

**Message:** `Partial refund requires both refund_amount and release_amount`

**HTTP Status:** 400 Bad Request

---

### HX006 - Partial Refund Sum Mismatch

**Trigger:** refund_amount + release_amount != original amount

**Enforcement:** Database trigger `escrow_partial_sum_check`

**Message:** `Partial refund amounts must sum to original escrow amount`

**HTTP Status:** 400 Bad Request

---

## XP System Errors (HX101-HX199)

### HX101 - XP Without Released Escrow (INV-1)

**Trigger:** Attempting to award XP when escrow is not RELEASED

**Enforcement:** Database trigger `xp_requires_released_escrow`

**Message:** `XP cannot be awarded: escrow state is {state}, must be RELEASED`

**HTTP Status:** 409 Conflict

**Resolution:** Complete the task lifecycle: proof accepted → task completed → escrow released → XP awarded

```typescript
// This will fail with HX101
INSERT INTO xp_ledger (user_id, task_id, escrow_id, ...)
WHERE escrow.state = 'FUNDED';  // Not RELEASED
```

---

### HX102 - XP Ledger Deletion Attempt

**Trigger:** Attempting to delete an XP ledger entry

**Enforcement:** Database trigger `xp_ledger_no_delete`

**Message:** `XP ledger entries cannot be deleted`

**HTTP Status:** 403 Forbidden

**Resolution:** XP ledger is append-only. If correction needed, add adjustment entry.

---

## Escrow System Errors (HX201-HX299)

### HX201 - Release Without Completed Task (INV-2)

**Trigger:** Attempting to release escrow when task is not COMPLETED

**Enforcement:** Database trigger `escrow_released_requires_completed_task`

**Message:** `Escrow cannot be released: task state is {state}, must be COMPLETED`

**HTTP Status:** 409 Conflict

**Resolution:** Task must reach COMPLETED state before escrow can be released.

---

## Task System Errors (HX301-HX399)

### HX301 - Complete Without Accepted Proof (INV-3)

**Trigger:** Attempting to complete task without accepted proof

**Enforcement:** Database trigger `task_completed_requires_accepted_proof`

**Message:** `Task cannot be completed: no accepted proof exists`

**HTTP Status:** 409 Conflict

**Resolution:** Proof must be accepted before task can be completed.

---

## Badge System Errors (HX401-HX499)

### HX401 - Badge Deletion Attempt

**Trigger:** Attempting to delete a badge entry

**Enforcement:** Database trigger `badge_ledger_no_delete`

**Message:** `Badge entries cannot be deleted`

**HTTP Status:** 403 Forbidden

**Resolution:** Badges are permanent. Cannot be revoked.

---

## User System Errors (HX501-HX599)

### HX501 - Authentication Required

**Trigger:** Request without valid authentication

**Message:** `Authentication required`

**HTTP Status:** 401 Unauthorized

---

### HX502 - Invalid Authentication Token

**Trigger:** Invalid or expired JWT

**Message:** `Invalid authentication token`

**HTTP Status:** 401 Unauthorized

---

### HX503 - Insufficient Permissions

**Trigger:** User lacks permission for action

**Message:** `Insufficient permissions for this action`

**HTTP Status:** 403 Forbidden

---

### HX504 - User Not Found

**Trigger:** Referenced user does not exist

**Message:** `User not found`

**HTTP Status:** 404 Not Found

---

## Fatigue/Pause Errors (HX601-HX699)

### HX601 - Fatigue Break Bypass Attempt

**Trigger:** Attempting to bypass mandatory fatigue break (FATIGUE-4)

**Enforcement:** Backend service

**Message:** `Mandatory break required. Please wait {minutes} minutes.`

**HTTP Status:** 429 Too Many Requests

---

### HX602 - Pause State Violation

**Trigger:** Attempting action during PAUSED account state

**Message:** `Account is paused. Resume to continue.`

**HTTP Status:** 403 Forbidden

---

### HX603 - Poster Reputation Access Violation

**Trigger:** Poster attempting to view their own reputation (POSTER-1)

**Message:** `Poster reputation is not visible to posters`

**HTTP Status:** 403 Forbidden

---

### HX604 - Percentile Public Exposure Attempt

**Trigger:** Attempting to expose percentile data publicly (PERC-1)

**Message:** `Percentile data cannot be made public`

**HTTP Status:** 403 Forbidden

---

## AI System Errors (HX701-HX799)

### HX701 - AI Question After Locked

**Trigger:** AI question attempted after task LOCKED (COMPLETE-3)

**Enforcement:** Backend service

**Message:** `AI questions not allowed after task is locked`

**HTTP Status:** 409 Conflict

---

### HX702 - Escrow Funding Before Complete

**Trigger:** Attempting to fund escrow before AI state = COMPLETE (COMPLETE-4)

**Enforcement:** Database trigger

**Message:** `Escrow cannot be funded: task AI state is {state}, must be COMPLETE`

**HTTP Status:** 409 Conflict

---

### HX703 - Invalid AI Question Type

**Trigger:** AI question type not in allowed list (COMPLETE-5)

**Enforcement:** Backend validation

**Message:** `Invalid question type. Allowed: LOCATION_CLARITY, TIME_CONSTRAINTS, TASK_SCOPE, PROOF_EXPECTATION`

**HTTP Status:** 400 Bad Request

---

### HX704 - Confidence Threshold Bypass

**Trigger:** Attempting to bypass AI confidence threshold (COMPLETE-6)

**Enforcement:** Backend validation

**Message:** `Confidence threshold cannot be bypassed`

**HTTP Status:** 403 Forbidden

---

## Messaging Errors (HX801-HX899)

### HX801 - Message Outside Active Task States

**Trigger:** Message sent when task not in ACCEPTED/PROOF_SUBMITTED/DISPUTED (MSG-1)

**Enforcement:** Database trigger

**Message:** `Messages can only be sent during ACCEPTED, PROOF_SUBMITTED, or DISPUTED states`

**HTTP Status:** 409 Conflict

---

### HX802 - Message Sender Not Participant

**Trigger:** Message sender is not task poster or worker (MSG-2)

**Enforcement:** Database trigger

**Message:** `Message sender must be task poster or worker`

**HTTP Status:** 403 Forbidden

---

### HX803 - Message Photo Limit Exceeded

**Trigger:** More than 3 photos in message (MSG-3)

**Enforcement:** Database constraint

**Message:** `Maximum 3 photos allowed per message`

**HTTP Status:** 400 Bad Request

---

### HX804 - Message Content Too Long

**Trigger:** Message exceeds 500 characters (MSG-4)

**Enforcement:** Database constraint

**Message:** `Message content exceeds 500 character limit`

**HTTP Status:** 400 Bad Request

---

### HX805 - Notification To Non-Participant

**Trigger:** Notification sent to non-task participant (NOTIF-1)

**Enforcement:** Backend validation

**Message:** `Notifications can only be sent to task participants`

**HTTP Status:** 403 Forbidden

---

### HX806 - Notification Rate Limit

**Trigger:** Notification frequency limit exceeded (NOTIF-3)

**Enforcement:** Backend rate limiting

**Message:** `Notification rate limit exceeded for this category`

**HTTP Status:** 429 Too Many Requests

---

### HX807 - Rating Before Completed

**Trigger:** Rating submitted before task COMPLETED (RATE-1)

**Enforcement:** Database trigger

**Message:** `Ratings can only be submitted after task is COMPLETED`

**HTTP Status:** 409 Conflict

---

### HX808 - Rating Window Expired

**Trigger:** Rating submitted after 7-day window (RATE-2)

**Enforcement:** Backend validation

**Message:** `Rating window has expired (7 days)`

**HTTP Status:** 409 Conflict

---

### HX809 - Rating Modification Attempt

**Trigger:** Attempting to edit/delete rating (RATE-4)

**Enforcement:** Database trigger

**Message:** `Ratings cannot be modified after submission`

**HTTP Status:** 403 Forbidden

---

### HX810 - Rating Stars Invalid

**Trigger:** Star rating not 1-5 (RATE-6)

**Enforcement:** Database constraint

**Message:** `Star rating must be between 1 and 5`

**HTTP Status:** 400 Bad Request

---

### HX811 - Rating Comment Too Long

**Trigger:** Rating comment exceeds 500 characters

**Enforcement:** Backend validation

**Message:** `Rating comment exceeds 500 character limit`

**HTTP Status:** 400 Bad Request

---

## Live Mode & Fraud Errors (HX901-HX999)

### HX901 - Live Broadcast Without Funded Escrow

**Trigger:** Live broadcast without FUNDED escrow (LIVE-1)

**Enforcement:** Database trigger

**Message:** `Live broadcast cannot start: escrow must be FUNDED`

**HTTP Status:** 409 Conflict

---

### HX902 - Live Task Below Price Floor

**Trigger:** Live task price below $15.00 minimum (LIVE-2)

**Enforcement:** Database constraint

**Message:** `Live tasks require minimum price of $15.00`

**HTTP Status:** 400 Bad Request

---

### HX903 - Hustler Not In Active State

**Trigger:** Live accept while in OFF/COOLDOWN/PAUSED

**Message:** `Cannot accept Live tasks: current state is {state}`

**HTTP Status:** 403 Forbidden

---

### HX904 - Live Mode Toggle Cooldown

**Trigger:** Toggle attempt within 5 minutes of last toggle

**Message:** `Live Mode toggle cooldown: wait {seconds} seconds`

**HTTP Status:** 429 Too Many Requests

---

### HX905 - Live Mode Banned

**Trigger:** Attempt to enable Live Mode while banned

**Message:** `Live Mode access suspended until {date}`

**HTTP Status:** 403 Forbidden

---

### HX951 - Content Moderation Scan Failed

**Trigger:** Content moderation scan failure (MOD-1)

**Message:** `Content moderation scan failed`

**HTTP Status:** 500 Internal Server Error

---

### HX952 - Critical Content Not Quarantined

**Trigger:** CRITICAL content not auto-quarantined (MOD-2)

**Message:** `Content flagged for review`

**HTTP Status:** 403 Forbidden

---

### HX953 - Review Queue SLA Missing

**Trigger:** Review queue item without SLA deadline (MOD-3)

**Message:** `Review queue configuration error`

**HTTP Status:** 500 Internal Server Error

---

### HX954 - Appeal Same Admin

**Trigger:** Appeal reviewed by same admin who made original decision (MOD-4)

**Message:** `Appeals must be reviewed by different administrator`

**HTTP Status:** 409 Conflict

---

### HX971 - GDPR Export Overdue

**Trigger:** Data export not processed within 30 days (GDPR-1)

**Message:** `Data export request processing delayed`

**HTTP Status:** 500 Internal Server Error

---

### HX972 - GDPR Deletion Overdue

**Trigger:** Data deletion not processed within 7 days (GDPR-2)

**Message:** `Data deletion request processing delayed`

**HTTP Status:** 500 Internal Server Error

---

### HX973 - Consent Record Modification

**Trigger:** Attempting to modify consent record (GDPR-3)

**Enforcement:** Database trigger

**Message:** `Consent records cannot be modified`

**HTTP Status:** 403 Forbidden

---

### HX974 - Legal Retention Violation

**Trigger:** Attempting to delete data in legal retention period (GDPR-4)

**Message:** `Data in legal retention period cannot be deleted`

**HTTP Status:** 403 Forbidden

---

### HX975 - Data Breach Notification Overdue

**Trigger:** Breach notification not sent within 72 hours (GDPR-5)

**Message:** `Data breach notification required`

**HTTP Status:** 500 Internal Server Error

---

## Generic Errors

### VALIDATION_ERROR

**Trigger:** Request body validation failed

**Message:** `Validation failed: {details}`

**HTTP Status:** 400 Bad Request

---

### NOT_FOUND

**Trigger:** Resource not found

**Message:** `{resource} not found`

**HTTP Status:** 404 Not Found

---

### INTERNAL_ERROR

**Trigger:** Unexpected server error

**Message:** `An unexpected error occurred`

**HTTP Status:** 500 Internal Server Error

---

### RATE_LIMITED

**Trigger:** Rate limit exceeded

**Message:** `Too many requests. Try again in {seconds} seconds.`

**HTTP Status:** 429 Too Many Requests

---

## Error Handling Implementation

### TypeScript Error Class

```typescript
// src/utils/errors.ts
export class HXError extends Error {
  constructor(
    public code: string,
    public message: string,
    public statusCode: number = 400,
    public details?: Record<string, unknown>
  ) {
    super(message);
    this.name = 'HXError';
  }
}

// Usage
throw new HXError('HX101', 'XP cannot be awarded: escrow not released', 409, {
  escrow_id: escrowId,
  current_state: 'FUNDED',
});
```

### Error Middleware

```typescript
// src/api/middleware/error.middleware.ts
export const errorMiddleware = async (err: Error, c: Context) => {
  if (err instanceof HXError) {
    return c.json({
      success: false,
      error: {
        code: err.code,
        message: err.message,
        details: err.details,
      },
      timestamp: new Date().toISOString(),
    }, err.statusCode);
  }

  // Log unexpected errors
  console.error('Unexpected error:', err);

  return c.json({
    success: false,
    error: {
      code: 'INTERNAL_ERROR',
      message: 'An unexpected error occurred',
    },
    timestamp: new Date().toISOString(),
  }, 500);
};
```

### Frontend Error Handling

```typescript
// Frontend error handler
async function handleApiError(response: Response) {
  const body = await response.json();

  if (!body.success) {
    const { code, message } = body.error;

    // Map error codes to user-friendly messages
    const userMessages: Record<string, string> = {
      HX101: 'Payment must be completed before earning XP.',
      HX301: 'Please upload proof before marking complete.',
      HX901: 'Payment required to start live broadcast.',
      // ... etc
    };

    toast.error(userMessages[code] || message);

    // Log for debugging
    console.error(`API Error ${code}:`, message);
  }
}
```

---

## Quick Reference Table

| Code | Name | HTTP | Enforcement |
|------|------|------|-------------|
| HX001 | Task Terminal Violation | 409 | DB Trigger |
| HX002 | Escrow Terminal Violation | 409 | DB Trigger |
| HX004 | Escrow Amount Immutable | 409 | DB Trigger |
| HX101 | XP Without Released Escrow | 409 | DB Trigger |
| HX102 | XP Ledger Delete | 403 | DB Trigger |
| HX201 | Release Without Completed | 409 | DB Trigger |
| HX301 | Complete Without Proof | 409 | DB Trigger |
| HX401 | Badge Delete | 403 | DB Trigger |
| HX701 | AI Question After Locked | 409 | Backend |
| HX702 | Fund Before Complete | 409 | DB Trigger |
| HX801 | Message Wrong State | 409 | DB Trigger |
| HX807 | Rating Before Complete | 409 | DB Trigger |
| HX809 | Rating Immutable | 403 | DB Trigger |
| HX901 | Live Without Escrow | 409 | DB Trigger |
| HX902 | Live Price Too Low | 400 | DB Constraint |

---

**END OF ERROR_CODES v1.0.0**
