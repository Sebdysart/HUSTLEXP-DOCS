# AI Task Template System v2.1 Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build a bulletproof 8-template task creation system with server-side Compliance Guardian AI, deterministic risk/pricing, and structured proof criteria — eliminating pricing errors, disputes, and illegal task postings.

**Architecture:** 4-layer pipeline: ComplianceGuardian (pre-screen) → TaskRiskClassifier (template-aware) → ScoperAI (context-injected + deterministic multipliers) → Template (structured proof/completion criteria). Every task flows through all 4 layers before posting. iOS template picker replaces generic "what do you need done?" form.

**Tech Stack:** Node.js / TypeScript / tRPC / PostgreSQL / Zod / Groq LLM / SwiftUI

**Design doc:** `docs/plans/2026-03-16-ai-task-template-system-design.md`

---

## Task 1: Database Migration

**Files:**
- Create: `backend/database/migrations/task_template_system.sql`

**Step 1: Write the migration**

```sql
-- backend/database/migrations/task_template_system.sql
-- AI Task Template System v2.1
-- Adds: template_slug, completion_criteria, compliance fields, consent, late_cancel_pct
-- Creates: compliance_violations table

BEGIN;

-- ============================================================
-- 1. New columns on tasks
-- ============================================================

ALTER TABLE tasks
  ADD COLUMN IF NOT EXISTS template_slug VARCHAR(50),
  ADD COLUMN IF NOT EXISTS completion_criteria JSONB,
  ADD COLUMN IF NOT EXISTS content_release BOOLEAN DEFAULT FALSE,
  ADD COLUMN IF NOT EXISTS cancellation_window_hours INTEGER DEFAULT 0,
  ADD COLUMN IF NOT EXISTS illegal_risk_score INTEGER DEFAULT 0 CHECK (illegal_risk_score BETWEEN 0 AND 100),
  ADD COLUMN IF NOT EXISTS compliance_guardian_notes JSONB,
  ADD COLUMN IF NOT EXISTS mutual_consent_accepted BOOLEAN DEFAULT FALSE,
  ADD COLUMN IF NOT EXISTS late_cancel_pct INTEGER NOT NULL DEFAULT 0 CHECK (late_cancel_pct BETWEEN 0 AND 100);

-- Index for compliance dashboard queries
CREATE INDEX IF NOT EXISTS idx_tasks_illegal_risk_score
  ON tasks(illegal_risk_score)
  WHERE illegal_risk_score > 20;

CREATE INDEX IF NOT EXISTS idx_tasks_template_slug
  ON tasks(template_slug);

-- ============================================================
-- 2. compliance_violations table (Trust & Safety only)
-- ============================================================

CREATE TABLE IF NOT EXISTS compliance_violations (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID NOT NULL REFERENCES users(id) ON DELETE SET NULL,
  ip_address      INET,
  device_fingerprint TEXT,
  raw_description TEXT NOT NULL,
  risk_score      INTEGER NOT NULL CHECK (risk_score BETWEEN 0 AND 100),
  triggered_rules JSONB,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_compliance_violations_user_id
  ON compliance_violations(user_id);

CREATE INDEX IF NOT EXISTS idx_compliance_violations_risk_score
  ON compliance_violations(risk_score);

COMMIT;
```

**Step 2: Apply migration**

```bash
cd /Users/sebastiandysart/Desktop/hustlexp-ai-backend
node migrate-pg.mjs
```

Expected: `Migration applied: task_template_system.sql`

**Step 3: Verify columns exist**

```bash
node -e "
const { db } = await import('./backend/src/db.js');
const r = await db.query(\"SELECT column_name FROM information_schema.columns WHERE table_name='tasks' AND column_name IN ('template_slug','illegal_risk_score','mutual_consent_accepted','late_cancel_pct')\");
console.log(r.rows);
process.exit(0);
"
```

Expected: 4 rows returned.

**Step 4: Commit**

```bash
git add backend/database/migrations/task_template_system.sql
git commit -m "feat(db): task template system migration — template_slug, compliance fields, consent, late_cancel_pct"
```

---

## Task 2: Template Registry

**Files:**
- Create: `backend/src/services/TaskTemplateRegistry.ts`
- Create: `backend/tests/unit/TaskTemplateRegistry.test.ts`

**Step 1: Write the failing test**

```typescript
// backend/tests/unit/TaskTemplateRegistry.test.ts
import { describe, it, expect } from 'vitest';
import {
  TaskTemplateRegistry,
  getTemplate,
  TEMPLATE_SLUGS,
  type TaskTemplate,
} from '../../src/services/TaskTemplateRegistry.js';

describe('TaskTemplateRegistry', () => {
  it('has exactly 8 templates', () => {
    expect(Object.keys(TaskTemplateRegistry)).toHaveLength(8);
  });

  it('every template has required fields', () => {
    for (const slug of Object.values(TEMPLATE_SLUGS)) {
      const t = TaskTemplateRegistry[slug];
      expect(t.slug).toBe(slug);
      expect(t.defaultRiskTier).toBeGreaterThanOrEqual(0);
      expect(t.defaultRiskTier).toBeLessThanOrEqual(3);
      expect(t.requiredTrustTier).toBeDefined();
      expect(t.completionCriteriaType).toBeDefined();
      expect(t.autoReleaseHours).toBeGreaterThan(0);
      expect(t.lateCancelPct).toBeGreaterThanOrEqual(0);
      expect(t.scoperContext).toBeTruthy();
    }
  });

  it('getTemplate returns correct template for known slug', () => {
    const t = getTemplate('content_creator');
    expect(t.slug).toBe('content_creator');
    expect(t.requiresMutualConsent).toBe(true);
  });

  it('getTemplate falls back to wildcard_bizarre for unknown slug', () => {
    const t = getTemplate('totally_unknown_slug');
    expect(t.slug).toBe('wildcard_bizarre');
  });

  it('wildcard_bizarre has deterministic multiplier table', () => {
    const t = getTemplate('wildcard_bizarre');
    expect(t.wildcardMultipliers).toBeDefined();
    expect(t.wildcardMultipliers!.performance_element_flag).toBe(0.20);
  });
});
```

**Step 2: Run test to verify it fails**

```bash
cd /Users/sebastiandysart/Desktop/hustlexp-ai-backend
npx vitest run backend/tests/unit/TaskTemplateRegistry.test.ts
```

Expected: FAIL — `TaskTemplateRegistry` not found

**Step 3: Implement the registry**

```typescript
// backend/src/services/TaskTemplateRegistry.ts

export const TEMPLATE_SLUGS = {
  STANDARD_PHYSICAL:    'standard_physical',
  IN_HOME:              'in_home',
  CARE:                 'care',
  CONTENT_CREATOR:      'content_creator',
  EVENT_APPEARANCE:     'event_appearance',
  CREATIVE_PRODUCTION:  'creative_production',
  SPECIALIZED_LICENSED: 'specialized_licensed',
  WILDCARD_BIZARRE:     'wildcard_bizarre',
} as const;

export type TemplateSlug = typeof TEMPLATE_SLUGS[keyof typeof TEMPLATE_SLUGS];

export type CompletionCriteriaType =
  | 'photo_proof'
  | 'check_in_check_out'
  | 'session_completion'
  | 'hybrid';

export interface TaskTemplate {
  slug: TemplateSlug;
  displayName: string;
  defaultRiskTier: 0 | 1 | 2 | 3;       // minimum tier; flags can only raise it
  requiredTrustTier: 'rookie' | 'verified' | 'trusted';
  completionCriteriaType: CompletionCriteriaType;
  autoReleaseHours: number;              // hours after proof before auto-release
  lateCancelPct: number;                 // % of price released on Poster late-cancel
  requiresMutualConsent: boolean;        // wildcard + content_creator only
  requiresContentRelease: boolean;
  scoperContext: string;
  wildcardMultipliers?: Record<string, number>;  // wildcard_bizarre only
}

export const WILDCARD_MULTIPLIERS: Record<string, number> = {
  private_location_flag:    0.15,
  props_required_flag:      0.10,
  performance_element_flag: 0.20,
  audience_present_flag:    0.10,
  costume_or_attire_flag:   0.10,
  travel_over_30min_flag:   0.20,
};

export const MAX_WILDCARD_PREMIUM = 0.50; // 50% cap

export const TaskTemplateRegistry: Record<TemplateSlug, TaskTemplate> = {
  standard_physical: {
    slug: 'standard_physical',
    displayName: 'Standard Physical',
    defaultRiskTier: 0,
    requiredTrustTier: 'rookie',
    completionCriteriaType: 'photo_proof',
    autoReleaseHours: 24,
    lateCancelPct: 0,
    requiresMutualConsent: false,
    requiresContentRelease: false,
    scoperContext: `TEMPLATE: standard_physical
Market rate: light labor $15–$30/hr, moderate $25–$50/hr, heavy $40–$75/hr.
Vehicle premium: +$10–$20 flat if required. Multi-person: multiply by count.
$15 floor for any task under 30 min.
Flag "heavy_lifting" if moving furniture, appliances, or heavy boxes.
Flag "vehicle_required" if delivery >2 miles or items too large to carry.`,
  },

  in_home: {
    slug: 'in_home',
    displayName: 'In-Home',
    defaultRiskTier: 2,
    requiredTrustTier: 'verified',
    completionCriteriaType: 'photo_proof',
    autoReleaseHours: 24,
    lateCancelPct: 0,
    requiresMutualConsent: false,
    requiresContentRelease: false,
    scoperContext: `TEMPLATE: in_home
Market rate: apartment cleaning $60–$100, house $100–$180, deep clean 1.5–2x.
Handyman: $40–$75/hr. Painting per room: $150–$300.
Never price below $40 for any in-home task.
Flag "licensed_required" if electrical, plumbing, or structural work described.
Always flag "inside_home" — minimum TIER_2 risk.`,
  },

  care: {
    slug: 'care',
    displayName: 'Care',
    defaultRiskTier: 3,
    requiredTrustTier: 'verified',
    completionCriteriaType: 'check_in_check_out',
    autoReleaseHours: 0,  // auto-releases on GPS checkout
    lateCancelPct: 0,
    requiresMutualConsent: false,
    requiresContentRelease: false,
    scoperContext: `TEMPLATE: care
Market rate: babysitting 1 child $18–$25/hr, +$5/hr each additional.
Pet sitting 8hr: $40–$80. Dog walk 30min: $20–$35.
Elder care companion: $20–$30/hr. Personal assistant: $18–$28/hr.
ALWAYS TIER_3. Minimum 2-hour duration (30-min pet walks excepted).
Flag "caregiving" always.`,
  },

  content_creator: {
    slug: 'content_creator',
    displayName: 'Content & Creator',
    defaultRiskTier: 1,
    requiredTrustTier: 'verified',
    completionCriteriaType: 'hybrid',
    autoReleaseHours: 0,  // auto-releases on GPS checkout
    lateCancelPct: 75,
    requiresMutualConsent: true,
    requiresContentRelease: true,
    scoperContext: `TEMPLATE: content_creator
IMPORTANT: IRL in-person talent work. NOT digital labor.
Market rate by audience: <1K $20–$50/hr, 1K–10K $40–$80/hr, 10K–100K $75–$150/hr, 100K+ $150–$400/hr.
Minimum 1-hour billing floor. Travel >30min: +$15–$30 flat.
Specialization premium: competitive gaming +20%, music +30%, subject expertise +25%.
DO NOT price like physical labor. Price like talent.`,
  },

  event_appearance: {
    slug: 'event_appearance',
    displayName: 'Event & Appearance',
    defaultRiskTier: 1,
    requiredTrustTier: 'verified',
    completionCriteriaType: 'check_in_check_out',
    autoReleaseHours: 0,
    lateCancelPct: 100, // 100% if Poster cancels day-of
    requiresMutualConsent: false,
    requiresContentRelease: false,
    scoperContext: `TEMPLATE: event_appearance
Market rate: general staff $18–$28/hr, brand ambassador $22–$35/hr.
Promo model $30–$60/hr. Party host $40–$80/hr. Product demo $28–$45/hr.
Minimum 3-hour booking. Weekend/evening: +15%.
Hustler-sourced professional attire: +$10–$15 flat.`,
  },

  creative_production: {
    slug: 'creative_production',
    displayName: 'Creative Production',
    defaultRiskTier: 1,
    requiredTrustTier: 'verified',
    completionCriteriaType: 'session_completion',
    autoReleaseHours: 0,
    lateCancelPct: 50,
    requiresMutualConsent: false,
    requiresContentRelease: true,
    scoperContext: `TEMPLATE: creative_production
Market rate: photo shoot personal $50–$100, commercial $150–$400.
Video shoot extra half-day $80–$150, principal $150–$300.
Music session $40–$150. Film background $100–$200/day.
Usage rights multiplier: personal 1x, social commercial 1.5x, advertising 2–3x.
Never under $50 for any production task.`,
  },

  specialized_licensed: {
    slug: 'specialized_licensed',
    displayName: 'Specialized / Licensed',
    defaultRiskTier: 1,
    requiredTrustTier: 'trusted',
    completionCriteriaType: 'photo_proof',
    autoReleaseHours: 24,
    lateCancelPct: 0,
    requiresMutualConsent: false,
    requiresContentRelease: false,
    scoperContext: `TEMPLATE: specialized_licensed
Market rate: electrician/plumber $75–$150/hr, HVAC $85–$150/hr.
Notary $15–$30/signing. Personal trainer $50–$100/session.
Licensed massage $60–$100/hr. Tutor $30–$60/hr general, $60–$120/hr specialized.
NEVER under $30/hr. Materials cost is separate — do not include in price.
Flag "license_required" for all trade work.`,
  },

  wildcard_bizarre: {
    slug: 'wildcard_bizarre',
    displayName: 'Wildcard / Custom',
    defaultRiskTier: 1,
    requiredTrustTier: 'verified',
    completionCriteriaType: 'hybrid',
    autoReleaseHours: 48,  // longer review window for bizarre tasks
    lateCancelPct: 75,
    requiresMutualConsent: true,
    requiresContentRelease: false,
    wildcardMultipliers: WILDCARD_MULTIPLIERS,
    scoperContext: `TEMPLATE: wildcard_bizarre
One-off IRL performance/participation gig. Price like talent, NOT labor.
Base rate: $25–$100/hr depending on complexity.
DO NOT estimate a weirdness premium — the system applies deterministic multipliers.
Minimum 2-hour floor. $500 constitutional cap applies after multipliers.
Flag "bizarre_custom" + audience_size + performance_element.`,
  },
};

/**
 * Get template by slug. Falls back to wildcard_bizarre for unknown slugs.
 */
export function getTemplate(slug: string): TaskTemplate {
  return TaskTemplateRegistry[slug as TemplateSlug] ?? TaskTemplateRegistry.wildcard_bizarre;
}

/**
 * Apply deterministic weirdness multipliers to a wildcard base price.
 * Caps total premium at 50%. Final price clamped to MAX_PRICE_CENTS ($500).
 */
export function applyWildcardMultipliers(
  basePriceCents: number,
  activeFlags: string[],
  maxPriceCents = 50000
): number {
  const totalMultiplier = activeFlags
    .filter(f => WILDCARD_MULTIPLIERS[f] !== undefined)
    .reduce((sum, f) => sum + WILDCARD_MULTIPLIERS[f], 0);

  const cappedMultiplier = Math.min(totalMultiplier, MAX_WILDCARD_PREMIUM);
  const raw = Math.round(basePriceCents * (1 + cappedMultiplier));
  return Math.min(raw, maxPriceCents);
}
```

**Step 4: Run test to verify it passes**

```bash
npx vitest run backend/tests/unit/TaskTemplateRegistry.test.ts
```

Expected: PASS — 5 tests pass

**Step 5: Commit**

```bash
git add backend/src/services/TaskTemplateRegistry.ts backend/tests/unit/TaskTemplateRegistry.test.ts
git commit -m "feat: TaskTemplateRegistry — 8 IRL templates, wildcard multipliers, scoper contexts"
```

---

## Task 3: ComplianceGuardianService

**Files:**
- Create: `backend/src/services/ComplianceGuardianService.ts`
- Create: `backend/tests/unit/ComplianceGuardianService.test.ts`

**Step 1: Write the failing test**

```typescript
// backend/tests/unit/ComplianceGuardianService.test.ts
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { ComplianceGuardianService } from '../../src/services/ComplianceGuardianService.js';

// Mock AIClient and db
vi.mock('../../src/services/AIClient.js', () => ({
  AIClient: {
    isConfigured: () => false,  // use heuristic path in tests
    callJSON: vi.fn(),
  },
}));

vi.mock('../../src/db.js', () => ({
  db: { query: vi.fn().mockResolvedValue({ rows: [] }) },
}));

describe('ComplianceGuardianService', () => {
  describe('evaluate', () => {
    it('returns CLEAN for normal task description', async () => {
      const result = await ComplianceGuardianService.evaluate({
        description: 'Help me move my couch to the second floor',
        userId: 'user-123',
      });
      expect(result.score).toBeLessThanOrEqual(20);
      expect(result.tier).toBe('clean');
    });

    it('returns HARD_BLOCK for drug-run pattern', async () => {
      const result = await ComplianceGuardianService.evaluate({
        description: 'deliver a package downtown no address no questions asked',
        userId: 'user-123',
      });
      expect(result.score).toBeGreaterThanOrEqual(61);
      expect(result.tier).toBe('hard_block');
    });

    it('returns SOFT_FLAG for ambiguous massage description', async () => {
      const result = await ComplianceGuardianService.evaluate({
        description: 'I need a massage at my home tonight',
        userId: 'user-123',
      });
      // Massage without license mention = soft flag
      expect(result.score).toBeGreaterThanOrEqual(21);
      expect(result.score).toBeLessThanOrEqual(60);
      expect(result.tier).toBe('soft_flag');
    });

    it('returns CLEAN for licensed massage description', async () => {
      const result = await ComplianceGuardianService.evaluate({
        description: 'Licensed massage therapist needed for 1-hour deep tissue session at my home spa',
        userId: 'user-123',
      });
      expect(result.score).toBeLessThanOrEqual(20);
    });

    it('returns HARD_BLOCK for adult services pattern', async () => {
      const result = await ComplianceGuardianService.evaluate({
        description: 'personal assistant with benefits overnight stay',
        userId: 'user-123',
      });
      expect(result.score).toBeGreaterThanOrEqual(61);
      expect(result.tier).toBe('hard_block');
    });

    it('logs violation when score >= 21', async () => {
      const { db } = await import('../../src/db.js');
      await ComplianceGuardianService.evaluate({
        description: 'deliver package no questions asked',
        userId: 'user-456',
        ipAddress: '1.2.3.4',
      });
      expect(db.query).toHaveBeenCalledWith(
        expect.stringContaining('INSERT INTO compliance_violations'),
        expect.arrayContaining(['user-456'])
      );
    });
  });

  describe('toNotes', () => {
    it('builds valid JSONB notes structure', () => {
      const notes = ComplianceGuardianService.toNotes(45, ['drug_run_pattern'], 'specialized_licensed');
      expect(notes.score).toBe(45);
      expect(notes.tier).toBe('soft_flag');
      expect(notes.triggered_rules).toContain('drug_run_pattern');
      expect(notes.suggested_alternative).toBe('specialized_licensed');
      expect(notes.appeal_status).toBe('none');
    });
  });
});
```

**Step 2: Run test to verify it fails**

```bash
npx vitest run backend/tests/unit/ComplianceGuardianService.test.ts
```

Expected: FAIL — `ComplianceGuardianService` not found

**Step 3: Implement the service**

```typescript
// backend/src/services/ComplianceGuardianService.ts
import { db } from '../db.js';
import { AIClient } from './AIClient.js';
import { logger } from '../logger.js';
import { scrubPII } from '../lib/pii-scrubber.js';

const log = logger.child({ service: 'ComplianceGuardianService' });

// ============================================================================
// TYPES
// ============================================================================

export type ComplianceTier = 'clean' | 'soft_flag' | 'hard_block';

export interface ComplianceResult {
  score: number;          // 0–100
  tier: ComplianceTier;
  triggeredRules: string[];
  suggestedAlternative?: string;
  notes: ComplianceNotes;
}

export interface ComplianceNotes {
  score: number;
  tier: ComplianceTier;
  triggered_rules: string[];
  suggested_alternative: string | null;
  admin_review_id: string | null;
  appeal_status: 'none' | 'pending' | 'approved' | 'rejected';
}

interface EvaluateInput {
  description: string;
  userId: string;
  ipAddress?: string;
  deviceFingerprint?: string;
}

// ============================================================================
// HEURISTIC PATTERNS (used when AI not configured)
// ============================================================================

const HARD_BLOCK_PATTERNS = [
  /no\s+questions?\s+asked/i,
  /discreet\s+(only|delivery|service)/i,
  /with\s+benefits/i,
  /adult\s+(service|entertainment|modeling)/i,
  /happy\s+ending/i,
  /erotic|sexual\s+service/i,
  /unlicensed\s+(medical|legal|therapy)/i,
  /bring\s+your\s+own\s+(gun|weapon|firearm)/i,
  /no\s+address.{0,20}deliver/i,
];

const SOFT_FLAG_PATTERNS = [
  { pattern: /massage/i, rule: 'physical_contact_ambiguous', score: 35 },
  { pattern: /overnight.{0,20}(stay|companion)/i, rule: 'overnight_ambiguous', score: 45 },
  { pattern: /alone.{0,20}(house|home|apartment)/i, rule: 'isolation_flag', score: 30 },
  { pattern: /(notary|legal\s+document).{0,30}(home|house)/i, rule: 'unlicensed_legal', score: 40 },
  { pattern: /medical.{0,20}(advice|treatment|injection)/i, rule: 'unlicensed_medical', score: 50 },
  { pattern: /cash\s+only.{0,20}no\s+record/i, rule: 'unreported_payment', score: 45 },
];

const SUGGESTED_ALTERNATIVES: Record<string, string> = {
  'physical_contact_ambiguous': 'specialized_licensed',
  'unlicensed_medical': 'specialized_licensed',
  'unlicensed_legal': 'specialized_licensed',
};

// ============================================================================
// SERVICE
// ============================================================================

export const ComplianceGuardianService = {
  /**
   * Evaluate a task draft for compliance.
   * Runs server-side only. Client displays result — never runs the check.
   *
   * Precedence: heuristic patterns first (fast), LLM fallback if ambiguous.
   * Violations logged internally for Trust & Safety.
   */
  evaluate: async (input: EvaluateInput): Promise<ComplianceResult> => {
    const { description, userId, ipAddress, deviceFingerprint } = input;

    // Fast heuristic pass first
    const heuristicResult = ComplianceGuardianService._heuristicCheck(description);

    let finalResult = heuristicResult;

    // If heuristic is ambiguous (score 15–50) and AI is configured, use LLM
    if (AIClient.isConfigured() && heuristicResult.score >= 15 && heuristicResult.score <= 50) {
      try {
        finalResult = await ComplianceGuardianService._aiCheck(description, heuristicResult);
      } catch (err) {
        log.warn({ err }, 'AI compliance check failed, using heuristic result');
      }
    }

    const tier = ComplianceGuardianService._scoreTotier(finalResult.score);

    // Log violation for any flagged attempt
    if (finalResult.score >= 21) {
      await ComplianceGuardianService._logViolation({
        userId,
        ipAddress,
        deviceFingerprint,
        description,
        score: finalResult.score,
        triggeredRules: finalResult.triggeredRules,
      });
    }

    const suggestedAlternative = finalResult.triggeredRules
      .map(r => SUGGESTED_ALTERNATIVES[r])
      .find(Boolean) ?? null;

    const notes = ComplianceGuardianService.toNotes(
      finalResult.score,
      finalResult.triggeredRules,
      suggestedAlternative ?? undefined
    );

    return {
      score: finalResult.score,
      tier,
      triggeredRules: finalResult.triggeredRules,
      suggestedAlternative: suggestedAlternative ?? undefined,
      notes,
    };
  },

  /**
   * Build JSONB notes object for storage on task record.
   */
  toNotes: (
    score: number,
    triggeredRules: string[],
    suggestedAlternative?: string
  ): ComplianceNotes => ({
    score,
    tier: ComplianceGuardianService._scoreTotier(score),
    triggered_rules: triggeredRules,
    suggested_alternative: suggestedAlternative ?? null,
    admin_review_id: null,
    appeal_status: 'none',
  }),

  // ============================================================
  // PRIVATE
  // ============================================================

  _scoreTotier: (score: number): ComplianceTier => {
    if (score >= 61) return 'hard_block';
    if (score >= 21) return 'soft_flag';
    return 'clean';
  },

  _heuristicCheck: (description: string): { score: number; triggeredRules: string[] } => {
    // Hard block patterns
    for (const pattern of HARD_BLOCK_PATTERNS) {
      if (pattern.test(description)) {
        return { score: 85, triggeredRules: ['hard_block_pattern'] };
      }
    }

    // Soft flag patterns
    let highestScore = 0;
    const triggeredRules: string[] = [];
    for (const { pattern, rule, score } of SOFT_FLAG_PATTERNS) {
      if (pattern.test(description)) {
        highestScore = Math.max(highestScore, score);
        triggeredRules.push(rule);
      }
    }

    return { score: highestScore, triggeredRules };
  },

  _aiCheck: async (
    description: string,
    heuristic: { score: number; triggeredRules: string[] }
  ): Promise<{ score: number; triggeredRules: string[] }> => {
    const response = await AIClient.callJSON<{ score: number; rules: string[] }>({
      route: 'fast',
      temperature: 0.1,
      timeoutMs: 5000,
      schema: { type: 'object', properties: { score: { type: 'number' }, rules: { type: 'array' } }, required: ['score', 'rules'] },
      systemPrompt: `You are HustleXP's Compliance Guardian. Score this IRL gig task description 0–100 for illegal content.
0–20 = clearly legal IRL gig task
21–60 = ambiguous, needs review (unlicensed professional work, physical contact without license, isolation risk)
61–100 = likely illegal (drugs, adult services, weapons, fraud, exploitation)

PROHIBITED: controlled substances, adult/sexual services, unlicensed medical/legal/notary,
fraud/counterfeit, weapons, animal cruelty, child exploitation, "no questions asked" deliveries.

Return JSON: { "score": number, "rules": string[] }
rules = short snake_case identifiers for what triggered the score.`,
      prompt: scrubPII(description),
    });

    return {
      score: Math.max(heuristic.score, response.data.score),
      triggeredRules: [...new Set([...heuristic.triggeredRules, ...response.data.rules])],
    };
  },

  _logViolation: async (params: {
    userId: string;
    ipAddress?: string;
    deviceFingerprint?: string;
    description: string;
    score: number;
    triggeredRules: string[];
  }) => {
    try {
      await db.query(
        `INSERT INTO compliance_violations
           (user_id, ip_address, device_fingerprint, raw_description, risk_score, triggered_rules)
         VALUES ($1, $2, $3, $4, $5, $6)`,
        [
          params.userId,
          params.ipAddress ?? null,
          params.deviceFingerprint ?? null,
          params.description,
          params.score,
          JSON.stringify(params.triggeredRules),
        ]
      );
    } catch (err) {
      log.error({ err }, 'Failed to log compliance violation');
    }
  },
};
```

**Step 4: Run test to verify it passes**

```bash
npx vitest run backend/tests/unit/ComplianceGuardianService.test.ts
```

Expected: PASS — 6 tests pass

**Step 5: Commit**

```bash
git add backend/src/services/ComplianceGuardianService.ts backend/tests/unit/ComplianceGuardianService.test.ts
git commit -m "feat: ComplianceGuardianService — heuristic + LLM compliance check, violation logging"
```

---

## Task 4: Template-Aware TaskRiskClassifier

**Files:**
- Modify: `backend/src/services/TaskRiskClassifier.ts`
- Modify: `backend/tests/unit/` (add test file `TaskRiskClassifier-template.test.ts`)

**Step 1: Write the failing test**

```typescript
// backend/tests/unit/TaskRiskClassifier-template.test.ts
import { describe, it, expect } from 'vitest';
import { TaskRiskClassifier, TaskRisk } from '../../src/services/TaskRiskClassifier.js';

describe('TaskRiskClassifier — template-aware', () => {
  it('care template always returns TIER_3', () => {
    const risk = TaskRiskClassifier.classifyWithTemplate(
      { insideHome: false, peoplePresent: false, petsPresent: false, caregiving: false },
      'care'
    );
    expect(risk).toBe(TaskRisk.TIER_3);
  });

  it('wildcard_bizarre with private_location_flag bumps to TIER_2', () => {
    const risk = TaskRiskClassifier.classifyWithTemplate(
      { insideHome: false, peoplePresent: false, petsPresent: false, caregiving: false },
      'wildcard_bizarre',
      ['private_location_flag']
    );
    expect(risk).toBe(TaskRisk.TIER_2);
  });

  it('content_creator at private home → TIER_2', () => {
    const risk = TaskRiskClassifier.classifyWithTemplate(
      { insideHome: true, peoplePresent: false, petsPresent: false, caregiving: false },
      'content_creator'
    );
    expect(risk).toBe(TaskRisk.TIER_2);
  });

  it('flags can only increase tier, never decrease', () => {
    // standard_physical default is TIER_0, but caregiving flag bumps it to TIER_3
    const risk = TaskRiskClassifier.classifyWithTemplate(
      { insideHome: false, peoplePresent: true, petsPresent: false, caregiving: false },
      'standard_physical'
    );
    expect(risk).toBe(TaskRisk.TIER_3);
  });

  it('original classifyTaskRisk still works unchanged', () => {
    const risk = TaskRiskClassifier.classifyTaskRisk({
      insideHome: false, peoplePresent: false, petsPresent: false, caregiving: false,
    });
    expect(risk).toBe(TaskRisk.TIER_0);
  });
});
```

**Step 2: Run test to verify it fails**

```bash
npx vitest run backend/tests/unit/TaskRiskClassifier-template.test.ts
```

Expected: FAIL — `classifyWithTemplate` not found

**Step 3: Add `classifyWithTemplate` to TaskRiskClassifier**

Add to `backend/src/services/TaskRiskClassifier.ts` after the existing `classifyTaskRisk` method:

```typescript
// Template minimum risk tiers (flags can only raise, never lower)
const TEMPLATE_MIN_TIERS: Record<string, TaskRisk> = {
  standard_physical:    TaskRisk.TIER_0,
  in_home:              TaskRisk.TIER_2,
  care:                 TaskRisk.TIER_3,
  content_creator:      TaskRisk.TIER_1,
  event_appearance:     TaskRisk.TIER_1,
  creative_production:  TaskRisk.TIER_1,
  specialized_licensed: TaskRisk.TIER_1,
  wildcard_bizarre:     TaskRisk.TIER_1,
};

// Add this method to the TaskRiskClassifier object:
classifyWithTemplate: (
  input: TaskRiskInput,
  templateSlug: string,
  activeFlags: string[] = []
): TaskRisk => {
  // Start with base boolean-flag classification
  const baseRisk = TaskRiskClassifier.classifyTaskRisk(input);

  // Apply template minimum tier
  const templateMin = TEMPLATE_MIN_TIERS[templateSlug] ?? TaskRisk.TIER_1;

  // private_location_flag bumps wildcard to TIER_2
  const flagBump = activeFlags.includes('private_location_flag') ? TaskRisk.TIER_2 : TaskRisk.TIER_0;

  // Flags can only raise, never lower
  return Math.max(baseRisk, templateMin, flagBump) as TaskRisk;
},
```

**Step 4: Run test to verify it passes**

```bash
npx vitest run backend/tests/unit/TaskRiskClassifier-template.test.ts
```

Expected: PASS — 5 tests pass

**Step 5: Commit**

```bash
git add backend/src/services/TaskRiskClassifier.ts backend/tests/unit/TaskRiskClassifier-template.test.ts
git commit -m "feat: TaskRiskClassifier.classifyWithTemplate — template-aware risk, flags only raise tier"
```

---

## Task 5: Template-Aware ScoperAI + Wildcard Multipliers

**Files:**
- Modify: `backend/src/services/ScoperAIService.ts`
- Create: `backend/tests/unit/ScoperAI-template.test.ts`

**Step 1: Write the failing test**

```typescript
// backend/tests/unit/ScoperAI-template.test.ts
import { describe, it, expect, vi } from 'vitest';
import { ScoperAIService } from '../../src/services/ScoperAIService.js';

vi.mock('../../src/services/AIClient.js', () => ({
  AIClient: { isConfigured: () => false },
}));

describe('ScoperAI — template-aware pricing', () => {
  it('wildcard with performance_element_flag applies 20% multiplier', async () => {
    const result = await ScoperAIService.analyzeTaskScope({
      description: 'Be a human statue at my art event for 3 hours',
      templateSlug: 'wildcard_bizarre',
      wildcardFlags: ['performance_element_flag'],
    });
    expect(result.success).toBe(true);
    // base heuristic ~$75 (hard task) × 1.20 = $90, within $500 cap
    expect(result.data!.suggested_price_cents).toBeGreaterThan(7500);
  });

  it('wildcard with all flags capped at 50% premium', async () => {
    const result = await ScoperAIService.analyzeTaskScope({
      description: 'Wear a costume and perform at a private venue for 4 hours',
      templateSlug: 'wildcard_bizarre',
      wildcardFlags: [
        'private_location_flag',
        'props_required_flag',
        'performance_element_flag',
        'audience_present_flag',
        'costume_or_attire_flag',
        'travel_over_30min_flag',
      ],
    });
    // Total flags = 85%, capped at 50%
    expect(result.success).toBe(true);
    const price = result.data!.suggested_price_cents;
    expect(price).toBeLessThanOrEqual(50000); // never exceeds $500
  });

  it('template context injected into system prompt for content_creator', async () => {
    // Verify the template scoperContext is in the prompt by checking pricing reflects talent rates
    const result = await ScoperAIService.analyzeTaskScope({
      description: 'Be a guest on my gaming stream for 2 hours, audience is 50K',
      templateSlug: 'content_creator',
    });
    expect(result.success).toBe(true);
    // Should price significantly higher than physical labor rate for same duration
    expect(result.data!.suggested_price_cents).toBeGreaterThan(5000); // > $50
  });
});
```

**Step 2: Run test to verify it fails**

```bash
npx vitest run backend/tests/unit/ScoperAI-template.test.ts
```

Expected: FAIL — `templateSlug` not accepted by `analyzeTaskScope`

**Step 3: Modify `ScoperAIService.analyzeTaskScope`**

Update `ScoperInput` interface and `analyzeTaskScope` in `backend/src/services/ScoperAIService.ts`:

```typescript
// Add to ScoperInput interface:
interface ScoperInput {
  description: string;
  category?: string;
  budget_hint_cents?: number;
  location?: { city: string; state: string; zip_code?: string; };
  templateSlug?: string;       // NEW
  wildcardFlags?: string[];    // NEW — for wildcard_bizarre only
}
```

In `analyzeTaskScope`, inject template context into system prompt and apply multipliers after validation:

```typescript
// Import at top of file:
import { getTemplate, applyWildcardMultipliers, TEMPLATE_SLUGS } from './TaskTemplateRegistry.js';

// In analyzeTaskScope, before calling AIClient.callJSON:
const template = input.templateSlug ? getTemplate(input.templateSlug) : null;
const templateContext = template ? `\n\n${template.scoperContext}` : '';

// Modify systemPrompt to append templateContext:
systemPrompt: `You are HustleXP's Scoper Agent (A2 authority - proposal only).
Analyze task descriptions and propose pricing, XP rewards, and difficulty.
Your proposals are validated by deterministic constitutional rules — you cannot override them.

CONSTITUTIONAL BOUNDS:
- Price: $15–$500 (1500–50000 cents)
- XP: price_cents / 10 (±20% tolerance)
- Difficulty tiers: easy ($15–$50), medium ($50–$150), hard ($150–$500)
- Confidence threshold: >= 0.60 (below requires human review)
${templateContext}
...`,

// After _validateProposal passes, apply wildcard multipliers if applicable:
if (
  input.templateSlug === TEMPLATE_SLUGS.WILDCARD_BIZARRE &&
  input.wildcardFlags?.length
) {
  proposal.suggested_price_cents = applyWildcardMultipliers(
    proposal.suggested_price_cents,
    input.wildcardFlags
  );
  // Re-validate after multiplier (catches XP drift)
  const revalidation = ScoperAIService._validateProposal(proposal);
  if (!revalidation.valid) {
    // Clamp XP to match new price
    proposal.suggested_xp = Math.round(proposal.suggested_price_cents / 10);
  }
}
```

Also update `_generateProposal` heuristic to accept templateSlug and use template min price floor.

**Step 4: Run test to verify it passes**

```bash
npx vitest run backend/tests/unit/ScoperAI-template.test.ts
```

Expected: PASS — 3 tests pass

**Step 5: Commit**

```bash
git add backend/src/services/ScoperAIService.ts backend/tests/unit/ScoperAI-template.test.ts
git commit -m "feat: ScoperAI template-aware pricing — context injection + deterministic wildcard multipliers"
```

---

## Task 6: New tRPC Schemas + Procedures

**Files:**
- Modify: `backend/src/trpc.ts` (add schemas)
- Modify: `backend/src/routers/task.ts` (add 3 new procedures)
- Modify: `backend/src/routers/index.ts` (no change needed — task router already exported)

**Step 1: Add schemas to `backend/src/trpc.ts`**

After the existing `createTask` schema, add:

```typescript
evaluateDraft: z.object({
  description: z.string().min(10).max(5000),
  templateSlug: z.string().max(50).optional(),
}),

acceptWithConsent: z.object({
  taskId: z.string().uuid(),
  consentItems: z.array(z.string()).min(5).max(5),  // exactly 5 checklist items
}),
```

**Step 2: Add `task.evaluateDraft` procedure to `backend/src/routers/task.ts`**

```typescript
/**
 * Evaluate a task draft for compliance before creation.
 * Fires when Poster taps "Preview Task". Client surfaces result only.
 * HARD_BLOCK (score ≥ 61): returns error, no task created.
 * SOFT_FLAG (score 21–60): returns result with tier for Poster awareness.
 */
evaluateDraft: posterProcedure
  .input(Schemas.evaluateDraft)
  .mutation(async ({ ctx, input }) => {
    const result = await ComplianceGuardianService.evaluate({
      description: input.description,
      userId: ctx.user.id,
      ipAddress: ctx.req?.ip,
    });

    if (result.tier === 'hard_block') {
      throw new TRPCError({
        code: 'BAD_REQUEST',
        message: `This task was blocked. Reason: ${result.triggeredRules.join(', ')}. HustleXP only allows legal IRL tasks.`,
      });
    }

    return {
      score: result.score,
      tier: result.tier,
      triggeredRules: result.triggeredRules,
      suggestedAlternative: result.suggestedAlternative,
      notes: result.notes,
    };
  }),

/**
 * Accept a task with mutual consent checklist.
 * Required for wildcard_bizarre and content_creator templates.
 */
acceptWithConsent: hustlerProcedure
  .input(Schemas.acceptWithConsent)
  .mutation(async ({ ctx, input }) => {
    const taskResult = await db.query<{
      template_slug: string;
      state: string;
    }>(
      `SELECT template_slug, state FROM tasks WHERE id = $1`,
      [input.taskId]
    );

    if (!taskResult.rows[0]) {
      throw new TRPCError({ code: 'NOT_FOUND', message: 'Task not found' });
    }

    const task = taskResult.rows[0];
    const template = getTemplate(task.template_slug);

    if (!template.requiresMutualConsent) {
      throw new TRPCError({
        code: 'BAD_REQUEST',
        message: 'This template does not require consent checklist',
      });
    }

    if (input.consentItems.length !== 5) {
      throw new TRPCError({
        code: 'BAD_REQUEST',
        message: 'Mutual consent checklist requires exactly 5 items',
      });
    }

    await db.query(
      `UPDATE tasks
       SET mutual_consent_accepted = TRUE,
           worker_id = $2,
           state = 'claimed',
           accepted_at = NOW()
       WHERE id = $1 AND state = 'posted'`,
      [input.taskId, ctx.user.id]
    );

    return { accepted: true };
  }),

/**
 * Get compliance status for a task — Hustler-facing, no new LLM call.
 * Surfaces existing illegal_risk_score + compliance_guardian_notes.
 */
getComplianceStatus: protectedProcedure
  .input(z.object({ taskId: z.string().uuid() }))
  .query(async ({ input }) => {
    const result = await db.query<{
      illegal_risk_score: number;
      compliance_guardian_notes: object;
    }>(
      `SELECT illegal_risk_score, compliance_guardian_notes FROM tasks WHERE id = $1`,
      [input.taskId]
    );

    if (!result.rows[0]) {
      throw new TRPCError({ code: 'NOT_FOUND', message: 'Task not found' });
    }

    return {
      score: result.rows[0].illegal_risk_score,
      notes: result.rows[0].compliance_guardian_notes,
    };
  }),
```

**Step 3: Update `task.create` to run compliance check and store template fields**

In the existing `create` procedure in `backend/src/routers/task.ts`, before the INSERT:

```typescript
// 1. Run compliance check (hard blocks throw before any DB write)
const compliance = await ComplianceGuardianService.evaluate({
  description: input.description,
  userId: ctx.user.id,
});
if (compliance.tier === 'hard_block') {
  throw new TRPCError({ code: 'BAD_REQUEST', message: 'Task blocked by compliance check' });
}

// 2. Classify risk with template awareness
const template = getTemplate(input.templateSlug ?? 'standard_physical');
const riskTier = TaskRiskClassifier.classifyWithTemplate(
  {
    insideHome: input.insideHome ?? false,
    peoplePresent: input.peoplePresent ?? false,
    petsPresent: input.petsPresent ?? false,
    caregiving: template.slug === 'care',
  },
  template.slug,
  input.wildcardFlags ?? []
);
const riskLevel = TaskRiskClassifier.toLegacyRiskLevel(riskTier);

// 3. Add to INSERT: template_slug, illegal_risk_score, compliance_guardian_notes,
//    late_cancel_pct, content_release, cancellation_window_hours
```

**Step 4: Run full test suite**

```bash
npx vitest run --reporter=verbose 2>&1 | tail -20
```

Expected: all existing tests pass, no regressions

**Step 5: Commit**

```bash
git add backend/src/trpc.ts backend/src/routers/task.ts
git commit -m "feat(task): evaluateDraft, acceptWithConsent, getComplianceStatus procedures + template-aware create"
```

---

## Task 7: ProofService — Criteria-Type-Aware Validation

**Files:**
- Modify: `backend/src/services/ProofService.ts`
- Create: `backend/tests/unit/ProofService-criteria.test.ts`

**Step 1: Write the failing test**

```typescript
// backend/tests/unit/ProofService-criteria.test.ts
import { describe, it, expect, vi } from 'vitest';
import { ProofService } from '../../src/services/ProofService.js';

vi.mock('../../src/db.js', () => ({
  db: {
    query: vi.fn().mockImplementation((sql: string) => {
      if (sql.includes('SELECT') && sql.includes('tasks')) {
        return { rows: [{ completion_criteria: { type: 'check_in_check_out' }, state: 'in_progress' }] };
      }
      return { rows: [] };
    }),
  },
}));

describe('ProofService — criteria-type validation', () => {
  it('check_in_check_out criteria requires GPS timestamps', async () => {
    const result = await ProofService.validateProofForCriteria('task-123', {
      type: 'check_in_check_out',
      checkInAt: null,
      checkOutAt: new Date().toISOString(),
    });
    expect(result.valid).toBe(false);
    expect(result.reason).toContain('GPS check-in');
  });

  it('photo_proof criteria requires at least one photo', async () => {
    const result = await ProofService.validateProofForCriteria('task-123', {
      type: 'photo_proof',
      photoUrls: [],
    });
    expect(result.valid).toBe(false);
    expect(result.reason).toContain('photo');
  });

  it('session_completion requires both-party confirmation', async () => {
    const result = await ProofService.validateProofForCriteria('task-123', {
      type: 'session_completion',
      hustlerConfirmed: true,
      posterConfirmed: false,
    });
    expect(result.valid).toBe(false);
    expect(result.reason).toContain('Poster');
  });
});
```

**Step 2: Run test to verify it fails**

```bash
npx vitest run backend/tests/unit/ProofService-criteria.test.ts
```

Expected: FAIL — `validateProofForCriteria` not found

**Step 3: Add `validateProofForCriteria` to ProofService**

```typescript
// Add to ProofService in backend/src/services/ProofService.ts:

validateProofForCriteria: async (
  taskId: string,
  proof: {
    type: 'photo_proof' | 'check_in_check_out' | 'session_completion' | 'hybrid';
    photoUrls?: string[];
    checkInAt?: string | null;
    checkOutAt?: string | null;
    hustlerConfirmed?: boolean;
    posterConfirmed?: boolean;
  }
): Promise<{ valid: boolean; reason?: string }> => {
  switch (proof.type) {
    case 'photo_proof':
      if (!proof.photoUrls?.length) {
        return { valid: false, reason: 'At least one photo is required for proof submission.' };
      }
      return { valid: true };

    case 'check_in_check_out':
      if (!proof.checkInAt) {
        return { valid: false, reason: 'GPS check-in timestamp is required.' };
      }
      if (!proof.checkOutAt) {
        return { valid: false, reason: 'GPS check-out timestamp is required.' };
      }
      return { valid: true };

    case 'session_completion':
      if (!proof.hustlerConfirmed) {
        return { valid: false, reason: 'Hustler must confirm session completion.' };
      }
      if (!proof.posterConfirmed) {
        return { valid: false, reason: 'Poster must confirm session completion before payment releases.' };
      }
      return { valid: true };

    case 'hybrid':
      // Requires check-in/out at minimum; bonus proof items are optional
      if (!proof.checkInAt || !proof.checkOutAt) {
        return { valid: false, reason: 'GPS check-in and check-out are required for this task type.' };
      }
      return { valid: true };

    default:
      return { valid: true };
  }
},
```

**Step 4: Run test to verify it passes**

```bash
npx vitest run backend/tests/unit/ProofService-criteria.test.ts
```

Expected: PASS — 3 tests pass

**Step 5: Commit**

```bash
git add backend/src/services/ProofService.ts backend/tests/unit/ProofService-criteria.test.ts
git commit -m "feat: ProofService.validateProofForCriteria — type-aware proof validation (photo/GPS/session/hybrid)"
```

---

## Task 8: iOS TaskCategory Enum Expansion

**Files:**
- Modify: `HUSTLEXPFINAL1/hustleXP final1/Models/AIPricing.swift`

**Step 1: Add 8 new cases to TaskCategory enum**

In `AIPricing.swift`, update the enum:

```swift
enum TaskCategory: String, Codable, CaseIterable {
    // Existing
    case delivery = "delivery"
    case moving = "moving"
    case cleaning = "cleaning"
    case yardWork = "yard_work"
    case assembly = "assembly"
    case petCare = "pet_care"
    case shopping = "shopping"
    case tech = "tech"
    // New — template-aligned
    case contentCreator = "content_creator"
    case eventAppearance = "event_appearance"
    case creativeProduction = "creative_production"
    case specializedLicensed = "specialized_licensed"
    case childcare = "childcare"
    case elderCare = "elder_care"
    case handyman = "handyman"
    case wildcardBizarre = "wildcard_bizarre"
    // Catch-all
    case other = "other"
}
```

Update `displayName`:

```swift
var displayName: String {
    switch self {
    case .delivery:            return "Delivery"
    case .moving:              return "Moving"
    case .cleaning:            return "Cleaning"
    case .yardWork:            return "Yard Work"
    case .assembly:            return "Assembly"
    case .petCare:             return "Pet Care"
    case .shopping:            return "Shopping"
    case .tech:                return "Tech Help"
    case .contentCreator:      return "Content & Creator"
    case .eventAppearance:     return "Event & Appearance"
    case .creativeProduction:  return "Creative Production"
    case .specializedLicensed: return "Specialized / Licensed"
    case .childcare:           return "Childcare"
    case .elderCare:           return "Elder Care"
    case .handyman:            return "Handyman"
    case .wildcardBizarre:     return "Wildcard / Custom"
    case .other:               return "Other"
    }
}

// Map category → template slug for backend
var templateSlug: String {
    switch self {
    case .delivery, .moving, .assembly, .shopping, .yardWork: return "standard_physical"
    case .cleaning, .handyman:                                  return "in_home"
    case .petCare, .childcare, .elderCare:                      return "care"
    case .contentCreator:                                       return "content_creator"
    case .eventAppearance:                                      return "event_appearance"
    case .creativeProduction:                                   return "creative_production"
    case .specializedLicensed, .tech:                          return "specialized_licensed"
    case .wildcardBizarre, .other:                             return "wildcard_bizarre"
    }
}
```

**Step 2: Build the iOS app**

```bash
cd /Users/sebastiandysart/HustleXP/HUSTLEXPFINAL1
xcodebuild -scheme "hustleXP final1" -destination "platform=iOS Simulator,name=iPhone 16" build 2>&1 | grep -E "BUILD|error:|warning:" | head -30
```

Expected: `BUILD SUCCEEDED`

**Step 3: Commit**

```bash
cd /Users/sebastiandysart/HustleXP/HUSTLEXPFINAL1
git add "hustleXP final1/Models/AIPricing.swift"
git commit -m "feat(ios): expand TaskCategory enum — 8 new template-aligned categories + templateSlug mapping"
```

---

## Task 9: iOS AI Task Creation — Template Picker

**Files:**
- Modify: `HUSTLEXPFINAL1/hustleXP final1/Screens/Poster/AITaskCreationScreen.swift`
- Modify: `HUSTLEXPFINAL1/hustleXP final1/Services/AIConversationService.swift`

**Step 1: Add template detection to AIConversationService**

Add `detectTemplate(from description: String) -> TaskCategory` method:

```swift
func detectTemplate(from description: String) -> TaskCategory {
    let lower = description.lowercased()
    // Content creator signals
    if lower.contains("stream") || lower.contains("youtube") || lower.contains("tiktok") ||
       lower.contains("podcast") || lower.contains("collab") || lower.contains("gaming") {
        return .contentCreator
    }
    // Care signals
    if lower.contains("babysit") || lower.contains("childcare") || lower.contains("dog walk") ||
       lower.contains("pet sit") || lower.contains("elder") {
        return lower.contains("pet") ? .petCare : .childcare
    }
    // Event signals
    if lower.contains("event") || lower.contains("party") || lower.contains("ambassador") ||
       lower.contains("promoter") || lower.contains("mascot") {
        return .eventAppearance
    }
    // Creative production
    if lower.contains("photo shoot") || lower.contains("video shoot") || lower.contains("model") ||
       lower.contains("recording session") {
        return .creativeProduction
    }
    // Licensed/specialized
    if lower.contains("electrician") || lower.contains("plumber") || lower.contains("notary") ||
       lower.contains("tutor") || lower.contains("trainer") || lower.contains("licensed") {
        return .specializedLicensed
    }
    // In-home
    if lower.contains("clean") || lower.contains("repair") || lower.contains("handyman") ||
       lower.contains("paint") {
        return lower.contains("clean") ? .cleaning : .handyman
    }
    // Wildcard — anything weird that doesn't fit
    let wordCount = description.split(separator: " ").count
    if wordCount > 4 && !lower.contains("deliver") && !lower.contains("move") &&
       !lower.contains("assemble") {
        return .wildcardBizarre
    }
    return .other
}
```

**Step 2: Add template badge to AITaskCreationScreen**

After template detection fires, show inline badge:
```swift
// In AITaskCreationScreen, after processUserInput():
let detected = aiService.detectTemplate(from: userInput)
if detected != .other {
    taskDraft.category = detected
    // Show template badge: "✦ Detected: Content & Creator template"
}
```

**Step 3: Add wildcard 3-question flow**

When `taskDraft.category == .wildcardBizarre`, after initial description captured, inject 3 AI follow-up questions:
```swift
// In AIConversationService.processUserInput() for wildcard path:
if currentDraft.category == .wildcardBizarre && followUpStep == 0 {
    return (updatedDraft, AIConversationMessage(
        content: "What's the weirdest or most unusual part of this task?",
        isFromAI: true
    ))
}
if currentDraft.category == .wildcardBizarre && followUpStep == 1 {
    return (updatedDraft, AIConversationMessage(
        content: "What specific proof would make you 100% satisfied this is done?",
        isFromAI: true
    ))
}
```

**Step 4: Build and verify**

```bash
xcodebuild -scheme "hustleXP final1" -destination "platform=iOS Simulator,name=iPhone 16" build 2>&1 | grep -E "BUILD|error:" | head -20
```

Expected: `BUILD SUCCEEDED`

**Step 5: Commit**

```bash
cd /Users/sebastiandysart/HustleXP/HUSTLEXPFINAL1
git add "hustleXP final1/Screens/Poster/AITaskCreationScreen.swift" "hustleXP final1/Services/AIConversationService.swift"
git commit -m "feat(ios): template detector + wildcard 3-question flow in AI task creation"
```

---

## Task 10: Run Full Test Suite + Health Check

**Step 1: Run full backend test suite**

```bash
cd /Users/sebastiandysart/Desktop/hustlexp-ai-backend
npx vitest run 2>&1 | tail -15
```

Expected: all tests pass, coverage ≥ 88.88%

**Step 2: Run omni-link health**

```bash
node /Users/sebastiandysart/omni-link-hustlexp/dist/cli.js health
```

Expected: ecosystem overall ≥ 97

**Step 3: Final commit on docs**

```bash
cd /Users/sebastiandysart/HustleXP/HUSTLEXP-DOCS
git add docs/plans/2026-03-16-ai-task-template-system.md
git commit -m "docs: AI task template system v2.1 implementation plan"
```

---

Plan complete and saved to `docs/plans/2026-03-16-ai-task-template-system.md`.

**Two execution options:**

**1. Subagent-Driven (this session)** — Fresh subagent per task, review between tasks, fast iteration

**2. Parallel Session (separate)** — Open new session with executing-plans, batch execution with checkpoints

Which approach?
