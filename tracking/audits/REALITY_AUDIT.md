# HustleXP Reality Audit — Gap & Hallucination Prevention

**Status:** COMPLETE  
**Date:** January 2025  
**Purpose:** Compare WHAT THE SPECS CLAIM EXISTS vs WHAT ACTUALLY EXISTS IN THE REPO

---

## Executive Summary

This audit identifies gaps between architectural claims (PRODUCT_SPEC.md, ARCHITECTURE.md, LOCKED architecture specs) and actual implementation in `hustlexp-ai-backend` and `hustlexp-app`. This prevents hallucination, scope drift, and assuming files/components exist when they do not.

---

## 1. Claimed But Missing

### 1.1 Core Backend Services (ARCHITECTURE.md §11-13)

**Claim:** `CapabilityProfileService.recompute()` service exists  
**Spec Reference:** ARCHITECTURE.md §11.3 "Backend service (`CapabilityProfileService.recompute()`)  
**Expected File:** `hustlexp-ai-backend/backend/src/services/CapabilityProfileService.ts`  
**Actual Status:** ❌ NOT FOUND  
**Impact:** CRITICAL — Core eligibility system cannot function without recompute engine

---

**Claim:** `LicenseVerificationService` exists  
**Spec Reference:** ARCHITECTURE.md §12.2 "License verifications: `license_verifications` table"  
**Expected File:** `hustlexp-ai-backend/backend/src/services/LicenseVerificationService.ts`  
**Actual Status:** ❌ NOT FOUND  
**Impact:** CRITICAL — Verification pipeline cannot function without license verification service

---

**Claim:** `InsuranceVerificationService` exists  
**Spec Reference:** ARCHITECTURE.md §12.2 "Insurance verifications: `insurance_verifications` table"  
**Expected File:** `hustlexp-ai-backend/backend/src/services/InsuranceVerificationService.ts`  
**Actual Status:** ❌ NOT FOUND  
**Impact:** CRITICAL — Insurance verification cannot function without service

---

**Claim:** `BackgroundCheckService` exists  
**Spec Reference:** ARCHITECTURE.md §12.2 "Background checks: `background_checks` table"  
**Expected File:** `hustlexp-ai-backend/backend/src/services/BackgroundCheckService.ts`  
**Actual Status:** ❌ NOT FOUND  
**Impact:** CRITICAL — Background check verification cannot function without service

---

**Claim:** `FeedQueryService` or `EligibilityResolverService` exists  
**Spec Reference:** ARCHITECTURE.md §13.3 "Eligibility Resolver (Pure Function)"  
**Expected File:** `hustlexp-ai-backend/backend/src/services/FeedQueryService.ts` or `EligibilityResolverService.ts`  
**Actual Status:** ❌ NOT FOUND  
**Impact:** CRITICAL — Feed eligibility filtering cannot function without resolver service

---

**Claim:** `RiskClassificationService` exists  
**Spec Reference:** `architecture/POSTER_TASK_CREATION_RISK_CLASSIFIER_LOCKED.md` "Risk Classification Engine"  
**Expected File:** `hustlexp-ai-backend/backend/src/services/RiskClassificationService.ts`  
**Actual Status:** ❌ NOT FOUND (found `TaskRiskClassifier.ts` but not full service)  
**Impact:** HIGH — Task risk classification may be incomplete

---

### 1.2 API Endpoints (PRODUCT_SPEC.md §17)

**Claim:** Feed endpoints with eligibility filtering exist  
**Spec Reference:** PRODUCT_SPEC.md §17.4 "Feed Shows Only Eligible Gigs", ARCHITECTURE.md §13.2 "Feed Is a Join, Not a Filter"  
**Expected Files:** `hustlexp-ai-backend/backend/src/routers/feed.ts` or similar  
**Actual Status:** ❌ NOT FOUND  
**Impact:** CRITICAL — Feed cannot filter by eligibility without endpoint

---

**Claim:** Verification endpoints (create, status, renew) exist  
**Spec Reference:** PRODUCT_SPEC.md §17.3 "Verification as Prerequisite", ARCHITECTURE.md §12.4 "Verification Flow Authority"  
**Expected Files:** `hustlexp-ai-backend/backend/src/routers/verification.ts` or similar  
**Actual Status:** ❌ NOT FOUND  
**Impact:** CRITICAL — Verification cannot be initiated without endpoints

---

**Claim:** Settings → Work Eligibility endpoint exists  
**Spec Reference:** `architecture/SETTINGS_VERIFICATION_AND_ELIGIBILITY_LOCKED.md` "Settings → Work Eligibility"  
**Expected Files:** `hustlexp-ai-backend/backend/src/routers/settings.ts` or `eligibility.ts`  
**Actual Status:** ❌ NOT FOUND  
**Impact:** HIGH — Settings cannot display eligibility status without endpoint

---

**Claim:** Apply endpoint with eligibility recheck exists  
**Spec Reference:** ARCHITECTURE.md §13.4 "Defense-in-Depth (Apply Endpoint Recheck)"  
**Expected Files:** `hustlexp-ai-backend/backend/src/routers/tasks/apply.ts` or similar  
**Actual Status:** ⚠️ PARTIAL (may exist but needs verification)  
**Impact:** CRITICAL — Apply must recheck eligibility before accepting

---

### 1.3 Frontend Screens (PRODUCT_SPEC.md §17.8)

**Claim:** Settings → Work Eligibility screen exists  
**Spec Reference:** `architecture/SETTINGS_VERIFICATION_AND_ELIGIBILITY_LOCKED.md` "Settings → Work Eligibility UI"  
**Expected File:** `hustlexp-app/screens/settings/WorkEligibilityScreen.tsx` or similar  
**Actual Status:** ❌ NOT FOUND  
**Impact:** HIGH — Users cannot view eligibility status without screen

---

**Claim:** Capability-driven onboarding screens exist  
**Spec Reference:** `architecture/CAPABILITY_DRIVEN_ONBOARDING_LOCKED.md` "7-Phase Onboarding Flow"  
**Expected Files:** `hustlexp-app/screens/onboarding/CapabilityOnboardingScreen.tsx` or similar  
**Actual Status:** ⚠️ UNKNOWN (onboarding exists but may not be capability-driven)  
**Impact:** HIGH — Onboarding may not collect capability claims correctly

---

### 1.4 Database Migrations

**Claim:** Migration for eligibility system tables exists  
**Spec Reference:** `HUSTLEXP-DOCS/schema.sql` v1.2.0, `migrations/20250117_eligibility_system_tables.sql`  
**Expected File:** `hustlexp-ai-backend/migrations/20250117_eligibility_system_tables.sql`  
**Actual Status:** ⚠️ UNKNOWN (migration exists in HUSTLEXP-DOCS but may not be in backend repo)  
**Impact:** HIGH — Database may not have eligibility tables

---

### 1.5 Tests

**Claim:** Invariant tests for all 8 eligibility invariants exist  
**Spec Reference:** PRODUCT_SPEC.md §2 (INV-ELIGIBILITY-1 through INV-ELIGIBILITY-8)  
**Expected Files:** `hustlexp-ai-backend/tests/invariants/eligibility-invariants.test.ts`  
**Actual Status:** ❌ NOT FOUND  
**Impact:** CRITICAL — Invariants cannot be verified without tests

---

**Claim:** Integration tests for verification → recompute → feed flow exist  
**Spec Reference:** ARCHITECTURE.md §12.3 "Recomputation Flow", §13.5 "Authority Chain"  
**Expected Files:** `hustlexp-ai-backend/tests/integration/verification-recompute-feed.test.ts`  
**Actual Status:** ❌ NOT FOUND  
**Impact:** HIGH — Integration flow cannot be verified without tests

---

## 2. Partially Specified

### 2.1 TaskRiskClassifier.ts (Not Full Service)

**Item:** `TaskRiskClassifier.ts` exists but may not implement full risk classification engine  
**File Path:** `hustlexp-ai-backend/backend/src/services/TaskRiskClassifier.ts`  
**Spec Reference:** `architecture/POSTER_TASK_CREATION_RISK_CLASSIFIER_LOCKED.md` "Risk Classification Engine"  
**Missing Elements:**
- Full risk classification logic (task_category → risk_level mapping)
- Requirement mapping table (risk_level → required_trade, required_trust_tier, insurance_required, background_check_required)
- Task requirement enforcement on creation
**Risk if Ignored:** Tasks may be created without proper risk classification and requirements

---

### 2.2 EligibilityGuard.ts (Not Full Service)

**Item:** `EligibilityGuard.ts` exists but may not implement full eligibility resolver  
**File Path:** `hustlexp-ai-backend/backend/src/services/EligibilityGuard.ts`  
**Spec Reference:** ARCHITECTURE.md §13.3 "Eligibility Predicate Location"  
**Missing Elements:**
- Full `isEligible(task, capabilityProfile)` pure function
- Integration with feed query (SQL join)
- Defense-in-depth recheck for apply endpoint
**Risk if Ignored:** Feed may not filter by eligibility correctly

---

### 2.3 TrustService.ts (May Not Map Risk Clearance)

**Item:** `TrustService.ts` exists but may not implement trust tier → risk clearance mapping  
**File Path:** `hustlexp-ai-backend/backend/src/services/TrustService.ts`  
**Spec Reference:** PRODUCT_SPEC.md §2 (INV-ELIGIBILITY-1), ARCHITECTURE.md §11.2 "Source Records vs Derived Records"  
**Missing Elements:**
- Trust tier → risk clearance mapping (A→low, B/C→low+medium, D→low+medium+high)
- Risk clearance updates in capability profile on trust tier change
**Risk if Ignored:** Risk clearance may not be derived from trust tier correctly

---

### 2.4 Onboarding Service (May Not Be Capability-Driven)

**Item:** `OnboardingService.ts` exists but may not implement capability-driven onboarding  
**File Path:** `hustlexp-ai-backend/backend/src/services/OnboardingService.ts` (or `src/services/OnboardingService.ts`)  
**Spec Reference:** `architecture/CAPABILITY_DRIVEN_ONBOARDING_LOCKED.md` "7-Phase Onboarding Flow"  
**Missing Elements:**
- Capability claims collection (trades, location, willingness flags)
- Capability claims stored in `capability_claims` table
- Verification path unlocking (not task access)
**Risk if Ignored:** Onboarding may not create capability claims correctly

---

## 3. Orphaned Files

### 3.1 Existing Services Not Referenced in Architecture Specs

**File Path:** `hustlexp-ai-backend/backend/src/services/PlanService.ts`  
**Suspected Purpose:** Plan/subscription management  
**Referenced Anywhere?** ⚠️ UNKNOWN — May be legacy or unimplemented feature

---

**File Path:** `hustlexp-ai-backend/backend/src/services/StripeSubscriptionProcessor.ts`  
**Suspected Purpose:** Stripe subscription processing  
**Referenced Anywhere?** ⚠️ UNKNOWN — May be legacy or unimplemented feature

---

**File Path:** `hustlexp-ai-backend/backend/src/services/StripeEntitlementProcessor.ts`  
**Suspected Purpose:** Stripe entitlement processing  
**Referenced Anywhere?** ⚠️ UNKNOWN — May be legacy or unimplemented feature

---

**File Path:** `hustlexp-ai-backend/backend/src/services/TaskDiscoveryService.ts`  
**Suspected Purpose:** Task discovery/recommendation  
**Referenced Anywhere?** ⚠️ UNKNOWN — May overlap with feed query

---

## 4. Duplicated or Conflicting Definitions

### 4.1 Trust Tier Definitions

**Concept:** Trust tier names and values
**RESOLVED:** All specs now use INTEGER tiers (1/2/3/4):
- Tier 1 = ROOKIE (default)
- Tier 2 = VERIFIED
- Tier 3 = TRUSTED
- Tier 4 = ELITE
**Standard:** Numeric tiers (1/2/3/4) per schema.sql and PRODUCT_SPEC v1.6.0
**Impact:** RESOLVED — All files standardized

---

### 4.2 Eligibility Logic Location

**Concept:** Where eligibility computation happens  
**Conflicting Files:**
- `ARCHITECTURE.md` §13.3: "Primary Location: SQL Query (WHERE clause)", "Secondary Location: `isEligible()` function"
- `hustlexp-ai-backend/backend/src/services/EligibilityGuard.ts`: May compute eligibility in application code
**Nature of Conflict:** SQL-first vs application-first eligibility  
**Impact:** HIGH — Eligibility may be computed incorrectly  
**Resolution Required:** Enforce SQL-first eligibility per ARCHITECTURE.md §13.2

---

## 5. False Completeness Risks

### 5.1 Backend Service Count

**Area:** Backend services (BACKEND_AUDIT.md claims "100% Complete")  
**Why It Appears Complete:** 36 service files exist in `backend/src/services/`  
**What Is Actually Missing:**
- Core eligibility services (CapabilityProfileService, Verification services, FeedQueryService)
- Services may exist but not implement full spec requirements
**Risk:** False confidence in completeness prevents building missing services

---

### 5.2 Schema Completeness

**Area:** Database schema (schema.sql v1.2.0 claims eligibility tables exist)  
**Why It Appears Complete:** `schema.sql` includes eligibility system tables  
**What Is Actually Missing:**
- Migration may not be applied to `hustlexp-ai-backend` database
- Triggers may not be created in production database
- Constraints may not be enforced in actual database
**Risk:** Schema exists in docs but not in runtime database

---

### 5.3 UI Screen Implementation

**Area:** iOS app screens (17 screens claimed implemented)  
**Why It Appears Complete:** Screen files exist in `hustlexp-app/screens/`  
**What Is Actually Missing:**
- Settings → Work Eligibility screen (critical for eligibility system)
- Capability-driven onboarding screens (may not match spec)
- Screens may exist but not wired to backend eligibility endpoints
**Risk:** UI exists but cannot display eligibility information

---

## 6. Hallucination Risk Summary

### 6.1 Where Engineers/AI Are Most Likely to Assume Something Exists

**HIGH RISK:**
1. **CapabilityProfileService** — ARCHITECTURE.md §11 references this service extensively, but file does not exist
2. **Verification Services** — ARCHITECTURE.md §12 references License/Insurance/Background services, but files do not exist
3. **FeedQueryService** — ARCHITECTURE.md §13 references feed query service, but file does not exist
4. **Settings → Work Eligibility Screen** — PRODUCT_SPEC.md §17.8 references this screen, but file may not exist
5. **Eligibility Endpoints** — PRODUCT_SPEC.md §17 references endpoints, but may not exist

**MEDIUM RISK:**
1. **Risk Classification Service** — `TaskRiskClassifier.ts` exists but may not be full service
2. **Eligibility Resolver** — `EligibilityGuard.ts` exists but may not implement full logic
3. **Onboarding Service** — Exists but may not be capability-driven

### 6.2 Where Future Cursor Sessions Are Most Likely to Hallucinate Behavior

**CRITICAL RISK:**
1. **Recompute Flow** — ARCHITECTURE.md §11.3 describes `CapabilityProfileService.recompute()` flow, but service doesn't exist → Cursor may assume service exists and reference non-existent methods
2. **Feed Query** — ARCHITECTURE.md §13.2 describes SQL join for feed, but no service exists → Cursor may assume feed endpoint exists
3. **Verification Pipeline** — ARCHITECTURE.md §12.4 describes verification flow, but no services exist → Cursor may assume services exist

**HIGH RISK:**
1. **Settings UI** — PRODUCT_SPEC.md §17.8 describes Settings → Work Eligibility screen, but may not exist → Cursor may assume screen exists and try to wire it
2. **Onboarding Flow** — `architecture/CAPABILITY_DRIVEN_ONBOARDING_LOCKED.md` describes 7-phase flow, but implementation may not match → Cursor may assume implementation matches spec

### 6.3 Dangerous Assumptions to Prevent

**DO NOT ASSUME:**
- Services exist just because ARCHITECTURE.md references them → CHECK FILE EXISTS FIRST
- Database has eligibility tables just because `schema.sql` defines them → VERIFY MIGRATION APPLIED
- UI screens exist just because specs describe them → VERIFY FILES EXIST
- Existing services implement full spec requirements → VERIFY IMPLEMENTATION MATCHES SPEC

**ALWAYS VERIFY:**
- File exists before referencing it
- Service implements full spec before using it
- Database has tables before querying them
- UI screen exists before wiring it

---

## 7. Priority Gaps (Blockers vs Nice-to-Have)

### CRITICAL BLOCKERS (Must Fix Before Execution)

1. **CapabilityProfileService** — Core eligibility system cannot function without recompute engine
2. **Verification Services** — Verification pipeline cannot function without services
3. **FeedQueryService** — Feed cannot filter by eligibility without service
4. **Feed Endpoints** — Frontend cannot fetch eligible tasks without endpoint
5. **Eligibility Invariant Tests** — Invariants cannot be verified without tests

### HIGH PRIORITY (Block Progress Without These)

1. **Settings → Work Eligibility Screen** — Users cannot view eligibility status
2. **Apply Endpoint Recheck** — Apply may bypass eligibility without recheck
3. **Risk Classification Service** — Tasks may be created without proper requirements
4. **Onboarding Capability Claims** — Onboarding may not create claims correctly

### MEDIUM PRIORITY (Will Cause Issues Later)

1. **Integration Tests** — Cannot verify end-to-end flow
2. **Trust Tier → Risk Clearance Mapping** — Risk clearance may be incorrect
3. **Migration Application** — Database may not have eligibility tables

---

**END OF REALITY AUDIT**
