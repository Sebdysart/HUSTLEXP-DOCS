# HustleXP Architecture Diagrams

**Purpose:** Visual representations of system architecture using Mermaid syntax for GitHub rendering.

**Last Updated:** 2025-01-23

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

## 5. Trust Tier Progression

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

**Each tier unlocks:**
- Higher task values
- More task categories
- Additional capabilities

---

## 6. XP Award Flow

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
        E->>DB: Update escrow_status = RELEASED
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

## 7. Proof Verification Flow

Two-stage verification: AI first, human escalation.

```mermaid
flowchart TD
    SUBMIT[Hustler Submits Proof] --> AI{AI Verification}

    AI -->|High Confidence Pass| PASS1[Auto-Approve]
    AI -->|High Confidence Fail| FAIL1[Auto-Reject]
    AI -->|Low Confidence| HUMAN{Human Review}

    HUMAN -->|Approve| PASS2[Human Approved]
    HUMAN -->|Reject| FAIL2[Human Rejected]

    PASS1 --> RELEASE[Release Escrow]
    PASS2 --> RELEASE

    FAIL1 --> RETRY{Retry Allowed?}
    FAIL2 --> RETRY

    RETRY -->|Yes| RESUBMIT[Hustler Resubmits]
    RETRY -->|No| DISPUTE[Open Dispute]

    RESUBMIT --> AI

    style PASS1 fill:#27ae60,color:#fff
    style PASS2 fill:#27ae60,color:#fff
    style FAIL1 fill:#e74c3c,color:#fff
    style FAIL2 fill:#e74c3c,color:#fff
    style RELEASE fill:#2ecc71,color:#fff
```

---

## 8. Screen Navigation (Hustler Flow)

Main user journey for task workers.

```mermaid
flowchart TD
    subgraph "AUTH"
        LOGIN[Login Screen]
        SIGNUP[Signup Screen]
    end

    subgraph "ONBOARDING"
        FRAMING[Framing]
        CALIBRATION[Calibration]
        ROLE[Role Selection]
        CAPABILITIES[Capability Setup<br/>8 screens]
    end

    subgraph "MAIN APP"
        HOME[Hustler Home]
        FEED[Task Feed]
        DETAIL[Task Detail]
        INPROGRESS[Task In Progress]
        COMPLETION[Task Completion]
        XP[XP Breakdown]
    end

    subgraph "INSTANT MODE"
        INTERRUPT[Instant Interrupt Card]
    end

    LOGIN --> HOME
    SIGNUP --> FRAMING
    FRAMING --> CALIBRATION
    CALIBRATION --> ROLE
    ROLE --> CAPABILITIES
    CAPABILITIES --> HOME

    HOME --> FEED
    FEED --> DETAIL
    DETAIL --> INPROGRESS
    INPROGRESS --> COMPLETION
    COMPLETION --> XP
    XP --> HOME

    HOME -.->|Instant Mode On| INTERRUPT
    INTERRUPT -->|Accept| INPROGRESS
    INTERRUPT -->|Skip| HOME

    style HOME fill:#3498db,color:#fff
    style INTERRUPT fill:#f39c12,color:#fff
```

---

## 9. Database Entity Relationships (Simplified)

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

## 10. iOS SwiftUI Package Structure

```mermaid
flowchart TD
    subgraph "HustleXP Package"
        PKG[Package.swift<br/>iOS 17+, macOS 14+]

        subgraph "Sources/HustleXP"
            MAIN[HustleXP.swift<br/>Version info + Catalog]

            subgraph "DesignSystem"
                COLORS[HustleColors.swift]
                TYPO[HustleTypography.swift]
                COMP[HustleComponents.swift]
            end

            subgraph "Screens (15)"
                S1[InstantInterruptCard]
                S2[HustlerHomeScreen]
                S3[TrustTierLadderScreen]
                S4[TaskInProgressScreen]
                S5[XPBreakdownScreen]
                S6[TaskCompletion x3]
                S7[PosterTaskCompletion]
                S8[TrustChangeExplanation]
                S9[DisputeEntryScreen]
                S10[Edge States x3]
            end
        end
    end

    PKG --> MAIN
    MAIN --> COLORS
    MAIN --> TYPO
    MAIN --> COMP
    MAIN --> S1

    style PKG fill:#f39c12,color:#fff
    style MAIN fill:#3498db,color:#fff
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
- `screens-spec/SCREEN_REGISTRY.md` — All 38 screens
- `specs/01-product/PRODUCT_SPEC.md` — Full product specification
