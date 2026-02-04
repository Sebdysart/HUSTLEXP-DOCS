# OFFLINE RESILIENCE SPECIFICATION

**Authority:** SPATIAL_INTELLIGENCE_LOCKED §14 | PLATFORM_SPECIFIC.md
**Status:** v1.0 — Launch-ready specification
**Subsystem:** LOCKED

---

## §1. Problem Statement

Workers perform tasks in basements, rural areas, and buildings with poor connectivity. Critical actions (proof submission, arrival marking, messaging) must not fail silently when offline.

---

## §2. Offline Action Queue

### 2.1 Queued Actions (Critical)

| Action | Priority | Staleness Limit |
|---|---|---|
| `proof.submit` | 1 (highest) | 60 minutes |
| `task.markArrived` | 2 | 30 minutes |
| `messaging.send` | 3 | 30 minutes |
| `task.updateStatus` | 2 | 30 minutes |
| `location.update` | 4 (lowest) | 5 minutes |

### 2.2 NOT Queued (Require Real-Time)

| Action | Reason |
|---|---|
| `task.accept` | Must verify escrow + availability in real-time |
| `task.create` | Must process payment in real-time |
| `payment.*` | Must verify with Stripe in real-time |
| `dispute.open` | Must lock escrow in real-time |

---

## §3. Queue Behavior

**Storage:** AsyncStorage (React Native) with encryption.

**On action attempt while offline:**
1. Action added to local queue with timestamp and payload
2. UI shows optimistic state with "Pending sync" indicator (subtle pulse icon)
3. Toast: "Saved. Will sync when connected."

**On connectivity restore:**
1. Queue processes in priority order (§2.1)
2. Each action retried up to 3 times with 5s backoff
3. If action succeeds: remove from queue, update UI
4. If action fails after 3 retries: notify user with actionable error

**Staleness check:**
- Before sending queued action, check timestamp against staleness limit
- If expired: discard action, notify user: "Your [action] couldn't be sent — it's been too long. Please try again."
- Rationale: A proof submitted 2 hours after connectivity loss may be invalid (task may have been cancelled)

---

## §4. Conflict Resolution

| Conflict | Resolution |
|---|---|
| Queued `proof.submit` but task was cancelled while offline | Discard proof, notify worker |
| Queued `messaging.send` but thread was closed | Discard message, notify sender |
| Queued `task.markArrived` but task was reassigned | Discard, notify worker |
| Multiple queued location updates | Send only the most recent |

**Rule:** Server state always wins. Queued actions are best-effort.

---

## §5. Offline Indicators

| Condition | UI Treatment |
|---|---|
| Device offline | Top banner: "No connection — actions will sync when you're back online" |
| Queue has pending items | Badge on status bar: "2 pending" |
| Action discarded (stale) | Push notification explaining why |
| All items synced | Brief toast: "All caught up" |

---

## §6. Implementation Notes

- Use `@react-native-community/netinfo` for connectivity detection
- Queue stored in AsyncStorage under key `offline_action_queue`
- Queue encrypted with device keychain key
- Maximum queue size: 50 actions (prevent storage abuse)
- Queue persists across app restarts

---

**END OF OFFLINE_RESILIENCE_SPEC v1.0.0**
