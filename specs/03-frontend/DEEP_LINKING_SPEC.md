# DEEP LINKING SPECIFICATION

**Authority:** NOTIFICATION_SPEC | SCREEN_REGISTRY | API_CONTRACT
**Status:** v1.0 — Launch-ready specification
**Subsystem:** LOCKED

---

## §1. URI Scheme

**Custom scheme:** `hustlexp://`
**Universal links (iOS):** `https://hustlexp.com/...`
**App Links (Android):** `https://hustlexp.com/...`

---

## §2. Route Map

| URI Pattern | Screen | Context |
|---|---|---|
| `hustlexp://task/{task_id}` | H4-task-detail | View task details |
| `hustlexp://task/{task_id}/active` | H5-active-task | Worker's active task |
| `hustlexp://task/{task_id}/chat` | SH1-task-conversation | Message thread for task |
| `hustlexp://feed` | H2-task-feed | Main task feed |
| `hustlexp://profile` | S1-profile | User profile |
| `hustlexp://wallet` | S2-wallet | Wallet / earnings |
| `hustlexp://settings` | Settings screen | App settings |
| `hustlexp://notifications` | Notification list | All notifications |
| `hustlexp://dispute/{dispute_id}` | Dispute detail | View dispute status |
| `hustlexp://referral/{code}` | Signup with referral | Pre-fill referral code |
| `hustlexp://verify-email/{token}` | Email verification | Confirm email |
| `hustlexp://reset-password/{token}` | Password reset | Reset flow |
| `hustlexp://update` | E5-force-update | Force update screen |

---

## §3. Notification → Deep Link Mapping

| Notification Type | Deep Link |
|---|---|
| `task.accepted` | `hustlexp://task/{task_id}/active` |
| `task.completed` | `hustlexp://task/{task_id}` |
| `task.disputed` | `hustlexp://dispute/{dispute_id}` |
| `message.received` | `hustlexp://task/{task_id}/chat` |
| `proof.submitted` | `hustlexp://task/{task_id}` |
| `proof.rejected` | `hustlexp://task/{task_id}/active` |
| `payment.released` | `hustlexp://wallet` |
| `trust_tier.changed` | `hustlexp://profile` |
| `system.force_update` | `hustlexp://update` |

---

## §4. Fallback Behavior

| Condition | Behavior |
|---|---|
| App installed, user logged in | Navigate to target screen |
| App installed, user NOT logged in | Store deep link → navigate after login |
| App NOT installed (universal link) | Redirect to App Store / Play Store |
| App NOT installed (custom scheme) | Nothing (standard OS behavior) |
| Invalid route / missing resource | Navigate to home screen with toast error |

---

## §5. Implementation

**React Navigation deep linking config:**
```typescript
const linking = {
  prefixes: ['hustlexp://', 'https://hustlexp.com'],
  config: {
    screens: {
      TaskDetail: 'task/:taskId',
      ActiveTask: 'task/:taskId/active',
      TaskChat: 'task/:taskId/chat',
      Feed: 'feed',
      Profile: 'profile',
      Wallet: 'wallet',
    }
  }
};
```

**Apple Associated Domains:** `applinks:hustlexp.com`
**Android Asset Links:** `.well-known/assetlinks.json` on `hustlexp.com`

---

**END OF DEEP_LINKING_SPEC v1.0.0**
