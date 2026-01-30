# ARCHETYPE → MOLECULE MATRIX

**STATUS: FROZEN — This defines what molecules each archetype may use**

---

## PURPOSE

Each archetype maps to a **fixed allowed molecule set**.
If a screen uses a molecule NOT listed for its archetype → **INVALID**.

This eliminates "design within archetype" drift.

---

## THE MATRIX

### A. ENTRY / COMMITMENT

**Purpose:** User decides to engage

**Allowed Molecules:**
```
✅ FormField          — Login/signup inputs
✅ ActionBar          — Primary CTA at bottom
✅ EmptyState         — Error recovery only
✅ LoadingState       — Submit feedback
```

**Forbidden Molecules:**
```
❌ TaskCard           — No tasks in entry flow
❌ UserHeader         — No profile display yet
❌ ProgressBar        — No progress to show
❌ RatingStars        — No ratings in entry
❌ FilterBar          — No filtering
```

**Screens:** A1-A4 (Auth), O1-O2 (Welcome, Role Selection)

---

### B. FEED / OPPORTUNITY

**Purpose:** User discovers options

**Allowed Molecules:**
```
✅ TaskCard           — Primary content
✅ FilterBar          — Sort/filter controls
✅ EmptyState         — No results (chosen-state)
✅ LoadingState       — Feed loading
✅ StatusBadge        — Task status indicators
```

**Forbidden Molecules:**
```
❌ FormField          — No forms in feed
❌ ActionBar          — Actions are per-card
❌ UserHeader         — Not a profile view
❌ ProgressBar        — No progress display
```

**Screens:** H2 (TaskFeed), H3 (TaskHistory), P3 (ActiveTasks)

---

### C. TASK LIFECYCLE

**Purpose:** Active work in progress

**Allowed Molecules:**
```
✅ TaskCard           — Expanded task display
✅ StatusBadge        — Current status
✅ ProgressBar        — Task progress
✅ ActionBar          — Task actions
✅ UserHeader         — Other party info
✅ LoadingState       — Action feedback
✅ ErrorState         — Action failures
```

**Forbidden Molecules:**
```
❌ FilterBar          — Not browsing
❌ FormField          — Use specialized inputs
❌ RatingStars        — Not in active task (only completion)
```

**Screens:** H5-H6, P5-P8, SH1-SH4

---

### D. CALIBRATION / CAPABILITY

**Purpose:** User configures self

**Allowed Molecules:**
```
✅ FormField          — Input collection
✅ ActionBar          — Continue/back
✅ ProgressBar        — Onboarding progress
✅ ListItem           — Settings options
✅ LoadingState       — Save feedback
```

**Forbidden Molecules:**
```
❌ TaskCard           — Not viewing tasks
❌ FilterBar          — Not browsing
❌ UserHeader         — Not profile display
❌ RatingStars        — Not rating
```

**Screens:** O3-O6 (Onboarding), S1-S6 (Settings), P2 (TaskCreation)

---

### E. PROGRESS / STATUS

**Purpose:** User sees their standing

**Allowed Molecules:**
```
✅ UserHeader         — Profile display
✅ ProgressBar        — XP/trust progress
✅ StatusBadge        — Tier/level badges
✅ ListItem           — Stats breakdown
✅ RatingStars        — Rating display
✅ PriceDisplay       — Earnings display
```

**Forbidden Molecules:**
```
❌ FormField          — Not editing
❌ FilterBar          — Not browsing
❌ ActionBar          — Minimal actions
❌ TaskCard           — Not task view (use stats)
```

**Screens:** H1 (HustlerHome), H4 (HustlerProfile), H7-H9 (XP, Trust, Earnings), P1 (PosterHome), P4 (PosterProfile)

---

### F. SYSTEM / INTERRUPT

**Purpose:** System communicates critical info

**Allowed Molecules:**
```
✅ EmptyState         — Error/empty display
✅ ErrorState         — Error with retry
✅ ActionBar          — Single action (retry/dismiss)
✅ LoadingState       — Processing states
```

**Forbidden Molecules:**
```
❌ TaskCard           — No tasks in system screens
❌ UserHeader         — No profile in system screens
❌ FilterBar          — No browsing
❌ FormField          — No input (except support)
❌ ProgressBar        — No progress
❌ RatingStars        — No ratings
❌ PriceDisplay       — No prices
❌ ListItem           — Minimal content
```

**Screens:** E1-E5 (Edge cases), S7 (Support)

---

## ENFORCEMENT RULES

### Rule 1: Binding is Absolute
```
If a molecule is not in the archetype's ALLOWED list → FORBIDDEN.
No exceptions. No "just this once."
```

### Rule 2: Verify Before Implementation
```
Before adding ANY molecule to a screen:
1. Identify the screen's archetype
2. Check the ALLOWED list above
3. If molecule not allowed → STOP AND ASK
```

### Rule 3: Cross-Archetype Molecules
```
Some molecules appear in multiple archetypes.
This is intentional — they serve different purposes.
Usage must still match archetype intent.
```

### Rule 4: New Molecules
```
If you need a molecule not in ANY allowed list:
1. STOP
2. Report: "Need molecule [X] for archetype [Y]"
3. Wait for approval
4. Do NOT invent inline solutions
```

---

## QUICK REFERENCE

| Molecule | A | B | C | D | E | F |
|----------|---|---|---|---|---|---|
| TaskCard | ❌ | ✅ | ✅ | ❌ | ❌ | ❌ |
| UserHeader | ❌ | ❌ | ✅ | ❌ | ✅ | ❌ |
| PriceDisplay | ❌ | ✅ | ✅ | ❌ | ✅ | ❌ |
| RatingStars | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ |
| ProgressBar | ❌ | ❌ | ✅ | ✅ | ✅ | ❌ |
| StatusBadge | ❌ | ✅ | ✅ | ❌ | ✅ | ❌ |
| EmptyState | ✅ | ✅ | ❌ | ❌ | ❌ | ✅ |
| ErrorState | ❌ | ❌ | ✅ | ❌ | ❌ | ✅ |
| LoadingState | ✅ | ✅ | ✅ | ✅ | ❌ | ✅ |
| ListItem | ❌ | ❌ | ❌ | ✅ | ✅ | ❌ |
| FormField | ✅ | ❌ | ❌ | ✅ | ❌ | ❌ |
| ActionBar | ✅ | ❌ | ✅ | ✅ | ❌ | ✅ |
| FilterBar | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ |

---

## VIOLATION EXAMPLES

### ❌ INVALID: TaskCard in Entry Screen
```tsx
// AuthLoginScreen.tsx (Archetype A)
<TaskCard task={...} />  // FORBIDDEN — TaskCard not allowed in A
```

### ❌ INVALID: FormField in Feed Screen
```tsx
// TaskFeedScreen.tsx (Archetype B)
<FormField label="Search" />  // FORBIDDEN — FormField not allowed in B
```

### ❌ INVALID: FilterBar in System Screen
```tsx
// NetworkErrorScreen.tsx (Archetype F)
<FilterBar options={...} />  // FORBIDDEN — FilterBar not allowed in F
```

### ✅ VALID: ActionBar in Entry Screen
```tsx
// AuthLoginScreen.tsx (Archetype A)
<ActionBar primary="Login" />  // ALLOWED — ActionBar in A's list
```

---

## WHY THIS MATTERS

Without this matrix:
```
"I'm building a login screen, let me add a TaskCard preview..."
"The error screen could use a progress bar..."
"The feed could have inline forms..."
```

With this matrix:
```
"Login = Archetype A. TaskCard not allowed. Stop."
"Error = Archetype F. ProgressBar not allowed. Stop."
"Feed = Archetype B. FormField not allowed. Stop."
```

**Aesthetic drift dies at the source.**
