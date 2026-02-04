# Screen 5: Poster "Hustler on the Way" Screen
## Purpose: This is your DoorDash moment
**Authority:** DESIGN_SYSTEM.md, POSTER_UI_SPEC.md, SPATIAL_INTELLIGENCE_LOCKED.md (§5 Poster Visibility Protocol)
**Privacy:** INV-PRIVACY-2 — Worker location graduates with proximity. Raw GPS coordinates are NEVER sent to this screen at >100m. Server sends `PosterVisibleLocation` objects only.

### Stitch Prompt

```
Design a high-fidelity mobile app UI screen for HustleXP, a premium AI-powered gig marketplace.

Screen: Hustler On The Way (Poster View)

Style: Apple Glass aesthetic, clean typography, subtle glassmorphism, relief and certainty.
Design for iPhone 15 Pro Max viewport (430×932px). Dark mode preferred.

Visual Requirements:
- Full-screen status view
- Progress steps visible
- Hustler avatar (abstract, not creepy)
- Trust tier badge prominent

Content Layout (Centered, Vertical):

1. STATUS HEADER (Top 20%)
   - "Hustler on the way" (title, size: 32px, weight: 800, color: white, centered)
   - "Task accepted" (subtitle, size: 16px, color: #34C759, centered)

2. HUSTLER AVATAR (Middle 30%, centered)
   - Circular avatar (diameter: 120px)
   - Abstract design (geometric, not photo)
   - Trust tier badge overlay: "{TIER_LABEL} (Tier {N})" (bottom-right of avatar, pill-shaped, blue #007AFF) — Dynamic per worker's trust tier:
     - Tier 1 (NEW): "NEW (Tier 1)" — white text
     - Tier 2 (VERIFIED): "VERIFIED (Tier 2)" — blue #007AFF
     - Tier 3 (TRUSTED): "TRUSTED (Tier 3)" — green #34C759
     - Tier 4 (ELITE): "ELITE (Tier 4)" — gold #FFD700
     - Tier 5 (MASTER): "MASTER (Tier 5)" — purple #AF52DE
   - Subtle glow effect (not animated, just visual depth)

3. HUSTLER INFO (Below avatar)
   - Name: "Alex M." (size: 18px, weight: 700, color: white, centered, opacity: 0.9) — REFINEMENT: De-emphasized to not compete with system state
   - Stats: "47 tasks • 4.9★ rating" (size: 14px, color: #8E8E93, centered)

4. PROGRESS STEPS (Card, below info)
   - Glassmorphic card (background: rgba(28, 28, 30, 0.6), blur)
   - Step 1: "✓ Accepted" (green checkmark, completed)
   - Step 2: "→ En route" (current, amber accent)
   - Step 3: "○ Working" (upcoming, grey)
   - Step 4: "○ Completed" (upcoming, grey)
   - Visual connector line between steps

5. GRADUATED MAP VIEW (Below progress — SPATIAL_INTELLIGENCE §5.1)
   - Small interactive map (height: 160px, rounded corners, inset 16px)
   - Task pin always visible (center)
   - Worker representation GRADUATES with proximity (INV-PRIVACY-2):
     - >0.5mi: No worker marker. ETA text only. Map shows task pin + directional arrow (N/S/E/W).
     - ≤0.5mi: Shaded 200m-radius circle approaching task pin. No exact worker location.
     - ≤100m (ARRIVED): Precise worker pin appears on map.
   - Server sends `PosterVisibleLocation` objects, NEVER raw `{lat, lng}` at >100m.

6. ETA (Below map)
   - "Arriving in ~12 minutes" (size: 18px, weight: 600, color: white, centered)
   - "Based on current location" (subtext, size: 12px, color: #8E8E93, centered)

7. TASK DETAILS (Card, below ETA)
   - "Task: Move furniture — 2nd floor" (size: 16px, weight: 600)
   - "Pay: $45.00" (size: 14px, color: #34C759)
   - "Escrow protected" (badge, size: 12px, color: #8E8E93)
   - "HustleXP monitors this task end-to-end" (system assurance, size: 12px, color: #8E8E93, centered) — REFINEMENT: Reinforces accountability and institutional presence

8. CONTACT BUTTON (Bottom, fixed)
   - "Contact via HustleXP" (button, full-width minus margins, height: 44px, background: rgba(28, 28, 30, 0.8), white text, size: 16px, weight: 600) — REFINEMENT: Reinforces system mediation, reduces poster anxiety about bothering hustler

Spacing:
- Section spacing: 24px vertical
- Card padding: 20px
- Centered alignment for avatar and status

Typography:
- Font family: SF Pro Display
- Status: weight 800
- Names: weight 700
- Body: weight 400-500

Color Palette:
- Background: #000000
- Card background: rgba(28, 28, 30, 0.6) with blur
- Success: #34C759 (green)
- Current step: #FF9500 (amber)
- Trust tier: #007AFF (blue)
- Text primary: #FFFFFF
- Text secondary: #8E8E93

Tone: Relief. Certainty. Momentum. This is the moment of trust.

Constraints:
- Static UI only. No animations.
- Avatar is abstract (geometric shapes, not photo).
- Progress steps are clear but not cluttered.
- ETA is prominent but not stressful.
```

### Design Notes

**Why this matters:**
- This is the DoorDash moment (relief, certainty)
- Makes trust visible (tier badge, stats)
- Shows momentum (progress steps)
- Reduces anxiety (ETA, escrow protected)

**Visual Authority:**
- Large avatar = human connection (abstract, not creepy)
- Trust tier badge = earned status ("VERIFIED" human-readable, "Tier 2" system-transparent)
- Progress steps = system is working
- ETA = transparency
- System assurance line = accountability and institutional presence
- Contact button = system-mediated, not direct obligation

**Trust Signals:**
- Abstract avatar (not creepy, not fake)
- Stats visible (47 tasks, 4.9★)
- Escrow protected badge
- System is in control (progress steps)
- "HustleXP monitors this task end-to-end" = traceability
- "Contact via HustleXP" = system mediation, not direct obligation
- Hustler name de-emphasized = system state is hero, not individual

---

## Props Interface

```typescript
interface PosterHustlerOnWayProps {
  // Task data
  task: {
    id: string;
    title: string;
    price: number;                    // In cents
    state: 'ACCEPTED' | 'PROOF_SUBMITTED';
  };

  // Worker info
  worker: {
    id: string;
    displayName: string;              // e.g., "Alex M."
    avatarUrl?: string;
    trustTier: {
      level: 1 | 2 | 3 | 4;
      name: 'ROOKIE' | 'VERIFIED' | 'TRUSTED' | 'ELITE';
    };
    stats: {
      tasksCompleted: number;
      averageRating: number;
    };
  };

  // Progress
  currentStep: 'ACCEPTED' | 'EN_ROUTE' | 'WORKING' | 'COMPLETED';

  // ETA
  eta?: {
    minutes: number;
    basedOn: 'current_location' | 'estimate';
  };

  // Escrow
  escrowState: 'FUNDED' | 'LOCKED_DISPUTE';

  // Callbacks
  onContactWorker: () => void;
  onViewTaskDetails: () => void;

  // Optional
  testID?: string;
}
```

### Data Flow
- Task and worker data from `task.getById` with worker relation
- ETA computed from server-side `PosterVisibleLocation` updates (SPATIAL_INTELLIGENCE §5). Never from raw worker GPS.
- Progress steps derived from task state
- Contact opens task conversation screen
