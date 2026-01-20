# Staging Specifications

**STATUS: DETAILED IMPLEMENTATION SPECS**
**Last Updated:** January 2025

---

## Purpose

This directory contains detailed implementation specifications that expand on sections of PRODUCT_SPEC.md. These specs provide:

- Implementation details
- Database schemas
- API contracts
- UI component specifications
- Edge case handling

---

## Authority Hierarchy

```
PRODUCT_SPEC.md (§X)  ← Canonical definition
        ↓
staging/X_SPEC.md     ← Implementation details
        ↓
Code implementation   ← Must match both
```

**If there is a conflict, PRODUCT_SPEC.md wins.**

---

## Specifications

| File | PRODUCT_SPEC Section | Status |
|------|---------------------|--------|
| `AI_TASK_COMPLETION_SPEC.md` | §8 | Complete |
| `MESSAGING_SPEC.md` | §10 | Complete |
| `NOTIFICATION_SPEC.md` | §11 | Stub |
| `RATING_SYSTEM_SPEC.md` | §12 | Stub |
| `ANALYTICS_SPEC.md` | §13 | Stub |
| `FRAUD_DETECTION_SPEC.md` | §14 | Stub |
| `CONTENT_MODERATION_SPEC.md` | §15 | Stub |
| `GDPR_COMPLIANCE_SPEC.md` | §16 | Stub |
| `TASK_DISCOVERY_SPEC.md` | §9 | Stub |

---

## Stub Files

Stub files contain:
- Link to PRODUCT_SPEC section
- Placeholder for future detailed implementation
- Key invariants copied from PRODUCT_SPEC

These will be expanded as features are implemented.

---

## Contributing

When adding a staging spec:

1. Copy structure from existing spec
2. Link to PRODUCT_SPEC section
3. Add to this README
4. Ensure no conflicts with PRODUCT_SPEC

---

**See PRODUCT_SPEC.md for all canonical definitions.**
