# Reference Implementation (Scaffold Code)

⚠️ **WARNING: This is NOT production code.**

---

## What This Is

This folder contains **reference implementation scaffold code** that demonstrates:

- State machine structure matching backend definitions
- Screen organization following UI_SPEC rules
- Component patterns following accessibility requirements

## What This Is NOT

- ❌ Production-ready code
- ❌ Tested or verified code
- ❌ The actual app to ship

## Purpose

This code exists to:

1. **Validate spec feasibility** - Prove the specs can be implemented
2. **Provide implementation guidance** - Show patterns to follow
3. **Establish conventions** - Naming, structure, organization

## Using This Code

**DO:**
- Reference for patterns and structure
- Copy component interfaces
- Use as starting point for real implementation

**DO NOT:**
- Deploy this code
- Assume it works correctly
- Skip testing because "it's already written"

## Structure

```
reference/
├── App.js              ← Entry point
├── index.js            ← React Native registration
├── app.json            ← Expo/RN config
├── package.json        ← Dependencies
├── components/         ← Shared UI components
├── screens/            ← Screen components
├── state/              ← State machines
├── navigation/         ← Navigation structure
├── constants/          ← Design tokens
└── assets/             ← Images & icons
```

## Production Implementation

For production, follow:

1. `specs/04-backend/BUILD_GUIDE.md` - Build phases
2. `screens-spec/SCREEN_REGISTRY.md` - Screen specs
3. `.cursorrules` - Frontend rules

---

*This is scaffold code. Build real code following the specs.*
