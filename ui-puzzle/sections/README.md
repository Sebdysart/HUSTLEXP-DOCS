# Sections — Layer 3

> **Narrative fragments. One job per section.**

Sections are screen regions with a single narrative purpose. Each section answers ONE question.

---

## Available Sections

| Section | Question Answered | Molecules Used |
|---------|-------------------|----------------|
| `EntryHeroSection` | "What is this app?" | BrandCluster, TypeReveal |
| `EntryActionSection` | "What do I do next?" | CTAStack |

---

## Rules

1. **One job** — Each section answers exactly ONE question
2. **Approved molecules only** — Can only use molecules with contracts
3. **UAP-0 to UAP-3** — Must pass first 4 UAP gates
4. **No screen logic** — No navigation, no full-screen layout
5. **Section contract required** — Must declare purpose and boundaries

---

## Folder Structure

```
sections/
├── SectionName/
│   ├── SectionName.swift       # Implementation
│   ├── SectionName.contract.md # Purpose and rules
│   └── SectionName.stress.md   # Stress test results
```

---

## Section Contract Template

```markdown
## Section Contract: [SectionName]

### Purpose (ONE sentence only)
[What single question does this section answer?]

### Molecules Used
- MoleculeA
- MoleculeB

### Forbidden Content
- [What this section must NOT communicate]

### UAP Compliance
- [ ] UAP-0: Visible hierarchy
- [ ] UAP-1: Motion continuity
- [ ] UAP-2: Action clarity
- [ ] UAP-3: Loading elegance
```
