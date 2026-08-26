# SKILL TAXONOMY — HUSTLEXP v1.0

**STATUS: CONSTITUTIONAL — Canonical skill enumeration**
**Authority: PRODUCT_SPEC §17 (Capability System), CAPABILITY_PROFILE_SCHEMA_LOCKED.md**
**Cross-Reference: POSTER_TASK_CREATION_RISK_CLASSIFIER_LOCKED.md (risk levels)**
**Version: v1.0.0**

---

## §1. Purpose

This document enumerates every skill a worker can claim in HustleXP. It is the single source of truth for:

- O5 Skill Cloud UI (what bubbles appear)
- `capability_claims.skill_id` values (what gets stored)
- Feed filtering (what tasks match which skills)
- Risk classification baseline (what risk level a skill inherits)
- Verification gating (which skills require credentials)
- IC classification evidence (self-selection breadth)

**Rule:** If a skill is not in this taxonomy, it does not exist in HustleXP.

---

## §2. Hierarchy

```
Category (6)
  └── Subcategory (grouping for UI)
      └── Skill (atomic unit — what workers claim)
```

---

## §3. Category 1: Physical Tasks (📦)

### 3.1 Moving & Hauling

| Skill ID | Display Name | Risk | Regulated | Min Tier | Gate |
|----------|-------------|------|-----------|----------|------|
| `moving_help` | Moving Help | LOW | No | 1 | — |
| `furniture_moving` | Furniture Moving | LOW | No | 1 | — |
| `heavy_lifting` | Heavy Lifting | LOW | No | 1 | — |
| `hauling` | Hauling & Disposal | LOW | No | 1 | — |
| `junk_removal` | Junk Removal | LOW | No | 1 | — |
| `loading_unloading` | Loading / Unloading | LOW | No | 1 | — |
| `packing` | Packing & Unpacking | LOW | No | 1 | — |
| `storage_organization` | Storage Organization | LOW | No | 1 | — |

### 3.2 Cleaning

| Skill ID | Display Name | Risk | Regulated | Min Tier | Gate |
|----------|-------------|------|-----------|----------|------|
| `house_cleaning` | House Cleaning | LOW | No | 1 | — |
| `deep_cleaning` | Deep Cleaning | LOW | No | 1 | — |
| `office_cleaning` | Office Cleaning | LOW | No | 1 | — |
| `post_construction_clean` | Post-Construction Cleaning | MEDIUM | No | 2 | ID verified |
| `carpet_cleaning` | Carpet Cleaning | LOW | No | 1 | — |
| `window_cleaning_ext` | Window Cleaning (Exterior) | MEDIUM | No | 2 | ID verified |
| `pressure_washing` | Pressure Washing | MEDIUM | No | 2 | ID verified |
| `gutter_cleaning` | Gutter Cleaning | MEDIUM | No | 2 | ID verified |
| `hazardous_cleanup` | Hazardous Material Cleanup | HIGH | Yes | 4 | Certification |

### 3.3 Yard & Outdoor

| Skill ID | Display Name | Risk | Regulated | Min Tier | Gate |
|----------|-------------|------|-----------|----------|------|
| `lawn_mowing` | Lawn Mowing | LOW | No | 1 | — |
| `gardening` | Gardening | LOW | No | 1 | — |
| `landscaping` | Landscaping | LOW | No | 1 | — |
| `hedge_trimming` | Hedge Trimming | LOW | No | 1 | — |
| `leaf_removal` | Leaf Removal | LOW | No | 1 | — |
| `snow_removal` | Snow Removal | LOW | No | 1 | — |
| `tree_trimming` | Tree Trimming | MEDIUM | No | 2 | ID verified |
| `fence_work` | Fence Repair / Install | MEDIUM | No | 2 | ID verified |
| `deck_staining` | Deck Staining / Sealing | LOW | No | 1 | — |
| `sprinkler_repair` | Sprinkler Repair | MEDIUM | No | 2 | ID verified |

### 3.4 General Labor

| Skill ID | Display Name | Risk | Regulated | Min Tier | Gate |
|----------|-------------|------|-----------|----------|------|
| `general_labor` | General Labor | LOW | No | 1 | — |
| `event_setup` | Event Setup / Teardown | LOW | No | 1 | — |
| `warehouse_help` | Warehouse Help | LOW | No | 1 | — |

**Category 1 Total: 30 skills**

---

## §4. Category 2: Handy Work (🔧)

### 4.1 Assembly

| Skill ID | Display Name | Risk | Regulated | Min Tier | Gate |
|----------|-------------|------|-----------|----------|------|
| `furniture_assembly` | Furniture Assembly | LOW | No | 1 | — |
| `ikea_assembly` | IKEA Assembly | LOW | No | 1 | — |
| `shelf_mounting` | Shelf / Bracket Mounting | LOW | No | 1 | — |
| `tv_mounting` | TV Mounting | LOW | No | 1 | — |
| `gym_equipment` | Gym Equipment Assembly | LOW | No | 1 | — |
| `playground_assembly` | Playground Assembly | MEDIUM | No | 2 | ID verified |
| `shed_assembly` | Shed / Gazebo Assembly | MEDIUM | No | 2 | ID verified |

### 4.2 Repair

| Skill ID | Display Name | Risk | Regulated | Min Tier | Gate |
|----------|-------------|------|-----------|----------|------|
| `drywall_repair` | Drywall Repair | LOW | No | 1 | — |
| `door_repair` | Door Repair / Replacement | LOW | No | 1 | — |
| `cabinet_repair` | Cabinet Repair | LOW | No | 1 | — |
| `tile_repair` | Tile Repair | LOW | No | 1 | — |
| `grout_repair` | Grout / Caulking | LOW | No | 1 | — |
| `appliance_repair` | Appliance Repair | MEDIUM | No | 2 | ID verified |
| `window_repair` | Window Repair | MEDIUM | No | 2 | ID verified |
| `lock_repair` | Lock / Deadbolt Repair | MEDIUM | No | 2 | ID verified |

### 4.3 Installation

| Skill ID | Display Name | Risk | Regulated | Min Tier | Gate |
|----------|-------------|------|-----------|----------|------|
| `light_fixture` | Light Fixture Install | MEDIUM | No | 2 | ID verified |
| `ceiling_fan` | Ceiling Fan Install | MEDIUM | No | 2 | ID verified |
| `blinds_curtains` | Blinds / Curtain Install | LOW | No | 1 | — |
| `smart_home` | Smart Home Device Install | LOW | No | 1 | — |
| `thermostat` | Thermostat Install | MEDIUM | No | 2 | ID verified |
| `toilet_install` | Toilet Install | MEDIUM | No | 2 | ID verified |
| `faucet_install` | Faucet Install | MEDIUM | No | 2 | ID verified |
| `dishwasher_install` | Dishwasher Install | MEDIUM | No | 2 | ID verified |
| `garage_door` | Garage Door Repair | MEDIUM | No | 2 | ID verified |

### 4.4 Regulated Trades

| Skill ID | Display Name | Risk | Regulated | Min Tier | Gate |
|----------|-------------|------|-----------|----------|------|
| `electrical_work` | Electrical Work | HIGH | Yes | 4 | Electrical business + worker credential matrix |
| `plumbing_work` | Plumbing Work | HIGH | Yes | 4 | Plumbing business + worker credential matrix |
| `hvac_work` | HVAC Work | HIGH | Yes | 4 | Contractor registration + scope-specific trade credentials |
| `gas_line_work` | Gas Line Work | HIGH | Yes | 4 | Gas Fitter License |
| `roofing` | Roofing | HIGH | Yes | 4 | Contractor License |
| `structural_work` | Structural Modification | HIGH | Yes | 4 | Contractor License |
| `general_contracting` | General Contracting | HIGH | Yes | 4 | General contractor registration + trade routing |
| `remodeling` | Remodeling | HIGH | Yes | 4 | General contractor registration + permit/trade matrix |
| `painting_commercial` | Painting (Commercial) | MEDIUM | Yes | 2 | Contractor License |
| `painting_residential` | Painting (Residential) | LOW | No | 1 | — |

**Category 2 Total: 37 skills**

---

## §5. Category 3: Transportation (🚗)

### 5.1 Delivery

| Skill ID | Display Name | Risk | Regulated | Min Tier | Gate |
|----------|-------------|------|-----------|----------|------|
| `package_delivery` | Package Delivery | LOW | No | 1 | — |
| `grocery_delivery` | Grocery Delivery | LOW | No | 1 | — |
| `food_delivery` | Food Delivery | LOW | No | 1 | — |
| `furniture_delivery` | Furniture Delivery | LOW | No | 1 | — |
| `appliance_delivery` | Appliance Delivery | MEDIUM | No | 2 | ID verified |
| `medical_delivery` | Medical Supply Delivery | MEDIUM | No | 2 | ID + background |

### 5.2 Errands & Driving

| Skill ID | Display Name | Risk | Regulated | Min Tier | Gate |
|----------|-------------|------|-----------|----------|------|
| `errands` | Run Errands | LOW | No | 1 | — |
| `shopping` | Personal Shopping | LOW | No | 1 | — |
| `waiting_in_line` | Waiting in Line | LOW | No | 1 | — |
| `airport_pickup` | Airport Pickup | LOW | No | 1 | — |
| `car_detailing` | Car Detailing | LOW | No | 1 | — |
| `car_wash` | Car Wash | LOW | No | 1 | — |
| `vehicle_transport` | Vehicle Transport | MEDIUM | No | 2 | ID + insurance |
| `boat_transport` | Boat Transport | MEDIUM | No | 2 | ID + insurance |

**Category 3 Total: 14 skills**

---

## §6. Category 4: Tech & Digital (💻)

| Skill ID | Display Name | Risk | Regulated | Min Tier | Gate |
|----------|-------------|------|-----------|----------|------|
| `computer_setup` | Computer / Laptop Setup | LOW | No | 1 | — |
| `wifi_setup` | WiFi / Router Setup | LOW | No | 1 | — |
| `printer_setup` | Printer Setup | LOW | No | 1 | — |
| `smart_tv_setup` | Smart TV Setup | LOW | No | 1 | — |
| `phone_setup` | Phone / Tablet Setup | LOW | No | 1 | — |
| `data_transfer` | Data Transfer / Backup | LOW | No | 1 | — |
| `virus_removal` | Virus Removal | LOW | No | 1 | — |
| `home_network` | Home Network Setup | LOW | No | 1 | — |
| `security_camera` | Security Camera Install | MEDIUM | No | 2 | ID verified |
| `home_theater` | Home Theater Setup | LOW | No | 1 | — |
| `tech_tutoring` | Tech Tutoring | LOW | No | 1 | — |
| `website_help` | Basic Website Help | LOW | No | 1 | — |
| `social_media_help` | Social Media Setup | LOW | No | 1 | — |
| `smart_home_setup` | Smart Home System Setup | LOW | No | 1 | — |

**Category 4 Total: 14 skills**

---

## §7. Category 5: Personal Services (🏠)

### 7.1 Care Services

| Skill ID | Display Name | Risk | Regulated | Min Tier | Gate |
|----------|-------------|------|-----------|----------|------|
| `pet_sitting` | Pet Sitting | LOW | No | 1 | — |
| `dog_walking` | Dog Walking | LOW | No | 1 | — |
| `pet_grooming` | Pet Grooming | LOW | No | 1 | — |
| `babysitting` | Babysitting | CRITICAL | No | 5 | Background check |
| `childcare` | Childcare | CRITICAL | Yes | 5 | Background + cert |
| `elder_companion` | Elder Companionship | HIGH | No | 4 | Background check |
| `elder_care` | Elder Care (Medical) | CRITICAL | Yes | 5 | Background + cert |
| `house_sitting` | House Sitting | MEDIUM | No | 2 | ID verified |

### 7.2 Personal Assistance

| Skill ID | Display Name | Risk | Regulated | Min Tier | Gate |
|----------|-------------|------|-----------|----------|------|
| `personal_assistant` | Personal Assistant | LOW | No | 1 | — |
| `meal_prep` | Meal Preparation | LOW | No | 1 | — |
| `closet_organization` | Closet Organization | LOW | No | 1 | — |
| `home_organization` | Home Organization | LOW | No | 1 | — |
| `laundry` | Laundry / Ironing | LOW | No | 1 | — |
| `tutoring_academic` | Academic Tutoring | LOW | No | 1 | — |
| `music_lessons` | Music Lessons | LOW | No | 1 | — |
| `fitness_training` | Fitness Training | MEDIUM | No | 2 | ID + insurance |

### 7.3 Events

| Skill ID | Display Name | Risk | Regulated | Min Tier | Gate |
|----------|-------------|------|-----------|----------|------|
| `party_setup` | Party Setup / Cleanup | LOW | No | 1 | — |
| `event_staff` | Event Staffing | LOW | No | 1 | — |
| `bartending` | Bartending | MEDIUM | Yes | 2 | Bartending license |
| `catering_help` | Catering Assistance | LOW | No | 1 | — |

**Category 5 Total: 20 skills**

---

## §8. Category 6: Professional (📋)

| Skill ID | Display Name | Risk | Regulated | Min Tier | Gate |
|----------|-------------|------|-----------|----------|------|
| `data_entry` | Data Entry | LOW | No | 1 | — |
| `filing_organization` | Filing / Organization | LOW | No | 1 | — |
| `inventory_count` | Inventory Counting | LOW | No | 1 | — |
| `photography` | Photography | LOW | No | 1 | — |
| `videography` | Videography | LOW | No | 1 | — |
| `graphic_design` | Graphic Design | LOW | No | 1 | — |
| `flyer_distribution` | Flyer Distribution | LOW | No | 1 | — |
| `sign_installation` | Sign Installation | LOW | No | 1 | — |
| `notary` | Notary Services | LOW | Yes | 1 | Notary commission |
| `translation` | Translation / Interpretation | LOW | No | 1 | — |
| `mystery_shopping` | Mystery Shopping | LOW | No | 1 | — |
| `survey_fieldwork` | Survey / Fieldwork | LOW | No | 1 | — |
| `real_estate_staging` | Real Estate Staging | MEDIUM | No | 2 | ID verified |

**Category 6 Total: 13 skills**

---

## §9. Summary Statistics

| Category | Skills | LOW | MEDIUM | HIGH | CRITICAL | Regulated |
|----------|--------|-----|--------|------|----------|-----------|
| Physical Tasks | 30 | 22 | 7 | 1 | 0 | 1 |
| Handy Work | 37 | 15 | 13 | 8 | 0 | 9 |
| Transportation | 14 | 10 | 4 | 0 | 0 | 0 |
| Tech & Digital | 14 | 13 | 1 | 0 | 0 | 0 |
| Personal Services | 20 | 11 | 4 | 1 | 4 | 3 |
| Professional | 13 | 12 | 1 | 0 | 0 | 1 |
| **TOTAL** | **128** | **83** | **30** | **10** | **4** | **14** |

**Tier Access Distribution:**
- Tier 1 (ROOKIE): 83 skills (65%) — immediate access
- Tier 2 (VERIFIED): 30 skills (23%) — after ID verification
- Tier 4 (ELITE): 11 skills (9%) — high-risk, licensed trades
- Tier 5 (MASTER): 4 skills (3%) — critical-risk, vulnerable populations

---

## §10. Schema Integration

### 10.1 Skill Catalog Table

```sql
CREATE TABLE IF NOT EXISTS skill_catalog (
  skill_id VARCHAR(100) PRIMARY KEY,
  display_name VARCHAR(255) NOT NULL,
  category VARCHAR(50) NOT NULL,
  subcategory VARCHAR(100),
  base_risk VARCHAR(10) NOT NULL
    CHECK (base_risk IN ('low', 'medium', 'high', 'critical')),
  regulated BOOLEAN NOT NULL DEFAULT FALSE,
  requires_insurance BOOLEAN NOT NULL DEFAULT FALSE,
  requires_background BOOLEAN NOT NULL DEFAULT FALSE,
  min_trust_tier INTEGER NOT NULL DEFAULT 1
    CHECK (min_trust_tier BETWEEN 1 AND 5),
  verification_gate VARCHAR(100),
  adjacent_skills TEXT[],  -- v2: for skill expansion prompts
  sort_order INTEGER NOT NULL DEFAULT 0,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_skill_catalog_category ON skill_catalog(category);
CREATE INDEX idx_skill_catalog_risk ON skill_catalog(base_risk);
CREATE INDEX idx_skill_catalog_active ON skill_catalog(active) WHERE active = TRUE;
```

### 10.2 Capability Claims Extension

```sql
-- Extend existing capability_claims to reference skill_catalog
ALTER TABLE capability_claims ADD COLUMN IF NOT EXISTS
  skill_id VARCHAR(100) REFERENCES skill_catalog(skill_id);

ALTER TABLE capability_claims ADD COLUMN IF NOT EXISTS
  selection_source VARCHAR(20) DEFAULT 'onboarding'
  CHECK (selection_source IN ('onboarding', 'settings', 'post_task_prompt'));

CREATE INDEX IF NOT EXISTS idx_capability_claims_skill
  ON capability_claims(skill_id);
```

---

## §11. Invariants

| ID | Invariant | Enforcement |
|----|-----------|-------------|
| INV-SKILL-1 | Every `capability_claims.skill_id` must exist in `skill_catalog` | FK constraint |
| INV-SKILL-2 | Regulated skills cannot be claimed without verification path initiated | Application layer |
| INV-SKILL-3 | Gated skills (min_trust_tier > user.trust_tier) shown but not claimable | UI + backend validation |
| INV-SKILL-4 | Skill catalog is append-only; skills are deactivated, never deleted | `active` flag |
| INV-SKILL-5 | Worker self-selects skills; platform never auto-assigns | No auto-add endpoint |

---

## §12. Amendment History

| Version | Date | Summary |
|---------|------|---------|
| 1.0.0 | Feb 2026 | Initial 126-skill taxonomy across 6 categories |

---

**This taxonomy is the canonical skill enumeration. If it's not here, it doesn't exist in HustleXP.**

