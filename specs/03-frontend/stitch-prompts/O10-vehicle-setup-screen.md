# Screen O10: Vehicle Setup Screen
## Status: IMPLEMENTATION SPEC
**Authority:** DESIGN_SYSTEM.md, ONBOARDING_SPEC.md
**Cursor-Ready:** YES
**Role:** Hustler Only (conditional)

---

## Overview

Hustlers who selected "Transportation" capabilities add vehicle details. Required for delivery and transport tasks.

---

## Layout

```
┌─────────────────────────────────────────┐
│ ←                                       │
│                                         │
│      Tell us about your vehicle         │  ← typography.h1
│                                         │
│   Required for delivery and             │  ← typography.body
│   transport tasks.                      │
│                                         │
├─────────────────────────────────────────┤
│                                         │
│   Vehicle type                          │  ← Label
│                                         │
│  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐   │
│  │ 🚗   │ │ 🚙   │ │ 🛻   │ │ 🚚   │   │  ← Vehicle type chips
│  │ Car  │ │ SUV  │ │Truck │ │ Van  │   │
│  └──────┘ └──────┘ └──────┘ └──────┘   │
│                                         │
│   Cargo capacity                        │
│                                         │
│  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐   │
│  │Small │ │Medium│ │Large │ │X-Large│  │
│  │Boxes │ │Furn. │ │Move  │ │Truck │   │
│  └──────┘ └──────┘ └──────┘ └──────┘   │
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ Make                                ││
│  └─────────────────────────────────────┘│
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ Model                               ││
│  └─────────────────────────────────────┘│
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ Year                                ││
│  └─────────────────────────────────────┘│
│                                         │
│  ┌─────────────────────────────────────┐│
│  │ License Plate                       ││
│  └─────────────────────────────────────┘│
│                                         │
│  ┌─────────────────────────────────────┐│
│  │           Continue                  ││
│  └─────────────────────────────────────┘│
│                                         │
│     I don't have a vehicle             │  ← Link
│                                         │
└─────────────────────────────────────────┘
```

---

## Props Interface

```typescript
interface VehicleSetupScreenProps {
  // Vehicle data
  vehicleType?: 'CAR' | 'SUV' | 'TRUCK' | 'VAN' | null;
  cargoCapacity?: 'SMALL' | 'MEDIUM' | 'LARGE' | 'XLARGE' | null;
  make?: string;
  model?: string;
  year?: string;
  licensePlate?: string;

  // Callbacks
  onVehicleTypeChange?: (type: string) => void;
  onCargoCapacityChange?: (capacity: string) => void;
  onMakeChange?: (make: string) => void;
  onModelChange?: (model: string) => void;
  onYearChange?: (year: string) => void;
  onLicensePlateChange?: (plate: string) => void;
  onContinue?: () => void;
  onNoVehicle?: () => void;
  onBack?: () => void;
}
```

---

## Visual Spec

| Element | Style |
|---------|-------|
| Title | `typography.h1`, `colors.neutral[900]` |
| Subtitle | `typography.body`, `colors.neutral[600]` |
| Labels | `typography.bodySmall`, `colors.neutral[600]` |
| Type chips | 64px square, `radius.lg`, icon 32px |
| Selected chip | `colors.primary[500]` border, `colors.primary[50]` bg |
| Unselected chip | `colors.neutral[200]` border |
| Chip label | `typography.caption`, centered |
| Input fields | `inputStyles.default`, 48px height |
| Button | `buttonVariants.primary`, `buttonSizes.lg` |
| No vehicle link | `typography.body`, `colors.neutral[500]` |

---

## Vehicle Types

| Icon | Label | Value |
|------|-------|-------|
| 🚗 | Car | CAR |
| 🚙 | SUV | SUV |
| 🛻 | Truck | TRUCK |
| 🚚 | Van | VAN |

---

## Cargo Capacity

| Label | Description | Value |
|-------|-------------|-------|
| Small | Boxes, groceries | SMALL |
| Medium | Small furniture | MEDIUM |
| Large | Full move | LARGE |
| X-Large | Commercial | XLARGE |

---

## Validation

- Vehicle type required
- Cargo capacity required
- Make, Model, Year recommended but optional
- License plate optional (can add later)
- Continue enabled when type and capacity selected

---

## "No Vehicle" Flow

If user taps "I don't have a vehicle":
- Remove transportation capabilities
- Skip to next relevant screen
- Show confirmation: "No problem! You can add a vehicle later in settings."

---

**This screen is Cursor-ready. Build exactly as specified.**
