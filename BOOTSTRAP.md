# BOOTSTRAP CONTRACT — HUSTLEXP RUNTIME BASELINE

**STATUS: BLOCKING — Nothing else proceeds until this passes**
**Owner: Frontend (Cursor)**
**Validator: Xcode Simulator**
**Frontend Repo: [HUSTLEXPFINAL1](https://github.com/Sebdysart/HUSTLEXPFINAL1)**

---

## PURPOSE

This document defines the **MINIMUM VIABLE STATE** required before ANY other work can proceed.

Until Bootstrap passes:
- ❌ No new screens
- ❌ No maps
- ❌ No SVG
- ❌ No backend calls
- ❌ No complex navigation
- ❌ No new dependencies

---

## AUTHORITATIVE COLOR TOKENS

**USE THESE EXACT VALUES. NO EXCEPTIONS.**

```typescript
// Brand
const BRAND_PRIMARY = '#5B2DFF';     // HustleXP purple
const BRAND_YELLOW = '#FFD900';      // Instant mode

// Apple System Colors
const APPLE_RED = '#FF3B30';
const APPLE_ORANGE = '#FF9500';
const APPLE_GREEN = '#34C759';
const APPLE_BLUE = '#007AFF';
const APPLE_GRAY = '#8E8E93';

// Background
const BACKGROUND_DARK = '#000000';   // NOT #0D0D0D

// Glass
const GLASS_SURFACE = 'rgba(28, 28, 30, 0.6)';
const GLASS_BORDER = 'rgba(255, 255, 255, 0.1)';

// Text
const TEXT_PRIMARY = '#FFFFFF';
const TEXT_MUTED = '#8E8E93';
```

---

## SUCCESS CRITERIA

### The app MUST:

```
✅ Build without errors in Xcode
✅ Launch in iOS Simulator without crashing
✅ Display ONE screen (HomeScreen)
✅ Show static text: "HustleXP"
✅ Show ONE button: "Get Started"
✅ Button tap logs to console: "Button pressed"
✅ No red error screens
✅ No yellow warning screens
✅ No crashes for 30 seconds of idle
✅ Use CORRECT colors from tokens above
```

### The app MUST NOT:

```
❌ Make any network requests
❌ Use any maps or location services
❌ Use any SVG or complex graphics
❌ Navigate to other screens
❌ Access any backend APIs
❌ Use any state management beyond local useState
❌ Import any packages not in current package.json
❌ Use #0D0D0D (wrong) — use #000000
❌ Use #FF6B35 (wrong) — use #5B2DFF (brand) or #34C759 (success)
```

---

## THE ENTRY SCREEN (UAP-5 COMPLIANT)

> **THIS IS THE CORRECT PATTERN.** Copy this, not minimal card layouts.

**File:** `HUSTLEXPFINAL1/screens/EntryScreen.tsx`

```tsx
import React, { useEffect, useRef } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
  Animated,
  Dimensions,
} from 'react-native';
import { LinearGradient } from 'expo-linear-gradient';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

// ═══════════════════════════════════════════════════════════════════════════
// AUTHORITATIVE COLORS — BLACK + PURPLE BRAND (NOT GREEN)
// ═══════════════════════════════════════════════════════════════════════════
// Green = SUCCESS ONLY. Purple = Brand. See COLOR_SEMANTICS_LAW.md
const colors = {
  brandBlack: '#0B0B0F',        // Near-black (premium)
  brandPurple: '#5B2DFF',       // Electric purple (primary)
  brandPurpleMuted: '#A78BFA',  // Softer purple
  textPrimary: '#FFFFFF',
  textSecondary: '#E5E5EA',
  textMuted: '#8E8E93',
};

const { height: SCREEN_HEIGHT } = Dimensions.get('window');

// ═══════════════════════════════════════════════════════════════════════════
// ENTRY SCREEN — UAP-5 FULL-CANVAS COMPOSITION
// ═══════════════════════════════════════════════════════════════════════════
// ✅ PASSES UAP-5:
//    - Full-canvas composition (NOT card-based)
//    - Gradient background (narrative surface)
//    - Hierarchy: Brand → Value Prop → Context → Action
//    - Logo fade-in animation
//    - Feels like DESTINATION, not popup
// ═══════════════════════════════════════════════════════════════════════════

interface EntryScreenProps {
  onGetStarted: () => void;
  onSignIn: () => void;
}

export function EntryScreen({ onGetStarted, onSignIn }: EntryScreenProps) {
  const insets = useSafeAreaInsets();
  const logoOpacity = useRef(new Animated.Value(0)).current;
  const contentOpacity = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    // Logo fade-in first (300ms)
    Animated.timing(logoOpacity, {
      toValue: 1,
      duration: 300,
      useNativeDriver: true,
    }).start(() => {
      // Then content fade-in (400ms)
      Animated.timing(contentOpacity, {
        toValue: 1,
        duration: 400,
        useNativeDriver: true,
      }).start();
    });
  }, []);

  return (
    <View style={styles.container}>
      {/* ═══ PURPLE GRADIENT BACKGROUND (Required by COLOR_SEMANTICS_LAW) ═══ */}
      <LinearGradient
        colors={['#1a0a2e', '#0B0B0F', '#000000']}  // PURPLE tint, NOT green
        locations={[0, 0.3, 1]}
        style={StyleSheet.absoluteFill}
      />

      {/* ═══ PURPLE GLOW EFFECT (NOT green) ═══ */}
      <View style={styles.glowContainer}>
        <View style={styles.glowOrb} />  {/* backgroundColor: colors.brandPurple */}
      </View>

      {/* ═══ FULL-CANVAS CONTENT (NOT centered card) ═══ */}
      <View style={[styles.content, { paddingTop: insets.top + 60 }]}>

        {/* BRAND MARK — with animated fade-in */}
        <Animated.View style={[styles.brandSection, { opacity: logoOpacity }]}>
          <View style={styles.logoContainer}>
            <Text style={styles.logoText}>H</Text>
          </View>
          <Text style={styles.brandName}>HustleXP</Text>
        </Animated.View>

        {/* VALUE PROP + CONTEXT — spans full width */}
        <Animated.View style={[styles.valueSection, { opacity: contentOpacity }]}>
          <Text style={styles.headline}>Get things done.{'\n'}Get paid.</Text>
          <Text style={styles.subheadline}>
            Post tasks and find help in minutes.{'\n'}
            Or earn money completing tasks nearby.
          </Text>
        </Animated.View>

        {/* SPACER — pushes CTA to bottom */}
        <View style={styles.spacer} />

        {/* CTA SECTION — anchored at bottom, NOT floating card */}
        <Animated.View
          style={[
            styles.ctaSection,
            { paddingBottom: insets.bottom + 24, opacity: contentOpacity }
          ]}
        >
          <TouchableOpacity style={styles.primaryButton} onPress={onGetStarted}>
            <Text style={styles.primaryButtonText}>Get Started</Text>
          </TouchableOpacity>

          <TouchableOpacity style={styles.secondaryButton} onPress={onSignIn}>
            <Text style={styles.secondaryButtonText}>
              Already have an account? <Text style={styles.signInLink}>Sign in</Text>
            </Text>
          </TouchableOpacity>
        </Animated.View>
      </View>
    </View>
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// STYLES — UAP-5 COMPLIANT + BLACK/PURPLE BRAND
// ═══════════════════════════════════════════════════════════════════════════
const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.brandBlack,  // #0B0B0F, NOT green
  },

  // ═══ PURPLE GLOW EFFECT ═══
  glowContainer: {
    ...StyleSheet.absoluteFillObject,
    alignItems: 'center',
    justifyContent: 'flex-start',
    paddingTop: SCREEN_HEIGHT * 0.15,
  },
  glowOrb: {
    width: 200,
    height: 200,
    borderRadius: 100,
    backgroundColor: colors.brandPurple,   // PURPLE #5B2DFF, NOT green
    opacity: 0.2,
    // Purple glow via shadow on iOS
    shadowColor: colors.brandPurple,
    shadowOffset: { width: 0, height: 0 },
    shadowOpacity: 0.8,
    shadowRadius: 60,
  },

  // ═══ FULL-CANVAS CONTENT LAYOUT ═══
  // NOTE: NO justifyContent: 'center' + alignItems: 'center'
  // Content flows top-to-bottom with explicit spacing
  content: {
    flex: 1,
    paddingHorizontal: 24,
  },

  // ═══ BRAND SECTION ═══
  brandSection: {
    alignItems: 'center',
    marginBottom: 48,
  },
  logoContainer: {
    width: 80,
    height: 80,
    borderRadius: 20,
    backgroundColor: colors.brandPurple,   // PURPLE #5B2DFF, NOT green
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 16,
    // Purple glow on logo
    shadowColor: colors.brandPurple,
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.4,
    shadowRadius: 12,
  },
  logoText: {
    fontSize: 40,
    fontWeight: '700',
    color: colors.textPrimary,
  },
  brandName: {
    fontSize: 28,
    fontWeight: '700',
    color: colors.textPrimary,
    letterSpacing: -0.5,
  },

  // ═══ VALUE PROP SECTION ═══
  valueSection: {
    alignItems: 'center',
  },
  headline: {
    fontSize: 32,
    fontWeight: '700',
    color: colors.textPrimary,
    textAlign: 'center',
    lineHeight: 40,
    marginBottom: 16,
  },
  subheadline: {
    fontSize: 17,
    fontWeight: '400',
    color: colors.textSecondary,
    textAlign: 'center',
    lineHeight: 24,
  },

  // ═══ SPACER (pushes CTA to bottom) ═══
  spacer: {
    flex: 1,
    minHeight: 40,
  },

  // ═══ CTA SECTION (anchored, NOT floating) ═══
  ctaSection: {
    width: '100%',
  },
  primaryButton: {
    backgroundColor: colors.brandPurple,   // PURPLE #5B2DFF, NOT green
    paddingVertical: 16,
    borderRadius: 14,
    alignItems: 'center',
    marginBottom: 16,
    // Purple glow on button
    shadowColor: colors.brandPurple,
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 8,
  },
  primaryButtonText: {
    fontSize: 17,
    fontWeight: '600',
    color: colors.textPrimary,
  },
  secondaryButton: {
    alignItems: 'center',
    paddingVertical: 8,
  },
  secondaryButtonText: {
    fontSize: 15,
    color: colors.textMuted,
  },
  signInLink: {
    color: colors.brandPurpleMuted,        // Muted purple, NOT green
    fontWeight: '600',
  },
});
```

---

## INTERNAL BOOTSTRAP VERIFICATION (Debug Only)

> ⚠️ **FOR INTERNAL TESTING ONLY.** This minimal screen verifies the app boots.
> It is NOT a production screen. NEVER ship this. NEVER copy this pattern.

```tsx
// #if DEBUG — INTERNAL ONLY
// This is NOT a user-facing screen. See EntryScreen above for correct pattern.
export function _InternalBootstrapVerification() {
  return (
    <View style={{ flex: 1, backgroundColor: '#000', justifyContent: 'center', alignItems: 'center' }}>
      <Text style={{ color: '#FFF' }}>Bootstrap OK</Text>
    </View>
  );
}
```

---

## VERIFICATION STEPS

### Step 1: Clean Build
```bash
cd HUSTLEXPFINAL1
rm -rf node_modules
rm -rf ios/Pods
rm -rf ios/build
npm install
cd ios && pod install && cd ..
```

### Step 2: Open in Xcode
```bash
open ios/HustleXP.xcworkspace
```

### Step 3: Run in Simulator
- Select: iPhone 15 Pro (or any iOS 17+ simulator)
- Press: ⌘R (Run)
- Wait for app to launch

### Step 4: Verify Criteria
```
[ ] App builds without errors
[ ] App launches without crashing
[ ] Black screen with "HustleXP" text visible
[ ] Teal-green (#5B2DFF) "Get Started" button visible
[ ] Tap button → "Button pressed" appears in Xcode console
[ ] App does not crash after 30 seconds idle
```

---

## FAILURE MODES

### If Build Fails:
1. Read the exact error message
2. Do NOT add dependencies to fix it
3. Do NOT modify Podfile unless absolutely necessary
4. Report the exact error to user

### If App Crashes on Launch:
1. Check Xcode console for crash log
2. Look for missing imports or undefined components
3. Verify App.tsx only renders BootstrapScreen
4. Report the exact crash to user

### If Screen is Blank:
1. Verify BootstrapScreen is exported correctly
2. Verify App.tsx imports and renders BootstrapScreen
3. Check for silent JavaScript errors in Metro console

---

## APP.TSX FOR BOOTSTRAP

**File:** `HUSTLEXPFINAL1/App.tsx`

```tsx
import React from 'react';
import { BootstrapScreen } from './screens/BootstrapScreen';

export default function App() {
  return <BootstrapScreen />;
}
```

**That's it. Nothing else.**

---

## PRODUCTION ENTRY SCREEN REQUIREMENTS (UAP-5)

> **CRITICAL:** When replacing the Bootstrap Screen with the real Entry Screen,
> it MUST pass UAP-5 (Full-Canvas Immersion Gate). Card-based layouts are FORBIDDEN.

### ❌ FORBIDDEN PATTERNS (Will Fail UAP-5):

```
┌─────────────────────────────────────┐
│ ████████████████████████████████████│ ← Black empty space
│    ┌─────────────────────────┐      │
│    │       HustleXP          │      │ ← Centered card (FORBIDDEN)
│    │   "Where hustlers..."   │      │
│    └─────────────────────────┘      │
│    ┌─────────────────────────┐      │
│    │     [ Get Started ]     │      │ ← Separate card (FORBIDDEN)
│    └─────────────────────────┘      │
│ ████████████████████████████████████│ ← Black empty space
└─────────────────────────────────────┘
```

### ✅ REQUIRED PATTERN (Passes UAP-5):

```
┌─────────────────────────────────────┐
│ ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░│ ← Gradient/glow background
│ ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░│
│          🟢 HustleXP               │ ← Brand mark (animated fade-in)
│                                     │
│    Get things done. Get paid.       │ ← Value prop (WHO/WHY)
│                                     │
│    Post tasks and find help in      │ ← Supporting context
│    minutes. Or earn money           │
│    completing tasks nearby.         │
│                                     │
│    ┌─────────────────────────────┐  │
│    │        Get Started          │  │ ← CTA anchored at bottom
│    └─────────────────────────────┘  │
│      Already have an account?       │ ← Secondary action
└─────────────────────────────────────┘
```

### Technical Implementation Rules:

```
FORBIDDEN:
• <Card> wrapping all content
• justify-content: center + alignItems: center + single child
• backgroundColor: '#000000' with no gradient/glow
• Modal-like border radius on content container

REQUIRED:
• Background: LinearGradient or subtle glow treatment
• Hierarchy: Brand → Value Prop → Context → Action
• Full-canvas composition (no floating cards)
• Logo fade-in animation (300ms)
```

**Reference:** `PER/UI_ACCEPTANCE_PROTOCOL.md` §UAP-5

---

## WHAT HAPPENS AFTER BOOTSTRAP PASSES

Once ALL criteria are met:

1. **Phase 1:** Add navigation shell (no screens yet)
2. **Phase 2:** Add Entry Screen (UAP-5 compliant, replacing Bootstrap)
3. **Phase 3:** Add one screen at a time from SCREEN_REGISTRY
4. **Phase 4:** Add backend integration (one endpoint at a time)

**Each phase requires explicit user approval to proceed.**

---

## CURRENT STATUS

```
[ ] Build passes
[ ] Launch passes  
[ ] Screen renders
[ ] Button works
[ ] 30-second stability

BOOTSTRAP STATUS: ❌ NOT PASSED
```

---

## REMEMBER

> **Until Bootstrap passes, the app does not exist.**

All other work is theoretical until we prove the app can:
1. Build
2. Launch
3. Render
4. Respond to input
5. Not crash

This is the foundation. Everything else is built on top of this.

**No exceptions. No shortcuts. No "but we need to add X first."**
