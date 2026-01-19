# HustleXP Quick Start Guide

**Read time: 5 minutes**

---

## What is HustleXP?

HustleXP is a **task marketplace** where:

1. **Posters** create tasks and lock money in escrow
2. **Hustlers** (workers) complete tasks and submit proof
3. **System** releases money only after proof is verified
4. **XP** (experience points) is awarded only after payment

### The Golden Rule

> **Money moves only when work is proven. XP exists only when money moved.**

---

## The Flow

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Poster    │     │   Escrow    │     │   Hustler   │
│  creates    │────▶│   funded    │────▶│  accepts    │
│   task      │     │  (locked)   │     │   task      │
└─────────────┘     └─────────────┘     └─────────────┘
                                               │
                                               ▼
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  XP awarded │◀────│   Escrow    │◀────│   Proof     │
│  to Hustler │     │  released   │     │  accepted   │
└─────────────┘     └─────────────┘     └─────────────┘
```

Every arrow is **enforced by the database**. You cannot skip steps.

---

## 5 Rules That Cannot Be Broken

| # | Rule | What it means |
|---|------|---------------|
| 1 | XP requires released escrow | Can't get XP without payment |
| 2 | Release requires completed task | Can't pay for incomplete work |
| 3 | Complete requires accepted proof | Can't mark done without evidence |
| 4 | Escrow amount is immutable | Price can't change after agreement |
| 5 | One XP per escrow | Can't double-award for same work |

These are **mechanically enforced** at the database level. No code can bypass them.

---

## Who Builds What

| Team | Tool | Builds |
|------|------|--------|
| Backend | Claude Code | Database, Services, API |
| Frontend | Cursor | React Native screens |

### Backend (Claude Code)
- Read: `.claude/instructions.md`
- Then: `specs/02-architecture/schema.sql`
- Then: `specs/01-product/PRODUCT_SPEC.md`

### Frontend (Cursor)
- Read: `.cursorrules`
- Then: `screens-spec/SCREEN_REGISTRY.md`
- Then: `specs/03-frontend/UI_SPEC.md`

---

## Key Documents

| Document | Purpose | When to read |
|----------|---------|--------------|
| PRODUCT_SPEC | What we're building | First |
| ARCHITECTURE | How authority flows | Backend work |
| UI_SPEC | Design system | Frontend work |
| SCREEN_REGISTRY | All 38 screens | Frontend work |
| schema.sql | Database structure | Backend work |
| BUILD_GUIDE | Build phases | Starting a phase |

---

## 38 Screens Overview

| Category | Count | Examples |
|----------|-------|----------|
| Auth | 3 | Login, Signup, Forgot Password |
| Hustler | 9 | Home, Task Feed, Task Detail, XP Breakdown |
| Poster | 4 | Task Creation, Hustler On Way, Feedback |
| Onboarding | 12 | Calibration, Role Selection, Capability Setup |
| Settings | 3 | Profile, Wallet, Work Eligibility |
| Shared | 4 | Messaging, Trust Ladder, Disputes |
| Edge | 3 | No Tasks, Eligibility Mismatch, Trust Locked |

Full list: `screens-spec/SCREEN_REGISTRY.md`

---

## Key Terms

| Term | Meaning |
|------|---------|
| **Poster** | Person who creates and pays for tasks |
| **Hustler** | Person who completes tasks for money |
| **Escrow** | Money locked until work is verified |
| **Proof** | Evidence that work was completed |
| **XP** | Experience points earned after payment |
| **Trust Tier** | Your reliability score (0-5) |
| **Live Mode** | Real-time task matching (optional) |

---

## Next Steps

### If you're doing frontend work:
1. Clone the frontend repo: `git clone https://github.com/Sebdysart/HUSTLEXPFINAL1`
2. Read `EXECUTION_QUEUE.md` — find first unchecked step
3. Read `STOP_CONDITIONS.md` — know when to stop
4. Read `.cursorrules` — understand file access rules
5. Execute steps in order, never skip

### If you're doing backend work:
1. Read `.claude/instructions.md`
2. Understand the 5 invariants
3. Study `schema.sql`
4. Follow BUILD_GUIDE phases

---

## Repositories

| Repo | Purpose | Link |
|------|---------|------|
| **HUSTLEXP-DOCS** | This repo (specs, docs) | You're here |
| **HUSTLEXPFINAL1** | React Native frontend | [GitHub](https://github.com/Sebdysart/HUSTLEXPFINAL1) |
| **hustlexp-ai-backend** | Backend services | [GitHub](https://github.com/Sebdysart/hustlexp-ai-backend) |

---

*Welcome to HustleXP. Build something great.*
