# HustleXP Execution TODO — Production Readiness

**Status:** IN PROGRESS  
**Last Updated:** January 2025  
**Current Phase:** Phase 1 (Core Backend Services)  
**Completion:** Phase 0 complete (1/8 phases)

**Authority:** This TODO is derived from:
- `PRODUCT_SPEC.md` v1.5.0
- `ARCHITECTURE.md` v1.2.0
- `schema.sql` v1.2.0
- All LOCKED architecture specs in `architecture/`
- `REALITY_AUDIT.md` (gap findings)

**Usage:** If it's not in this TODO, we don't work on it. Every task must reference a spec.

---

## Phase 0: Schema & Infrastructure ✅ COMPLETE

**Completion Criteria:** Database schema v1.2.0 includes all eligibility system tables, constraints, and triggers.  
**Status:** ✅ COMPLETE (Phase 1 of integration roadmap executed)

### Phase 0.1: Database Schema (COMPLETE)

- [x] **Eligibility System Tables Added to schema.sql**
  - **File:** `HUSTLEXP-DOCS/schema.sql`
  - **Spec:** `schema.sql` v1.2.0, Section 12 (ELIGIBILITY SYSTEM TABLES)
  - **Goal:** All 6 eligibility tables exist in schema.sql with constraints
  - **Done Criteria:**
    - [x] `capability_profiles` table created
    - [x] `capability_claims` table created
    - [x] `license_verifications` table created
    - [x] `insurance_verifications` table created
    - [x] `background_checks` table created
    - [x] `verified_trades` table created
  - **Verification:** `grep -c "capability_profiles\|license_verifications" schema.sql` returns > 0

---

- [x] **Tasks Table Extended with Requirements Fields**
  - **File:** `HUSTLEXP-DOCS/schema.sql`
  - **Spec:** `schema.sql` v1.2.0, Section 12 (ALTER TABLE tasks)
  - **Goal:** All 9 requirement fields added to tasks table
  - **Done Criteria:**
    - [x] `task_category` field added
    - [x] `risk_level` field added
    - [x] `required_trade` field added
    - [x] `required_trust_tier` field added
    - [x] `insurance_required` field added
    - [x] `background_check_required` field added
    - [x] `location_state` field added
    - [x] `classification_confidence` field added
    - [x] `classification_rules_applied` field added
  - **Verification:** `grep "task_category\|risk_level\|required_trade" schema.sql` returns matches

---

- [x] **Invariant Constraints Enforced at Database Level**
  - **File:** `HUSTLEXP-DOCS/schema.sql`
  - **Spec:** `schema.sql` v1.2.0, Section 12 (Constraints)
  - **Goal:** All 8 eligibility invariants enforced via CHECK, FK, or triggers
  - **Done Criteria:**
    - [x] INV-ELIGIBILITY-1: Trust tier → risk clearance CHECK constraint
    - [x] INV-ELIGIBILITY-2: Verified trades FK to license_verifications
    - [x] INV-ELIGIBILITY-3: Expiry detection via triggers/cron (partial enforcement)
    - [x] INV-ELIGIBILITY-4: Insurance FK to verified_trades
    - [x] INV-ELIGIBILITY-5: Background check FK constraints
    - [x] INV-ELIGIBILITY-6: Location state CHECK constraint (length = 2)
    - [x] INV-ELIGIBILITY-7: Willingness flags cannot override (enforced in recompute logic, not DB)
    - [x] INV-ELIGIBILITY-8: Capability profile recompute-only (enforced in application logic, not DB)
  - **Verification:** All CHECK constraints and FKs exist in schema.sql

---

- [x] **Migration File Created**
  - **File:** `HUSTLEXP-DOCS/migrations/20250117_eligibility_system_tables.sql`
  - **Spec:** `schema.sql` v1.2.0, Phase 1 of integration roadmap
  - **Goal:** SQL migration file with all CREATE TABLE and ALTER TABLE statements
  - **Done Criteria:**
    - [x] Migration file exists
    - [x] All 6 tables created in migration
    - [x] All 9 task fields added in migration
    - [x] All constraints included in migration
  - **Verification:** Migration file exists and contains all table definitions

---

### Phase 0.2: Documentation Integration (COMPLETE)

- [x] **PRODUCT_SPEC.md Updated to v1.5.0**
  - **File:** `HUSTLEXP-DOCS/PRODUCT_SPEC.md`
  - **Spec:** Phase 2 of integration roadmap (COMPLETE)
  - **Goal:** §17 added, 8 invariants added to §2, sections updated
  - **Done Criteria:**
    - [x] §17 Capability-Driven Eligibility System added
    - [x] 8 eligibility invariants added to §2
    - [x] §3 updated with Task Requirements
    - [x] §8 updated with Onboarding clarification and Trust Tiers + Risk Clearance
    - [x] Sections renumbered 17→18, 18→19, 19→20
    - [x] Version bumped to v1.5.0
  - **Verification:** `grep "^## §17" PRODUCT_SPEC.md` returns match

---

- [x] **ARCHITECTURE.md Updated to v1.2.0**
  - **File:** `HUSTLEXP-DOCS/ARCHITECTURE.md`
  - **Spec:** Phase 3 of integration roadmap (COMPLETE)
  - **Goal:** §11, §12, §13 added with authority boundaries
  - **Done Criteria:**
    - [x] §11 Capability Profile Authority added
    - [x] §12 Verification Pipeline Authority added
    - [x] §13 Feed Eligibility Authority added
    - [x] Version bumped to v1.2.0
  - **Verification:** `grep "^## §1[123]" ARCHITECTURE.md` returns 3 matches

---

## Phase 1: Core Backend Services

**Completion Criteria:** All core eligibility services implemented, tested, and wired.  
**Depends On:** Phase 0 (COMPLETE)  
**Status:** ⏳ IN PROGRESS

### Phase 1.1: Capability Profile Service (CRITICAL)

- [ ] **Create CapabilityProfileService.ts**
  - **File:** `hustlexp-ai-backend/backend/src/services/CapabilityProfileService.ts`
  - **Spec:** ARCHITECTURE.md §11.3 "Recompute-Only Rule", `architecture/CAPABILITY_PROFILE_SCHEMA_AND_INVARIANTS_LOCKED.md` §Recomputation Triggers
  - **Goal:** Service with `recompute(userId)` method that derives capability profile from source records
  - **Done Criteria:**
    - [ ] Service class created with `recompute(userId)` method
    - [ ] Loads all source records (license_verifications, insurance_verifications, background_checks, users.trust_tier)
    - [ ] Re-evaluates verified_trades from license_verifications
    - [ ] Re-evaluates risk_clearance from trust_tier (A→low, B/C→low+medium, D→low+medium+high)
    - [ ] Re-evaluates insurance_valid from insurance_verifications
    - [ ] Re-evaluates background_check_valid from background_checks
    - [ ] Updates capability_profiles table (atomic transaction)
    - [ ] Invalidates feed cache on recompute
    - [ ] No direct UPDATE on capability_profiles (except updated_at)
  - **Verification:** Service file exists, recompute() method implemented, tests passing
  - **Prerequisites:** Phase 0 complete

---

- [ ] **Add Recomputation Triggers to Verification Services**
  - **File:** `hustlexp-ai-backend/backend/src/services/LicenseVerificationService.ts` (when created)
  - **Spec:** ARCHITECTURE.md §12.3 "What Triggers Recomputation", VERIFICATION_PIPELINE_LOCKED.md §1.2
  - **Goal:** All verification services trigger recompute atomically on state change
  - **Done Criteria:**
    - [ ] LicenseVerificationService triggers recompute on status change
    - [ ] InsuranceVerificationService triggers recompute on status change
    - [ ] BackgroundCheckService triggers recompute on status change
    - [ ] Recompute happens in same transaction as verification update
  - **Verification:** All verification services import and call CapabilityProfileService.recompute()
  - **Prerequisites:** CapabilityProfileService.ts created

---

### Phase 1.2: Verification Pipeline Services (CRITICAL)

- [ ] **Create LicenseVerificationService.ts**
  - **File:** `hustlexp-ai-backend/backend/src/services/LicenseVerificationService.ts`
  - **Spec:** `architecture/VERIFICATION_PIPELINE_LOCKED.md` §1 "License Verification Pipeline"
  - **Goal:** Service for license verification lifecycle (submit → verify → approve/reject)
  - **Done Criteria:**
    - [ ] `submit(userId, licenseDetails)` method creates PENDING verification record
    - [ ] `process(verificationId)` method runs verification (automated or manual)
    - [ ] `approve(verificationId)` method updates status to VERIFIED
    - [ ] `reject(verificationId, reason)` method updates status to FAILED
    - [ ] `expire(verificationId)` method updates status to EXPIRED
    - [ ] All status changes trigger CapabilityProfileService.recompute() (atomic)
    - [ ] Eligibility pre-check before payment gating
  - **Verification:** Service file exists, all methods implemented, tests passing
  - **Prerequisites:** CapabilityProfileService.ts created

---

- [ ] **Create InsuranceVerificationService.ts**
  - **File:** `hustlexp-ai-backend/backend/src/services/InsuranceVerificationService.ts`
  - **Spec:** `architecture/VERIFICATION_PIPELINE_LOCKED.md` §2 "Insurance Verification Pipeline"
  - **Goal:** Service for insurance verification lifecycle (upload → verify → approve/reject)
  - **Done Criteria:**
    - [ ] `submit(userId, insuranceDetails)` method creates PENDING verification record
    - [ ] `process(verificationId)` method validates COI (OCR or manual review)
    - [ ] `approve(verificationId)` method updates status to VERIFIED
    - [ ] `reject(verificationId, reason)` method updates status to FAILED
    - [ ] `expire(verificationId)` method updates status to EXPIRED
    - [ ] All status changes trigger CapabilityProfileService.recompute() (atomic)
    - [ ] Enforces verified trade prerequisite (INV-ELIGIBILITY-4)
  - **Verification:** Service file exists, all methods implemented, tests passing
  - **Prerequisites:** CapabilityProfileService.ts created, LicenseVerificationService.ts created

---

- [ ] **Create BackgroundCheckService.ts**
  - **File:** `hustlexp-ai-backend/backend/src/services/BackgroundCheckService.ts`
  - **Spec:** `architecture/VERIFICATION_PIPELINE_LOCKED.md` §3 "Background Check Pipeline"
  - **Goal:** Service for background check lifecycle (initiate → verify → approve/reject)
  - **Done Criteria:**
    - [ ] `initiate(userId)` method creates PENDING verification record
    - [ ] `process(verificationId)` method calls third-party provider
    - [ ] `approve(verificationId)` method updates status to VERIFIED
    - [ ] `reject(verificationId, reason)` method updates status to FAILED
    - [ ] `expire(verificationId)` method updates status to EXPIRED
    - [ ] All status changes trigger CapabilityProfileService.recompute() (atomic)
    - [ ] Only available for critical-risk tasks
  - **Verification:** Service file exists, all methods implemented, tests passing
  - **Prerequisites:** CapabilityProfileService.ts created

---

### Phase 1.3: Feed Query & Eligibility Resolver Service (CRITICAL)

- [ ] **Create FeedQueryService.ts**
  - **File:** `hustlexp-ai-backend/backend/src/services/FeedQueryService.ts`
  - **Spec:** `architecture/FEED_QUERY_AND_ELIGIBILITY_RESOLVER_LOCKED.md` §4 "Feed Query Strategy", ARCHITECTURE.md §13.2 "Feed Is a Join, Not a Filter"
  - **Goal:** Service that queries tasks using SQL JOIN with capability_profiles (not post-filtering)
  - **Done Criteria:**
    - [ ] `getFeed(userId, feedMode, paginationCursor, limit)` method
    - [ ] SQL query joins `tasks` with `capability_profiles`
    - [ ] Join conditions enforce eligibility (location_state, trade, trust_tier, insurance, background_check)
    - [ ] No post-filtering in application code
    - [ ] Returns empty feed if capability_profile missing
    - [ ] Cursor-based pagination (opaque cursor)
    - [ ] Feed modes: normal, urgent, nearby
  - **Verification:** Service file exists, SQL query joins tables correctly, tests passing
  - **Prerequisites:** Phase 0 complete (capability_profiles table exists)

---

- [ ] **Create isEligible() Pure Function**
  - **File:** `hustlexp-ai-backend/backend/src/services/EligibilityResolver.ts` (or within FeedQueryService.ts)
  - **Spec:** `architecture/FEED_QUERY_AND_ELIGIBILITY_RESOLVER_LOCKED.md` §2 "Canonical Eligibility Predicate", ARCHITECTURE.md §13.3 "Eligibility Predicate Location"
  - **Goal:** Pure function `isEligible(task, capabilityProfile): boolean` for defense-in-depth
  - **Done Criteria:**
    - [ ] Pure function (deterministic, side-effect free)
    - [ ] Checks location_state match
    - [ ] Checks required_trade in verified_trades
    - [ ] Checks trust_tier >= required_trust_tier
    - [ ] Checks insurance_required → insurance_valid
    - [ ] Checks background_check_required → background_check_valid
    - [ ] Used by: FeedQueryService (defense-in-depth), Apply endpoint (recheck)
  - **Verification:** Function file exists, all eligibility rules implemented, tests passing
  - **Prerequisites:** FeedQueryService.ts created

---

### Phase 1.4: Risk Classification Service (HIGH)

- [ ] **Enhance TaskRiskClassifier.ts to Full Service**
  - **File:** `hustlexp-ai-backend/backend/src/services/TaskRiskClassifier.ts`
  - **Spec:** `architecture/POSTER_TASK_CREATION_RISK_CLASSIFIER_LOCKED.md` §2 "Risk Classification Engine"
  - **Goal:** Full service that classifies task risk and sets requirements
  - **Done Criteria:**
    - [ ] `classifyTask(taskCategory, riskInputs, locationState)` method
    - [ ] Implements risk level mapping table (low→none, medium→sometimes, high→yes, critical→yes)
    - [ ] Sets required_trade, required_trust_tier, insurance_required, background_check_required
    - [ ] Requirements are immutable after task creation
    - [ ] Enforces risk level cannot be downgraded
  - **Verification:** Service implements full risk classification logic, tests passing
  - **Prerequisites:** None (can be done in parallel with Phase 1.1-1.3)

---

- [ ] **Update TaskService to Use Risk Classifier**
  - **File:** `hustlexp-ai-backend/backend/src/services/TaskService.ts`
  - **Spec:** `architecture/POSTER_TASK_CREATION_RISK_CLASSIFIER_LOCKED.md` §1 "Task Creation Flow", PRODUCT_SPEC.md §3.4.1 "Task Requirements"
  - **Goal:** Task creation calls risk classifier and sets requirements fields
  - **Done Criteria:**
    - [ ] `createTask()` calls RiskClassificationService.classifyTask()
    - [ ] Task requirements (trade, trust_tier, insurance, background_check) set from classification
    - [ ] Requirements are immutable after creation (enforced at DB level)
  - **Verification:** TaskService.createTask() sets all requirement fields, tests passing
  - **Prerequisites:** TaskRiskClassifier.ts enhanced

---

## Phase 2: Supporting Services

**Completion Criteria:** TrustService, TaskService, and OnboardingService updated to support eligibility system.  
**Depends On:** Phase 1 complete (all core services implemented)  
**Status:** ⏳ PENDING

### Phase 2.1: Trust Service Enhancement (HIGH)

- [ ] **Update TrustService.ts with Risk Clearance Mapping**
  - **File:** `hustlexp-ai-backend/backend/src/services/TrustService.ts`
  - **Spec:** PRODUCT_SPEC.md §2 (INV-ELIGIBILITY-1), ARCHITECTURE.md §11.2 "Source Records vs Derived Records"
  - **Goal:** TrustService triggers recompute when trust tier changes, ensuring risk_clearance updated
  - **Done Criteria:**
    - [ ] `promoteTier(userId)` method triggers CapabilityProfileService.recompute()
    - [ ] `demoteTier(userId)` method triggers CapabilityProfileService.recompute()
    - [ ] Risk clearance mapping enforced (A→low, B/C→low+medium, D→low+medium+high)
    - [ ] Recompute happens in same transaction as trust tier change
  - **Verification:** TrustService.promoteTier() calls CapabilityProfileService.recompute(), tests passing
  - **Prerequisites:** CapabilityProfileService.ts created

---

### Phase 2.2: Onboarding Service Enhancement (HIGH)

- [ ] **Update OnboardingService to Capability-Driven Onboarding**
  - **File:** `hustlexp-ai-backend/backend/src/services/OnboardingService.ts` (or `OnboardingAIService.ts`)
  - **Spec:** `architecture/CAPABILITY_DRIVEN_ONBOARDING_LOCKED.md` "7-Phase Onboarding Flow", PRODUCT_SPEC.md §8.1 "Onboarding and Capability Claims"
  - **Goal:** Onboarding collects capability claims (not permissions) and stores in capability_claims table
  - **Done Criteria:**
    - [ ] Onboarding questions collect: role, claimed_trades, location (state), willingness_flags
    - [ ] Onboarding completion creates `capability_claims` record (immutable historical record)
    - [ ] Capability claims unlock verification paths (not task access)
    - [ ] Initial capability_profile created with verified_trades = [], trust_tier = A
    - [ ] Verification is separate step after onboarding (not during onboarding)
  - **Verification:** Onboarding creates capability_claims record, initial profile created, tests passing
  - **Prerequisites:** Phase 0 complete (capability_claims table exists)

---

## Phase 3: API Layer

**Completion Criteria:** All API endpoints for eligibility system implemented and wired.  
**Depends On:** Phase 1 complete (all core services implemented)  
**Status:** ⏳ PENDING

### Phase 3.1: Feed Endpoints (CRITICAL)

- [ ] **Create Feed Router with Eligibility Filtering**
  - **File:** `hustlexp-ai-backend/backend/src/routers/feed.ts` (new file)
  - **Spec:** `architecture/FEED_QUERY_AND_ELIGIBILITY_RESOLVER_LOCKED.md` §1 "Inputs to Feed Resolver", ARCHITECTURE.md §13.2 "Feed Is a Join, Not a Filter"
  - **Goal:** tRPC router with feed endpoints that use FeedQueryService (SQL join, not post-filtering)
  - **Done Criteria:**
    - [ ] `feed.get` query endpoint (normal feed)
    - [ ] `feed.getUrgent` query endpoint (urgent feed)
    - [ ] `feed.getNearby` query endpoint (nearby feed with geospatial)
    - [ ] All endpoints use FeedQueryService.getFeed()
    - [ ] All endpoints return pre-filtered tasks (all eligible)
    - [ ] Cursor-based pagination (opaque cursor)
  - **Verification:** Router file exists, endpoints implemented, tests passing
  - **Prerequisites:** FeedQueryService.ts created

---

- [ ] **Update Apply Endpoint with Eligibility Recheck**
  - **File:** `hustlexp-ai-backend/backend/src/routers/task.ts` (update existing)
  - **Spec:** ARCHITECTURE.md §13.4 "Defense-in-Depth (Apply Endpoint Recheck)", PRODUCT_SPEC.md §17.4 "Feed Shows Only Eligible Gigs"
  - **Goal:** Apply endpoint rechecks eligibility before accepting task (defense-in-depth)
  - **Done Criteria:**
    - [ ] `task.accept` mutation calls isEligible(task, profile)
    - [ ] If not eligible, returns 403 Forbidden (not "try anyway")
    - [ ] Recheck uses latest capability_profile (not cached)
    - [ ] Protects against: stale cache, race conditions, malicious clients
  - **Verification:** Apply endpoint rechecks eligibility, returns 403 if ineligible, tests passing
  - **Prerequisites:** isEligible() function created, FeedQueryService.ts created

---

### Phase 3.2: Verification Endpoints (CRITICAL)

- [ ] **Create Verification Router**
  - **File:** `hustlexp-ai-backend/backend/src/routers/verification.ts` (new file)
  - **Spec:** `architecture/VERIFICATION_PIPELINE_LOCKED.md` §1.2 "License Verification Flow", ARCHITECTURE.md §12.4 "Verification Flow Authority"
  - **Goal:** tRPC router with verification endpoints (create, status, renew)
  - **Done Criteria:**
    - [ ] `verification.license.submit` mutation (creates PENDING record)
    - [ ] `verification.license.getStatus` query (returns status, expiry)
    - [ ] `verification.license.renew` mutation (creates new PENDING record)
    - [ ] `verification.insurance.submit` mutation
    - [ ] `verification.insurance.getStatus` query
    - [ ] `verification.insurance.renew` mutation
    - [ ] `verification.backgroundCheck.initiate` mutation
    - [ ] `verification.backgroundCheck.getStatus` query
    - [ ] All endpoints use respective verification services
  - **Verification:** Router file exists, all endpoints implemented, tests passing
  - **Prerequisites:** LicenseVerificationService.ts, InsuranceVerificationService.ts, BackgroundCheckService.ts created

---

### Phase 3.3: Settings Endpoints (HIGH)

- [ ] **Create Settings/Eligibility Router**
  - **File:** `hustlexp-ai-backend/backend/src/routers/settings.ts` or `eligibility.ts` (new file)
  - **Spec:** `architecture/SETTINGS_VERIFICATION_AND_ELIGIBILITY_LOCKED.md` "Settings → Work Eligibility", PRODUCT_SPEC.md §17.8 "Settings as Eligibility Control Room"
  - **Goal:** tRPC router with settings endpoints for eligibility display
  - **Done Criteria:**
    - [ ] `settings.eligibility.getSummary` query (returns trust tier, risk clearance, location)
    - [ ] `settings.eligibility.getVerifiedTrades` query (returns verified trades with status, expiry)
    - [ ] `settings.eligibility.getInsuranceStatus` query (returns insurance status, expiry)
    - [ ] `settings.eligibility.getBackgroundCheckStatus` query (returns background check status, expiry)
    - [ ] `settings.eligibility.getUpgradeOpportunities` query (computed, not estimated)
    - [ ] All endpoints read from capability_profile (no mutations)
  - **Verification:** Router file exists, all endpoints implemented, tests passing
  - **Prerequisites:** CapabilityProfileService.ts created

---

## Phase 4: Frontend Integration

**Completion Criteria:** All frontend screens for eligibility system implemented and wired.  
**Depends On:** Phase 3 complete (all API endpoints implemented)  
**Status:** ⏳ PENDING

### Phase 4.1: Settings → Work Eligibility Screen (HIGH)

- [ ] **Create WorkEligibilityScreen.tsx**
  - **File:** `hustlexp-app/screens/settings/WorkEligibilityScreen.tsx` (new file)
  - **Spec:** `architecture/SETTINGS_VERIFICATION_AND_ELIGIBILITY_LOCKED.md` "Settings → Work Eligibility UI", PRODUCT_SPEC.md §17.8 "Settings as Eligibility Control Room"
  - **Goal:** Screen that displays eligibility summary, verified trades, insurance, background checks, upgrade opportunities
  - **Done Criteria:**
    - [ ] Eligibility Summary section (trust tier, risk clearance, location)
    - [ ] Verified Trades section (status, expiry, verify/renew actions)
    - [ ] Insurance section (status, expiry, add/renew actions)
    - [ ] Background Check section (status, expiry, initiate/renew actions)
    - [ ] Upgrade Opportunities section (computed, not estimated)
    - [ ] All data fetched from settings.eligibility.* endpoints
    - [ ] No mutations in UI (read-only except verification initiation)
  - **Verification:** Screen file exists, all sections implemented, wired to API endpoints, tests passing
  - **Prerequisites:** Phase 3.3 complete (settings/eligibility endpoints)

---

- [ ] **Wire Settings → Work Eligibility Navigation**
  - **File:** `hustlexp-app/navigation/` (update navigation config)
  - **Spec:** `architecture/SETTINGS_VERIFICATION_AND_ELIGIBILITY_LOCKED.md` "Navigation Rules"
  - **Goal:** Settings screen has link to Work Eligibility screen
  - **Done Criteria:**
    - [ ] Settings screen has "Work Eligibility" button/link
    - [ ] Clicking navigates to WorkEligibilityScreen
    - [ ] Deep-links work for verification initiation
  - **Verification:** Navigation wired, deep-links work, tests passing
  - **Prerequisites:** WorkEligibilityScreen.tsx created

---

### Phase 4.2: Capability-Driven Onboarding Updates (HIGH)

- [ ] **Update Onboarding Screens to Capability-Driven Flow**
  - **File:** `hustlexp-app/screens/onboarding/*.tsx` (update existing or create new)
  - **Spec:** `architecture/CAPABILITY_DRIVEN_ONBOARDING_LOCKED.md` "7-Phase Onboarding Flow", PRODUCT_SPEC.md §8.1 "Onboarding and Capability Claims"
  - **Goal:** Onboarding screens collect capability claims (not permissions)
  - **Done Criteria:**
    - [ ] Phase 0: Role declaration (hustler/poster/both)
    - [ ] Phase 1: Location & jurisdiction (state, city/ZIP)
    - [ ] Phase 2: Capability declaration (trades selection)
    - [ ] Phase 3: Credential claim (license yes/no/unsure)
    - [ ] Phase 4: License metadata capture (if yes)
    - [ ] Phase 5: Insurance claim (conditional)
    - [ ] Phase 6: Risk willingness (in-home, urgent, high-value)
    - [ ] Phase 7: Summary & next steps (verification paths, not task access)
    - [ ] All answers create capability_claims record (not capability_profile)
  - **Verification:** Onboarding screens updated, capability_claims created on completion, tests passing
  - **Prerequisites:** Phase 0 complete (capability_claims table exists), OnboardingService updated

---

### Phase 4.3: Feed Screens Updates (MEDIUM)

- [ ] **Update Feed Screens to Use Eligibility-Filtered Endpoints**
  - **File:** `hustlexp-app/screens/hustler/FeedScreen.tsx` or similar (update existing)
  - **Spec:** ARCHITECTURE.md §13.5 "Authority Chain", PRODUCT_SPEC.md §17.4 "Feed Shows Only Eligible Gigs"
  - **Goal:** Feed screens use feed.get/feed.getUrgent/feed.getNearby endpoints (pre-filtered)
  - **Done Criteria:**
    - [ ] Feed screen uses feed.get endpoint (not task.listOpen)
    - [ ] All tasks displayed are eligible (server-filtered)
    - [ ] No client-side eligibility computation
    - [ ] No "disabled" task cards
    - [ ] No "you don't qualify" messages
  - **Verification:** Feed screens use eligibility-filtered endpoints, no client-side filtering, tests passing
  - **Prerequisites:** Phase 3.1 complete (feed endpoints)

---

## Phase 5: Testing & Hardening

**Completion Criteria:** All invariant tests, integration tests, and E2E tests passing.  
**Depends On:** Phase 1-4 complete (all services and endpoints implemented)  
**Status:** ⏳ PENDING

### Phase 5.1: Invariant Tests (CRITICAL)

- [ ] **Create Eligibility Invariant Tests**
  - **File:** `hustlexp-ai-backend/tests/invariants/eligibility-invariants.test.ts` (new file)
  - **Spec:** PRODUCT_SPEC.md §2 (INV-ELIGIBILITY-1 through INV-ELIGIBILITY-8), `architecture/CAPABILITY_PROFILE_SCHEMA_AND_INVARIANTS_LOCKED.md` §Invariants
  - **Goal:** Tests that verify all 8 eligibility invariants are enforced
  - **Done Criteria:**
    - [ ] Test INV-ELIGIBILITY-1: Trust tier → risk clearance mapping (A→low, B/C→low+medium, D→low+medium+high)
    - [ ] Test INV-ELIGIBILITY-2: Verified trades must have active verification (FK constraint)
    - [ ] Test INV-ELIGIBILITY-3: Expired credentials invalidate capabilities (recompute removes expired)
    - [ ] Test INV-ELIGIBILITY-4: Insurance validity gated by verification (FK constraint)
    - [ ] Test INV-ELIGIBILITY-5: Background check validity gated by verification (FK constraint)
    - [ ] Test INV-ELIGIBILITY-6: Location state must be valid US state code (CHECK constraint)
    - [ ] Test INV-ELIGIBILITY-7: Willingness flags cannot override eligibility (recompute ignores flags)
    - [ ] Test INV-ELIGIBILITY-8: Capability profile never mutated directly (recompute-only)
    - [ ] All tests passing
  - **Verification:** Test file exists, all 8 invariants tested, all tests passing
  - **Prerequisites:** Phase 1 complete (all services implemented)

---

### Phase 5.2: Integration Tests (HIGH)

- [ ] **Create Verification → Recompute → Feed Integration Test**
  - **File:** `hustlexp-ai-backend/tests/integration/verification-recompute-feed.test.ts` (new file)
  - **Spec:** ARCHITECTURE.md §12.3 "Recomputation Flow", §13.5 "Authority Chain"
  - **Goal:** E2E test for verification state change → recompute → feed update flow
  - **Done Criteria:**
    - [ ] Test: License verified → recompute triggered → profile updated → feed shows eligible tasks
    - [ ] Test: License expired → recompute triggered → profile updated → feed no longer shows tasks
    - [ ] Test: Trust tier promoted → recompute triggered → risk_clearance updated → feed shows higher-risk tasks
    - [ ] Test: All state changes are atomic (recompute in same transaction)
    - [ ] All tests passing
  - **Verification:** Test file exists, integration flow tested, all tests passing
  - **Prerequisites:** Phase 1-3 complete (all services and endpoints)

---

### Phase 5.3: E2E Tests (HIGH)

- [ ] **Create Onboarding → Verification → Feed → Apply E2E Test**
  - **File:** `hustlexp-ai-backend/tests/e2e/eligibility-flow.test.ts` (new file)
  - **Spec:** PRODUCT_SPEC.md §17 (full eligibility flow), `architecture/CAPABILITY_DRIVEN_ONBOARDING_LOCKED.md`
  - **Goal:** Full user flow test from onboarding to task acceptance
  - **Done Criteria:**
    - [ ] Test: User completes onboarding → capability_claims created → initial profile created
    - [ ] Test: User submits license verification → verification approved → recompute triggered → profile updated
    - [ ] Test: User views feed → only eligible tasks shown → no ineligible tasks
    - [ ] Test: User applies to task → eligibility rechecked → task accepted (if eligible) or 403 (if not)
    - [ ] All tests passing
  - **Verification:** Test file exists, full flow tested, all tests passing
  - **Prerequisites:** Phase 1-4 complete (all services, endpoints, and screens)

---

### Phase 5.4: Performance Tests (MEDIUM)

- [ ] **Create Feed Query Performance Test**
  - **File:** `hustlexp-ai-backend/tests/performance/feed-query.test.ts` (new file)
  - **Spec:** `architecture/FEED_QUERY_AND_ELIGIBILITY_RESOLVER_LOCKED.md` §7 "Cache Strategy"
  - **Goal:** Verify feed query performance (SQL join, not post-filtering)
  - **Done Criteria:**
    - [ ] Test: Feed query completes in < 100ms (p95)
    - [ ] Test: Feed query uses SQL JOIN (not post-filtering in JS)
    - [ ] Test: Feed cache TTL enforced (60s normal, 15s urgent)
    - [ ] Test: Cache invalidation on recompute works correctly
    - [ ] All tests passing
  - **Verification:** Test file exists, performance benchmarks met, tests passing
  - **Prerequisites:** Phase 3.1 complete (feed endpoints)

---

- [ ] **Create Recompute Performance Test**
  - **File:** `hustlexp-ai-backend/tests/performance/recompute.test.ts` (new file)
  - **Spec:** `architecture/CAPABILITY_PROFILE_SCHEMA_AND_INVARIANTS_LOCKED.md` §Recomputation Triggers
  - **Goal:** Verify recompute completes quickly (atomic transaction)
  - **Done Criteria:**
    - [ ] Test: Recompute completes in < 50ms (p95)
    - [ ] Test: Recompute is atomic (all or nothing)
    - [ ] Test: Recompute handles concurrent requests (no race conditions)
    - [ ] All tests passing
  - **Verification:** Test file exists, performance benchmarks met, tests passing
  - **Prerequisites:** Phase 1.1 complete (CapabilityProfileService)

---

## Phase 6: Admin & Ops

**Completion Criteria:** Admin tools for verification review, eligibility debugging, and monitoring.  
**Depends On:** Phase 1-5 complete (all services, endpoints, tests)  
**Status:** ⏳ PENDING

### Phase 6.1: Admin Verification Tools (MEDIUM)

- [ ] **Create Admin Verification Review Tool**
  - **File:** `hustlexp-ai-backend/backend/src/admin/verification-review.ts` (new file, or update existing admin tools)
  - **Spec:** `architecture/VERIFICATION_PIPELINE_LOCKED.md` §1.2 "Verification Flow", ARCHITECTURE.md §12.4 "Authority Boundaries"
  - **Goal:** Admin tool for reviewing pending verifications
  - **Done Criteria:**
    - [ ] List pending verifications (license, insurance, background check)
    - [ ] View verification details (document, metadata, confidence score)
    - [ ] Approve/reject verification (triggers recompute)
    - [ ] Audit log entry created on admin action
  - **Verification:** Admin tool exists, can approve/reject verifications, audit log created, tests passing
  - **Prerequisites:** Phase 1.2 complete (verification services)

---

### Phase 6.2: Eligibility Debugging Tools (MEDIUM)

- [ ] **Create Eligibility Debug Tool**
  - **File:** `hustlexp-ai-backend/backend/src/admin/eligibility-debug.ts` (new file)
  - **Spec:** ARCHITECTURE.md §13.5 "Authority Chain", PRODUCT_SPEC.md §17 "Capability-Driven Eligibility System"
  - **Goal:** Admin tool for debugging eligibility issues (why user can't see tasks)
  - **Done Criteria:**
    - [ ] View capability_profile for user
    - [ ] View source records (license_verifications, insurance_verifications, background_checks, trust_tier)
    - [ ] Trace eligibility for specific task (isEligible(task, profile) breakdown)
    - [ ] View feed query result (which tasks would appear)
    - [ ] Trigger manual recompute (with audit log)
  - **Verification:** Admin tool exists, can debug eligibility, tests passing
  - **Prerequisites:** Phase 1-3 complete (all services and endpoints)

---

### Phase 6.3: Monitoring & Alerting (MEDIUM)

- [ ] **Add Recompute Metrics**
  - **File:** `hustlexp-ai-backend/backend/src/services/CapabilityProfileService.ts` (update existing)
  - **Spec:** `architecture/CAPABILITY_PROFILE_SCHEMA_AND_INVARIANTS_LOCKED.md` §Recomputation Triggers
  - **Goal:** Metrics for recompute performance and frequency
  - **Done Criteria:**
    - [ ] Metric: recompute_count (total recomputes)
    - [ ] Metric: recompute_duration_ms (p50, p95, p99)
    - [ ] Metric: recompute_failures (count of failures)
    - [ ] Metric: recompute_triggers (by trigger type: verification, trust_tier, expiry)
    - [ ] Metrics exported to monitoring system
  - **Verification:** Metrics added, exported to monitoring, dashboards created
  - **Prerequisites:** Phase 1.1 complete (CapabilityProfileService)

---

- [ ] **Add Feed Query Metrics**
  - **File:** `hustlexp-ai-backend/backend/src/services/FeedQueryService.ts` (update existing)
  - **Spec:** `architecture/FEED_QUERY_AND_ELIGIBILITY_RESOLVER_LOCKED.md` §7 "Cache Strategy"
  - **Goal:** Metrics for feed query performance and cache hit rate
  - **Done Criteria:**
    - [ ] Metric: feed_query_count (total queries)
    - [ ] Metric: feed_query_duration_ms (p50, p95, p99)
    - [ ] Metric: feed_cache_hit_rate (cache hits / total queries)
    - [ ] Metric: feed_query_result_count (tasks returned per query)
    - [ ] Metrics exported to monitoring system
  - **Verification:** Metrics added, exported to monitoring, dashboards created
  - **Prerequisites:** Phase 1.3 complete (FeedQueryService)

---

## Phase 7: Deployment & Launch

**Completion Criteria:** Migration scripts, feature flags, rollout plan, and post-launch monitoring in place.  
**Depends On:** Phase 1-6 complete (all services, endpoints, tests, admin tools)  
**Status:** ⏳ PENDING

### Phase 7.1: Migration Scripts (CRITICAL)

- [ ] **Verify Migration Script Exists in Backend Repo**
  - **File:** `hustlexp-ai-backend/migrations/20250117_eligibility_system_tables.sql` (verify or copy from HUSTLEXP-DOCS)
  - **Spec:** `HUSTLEXP-DOCS/migrations/20250117_eligibility_system_tables.sql`, `schema.sql` v1.2.0
  - **Goal:** Migration script exists in backend repo and can be applied to production database
  - **Done Criteria:**
    - [ ] Migration file exists in backend repo (or copied from HUSTLEXP-DOCS)
    - [ ] Migration can be applied to production database
    - [ ] Migration is idempotent (safe to run multiple times)
    - [ ] Rollback script exists (or documented that rollback is not supported)
  - **Verification:** Migration file exists, can be applied, tests passing
  - **Prerequisites:** Phase 0 complete (migration created in HUSTLEXP-DOCS)

---

- [ ] **Test Migration on Staging Database**
  - **File:** `hustlexp-ai-backend/migrations/20250117_eligibility_system_tables.sql` (test execution)
  - **Spec:** Migration script
  - **Goal:** Verify migration works correctly on staging database before production
  - **Done Criteria:**
    - [ ] Migration applied to staging database
    - [ ] All 6 tables created successfully
    - [ ] All 9 task fields added successfully
    - [ ] All constraints created successfully
    - [ ] All indexes created successfully
    - [ ] Verification queries pass (check schema matches spec)
  - **Verification:** Migration tested on staging, all checks pass
  - **Prerequisites:** Migration script exists in backend repo

---

### Phase 7.2: Feature Flags (MEDIUM)

- [ ] **Add Eligibility System Feature Flag**
  - **File:** `hustlexp-ai-backend/backend/config.ts` or feature flag system (update existing)
  - **Spec:** Standard feature flag pattern
  - **Goal:** Feature flag to enable/disable eligibility system (for gradual rollout)
  - **Done Criteria:**
    - [ ] Feature flag: `ELIGIBILITY_SYSTEM_ENABLED` (boolean)
    - [ ] Feed endpoints check flag before using eligibility filtering
    - [ ] Verification endpoints check flag before allowing verification
    - [ ] Settings endpoints check flag before showing eligibility UI
    - [ ] Default: `false` (disabled until rollout)
  - **Verification:** Feature flag exists, all endpoints check flag, can be toggled
  - **Prerequisites:** Phase 3 complete (all endpoints)

---

### Phase 7.3: Rollout Plan (MEDIUM)

- [ ] **Create Gradual Rollout Plan**
  - **File:** `HUSTLEXP-DOCS/docs/ELIGIBILITY_SYSTEM_ROLLOUT.md` (new file)
  - **Spec:** Standard rollout best practices
  - **Goal:** Gradual rollout plan for eligibility system (10% → 50% → 100%)
  - **Done Criteria:**
    - [ ] Rollout phases defined (10%, 50%, 100% of users)
    - [ ] Rollout criteria defined (success metrics, failure thresholds)
    - [ ] Rollback plan defined (how to disable if issues)
    - [ ] Monitoring plan defined (what to watch during rollout)
  - **Verification:** Rollout plan document exists, reviewed by team
  - **Prerequisites:** Phase 7.1-7.2 complete (migration scripts, feature flags)

---

### Phase 7.4: Post-Launch Monitoring (MEDIUM)

- [ ] **Create Post-Launch Monitoring Dashboard**
  - **File:** Monitoring system dashboard (Grafana, DataDog, etc.)
  - **Spec:** Phase 6.3 metrics (recompute metrics, feed query metrics)
  - **Goal:** Dashboard showing eligibility system health and performance
  - **Done Criteria:**
    - [ ] Dashboard shows: recompute_count, recompute_duration, recompute_failures
    - [ ] Dashboard shows: feed_query_count, feed_query_duration, feed_cache_hit_rate
    - [ ] Dashboard shows: verification_count (by status: pending, verified, failed, expired)
    - [ ] Alerts configured for: recompute_failures > threshold, feed_query_duration > threshold
  - **Verification:** Dashboard exists, metrics displayed, alerts configured
  - **Prerequisites:** Phase 6.3 complete (metrics added)

---

## Summary

**Total Phases:** 8 (0-7)  
**Phase 0 Status:** ✅ COMPLETE (Schema & Infrastructure)  
**Phases 1-7 Status:** ⏳ PENDING

**Critical Blockers (Must Complete Before Launch):**
- Phase 1: Core Backend Services (CapabilityProfileService, Verification Services, FeedQueryService)
- Phase 3.1: Feed Endpoints (eligibility filtering)
- Phase 3.2: Verification Endpoints (initiate verification)
- Phase 5.1: Invariant Tests (verify all 8 invariants)

**High Priority (Block Progress):**
- Phase 2: Supporting Services (TrustService, OnboardingService updates)
- Phase 4.1: Settings → Work Eligibility Screen
- Phase 5.2: Integration Tests

**Medium Priority (Will Cause Issues Later):**
- Phase 4.2: Capability-Driven Onboarding Updates
- Phase 4.3: Feed Screens Updates
- Phase 5.3-5.4: E2E Tests, Performance Tests
- Phase 6-7: Admin Tools, Deployment

---

**END OF EXECUTION_TODO**
