# FORBIDDEN OUTPUTS — EXPLICIT BANS

**STATUS: CONSTITUTIONAL**
**VIOLATION: BUILD FAILURE / REJECTION**
**PURPOSE: Explicit list of what AI must NEVER produce**

---

## WHY THIS EXISTS

AI tools sometimes produce technically valid but contextually wrong output.

This document lists specific patterns that are BANNED regardless of context.

**If output matches any pattern here → REJECT and redo.**

---

## COLOR VIOLATIONS

### FORBIDDEN: Green on Entry/Brand Surfaces

```tsx
// ❌ INSTANT FAIL — Green background on entry
<View style={{ backgroundColor: '#1FAD7E' }}>  // FORBIDDEN
<View style={{ backgroundColor: '#34C759' }}>  // FORBIDDEN

// ❌ INSTANT FAIL — Green gradient on entry
<LinearGradient colors={['#1FAD7E', '#000000']} />  // FORBIDDEN

// ❌ INSTANT FAIL — Green glow on entry
<View style={{ shadowColor: '#1FAD7E' }} />  // FORBIDDEN on entry

// ✅ CORRECT — Purple brand on entry
<View style={{ backgroundColor: '#5B2DFF' }}>
<LinearGradient colors={['#1a0a2e', '#0B0B0F', '#000000']} />
```

### FORBIDDEN: Wrong Background Black

```tsx
// ❌ FORBIDDEN — #0D0D0D (old, incorrect)
backgroundColor: '#0D0D0D'

// ✅ CORRECT — #0B0B0F (brand black) or #000000 (pure black)
backgroundColor: '#0B0B0F'
backgroundColor: '#000000'
```

### FORBIDDEN: Wrong Brand Colors

```tsx
// ❌ FORBIDDEN — These are NOT brand colors
'#FF6B35'   // Some orange
'#00FF00'   // Bright green
'#1FAD7E'   // Teal (this is SUCCESS, not brand)

// ✅ CORRECT — Actual brand colors
'#0B0B0F'   // Brand black
'#5B2DFF'   // Brand purple
'#7A4DFF'   // Brand purple light
'#8B5CF6'   // Brand purple glow
```

---

## LAYOUT VIOLATIONS

### FORBIDDEN: Card-Based Entry Screens

```tsx
// ❌ INSTANT FAIL — Centered card layout
<View style={{
  flex: 1,
  justifyContent: 'center',    // ← FORBIDDEN for entry
  alignItems: 'center',        // ← FORBIDDEN for entry
}}>
  <View style={{
    backgroundColor: 'rgba(...)',  // Card styling
    borderRadius: 20,              // Card styling
    padding: 24,                   // Card styling
  }}>
    {/* Content in a card */}
  </View>
</View>

// ✅ CORRECT — Full-canvas layout
<View style={{ flex: 1, backgroundColor: '#0B0B0F' }}>
  <LinearGradient ... />
  <View style={styles.content}>
    {/* Content flows top-to-bottom, not centered in card */}
  </View>
</View>
```

### FORBIDDEN: Minimal Entry Screens

```tsx
// ❌ INSTANT FAIL — Minimal bootstrap-style entry
<View style={{ flex: 1, backgroundColor: '#000', justifyContent: 'center', alignItems: 'center' }}>
  <Text style={{ color: '#FFF' }}>HustleXP</Text>
  <Button>Get Started</Button>
</View>

// This fails because:
// - No gradient treatment
// - No glow effect
// - Centered card layout
// - No brand personality
// - Does not pass UAP-5
```

### FORBIDDEN: Flat Black Without Treatment

```tsx
// ❌ FORBIDDEN — Flat black with no depth
<View style={{ flex: 1, backgroundColor: '#000000' }}>
  {/* No gradient, no glow, no visual interest */}
</View>

// ✅ CORRECT — Black with purple treatment
<View style={{ flex: 1, backgroundColor: '#0B0B0F' }}>
  <LinearGradient
    colors={['#1a0a2e', '#0B0B0F', '#000000']}
    style={StyleSheet.absoluteFill}
  />
  <View style={styles.glowOrb} />
  {/* Content */}
</View>
```

---

## COMPONENT VIOLATIONS

### FORBIDDEN: Default React Native Buttons

```tsx
// ❌ FORBIDDEN — Plain RN Button
<Button title="Get Started" onPress={...} />

// ✅ CORRECT — Custom styled TouchableOpacity
<TouchableOpacity style={styles.primaryButton} onPress={...}>
  <Text style={styles.primaryButtonText}>Get Started</Text>
</TouchableOpacity>
```

### FORBIDDEN: Unstyled Text

```tsx
// ❌ FORBIDDEN — Default system font
<Text>Hello World</Text>

// ✅ CORRECT — Styled with design tokens
<Text style={{
  fontSize: 17,
  fontWeight: '600',
  color: '#FFFFFF',
  letterSpacing: -0.4,
}}>Hello World</Text>
```

---

## STRUCTURAL VIOLATIONS

### FORBIDDEN: New Screens Not in Registry

```tsx
// ❌ FORBIDDEN — Screen not in SCREEN_REGISTRY.md
// screens/RandomNewScreen.tsx
export function RandomNewScreen() { ... }

// If it's not in SCREEN_REGISTRY.md, it cannot be created
```

### FORBIDDEN: New Database Tables

```sql
-- ❌ FORBIDDEN — Table not in schema.sql
CREATE TABLE new_random_table (...);

-- 31 tables are defined. No new tables allowed.
```

### FORBIDDEN: New Dependencies

```json
// ❌ FORBIDDEN — Adding deps without approval
{
  "dependencies": {
    "some-new-package": "^1.0.0"  // FORBIDDEN without approval
  }
}
```

---

## INVARIANT VIOLATIONS

### FORBIDDEN: Bypassing Invariant Logic

```typescript
// ❌ FORBIDDEN — Skipping escrow check
async function awardXP(userId: string, amount: number) {
  // Missing: check that escrow is RELEASED
  await db.xpLedger.insert({ userId, amount });
}

// ✅ CORRECT — Invariant enforced
async function awardXP(escrowId: string) {
  const escrow = await db.escrows.findUnique({ where: { id: escrowId } });
  if (escrow.state !== 'RELEASED') {
    throw new Error('HX101: XP requires RELEASED escrow');
  }
  // ... award XP
}
```

### FORBIDDEN: Modifying Audit Tables

```sql
-- ❌ FORBIDDEN — Deleting from append-only tables
DELETE FROM xp_ledger WHERE ...;
UPDATE xp_ledger SET amount = ...;

-- Audit tables are append-only (INV: AUDIT-5)
```

### FORBIDDEN: Direct Layer 0 Access from UI

```typescript
// ❌ FORBIDDEN — UI calling database directly
// In a React component:
const data = await db.query('SELECT * FROM tasks');

// UI must go through API (ARCH-4)
```

---

## BEHAVIOR VIOLATIONS

### FORBIDDEN: Implementing Unspecified Features

```
User: "Can you add dark mode?"
AI: "Sure, let me implement dark mode..."

// ❌ FORBIDDEN — Dark mode is not in FINISHED_STATE.md
// ✅ CORRECT — "Dark mode is not in the current scope. The app uses dark theme by default."
```

### FORBIDDEN: Refactoring Without Request

```
User: "Fix the button color"
AI: "I'll fix the button color and also refactor the entire component..."

// ❌ FORBIDDEN — Only do what was asked
// ✅ CORRECT — Fix only the button color
```

### FORBIDDEN: Adding Comments/Docs to Unchanged Code

```typescript
// ❌ FORBIDDEN — Adding docstrings where not needed
/**
 * This function does something.
 * @param x The x value
 * @returns The result
 */
function existingFunction(x) { ... }  // You didn't change this function

// Only add documentation to NEW or MODIFIED code
```

---

## FILE VIOLATIONS

### FORBIDDEN: Editing Protected Files

These files cannot be edited by AI under any circumstances:

```
PER/INVARIANTS.md           — Invariant definitions
PER/DO_NOT_TOUCH.md         — Protected file list
specs/02-architecture/schema.sql — Database schema (without explicit approval)
.claude/instructions.md     — Claude instructions (without explicit approval)
.cursorrules                — Cursor rules (without explicit approval)
```

### FORBIDDEN: Creating Certain File Types

```
*.md in root (except approved ones)  — No random docs
*.env or *.secret                     — No secrets
*.test.ts without test content        — No empty tests
```

---

## COMMUNICATION VIOLATIONS

### FORBIDDEN: Vague Status Updates

```
// ❌ FORBIDDEN
"I think this might work"
"Let me try something"
"This should be good"

// ✅ CORRECT
"Created EntryScreen.tsx matching COLOR_SEMANTICS_LAW.md"
"Fixed: button now uses #5B2DFF per brand specification"
"Blocked: file X does not exist (PER-1 violation)"
```

### FORBIDDEN: Proceeding Without Approval

```
// ❌ FORBIDDEN — Making changes without plan
"I'll just make this change real quick..."
[edits files]

// ✅ CORRECT — Present plan first
"Plan: Edit EntryScreen.tsx to change button color from X to Y"
[wait for approval]
[then edit]
```

---

## QUICK REFERENCE

### Instant Fail Patterns

| Pattern | Why It Fails |
|---------|--------------|
| Green on entry screen | COLOR_SEMANTICS_LAW violation |
| justifyContent: 'center' on entry container | UAP-5 violation |
| Flat black background | Missing brand treatment |
| New screen not in registry | SCREEN_REGISTRY violation |
| New dependency | Requires explicit approval |
| Editing invariant logic | Constitutional violation |

### Detection Regex (For Tooling)

```regex
# Green on entry (in entry screen files)
backgroundColor:\s*['"]#(1FAD7E|34C759)['"]

# Card layout on entry
justifyContent:\s*['"]center['"].*alignItems:\s*['"]center['"]

# Wrong black
backgroundColor:\s*['"]#0D0D0D['"]
```

---

## SEMANTIC EQUIVALENTS (PATTERN RENAMING BYPASS)

AI may try to recreate banned patterns under different names.
The following are ALSO forbidden, even if named differently:

### Card-Like Containers (All Names Forbidden)

```tsx
// ❌ ALL OF THESE ARE FORBIDDEN on entry screens:

<HeroCard>           // Renamed card
<Panel>              // Renamed card
<OverlayContainer>   // Renamed card
<CenteredStack>      // Centered layout
<PrimaryContainer>   // Renamed card
<WelcomeTile>        // Renamed card
<ContentBox>         // Renamed card
<MainPanel>          // Renamed card
<CenteredWrapper>    // Centered layout
<ModalContainer>     // Modal-like card
<FloatingCard>       // Floating card
<ContentCard>        // Obvious card
```

### Visual Test (If It Looks Like a Card, It's Forbidden)

```
Does the layout have:
[ ] A distinct "box" floating in the center?
[ ] Empty space around all edges?
[ ] Content that could be a popup/modal?
[ ] A container that looks like it could be dismissed?

If ANY are checked → IT'S A CARD → FORBIDDEN
```

### The Rule

> **Renaming does not bypass prohibition.**
>
> If it visually resembles a card, modal, or centered popup,
> it is forbidden on entry screens regardless of what it's called.

---

## COPY DISGUISES (SAME CONTENT, DIFFERENT WORDS)

AI may reproduce forbidden copy with slight rewording:

### Forbidden Copy Patterns

```
❌ "Welcome to HustleXP"           → Too generic
❌ "Let's get started"             → Too generic
❌ "Your journey begins here"      → Too cliché
❌ "Ready to hustle?"              → Too informal
❌ "Sign up now"                   → Wrong CTA for entry
```

### Required Copy Pattern

```
✅ Headline: Value proposition (what user gets)
   Example: "Get things done. Get paid."

✅ Subheadline: How it works (mechanism)
   Example: "Post tasks and find help in minutes."

✅ CTA: Clear action (not generic)
   Example: "Get Started"
```

---

## PUZZLE MODE VIOLATIONS

### FORBIDDEN: Layer Boundary Violations

```swift
// ❌ FORBIDDEN — Screen (Layer 4) creating new atom
// In a screen file:
struct MyScreen: View {
    var body: some View {
        NewGlowEffect()  // ← Inventing an atom at screen layer
    }
}

// ✅ CORRECT — Screen uses only existing sections
struct MyScreen: View {
    var body: some View {
        ExistingSection()  // ← From Layer 3
    }
}
```

### FORBIDDEN: Raw Values Instead of Tokens

```swift
// ❌ FORBIDDEN — Using raw hex in molecule/section/screen
.foregroundColor(Color(hex: "#5B2DFF"))

// ✅ CORRECT — Using token from Layer 0
.foregroundColor(PuzzleColors.brandPrimary)
```

### FORBIDDEN: Missing Contracts/Manifests

```
// ❌ FORBIDDEN — Molecule without contract
ui-puzzle/molecules/NewMolecule/
├── NewMolecule.swift     ← EXISTS
└── (no contract file)    ← VIOLATION

// ✅ CORRECT — Molecule with contract
ui-puzzle/molecules/NewMolecule/
├── NewMolecule.swift
└── NewMolecule.contract.md  ← REQUIRED
```

### FORBIDDEN: Atoms Without Stress Tests

```
// ❌ FORBIDDEN — Atom promoted without stress test
ui-puzzle/atoms/NewAtom/
├── NewAtom.swift         ← EXISTS
└── (no stress file)      ← VIOLATION

// ✅ CORRECT — Atom with stress test
ui-puzzle/atoms/NewAtom/
├── NewAtom.swift
└── NewAtom.stress.md     ← REQUIRED
```

### FORBIDDEN: Screen Invention

```swift
// ❌ FORBIDDEN — Screen declaring new concepts
// EntryScreen.manifest.md
## New Atoms: CustomGlow       ← VIOLATION
## New Copy: "Welcome!"        ← VIOLATION
## New Motion: bounceIn        ← VIOLATION

// ✅ CORRECT — Screen as pure assembly
## New Atoms: NONE
## New Molecules: NONE
## New Copy: NONE
## New Motion: NONE
```

### FORBIDDEN: Section Answering Multiple Questions

```swift
// ❌ FORBIDDEN — Section doing too much
struct HeroAndActionSection: View {  // ← Answering TWO questions
    // "What is this?" AND "What do I do?"
}

// ✅ CORRECT — One section per question
struct EntryHeroSection: View {      // "What is this?"
struct EntryActionSection: View {    // "What do I do?"
```

---

## PUZZLE MODE QUICK REFERENCE

| Layer | Violation | Result |
|-------|-----------|--------|
| Screen creates atom | INSTANT REJECT | Must use existing atoms |
| Molecule uses raw color | REJECT | Must use PuzzleColors token |
| Atom without stress test | CANNOT PROMOTE | Stays at Layer 1 |
| Screen with "New Atoms: X" | INSTANT REJECT | Must be NONE |
| Section without contract | CANNOT USE | Contract required |

---

**If output matches ANY pattern in this document → REJECT and redo.**
**Renaming patterns does not make them acceptable.**
**Layer boundaries are inviolable. Higher layers CANNOT invent lower-layer concepts.**
