# MOLECULE REGISTRY — HUSTLEXP COMPOSITE ELEMENTS

**STATUS: LOCKED — These are the ONLY composite elements**

---

## WHAT IS A MOLECULE?

A molecule is a **combination of atoms** that serves a specific purpose.
Molecules are reusable across screens but never contain business logic.

---

## MOLECULE INDEX

| Molecule | Purpose | Atoms Used | File |
|----------|---------|------------|------|
| **TaskCard** | Display task summary | Text, Badge, Icon, Avatar | `TaskCard.md` |
| **UserHeader** | Display user info with stats | Avatar, Text, Badge | `UserHeader.md` |
| **PriceDisplay** | Show monetary amounts | Text, Icon | `PriceDisplay.md` |
| **RatingStars** | Show/input ratings | Icon, Text | `RatingStars.md` |
| **ProgressBar** | Show progress | - (custom) | `ProgressBar.md` |
| **StatusBadge** | Show task/user status | Badge, Icon | `StatusBadge.md` |
| **EmptyState** | No data state | Icon, Text, Button | `EmptyState.md` |
| **ErrorState** | Error state | Icon, Text, Button | `ErrorState.md` |
| **LoadingState** | Loading state | - (spinner) | `LoadingState.md` |
| **ListItem** | Generic list row | Icon, Text, Badge | `ListItem.md` |
| **FormField** | Input with label/error | Text, Input | `FormField.md` |
| **ActionBar** | Bottom action buttons | Button, Spacer | `ActionBar.md` |

**Total: 12 molecules**

---

## MOLECULE RULES

### Creation Rules
```
✅ Molecules are LOCKED once approved
✅ Molecules are composed of ATOMS only
✅ Molecules are reusable across screens
✅ Molecules receive ALL data via props
❌ Molecules NEVER contain business logic
❌ Molecules NEVER fetch data
❌ Molecules NEVER compute eligibility/XP/trust
❌ Molecules are NEVER duplicated with variations
```

### Usage Rules
```
✅ Import from: src/components/molecules/
✅ Pass all data via props
✅ Use callback props for actions (onPress, onChange)
❌ Do NOT compute anything inside molecules
❌ Do NOT add inline styles
❌ Do NOT create "custom" versions
```

---

## MOLECULE CONTRACT

Every molecule MUST have:

```typescript
interface MoleculeContract<T> {
  // Data (passed in, never fetched)
  data: T;
  
  // State
  isLoading?: boolean;
  
  // Actions (callbacks, no logic)
  onPress?: () => void;
  onAction?: (action: string) => void;
  
  // Accessibility
  accessibilityLabel?: string;
}
```

---

## MOLECULE → ARCHETYPE MAPPING

| Molecule | Archetypes | Usage |
|----------|------------|-------|
| TaskCard | B, C | Feed items, active tasks |
| UserHeader | D, E | Profile headers |
| PriceDisplay | B, C | Task pricing |
| RatingStars | C, E | Reviews, profiles |
| ProgressBar | C, D, E | Task progress, XP |
| StatusBadge | B, C, E | Task/user status |
| EmptyState | A, B, F | No data scenarios |
| ErrorState | F | Error scenarios |
| LoadingState | ALL | Loading scenarios |
| ListItem | D, E | Settings, lists |
| FormField | A, D | Forms, inputs |
| ActionBar | A, C, D | Screen actions |

---

## ADDING NEW MOLECULES

**Process:**
1. Verify it cannot be achieved with existing molecules
2. Create spec file in `ui-puzzle/molecules/[Name].md`
3. Get approval from product owner
4. Implement in `src/components/molecules/[Name].tsx`
5. Stress test across 3+ screens
6. Lock spec and implementation

**Approval required because:**
- Molecules are shared across screens
- Inconsistent molecules = inconsistent product
- Every molecule must pass chosen-state test
