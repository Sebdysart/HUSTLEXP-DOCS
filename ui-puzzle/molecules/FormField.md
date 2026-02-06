# MOLECULE: FormField

**STATUS: LOCKED**
**Location:** `src/components/molecules/FormField.tsx`

---

## PURPOSE

Input field with label and error messaging.
Consistent form interaction across all screens.

---

## VARIANTS

| Variant | Input Type | Keyboard | Validation |
|---------|-----------|----------|------------|
| `text` | Single line text | Default | Required |
| `email` | Email address | Email | Email format |
| `phone` | Phone number | Phone pad | Phone format |
| `password` | Password field | Default | Secure entry |

---

## ANATOMY

```
┌─────────────────────────────────────────────┐
│ Label Text                                  │
│ ┌─────────────────────────────────────────┐ │
│ │ Input placeholder text...               │ │
│ └─────────────────────────────────────────┘ │
│ Helper text or error message                │
└─────────────────────────────────────────────┘
```

---

## ATOMS USED

| Atom | Purpose |
|------|---------|
| Text (body) | Label text |
| Input | Text input field |
| Text (caption) | Helper text or error |

---

## PROPS INTERFACE

```typescript
interface FormFieldProps {
  // Content
  label: string;
  placeholder?: string;
  value: string;
  helperText?: string;
  
  // Appearance
  variant: 'text' | 'email' | 'phone' | 'password';
  
  // Validation
  error?: string;          // Error message from backend
  isValid?: boolean;
  isRequired?: boolean;
  
  // Events
  onChangeText: (text: string) => void;
  onBlur?: () => void;
  onFocus?: () => void;
  
  // Accessibility
  accessibilityLabel?: string;
  accessibilityHint?: string;
}
```

---

## VISUAL STATES

| State | Visual Change |
|-------|---------------|
| Default | Base appearance |
| Focused | Border color: primary (#FF6B35) |
| Error | Border color: error (#EF4444), show error text |
| Disabled | 50% opacity, no interaction |
| Filled | Label moves up (optional) |

---

## CHOSEN-STATE REQUIREMENTS

**MUST convey:**
- ✅ Field purpose is clear from label
- ✅ Current state (empty, filled, error) is obvious
- ✅ Error messages are actionable

**FORBIDDEN:**
- ❌ Client-side validation logic (use backend)
- ❌ Generic errors ("Invalid input")
- ❌ Missing labels
- ❌ Placeholder as label substitute

---

## USAGE EXAMPLES

### Text Input
```tsx
<FormField
  label="Full Name"
  placeholder="Enter your name"
  variant="text"
  value={formData.name}
  onChangeText={(text) => setFormData({...formData, name: text})}
  isRequired={true}
/>
```

### Email with Error
```tsx
<FormField
  label="Email Address"
  placeholder="you@example.com"
  variant="email"
  value={formData.email}
  onChangeText={(text) => setFormData({...formData, email: text})}
  error={validationErrors.email}
  isRequired={true}
/>
```

### Password Field
```tsx
<FormField
  label="Password"
  placeholder="Enter password"
  variant="password"
  value={formData.password}
  onChangeText={(text) => setFormData({...formData, password: text})}
  helperText="Must be at least 8 characters"
/>
```

### Phone Number
```tsx
<FormField
  label="Phone Number"
  placeholder="(555) 123-4567"
  variant="phone"
  value={formData.phone}
  onChangeText={(text) => setFormData({...formData, phone: text})}
/>
```

---

## MOTION

| Trigger | Animation |
|---------|-----------|
| Focus | Border color transition, 150ms |
| Error appear | Error text fade in, 200ms |
| Label float | Move up animation, 200ms (optional) |

---

## FORBIDDEN

```
❌ Computing validation rules client-side
❌ Email/phone format validation in component
❌ Password strength calculation
❌ Auto-formatting without user input
❌ Inline styles for states
❌ Missing error state styling
```

---

## DESIGN TOKENS

**Colors:**
- Label: `colors.textPrimary` (#FFFFFF)
- Input text: `colors.textPrimary` (#FFFFFF)
- Placeholder: `colors.textTertiary` (#6B7280)
- Helper text: `colors.textSecondary` (#9CA3AF)
- Error text: `colors.error` (#EF4444)
- Border default: `colors.border` (#374151)
- Border focused: `colors.primary` (#FF6B35)
- Border error: `colors.error` (#EF4444)
- Background: `colors.surface` (#1A1A1A)

**Typography:**
- Label: `typography.body` (16px Regular)
- Input: `typography.body` (16px Regular)
- Helper/error: `typography.caption` (14px Regular)

**Spacing:**
- Label to input: `spacing.xs` (4px)
- Input to helper: `spacing.xs` (4px)
- Input internal padding: `spacing.md` (16px)
- Field bottom margin: `spacing.lg` (24px)

**Sizes:**
- Input height: 48px
- Border width: 1px (default), 2px (focused)
- Border radius: 8px

---

## VALIDATION MESSAGES

Validation errors MUST come from backend API:

```typescript
// Backend response includes field-specific errors
{
  "errors": {
    "email": "Email address is already registered",
    "phone": "Phone number format is invalid"
  }
}

// Component displays these directly
<FormField
  error={apiErrors.email}
  // Shows: "Email address is already registered"
/>
```

---

**Last Updated:** 2026-02-05
**Author:** Claude Sonnet 4.5
