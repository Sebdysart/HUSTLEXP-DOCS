# TASK CLARIFICATION QUESTION BANK — HUSTLEXP v1.0

**STATUS: FROZEN — Static question banks per task category**  
**Rule: AI selects from these questions. AI does NOT invent questions.**

---

## HOW THIS WORKS

1. User writes rough task description
2. AI classifies into category
3. AI checks which required fields are missing
4. AI asks questions from this bank (in order)
5. User answers
6. Task unlocks when all blocking questions answered

**AI may NOT:**
- Invent new required questions
- Waive required questions
- Accept ambiguous answers
- Skip blocking questions

---

## QUESTION METADATA FORMAT

```
QUESTION: "The question text"
FIELD: which_field_it_populates
TYPE: blocking | non-blocking
REQUIRED: always | conditional | optional
CONDITION: (if conditional) when this applies
ACCEPTS: valid answer formats
REJECTS: invalid answer patterns
```

---

## CATEGORY: DELIVERY / PICKUP

### Q1 — Pickup Location (BLOCKING)
```
QUESTION: "Where are you picking up from? Please provide the full address."
FIELD: pickup_address
TYPE: blocking
REQUIRED: always
ACCEPTS: Full street address with city, state, zip
REJECTS: "my place", "nearby", partial addresses
```

### Q2 — Dropoff Location (BLOCKING)
```
QUESTION: "Where should this be delivered? Please provide the full address."
FIELD: dropoff_address
TYPE: blocking
REQUIRED: always
ACCEPTS: Full street address with city, state, zip
REJECTS: "my house", "downtown", partial addresses
```

### Q3 — Item Description (BLOCKING)
```
QUESTION: "What exactly is being picked up/delivered?"
FIELD: item_description
TYPE: blocking
REQUIRED: always
ACCEPTS: Specific item name, quantity, basic description
REJECTS: "stuff", "things", "items"
```

### Q4 — Item Size (BLOCKING)
```
QUESTION: "How big is the item? (fits in car / needs SUV / needs truck)"
FIELD: item_size
TYPE: blocking
REQUIRED: always
ACCEPTS: car, SUV, truck, dimensions
REJECTS: "medium", "not too big"
```

### Q5 — Time Window (BLOCKING)
```
QUESTION: "When do you need this done? Please give a date and time range."
FIELD: time_window
TYPE: blocking
REQUIRED: always
ACCEPTS: Specific date + time range (e.g., "Saturday 2-5pm")
REJECTS: "soon", "whenever", "ASAP" without date
```

### Q6 — Recipient Info (BLOCKING)
```
QUESTION: "Who should the hustler contact at the dropoff location?"
FIELD: recipient_contact
TYPE: blocking
REQUIRED: always
ACCEPTS: Name + phone number or "I'll be there"
REJECTS: Empty, "they'll know"
```

### Q7 — Fragile Items (NON-BLOCKING)
```
QUESTION: "Are any items fragile or require special handling?"
FIELD: fragile_items
TYPE: non-blocking
REQUIRED: optional
ACCEPTS: yes/no + description if yes
```

---

## CATEGORY: CLEANING

### Q1 — Address (BLOCKING)
```
QUESTION: "What's the address for cleaning?"
FIELD: address
TYPE: blocking
REQUIRED: always
ACCEPTS: Full street address
REJECTS: "my apartment", partial addresses
```

### Q2 — Space Size (BLOCKING)
```
QUESTION: "How big is the space? (sq ft or number of rooms)"
FIELD: space_size
TYPE: blocking
REQUIRED: always
ACCEPTS: Square footage, room count, apartment size (studio/1BR/etc)
REJECTS: "normal size", "medium"
```

### Q3 — Rooms to Clean (BLOCKING)
```
QUESTION: "Which rooms or areas need cleaning?"
FIELD: rooms_list
TYPE: blocking
REQUIRED: always
ACCEPTS: List of specific rooms/areas
REJECTS: "everywhere", "the whole place" without specifics
```

### Q4 — Cleaning Type (BLOCKING)
```
QUESTION: "What type of cleaning? (standard / deep clean / move-in/out / specific areas only)"
FIELD: cleaning_type
TYPE: blocking
REQUIRED: always
ACCEPTS: standard, deep, move-in, move-out, specific
REJECTS: "just clean it"
```

### Q5 — Supplies (BLOCKING)
```
QUESTION: "Will you provide cleaning supplies, or should the hustler bring their own?"
FIELD: supplies_provided_by
TYPE: blocking
REQUIRED: always
ACCEPTS: "I'll provide", "hustler brings", "either is fine"
REJECTS: Ambiguous responses
```

### Q6 — Time Window (BLOCKING)
```
QUESTION: "When do you need this done?"
FIELD: time_window
TYPE: blocking
REQUIRED: always
ACCEPTS: Specific date + time range
REJECTS: "soon", "this week" without specifics
```

### Q7 — Access (BLOCKING)
```
QUESTION: "How will the hustler access the space?"
FIELD: access_instructions
TYPE: blocking
REQUIRED: always
ACCEPTS: "I'll be there", key location, door code, building instructions
REJECTS: "they'll figure it out"
```

### Q8 — Pets (NON-BLOCKING)
```
QUESTION: "Are there any pets at the location?"
FIELD: pets_present
TYPE: non-blocking
REQUIRED: optional
ACCEPTS: yes/no + type if yes
```

### Q9 — Proof (BLOCKING)
```
QUESTION: "Should the hustler take before/after photos?"
FIELD: photos_required
TYPE: blocking
REQUIRED: always
ACCEPTS: yes/no
```

---

## CATEGORY: MOVING / HAULING

### Q1 — Pickup Address (BLOCKING)
```
QUESTION: "What's the pickup address?"
FIELD: pickup_address
TYPE: blocking
REQUIRED: always
ACCEPTS: Full street address
REJECTS: Partial addresses
```

### Q2 — Dropoff Address (BLOCKING)
```
QUESTION: "What's the dropoff address?"
FIELD: dropoff_address
TYPE: blocking
REQUIRED: always
ACCEPTS: Full street address
REJECTS: Partial addresses
```

### Q3 — Item Inventory (BLOCKING)
```
QUESTION: "What items are being moved? Please list them."
FIELD: item_inventory
TYPE: blocking
REQUIRED: always
ACCEPTS: Specific list with quantities
REJECTS: "furniture", "boxes" without details
```

### Q4 — Largest Item (BLOCKING)
```
QUESTION: "What's the largest/heaviest item? Approximate dimensions?"
FIELD: largest_item
TYPE: blocking
REQUIRED: always
ACCEPTS: Item name + rough dimensions or description
REJECTS: "pretty big"
```

### Q5 — Stairs at Pickup (BLOCKING)
```
QUESTION: "Are there stairs at the pickup location? If so, how many flights?"
FIELD: stairs_pickup
TYPE: blocking
REQUIRED: always
ACCEPTS: "no stairs / ground floor", "X flights", "elevator available"
REJECTS: "some"
```

### Q6 — Stairs at Dropoff (BLOCKING)
```
QUESTION: "Are there stairs at the dropoff location? If so, how many flights?"
FIELD: stairs_dropoff
TYPE: blocking
REQUIRED: always
ACCEPTS: "no stairs / ground floor", "X flights", "elevator available"
REJECTS: "some"
```

### Q7 — Vehicle Needed (BLOCKING)
```
QUESTION: "What type of vehicle is needed? (car / SUV / pickup truck / cargo van / box truck)"
FIELD: vehicle_type
TYPE: blocking
REQUIRED: always
ACCEPTS: Specific vehicle type
REJECTS: "something big"
```

### Q8 — Time Window (BLOCKING)
```
QUESTION: "When do you need this done?"
FIELD: time_window
TYPE: blocking
REQUIRED: always
ACCEPTS: Specific date + time range
REJECTS: "soon", "this weekend" without time
```

### Q9 — Assembly Required (NON-BLOCKING)
```
QUESTION: "Does anything need to be disassembled or reassembled?"
FIELD: assembly_required
TYPE: non-blocking
REQUIRED: optional
ACCEPTS: yes/no + details if yes
```

### Q10 — Disposal (BLOCKING)
```
QUESTION: "Is there anything to dispose of or take to the dump?"
FIELD: disposal_required
TYPE: blocking
REQUIRED: always
ACCEPTS: yes/no + details if yes
```

---

## CATEGORY: ASSEMBLY / INSTALLATION

### Q1 — Item Description (BLOCKING)
```
QUESTION: "What needs to be assembled or installed?"
FIELD: item_description
TYPE: blocking
REQUIRED: always
ACCEPTS: Specific item name, brand if known
REJECTS: "furniture", "stuff"
```

### Q2 — Brand/Model (NON-BLOCKING)
```
QUESTION: "What's the brand and model? (helps hustler prepare)"
FIELD: brand_model
TYPE: non-blocking
REQUIRED: optional
ACCEPTS: Brand name, model number, or "unknown"
```

### Q3 — Tools Needed (BLOCKING)
```
QUESTION: "Will you provide tools, or should the hustler bring their own?"
FIELD: tools_provided_by
TYPE: blocking
REQUIRED: always
ACCEPTS: "I'll provide", "hustler brings", "basic tools needed"
REJECTS: Ambiguous
```

### Q4 — Parts Included (BLOCKING)
```
QUESTION: "Are all parts and hardware included?"
FIELD: parts_included
TYPE: blocking
REQUIRED: always
ACCEPTS: "yes, all included", "missing X", "need to purchase X"
REJECTS: "I think so"
```

### Q5 — Location in Home (BLOCKING)
```
QUESTION: "Where in your home will this be assembled/installed?"
FIELD: location_in_home
TYPE: blocking
REQUIRED: always
ACCEPTS: Specific room/location
REJECTS: "inside"
```

### Q6 — Wall Mounting (BLOCKING)
```
QUESTION: "Does this require wall mounting or drilling?"
FIELD: wall_mounting
TYPE: blocking
REQUIRED: always
ACCEPTS: yes/no
```

### Q7 — Address (BLOCKING)
```
QUESTION: "What's the address?"
FIELD: address
TYPE: blocking
REQUIRED: always
ACCEPTS: Full street address
REJECTS: Partial addresses
```

### Q8 — Time Window (BLOCKING)
```
QUESTION: "When do you need this done?"
FIELD: time_window
TYPE: blocking
REQUIRED: always
ACCEPTS: Specific date + time range
REJECTS: "soon"
```

### Q9 — Access (BLOCKING)
```
QUESTION: "How will the hustler access your home?"
FIELD: access_instructions
TYPE: blocking
REQUIRED: always
ACCEPTS: "I'll be there", door code, key location
REJECTS: Vague
```

---

## CATEGORY: YARD / OUTDOOR

### Q1 — Address (BLOCKING)
```
QUESTION: "What's the address?"
FIELD: address
TYPE: blocking
REQUIRED: always
ACCEPTS: Full street address
REJECTS: Partial addresses
```

### Q2 — Task Specifics (BLOCKING)
```
QUESTION: "What exactly needs to be done in the yard?"
FIELD: task_specifics
TYPE: blocking
REQUIRED: always
ACCEPTS: Specific tasks (mow, trim, rake, plant, etc.)
REJECTS: "yard work", "clean up"
```

### Q3 — Yard Size (BLOCKING)
```
QUESTION: "How big is the yard? (small / medium / large / approximate sq ft)"
FIELD: yard_size
TYPE: blocking
REQUIRED: always
ACCEPTS: Size estimate or square footage
REJECTS: "normal"
```

### Q4 — Tools (BLOCKING)
```
QUESTION: "Will you provide tools (mower, trimmer, etc.) or should hustler bring their own?"
FIELD: tools_provided_by
TYPE: blocking
REQUIRED: always
ACCEPTS: "I'll provide X", "hustler brings", specific tool list
REJECTS: Vague
```

### Q5 — Disposal (BLOCKING)
```
QUESTION: "How should yard waste be handled? (bag it / you'll dispose / hustler takes)"
FIELD: disposal_method
TYPE: blocking
REQUIRED: always
ACCEPTS: Specific disposal method
REJECTS: "whatever"
```

### Q6 — Water Access (CONDITIONAL)
```
QUESTION: "Is there access to water/hose if needed?"
FIELD: water_access
TYPE: blocking
REQUIRED: conditional (if watering/washing involved)
ACCEPTS: yes/no + location
```

### Q7 — Time Window (BLOCKING)
```
QUESTION: "When do you need this done?"
FIELD: time_window
TYPE: blocking
REQUIRED: always
ACCEPTS: Specific date + time range
REJECTS: "soon"
```

---

## CATEGORY: ERRANDS / SHOPPING

### Q1 — Store Preferences (BLOCKING)
```
QUESTION: "Where should the hustler shop? (specific store or type)"
FIELD: store_preferences
TYPE: blocking
REQUIRED: always
ACCEPTS: Specific store name(s) or "any grocery store", etc.
REJECTS: "somewhere"
```

### Q2 — Item List (BLOCKING)
```
QUESTION: "What items do you need? Please be specific."
FIELD: item_list
TYPE: blocking
REQUIRED: always
ACCEPTS: Detailed list with quantities, sizes, brands if preferred
REJECTS: "groceries", "supplies"
```

### Q3 — Budget (BLOCKING)
```
QUESTION: "What's the maximum budget for the items (not including hustler pay)?"
FIELD: budget_limit
TYPE: blocking
REQUIRED: always
ACCEPTS: Dollar amount
REJECTS: "reasonable", "not too much"
```

### Q4 — Payment Method (BLOCKING)
```
QUESTION: "How will the hustler pay for items? (your card / reimburse / prepaid)"
FIELD: payment_method
TYPE: blocking
REQUIRED: always
ACCEPTS: Specific method
REJECTS: "we'll figure it out"
```

### Q5 — Substitutions (BLOCKING)
```
QUESTION: "If an item is unavailable, should the hustler substitute, skip it, or contact you?"
FIELD: substitution_policy
TYPE: blocking
REQUIRED: always
ACCEPTS: substitute / skip / contact
REJECTS: "whatever"
```

### Q6 — Delivery Address (BLOCKING)
```
QUESTION: "Where should items be delivered?"
FIELD: delivery_address
TYPE: blocking
REQUIRED: always
ACCEPTS: Full street address
REJECTS: Partial
```

### Q7 — Time Window (BLOCKING)
```
QUESTION: "When do you need this done?"
FIELD: time_window
TYPE: blocking
REQUIRED: always
ACCEPTS: Specific date + time range
REJECTS: "soon"
```

---

## UNIVERSAL QUESTIONS (ALL CATEGORIES)

These questions apply to ALL task types:

### U1 — Completion Proof (BLOCKING)
```
QUESTION: "How will you know the task is complete? What should the hustler send as proof?"
FIELD: completion_proof
TYPE: blocking
REQUIRED: always
ACCEPTS: Specific proof type (photos, receipt, confirmation)
REJECTS: "I'll know"
```

### U2 — Poster Presence (BLOCKING)
```
QUESTION: "Will you be present during the task?"
FIELD: poster_present
TYPE: blocking
REQUIRED: always
ACCEPTS: yes/no
```

### U3 — Contact Method (BLOCKING)
```
QUESTION: "What's the best way for the hustler to contact you if needed?"
FIELD: contact_method
TYPE: blocking
REQUIRED: always
ACCEPTS: Phone, in-app chat, specific instructions
REJECTS: "they can figure it out"
```

### U4 — Special Instructions (NON-BLOCKING)
```
QUESTION: "Anything else the hustler should know?"
FIELD: special_instructions
TYPE: non-blocking
REQUIRED: optional
ACCEPTS: Any additional details
```

---

## AI SELECTION LOGIC

```
1. Classify task → determine category
2. Get required questions for category
3. Check which fields are already populated (from description)
4. Filter to unanswered required questions
5. Add universal questions if not answered
6. Present questions in logical order
7. Validate each answer before proceeding
8. Mark task ready when all blocking questions answered
```

---

## SIGNATURE

This question bank is FROZEN.
AI selects from these questions.
AI does NOT invent questions.
AI does NOT waive questions.

**Crystal clear tasks. No ambiguity. No disputes.**
