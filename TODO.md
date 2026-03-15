# HustleXP — Master To-Do List

**Last updated:** 2026-03-15
**Status:** Private Beta Ready (100/100 scorecard) — working toward public launch

Items are grouped by track and ordered by priority. P0 = blocking launch. P1 = high priority. P2 = important but not blocking.

---

## ⚖️ Legal Track

### P0 — Must complete before any user signs a document

- [ ] **Fill `[State]`** — choose governing jurisdiction across all 6 legal documents. Note: California triggers PAGA exposure and AB5/Dynamex complications. Discuss with counsel before deciding.
- [ ] **Fill `[Effective Date]`** — populate in all 6 documents: Hustler Agreement, Poster Agreement, Beta NDA, AUP, Arbitration Agreement, Background Check Consent.
- [ ] **Fill `[Address]`** — HustleXP legal department mailing address in Arbitration Agreement (Sections 3.2 and 5.1 — opt-out notice delivery address).

### P0 — Counsel review

- [ ] **Hire gig economy lawyer** to review full document suite before deployment. Priority review items: PAGA waiver enforceability in target state, AAA fee schedule current as of 2024 rules, FCRA adverse action timeline compliance for Checkr integration.
- [ ] **Publish cancellation fee schedule** at `https://hustlexp.com/legal/cancellation-fees` — referenced by Poster Agreement Exhibit A and Section 4.4. Must be live and versioned before Poster Agreement is executed.

### P1 — Pre-launch

- [ ] **Get Checkr API authorization** — account "hustlr" at dashboard.checkr.com is pending authorization. Email sent to Checkr. Follow up with phone call if no response within 5 business days. Consider having lawyer send authorization request on letterhead.
- [ ] **Wire Checkr API** to Background Check Consent flow once authorization granted — replace beta-period manual process with live API calls.

---

## 💰 Revenue / Profitability Track

These are bugs where the platform earns $0 or less than it should. All identified in March 2026 revenue audit.

### P0 — Platform is not collecting fees correctly

- [x] **Platform fee collection** — FIXED via Separate Charges and Transfers model. `escrow-action-worker.ts` now computes `platformFeeCents = Math.round(escrowAmount * 0.15)` and transfers only `netPayoutCents = escrowAmount - platformFeeCents` to the worker. Platform implicitly keeps the fee difference. Commit `850f9207`.
- [x] **Fix escrow fee calculation in `EscrowService.ts:337`** — `grossPayoutCents = task.price` should be `escrow.amount`. Platform misses the surge premium cut because surge is applied to escrow amount, not base task price. Fixed in commit `850f9207`.

### P1 — Revenue leaks

- [x] **Wire `SelfInsurancePoolService.recordContribution()`** — method exists but is never called from `EscrowService.release()`. Self-insurance pool is permanently $0. Wired the call on every successful escrow release. Fixed in commit `850f9207`.
- [ ] **Add platform cut on tips in `TippingService.ts:98`** — tips currently earn $0 and cost the platform Stripe processing fees. Add 5–8% platform cut. Update Poster Agreement and Hustler Agreement fee disclosures accordingly.
- [x] **Fix subscription renewal revenue logging** — Stripe `invoice.paid` webhook not wired for recurring subscriptions. Only month 1 revenue is logged. Added `invoice.paid` + `charge.dispute.*` handlers in `stripe-event-worker.ts`. Fixed in commit `850f9207`.
- [ ] **Fix XP tax dead code path in `EscrowService.ts:336`** — `paymentMethod` hardcoded to `'escrow'`, making the XP tax path unreachable for non-escrow payment methods. Derive from task metadata.

### P2 — Future revenue

- [ ] **Build background check freemium model** — workers can either pay $X upfront for background check OR complete low-risk tasks until platform has earned enough (threshold: ~$60 cumulative platform fees from that worker ≈ $400 in tasks at 15%) to cover the Checkr fee and give them a free background check. Track per-worker cumulative platform earnings in `EarnedVerificationUnlockService`. Auto-initiate Checkr at threshold.

---

## 📱 iOS Feature Sync Track

Features that exist in the backend but are stubbed, mocked, or broken in the iOS app.

### P0 — Financial safety path broken

- [x] **Implement backend `dispute.create` procedure** — No `dispute` router existed in the backend. Created `backend/src/routers/dispute.ts` with `create`, `getById`, `getByTask`, and `getMine` procedures. Registered in `backend/src/routers/index.ts`. Commit `c6e9ce57`.
- [x] **Wire real dispute submission in `DisputeScreen.swift:73-85`** — previously used `DispatchQueue.main.asyncAfter(deadline: .now() + 2)` fake success with NO tRPC call. Replaced with real `disputeRouter.create` tRPC call. Commit `9f94e39`.

### P1 — High priority stubs

- [ ] **Fix biometric proof result in `ProofSubmissionViewModel.swift:280-284`** — `dataService.validateBiometricProof()` returns a local mock result, not the API response. Fix: use actual response from `biometric.submitVerification` tRPC call.
- [ ] **Remove squad stubs in `SquadService.swift:151-171`** — 3 methods hardcoded as stubs when live backend procedures exist:
  - `getSquadTasks()` returns `[]` — backend `squad.listTasks` exists at `squad.ts:550`
  - `acceptSquadTask()` throws 501 — backend `squad.acceptTask` exists
  - `getLeaderboard()` returns `[]` — backend `squad.leaderboard` exists at `squad.ts:826`
- [ ] **Fix `squad.disband` field mismatch** — `SquadService.swift:82` sends `DisbandInput(id: id)` but backend `squad.ts:455` validates `z.object({ squadId: Schemas.uuid })`. LIVE BUG — disband silently fails. Fix: rename struct field from `id` to `squadId` in iOS. Do NOT change the backend schema.
- [x] **Fix pre-existing build errors in ConversationScreen + NotificationService** — `HXMessage.senderName` no longer exists (use `senderId`); `NotificationPreferences` convenience init added. Commit `9f94e39`.
- [ ] **Commit 1 uncommitted change in `hustlexp-ios`** — omni-link digest shows 1 uncommitted change. Identify and commit.

### P2 — Missing screens

- [ ] **Build jury voting screen** — backend `jury.submitVote` and `jury.getVoteTally` procedures exist and are wired. iOS has no screen to reach them.
- [ ] **Build daily challenges screen** — backend `challenges` router fully implemented. Screen is missing from Hustler Home navigation.
- [ ] **Fix batch quest** — needs to call `buildRoute` and claim all tasks. Currently broken flow.
- [ ] **Add featured listing UI for Posters** — backend `featured.createFeaturingAd` exists. No Poster UI to boost a task listing.

---

## 🔒 Security / Backend Track

From omni-link evolution analysis and domain reorganization audit.

### P1

- [ ] **Zod validation audit** — verify all 460 tRPC procedures have `.input(z.object(...))` schemas. Current coverage: 65.9% (303/460 across 50 routers). Target: 95%+. The `hustlerProcedure` and `posterProcedure` role guards added in commit `acef5c42` are a good foundation — validation should be the next layer.
- [ ] **Rate limiting coverage audit** — omni-link digest flags 140 mutation routes with no rate-limiting middleware detected. Audit `security.ts` to confirm actual coverage. If gaps exist, add Hono-compatible rate limiting per route group.
- [ ] **Fix pre-existing test failure in `task-router.test.ts`** — `task.getById > throws NOT_FOUND when task does not exist` fails with mock setup issue (`TaskService.getById` returning `undefined` instead of `{ success: false }`). Pre-existing, not introduced by role guard changes.

### P2

- [ ] **Add pagination to unbounded list endpoints** — omni-link flags 27 list procedures with no pagination: `admin.listUsers`, `admin.listTasks`, `instant.listAvailable`, `notification.getList`, `recurringTask.listMine`, `recurringTask.listOccurrences`, `squad.listMine`, `squad.listInvites`, `squad.listTasks`, `task.listByPoster`, `task.listByWorker`, `task.listOpen`, `task.listApplicants`, `taskDiscovery.search` and others. Without pagination these return unbounded data under load.
- [ ] **API versioning** — add `/v1/` prefix to REST endpoints in `server.ts`. tRPC procedures are inherently versioned by procedure name but the REST health/status endpoints at `/health`, `/api/*` have no versioning.

---

## 🧪 iOS E2E Testing Plugin Track

### P1 — Infrastructure investment (post-revenue-fix, pre-public-launch)

- [ ] **Extract `TRPCClientProtocol`** — prerequisite for all ViewInspector tests. Extract a Swift protocol from the concrete `TRPCClient` class with `call(router:procedure:type:input:) async throws -> Output`. Inject via `@Environment` in ViewModels. This is a ~2-day refactor that also enables proper ViewModel unit tests in the existing test suite.

- [ ] **Layer 3: FSM model-based tests for Escrow + Task lifecycle** — Highest-value layer. Build exhaustive path coverage from transition matrix using Swift Testing `@Test(..., arguments:)`. State machines to cover: Escrow (PENDING→FUNDED→RELEASED/REFUNDED/LOCKED_DISPUTE), Task (OPEN→ASSIGNED→IN_PROGRESS→COMPLETED/CANCELLED/DISPUTED), Dispute (OPEN→UNDER_REVIEW→RESOLVED/CLOSED). Auto-generates every valid transition — not handwritten test cases.

- [ ] **Layer 2 + 1: ViewInspector + AST scaffolding** — Add `Inspectable` conformance (or `#if DEBUG` protocol) to top 10 critical ViewModels. Use SwiftSyntax AST parsing to auto-generate test plan from `@State`/`@Binding` declarations. Requires `TRPCClientProtocol` extraction above.

- [ ] **Layer 4: Semantic snapshot tests** — JSON/YAML view tree dumps via ViewInspector for error states and business-critical UI conditions. CI-stable (no pixel flakiness). Apply to: payment failure banner, escrow status pill, dispute submission confirmation.

- [ ] **Layer 5: Pixel-perfect snapshots for 5 critical contracts** — `pointfreeco/swift-snapshot-testing 1.17.0+` via `UIHostingController + UIGraphicsImageRenderer` (offscreen, no Simulator). Scope: green released checkmark, red disputed badge, payment success animation frame, Stripe connect onboarding completion, KYC verified badge.

- [ ] **Build `ios-e2e-tester` skill** — Skill documenting the full 5-layer test generation workflow, TRPCClientProtocol extraction pattern, ViewModel `Inspectable` conformance recipes, FSM template for gig-app state machines, and critical visual contract checklist.

---

## 📋 Deferred (Post-Beta / B3)

Do NOT work on these until beta is proven and revenue is flowing.

- [ ] Checkr full integration (pending authorization — see Legal Track above)
- [ ] Android app research
- [ ] Squads full feature (beyond stub removal above)
- [ ] Insurance claims full UI
- [ ] AWS Rekognition biometric step-up auth (Amplify FaceLivenessDetector → `GetFaceLivenessSessionResults` → `CompareFaces`)
- [ ] FCM token registration hardening
- [ ] Real R2 photo upload in messaging (currently using placeholder)

---

## ✅ Done — Reference

- [x] Private beta gate: 100/100 (all P0 blockers resolved)
- [x] Ecosystem health: 100/100
- [x] 5,448 passing tests, 89%+ coverage
- [x] Role-based tRPC procedures (`hustlerProcedure`, `posterProcedure`) — commit `acef5c42`
- [x] Domain reorganization (49 routers into 5 domain sections)
- [x] Payload drift: 11 (irreducible type-repr floor — not actionable)
- [x] README reset across all 3 repos — full product vision, business logic, roadmap
- [x] Full legal document suite (6 documents, audited + patched + re-verified bulletproof)
- [x] Audit: KYC gate fixed, 1099 form gen wired, DB pool configurable
- [x] Tranche 1 + 2 payload reconciliation (57 → 11 drift)
- [x] P0 revenue: escrow-action-worker.ts platform fee fix (Separate Charges and Transfers, 15% deducted from transfer) — commit `850f9207`
- [x] P0 revenue: EscrowService.ts:337 escrow.amount fix (was task.price, missing surge premium) — commit `850f9207`
- [x] P1 revenue: SelfInsurancePool wired at 2% per release — commit `850f9207`
- [x] P1 revenue: invoice.paid + charge.dispute.* Stripe webhook handlers — commit `850f9207`
- [x] P0 safety: backend dispute router created (dispute.create/getById/getByTask/getMine) — commit `c6e9ce57`
- [x] P0 safety: DisputeScreen.swift wired to real dispute.create tRPC — commit `9f94e39`
- [x] ConversationScreen build errors fixed (senderName→senderId, content optional) — commit `9f94e39`
- [x] NotificationService.swift convenience init added for 6-field settings screen — commit `9f94e39`
