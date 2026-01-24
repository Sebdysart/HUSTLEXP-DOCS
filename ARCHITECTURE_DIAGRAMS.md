# ARCHITECTURE DIAGRAMS — HUSTLEXP VISUAL REFERENCE

**STATUS: REFERENCE**
**PURPOSE: Visual representations of system architecture using Mermaid**
**LAST UPDATED: 2026-01-24**
**VERSION: 2.0.0**

---

## 1. Authority Hierarchy

The 7-layer authority model determines which system has final say over data.

```mermaid
flowchart TD
    subgraph "IMMUTABLE"
        L0[Layer 0: PostgreSQL Constraints<br/>CHECK, UNIQUE, FK, triggers]
    end

    subgraph "BACKEND AUTHORITY"
        L1[Layer 1: Backend State Machines<br/>Valid state transitions only]
        L2[Layer 2: Temporal Enforcement<br/>Workflow orchestration]
        L3[Layer 3: Stripe Integration<br/>Payment processing]
    end

    subgraph "AI LAYER"
        L4[Layer 4: AI Proposals<br/>Suggestions only, no authority]
    end

    subgraph "FRONTEND"
        L5[Layer 5: Frontend State<br/>UI state only]
        L6[Layer 6: Client Rendering<br/>Display layer]
    end

    L0 --> L1
    L1 --> L2
    L2 --> L3
    L3 --> L4
    L4 --> L5
    L5 --> L6

    style L0 fill:#ff6b6b,stroke:#c0392b,color:#fff
    style L1 fill:#4ecdc4,stroke:#16a085,color:#fff
    style L2 fill:#4ecdc4,stroke:#16a085,color:#fff
    style L3 fill:#4ecdc4,stroke:#16a085,color:#fff
    style L4 fill:#f39c12,stroke:#d68910,color:#fff
    style L5 fill:#9b59b6,stroke:#8e44ad,color:#fff
    style L6 fill:#9b59b6,stroke:#8e44ad,color:#fff
```

**Rule:** Higher layers cannot override lower layers. Database is constitutional.

---

## 2. Task Lifecycle State Machine

Every task follows this exact state progression. No shortcuts allowed.

```mermaid
stateDiagram-v2
    [*] --> DRAFT: Poster creates
    DRAFT --> POSTED: Poster funds escrow
    POSTED --> ACCEPTED: Hustler accepts
    ACCEPTED --> EN_ROUTE: Hustler starts travel
    EN_ROUTE --> WORKING: Hustler arrives
    WORKING --> PROOF_SUBMITTED: Hustler uploads proof

    PROOF_SUBMITTED --> APPROVED: Verification passes
    PROOF_SUBMITTED --> REJECTED: Verification fails

    REJECTED --> WORKING: Hustler retries

    APPROVED --> COMPLETED: Escrow released
    COMPLETED --> [*]

    note right of POSTED: 30-second acceptance window<br/>in Instant Mode
    note right of PROOF_SUBMITTED: AI + Human verification
    note left of COMPLETED: XP awarded here<br/>(INV-1, INV-2, INV-3)
```

---

## 3. Escrow Flow

Payment lifecycle tied to task completion.

```mermaid
flowchart LR
    subgraph "POSTER"
        CREATE[Create Task]
        FUND[Fund Escrow]
    end

    subgraph "ESCROW STATES"
        FUNDED((FUNDED))
        HELD((HELD))
        RELEASED((RELEASED))
        REFUNDED((REFUNDED))
    end

    subgraph "HUSTLER"
        COMPLETE[Complete Task]
        RECEIVE[Receive Payment]
    end

    subgraph "DISPUTE"
        DISPUTED((DISPUTED))
        REVIEW[Staff Review]
    end

    CREATE --> FUND
    FUND --> FUNDED
    FUNDED --> HELD
    HELD --> COMPLETE
    COMPLETE --> RELEASED
    RELEASED --> RECEIVE

    HELD --> DISPUTED
    DISPUTED --> REVIEW
    REVIEW --> RELEASED
    REVIEW --> REFUNDED

    style FUNDED fill:#f39c12,color:#fff
    style HELD fill:#3498db,color:#fff
    style RELEASED fill:#27ae60,color:#fff
    style REFUNDED fill:#e74c3c,color:#fff
    style DISPUTED fill:#9b59b6,color:#fff
```

**INV-4:** Escrow amount is immutable after FUNDED state.

---

## 4. PER Enforcement Chain

Every code change must pass through these gates.

```mermaid
flowchart TD
    REQ[User Request] --> PER0{PER-0<br/>In Scope?}

    PER0 -->|No| REJECT1[REJECT<br/>Not in FINISHED_STATE]
    PER0 -->|Yes| PER1{PER-1<br/>Files Exist?}

    PER1 -->|No| REJECT2[REJECT<br/>Missing dependencies]
    PER1 -->|Yes| PER2{PER-2<br/>Plan Approved?}

    PER2 -->|No| PLAN[Create Plan<br/>Get approval]
    PLAN --> PER2
    PER2 -->|Yes| PER3{PER-3<br/>Invariants OK?}

    PER3 -->|No| FIX1[Fix Invariants]
    FIX1 --> PER3
    PER3 -->|Yes| IMPL[Implementation]

    IMPL --> PER4{PER-4<br/>Tests Pass?}
    PER4 -->|No| FIX2[Fix Tests]
    FIX2 --> PER4
    PER4 -->|Yes| PER5{PER-5<br/>Blast Radius OK?}

    PER5 -->|No| SCOPE[Reduce Scope]
    SCOPE --> PER5
    PER5 -->|Yes| PER6{PER-6<br/>Human Audit?}

    PER6 -->|No| AUDIT[Request Review]
    AUDIT --> PER6
    PER6 -->|Yes| MERGE[MERGE]

    style REJECT1 fill:#e74c3c,color:#fff
    style REJECT2 fill:#e74c3c,color:#fff
    style MERGE fill:#27ae60,color:#fff
    style IMPL fill:#3498db,color:#fff
```

---

## 5. HIC Invocation Flow

Every Cursor response follows this mandatory syscall.

```mermaid
flowchart TD
    REQ[User Prompt] --> INVOKE[HUSTLEXP_INVOCATION]

    INVOKE --> STEP0[STEP 0: REPO RE-ANCHOR<br/>Read all 12 PER documents]
    STEP0 --> STEP1[STEP 1: COLD START VERIFICATION<br/>Output proof of alignment]

    STEP1 --> STEP2[STEP 2: PROTOCOL CLASSIFICATION<br/>Exactly ONE mode]

    STEP2 --> RESEARCH[RESEARCH_MODE]
    STEP2 --> IMPLEMENT[IMPLEMENTATION_MODE]
    STEP2 --> VALIDATE[VALIDATION_MODE]
    STEP2 --> RECOVERY[RECOVERY_MODE]
    STEP2 --> CLARIFY[CLARIFICATION_REQUIRED]

    RESEARCH --> STEP3{STEP 3: LEGALITY CHECK}
    IMPLEMENT --> STEP3
    VALIDATE --> STEP3
    RECOVERY --> STEP3

    CLARIFY --> STOP[STOP → ASK]

    STEP3 -->|ILLEGAL| STOP2[STOP → CANNOT PROCEED]
    STEP3 -->|LEGAL| STEP4[STEP 4: PLAN<br/>Map to gates, declare files]

    STEP4 --> STEP5[STEP 5: EXECUTE]

    STEP5 --> CHECK[Run SELF_CHECK]
    CHECK --> OUTPUT[OUTPUT with HIC header]

    style STOP fill:#f39c12,color:#fff
    style STOP2 fill:#e74c3c,color:#fff
    style OUTPUT fill:#27ae60,color:#fff
```

---

## 6. Trust Tier Progression

6-level trust system gating task complexity.

```mermaid
flowchart LR
    subgraph "TRUST TIERS"
        T0[T0: Unverified<br/>Basic tasks only]
        T1[T1: Email Verified<br/>Low-value tasks]
        T2[T2: Identity Verified<br/>Standard tasks]
        T3[T3: Background Checked<br/>In-home tasks]
        T4[T4: Insured<br/>High-value tasks]
        T5[T5: Elite<br/>All tasks unlocked]
    end

    T0 -->|Email verify| T1
    T1 -->|ID verify| T2
    T2 -->|Background check| T3
    T3 -->|Insurance upload| T4
    T4 -->|XP threshold + history| T5

    style T0 fill:#95a5a6,color:#fff
    style T1 fill:#3498db,color:#fff
    style T2 fill:#2ecc71,color:#fff
    style T3 fill:#f39c12,color:#fff
    style T4 fill:#9b59b6,color:#fff
    style T5 fill:#e74c3c,color:#fff
```

---

## 7. XP Award Flow

XP is only awarded after escrow release (INV-1).

```mermaid
sequenceDiagram
    participant H as Hustler
    participant T as Task System
    participant E as Escrow
    participant X as XP System
    participant DB as Database

    H->>T: Complete Task
    T->>T: Verify Proof
    T->>E: Request Release
    E->>E: Check Conditions

    alt Conditions Met
        E->>DB: UPDATE escrow_status = RELEASED
        E->>X: Trigger XP Award
        X->>DB: INSERT INTO xp_ledger
        X->>H: XP Awarded
    else Conditions Not Met
        E->>T: Reject Release
        T->>H: Action Required
    end

    Note over DB: INV-1: XP requires RELEASED escrow
    Note over DB: INV-5: XP issuance is idempotent
```

---

## 8. Color Semantics Flow

Brand color application follows strict semantic rules.

```mermaid
flowchart TD
    SCREEN[Screen Type?] --> ENTRY{Entry/Welcome?}

    ENTRY -->|Yes| PURPLE[PURPLE ONLY<br/>#5B2DFF gradient]
    ENTRY -->|No| CONTEXT{Context?}

    CONTEXT -->|Success State| GREEN[GREEN<br/>#34C759]
    CONTEXT -->|Error State| RED[RED<br/>#FF3B30]
    CONTEXT -->|Warning State| ORANGE[ORANGE<br/>#FF9500]
    CONTEXT -->|Info State| BLUE[BLUE<br/>#007AFF]
    CONTEXT -->|Default| BLACK[BLACK<br/>#0B0B0F]

    PURPLE --> GRADIENT[Apply Entry Gradient<br/>['#1a0a2e', '#0B0B0F', '#000']]
    GRADIENT --> GLOW[Add Purple Glow<br/>#5B2DFF @ 0.2 opacity]

    style PURPLE fill:#5B2DFF,color:#fff
    style GREEN fill:#34C759,color:#fff
    style RED fill:#FF3B30,color:#fff
    style ORANGE fill:#FF9500,color:#fff
    style BLUE fill:#007AFF,color:#fff
    style BLACK fill:#0B0B0F,color:#fff
```

---

## 9. Database Entity Relationships

Core tables and their relationships.

```mermaid
erDiagram
    USERS ||--o{ PROFILES : has
    USERS ||--o{ TASKS : creates
    USERS ||--o{ TASK_ASSIGNMENTS : performs

    TASKS ||--|| ESCROW_TRANSACTIONS : funded_by
    TASKS ||--o{ TASK_ASSIGNMENTS : has
    TASKS ||--o{ PROOF_SUBMISSIONS : requires

    TASK_ASSIGNMENTS ||--o{ PROOF_SUBMISSIONS : uploads

    ESCROW_TRANSACTIONS ||--o{ XP_LEDGER : triggers

    PROFILES ||--|| CAPABILITY_PROFILES : defines
    PROFILES ||--|| TRUST_HISTORY : tracks

    USERS {
        uuid id PK
        string email
        string firebase_uid
        timestamp created_at
    }

    TASKS {
        uuid id PK
        uuid poster_id FK
        string status
        decimal amount
        timestamp deadline
    }

    ESCROW_TRANSACTIONS {
        uuid id PK
        uuid task_id FK
        string status
        decimal amount
        timestamp funded_at
    }
```

---

## 10. UAP Gate Chain

UI Acceptance Protocol gates every screen must pass.

```mermaid
flowchart LR
    SCREEN[Screen] --> UAP1{UAP-1<br/>Token Compliance?}

    UAP1 -->|No| FAIL1[FAIL: Use DESIGN_SYSTEM tokens]
    UAP1 -->|Yes| UAP2{UAP-2<br/>300ms Polish?}

    UAP2 -->|No| FAIL2[FAIL: Animations too slow]
    UAP2 -->|Yes| UAP3{UAP-3<br/>Accessibility?}

    UAP3 -->|No| FAIL3[FAIL: VoiceOver/contrast]
    UAP3 -->|Yes| UAP4{UAP-4<br/>Empty/Error States?}

    UAP4 -->|No| FAIL4[FAIL: Missing states]
    UAP4 -->|Yes| UAP5{UAP-5<br/>Full-Canvas?}

    UAP5 -->|No| FAIL5[FAIL: Card layout detected]
    UAP5 -->|Yes| PASS[PASS: Screen Approved]

    style PASS fill:#27ae60,color:#fff
    style FAIL1 fill:#e74c3c,color:#fff
    style FAIL2 fill:#e74c3c,color:#fff
    style FAIL3 fill:#e74c3c,color:#fff
    style FAIL4 fill:#e74c3c,color:#fff
    style FAIL5 fill:#e74c3c,color:#fff
```

---

## 11. Context Loading Levels

Progressive context management for AI tools.

```mermaid
flowchart TD
    START[Session Start] --> L1[Level 1: Foundation]

    L1 --> CURSOR_L1[Cursor: .cursorrules + CURRENT_PHASE.md]
    L1 --> CLAUDE_L1[Claude: .claude/instructions.md + CURRENT_PHASE.md]

    CURSOR_L1 --> TASK{Task Type?}
    CLAUDE_L1 --> TASK

    TASK -->|Frontend| L2_FE[Level 2: CURSOR_INSTRUCTIONS + DESIGN_SYSTEM]
    TASK -->|Backend| L2_BE[Level 2: BUILD_GUIDE + API_CONTRACT]
    TASK -->|iOS| L2_IOS[Level 2: ios-swiftui README]
    TASK -->|Database| L2_DB[Level 2: schema.sql + INVARIANTS]

    L2_FE --> L3[Level 3: Reference<br/>Lookup only when needed]
    L2_BE --> L3
    L2_IOS --> L3
    L2_DB --> L3

    L3 --> TOKENS[Design tokens]
    L3 --> ERRORS[Error codes]
    L3 --> UAP[UAP gates]

    style L1 fill:#e74c3c,color:#fff
    style L2_FE fill:#f39c12,color:#fff
    style L2_BE fill:#f39c12,color:#fff
    style L2_IOS fill:#f39c12,color:#fff
    style L2_DB fill:#f39c12,color:#fff
    style L3 fill:#3498db,color:#fff
```

---

## Rendering Note

These diagrams use Mermaid syntax. They render automatically on:
- GitHub (README, markdown files)
- VS Code with Mermaid extension
- Notion (via embed)

To preview locally: Use VS Code "Markdown Preview Enhanced" or similar extension.

---

## Cross-References

- `APP_OVERVIEW.md` — System summary
- `specs/02-architecture/schema.sql` — Full database schema
- `PER/PER_MASTER_INDEX.md` — PER system details
- `PER/INVOCATION_COMMAND.md` — HIC specification
- `PER/UI_ACCEPTANCE_PROTOCOL.md` — UAP gates
- `COLOR_SEMANTICS_LAW.md` — Color rules
