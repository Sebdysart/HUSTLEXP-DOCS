# ATOM REGISTRY — HUSTLEXP UI PRIMITIVES

**STATUS: LOCKED — These are the ONLY primitive elements**

---

## WHAT IS AN ATOM?

An atom is a **single-purpose visual element** that cannot be broken down further.
Atoms are the lowest level of the UI puzzle.

---

## ATOM INDEX

| Atom | Purpose | Variants | File |
|------|---------|----------|------|
| **Button** | User actions | primary, secondary, ghost, danger | `Button.md` |
| **Text** | Display text | heading, body, caption, label, micro | `Text.md` |
| **Input** | User input | text, password, number, multiline | `Input.md` |
| **Icon** | Visual symbols | (from approved set only) | `Icon.md` |
| **Avatar** | User images | small, medium, large | `Avatar.md` |
| **Badge** | Status/counts | status, count, tier | `Badge.md` |
| **Divider** | Visual separation | horizontal, vertical | `Divider.md` |
| **Spacer** | Layout spacing | xs, sm, md, lg, xl | `Spacer.md` |
| **Image** | Display images | rounded, square, full | `Image.md` |

**Total: 9 atoms**

---

## ATOM RULES

### Creation Rules
```
✅ Atoms are LOCKED once approved
✅ Atoms are used across ALL screens
✅ Atoms use design tokens ONLY (no hardcoded values)
❌ Atoms are NEVER modified for specific screens
❌ Atoms are NEVER duplicated with variations
❌ Atoms do NOT contain business logic
❌ Atoms do NOT fetch data
```

### Usage Rules
```
✅ Import from: src/components/atoms/
✅ Use exactly as specified
✅ Combine into molecules for complex patterns
❌ Do NOT style atoms inline
❌ Do NOT create "custom" versions
```

---

## ATOM CONTRACT

Every atom MUST have:

```typescript
interface AtomContract {
  // Visual props
  variant?: string;        // From approved variants only
  size?: 'sm' | 'md' | 'lg';
  
  // State props
  disabled?: boolean;
  loading?: boolean;
  
  // Event props
  onPress?: () => void;    // For interactive atoms
  
  // Accessibility
  accessibilityLabel: string;
}
```

---

## ADDING NEW ATOMS

**Process:**
1. Create spec file in `ui-puzzle/atoms/[Name].md`
2. Get approval from product owner
3. Implement in `src/components/atoms/[Name].tsx`
4. Stress test across 3+ screens
5. Lock spec and implementation

**Approval required because:**
- Atoms propagate to ALL screens
- Wrong atom = 38 screens affected
- Atoms are the foundation of quality
