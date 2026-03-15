# Design: README Vision Reset — All 3 Repos
**Date:** 2026-03-14
**Status:** Approved
**Author:** Sebastian Dysart + Claude

---

## Problem

Three repos. Three READMEs. Zero alignment.

- **Docs README** says React Native (it's SwiftUI), shows BOOTSTRAP/all ❌ (app is 100/100 beta-ready), lists tipping/recurring/referral as excluded v2 features (all are live). A new developer reading this thinks the project is broken.
- **Backend README** is a pure engineering reference manual with no product soul. Zero mention of why HustleXP exists, why it's different from TaskRabbit, what it feels like, or where it's going.
- **iOS README** has accurate screen counts but no story. The thesis — *"your reputation compounds instead of resetting"* — is not written anywhere.

The original app was scoped at ~50 endpoints, 32 tables, 38 screens. What shipped is 290+ procedures, 103 tables, 58 screens — 3x the scope — and qualitatively more interesting. The docs never acknowledged the evolution.

**Root cause of direction loss:** The north star lives only in session memory and a confidential audit document. It is not in any README. New team members, investors, or AI coding agents reading the repos cannot reconstruct the vision from what's written.

---

## The Thesis (must appear in every README)

> HustleXP is a local task marketplace where completing work builds a permanent, verifiable identity. XP, trust tiers, and platform reputation compound over time instead of resetting with every job.

**The 3 differentiators:**
1. **Progression that compounds** — Rookie → Verified → Trusted → Elite → Master. Every tier unlocks new capabilities and multipliers. TaskRabbit has no equivalent.
2. **Proof of Work with real teeth** — GPS + photo + biometric liveness + AI Judge + human review before escrow releases. No ambiguity, no disputes from vague completions.
3. **Live Mode radar** — Elite+ workers see ASAP task alerts pulsing in real time with 60-second claim windows and surge pricing. It's a game mechanic inside a real marketplace.

**The 2-year north star:**
A skilled-labor credentialing network with a marketplace on top. A "Master" Hustler with 4.95+ stars, $10k+ earned, and zero disputes is more verifiable than a resume. Squads allow Elite workers to compete for commercial contracts. The XP economy may extend into tangible rewards: insurance discounts, earned wage advance at Trusted+, verified worker identity exportable to other platforms.

---

## Scope

Three READMEs get full rewrites. Max-tier output for each.

### 1. Backend README (`hustlexp-ai-backend/README.md`)

**Principle:** 40% product, 60% technical. Currently 0% product.

**Sections:**
- Header: one-paragraph pitch that explains what the app IS and why it's different
- Current Status table: beta gate, test count, coverage, deployment URL, ecosystem health
- Architecture diagram (keep existing)
- Quick Start (keep existing)
- Tech Stack (keep existing)
- Core Business Logic (NEW): 5 flows in plain English — task lifecycle, escrow chain, XP + trust tiers, AI agent pipeline, Live Mode
- API Surface: 38 router tables (keep existing, cleaned up)
- Auth Model (keep existing)
- Environment Variables (keep existing)
- Database (keep existing)
- Background Workers (keep existing)
- Test Coverage (keep existing)
- Deployment (keep existing)
- Roadmap (NEW): 90-day milestones + 2-year vision
- What's Deferred (NEW): Checkr, Rekognition, Android, video proof

### 2. iOS README (`HUSTLEXPFINAL1/README.md`)

**Principle:** Start with the product story, architecture second.

**Sections:**
- Header: role-specific pitch — what a Hustler experiences, what a Poster experiences
- Current Status: beta-ready, link to backend URL
- The Two Journeys (NEW): prose walkthrough of Hustler journey + Poster journey
- Key Differentiating Features (NEW): Live Mode radar, trust tier system, XP economy, proof-of-work chain, squads
- Requirements (keep existing)
- Setup (keep existing)
- Architecture Overview (keep existing)
- Project Structure (keep existing)
- Screens by Role (keep existing, complete Hustler count to 19)
- Service Layer (keep existing)
- Dependencies (keep existing)
- Backend Connection (keep existing)
- Gaps / Not Yet Wired (NEW — honest): dispute submission, Rekognition liveness, squad tasks, featured listing Poster UI, daily challenges
- Roadmap (NEW)

### 3. Docs Repo README (`HUSTLEXP-DOCS/README.md`)

**Principle:** Humans first, AI tools second. Rebuild from scratch. Current version is catastrophically wrong on 3 factual points.

**Sections:**
- Header: product description + current live truth (not bootstrap)
- Current Status (LIVE TRUTH): single authoritative table replacing all the ❌ checkboxes
- For New Contributors — Read This First: ordered 10-minute orientation list
- What's Live: accurate feature list (includes tipping, recurring, referral, squads — all the things FINISHED_STATE wrongly says are excluded)
- What's Deferred: Checkr, Rekognition, Android
- Repository Map: clean directory tree with plain-English purpose per directory
- Authority Hierarchy: docs > backend > iOS, brief
- AI Tool Instructions: move Cursor/Claude enforcement content to named section so humans can skip it
- Roadmap (NEW)
- Fix: change "React Native" to "SwiftUI / iOS"

---

## Quality Bar

Each README must pass this test: a smart person who has never seen HustleXP can read it in 10 minutes and correctly answer:
1. What is HustleXP?
2. Why is it different from TaskRabbit?
3. Is this live? What works right now?
4. What are the 3 most important things to know about the codebase?
5. Where is this going in the next 6 months?

---

## Success Criteria

- [ ] All 3 READMEs pass the 10-minute orientation test
- [ ] No factual errors (React Native → SwiftUI, BOOTSTRAP → Private Beta, excluded features → live)
- [ ] The thesis and 3 differentiators appear in every README
- [ ] Current status is honest: what's live, what's beta, what's deferred
- [ ] Backend README has the 5 core business logic flows explained in plain English
- [ ] iOS README has the two user journeys explained in plain English
- [ ] Docs README is useful to humans, not just AI tools
- [ ] All 3 repos committed and pushed
