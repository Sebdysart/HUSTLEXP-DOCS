# FRONTEND ENTRYPOINT — HUSTLEXP

**This file is the SINGLE SOURCE for "what do I do now?"**  
**Copy this file to HUSTLEXPFINAL1 repo when updated.**

---

## CURRENT_PHASE

```
BOOTSTRAP
```

---

## NEXT_LEGAL_ACTION

```
Fix runtime crashes preventing BootstrapScreen render.
```

---

## SESSION_SCOPE

| Status | Files |
|--------|-------|
| **ALLOWED** | `App.tsx`, `src/screens/BootstrapScreen.tsx` |
| **FROZEN** | `src/navigation/**`, all other screens |
| **READ-ONLY** | `package.json`, `ios/`, `android/` |

---

## SUCCESS_CRITERIA (ALL REQUIRED)

```
[ ] App builds in Xcode without errors
[ ] App launches in iOS Simulator without crash
[ ] BootstrapScreen renders with "HustleXP" text
[ ] Primary button visible and logs to console on press
[ ] App survives 30 seconds idle without crash or freeze
```

---

## STOP_CONDITION

```
When ALL success criteria pass → STOP IMMEDIATELY.

Do NOT:
- Refactor
- Polish
- Enhance
- Improve
- Add features
- Optimize
- Style beyond spec

Mark BOOTSTRAP complete and STOP.
```

---

## IF_BLOCKED

```
1. Identify the specific blocker
2. Report: "BLOCKED: [specific error/issue]"
3. REFUSE to proceed until blocker is resolved
4. Do NOT work around blockers by inventing solutions
```

---

## PHASE_GATE

```
BOOTSTRAP must pass before ANY of the following are legal:
- Navigation implementation
- Screen implementation (except BootstrapScreen)
- Component creation
- Styling work
- Animation work
- Copy/text changes
```

---

## SESSION_CHECKLIST

Before starting work:
```
[ ] Read this file (FRONTEND_ENTRYPOINT.md)
[ ] Confirm CURRENT_PHASE matches your task
[ ] Confirm files you're touching are ALLOWED
[ ] Understand SUCCESS_CRITERIA
[ ] Understand STOP_CONDITION
```

After completing work:
```
[ ] All SUCCESS_CRITERIA checked
[ ] No files outside SESSION_SCOPE modified
[ ] STOP_CONDITION triggered
[ ] Session ends immediately
```

---

## PHASE PROGRESSION

| Phase | Gate | Next Phase |
|-------|------|------------|
| BOOTSTRAP | All criteria pass | NAVIGATION |
| NAVIGATION | All 38 screen stubs exist | SCREENS |
| SCREENS | All screens implemented | WIRING |
| WIRING | Mock data connected | INTEGRATION |

**Current: BOOTSTRAP**

---

## UPDATING THIS FILE

1. Edit this file in HUSTLEXP-DOCS
2. Copy to HUSTLEXPFINAL1/FRONTEND_ENTRYPOINT.md
3. Commit both repos
4. Verify sync

**HUSTLEXP-DOCS is the source. HUSTLEXPFINAL1 is the copy.**
