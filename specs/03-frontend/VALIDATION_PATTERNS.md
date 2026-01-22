# HustleXP Validation Patterns

**AUTHORITY:** API_CONTRACT.md, PRODUCT_SPEC.md
**STATUS:** Constitutional Reference for Cursor
**VERSION:** 1.0.0

This document defines ALL validation rules for form fields. Cursor MUST use these patterns — do not invent validation rules.

---

## Table of Contents

1. [Validation Philosophy](#validation-philosophy)
2. [Field Validation Rules](#field-validation-rules)
3. [Error Messages](#error-messages)
4. [Form-Level Validation](#form-level-validation)
5. [Screen-Specific Required Fields](#screen-specific-required-fields)

---

## Validation Philosophy

### Client vs Server Validation

| Location | Purpose | Examples |
|----------|---------|----------|
| **Client** | Immediate feedback, UX | Format validation, required fields, length limits |
| **Server** | Authority, business rules | Uniqueness, permissions, state transitions |

**Rule:** Client validates format. Server validates truth.

### Validation Timing

| Event | Action |
|-------|--------|
| On blur | Validate field, show error if invalid |
| On change | Clear error if now valid |
| On submit | Validate all fields, focus first error |

### Error Display

- Show error BELOW the field
- Red text (`STATUS.error` #EF4444)
- 14px font size
- Clear error when user corrects input

---

## Field Validation Rules

### 2.1 Email

```typescript
const EMAIL_VALIDATION = {
  pattern: /^[^\s@]+@[^\s@]+\.[^\s@]+$/,
  maxLength: 255,
  required: true,
  messages: {
    required: 'Email is required',
    invalid: 'Enter a valid email address',
    tooLong: 'Email must be less than 255 characters',
  },
};
```

**Additional server checks:**
- Uniqueness (signup only)
- Deliverability (optional)

---

### 2.2 Password

```typescript
const PASSWORD_VALIDATION = {
  minLength: 8,
  maxLength: 128,
  required: true,
  rules: [
    { pattern: /.{8,}/, message: 'At least 8 characters' },
    { pattern: /[A-Z]/, message: 'At least one uppercase letter' },
    { pattern: /[a-z]/, message: 'At least one lowercase letter' },
    { pattern: /[0-9]/, message: 'At least one number' },
  ],
  messages: {
    required: 'Password is required',
    weak: 'Password does not meet requirements',
  },
};
```

**Password strength indicator:**
- Weak: Meets 1-2 rules (red)
- Medium: Meets 3 rules (amber)
- Strong: Meets all 4 rules (green)

---

### 2.3 Phone Number

```typescript
const PHONE_VALIDATION = {
  // US phone format: (XXX) XXX-XXXX or +1XXXXXXXXXX
  pattern: /^(\+1)?[\s.-]?\(?\d{3}\)?[\s.-]?\d{3}[\s.-]?\d{4}$/,
  digitsOnly: /^\d{10}$/, // After stripping formatting
  required: false, // Optional in most forms
  messages: {
    invalid: 'Enter a valid US phone number',
  },
};

// Auto-format on blur
const formatPhone = (value: string): string => {
  const digits = value.replace(/\D/g, '').slice(0, 10);
  if (digits.length === 10) {
    return `(${digits.slice(0, 3)}) ${digits.slice(3, 6)}-${digits.slice(6)}`;
  }
  return value;
};
```

---

### 2.4 Full Name

```typescript
const NAME_VALIDATION = {
  minLength: 2,
  maxLength: 100,
  pattern: /^[a-zA-Z\s'-]+$/, // Letters, spaces, hyphens, apostrophes
  required: true,
  messages: {
    required: 'Name is required',
    tooShort: 'Name must be at least 2 characters',
    tooLong: 'Name must be less than 100 characters',
    invalid: 'Name can only contain letters, spaces, hyphens, and apostrophes',
  },
};
```

---

### 2.5 Task Title

```typescript
const TASK_TITLE_VALIDATION = {
  minLength: 1,
  maxLength: 255,
  required: true,
  messages: {
    required: 'Title is required',
    tooLong: 'Title must be less than 255 characters',
  },
};
```

---

### 2.6 Task Description

```typescript
const TASK_DESCRIPTION_VALIDATION = {
  minLength: 1,
  maxLength: 5000,
  required: true,
  messages: {
    required: 'Description is required',
    tooLong: 'Description must be less than 5000 characters',
  },
};

// Optional character counter
const showCharacterCount = (value: string, max: number) => {
  const remaining = max - value.length;
  return remaining < 500 ? `${remaining} characters remaining` : null;
};
```

---

### 2.7 Task Requirements

```typescript
const TASK_REQUIREMENTS_VALIDATION = {
  maxLength: 2000,
  required: false,
  messages: {
    tooLong: 'Requirements must be less than 2000 characters',
  },
};
```

---

### 2.8 Task Price

```typescript
const TASK_PRICE_VALIDATION = {
  min: 500, // $5.00 in cents
  minLive: 1500, // $15.00 for LIVE mode
  max: 1000000, // $10,000.00
  required: true,
  messages: {
    required: 'Price is required',
    tooLow: 'Minimum price is $5.00',
    tooLowLive: 'Minimum price for Live tasks is $15.00',
    tooHigh: 'Maximum price is $10,000.00',
    invalid: 'Enter a valid price',
  },
};

// Parse currency input
const parsePriceInput = (value: string): number | null => {
  const cleaned = value.replace(/[^0-9.]/g, '');
  const amount = parseFloat(cleaned);
  if (isNaN(amount)) return null;
  return Math.round(amount * 100); // Convert to cents
};

// Format for display
const formatPrice = (cents: number): string => {
  return `$${(cents / 100).toFixed(2)}`;
};
```

---

### 2.9 Location / Address

```typescript
const LOCATION_VALIDATION = {
  minLength: 1,
  maxLength: 500,
  required: true,
  messages: {
    required: 'Location is required',
    tooLong: 'Address must be less than 500 characters',
  },
};

// Coordinates (optional, from geocoding)
const COORDINATES_VALIDATION = {
  lat: { min: -90, max: 90 },
  lng: { min: -180, max: 180 },
};
```

---

### 2.10 Deadline

```typescript
const DEADLINE_VALIDATION = {
  minOffset: 60 * 60 * 1000, // At least 1 hour from now
  maxOffset: 30 * 24 * 60 * 60 * 1000, // Max 30 days from now
  required: true,
  messages: {
    required: 'Deadline is required',
    tooSoon: 'Deadline must be at least 1 hour from now',
    tooFar: 'Deadline must be within 30 days',
    invalid: 'Enter a valid date and time',
  },
};

const validateDeadline = (deadline: Date): string | null => {
  const now = Date.now();
  const deadlineTime = deadline.getTime();

  if (deadlineTime - now < DEADLINE_VALIDATION.minOffset) {
    return DEADLINE_VALIDATION.messages.tooSoon;
  }
  if (deadlineTime - now > DEADLINE_VALIDATION.maxOffset) {
    return DEADLINE_VALIDATION.messages.tooFar;
  }
  return null;
};
```

---

### 2.11 Proof Description

```typescript
const PROOF_DESCRIPTION_VALIDATION = {
  minLength: 1,
  maxLength: 2000,
  required: true,
  messages: {
    required: 'Description is required',
    tooLong: 'Description must be less than 2000 characters',
  },
};
```

---

### 2.12 Proof Photos

```typescript
const PROOF_PHOTOS_VALIDATION = {
  minCount: 1,
  maxCount: 5,
  maxSizeBytes: 10 * 1024 * 1024, // 10MB per photo
  allowedTypes: ['image/jpeg', 'image/png', 'image/heic'],
  required: true,
  messages: {
    required: 'At least one photo is required',
    tooMany: 'Maximum 5 photos allowed',
    tooLarge: 'Photo must be less than 10MB',
    invalidType: 'Only JPEG, PNG, and HEIC photos are allowed',
  },
};
```

---

### 2.13 Message Content

```typescript
const MESSAGE_VALIDATION = {
  maxLength: 2000,
  required: true,
  messages: {
    required: 'Message cannot be empty',
    tooLong: 'Message must be less than 2000 characters',
  },
};
```

---

### 2.14 Dispute Description

```typescript
const DISPUTE_DESCRIPTION_VALIDATION = {
  minLength: 1,
  maxLength: 2000,
  required: true,
  messages: {
    required: 'Description is required',
    tooLong: 'Description must be less than 2000 characters',
  },
};
```

---

### 2.15 Rating

```typescript
const RATING_VALIDATION = {
  stars: { min: 1, max: 5 },
  comment: { maxLength: 500 },
  required: true, // Stars required
  messages: {
    required: 'Please select a rating',
    commentTooLong: 'Comment must be less than 500 characters',
  },
};
```

---

### 2.16 License Number

```typescript
const LICENSE_NUMBER_VALIDATION = {
  minLength: 4,
  maxLength: 50,
  pattern: /^[A-Z0-9-]+$/i, // Alphanumeric with dashes
  required: true,
  messages: {
    required: 'License number is required',
    tooShort: 'License number must be at least 4 characters',
    invalid: 'Enter a valid license number',
  },
};
```

---

### 2.17 State Code

```typescript
const STATE_CODE_VALIDATION = {
  pattern: /^[A-Z]{2}$/,
  validStates: [
    'AL', 'AK', 'AZ', 'AR', 'CA', 'CO', 'CT', 'DE', 'FL', 'GA',
    'HI', 'ID', 'IL', 'IN', 'IA', 'KS', 'KY', 'LA', 'ME', 'MD',
    'MA', 'MI', 'MN', 'MS', 'MO', 'MT', 'NE', 'NV', 'NH', 'NJ',
    'NM', 'NY', 'NC', 'ND', 'OH', 'OK', 'OR', 'PA', 'RI', 'SC',
    'SD', 'TN', 'TX', 'UT', 'VT', 'VA', 'WA', 'WV', 'WI', 'WY',
    'DC', 'PR', 'VI', 'GU', 'AS', 'MP',
  ],
  required: true,
  messages: {
    required: 'State is required',
    invalid: 'Select a valid US state',
  },
};
```

---

## Error Messages

### Message Guidelines

1. **Be specific** — Tell the user exactly what's wrong
2. **Be helpful** — Suggest how to fix it
3. **Be brief** — One short sentence
4. **No blame** — Never say "You failed" or "Invalid input"

### Standard Messages by Error Type

| Error Type | Message Pattern |
|------------|-----------------|
| Required | "{Field} is required" |
| Too short | "{Field} must be at least {n} characters" |
| Too long | "{Field} must be less than {n} characters" |
| Invalid format | "Enter a valid {field type}" |
| Out of range | "{Field} must be between {min} and {max}" |
| Too soon | "{Field} must be at least {duration} from now" |
| Too many | "Maximum {n} {items} allowed" |

---

## Form-Level Validation

### Validate All Fields

```typescript
interface ValidationResult {
  isValid: boolean;
  errors: Record<string, string>;
  firstErrorField: string | null;
}

const validateForm = (
  fields: Record<string, unknown>,
  rules: Record<string, ValidationRule>
): ValidationResult => {
  const errors: Record<string, string> = {};
  let firstErrorField: string | null = null;

  for (const [field, rule] of Object.entries(rules)) {
    const value = fields[field];
    const error = validateField(value, rule);

    if (error) {
      errors[field] = error;
      if (!firstErrorField) {
        firstErrorField = field;
      }
    }
  }

  return {
    isValid: Object.keys(errors).length === 0,
    errors,
    firstErrorField,
  };
};
```

### Focus First Error

```typescript
const handleSubmit = async () => {
  const result = validateForm(formData, validationRules);

  if (!result.isValid) {
    setErrors(result.errors);
    // Focus first error field
    if (result.firstErrorField && fieldRefs[result.firstErrorField]) {
      fieldRefs[result.firstErrorField].focus();
    }
    return;
  }

  // Proceed with submission
};
```

---

## Screen-Specific Required Fields

### Login Screen

| Field | Required | Validation |
|-------|----------|------------|
| Email | YES | EMAIL_VALIDATION |
| Password | YES | Required only (no strength check) |

### Signup Screen

| Field | Required | Validation |
|-------|----------|------------|
| Full Name | YES | NAME_VALIDATION |
| Email | YES | EMAIL_VALIDATION |
| Password | YES | PASSWORD_VALIDATION (with strength) |
| Confirm Password | YES | Must match password |

### Forgot Password Screen

| Field | Required | Validation |
|-------|----------|------------|
| Email | YES | EMAIL_VALIDATION |

### Task Creation Screen

| Field | Required | Validation |
|-------|----------|------------|
| Title | YES | TASK_TITLE_VALIDATION |
| Description | YES | TASK_DESCRIPTION_VALIDATION |
| Requirements | NO | TASK_REQUIREMENTS_VALIDATION |
| Category | YES | Required (select from list) |
| Location | YES | LOCATION_VALIDATION |
| Price | YES | TASK_PRICE_VALIDATION |
| Deadline | YES | DEADLINE_VALIDATION |
| Mode | NO | Default: STANDARD |
| Proof Instructions | NO | Max 1000 chars |

### Proof Submission Screen

| Field | Required | Validation |
|-------|----------|------------|
| Description | YES | PROOF_DESCRIPTION_VALIDATION |
| Photos | YES | PROOF_PHOTOS_VALIDATION |

### Dispute Creation Screen

| Field | Required | Validation |
|-------|----------|------------|
| Reason | YES | Required (select from list) |
| Description | YES | DISPUTE_DESCRIPTION_VALIDATION |
| Evidence | NO | Same as PROOF_PHOTOS_VALIDATION |

### Rating Screen

| Field | Required | Validation |
|-------|----------|------------|
| Stars | YES | 1-5 |
| Comment | NO | Max 500 chars |
| Tags | NO | From predefined list |

### Message Send

| Field | Required | Validation |
|-------|----------|------------|
| Content | YES | MESSAGE_VALIDATION |
| Photos | NO | Max 3, 10MB each |

### Profile Update Screen

| Field | Required | Validation |
|-------|----------|------------|
| Full Name | YES | NAME_VALIDATION |
| Avatar | NO | Image, max 5MB |
| Phone | NO | PHONE_VALIDATION |

### Onboarding - Capability Claims

| Field | Required | Validation |
|-------|----------|------------|
| Work State | YES | STATE_CODE_VALIDATION |
| Claimed Trades | NO | From predefined list |
| License Claims | Conditional | If trade requires license |
| Insurance Claimed | NO | Boolean |
| Risk Preferences | YES | All three booleans |

### License Submission

| Field | Required | Validation |
|-------|----------|------------|
| Trade | YES | From predefined list |
| State | YES | STATE_CODE_VALIDATION |
| License Number | YES | LICENSE_NUMBER_VALIDATION |
| License Type | NO | From predefined list |
| Documents | NO | PDF or image, max 10MB each |

---

## Validation Utilities

### Create Validator

```typescript
// Usage: const validator = createValidator(EMAIL_VALIDATION);
const createValidator = (rules: ValidationRules) => {
  return (value: string): string | null => {
    if (rules.required && !value?.trim()) {
      return rules.messages.required;
    }

    if (value && rules.minLength && value.length < rules.minLength) {
      return rules.messages.tooShort;
    }

    if (value && rules.maxLength && value.length > rules.maxLength) {
      return rules.messages.tooLong;
    }

    if (value && rules.pattern && !rules.pattern.test(value)) {
      return rules.messages.invalid;
    }

    return null;
  };
};
```

### useFormValidation Hook

```typescript
const useFormValidation = <T extends Record<string, unknown>>(
  initialValues: T,
  validationRules: Record<keyof T, ValidationRules>
) => {
  const [values, setValues] = useState(initialValues);
  const [errors, setErrors] = useState<Partial<Record<keyof T, string>>>({});
  const [touched, setTouched] = useState<Partial<Record<keyof T, boolean>>>({});

  const validateField = (field: keyof T, value: unknown) => {
    const rule = validationRules[field];
    if (!rule) return null;

    const validator = createValidator(rule);
    return validator(String(value));
  };

  const handleChange = (field: keyof T, value: unknown) => {
    setValues(prev => ({ ...prev, [field]: value }));

    // Clear error if now valid
    if (touched[field]) {
      const error = validateField(field, value);
      if (!error) {
        setErrors(prev => {
          const next = { ...prev };
          delete next[field];
          return next;
        });
      }
    }
  };

  const handleBlur = (field: keyof T) => {
    setTouched(prev => ({ ...prev, [field]: true }));

    const error = validateField(field, values[field]);
    if (error) {
      setErrors(prev => ({ ...prev, [field]: error }));
    }
  };

  const validate = (): boolean => {
    const newErrors: Partial<Record<keyof T, string>> = {};

    for (const field of Object.keys(validationRules) as Array<keyof T>) {
      const error = validateField(field, values[field]);
      if (error) {
        newErrors[field] = error;
      }
    }

    setErrors(newErrors);
    setTouched(Object.keys(values).reduce((acc, key) => ({ ...acc, [key]: true }), {}));

    return Object.keys(newErrors).length === 0;
  };

  return {
    values,
    errors,
    touched,
    handleChange,
    handleBlur,
    validate,
    isValid: Object.keys(errors).length === 0,
  };
};
```

---

## Server-Side Validation Errors

When the server returns validation errors, map them to fields:

```typescript
interface ServerError {
  code: string;
  message: string;
  field?: string;
}

const handleServerErrors = (
  error: ServerError,
  setErrors: (errors: Record<string, string>) => void
) => {
  if (error.field) {
    setErrors({ [error.field]: error.message });
  } else {
    // Show as toast or general error
    toast.show({ message: error.message, variant: 'error' });
  }
};
```

---

**END OF VALIDATION PATTERNS**
