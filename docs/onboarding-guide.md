# HustleXP Developer Onboarding Guide

## Prerequisites
- Node.js 20+
- pnpm package manager
- Neon PostgreSQL access (ask Sebastian for credentials)
- Stripe test keys (see .env.example)

## Repository Setup
```bash
git clone git@github.com:Sebdysart/hustlexp-ai-backend.git
cd hustlexp-ai-backend
pnpm install
cp .env.example .env
# Fill in database URL and Stripe test keys
```

## Verification Commands
Run all three before every PR:
```bash
npx vitest run --coverage --reporter=verbose   # Expect 6320+ passing, 0 failed
npx tsc --noEmit                                # Exit code must be 0
npx eslint . --max-warnings=0                   # Exit code must be 0, zero warnings
```

## Key Directories
- `src/services/` — 85 service modules (business logic)
- `src/middleware/` — CircuitBreaker, auth, rate limiting
- `src/routes/` — tRPC procedure definitions

## Financial Code Rules (CRITICAL)
**NEVER** modify these services without running the full protocol:
- EscrowService, StripeService, DisputeService, LedgerService, TaskService

Before any financial change:
1. Run **escrow-state-guard** skill (full invariant checklist)
2. Run **hustlexp-tdd** skill (red-green-refactor with financial simulation)
3. Generate a **risk matrix** (probability x impact)
4. List every invariant checked and how it is protected

## PR Requirements
- All tests pass (6320+ passing, 0 failed)
- TSC clean (exit code 0)
- ESLint clean (0 warnings)
- Financial invariant checklist in PR description (use PR template)
- Coverage: financial modules >= 98% statement + branch

## Vault Reference
The HustleXP-Vault (~/HustleXP-Vault/) contains:
- **Dashboards**: P0 board, financial invariant health, error tracker
- **Runbooks**: INV-1 through INV-8 detailed procedures
- **Skills**: audit-service, trace-financial-path, generate-risk-matrix
- **Templates**: Daily notes, weekly reviews with Dataview integration
