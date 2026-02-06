# Scoper AI Agent Specification

**Status:** 🔒 LOCKED
**Version:** 1.0
**Authority Level:** A2 (Proposal-Only)
**Layer:** 3 (AI Decision Layer)

---

## 1. Purpose & Scope

The **Scoper AI Agent** analyzes task descriptions submitted by posters and generates pricing, XP reward, and difficulty proposals. It operates at **Authority Level A2**, meaning it can only propose values—final decisions are made by deterministic validators enforcing constitutional rules.

### Core Responsibilities

1. **Task Analysis**: Parse natural language task descriptions to extract:
   - Task category (delivery, moving, cleaning, handyman, etc.)
   - Complexity indicators (square footage, item count, time estimates)
   - Special requirements (tools needed, vehicle required, certifications)

2. **Pricing Proposal**: Suggest fair market price range based on:
   - Task category benchmarks
   - Estimated time/effort
   - Local market rates
   - Complexity factors

3. **XP Reward Calculation**: Propose XP based on:
   - Base formula: `XP = price_cents / 10` (100 XP per dollar)
   - Difficulty multipliers
   - Category-specific adjustments

4. **Difficulty Rating**: Classify tasks as:
   - **Easy**: Simple, low-skill tasks ($15-$50)
   - **Medium**: Moderate skill/effort ($50-$150)
   - **Hard**: High-skill or multi-hour tasks ($150-$500)

### Authority Constraints

- **CANNOT** directly set `task.price_cents` or `task.xp_reward`
- **MUST** log all proposals to `ai_agent_decisions` table
- **MUST** provide reasoning for transparency
- **MUST** operate within constitutional price bounds ($15-$500)
- All proposals validated by deterministic rules before acceptance

---

## 2. Input Schema

```typescript
interface ScoperInput {
  description: string;           // Raw task description from poster
  category?: string;              // Optional category hint (delivery, moving, etc.)
  budget_hint_cents?: number;     // Optional budget from poster
  location?: {                    // Optional location context
    city: string;
    state: string;
    zip_code: string;
  };
  poster_trust_tier?: number;     // Poster's trust level (0-4)
}
```

### Example Inputs

```json
{
  "description": "Move 15 boxes of books from my apartment (2nd floor, no elevator) to storage unit 3 miles away. Should take about 2 hours. Need someone with a truck.",
  "category": "moving",
  "location": { "city": "Austin", "state": "TX", "zip_code": "78701" }
}
```

---

## 3. Output Schema (Proposal)

```typescript
interface ScoperProposal {
  suggested_price_cents: number;      // $15-$500 (1500-50000 cents)
  price_reasoning: string;             // Human-readable explanation

  suggested_xp: number;                // Calculated from price
  xp_reasoning: string;

  difficulty: 'easy' | 'medium' | 'hard';
  difficulty_reasoning: string;

  confidence_score: number;            // 0.0-1.0
  flags: string[];                     // ['vehicle_required', 'heavy_lifting', etc.]

  estimated_duration_minutes?: number; // Optional time estimate
  required_capabilities?: string[];    // ['vehicle', 'strength', 'tools']
}
```

### Example Output

```json
{
  "suggested_price_cents": 8000,
  "price_reasoning": "2-hour moving job with 15 boxes, 2nd floor walk-up, 3-mile transport. Local market rate: $35-$45/hr. Suggested: $80 (mid-range).",

  "suggested_xp": 800,
  "xp_reasoning": "Base XP: 800 (100 XP per dollar). No difficulty multiplier applied for medium-difficulty task.",

  "difficulty": "medium",
  "difficulty_reasoning": "Requires vehicle, moderate physical effort (2nd floor, 15 boxes), but straightforward logistics.",

  "confidence_score": 0.85,
  "flags": ["vehicle_required", "moderate_lifting", "multi_location"],

  "estimated_duration_minutes": 120,
  "required_capabilities": ["vehicle", "strength"]
}
```

---

## 4. Constitutional Validation Rules

After the Scoper generates a proposal, a **deterministic validator** applies these hard rules:

### Rule 1: Price Bounds
```typescript
if (proposal.suggested_price_cents < 1500) {
  throw new Error('SCOPER-ERR-001: Price below minimum ($15)');
}
if (proposal.suggested_price_cents > 50000) {
  throw new Error('SCOPER-ERR-002: Price above maximum ($500)');
}
```

### Rule 2: XP Calculation Validation
```typescript
const expected_xp = Math.round(proposal.suggested_price_cents / 10);
const xp_tolerance = expected_xp * 0.20; // ±20% tolerance

if (Math.abs(proposal.suggested_xp - expected_xp) > xp_tolerance) {
  throw new Error('SCOPER-ERR-003: XP deviates >20% from price formula');
}
```

### Rule 3: Difficulty Alignment
```typescript
const difficulty_map = {
  easy: { min: 1500, max: 5000 },     // $15-$50
  medium: { min: 5000, max: 15000 },   // $50-$150
  hard: { min: 15000, max: 50000 }     // $150-$500
};

const range = difficulty_map[proposal.difficulty];
if (proposal.suggested_price_cents < range.min || proposal.suggested_price_cents > range.max) {
  // Adjust difficulty to match price tier
  proposal.difficulty = determineDifficultyFromPrice(proposal.suggested_price_cents);
}
```

### Rule 4: Confidence Threshold
```typescript
if (proposal.confidence_score < 0.60) {
  throw new Error('SCOPER-ERR-004: Confidence too low, require human review');
}
```

### Rule 5: Reasoning Required
```typescript
if (!proposal.price_reasoning || proposal.price_reasoning.length < 20) {
  throw new Error('SCOPER-ERR-005: Missing or insufficient price reasoning');
}
```

---

## 5. Implementation Flow

```
┌─────────────────┐
│ Poster submits  │
│ task description│
└────────┬────────┘
         │
         v
┌─────────────────────┐
│ TaskService.create()│
└────────┬────────────┘
         │
         v
┌──────────────────────────┐
│ ScoperAIService.         │
│ analyzeTaskScope(input)  │
└────────┬─────────────────┘
         │
         v
┌──────────────────────────┐
│ Generate proposal via    │
│ LLM (GPT-4o, Claude 3.5) │
└────────┬─────────────────┘
         │
         v
┌──────────────────────────┐
│ Log to ai_agent_decisions│
│ (authority_level='A2')   │
└────────┬─────────────────┘
         │
         v
┌──────────────────────────┐
│ Deterministic validator  │
│ applies Rules 1-5        │
└────────┬─────────────────┘
         │
    ┌────┴────┐
    │         │
 PASS       FAIL
    │         │
    v         v
┌───────┐  ┌──────────┐
│ Accept│  │  Reject  │
│proposal│  │ + notify │
└───┬───┘  └──────────┘
    │
    v
┌──────────────────┐
│ Set task.price,  │
│ task.xp_reward   │
└──────────────────┘
```

---

## 6. Database Schema Integration

### ai_agent_decisions Table

```sql
CREATE TABLE ai_agent_decisions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  agent_type TEXT NOT NULL CHECK (agent_type = 'scoper'),
  task_id UUID REFERENCES tasks(id) ON DELETE CASCADE,

  proposal JSONB NOT NULL,          -- Full ScoperProposal JSON
  confidence_score DECIMAL(5,4) CHECK (confidence_score >= 0 AND confidence_score <= 1),
  reasoning TEXT NOT NULL,

  accepted BOOLEAN,                  -- NULL if pending, TRUE/FALSE after validation
  validator_override BOOLEAN DEFAULT FALSE,
  validator_reason TEXT,

  authority_level TEXT NOT NULL DEFAULT 'A2' CHECK (authority_level = 'A2'),

  created_at TIMESTAMPTZ DEFAULT NOW(),
  decided_at TIMESTAMPTZ,
  decided_by UUID REFERENCES users(id)
);
```

### Logged Record Example

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "agent_type": "scoper",
  "task_id": "7c9e6679-7425-40de-944b-e07fc1f90ae7",
  "proposal": {
    "suggested_price_cents": 8000,
    "price_reasoning": "...",
    "suggested_xp": 800,
    "difficulty": "medium",
    "confidence_score": 0.85
  },
  "accepted": true,
  "authority_level": "A2",
  "created_at": "2026-02-06T10:30:00Z",
  "decided_at": "2026-02-06T10:30:01Z"
}
```

---

## 7. Prompt Engineering

### System Prompt (LLM)

```
You are the Scoper AI Agent for HustleXP, a gig marketplace platform.

Your role: Analyze task descriptions and propose fair pricing, XP rewards, and difficulty ratings.

Constitutional rules (NEVER VIOLATE):
- Price range: $15-$500 USD only
- XP formula: 100 XP per $1 earned (±20% allowed)
- Difficulty tiers:
  - Easy: $15-$50 (simple, <1 hour, no special skills)
  - Medium: $50-$150 (moderate skill/time, may need tools/vehicle)
  - Hard: $150-$500 (high skill, multi-hour, certifications/insurance)

Response format: JSON with fields:
- suggested_price_cents (1500-50000)
- price_reasoning (explain your calculation)
- suggested_xp (based on price)
- xp_reasoning
- difficulty (easy/medium/hard)
- difficulty_reasoning
- confidence_score (0.0-1.0)
- flags (array of relevant tags)
- estimated_duration_minutes (optional)
- required_capabilities (array, e.g., ['vehicle', 'tools'])

Be conservative with pricing. Always explain your reasoning clearly.
```

### User Prompt Template

```
Task description: "{description}"
Category: {category || "unspecified"}
Location: {location.city}, {location.state}
Poster trust tier: {poster_trust_tier}/4

Analyze this task and propose pricing, XP, and difficulty. Consider:
1. Time estimate (hours)
2. Skill level required
3. Physical effort
4. Tools/vehicle needs
5. Local market rates for {category} tasks
6. Safety/liability factors

Return JSON proposal.
```

---

## 8. Edge Cases & Fallbacks

### Edge Case 1: Ambiguous Description
**Example:** "Need help with some stuff"

**Response:**
```json
{
  "suggested_price_cents": null,
  "error": "SCOPER-AMBIGUOUS-001: Description too vague for pricing. Requires clarification.",
  "confidence_score": 0.0,
  "flags": ["ambiguous_description"],
  "suggested_questions": [
    "What type of task is this? (moving, delivery, cleaning, etc.)",
    "How long do you estimate this will take?",
    "What tools or equipment are needed?"
  ]
}
```

### Edge Case 2: Out-of-Scope Task
**Example:** "Drive me to the airport every day for a month"

**Response:**
```json
{
  "suggested_price_cents": null,
  "error": "SCOPER-OUT-OF-SCOPE-002: Task appears to be ongoing/recurring. Platform supports one-time gigs only.",
  "confidence_score": 0.0,
  "flags": ["recurring_task", "out_of_scope"]
}
```

### Edge Case 3: Illegal/Unsafe Task
**Example:** "Help me move this safe out of my office building at 2 AM"

**Response:**
```json
{
  "suggested_price_cents": null,
  "error": "SCOPER-SAFETY-003: Task raises safety/legal concerns. Requires admin review.",
  "confidence_score": 0.0,
  "flags": ["safety_concern", "suspicious_timing"],
  "reason": "Unusual timing and request pattern suggest potential illegal activity."
}
```

### Fallback Strategy

If Scoper AI fails (API timeout, low confidence, errors):
1. Log failure to `ai_agent_decisions` with `accepted = FALSE`
2. Notify poster: "Unable to auto-price your task. Please set a price manually."
3. Allow poster to manually enter price (subject to $15-$500 bounds)
4. Require admin review for manual pricing (fraud prevention)

---

## 9. Performance Metrics

Track these metrics for Scoper AI quality:

| Metric | Target | Measurement |
|--------|--------|-------------|
| **Acceptance Rate** | >85% | `accepted = TRUE` / total proposals |
| **Confidence Score (avg)** | >0.75 | Mean of all `confidence_score` values |
| **Price Deviation** | <15% | Difference between Scoper price and final negotiated price |
| **Poster Override Rate** | <20% | % of tasks where poster manually changes Scoper price |
| **Response Time** | <3 seconds | P95 latency for `analyzeTaskScope()` call |

### Monitoring Query

```sql
-- Scoper AI performance dashboard
SELECT
  COUNT(*) as total_proposals,
  AVG(confidence_score) as avg_confidence,
  SUM(CASE WHEN accepted = TRUE THEN 1 ELSE 0 END)::FLOAT / COUNT(*) as acceptance_rate,
  AVG(EXTRACT(EPOCH FROM (decided_at - created_at))) as avg_decision_time_seconds
FROM ai_agent_decisions
WHERE agent_type = 'scoper'
  AND created_at > NOW() - INTERVAL '7 days';
```

---

## 10. Integration with Other Agents

### Scoper → Logistics (Future)
When task is accepted by a hustler:
- Logistics AI uses Scoper's `estimated_duration_minutes` for routing
- Logistics validates if hustler capabilities match `required_capabilities`

### Scoper → Judge (Indirect)
- Judge AI may reference Scoper's `difficulty` rating during proof review
- Higher difficulty tasks get more lenient proof acceptance thresholds

### Scoper → Fraud Detection
- Unusual pricing patterns flagged (e.g., Scoper suggests $50, poster manually sets $500)
- Fraud system checks for pricing manipulation attempts

---

## 11. Admin Overrides

Admins can override Scoper decisions via admin panel:

```typescript
router.procedure('overrideScoperDecision')
  .input(z.object({
    decision_id: z.string(),
    override_price_cents: z.number(),
    override_xp: z.number(),
    reason: z.string()
  }))
  .mutation(async ({ input, ctx }) => {
    // Require admin role
    if (!ctx.user.is_admin) throw new TRPCError({ code: 'FORBIDDEN' });

    // Update ai_agent_decisions
    await db.query(`
      UPDATE ai_agent_decisions
      SET accepted = TRUE,
          validator_override = TRUE,
          validator_reason = $1,
          decided_by = $2,
          decided_at = NOW()
      WHERE id = $3
    `, [input.reason, ctx.user.id, input.decision_id]);

    // Update task with override values
    // ...
  });
```

---

## 12. Testing Requirements

### Unit Tests

```typescript
describe('ScoperAIService', () => {
  it('should propose price within $15-$500 range', async () => {
    const proposal = await ScoperAIService.analyzeTaskScope({
      description: 'Deliver 3 pizzas to downtown address',
      category: 'delivery'
    });
    expect(proposal.suggested_price_cents).toBeGreaterThanOrEqual(1500);
    expect(proposal.suggested_price_cents).toBeLessThanOrEqual(50000);
  });

  it('should calculate XP as price/10 ±20%', async () => {
    const proposal = await ScoperAIService.analyzeTaskScope({
      description: 'Move couch to 3rd floor apartment',
      category: 'moving'
    });
    const expected_xp = proposal.suggested_price_cents / 10;
    expect(proposal.suggested_xp).toBeCloseTo(expected_xp, 0.2 * expected_xp);
  });

  it('should reject ambiguous descriptions with low confidence', async () => {
    const proposal = await ScoperAIService.analyzeTaskScope({
      description: 'Do some stuff for me'
    });
    expect(proposal.confidence_score).toBeLessThan(0.60);
  });
});
```

### Integration Tests

```typescript
describe('Scoper Integration', () => {
  it('should log decision to ai_agent_decisions table', async () => {
    const result = await TaskService.create({
      description: 'Paint bedroom walls (12x14 room)',
      category: 'handyman'
    });

    const decision = await db.query(
      'SELECT * FROM ai_agent_decisions WHERE task_id = $1',
      [result.task_id]
    );

    expect(decision.rows[0].agent_type).toBe('scoper');
    expect(decision.rows[0].authority_level).toBe('A2');
  });
});
```

---

## 13. Deployment Checklist

- [ ] LLM API keys configured (.env: `OPENAI_API_KEY` or `GOOGLE_AI_API_KEY`)
- [ ] `ai_agent_decisions` table created (migration 002)
- [ ] ScoperAIService.ts implemented and tested
- [ ] Deterministic validator rules hardcoded (no AI bypass)
- [ ] TaskService.create() integrated with Scoper
- [ ] Admin override endpoints deployed
- [ ] Monitoring dashboard configured
- [ ] Fallback to manual pricing tested
- [ ] Rate limiting configured (prevent API abuse)
- [ ] Prompt injection defenses tested

---

## 14. Constitutional Enforcement Summary

| Rule | Enforced By | Bypass Possible? |
|------|-------------|------------------|
| Price bounds ($15-$500) | Deterministic validator | ❌ No (hardcoded) |
| XP = price/10 ±20% | Deterministic validator | ❌ No (hardcoded) |
| Difficulty-price alignment | Deterministic validator | ⚠️ Yes (admin override only) |
| Authority level A2 | Database schema CHECK constraint | ❌ No (DB-enforced) |
| Proposal logging | Application code | ⚠️ Yes (code bug only) |

**Key Insight:** Even if the AI model is compromised or hallucinates, the deterministic validator at Layer 1 prevents any constitutional violations from reaching the database (Layer 0).

---

**END OF SPECIFICATION**

_This specification is LOCKED and forms part of the constitutional layer of HustleXP. Changes require architectural review._
