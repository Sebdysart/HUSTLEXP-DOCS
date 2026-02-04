# COPY THIS, NOT THAT — AI Code Generation Guide

**STATUS: MANDATORY**
**PURPOSE: Show AI tools exactly what to copy and what to avoid**

---

## Entry/Welcome Screens

### ❌ NEVER COPY THIS (Fails UAP-5)

```tsx
// ❌ WRONG — Card-based layout
export function EntryScreen() {
  return (
    <View style={styles.container}>
      <Text style={styles.title}>HustleXP</Text>
      <TouchableOpacity style={styles.button}>
        <Text>Get Started</Text>
      </TouchableOpacity>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#000000',
    justifyContent: 'center',      // ❌ FORBIDDEN
    alignItems: 'center',          // ❌ FORBIDDEN
  },
  title: {
    fontSize: 32,
    color: '#FFFFFF',
    marginBottom: 24,
  },
  button: {
    backgroundColor: '#1FAD7E',
    paddingHorizontal: 32,
    paddingVertical: 16,
    borderRadius: 12,
  },
});
```

**WHY IT FAILS:**
- `justifyContent: 'center'` + `alignItems: 'center'` = card-based
- No gradient background = flat/boring
- No value prop, no context, no hierarchy
- Looks like a popup, not a destination

---

### ✅ ALWAYS COPY THIS (Passes UAP-5)

```tsx
// ✅ CORRECT — Full-canvas composition
import { LinearGradient } from 'expo-linear-gradient';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

export function EntryScreen({ onGetStarted, onSignIn }) {
  const insets = useSafeAreaInsets();
  const logoOpacity = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    Animated.timing(logoOpacity, {
      toValue: 1,
      duration: 300,
      useNativeDriver: true,
    }).start();
  }, []);

  return (
    <View style={styles.container}>
      {/* NARRATIVE BACKGROUND — Required */}
      <LinearGradient
        colors={['#0a2f1f', '#000000', '#000000']}
        locations={[0, 0.4, 1]}
        style={StyleSheet.absoluteFill}
      />

      {/* GLOW EFFECT — Adds depth */}
      <View style={styles.glowContainer}>
        <View style={styles.glowOrb} />
      </View>

      {/* FULL-CANVAS CONTENT */}
      <View style={[styles.content, { paddingTop: insets.top + 60 }]}>

        {/* BRAND — with animation */}
        <Animated.View style={[styles.brandSection, { opacity: logoOpacity }]}>
          <View style={styles.logoContainer}>
            <Text style={styles.logoText}>H</Text>
          </View>
          <Text style={styles.brandName}>HustleXP</Text>
        </Animated.View>

        {/* VALUE PROP */}
        <View style={styles.valueSection}>
          <Text style={styles.headline}>Get things done.{'\n'}Get paid.</Text>
          <Text style={styles.subheadline}>
            Post tasks and find help in minutes.{'\n'}
            Or earn money completing tasks nearby.
          </Text>
        </View>

        {/* SPACER — pushes CTA to bottom */}
        <View style={styles.spacer} />

        {/* CTA — anchored at bottom */}
        <View style={[styles.ctaSection, { paddingBottom: insets.bottom + 24 }]}>
          <TouchableOpacity style={styles.primaryButton} onPress={onGetStarted}>
            <Text style={styles.primaryButtonText}>Get Started</Text>
          </TouchableOpacity>
          <TouchableOpacity style={styles.secondaryButton} onPress={onSignIn}>
            <Text style={styles.secondaryText}>
              Already have an account? <Text style={styles.link}>Sign in</Text>
            </Text>
          </TouchableOpacity>
        </View>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#000000',
    // ✅ NO justifyContent: 'center' here
  },
  glowContainer: {
    ...StyleSheet.absoluteFillObject,
    alignItems: 'center',
    paddingTop: 120,
  },
  glowOrb: {
    width: 200,
    height: 200,
    borderRadius: 100,
    backgroundColor: '#1FAD7E',
    opacity: 0.15,
    shadowColor: '#1FAD7E',
    shadowRadius: 60,
    shadowOpacity: 0.8,
  },
  content: {
    flex: 1,
    paddingHorizontal: 24,
    // ✅ Content flows top-to-bottom
  },
  brandSection: {
    alignItems: 'center',
    marginBottom: 48,
  },
  logoContainer: {
    width: 80,
    height: 80,
    borderRadius: 20,
    backgroundColor: '#1FAD7E',
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 16,
  },
  logoText: { fontSize: 40, fontWeight: '700', color: '#FFFFFF' },
  brandName: { fontSize: 28, fontWeight: '700', color: '#FFFFFF' },
  valueSection: { alignItems: 'center' },
  headline: {
    fontSize: 32,
    fontWeight: '700',
    color: '#FFFFFF',
    textAlign: 'center',
    lineHeight: 40,
    marginBottom: 16,
  },
  subheadline: {
    fontSize: 17,
    color: '#E5E5EA',
    textAlign: 'center',
    lineHeight: 24,
  },
  spacer: {
    flex: 1,        // ✅ Pushes CTA to bottom
    minHeight: 40,
  },
  ctaSection: { width: '100%' },
  primaryButton: {
    backgroundColor: '#1FAD7E',
    paddingVertical: 16,
    borderRadius: 14,
    alignItems: 'center',
    marginBottom: 16,
  },
  primaryButtonText: { fontSize: 17, fontWeight: '600', color: '#FFFFFF' },
  secondaryButton: { alignItems: 'center', paddingVertical: 8 },
  secondaryText: { fontSize: 15, color: '#8E8E93' },
  link: { color: '#1FAD7E', fontWeight: '600' },
});
```

**WHY IT PASSES:**
- LinearGradient background = narrative surface
- Content flows top-to-bottom, not centered
- Spacer pushes CTA to bottom = anchored, not floating
- Has brand, value prop, context, and action
- Feels like arrival, not interruption

---

## Quick Reference: Forbidden vs Required

| Pattern | Entry Screens | Content Screens |
|---------|---------------|-----------------|
| `justifyContent: 'center'` on container | ❌ FORBIDDEN | ✅ OK |
| `alignItems: 'center'` on container | ❌ FORBIDDEN | ✅ OK |
| `<Card>` wrapping all content | ❌ FORBIDDEN | ✅ OK |
| Flat `#000000` background | ❌ FORBIDDEN | ✅ OK |
| `LinearGradient` background | ✅ REQUIRED | Optional |
| Glow/depth effects | ✅ REQUIRED | Optional |
| Logo animation (300ms fade) | ✅ REQUIRED | Optional |
| Spacer to push CTA bottom | ✅ REQUIRED | Optional |

---

## File to Copy

**For Entry/Welcome screens, always start from:**

```
reference/components/EntryScreen.js
```

This file is the authoritative, UAP-5 compliant template.

---

## Test Your Screen

Ask yourself:

> **"Does this screen feel like I've ARRIVED somewhere, or like I'm dismissing a popup?"**

- If popup → FAILS UAP-5 → Rewrite using the template above
- If arrival → PASSES UAP-5 → Continue

---

**END OF COPY_THIS_NOT_THAT.md**
