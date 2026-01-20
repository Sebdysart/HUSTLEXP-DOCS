/**
 * Mock Verification Data
 * SPEC: CAPABILITY_PROFILE_SCHEMA_AND_INVARIANTS_LOCKED.md
 * SPEC: PRODUCT_SPEC.md §17
 *
 * Verifications are credential validations that determine task eligibility.
 * Types: license, insurance, background_check
 */

export const VerificationType = {
  LICENSE: 'license',
  INSURANCE: 'insurance',
  BACKGROUND_CHECK: 'background_check',
};

export const VerificationStatus = {
  PENDING: 'pending',
  APPROVED: 'approved',
  REJECTED: 'rejected',
  EXPIRED: 'expired',
};

// Licensed trades supported
export const LicensedTrades = {
  ELECTRICIAN: 'electrician',
  PLUMBER: 'plumber',
  HVAC: 'hvac',
  GENERAL_CONTRACTOR: 'general_contractor',
  LOCKSMITH: 'locksmith',
  PEST_CONTROL: 'pest_control',
  LANDSCAPING: 'landscaping',
};

export const MOCK_VERIFICATIONS = {
  // Elite user has multiple verified credentials
  'verification-elite-electrician': {
    id: 'verification-elite-electrician',
    user_id: 'user-hustler-elite',
    type: VerificationType.LICENSE,
    trade: LicensedTrades.ELECTRICIAN,
    status: VerificationStatus.APPROVED,
    license_number: 'EL-12345-TX',
    state: 'TX',
    expires_at: '2026-06-01T00:00:00Z',
    verified_at: '2024-06-15T10:00:00Z',
    verified_by: 'system',
    document_url: 'https://storage.example.com/verifications/elite-elec-license.pdf',
    created_at: '2024-06-10T09:00:00Z',
    updated_at: '2024-06-15T10:00:00Z',
  },

  'verification-elite-insurance': {
    id: 'verification-elite-insurance',
    user_id: 'user-hustler-elite',
    type: VerificationType.INSURANCE,
    trade: LicensedTrades.ELECTRICIAN,  // Insurance is trade-scoped
    status: VerificationStatus.APPROVED,
    policy_number: 'INS-ELITE-001',
    coverage_amount: 100000000,  // $1,000,000 in cents
    state: 'TX',
    expires_at: '2025-12-31T00:00:00Z',
    verified_at: '2024-06-20T10:00:00Z',
    verified_by: 'system',
    document_url: 'https://storage.example.com/verifications/elite-insurance.pdf',
    created_at: '2024-06-18T09:00:00Z',
    updated_at: '2024-06-20T10:00:00Z',
  },

  'verification-elite-background': {
    id: 'verification-elite-background',
    user_id: 'user-hustler-elite',
    type: VerificationType.BACKGROUND_CHECK,
    status: VerificationStatus.APPROVED,
    check_provider: 'checkr',
    check_id: 'chk_elite_001',
    state: 'TX',
    expires_at: '2025-06-15T00:00:00Z',
    verified_at: '2024-06-15T14:00:00Z',
    verified_by: 'system',
    created_at: '2024-06-14T09:00:00Z',
    updated_at: '2024-06-15T14:00:00Z',
  },

  // Active hustler has ID verification only (trust tier 2)
  'verification-active-id': {
    id: 'verification-active-id',
    user_id: 'user-hustler-active',
    type: 'id_verification',  // Basic ID, not a license
    status: VerificationStatus.APPROVED,
    state: 'TX',
    verified_at: '2024-12-05T14:00:00Z',
    verified_by: 'system',
    created_at: '2024-12-03T09:00:00Z',
    updated_at: '2024-12-05T14:00:00Z',
  },

  // Pending verification example
  'verification-active-pending': {
    id: 'verification-active-pending',
    user_id: 'user-hustler-active',
    type: VerificationType.LICENSE,
    trade: LicensedTrades.GENERAL_CONTRACTOR,
    status: VerificationStatus.PENDING,
    license_number: 'GC-99999-TX',
    state: 'TX',
    submitted_at: '2025-01-14T10:00:00Z',
    document_url: 'https://storage.example.com/verifications/active-gc-pending.pdf',
    created_at: '2025-01-14T10:00:00Z',
    updated_at: '2025-01-14T10:00:00Z',
  },

  // Expired verification example
  'verification-expired-example': {
    id: 'verification-expired-example',
    user_id: 'user-both',
    type: VerificationType.LICENSE,
    trade: LicensedTrades.PLUMBER,
    status: VerificationStatus.EXPIRED,
    license_number: 'PL-55555-TX',
    state: 'TX',
    expires_at: '2024-12-31T00:00:00Z',  // Expired
    verified_at: '2024-01-15T10:00:00Z',
    verified_by: 'system',
    document_url: 'https://storage.example.com/verifications/both-plumber-expired.pdf',
    created_at: '2024-01-10T09:00:00Z',
    updated_at: '2025-01-01T00:00:00Z',  // Auto-expired by system
  },

  // Rejected verification example
  'verification-rejected-example': {
    id: 'verification-rejected-example',
    user_id: 'user-hustler-new',
    type: VerificationType.LICENSE,
    trade: LicensedTrades.HVAC,
    status: VerificationStatus.REJECTED,
    license_number: 'HV-00001-TX',
    state: 'TX',
    rejection_reason: 'License number could not be verified with state database',
    submitted_at: '2025-01-12T10:00:00Z',
    reviewed_at: '2025-01-13T15:00:00Z',
    reviewed_by: 'admin-001',
    document_url: 'https://storage.example.com/verifications/new-hvac-rejected.pdf',
    created_at: '2025-01-12T10:00:00Z',
    updated_at: '2025-01-13T15:00:00Z',
  },
};

// Capability claims (from onboarding) - historical record of what users stated
export const MOCK_CAPABILITY_CLAIMS = {
  'claim-elite-trades': {
    id: 'claim-elite-trades',
    user_id: 'user-hustler-elite',
    claimed_trades: [LicensedTrades.ELECTRICIAN, LicensedTrades.GENERAL_CONTRACTOR],
    location_state: 'TX',
    willing_in_home: true,
    willing_high_risk: true,
    willing_urgent: true,
    claimed_at: '2024-06-01T10:00:00Z',
  },

  'claim-active-general': {
    id: 'claim-active-general',
    user_id: 'user-hustler-active',
    claimed_trades: [LicensedTrades.GENERAL_CONTRACTOR],
    location_state: 'TX',
    willing_in_home: true,
    willing_high_risk: false,
    willing_urgent: true,
    claimed_at: '2024-12-01T10:00:00Z',
  },

  'claim-new-none': {
    id: 'claim-new-none',
    user_id: 'user-hustler-new',
    claimed_trades: [],
    location_state: 'TX',
    willing_in_home: false,
    willing_high_risk: false,
    willing_urgent: false,
    claimed_at: '2025-01-15T10:00:00Z',
  },
};

// Computed capability profiles (derived from verifications + trust tier)
export const MOCK_CAPABILITY_PROFILES = {
  'profile-elite': {
    id: 'profile-elite',
    user_id: 'user-hustler-elite',
    trust_tier: 4,  // ELITE
    risk_clearance: 'high',  // Can do low, medium, high risk tasks
    verified_trades: [LicensedTrades.ELECTRICIAN],
    insurance_valid: true,
    background_check_valid: true,
    location_state: 'TX',
    // Derived from verifications
    computed_at: '2025-01-15T00:00:00Z',
  },

  'profile-active': {
    id: 'profile-active',
    user_id: 'user-hustler-active',
    trust_tier: 2,  // VERIFIED
    risk_clearance: 'medium',  // Can do low, medium risk tasks
    verified_trades: [],  // No verified licenses yet
    insurance_valid: false,
    background_check_valid: false,
    location_state: 'TX',
    computed_at: '2025-01-15T00:00:00Z',
  },

  'profile-new': {
    id: 'profile-new',
    user_id: 'user-hustler-new',
    trust_tier: 1,  // ROOKIE
    risk_clearance: 'low',  // Can only do low risk tasks
    verified_trades: [],
    insurance_valid: false,
    background_check_valid: false,
    location_state: 'TX',
    computed_at: '2025-01-15T00:00:00Z',
  },
};

/**
 * Get verification by ID
 * @param {string} verificationId
 * @returns {Object|null}
 */
export const getVerification = (verificationId) =>
  MOCK_VERIFICATIONS[verificationId] || null;

/**
 * Get all verifications for a user
 * @param {string} userId
 * @returns {Object[]}
 */
export const getVerificationsForUser = (userId) => {
  return Object.values(MOCK_VERIFICATIONS).filter(v => v.user_id === userId);
};

/**
 * Get active (approved, not expired) verifications for a user
 * @param {string} userId
 * @returns {Object[]}
 */
export const getActiveVerificationsForUser = (userId) => {
  const now = new Date();
  return Object.values(MOCK_VERIFICATIONS).filter(v =>
    v.user_id === userId &&
    v.status === VerificationStatus.APPROVED &&
    (!v.expires_at || new Date(v.expires_at) > now)
  );
};

/**
 * Get capability profile for a user
 * @param {string} userId
 * @returns {Object|null}
 */
export const getCapabilityProfile = (userId) => {
  return Object.values(MOCK_CAPABILITY_PROFILES).find(p => p.user_id === userId) || null;
};

/**
 * Get capability claims for a user
 * @param {string} userId
 * @returns {Object|null}
 */
export const getCapabilityClaims = (userId) => {
  return Object.values(MOCK_CAPABILITY_CLAIMS).find(c => c.user_id === userId) || null;
};

/**
 * Check if user has verified trade
 * @param {string} userId
 * @param {string} trade
 * @returns {boolean}
 */
export const hasVerifiedTrade = (userId, trade) => {
  const profile = getCapabilityProfile(userId);
  return profile?.verified_trades?.includes(trade) || false;
};

/**
 * Check if user can access risk level
 * @param {string} userId
 * @param {string} riskLevel - 'low', 'medium', 'high'
 * @returns {boolean}
 */
export const canAccessRiskLevel = (userId, riskLevel) => {
  const profile = getCapabilityProfile(userId);
  if (!profile) return false;

  const riskHierarchy = { low: 1, medium: 2, high: 3 };
  const userClearance = riskHierarchy[profile.risk_clearance] || 0;
  const requiredClearance = riskHierarchy[riskLevel] || 0;

  return userClearance >= requiredClearance;
};

/**
 * Get pending verifications count for a user
 * @param {string} userId
 * @returns {number}
 */
export const getPendingVerificationsCount = (userId) => {
  return Object.values(MOCK_VERIFICATIONS).filter(
    v => v.user_id === userId && v.status === VerificationStatus.PENDING
  ).length;
};

/**
 * Get expiring verifications (within 30 days)
 * @param {string} userId
 * @returns {Object[]}
 */
export const getExpiringVerifications = (userId) => {
  const now = new Date();
  const thirtyDaysFromNow = new Date(now.getTime() + 30 * 24 * 60 * 60 * 1000);

  return Object.values(MOCK_VERIFICATIONS).filter(v =>
    v.user_id === userId &&
    v.status === VerificationStatus.APPROVED &&
    v.expires_at &&
    new Date(v.expires_at) > now &&
    new Date(v.expires_at) <= thirtyDaysFromNow
  );
};

export default {
  MOCK_VERIFICATIONS,
  MOCK_CAPABILITY_CLAIMS,
  MOCK_CAPABILITY_PROFILES,
};
