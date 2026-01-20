# HustleXP AI Service Interfaces v1.0.0

**STATUS: IMPLEMENTATION SPECIFICATION**
**Authority:** AI_INFRASTRUCTURE.md §5
**Cursor-Ready:** YES - All interfaces implementable without additional clarification

---

## Table of Contents

1. [Overview](#overview)
2. [Base Types](#base-types)
3. [Onboarding Services](#onboarding-services)
4. [Task Services](#task-services)
5. [Proof Services](#proof-services)
6. [Content Moderation Services](#content-moderation-services)
7. [Fraud Detection Services](#fraud-detection-services)
8. [Service Implementation](#service-implementation)

---

## Overview

This document defines concrete TypeScript interfaces for all AI services. Each service follows the AI_INFRASTRUCTURE.md authority model (A0-A3).

### Principles

1. **Typed I/O**: Every service has explicit input/output types
2. **Confidence Scores**: All proposals include confidence (0.0-1.0)
3. **Deterministic Fallback**: All services have fallback behavior when AI unavailable
4. **Audit Trail**: All calls logged to ai_jobs/ai_proposals tables

---

## Base Types

```typescript
// Common types used across all AI services

interface AIServiceConfig {
  timeout_ms: number;
  max_retries: number;
  fallback_enabled: boolean;
  kill_switch_key: string;
}

interface AIJobContext {
  job_id: string;
  event_id: string;
  user_id: string;
  subsystem: AISubsystem;
  created_at: string;
}

type AISubsystem =
  | 'onboarding'
  | 'task_classification'
  | 'pricing'
  | 'matching'
  | 'proof_analysis'
  | 'content_moderation'
  | 'fraud_detection'
  | 'support';

interface AIProposalBase {
  proposal_id: string;
  confidence: number;           // 0.0 to 1.0
  certainty_tier: 'HIGH' | 'MEDIUM' | 'LOW';
  model_id: string;
  prompt_version: string;
  latency_ms: number;
}

type CertaintyTier = 'HIGH' | 'MEDIUM' | 'LOW';

function deriveCertaintyTier(confidence: number): CertaintyTier {
  if (confidence >= 0.85) return 'HIGH';
  if (confidence >= 0.60) return 'MEDIUM';
  return 'LOW';
}
```

---

## Onboarding Services

### Role Inference Service

**Authority Level:** A2 (Proposal-Only)
**Purpose:** Infer user's primary role from onboarding questionnaire

```typescript
// === INPUT ===
interface RoleInferenceInput {
  user_id: string;
  questionnaire_answers: {
    question_id: string;
    answer_value: string | number | boolean;
  }[];
  signup_context: {
    referral_source?: string;
    device_type: 'ios' | 'android' | 'web';
    signup_time_local: string;
  };
}

// === OUTPUT ===
interface RoleInferenceProposal extends AIProposalBase {
  proposed_role: 'worker' | 'poster';
  role_confidence_worker: number;    // 0.0 to 1.0
  role_confidence_poster: number;    // 0.0 to 1.0
  contributing_signals: {
    signal_name: string;
    weight: number;
    value: string;
  }[];
  recommended_onboarding_variant: string;
}

// === SERVICE ===
interface RoleInferenceService {
  infer(
    input: RoleInferenceInput,
    ctx: AIJobContext
  ): Promise<RoleInferenceProposal>;

  // Fallback when AI unavailable
  fallback(input: RoleInferenceInput): RoleInferenceProposal;
}

// === FALLBACK IMPLEMENTATION ===
function roleInferenceFallback(input: RoleInferenceInput): RoleInferenceProposal {
  // Default: 50/50 split, let user choose
  return {
    proposal_id: `fallback_${Date.now()}`,
    confidence: 0.5,
    certainty_tier: 'LOW',
    model_id: 'fallback',
    prompt_version: 'v0',
    latency_ms: 0,
    proposed_role: 'worker',
    role_confidence_worker: 0.5,
    role_confidence_poster: 0.5,
    contributing_signals: [],
    recommended_onboarding_variant: 'default',
  };
}
```

### Profile Signals Extraction

**Authority Level:** A2 (Proposal-Only)
**Purpose:** Extract behavioral signals from onboarding for personalization

```typescript
// === INPUT ===
interface ProfileSignalsInput {
  user_id: string;
  onboarding_duration_seconds: number;
  screens_viewed: {
    screen_id: string;
    duration_seconds: number;
    interactions: number;
  }[];
  free_text_responses: {
    question_id: string;
    text: string;
  }[];
}

// === OUTPUT ===
interface ProfileSignalsProposal extends AIProposalBase {
  signals: {
    risk_tolerance: number;           // 0.0 to 1.0
    urgency_bias: number;             // 0.0 to 1.0
    authority_expectation: number;    // 0.0 to 1.0
    price_sensitivity: number;        // 0.0 to 1.0
  };
  inconsistency_flags: string[];      // e.g., ['contradictory_answers', 'rushed_completion']
  engagement_quality: 'HIGH' | 'MEDIUM' | 'LOW';
}

// === SERVICE ===
interface ProfileSignalsService {
  extract(
    input: ProfileSignalsInput,
    ctx: AIJobContext
  ): Promise<ProfileSignalsProposal>;

  fallback(input: ProfileSignalsInput): ProfileSignalsProposal;
}

// === FALLBACK IMPLEMENTATION ===
function profileSignalsFallback(input: ProfileSignalsInput): ProfileSignalsProposal {
  return {
    proposal_id: `fallback_${Date.now()}`,
    confidence: 0.5,
    certainty_tier: 'LOW',
    model_id: 'fallback',
    prompt_version: 'v0',
    latency_ms: 0,
    signals: {
      risk_tolerance: 0.5,
      urgency_bias: 0.5,
      authority_expectation: 0.5,
      price_sensitivity: 0.5,
    },
    inconsistency_flags: [],
    engagement_quality: 'MEDIUM',
  };
}
```

---

## Task Services

### Task Classification Service

**Authority Level:** A2 (Proposal-Only)
**Purpose:** Classify task category and risk level from title/description

```typescript
// === INPUT ===
interface TaskClassificationInput {
  task_id: string;
  title: string;
  description: string;
  requirements?: string;
  location_state: string;
  price_cents: number;
  poster_history: {
    tasks_posted: number;
    avg_task_price: number;
    dispute_rate: number;
  };
}

// === OUTPUT ===
interface TaskClassificationProposal extends AIProposalBase {
  primary_category: string;
  secondary_categories: string[];
  risk_level: 'low' | 'medium' | 'high' | 'critical';
  risk_factors: {
    factor: string;
    severity: 'low' | 'medium' | 'high';
    description: string;
  }[];
  required_trade: string | null;
  insurance_recommended: boolean;
  background_check_recommended: boolean;
  suggested_trust_tier: number;       // 1-4
  classification_rules_applied: string[];
}

// === CATEGORY DEFINITIONS ===
const TASK_CATEGORIES = [
  'cleaning',
  'moving',
  'delivery',
  'handyman',
  'errands',
  'tech_help',
  'yard_work',
  'pet_care',
  'admin',
  'tutoring',
  'organization',
  'elder_care',
  'child_care',
  'other',
] as const;

// === RISK CLASSIFICATION RULES ===
const RISK_RULES: {
  pattern: RegExp;
  risk_level: 'medium' | 'high' | 'critical';
  required_trade?: string;
  insurance_required?: boolean;
}[] = [
  // Electrical work
  { pattern: /\b(electric|wiring|outlet|circuit|panel)\b/i, risk_level: 'high', required_trade: 'electrician' },
  // Plumbing
  { pattern: /\b(plumb|pipe|drain|water heater|sewer)\b/i, risk_level: 'medium', required_trade: 'plumber' },
  // HVAC
  { pattern: /\b(hvac|air condition|furnace|heat pump|duct)\b/i, risk_level: 'high', required_trade: 'hvac' },
  // Gas work
  { pattern: /\b(gas line|gas leak|propane)\b/i, risk_level: 'critical', required_trade: 'gas_technician' },
  // Roofing
  { pattern: /\b(roof|gutter|shingle)\b/i, risk_level: 'high', insurance_required: true },
  // Home entry
  { pattern: /\b(inside|enter|home|house|apartment)\b/i, risk_level: 'medium' },
  // Child/Elder care
  { pattern: /\b(child|kid|baby|elder|senior|grandm|grandp)\b/i, risk_level: 'high' },
];

// === SERVICE ===
interface TaskClassificationService {
  classify(
    input: TaskClassificationInput,
    ctx: AIJobContext
  ): Promise<TaskClassificationProposal>;

  fallback(input: TaskClassificationInput): TaskClassificationProposal;
}

// === FALLBACK IMPLEMENTATION ===
function taskClassificationFallback(input: TaskClassificationInput): TaskClassificationProposal {
  // Apply deterministic rules without AI
  const matchedRules = RISK_RULES.filter(rule =>
    rule.pattern.test(input.title) || rule.pattern.test(input.description)
  );

  const highestRisk = matchedRules.reduce((max, rule) => {
    const order = { critical: 4, high: 3, medium: 2, low: 1 };
    return order[rule.risk_level] > order[max] ? rule.risk_level : max;
  }, 'low' as 'low' | 'medium' | 'high' | 'critical');

  return {
    proposal_id: `fallback_${Date.now()}`,
    confidence: 0.6,
    certainty_tier: 'LOW',
    model_id: 'fallback',
    prompt_version: 'v0',
    latency_ms: 0,
    primary_category: 'other',
    secondary_categories: [],
    risk_level: highestRisk,
    risk_factors: matchedRules.map(r => ({
      factor: r.pattern.source,
      severity: r.risk_level === 'critical' ? 'high' : r.risk_level,
      description: 'Matched keyword pattern',
    })),
    required_trade: matchedRules.find(r => r.required_trade)?.required_trade ?? null,
    insurance_recommended: matchedRules.some(r => r.insurance_required),
    background_check_recommended: highestRisk === 'critical' || highestRisk === 'high',
    suggested_trust_tier: highestRisk === 'critical' ? 4 : highestRisk === 'high' ? 3 : 2,
    classification_rules_applied: matchedRules.map(r => r.pattern.source),
  };
}
```

### Pricing Suggestion Service

**Authority Level:** A2 (Proposal-Only)
**Purpose:** Suggest price range for a task

```typescript
// === INPUT ===
interface PricingSuggestionInput {
  task_id: string;
  title: string;
  description: string;
  category: string;
  location_state: string;
  deadline_hours: number;
  poster_budget_hint?: number;        // If poster indicated budget
}

// === OUTPUT ===
interface PricingSuggestionProposal extends AIProposalBase {
  suggested_price_low_cents: number;
  suggested_price_mid_cents: number;
  suggested_price_high_cents: number;
  market_percentile: number;          // Where mid falls (0-100)
  pricing_factors: {
    factor: string;
    impact: 'increases' | 'decreases' | 'neutral';
    magnitude: number;                // 0.0 to 1.0
  }[];
  urgency_premium_applied: boolean;
  urgency_premium_percent: number;
}

// === SERVICE ===
interface PricingSuggestionService {
  suggest(
    input: PricingSuggestionInput,
    ctx: AIJobContext
  ): Promise<PricingSuggestionProposal>;

  fallback(input: PricingSuggestionInput): PricingSuggestionProposal;
}

// === CATEGORY BASE PRICES (fallback) ===
const CATEGORY_BASE_PRICES: Record<string, { low: number; mid: number; high: number }> = {
  cleaning: { low: 3000, mid: 5000, high: 8000 },
  moving: { low: 7500, mid: 12000, high: 20000 },
  delivery: { low: 1500, mid: 2500, high: 4000 },
  handyman: { low: 4000, mid: 7500, high: 15000 },
  errands: { low: 1000, mid: 2000, high: 3500 },
  tech_help: { low: 3500, mid: 6000, high: 10000 },
  yard_work: { low: 4000, mid: 6500, high: 12000 },
  pet_care: { low: 2000, mid: 3500, high: 6000 },
  other: { low: 2500, mid: 5000, high: 10000 },
};

// === FALLBACK IMPLEMENTATION ===
function pricingSuggestionFallback(input: PricingSuggestionInput): PricingSuggestionProposal {
  const base = CATEGORY_BASE_PRICES[input.category] || CATEGORY_BASE_PRICES['other'];

  // Apply urgency premium if deadline < 24 hours
  const urgencyPremium = input.deadline_hours < 24 ? 0.25 : 0;

  return {
    proposal_id: `fallback_${Date.now()}`,
    confidence: 0.5,
    certainty_tier: 'LOW',
    model_id: 'fallback',
    prompt_version: 'v0',
    latency_ms: 0,
    suggested_price_low_cents: Math.round(base.low * (1 + urgencyPremium)),
    suggested_price_mid_cents: Math.round(base.mid * (1 + urgencyPremium)),
    suggested_price_high_cents: Math.round(base.high * (1 + urgencyPremium)),
    market_percentile: 50,
    pricing_factors: [],
    urgency_premium_applied: urgencyPremium > 0,
    urgency_premium_percent: urgencyPremium * 100,
  };
}
```

---

## Proof Services

### Proof Analysis Service

**Authority Level:** A2 (Proposal-Only)
**Purpose:** Analyze proof photos and description for task completion

```typescript
// === INPUT ===
interface ProofAnalysisInput {
  proof_id: string;
  task_id: string;
  task_title: string;
  task_description: string;
  task_requirements?: string;
  proof_description: string;
  photo_urls: string[];               // Max 5
  proof_instructions?: string;
}

// === OUTPUT ===
interface ProofAnalysisProposal extends AIProposalBase {
  recommendation: 'ACCEPT' | 'REJECT' | 'NEEDS_MORE_INFO';
  acceptance_score: number;           // 0.0 to 1.0
  photo_analysis: {
    photo_url: string;
    is_relevant: boolean;
    detected_elements: string[];
    quality_score: number;            // 0.0 to 1.0
    issues: string[];
  }[];
  text_analysis: {
    addresses_requirements: boolean;
    missing_information: string[];
    quality_score: number;
  };
  rejection_reasons: string[];
  additional_info_needed: string[];
  human_review_recommended: boolean;
  human_review_reason?: string;
}

// === SERVICE ===
interface ProofAnalysisService {
  analyze(
    input: ProofAnalysisInput,
    ctx: AIJobContext
  ): Promise<ProofAnalysisProposal>;

  fallback(input: ProofAnalysisInput): ProofAnalysisProposal;
}

// === FALLBACK IMPLEMENTATION ===
function proofAnalysisFallback(input: ProofAnalysisInput): ProofAnalysisProposal {
  // Without AI, always recommend human review
  return {
    proposal_id: `fallback_${Date.now()}`,
    confidence: 0.3,
    certainty_tier: 'LOW',
    model_id: 'fallback',
    prompt_version: 'v0',
    latency_ms: 0,
    recommendation: 'NEEDS_MORE_INFO',
    acceptance_score: 0.5,
    photo_analysis: input.photo_urls.map(url => ({
      photo_url: url,
      is_relevant: true,  // Assume relevant
      detected_elements: [],
      quality_score: 0.5,
      issues: [],
    })),
    text_analysis: {
      addresses_requirements: input.proof_description.length > 20,
      missing_information: [],
      quality_score: 0.5,
    },
    rejection_reasons: [],
    additional_info_needed: ['Manual review required - AI unavailable'],
    human_review_recommended: true,
    human_review_reason: 'AI service unavailable, manual review required',
  };
}
```

---

## Content Moderation Services

### Text Moderation Service

**Authority Level:** A2 (Proposal-Only)
**Purpose:** Moderate user-generated text (task titles, descriptions, messages)

```typescript
// === INPUT ===
interface TextModerationInput {
  content_id: string;
  content_type: 'task_title' | 'task_description' | 'message' | 'review' | 'profile_bio';
  text: string;
  user_id: string;
  user_trust_tier: number;
}

// === OUTPUT ===
interface TextModerationProposal extends AIProposalBase {
  recommendation: 'APPROVE' | 'FLAG' | 'BLOCK';
  severity: 'NONE' | 'LOW' | 'MEDIUM' | 'HIGH' | 'CRITICAL';
  categories: {
    category: ModerationCategory;
    confidence: number;
    matched_phrases?: string[];
  }[];
  pii_detected: {
    type: 'phone' | 'email' | 'address' | 'ssn' | 'credit_card';
    redacted_text: string;
  }[];
  suggested_revision?: string;
  escalate_to_human: boolean;
  escalation_reason?: string;
}

type ModerationCategory =
  | 'spam'
  | 'harassment'
  | 'hate_speech'
  | 'violence'
  | 'sexual_content'
  | 'illegal_activity'
  | 'scam'
  | 'pii_exposure'
  | 'off_platform_solicitation';

// === SERVICE ===
interface TextModerationService {
  moderate(
    input: TextModerationInput,
    ctx: AIJobContext
  ): Promise<TextModerationProposal>;

  fallback(input: TextModerationInput): TextModerationProposal;
}

// === BLOCKLIST PATTERNS (fallback) ===
const BLOCKLIST_PATTERNS: { pattern: RegExp; category: ModerationCategory; severity: 'HIGH' | 'CRITICAL' }[] = [
  { pattern: /\b(venmo|paypal|cashapp|zelle)\s*(me|you)?\b/i, category: 'off_platform_solicitation', severity: 'HIGH' },
  { pattern: /\b(text|call|contact)\s*me\s*(at|on)?\s*\d{3}/i, category: 'pii_exposure', severity: 'HIGH' },
  { pattern: /\b\d{3}[-.\s]?\d{3}[-.\s]?\d{4}\b/, category: 'pii_exposure', severity: 'HIGH' },
  { pattern: /[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}/, category: 'pii_exposure', severity: 'HIGH' },
];

// === FALLBACK IMPLEMENTATION ===
function textModerationFallback(input: TextModerationInput): TextModerationProposal {
  const matches = BLOCKLIST_PATTERNS.filter(p => p.pattern.test(input.text));

  if (matches.length > 0) {
    return {
      proposal_id: `fallback_${Date.now()}`,
      confidence: 0.9,
      certainty_tier: 'HIGH',
      model_id: 'fallback',
      prompt_version: 'v0',
      latency_ms: 0,
      recommendation: 'FLAG',
      severity: matches.some(m => m.severity === 'CRITICAL') ? 'CRITICAL' : 'HIGH',
      categories: matches.map(m => ({
        category: m.category,
        confidence: 0.95,
        matched_phrases: [m.pattern.source],
      })),
      pii_detected: [],
      escalate_to_human: true,
      escalation_reason: 'Blocklist pattern match',
    };
  }

  return {
    proposal_id: `fallback_${Date.now()}`,
    confidence: 0.5,
    certainty_tier: 'LOW',
    model_id: 'fallback',
    prompt_version: 'v0',
    latency_ms: 0,
    recommendation: 'APPROVE',
    severity: 'NONE',
    categories: [],
    pii_detected: [],
    escalate_to_human: false,
  };
}
```

### Image Moderation Service

**Authority Level:** A2 (Proposal-Only)
**Purpose:** Moderate user-uploaded images

```typescript
// === INPUT ===
interface ImageModerationInput {
  content_id: string;
  content_type: 'proof_photo' | 'profile_photo' | 'message_photo';
  image_url: string;
  user_id: string;
}

// === OUTPUT ===
interface ImageModerationProposal extends AIProposalBase {
  recommendation: 'APPROVE' | 'FLAG' | 'BLOCK';
  severity: 'NONE' | 'LOW' | 'MEDIUM' | 'HIGH' | 'CRITICAL';
  categories: {
    category: ImageModerationCategory;
    confidence: number;
  }[];
  is_screenshot: boolean;
  contains_text: boolean;
  extracted_text?: string;
  escalate_to_human: boolean;
  escalation_reason?: string;
}

type ImageModerationCategory =
  | 'safe'
  | 'adult_content'
  | 'violence'
  | 'hate_symbols'
  | 'drugs'
  | 'weapons'
  | 'pii_visible'
  | 'spam_text';

// === SERVICE ===
interface ImageModerationService {
  moderate(
    input: ImageModerationInput,
    ctx: AIJobContext
  ): Promise<ImageModerationProposal>;

  fallback(input: ImageModerationInput): ImageModerationProposal;
}

// === FALLBACK IMPLEMENTATION ===
function imageModerationFallback(input: ImageModerationInput): ImageModerationProposal {
  // Without AI vision, approve but flag for async review
  return {
    proposal_id: `fallback_${Date.now()}`,
    confidence: 0.3,
    certainty_tier: 'LOW',
    model_id: 'fallback',
    prompt_version: 'v0',
    latency_ms: 0,
    recommendation: 'APPROVE',
    severity: 'NONE',
    categories: [{ category: 'safe', confidence: 0.5 }],
    is_screenshot: false,
    contains_text: false,
    escalate_to_human: true,
    escalation_reason: 'AI vision unavailable, queued for manual review',
  };
}
```

---

## Fraud Detection Services

### User Risk Scoring Service

**Authority Level:** A2 (Proposal-Only)
**Purpose:** Compute fraud risk score for a user

```typescript
// === INPUT ===
interface UserRiskScoringInput {
  user_id: string;
  account_age_days: number;
  total_tasks_completed: number;
  total_tasks_posted: number;
  dispute_rate: number;
  cancellation_rate: number;
  avg_response_time_minutes: number;
  payment_methods_count: number;
  unique_ip_count_30d: number;
  unique_device_count_30d: number;
  avg_task_price_completed: number;
  velocity_tasks_24h: number;
  recent_flags: string[];
}

// === OUTPUT ===
interface UserRiskScoringProposal extends AIProposalBase {
  risk_score: number;                 // 0.0 to 1.0
  risk_level: 'LOW' | 'MEDIUM' | 'HIGH' | 'CRITICAL';
  component_scores: {
    velocity_risk: number;
    device_risk: number;
    behavior_risk: number;
    financial_risk: number;
  };
  flags: string[];
  recommended_actions: ('monitor' | 'restrict_live_mode' | 'require_verification' | 'manual_review' | 'suspend')[];
  similar_accounts: string[];         // User IDs of potentially linked accounts
}

// === SERVICE ===
interface UserRiskScoringService {
  score(
    input: UserRiskScoringInput,
    ctx: AIJobContext
  ): Promise<UserRiskScoringProposal>;

  fallback(input: UserRiskScoringInput): UserRiskScoringProposal;
}

// === FALLBACK IMPLEMENTATION ===
function userRiskScoringFallback(input: UserRiskScoringInput): UserRiskScoringProposal {
  // Rule-based risk scoring
  let riskScore = 0;

  // New account risk
  if (input.account_age_days < 7) riskScore += 0.2;
  if (input.account_age_days < 1) riskScore += 0.2;

  // High dispute/cancellation
  if (input.dispute_rate > 0.1) riskScore += 0.3;
  if (input.cancellation_rate > 0.2) riskScore += 0.2;

  // Multiple devices/IPs
  if (input.unique_device_count_30d > 5) riskScore += 0.15;
  if (input.unique_ip_count_30d > 10) riskScore += 0.15;

  // High velocity
  if (input.velocity_tasks_24h > 10) riskScore += 0.2;

  riskScore = Math.min(1, riskScore);

  const riskLevel =
    riskScore >= 0.8 ? 'CRITICAL' :
    riskScore >= 0.6 ? 'HIGH' :
    riskScore >= 0.3 ? 'MEDIUM' : 'LOW';

  return {
    proposal_id: `fallback_${Date.now()}`,
    confidence: 0.6,
    certainty_tier: 'MEDIUM',
    model_id: 'fallback',
    prompt_version: 'v0',
    latency_ms: 0,
    risk_score: riskScore,
    risk_level: riskLevel,
    component_scores: {
      velocity_risk: input.velocity_tasks_24h > 10 ? 0.8 : 0.2,
      device_risk: input.unique_device_count_30d > 5 ? 0.7 : 0.2,
      behavior_risk: (input.dispute_rate + input.cancellation_rate) / 2,
      financial_risk: 0.3,
    },
    flags: [],
    recommended_actions: riskLevel === 'CRITICAL' ? ['manual_review', 'suspend'] :
                         riskLevel === 'HIGH' ? ['manual_review', 'restrict_live_mode'] :
                         riskLevel === 'MEDIUM' ? ['monitor'] : [],
    similar_accounts: [],
  };
}
```

---

## Service Implementation

### AI Orchestrator

```typescript
interface AIOrchestrator {
  // Execute any AI service with unified error handling
  execute<TInput, TOutput extends AIProposalBase>(
    service: AIService<TInput, TOutput>,
    input: TInput,
    ctx: AIJobContext
  ): Promise<TOutput>;

  // Check if a service's kill switch is engaged
  isKillSwitchActive(subsystem: AISubsystem): boolean;

  // Get service health metrics
  getServiceHealth(subsystem: AISubsystem): ServiceHealth;
}

interface AIService<TInput, TOutput extends AIProposalBase> {
  subsystem: AISubsystem;
  config: AIServiceConfig;
  execute(input: TInput, ctx: AIJobContext): Promise<TOutput>;
  fallback(input: TInput): TOutput;
}

interface ServiceHealth {
  status: 'healthy' | 'degraded' | 'down';
  latency_p50_ms: number;
  latency_p99_ms: number;
  error_rate_1h: number;
  fallback_rate_1h: number;
}

// === IMPLEMENTATION ===
class AIOrchestrator {
  async execute<TInput, TOutput extends AIProposalBase>(
    service: AIService<TInput, TOutput>,
    input: TInput,
    ctx: AIJobContext
  ): Promise<TOutput> {
    // Check kill switch
    if (this.isKillSwitchActive(service.subsystem)) {
      console.log(`[AI] Kill switch active for ${service.subsystem}, using fallback`);
      return service.fallback(input);
    }

    try {
      const startTime = Date.now();

      // Set timeout
      const result = await Promise.race([
        service.execute(input, ctx),
        new Promise<never>((_, reject) =>
          setTimeout(() => reject(new Error('AI_TIMEOUT')), service.config.timeout_ms)
        ),
      ]);

      // Log success
      await this.logJob(ctx, 'COMPLETED', Date.now() - startTime);

      return result;
    } catch (error) {
      console.error(`[AI] Service ${service.subsystem} failed:`, error);

      // Log failure
      await this.logJob(ctx, 'FAILED', 0, error);

      // Use fallback
      if (service.config.fallback_enabled) {
        return service.fallback(input);
      }

      throw error;
    }
  }

  private async logJob(
    ctx: AIJobContext,
    status: 'COMPLETED' | 'FAILED',
    latency_ms: number,
    error?: unknown
  ): Promise<void> {
    // Insert into ai_jobs table
    // Implementation depends on your DB client
  }
}
```

### Service Registry

```typescript
const AI_SERVICE_REGISTRY: Record<AISubsystem, AIServiceConfig> = {
  onboarding: {
    timeout_ms: 5000,
    max_retries: 2,
    fallback_enabled: true,
    kill_switch_key: 'ai:kill:onboarding',
  },
  task_classification: {
    timeout_ms: 3000,
    max_retries: 1,
    fallback_enabled: true,
    kill_switch_key: 'ai:kill:task_classification',
  },
  pricing: {
    timeout_ms: 3000,
    max_retries: 1,
    fallback_enabled: true,
    kill_switch_key: 'ai:kill:pricing',
  },
  matching: {
    timeout_ms: 2000,
    max_retries: 0,
    fallback_enabled: true,
    kill_switch_key: 'ai:kill:matching',
  },
  proof_analysis: {
    timeout_ms: 10000,
    max_retries: 2,
    fallback_enabled: true,
    kill_switch_key: 'ai:kill:proof_analysis',
  },
  content_moderation: {
    timeout_ms: 5000,
    max_retries: 1,
    fallback_enabled: true,
    kill_switch_key: 'ai:kill:content_moderation',
  },
  fraud_detection: {
    timeout_ms: 5000,
    max_retries: 1,
    fallback_enabled: true,
    kill_switch_key: 'ai:kill:fraud_detection',
  },
  support: {
    timeout_ms: 10000,
    max_retries: 2,
    fallback_enabled: false,
    kill_switch_key: 'ai:kill:support',
  },
};
```

---

## Amendment History

| Version | Date | Summary |
|---------|------|---------|
| 1.0.0 | Jan 2025 | Initial AI service interfaces specification |

---

**END OF AI SERVICE INTERFACES SPECIFICATION**
