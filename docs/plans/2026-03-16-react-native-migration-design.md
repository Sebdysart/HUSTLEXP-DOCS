# HustleXP React Native Migration — Design Document

**Date:** 2026-03-16
**Status:** APPROVED
**Author:** Claude (max-tier orbit loop)

---

## Goal

Migrate HustleXP frontend from SwiftUI (iOS-only) to React Native + Expo (iOS + Android) to capture the full mobile TAM. New repo `Sebdysart/hustlexp-rn`. Zero backend changes. Full feature parity in 4 weeks with AI-assisted development.

---

## Architecture

- **Base**: Expo SDK 52 + bare workflow (full native access, EAS toolchain, OTA updates)
- **Navigation**: Expo Router v3 (file-based, deep links built-in, matches iOS Router mental model)
- **Animations**: React Native Reanimated 3 + React Native Skia (Revolut motion language preserved exactly)
- **API**: `@trpc/client` + `@trpc/react-query` — zero backend changes, type-safe end-to-end
- **Backend URLs**: prod `https://hustlexp-ai-backend-production.up.railway.app`, staging `https://hustlexp-ai-backend-staging-production.up.railway.app`
- **tRPC wire format**: queries → GET `/trpc/{router}.{procedure}?input=JSON`, mutations → POST `/trpc/{router}.{procedure}`

---

## Tech Stack

| Layer | Library | Swift Equivalent |
|---|---|---|
| Navigation | Expo Router v3 | Router @Observable + NavigationStack |
| Animations | Reanimated 3 + Skia | SwiftUI Animation + Shape protocol |
| Styling | NativeWind v4 | SwiftUI modifiers |
| API | @trpc/client + @trpc/react-query | TRPCClient.swift |
| Auth | @react-native-firebase/auth | AuthService.swift + Firebase |
| Payments | @stripe/stripe-react-native | StripePaymentManager.swift |
| State | Zustand + MMKV | @Observable + UserDefaults |
| Real-time | react-native-sse | RealtimeSSEClient.swift |
| Maps | react-native-maps | MapKit |
| Location | expo-location | LocationService.swift |
| Camera | expo-camera + expo-image-picker | AVFoundation |
| Biometrics | expo-local-authentication | BiometricService.swift |
| Push | @react-native-firebase/messaging | PushNotificationManager.swift |
| SSL Pinning | react-native-ssl-pinning | CertificatePins.swift |
| Haptics | expo-haptics | UIImpactFeedbackGenerator |
| Storage | MMKV | UserDefaults |
| CI/CD | EAS Build + EAS Submit + EAS Update | Xcode + App Store Connect |

---

## Folder Structure

```
hustlexp-rn/
├── app/                           # Expo Router — file-based navigation
│   ├── _layout.tsx                # Root layout — auth gate, theme provider
│   ├── index.tsx                  # Splash/redirect
│   ├── (auth)/
│   │   ├── _layout.tsx
│   │   ├── login.tsx
│   │   ├── signup.tsx
│   │   ├── phone-verification.tsx
│   │   └── forgot-password.tsx
│   ├── (onboarding)/
│   │   ├── _layout.tsx
│   │   ├── welcome.tsx
│   │   ├── role-selection.tsx
│   │   ├── profile-setup.tsx
│   │   ├── skills.tsx
│   │   ├── permissions.tsx
│   │   └── complete.tsx
│   ├── (hustler)/
│   │   ├── _layout.tsx            # Bottom tab navigator (Home, Feed, Earnings, Profile)
│   │   ├── index.tsx              # HustlerHomeScreen
│   │   ├── feed.tsx
│   │   ├── task/
│   │   │   └── [id].tsx
│   │   ├── task-in-progress/
│   │   │   └── [id].tsx
│   │   ├── proof-submission/
│   │   │   └── [id].tsx
│   │   ├── earnings.tsx
│   │   ├── xp-breakdown.tsx
│   │   ├── history.tsx
│   │   ├── profile.tsx
│   │   ├── live-radar.tsx
│   │   ├── heat-map.tsx
│   │   ├── squads/
│   │   │   ├── index.tsx
│   │   │   └── [id].tsx
│   │   └── tax.tsx
│   ├── (poster)/
│   │   ├── _layout.tsx            # Bottom tab navigator (Home, Tasks, History, Profile)
│   │   ├── index.tsx              # PosterHomeScreen
│   │   ├── create-task.tsx
│   │   ├── asap-task.tsx
│   │   ├── ai-task.tsx
│   │   ├── task/
│   │   │   └── [id].tsx
│   │   ├── applicants/
│   │   │   └── [id].tsx
│   │   ├── proof-review/
│   │   │   └── [id].tsx
│   │   ├── active-tasks.tsx
│   │   ├── history.tsx
│   │   ├── profile.tsx
│   │   └── recurring/
│   │       ├── index.tsx
│   │       └── [id].tsx
│   ├── (shared)/
│   │   ├── messages/
│   │   │   ├── index.tsx          # MessagesInboxScreen
│   │   │   └── [id].tsx           # ConversationScreen
│   │   ├── dispute/
│   │   │   └── [id].tsx
│   │   ├── file-claim/
│   │   │   └── [id].tsx
│   │   ├── claims-history.tsx
│   │   ├── notifications.tsx
│   │   └── referral.tsx
│   ├── (settings)/
│   │   ├── _layout.tsx
│   │   ├── index.tsx              # SettingsMainScreen
│   │   ├── account.tsx
│   │   ├── payment.tsx
│   │   ├── notifications.tsx
│   │   ├── privacy.tsx
│   │   ├── subscription.tsx
│   │   ├── verification.tsx
│   │   └── help.tsx
│   ├── (admin)/
│   │   └── beta-dashboard.tsx
│   └── (edge)/
│       ├── maintenance.tsx
│       ├── network-error.tsx
│       ├── force-update.tsx
│       ├── no-tasks.tsx
│       └── eligibility.tsx
├── src/
│   ├── animations/
│   │   ├── RankUpView.tsx         # Port of RankUpView.swift (Reanimated 3 + Skia)
│   │   ├── XPBurstView.tsx        # Port of XPBurstView.swift (Revolut-grade rebuild)
│   │   └── constants.ts           # BEZIER_EASE_OUT = [0.22, 0, 0.36, 1]
│   ├── components/
│   │   ├── atoms/
│   │   ├── molecules/
│   │   └── organisms/
│   ├── services/                  # tRPC call wrappers — 1:1 with Swift services
│   │   ├── TaskService.ts
│   │   ├── AuthService.ts
│   │   ├── MessagingService.ts
│   │   ├── EscrowService.ts
│   │   └── ...
│   ├── models/                    # TypeScript types — port of Swift models
│   ├── design/
│   │   ├── tokens.ts              # All colors from ColorTokens.swift
│   │   ├── typography.ts
│   │   └── spacing.ts
│   ├── lib/
│   │   ├── trpc.ts                # tRPC client (mirrors TRPCClient.swift)
│   │   ├── firebase.ts
│   │   └── stripe.ts
│   ├── hooks/
│   │   ├── useAuth.ts
│   │   ├── useTRPC.ts
│   │   └── useSSE.ts
│   └── store/
│       ├── authStore.ts
│       ├── userStore.ts
│       └── taskStore.ts
├── assets/
├── eas.json                       # dev / preview / production
├── app.json
├── tailwind.config.js
├── tsconfig.json                  # strict: true
└── .github/
    └── workflows/
        └── ci.yml                 # type-check + lint on PR
```

---

## Screen Build Phases

### Phase 1 — Foundation + Auth + Onboarding (Week 1)
Expo bare scaffold → all deps → EAS → design tokens → tRPC client → Firebase → 12 screens

**Screens:** Splash, Login, Signup, PhoneVerification, ForgotPassword, Welcome, RoleSelection, ProfileSetup, SkillSelection, Permissions, OnboardingComplete

### Phase 2 — Money Flows J1 + J2 (Week 2)
Hustler + Poster core flows, escrow, tab navigation

**Screens:** HustlerHome, HustlerFeed, HustlerTaskDetail, TaskInProgress, ProofSubmission, PosterHome, CreateTask, ASAPTask, AITask, PosterTaskDetail, ApplicantList, ProofReview, TaskManagement, BatchDetails, Earnings

### Phase 3 — Communication + Trust + Settings (Week 3)
Messaging, disputes, ratings, all 8 settings screens

**Screens:** MessagesInbox, Conversation, Dispute, FileClaim, ClaimsHistory, NotificationCenter, RateTaskSheet, Referral, HustlerHistory, PosterHistory, SettingsMain, Account, Payment, NotificationSettings, Privacy, Subscription, Verification, Help

### Phase 4 — Gamification + Advanced (Week 4)
Revolut-grade animations, maps, squads, admin, edge cases

**Screens:** XPBreakdown, LiveRadar, HeatMapFullscreen, SquadsHub, SquadDetail, LockedQuests, TaxPayment, RecurringTasks, RecurringTaskDetail, BetaDashboard, Eligibility, ForceUpdate, Maintenance, NetworkError, NoTasks

**Animations:** XPBurstView (Reanimated 3 rebuild), RankUpView (Skia shield + Reanimated 3)

---

## EAS Configuration

```json
{
  "cli": { "version": ">= 7.0.0" },
  "build": {
    "development": {
      "developmentClient": true,
      "distribution": "internal",
      "env": { "APP_ENV": "development" }
    },
    "preview": {
      "distribution": "internal",
      "env": { "APP_ENV": "staging" }
    },
    "production": {
      "env": { "APP_ENV": "production" }
    }
  },
  "submit": {
    "production": {
      "ios": { "appleId": "...", "ascAppId": "..." },
      "android": { "serviceAccountKeyPath": "./google-service-account.json" }
    }
  }
}
```

---

## Revolut Motion Design Language (React Native)

All animations use:
```ts
const EASE_OUT = Easing.bezier(0.22, 0, 0.36, 1)
// withTiming(value, { duration: Xms, easing: EASE_OUT })
// NO spring, NO bounce, NO overshoot
// MAX 1 focal point, MAX 5 elements, MAX 1 ring
// No particles ever
```

---

## Backend Parity

Zero backend changes required. The tRPC client in React Native sends identical HTTP requests to the existing Railway backend:
- Queries: `GET /trpc/{router}.{procedure}?input={json}`
- Mutations: `POST /trpc/{router}.{procedure}` with JSON body
- Auth header: `Authorization: Bearer {firebaseJWT}`
- Snake case decoding: all field names are snake_case from DB → camelCase in app
