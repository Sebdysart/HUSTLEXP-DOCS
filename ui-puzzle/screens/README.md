# Screens — Layer 4

> **Pure assembly. No invention.**

Screens are assemblies of pre-approved sections. They contain NO new concepts.

---

## Available Screens

| Screen | Sections Used | Purpose |
|--------|---------------|---------|
| `EntryScreen` | EntryHeroSection, EntryActionSection | First screen users see |

---

## Rules

1. **Assembly only** — Screens ONLY arrange sections
2. **No new atoms** — Cannot introduce visual concepts
3. **No new molecules** — Cannot combine atoms
4. **No new copy** — All text comes from sections
5. **No new motion** — All animation comes from lower layers
6. **Assembly manifest required** — Must declare exactly what's used

---

## Folder Structure

```
screens/
├── ScreenName/
│   ├── ScreenName.swift       # Implementation
│   └── ScreenName.manifest.md # Assembly manifest
```

---

## Assembly Manifest Template

```markdown
## Assembly Manifest: [ScreenName]

### Sections Used
1. SectionA (position: top)
2. SectionB (position: bottom)

### New Atoms: NONE
### New Molecules: NONE
### New Copy: NONE
### New Motion: NONE

### Cursor Scope
- [ ] Layout positioning
- [ ] Section spacing
- [ ] Safe area handling
- [ ] Background placement
```

---

## What Cursor CAN Do at Screen Level

- Position sections vertically
- Apply screen-level padding
- Handle safe areas
- Place background behind content
- Connect section callbacks to navigation

## What Cursor CANNOT Do at Screen Level

- Create new visual elements
- Modify section internals
- Add text not defined in sections
- Add animations not defined in lower layers
- Invent anything
