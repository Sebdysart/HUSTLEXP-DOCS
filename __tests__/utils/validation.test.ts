/**
 * Validation Utility Tests
 *
 * Tests for form validation patterns
 * AUTHORITY: VALIDATION_PATTERNS.md
 */

// Validation patterns from VALIDATION_PATTERNS.md
const EMAIL_PATTERN = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
const PASSWORD_RULES = [
  { pattern: /.{8,}/, message: 'At least 8 characters' },
  { pattern: /[A-Z]/, message: 'At least one uppercase letter' },
  { pattern: /[a-z]/, message: 'At least one lowercase letter' },
  { pattern: /[0-9]/, message: 'At least one number' },
];
const PHONE_PATTERN =
  /^(\+1)?[\s.-]?\(?\d{3}\)?[\s.-]?\d{3}[\s.-]?\d{4}$/;
const NAME_PATTERN = /^[a-zA-Z\s'-]+$/;

// Validation functions
const validateEmail = (email: string): string | null => {
  if (!email?.trim()) return 'Email is required';
  if (email.length > 255) return 'Email must be less than 255 characters';
  if (!EMAIL_PATTERN.test(email)) return 'Enter a valid email address';
  return null;
};

const validatePassword = (password: string): string[] => {
  const errors: string[] = [];
  if (!password) {
    errors.push('Password is required');
    return errors;
  }
  for (const rule of PASSWORD_RULES) {
    if (!rule.pattern.test(password)) {
      errors.push(rule.message);
    }
  }
  return errors;
};

const validatePhone = (phone: string): string | null => {
  if (!phone) return null; // Phone is optional
  if (!PHONE_PATTERN.test(phone)) return 'Enter a valid US phone number';
  return null;
};

const validateName = (name: string): string | null => {
  if (!name?.trim()) return 'Name is required';
  if (name.length < 2) return 'Name must be at least 2 characters';
  if (name.length > 100) return 'Name must be less than 100 characters';
  if (!NAME_PATTERN.test(name)) {
    return 'Name can only contain letters, spaces, hyphens, and apostrophes';
  }
  return null;
};

const validatePrice = (
  price: number,
  mode: 'STANDARD' | 'LIVE' = 'STANDARD'
): string | null => {
  if (price === null || price === undefined) return 'Price is required';
  const minPrice = mode === 'LIVE' ? 1500 : 500;
  if (price < minPrice) {
    return mode === 'LIVE'
      ? 'Minimum price for Live tasks is $15.00'
      : 'Minimum price is $5.00';
  }
  if (price > 1000000) return 'Maximum price is $10,000.00';
  return null;
};

describe('Email Validation', () => {
  it('rejects empty email', () => {
    expect(validateEmail('')).toBe('Email is required');
  });

  it('rejects whitespace-only email', () => {
    expect(validateEmail('   ')).toBe('Email is required');
  });

  it('accepts valid email', () => {
    expect(validateEmail('user@example.com')).toBeNull();
  });

  it('accepts email with subdomain', () => {
    expect(validateEmail('user@mail.example.com')).toBeNull();
  });

  it('rejects email without @', () => {
    expect(validateEmail('userexample.com')).toBe('Enter a valid email address');
  });

  it('rejects email without domain', () => {
    expect(validateEmail('user@')).toBe('Enter a valid email address');
  });

  it('rejects email without TLD', () => {
    expect(validateEmail('user@example')).toBe('Enter a valid email address');
  });

  it('rejects very long email', () => {
    const longEmail = 'a'.repeat(250) + '@example.com';
    expect(validateEmail(longEmail)).toBe(
      'Email must be less than 255 characters'
    );
  });
});

describe('Password Validation', () => {
  it('rejects empty password', () => {
    expect(validatePassword('')).toContain('Password is required');
  });

  it('rejects short password', () => {
    expect(validatePassword('Ab1')).toContain('At least 8 characters');
  });

  it('requires uppercase letter', () => {
    expect(validatePassword('abcdefg1')).toContain(
      'At least one uppercase letter'
    );
  });

  it('requires lowercase letter', () => {
    expect(validatePassword('ABCDEFG1')).toContain(
      'At least one lowercase letter'
    );
  });

  it('requires number', () => {
    expect(validatePassword('Abcdefgh')).toContain('At least one number');
  });

  it('accepts valid password', () => {
    expect(validatePassword('ValidPass1')).toHaveLength(0);
  });

  it('accepts complex password', () => {
    expect(validatePassword('MyStr0ng!P@ssword')).toHaveLength(0);
  });
});

describe('Phone Validation', () => {
  it('accepts empty phone (optional)', () => {
    expect(validatePhone('')).toBeNull();
  });

  it('accepts standard US format', () => {
    expect(validatePhone('(555) 123-4567')).toBeNull();
  });

  it('accepts format with dashes', () => {
    expect(validatePhone('555-123-4567')).toBeNull();
  });

  it('accepts format with dots', () => {
    expect(validatePhone('555.123.4567')).toBeNull();
  });

  it('accepts format with +1', () => {
    expect(validatePhone('+1 555 123 4567')).toBeNull();
  });

  it('rejects too few digits', () => {
    expect(validatePhone('555-1234')).toBe('Enter a valid US phone number');
  });

  it('rejects too many digits', () => {
    expect(validatePhone('555-123-45678')).toBe('Enter a valid US phone number');
  });
});

describe('Name Validation', () => {
  it('rejects empty name', () => {
    expect(validateName('')).toBe('Name is required');
  });

  it('rejects single character', () => {
    expect(validateName('A')).toBe('Name must be at least 2 characters');
  });

  it('accepts simple name', () => {
    expect(validateName('John')).toBeNull();
  });

  it('accepts name with space', () => {
    expect(validateName('John Doe')).toBeNull();
  });

  it('accepts name with hyphen', () => {
    expect(validateName('Mary-Jane')).toBeNull();
  });

  it('accepts name with apostrophe', () => {
    expect(validateName("O'Connor")).toBeNull();
  });

  it('rejects name with numbers', () => {
    expect(validateName('John123')).toBe(
      'Name can only contain letters, spaces, hyphens, and apostrophes'
    );
  });

  it('rejects very long name', () => {
    const longName = 'A'.repeat(101);
    expect(validateName(longName)).toBe(
      'Name must be less than 100 characters'
    );
  });
});

describe('Price Validation', () => {
  it('rejects null price', () => {
    expect(validatePrice(null as any)).toBe('Price is required');
  });

  it('rejects price below minimum (STANDARD)', () => {
    expect(validatePrice(400)).toBe('Minimum price is $5.00');
  });

  it('accepts price at minimum (STANDARD)', () => {
    expect(validatePrice(500)).toBeNull();
  });

  it('rejects price below minimum (LIVE)', () => {
    expect(validatePrice(1400, 'LIVE')).toBe(
      'Minimum price for Live tasks is $15.00'
    );
  });

  it('accepts price at minimum (LIVE)', () => {
    expect(validatePrice(1500, 'LIVE')).toBeNull();
  });

  it('rejects price above maximum', () => {
    expect(validatePrice(1000001)).toBe('Maximum price is $10,000.00');
  });

  it('accepts price at maximum', () => {
    expect(validatePrice(1000000)).toBeNull();
  });
});
