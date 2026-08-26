# HustleXP Documentation Authority and Source Precedence

**Version:** 1.0.0  
**Effective:** 2026-08-25  
**Production effect:** NONE

## Precedence

Use this order when HustleXP documents conflict:

1. Applicable law, written regulator direction, executed agreements, and written processor/insurance decisions constrain what may be executed.
2. [HustleXP Business and Universal V1 Charter](HUSTLEXP_BUSINESS_AND_UNIVERSAL_V1_CHARTER.md) controls company identity, operating doctrine, product lanes, business policy, service cells, categories, economics definitions, metrics, and Universal V1 target behavior.
3. Repository-specific controlling specifications own exact implementation boundaries and current engineering truth, provided they do not contradict the charter.
4. Current checkpoints and evidence records own source-dated observations only.
5. Approved subordinate product, UX, architecture, runbook, and policy documents elaborate within the authorities above.
6. Validation plans and experiments are proposals until their evidence is reviewed and promoted.
7. Roadmaps, audits, archived specs, prior READMEs, underwriting assumptions, implementation plans, and files labeled final/locked/master/constitutional are historical or subordinate unless the alignment register explicitly promotes them.

## Conflict rules

- Current evidence beats stale status claims.
- Typed lifecycle states beat “escrow,” “paid,” “funded,” or “complete” shorthand.
- Processor-neutral intent beats processor-specific examples.
- Official credentials beat external ratings for trade eligibility.
- Broad demand intake never implies serviceability or payment authority.
- One lifecycle beats origin-specific parallel lifecycles.
- A real Task Draft precedes opportunities and financial commitment.
- The Financial Security Event precedes Work Order materialization, hard assignment, and exact-address release.
- Capture, settlement, platform funding, provider payout, reconciliation, and closure remain separate.
- Production money and deployment remain frozen unless separately authorized by exact release evidence.

## Document classifications

| Classification | Meaning |
| --- | --- |
| `CONTROLLING` | May define present policy within its stated scope. |
| `SUBORDINATE` | May elaborate but cannot contradict controlling authority. |
| `CURRENT EVIDENCE` | Source-dated observation; expires as reality changes. |
| `VALIDATION` | Hypothesis, test band, or proposed target. |
| `EXTERNAL DECISION` | Legal, processor, insurance, or regulatory result. |
| `HISTORICAL` | Preserved evidence; no execution authority. |
| `ARCHIVED` | Deliberately excluded from current planning. |

## Required header for new governing documents

Every new governing document must declare:

```text
Title
Version
Decision date or evidence date
Classification
Scope
Authority or owner
Supersedes / superseded by
External decisions still open
Production effect
```

## Legacy document rule

Existing documents are preserved. Their content remains useful for history, design exploration, implementation detail, and evidence. When they conflict with the charter, the conflicting clause is non-operative without requiring destructive history rewriting.

The words `LOCKED`, `FINAL`, `MASTER`, `CONSTITUTIONAL`, `AUTHORITY`, and `SINGLE SOURCE OF TRUTH` inside an older filename or document do not alter this precedence.
