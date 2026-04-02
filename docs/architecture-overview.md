# HustleXP Architecture Overview

## System Overview
HustleXP is a gamified hyperlocal task marketplace with Stripe escrow, XP/leveling, and AI agents.

## Backend — hustlexp-ai-backend (PRIVATE)
- **Framework**: Hono + tRPC on Cloudflare Workers
- **Database**: Neon PostgreSQL (103 tables)
- **Services**: 85 total, 5,448+ tests passing
- **Key Financial Services**: EscrowService, StripeService, DisputeService, LedgerService, TaskService

## Architecture Rules
- **External API calls**: Only through CircuitBreaker (backend/src/middleware/circuit-breaker.ts)
- **AI/LLM calls**: Only through AIRouter with strict budget + token accounting
- **Admin endpoints**: adminProcedure only (never protectedProcedure or public)
- **Database queries**: Parameterized only (zero string interpolation)
- **Financial mutations**: SERIALIZABLE isolation, explicit transactions
- **Idempotency**: Mandatory on Stripe, escrow release, and XP grant operations

## Financial Invariants
| ID | Rule | Status |
|----|------|--------|
| INV-1 | Escrow amounts are positive integers in cents | CLEAN |
| INV-2 | XP granted only after escrow fully released | CLEAN |
| INV-3 | Escrow released exactly once per task | CLEAN |
| INV-4 | Ledger entries are append-only immutable | CLEAN |
| INV-5 | All payment amounts are positive integer cents | CLEAN |
| INV-6 | Every financial operation is atomic with audit log | CLEAN |
| INV-7 | Double-release protection in same transaction | CLEAN |
| INV-8 | Stripe webhooks processed idempotently | CLEAN |

## Frontend — HUSTLEXPFINAL1
- **Stack**: React Native / Expo
- **Status**: ~15 errors tracked, NO CI/CD pipeline (P0 gap)

## Infrastructure Repos
- **HUSTLEXP-ERRORS-AND-TODOS**: Error tracking with staleness checks, issue templates, dependabot
- **HUSTLEXP-DOCS**: Documentation with markdown lint, link validator, doc freshness
- **omni-link-hustlexp**: CLI/agent orchestration with CodeQL, benchmarks, CODEOWNERS
