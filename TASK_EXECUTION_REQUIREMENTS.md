# TASK EXECUTION REQUIREMENTS — HUSTLEXP v1.0

**STATUS: FROZEN — Gate criteria for task posting**  
**Rule: Tasks CANNOT be posted unless ALL required fields are satisfied**

---

## THE CORE RULE

> **A task may only be posted if it meets execution-clarity requirements.**
> 
> AI exists to help users satisfy these requirements, not bypass them.
> 
> No exceptions. No manual bypass. No "post anyway."

---

## EXECUTION CLARITY DIMENSIONS

Every task MUST resolve these dimensions before creation:

### A. SCOPE (Required)
```
FIELD                  | TYPE      | REQUIRED | BLOCKING
-----------------------|-----------|----------|----------
task_description       | text      | YES      | YES
specific_outcome       | text      | YES      | YES
quantity_or_count      | text/num  | DEPENDS  | YES
explicit_exclusions    | text[]    | NO       | NO
```

**Questions:**
- "What exactly needs to be done?"
- "What does 'done' look like?"
- "How many items/rooms/hours?"
- "What is NOT included in this task?"

### B. LOCATION & ACCESS (Required)
```
FIELD                  | TYPE      | REQUIRED | BLOCKING
-----------------------|-----------|----------|----------
address                | string    | YES      | YES
address_verified       | boolean   | YES      | YES
indoor_outdoor         | enum      | YES      | YES
floor_level            | number    | DEPENDS  | NO
stairs_elevator        | enum      | DEPENDS  | NO
parking_available      | boolean   | YES      | NO
access_instructions    | text      | DEPENDS  | YES
gate_code              | text      | DEPENDS  | NO
```

**Questions:**
- "What's the exact address?"
- "Is this indoor, outdoor, or both?"
- "What floor? Are there stairs or an elevator?"
- "Where can the hustler park?"
- "How does the hustler access the location?"

### C. TIME (Required)
```
FIELD                  | TYPE      | REQUIRED | BLOCKING
-----------------------|-----------|----------|----------
desired_start_window   | datetime  | YES      | YES
deadline_type          | enum      | YES      | YES (hard/flexible/none)
estimated_duration     | minutes   | YES      | YES
time_flexibility       | text      | NO       | NO
```

**Questions:**
- "When do you want this done?"
- "Is there a hard deadline?"
- "About how long should this take?"

### D. RESPONSIBILITY SPLIT (Required)
```
FIELD                  | TYPE      | REQUIRED | BLOCKING
-----------------------|-----------|----------|----------
tools_provided_by      | enum      | YES      | YES (poster/hustler/either)
materials_provided_by  | enum      | YES      | YES (poster/hustler/either)
disposal_required      | boolean   | YES      | YES
disposal_responsibility| enum      | DEPENDS  | YES (if disposal=true)
```

**Questions:**
- "Who provides the tools needed?"
- "Who provides the materials?"
- "Is there anything to dispose of or remove?"
- "Who handles disposal?"

### E. PRESENCE & RISK (Required)
```
FIELD                  | TYPE      | REQUIRED | BLOCKING
-----------------------|-----------|----------|----------
poster_present         | boolean   | YES      | YES
pets_present           | boolean   | YES      | NO
high_value_items       | boolean   | YES      | NO
safety_considerations  | text[]    | DEPENDS  | NO
special_instructions   | text      | NO       | NO
```

**Questions:**
- "Will you be present during the task?"
- "Are there pets at the location?"
- "Are there high-value items the hustler should know about?"
- "Any safety considerations?"

### F. PROOF OF COMPLETION (Required)
```
FIELD                  | TYPE      | REQUIRED | BLOCKING
-----------------------|-----------|----------|----------
photos_required        | boolean   | YES      | YES
photo_instructions     | text      | DEPENDS  | YES (if photos=true)
specific_proof_type    | text      | YES      | YES
```

**Questions:**
- "Should the hustler take photos when done?"
- "What should the photos show?"
- "How will you know the task is complete?"

---

## CATEGORY → REQUIRED FIELDS MATRIX

Different task categories have different requirements:

### DELIVERY / PICKUP
```
REQUIRED: address, time_window, item_description, 
          pickup_location, dropoff_location,
          item_size, item_weight_estimate,
          recipient_name, recipient_contact
DEPENDS:  fragile_items, temperature_sensitive
```

### CLEANING
```
REQUIRED: address, square_footage_estimate, rooms_list,
          cleaning_type (deep/standard/specific),
          supplies_provided_by, time_window
DEPENDS:  pets_present, move_in_out, appliances_included
```

### MOVING / HAULING
```
REQUIRED: pickup_address, dropoff_address,
          item_inventory, largest_item_dimensions,
          stairs_at_pickup, stairs_at_dropoff,
          vehicle_type_needed, time_window
DEPENDS:  assembly_required, disposal_items
```

### ASSEMBLY / INSTALLATION
```
REQUIRED: item_description, brand_model (if applicable),
          tools_needed, parts_included,
          location_in_home, wall_mounting (y/n)
DEPENDS:  electrical_required, permit_needed
```

### YARD / OUTDOOR
```
REQUIRED: address, yard_size_estimate, task_specifics,
          tools_provided_by, disposal_required,
          access_to_water (if needed)
DEPENDS:  chemicals_approved, neighbor_notification
```

### ERRANDS / SHOPPING
```
REQUIRED: store_preferences, item_list_or_description,
          budget_limit, payment_method,
          delivery_address, time_window
DEPENDS:  substitution_allowed, brand_preferences
```

### HANDYMAN / REPAIR
```
REQUIRED: issue_description, photos_of_issue,
          tools_provided_by, parts_provided_by,
          access_instructions, time_window
DEPENDS:  permit_required, professional_license_needed
```

### PET CARE
```
REQUIRED: pet_type, pet_name, care_instructions,
          feeding_schedule, medications (if any),
          emergency_contact, vet_contact,
          access_instructions
DEPENDS:  special_needs, multiple_pets
```

### TECH HELP
```
REQUIRED: device_type, issue_description,
          remote_or_onsite, access_credentials (if needed),
          time_window
DEPENDS:  data_backup_needed, software_licenses
```

### GENERAL / OTHER
```
REQUIRED: full_description, specific_outcome,
          tools_needed, materials_needed,
          time_estimate, location (if applicable)
DEPENDS:  category-specific based on AI classification
```

---

## BLOCKING VS NON-BLOCKING

### BLOCKING FIELDS
If missing, task CANNOT be posted:
- Task description
- Specific completion outcome
- Address (for location-based tasks)
- Time window
- Tools/materials responsibility
- Proof of completion expectations

### NON-BLOCKING FIELDS
Optional but improve task quality:
- Explicit exclusions
- Parking details
- Safety considerations
- Special instructions

---

## FIELD VALIDATION RULES

### Address Validation
```
- Must be a real, geocodable address
- Must include street, city, state, zip
- P.O. boxes rejected for physical tasks
- "My house" or similar REJECTED
```

### Time Validation
```
- Start window must be in the future
- Duration estimate must be > 0
- If hard deadline, must be after start window + duration
```

### Scope Validation
```
- Description must be > 20 characters
- Outcome must be specific (AI checks for vagueness)
- Quantity must be numeric or descriptive
```

---

## POST BUTTON STATES

### 🔴 DISABLED — "More details needed"
```
Shown when:
- Any required field is empty
- Any required field fails validation
- AI clarity score < 3
- Risk classification incomplete
```

### 🟢 ENABLED — "Post Task"
```
Only when:
- ALL required fields populated
- ALL validations pass
- AI clarity score >= 3
- Risk classification complete
- Eligibility requirements computed
```

**No warnings. No "Are you sure?" No overrides.**

---

## INTEGRATION WITH AI

### AI's Role
1. Classify task into category
2. Determine which required fields are missing
3. Ask clarifying questions for missing fields
4. Validate answers meet requirements
5. Score task clarity (1-5)
6. Flag remaining issues

### AI's Constraints
```
❌ AI may NOT invent new required questions
❌ AI may NOT waive required questions
❌ AI may NOT accept ambiguous answers
❌ AI may NOT skip blocking fields
✅ AI may ONLY enforce defined requirements
```

---

## SIGNATURE

This document defines the gate criteria for task posting.
Tasks not meeting these requirements simply cannot exist.

**Quality is enforced upstream. Messes don't happen downstream.**
