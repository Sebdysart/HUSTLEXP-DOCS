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
const BRAND_PRIMARY = '#1FAD7E';     // HustleXP teal-green
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
❌ Use #FF6B35 (wrong) — use #1FAD7E (brand) or #34C759 (success)
```

---

## THE BOOTSTRAP SCREEN (FIXED COLORS)

**File:** `hustlexp-app/screens/BootstrapScreen.tsx`

```tsx
import React from 'react';
import { View, Text, TouchableOpacity, StyleSheet } from 'react-native';

// AUTHORITATIVE COLORS — DO NOT CHANGE
const colors = {
  background: '#000000',        // Pure black (STITCH spec)
  brandPrimary: '#1FAD7E',      // HustleXP teal-green
  textPrimary: '#FFFFFF',
  textMuted: '#8E8E93',
  glass: {
    surface: 'rgba(28, 28, 30, 0.6)',
    border: 'rgba(255, 255, 255, 0.1)',
  },
};

export function BootstrapScreen() {
  const handlePress = () => {
    console.log('Button pressed');
  };

  return (
    <View style={styles.container}>
      <Text style={styles.title}>HustleXP</Text>
      <TouchableOpacity style={styles.button} onPress={handlePress}>
        <Text style={styles.buttonText}>Get Started</Text>
      </TouchableOpacity>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.background,  // #000000
    justifyContent: 'center',
    alignItems: 'center',
  },
  title: {
    fontSize: 32,
    fontWeight: 'bold',
    color: colors.textPrimary,  // #FFFFFF
    marginBottom: 24,
  },
  button: {
    backgroundColor: colors.brandPrimary,  // #1FAD7E (NOT #FF6B35)
    paddingHorizontal: 32,
    paddingVertical: 16,
    borderRadius: 12,
  },
  buttonText: {
    fontSize: 16,
    fontWeight: '600',
    color: colors.textPrimary,  // #FFFFFF
  },
});
```

---

## VERIFICATION STEPS

### Step 1: Clean Build
```bash
cd hustlexp-app
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
[ ] Teal-green (#1FAD7E) "Get Started" button visible
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

**File:** `hustlexp-app/App.tsx`

```tsx
import React from 'react';
import { BootstrapScreen } from './screens/BootstrapScreen';

export default function App() {
  return <BootstrapScreen />;
}
```

**That's it. Nothing else.**

---

## WHAT HAPPENS AFTER BOOTSTRAP PASSES

Once ALL criteria are met:

1. **Phase 1:** Add navigation shell (no screens yet)
2. **Phase 2:** Add HomeScreen (real one, replacing Bootstrap)
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
