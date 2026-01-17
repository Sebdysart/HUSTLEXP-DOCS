# HustleXP UI Specs

**Source of truth for all UI components, tokens, and screen specifications.**

This directory contains the canonical design language for the HustleXP app.

## Structure

```
ui-specs/
├── components/          # Component specifications (glass-card.md, etc.)
├── tokens/             # Design tokens (colors.json, spacing.json, etc.)
└── stitch-prompts/     # Stitch design prompts (migrated from backend repo)
```

## Authority Model

**HUSTLEXP-DOCS = LAW**  
**App repo = COMPILER**

All UI implementation in `hustlexp-app` must reference specs in this directory. No design decisions are made in code.

## External References

- **Stitch Project**: https://stitch.withgoogle.com/projects/16815727890231502478
  - Visual designs generated from `stitch-prompts/`
  - Reference for visual validation and design review

## Status

- ✅ Components declared (LOCKED v1)
- ✅ Tokens declared (JSON format)
- ⏳ Stitch prompts migration (Step 2 pending)
- ⏳ Screen registry (Step 3 pending)
