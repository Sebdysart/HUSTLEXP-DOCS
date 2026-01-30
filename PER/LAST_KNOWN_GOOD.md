# LAST KNOWN GOOD — HUSTLEXP v1.0

**STATUS: RECOVERY ANCHORS**
**PURPOSE: Track confirmed stable states for Ω recovery**

---

## THE RULE

> A "Last Known Good" is a commit/tag where:
> - Build succeeds
> - Tests pass
> - App runs without crash
> - All invariants hold
>
> If you can't prove all four, it's not a Last Known Good.

---

## CURRENT LAST KNOWN GOOD

### Production Baseline

| Aspect | Value |
|--------|-------|
| **Tag** | `v1.0.0-baseline` (update as needed) |
| **Commit** | `[update with actual commit hash]` |
| **Date** | `[update with date]` |
| **Verified By** | `[name]` |

### Verification Evidence

```
[ ] Build: npm run build → SUCCESS
[ ] Tests: npm run test → ALL PASS
[ ] Start: npm run start → NO CRASH
[ ] Invariants: Manual verification → ALL HOLD
```

---

## HOW TO CREATE A LAST KNOWN GOOD

### Step 1: Verify Current State

```bash
# Clean environment
rm -rf node_modules
rm package-lock.json
npm install

# Build
npm run build

# Test
npm run test

# Start and verify
npm run start
# Manually verify app works
```

### Step 2: Tag the Commit

```bash
# Create annotated tag
git tag -a v1.0.X-lkg -m "Last Known Good: [date] - [reason]"

# Push tag
git push origin v1.0.X-lkg
```

### Step 3: Document in This File

Add entry to HISTORY section below.

---

## HOW TO USE LAST KNOWN GOOD (Ω Recovery)

### Quick Recovery

```bash
# Fresh clone
cd ~
rm -rf hustlexp-recovery
git clone [repo-url] hustlexp-recovery
cd hustlexp-recovery

# Checkout LKG
git checkout v1.0.0-baseline  # Use current LKG tag

# Fresh install
rm -rf node_modules
npm install

# Verify
npm run build
npm run start
```

### Subtractive Reconstruction

```bash
# List changes since LKG
git log --oneline v1.0.0-baseline..HEAD

# Apply changes one at a time
git cherry-pick [commit-1]
npm run build
npm run test

git cherry-pick [commit-2]
npm run build
npm run test

# Continue until failure identified
```

---

## LAST KNOWN GOOD HISTORY

### Template for New Entry

```markdown
### LKG-[N]: [Tag Name]

| Aspect | Value |
|--------|-------|
| **Tag** | `v1.0.X-lkg` |
| **Commit** | `abc1234` |
| **Date** | `YYYY-MM-DD` |
| **Verified By** | `[name]` |
| **Reason** | `[why this was marked as LKG]` |

**Verification:**
- Build: PASS
- Tests: PASS (X/Y tests)
- Start: PASS
- Invariants: ALL HOLD

**Notes:**
[Any relevant notes about this LKG]
```

---

### LKG-1: Initial Baseline

| Aspect | Value |
|--------|-------|
| **Tag** | `v1.0.0-baseline` |
| **Commit** | `46b2501` |
| **Date** | `2025-01-22` |
| **Verified By** | `System` |
| **Reason** | `Initial baseline after PER system implementation` |

**Verification:**
- Build: PENDING
- Tests: PENDING
- Start: PENDING
- Invariants: PENDING

**Notes:**
Initial LKG placeholder. Update after verification.

---

## WHEN TO CREATE NEW LKG

Create a new Last Known Good when:

```
[ ] Major milestone completed
[ ] Before significant refactor
[ ] After successful production deploy
[ ] Weekly (minimum)
[ ] Before any "risky" change
```

---

## LKG NAMING CONVENTION

```
v[major].[minor].[patch]-lkg[-descriptor]

Examples:
- v1.0.0-baseline     (initial)
- v1.0.1-lkg          (after bug fixes)
- v1.1.0-lkg-escrow   (after escrow feature)
- v1.2.0-lkg-pre-live (before live mode release)
```

---

## VERIFICATION CHECKLIST

Before marking a commit as LKG:

```
## LKG Verification Checklist

### Build Verification
[ ] node_modules deleted and reinstalled
[ ] npm run build succeeds with no warnings
[ ] Build output is reasonable size
[ ] No TypeScript errors

### Test Verification
[ ] npm run test passes
[ ] All invariant tests pass
[ ] Coverage meets threshold (70%+)
[ ] No skipped tests in critical paths

### Runtime Verification
[ ] npm run start succeeds
[ ] App loads without crash
[ ] Core flows work:
    [ ] User can sign up
    [ ] User can create task
    [ ] User can accept task
    [ ] Escrow flow works (in test mode)

### Invariant Verification
[ ] INV-1 through INV-5 hold (manual spot check)
[ ] No HX errors in logs
[ ] Database constraints active

### Documentation
[ ] Commit message clear
[ ] Tag created with annotation
[ ] This file updated
```

---

## EMERGENCY LKG (Quick Reference)

If you need to find a working state quickly:

```bash
# Find recent tags
git tag -l "v*-lkg*" --sort=-creatordate | head -5

# Get tag details
git show v1.0.0-baseline

# Checkout and verify
git checkout v1.0.0-baseline
npm install
npm run build
```

---

## AUTOMATED LKG (Future)

Consider automating LKG creation:

```yaml
# CI workflow (example)
name: Create LKG

on:
  schedule:
    - cron: '0 0 * * 0'  # Weekly
  workflow_dispatch:

jobs:
  create-lkg:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - run: npm install
      - run: npm run build
      - run: npm run test
      - name: Create LKG tag
        if: success()
        run: |
          git tag -a "v1.0.$(date +%Y%m%d)-lkg" -m "Automated LKG"
          git push origin "v1.0.$(date +%Y%m%d)-lkg"
```

---

**A Last Known Good is your insurance policy.**
**Update it regularly. You'll thank yourself during Ω.**
