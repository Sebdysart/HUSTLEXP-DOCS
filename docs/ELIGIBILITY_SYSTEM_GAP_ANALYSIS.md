# Eligibility System Gap Analysis
## Status: CRITICAL — Integration Required
## Date: 2025-01-17
## Authority: Gap Analysis — Identifies Missing Integration Points

---

**Verdict:** Eight MAX-tier architecture specs have been created and locked for the capability-driven eligibility system. However, these specs are **not yet integrated** into the canonical documentation hierarchy (PRODUCT_SPEC, ARCHITECTURE, BUILD_GUIDE, schema.sql). This gap analysis identifies all missing integration points and provides a roadmap for complete integration.

---

## Executive Summary

**8 New Architecture Specs Created:**
1. `CAPABILITY_ONBOARDING_AND_FEED_FILTERING_LOCKED.md` (838 lines)
2. `CAPABILITY_DRIVEN_ONBOARDING_LOCKED.md` (1,042 lines)
3. `CAPABILITY_PROFILE_SCHEMA_AND_INVARIANTS_LOCKED.md` (1,037 lines)
4. `POSTER_TASK_CREATION_RISK_CLASSIFIER_LOCKED.md` (1,041 lines)
5. `VERIFICATION_PIPELINE_LOCKED.md` (1,399 lines)
6. `FEED_QUERY_AND_ELIGIBILITY_RESOLVER_LOCKED.md` (919 lines)
7. `SETTINGS_VERIFICATION_AND_ELIGIBILITY_LOCKED.md` (1,282 lines)
8. `VERIFICATION_PAYMENT_UX_AND_COPY_LOCKED.md` (821 lines)

**Total:** 8,379 lines of locked architecture

**Status:** Specs are locked and pushed to `main`, but **not integrated** into canonical documentation.

---

## Gap Categories

### GAP 1: Database Schema Missing (CRITICAL)

**Issue:** The new architecture specs define database tables that do not exist in `schema.sql`.

**Missing Tables:**

1. **`capability_profiles`**
   - Purpose: Single source of truth for user eligibility
   - Authority: `CAPABILITY_PROFILE_SCHEMA_AND_INVARIANTS_LOCKED.md`
   - Fields: `user_id`, `profile_id`, `verified_trades`, `trust_tier`, `risk_clearance`, `insurance_valid`, `background_check_valid`, `location_state`, `willingness_flags`, `verification_status`, `expires_at`

2. **`verified_trades`** (Join Table)
   - Purpose: Links capability profiles to verified trades
   - Authority: `CAPABILITY_PROFILE_SCHEMA_AND_INVARIANTS_LOCKED.md`
   - Fields: `id`, `profile_id`, `trade`, `verified_at`, `expires_at`, `verification_method`, `verification_id`

3. **`license_verifications`**
   - Purpose: Source of truth for license verification records
   - Authority: `VERIFICATION_PIPELINE_LOCKED.md`
   - Fields: `id`, `user_id`, `trade`, `state`, `license_number`, `status`, `verified_at`, `expires_at`, `failure_reason`, `source`, `verification_method`, `confidence_score`

4. **`insurance_verifications`**
   - Purpose: Source of truth for insurance verification records
   - Authority: `VERIFICATION_PIPELINE_LOCKED.md`
   - Fields: `id`, `user_id`, `trade`, `status`, `coverage_amount`, `expires_at`, `verified_at`, `failure_reason`, `source`, `verification_method`

5. **`background_checks`**
   - Purpose: Source of truth for background check records
   - Authority: `VERIFICATION_PIPELINE_LOCKED.md`
   - Fields: `id`, `user_id`, `provider`, `provider_check_id`, `status`, `verified_at`, `expires_at`, `failure_reason`, `results_encrypted`

6. **`capability_claims`** (Optional, for audit trail)
   - Purpose: Immutable record of onboarding answers
   - Authority: `CAPABILITY_DRIVEN_ONBOARDING_LOCKED.md`
   - Fields: `user_id`, `role`, `claimed_trades`, `license_claims`, `insurance_claimed`, `work_state`, `work_region`, `risk_preferences`, `created_at`

**Missing Task Table Fields:**

The `tasks` table in `schema.sql` is missing fields required by the risk classifier:

1. **`task_category`** (VARCHAR(255) NOT NULL)
   - Authority: `POSTER_TASK_CREATION_RISK_CLASSIFIER_LOCKED.md`
   - Purpose: Primary category (e.g., "electrical", "moving", "plumbing")

2. **`risk_level`** (VARCHAR(20) NOT NULL)
   - Authority: `POSTER_TASK_CREATION_RISK_CLASSIFIER_LOCKED.md`
   - Purpose: System-classified risk level ('low', 'medium', 'high', 'critical')
   - Note: `schema.sql` line 1671 has `risk_level` but need to verify it's in tasks table

3. **`required_trade`** (VARCHAR(255))
   - Authority: `POSTER_TASK_CREATION_RISK_CLASSIFIER_LOCKED.md`
   - Purpose: Trade required to accept task (NULL if no trade required)

4. **`required_trust_tier`** (VARCHAR(1) NOT NULL)
   - Authority: `POSTER_TASK_CREATION_RISK_CLASSIFIER_LOCKED.md`
   - Purpose: Minimum trust tier required ('A', 'B', 'C', 'D')

5. **`insurance_required`** (BOOLEAN NOT NULL)
   - Authority: `POSTER_TASK_CREATION_RISK_CLASSIFIER_LOCKED.md`
   - Purpose: Whether insurance is required for this task

6. **`background_check_required`** (BOOLEAN NOT NULL)
   - Authority: `POSTER_TASK_CREATION_RISK_CLASSIFIER_LOCKED.md`
   - Purpose: Whether background check is required for this task

7. **`location_state`** (VARCHAR(2) NOT NULL)
   - Authority: `POSTER_TASK_CREATION_RISK_CLASSIFIER_LOCKED.md`
   - Purpose: ISO 3166-2 state code (for eligibility matching)

8. **`classification_confidence`** (NUMERIC(3, 2))
   - Authority: `POSTER_TASK_CREATION_RISK_CLASSIFIER_LOCKED.md`
   - Purpose: Confidence score for risk classification (0-1)

9. **`classification_rules_applied`** (TEXT[])
   - Authority: `POSTER_TASK_CREATION_RISK_CLASSIFIER_LOCKED.md`
   - Purpose: Audit trail of classification rules applied

**Impact:** Without these tables and fields, the eligibility system cannot be implemented.

**Priority:** CRITICAL — Blocks all eligibility system implementation.

---

### GAP 2: PRODUCT_SPEC Integration Missing (CRITICAL)

**Issue:** `PRODUCT_SPEC.md` does not reference the new capability-driven eligibility system.

**Missing Sections:**

1. **New Section: §17 — Capability-Driven Eligibility System**
   - Should reference all 8 architecture specs
   - Should define eligibility as a core product principle
   - Should integrate with existing trust system (§6)

2. **Task Requirements Integration**
   - `PRODUCT_SPEC.md` §3 (Tasks) should reference risk classification
   - Task creation should reference `POSTER_TASK_CREATION_RISK_CLASSIFIER_LOCKED.md`
   - Task requirements should be immutable (as per risk classifier spec)

3. **Onboarding Integration**
   - `PRODUCT_SPEC.md` should reference `CAPABILITY_DRIVEN_ONBOARDING_LOCKED.md`
   - Onboarding should establish capability claims (not preferences)

4. **Feed Integration**
   - `PRODUCT_SPEC.md` should reference `FEED_QUERY_AND_ELIGIBILITY_RESOLVER_LOCKED.md`
   - Feed should be filtered by capability profile (not user preferences)

**Impact:** PRODUCT_SPEC is the root authority document. Without integration, the eligibility system is not part of the constitutional law.

**Priority:** CRITICAL — Required for constitutional authority.

---

### GAP 3: ARCHITECTURE.md Integration Missing (CRITICAL)

**Issue:** `ARCHITECTURE.md` does not reference the new capability-driven eligibility system.

**Missing Sections:**

1. **New Section: §11 — Capability Profile Authority**
   - Should define capability profile as Layer 0 authority
   - Should reference `CAPABILITY_PROFILE_SCHEMA_AND_INVARIANTS_LOCKED.md`
   - Should define recomputation engine as Layer 1 service

2. **Verification Pipeline Authority**
   - Should reference `VERIFICATION_PIPELINE_LOCKED.md`
   - Should define verification records as mutable Layer 0
   - Should define capability profile as derived Layer 0

3. **Feed Query Authority**
   - Should reference `FEED_QUERY_AND_ELIGIBILITY_RESOLVER_LOCKED.md`
   - Should define feed query as Layer 1 service (not Layer 4)

4. **Task Classification Authority**
   - Should reference `POSTER_TASK_CREATION_RISK_CLASSIFIER_LOCKED.md`
   - Should define risk classification as Layer 1 service (system-only)

**Impact:** ARCHITECTURE.md defines authority boundaries. Without integration, the eligibility system's authority is unclear.

**Priority:** CRITICAL — Required for authority clarity.

---

### GAP 4: BUILD_GUIDE.md Integration Missing (HIGH)

**Issue:** `BUILD_GUIDE.md` does not have phases for implementing the capability-driven eligibility system.

**Missing Phases:**

1. **New Phase: Phase 7 — Capability Profile System**
   - Gate: All capability profile tables created and verified
   - Gate: All invariants enforced (8 invariants from schema spec)
   - Gate: Recomputation engine implemented and tested

2. **New Phase: Phase 8 — Verification Pipeline**
   - Gate: License verification pipeline implemented
   - Gate: Insurance verification pipeline implemented
   - Gate: Background check pipeline implemented
   - Gate: Payment gating implemented

3. **New Phase: Phase 9 — Task Risk Classification**
   - Gate: Risk classification engine implemented
   - Gate: Task requirements stored immutably
   - Gate: Classification rules tested

4. **New Phase: Phase 10 — Feed Query & Eligibility Resolver**
   - Gate: Eligibility predicate implemented (pure function)
   - Gate: Feed query implemented (SQL with eligibility filter)
   - Gate: Defense-in-depth implemented (apply endpoint re-check)

5. **New Phase: Phase 11 — Settings UI**
   - Gate: Settings → Work Eligibility screen implemented
   - Gate: Verification state wiring complete
   - Gate: Upgrade opportunities computed (not estimated)

6. **New Phase: Phase 12 — Payment UX**
   - Gate: Payment gating implemented (4 hard gates)
   - Gate: Payment flow implemented (4 steps)
   - Gate: Refund rules implemented (binary)

**Impact:** BUILD_GUIDE defines execution order. Without phases, implementation order is unclear.

**Priority:** HIGH — Required for implementation guidance.

---

### GAP 5: README.md Integration Missing (MEDIUM)

**Issue:** `README.md` does not mention the new architecture specs.

**Missing Content:**

1. **Architecture Specs Section**
   - Should list all 8 architecture specs
   - Should explain their relationship to canonical docs
   - Should indicate they are locked and ready for integration

2. **Document Hierarchy Update**
   - Should include `architecture/` directory in hierarchy
   - Should show architecture specs as intermediate authority (between PRODUCT_SPEC and BUILD_GUIDE)

3. **Integration Status**
   - Should indicate architecture specs are locked but not yet integrated
   - Should provide roadmap for integration

**Impact:** README is the entry point. Without mention, the architecture specs are invisible.

**Priority:** MEDIUM — Improves discoverability.

---

### GAP 6: Cross-Reference Missing (MEDIUM)

**Issue:** The new architecture specs are not cross-referenced in existing documentation.

**Missing Cross-References:**

1. **ONBOARDING_SPEC.md**
   - Should reference `CAPABILITY_DRIVEN_ONBOARDING_LOCKED.md`
   - Should indicate capability onboarding supersedes preference onboarding

2. **UI_SPEC.md**
   - Should reference `SETTINGS_VERIFICATION_AND_ELIGIBILITY_LOCKED.md`
   - Should reference onboarding screens from capability onboarding spec

3. **schema.sql**
   - Should reference architecture specs in table comments
   - Should indicate which tables are from which spec

**Impact:** Cross-references enable traceability. Without them, relationships are unclear.

**Priority:** MEDIUM — Improves traceability.

---

### GAP 7: API Contract Missing (HIGH)

**Issue:** No API contract document exists for the eligibility system endpoints.

**Missing Endpoints:**

1. **Onboarding Endpoints** (from `CAPABILITY_DRIVEN_ONBOARDING_LOCKED.md`)
   - `POST /api/onboarding/role-selection`
   - `POST /api/onboarding/location`
   - `POST /api/onboarding/capability-declaration`
   - `POST /api/onboarding/credential-status`
   - `POST /api/onboarding/license-metadata`
   - `POST /api/onboarding/insurance-status`
   - `POST /api/onboarding/risk-willingness`
   - `POST /api/onboarding/complete`

2. **Verification Endpoints** (from `VERIFICATION_PIPELINE_LOCKED.md`)
   - `POST /api/verifications/licenses/submit`
   - `POST /api/verifications/insurance/submit`
   - `POST /api/verifications/background-checks/initiate`
   - `POST /api/verifications/licenses/renew`
   - `POST /api/verifications/insurance/renew`
   - `POST /api/verifications/background-checks/renew`

3. **Settings Endpoints** (from `SETTINGS_VERIFICATION_AND_ELIGIBILITY_LOCKED.md`)
   - `GET /api/settings/work-eligibility`
   - `GET /api/settings/work-eligibility/upgrade-opportunities`

4. **Feed Endpoints** (from `FEED_QUERY_AND_ELIGIBILITY_RESOLVER_LOCKED.md`)
   - `GET /api/tasks/feed` (updated with eligibility filter)

5. **Task Creation Endpoints** (from `POSTER_TASK_CREATION_RISK_CLASSIFIER_LOCKED.md`)
   - `POST /api/tasks/describe`
   - `POST /api/tasks/select-category`
   - `POST /api/tasks/risk-follow-ups`
   - `POST /api/tasks` (updated with risk classification)

**Impact:** Without API contracts, backend implementation is ambiguous.

**Priority:** HIGH — Required for backend implementation.

---

### GAP 8: Invariant Integration Missing (CRITICAL)

**Issue:** The new architecture specs define 8 invariants that are not in `PRODUCT_SPEC.md` or `schema.sql`.

**Missing Invariants:**

1. **INV-ELIGIBILITY-1:** Trust Tier → Risk Clearance Mapping (Immutable)
   - Authority: `CAPABILITY_PROFILE_SCHEMA_AND_INVARIANTS_LOCKED.md`
   - Enforcement: Database check constraint

2. **INV-ELIGIBILITY-2:** Verified Trades Must Have Active Verification
   - Authority: `CAPABILITY_PROFILE_SCHEMA_AND_INVARIANTS_LOCKED.md`
   - Enforcement: Recomputation logic + foreign key

3. **INV-ELIGIBILITY-3:** Expired Credentials Invalidate Capabilities
   - Authority: `CAPABILITY_PROFILE_SCHEMA_AND_INVARIANTS_LOCKED.md`
   - Enforcement: Expiry detection cron + recomputation

4. **INV-ELIGIBILITY-4:** Insurance Validity Gated by Verification
   - Authority: `CAPABILITY_PROFILE_SCHEMA_AND_INVARIANTS_LOCKED.md`
   - Enforcement: Recomputation logic

5. **INV-ELIGIBILITY-5:** Background Check Validity Gated by Verification
   - Authority: `CAPABILITY_PROFILE_SCHEMA_AND_INVARIANTS_LOCKED.md`
   - Enforcement: Recomputation logic

6. **INV-ELIGIBILITY-6:** Location State Must Be Valid US State Code
   - Authority: `CAPABILITY_PROFILE_SCHEMA_AND_INVARIANTS_LOCKED.md`
   - Enforcement: Database check constraint

7. **INV-ELIGIBILITY-7:** Willingness Flags Cannot Override Eligibility
   - Authority: `CAPABILITY_PROFILE_SCHEMA_AND_INVARIANTS_LOCKED.md`
   - Enforcement: Feed query logic

8. **INV-ELIGIBILITY-8:** Capability Profile Is Never Mutated Directly
   - Authority: `CAPABILITY_PROFILE_SCHEMA_AND_INVARIANTS_LOCKED.md`
   - Enforcement: Application logic (no direct UPDATE statements)

**Impact:** Invariants are constitutional law. Without integration, they are not enforced.

**Priority:** CRITICAL — Required for enforcement.

---

### GAP 9: Service Layer Integration Missing (HIGH)

**Issue:** No service layer specifications exist for the eligibility system.

**Missing Services:**

1. **CapabilityProfileService**
   - Purpose: Manage capability profile lifecycle
   - Functions: `recomputeCapabilityProfile()`, `getLatestCapabilityProfile()`, `invalidateFeedCache()`
   - Authority: `CAPABILITY_PROFILE_SCHEMA_AND_INVARIANTS_LOCKED.md`

2. **VerificationService**
   - Purpose: Manage verification pipeline
   - Functions: `submitLicenseVerification()`, `submitInsuranceVerification()`, `initiateBackgroundCheck()`
   - Authority: `VERIFICATION_PIPELINE_LOCKED.md`

3. **RiskClassificationService**
   - Purpose: Classify task risk and derive requirements
   - Functions: `classifyTaskRisk()`, `getRequirementsForRiskLevel()`
   - Authority: `POSTER_TASK_CREATION_RISK_CLASSIFIER_LOCKED.md`

4. **EligibilityResolverService**
   - Purpose: Resolve eligibility (pure function)
   - Functions: `isEligible()`, `getFeed()`
   - Authority: `FEED_QUERY_AND_ELIGIBILITY_RESOLVER_LOCKED.md`

5. **OnboardingService** (Update Existing)
   - Purpose: Manage capability-driven onboarding
   - Functions: Update existing service to match `CAPABILITY_DRIVEN_ONBOARDING_LOCKED.md`
   - Authority: `CAPABILITY_DRIVEN_ONBOARDING_LOCKED.md`

**Impact:** Without service specifications, backend implementation is ambiguous.

**Priority:** HIGH — Required for backend implementation.

---

### GAP 10: Test Specifications Missing (MEDIUM)

**Issue:** The architecture specs define required tests, but no test specification document exists.

**Missing Test Specifications:**

1. **Capability Profile Tests** (from `CAPABILITY_PROFILE_SCHEMA_AND_INVARIANTS_LOCKED.md`)
   - 8 invariant tests
   - Recomputation trigger tests (7 triggers)
   - Illegal state prevention tests (5 states)

2. **Verification Pipeline Tests** (from `VERIFICATION_PIPELINE_LOCKED.md`)
   - License verification flow tests (5 steps)
   - Insurance verification flow tests
   - Background check flow tests
   - Payment gating tests

3. **Feed Query Tests** (from `FEED_QUERY_AND_ELIGIBILITY_RESOLVER_LOCKED.md`)
   - 6 required tests (no verified trades, license expires, trust tier downgrade, etc.)

4. **Settings UI Tests** (from `SETTINGS_VERIFICATION_AND_ELIGIBILITY_LOCKED.md`)
   - 5 required tests (expired license, verification completes, etc.)

5. **Payment UX Tests** (from `VERIFICATION_PAYMENT_UX_AND_COPY_LOCKED.md`)
   - 6 required tests (unqualified user, failed verification refund, etc.)

**Impact:** Without test specifications, test coverage is unclear.

**Priority:** MEDIUM — Improves test coverage clarity.

---

## Integration Roadmap

### Phase 1: Schema Integration (CRITICAL)

**Tasks:**
1. Add `capability_profiles` table to `schema.sql`
2. Add `verified_trades` table to `schema.sql`
3. Add `license_verifications` table to `schema.sql`
4. Add `insurance_verifications` table to `schema.sql`
5. Add `background_checks` table to `schema.sql`
6. Add `capability_claims` table to `schema.sql` (optional, for audit)
7. Add missing fields to `tasks` table
8. Add database constraints for all 8 invariants
9. Add indexes for performance
10. Update `schema_versions` table

**Authority:** `CAPABILITY_PROFILE_SCHEMA_AND_INVARIANTS_LOCKED.md`, `VERIFICATION_PIPELINE_LOCKED.md`, `POSTER_TASK_CREATION_RISK_CLASSIFIER_LOCKED.md`

**Gate:** All tables created, all constraints verified, all indexes created.

---

### Phase 2: PRODUCT_SPEC Integration (CRITICAL)

**Tasks:**
1. Add §17 — Capability-Driven Eligibility System
2. Update §3 (Tasks) to reference risk classification
3. Update onboarding section to reference capability onboarding
4. Add 8 new invariants (INV-ELIGIBILITY-1 through INV-ELIGIBILITY-8)
5. Update document version to v1.5.0

**Authority:** All 8 architecture specs

**Gate:** PRODUCT_SPEC references all architecture specs, invariants integrated.

---

### Phase 3: ARCHITECTURE.md Integration (CRITICAL)

**Tasks:**
1. Add §11 — Capability Profile Authority
2. Add verification pipeline authority section
3. Add feed query authority section
4. Add task classification authority section
5. Update document version to v1.2.0

**Authority:** All 8 architecture specs

**Gate:** ARCHITECTURE.md references all architecture specs, authority boundaries defined.

---

### Phase 4: BUILD_GUIDE.md Integration (HIGH)

**Tasks:**
1. Add Phase 7 — Capability Profile System
2. Add Phase 8 — Verification Pipeline
3. Add Phase 9 — Task Risk Classification
4. Add Phase 10 — Feed Query & Eligibility Resolver
5. Add Phase 11 — Settings UI
6. Add Phase 12 — Payment UX
7. Update document version to v1.1.0

**Authority:** All 8 architecture specs

**Gate:** BUILD_GUIDE has phases for all eligibility system components.

---

### Phase 5: README.md Integration (MEDIUM)

**Tasks:**
1. Add Architecture Specs section
2. Update document hierarchy
3. Add integration status
4. Update schema contents list

**Authority:** All 8 architecture specs

**Gate:** README mentions architecture specs and integration status.

---

### Phase 6: Cross-Reference Integration (MEDIUM)

**Tasks:**
1. Update `ONBOARDING_SPEC.md` to reference capability onboarding
2. Update `UI_SPEC.md` to reference settings UI
3. Add cross-references in `schema.sql` table comments

**Authority:** All 8 architecture specs

**Gate:** All cross-references added.

---

### Phase 7: API Contract Creation (HIGH)

**Tasks:**
1. Create `API_CONTRACT.md` or add to existing API documentation
2. Document all onboarding endpoints
3. Document all verification endpoints
4. Document all settings endpoints
5. Document feed endpoint updates
6. Document task creation endpoint updates

**Authority:** All 8 architecture specs

**Gate:** All endpoints documented with request/response schemas.

---

## Summary

**Total Gaps Identified:** 10

**Critical Gaps:** 4
- GAP 1: Database Schema Missing
- GAP 2: PRODUCT_SPEC Integration Missing
- GAP 3: ARCHITECTURE.md Integration Missing
- GAP 8: Invariant Integration Missing

**High Priority Gaps:** 3
- GAP 4: BUILD_GUIDE.md Integration Missing
- GAP 7: API Contract Missing
- GAP 9: Service Layer Integration Missing

**Medium Priority Gaps:** 3
- GAP 5: README.md Integration Missing
- GAP 6: Cross-Reference Missing
- GAP 10: Test Specifications Missing

**Integration Roadmap:** 7 phases, starting with schema integration (most critical).

**Next Step:** Begin Phase 1 (Schema Integration) to unblock all other work.

---

**Last Updated:** 2025-01-17  
**Status:** GAP ANALYSIS COMPLETE  
**Authority:** Gap Analysis — Identifies Missing Integration Points
