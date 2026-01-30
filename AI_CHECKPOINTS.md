# AI CHECKPOINTS — SPEC-TO-GATE MAPPING

**STATUS: ACTIVE — Read this before ANY implementation**

---

## PURPOSE

This file maps **deep spec sections** to **enforcement gates**.
AI tools must pass these gates before implementation is valid.

---

## HOW TO USE

1. Find the spec section relevant to your task
2. Read the checkpoint requirements
3. Verify ALL requirements are met
4. If ANY fail → STOP and report

---

## SPEC CHECKPOINTS

### UI_SPEC.md Checkpoints

| Spec Section | Checkpoint | Gate |
|--------------|------------|------|
| §1 Brand Colors | Must use HustleColors palette only | `COLORS_GATE` |
| §2 Typography | Must use HustleTypography presets only | `TYPOGRAPHY_GATE` |
| §3 Spacing | Must use HustleSpacing scale (4px base) | `SPACING_GATE` |
| §4 Motion | Must follow motion timing curves | `MOTION_GATE` |
| §5 Component Patterns | Must use existing atoms/molecules | `COMPONENT_GATE` |
| §6 Accessibility | Must meet WCAG 2.1 AA | `A11Y_GATE` |

### ARCHITECTURE.md Checkpoints

| Spec Section | Checkpoint | Gate |
|--------------|------------|------|
| §1 Authority Layers | Computation at correct layer | `LAYER_GATE` |
| §2 Database Schema | No schema modifications | `SCHEMA_GATE` |
| §3 API Contracts | Endpoints match spec exactly | `API_GATE` |
| §4 Invariants | Business rules enforced server-side | `INVARIANT_GATE` |

### PRODUCT_SPEC.md Checkpoints

| Spec Section | Checkpoint | Gate |
|--------------|------------|------|
| §Features | Feature exists in FINISHED_STATE.md | `FEATURE_GATE` |
| §Screens | Screen exists in SCREEN_REGISTRY.md | `SCREEN_GATE` |
| §Flows | Flow matches state machine | `FLOW_GATE` |

---

## GATE DEFINITIONS

### COLORS_GATE
```
PASS if:
  - All colors from tokens/colors.md
  - No hex values in component code
  - No rgba() with custom values
  
FAIL if:
  - Any hardcoded color
  - Any color not in palette
```

### TYPOGRAPHY_GATE
```
PASS if:
  - All text uses Text atom
  - All sizes from typography scale
  - All weights from approved set
  
FAIL if:
  - Inline font styles
  - Custom font sizes
  - Non-approved fonts
```

### SPACING_GATE
```
PASS if:
  - All spacing uses Spacer atom
  - All margins/padding use scale
  - 4px base unit respected
  
FAIL if:
  - Arbitrary pixel values
  - Spacing not divisible by 4
```

### COMPONENT_GATE
```
PASS if:
  - All components from ui-puzzle/
  - No inline styled components
  - No duplicate molecules
  
FAIL if:
  - New component created at screen level
  - Component not in registry
  - Inline <View style={{...}}>
```

### LAYER_GATE
```
PASS if:
  - Eligibility computed server-side
  - XP computed server-side
  - Trust tier computed server-side
  - Frontend receives results only
  
FAIL if:
  - Any business logic in frontend
  - Eligibility check in component
  - XP calculation in component
```

### SCHEMA_GATE
```
PASS if:
  - Using existing 32 tables
  - No ALTER TABLE statements
  - No new tables
  
FAIL if:
  - New table proposed
  - Schema modification
  - New column without spec
```

### API_GATE
```
PASS if:
  - Endpoint exists in API_SPEC.md
  - Request/response matches spec
  - Field names exact match
  
FAIL if:
  - New endpoint proposed
  - Field added to response
  - Type mismatch
```

### FEATURE_GATE
```
PASS if:
  - Feature in FINISHED_STATE.md
  - Feature not in "v2+" list
  
FAIL if:
  - Feature not specified
  - Feature explicitly excluded
  - Feature is v2+
```

### SCREEN_GATE
```
PASS if:
  - Screen in SCREEN_REGISTRY.md
  - Screen code matches spec code
  
FAIL if:
  - Screen not registered
  - New screen proposed
```

---

## CHECKPOINT VERIFICATION TEMPLATE

Before completing any task, verify:

```markdown
## Checkpoint Verification

**Task:** [Task name]
**Spec References:** [List spec sections]

**Gates Checked:**
- [ ] COLORS_GATE — All colors from palette
- [ ] TYPOGRAPHY_GATE — All text uses presets
- [ ] SPACING_GATE — All spacing uses scale
- [ ] COMPONENT_GATE — All components from registry
- [ ] LAYER_GATE — No frontend business logic
- [ ] FEATURE_GATE — Feature is specified

**Result:** [PASS / FAIL]
**If FAIL:** [Specific gate and reason]
```

---

## AUTOMATIC FAIL CONDITIONS

These ALWAYS fail, no exceptions:

```
❌ const isEligible = ... (in frontend)
❌ style={{ backgroundColor: '#...' }}
❌ <NewComponentNotInRegistry />
❌ fetch('/api/new-endpoint')
❌ ALTER TABLE ...
❌ Feature not in FINISHED_STATE.md
```

---

## ESCALATION

If you encounter:
- Spec conflict → Report to product owner
- Missing spec section → STOP, do not guess
- Unclear gate → Ask for clarification

**Never bypass gates. Never assume. Never "improve."**
