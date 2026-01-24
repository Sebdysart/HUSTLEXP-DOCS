/**
 * EntryScreen Component v2.0.0
 *
 * AUTHORITY: COLOR_SEMANTICS_LAW.md + PER/UI_ACCEPTANCE_PROTOCOL.md §UAP-5
 *
 * ═══════════════════════════════════════════════════════════════════════════
 * ✅ THIS IS THE CORRECT PATTERN FOR ENTRY SCREENS
 * ═══════════════════════════════════════════════════════════════════════════
 *
 * BRAND: Black + Purple (NOT green)
 * - Purple = Brand, energy, ambition
 * - Green = SUCCESS ONLY (never on entry screens)
 *
 * PASSES UAP-5:
 * ✅ Full-canvas composition (NOT card-based)
 * ✅ Purple gradient background (narrative surface)
 * ✅ Hierarchy: Brand → Value Prop → Context → Action
 * ✅ Logo fade-in animation (300ms)
 * ✅ Feels like DESTINATION, not popup
 *
 * FORBIDDEN:
 * ❌ Green background (green = "done", entry = "begin")
 * ❌ justifyContent: 'center' + alignItems: 'center' on container
 * ❌ <Card> wrapping all content
 * ❌ Flat black background with no gradient/glow
 */

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
// AUTHORITATIVE COLORS (Black + Purple Brand)
// ═══════════════════════════════════════════════════════════════════════════
// BRAND IS PURPLE, NOT GREEN. Green is for SUCCESS states only.

const COLORS = {
  // Brand Identity (NOT green)
  brand: {
    black: '#0B0B0F',           // Near-black (premium)
    purple: '#5B2DFF',          // Electric purple (primary)
    purpleLight: '#7A4DFF',     // Gradient
    purpleGlow: '#8B5CF6',      // Glow effects
    purpleMuted: '#A78BFA',     // Secondary purple
  },
  // Text
  text: {
    primary: '#FFFFFF',
    secondary: '#E5E5EA',
    muted: '#8E8E93',
  },
  // Gradient for entry screen (PURPLE tint, NOT green)
  gradient: {
    top: '#1a0a2e',             // Purple tint
    middle: '#0B0B0F',          // Brand black
    bottom: '#000000',          // Pure black
  },
};

const { height: SCREEN_HEIGHT } = Dimensions.get('window');

// ═══════════════════════════════════════════════════════════════════════════
// ENTRY SCREEN COMPONENT
// ═══════════════════════════════════════════════════════════════════════════

/**
 * @typedef {Object} EntryScreenProps
 * @property {() => void} onGetStarted - Primary CTA handler
 * @property {() => void} onSignIn - Secondary action handler
 */

/**
 * Entry Screen - First screen users see after app launch
 *
 * BRAND: Black + Purple (NOT green)
 * Green is reserved for SUCCESS states only.
 *
 * @param {EntryScreenProps} props
 */
export function EntryScreen({ onGetStarted, onSignIn }) {
  const insets = useSafeAreaInsets();
  const logoOpacity = useRef(new Animated.Value(0)).current;
  const contentOpacity = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    // Logo fade-in first (300ms) - Required by UAP-2
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
  }, [logoOpacity, contentOpacity]);

  return (
    <View style={styles.container}>
      {/* ═══════════════════════════════════════════════════════════════════
          PURPLE GRADIENT BACKGROUND — Required by COLOR_SEMANTICS_LAW
          NOT green. Purple = brand. Green = success only.
          ═══════════════════════════════════════════════════════════════════ */}
      <LinearGradient
        colors={[COLORS.gradient.top, COLORS.gradient.middle, COLORS.gradient.bottom]}
        locations={[0, 0.3, 1]}
        style={StyleSheet.absoluteFill}
      />

      {/* ═══════════════════════════════════════════════════════════════════
          PURPLE GLOW EFFECT — Brand energy, NOT green
          ═══════════════════════════════════════════════════════════════════ */}
      <View style={styles.glowContainer}>
        <View style={styles.glowOrb} />
      </View>

      {/* ═══════════════════════════════════════════════════════════════════
          FULL-CANVAS CONTENT LAYOUT
          NOTE: Content flows top-to-bottom, NOT centered in a card
          ═══════════════════════════════════════════════════════════════════ */}
      <View style={[styles.content, { paddingTop: insets.top + 60 }]}>

        {/* LAYER 1: BRAND MARK — with animated fade-in */}
        <Animated.View style={[styles.brandSection, { opacity: logoOpacity }]}>
          <View style={styles.logoContainer}>
            <Text style={styles.logoText}>H</Text>
          </View>
          <Text style={styles.brandName}>HustleXP</Text>
        </Animated.View>

        {/* LAYER 2: VALUE PROP + CONTEXT — spans full width */}
        <Animated.View style={[styles.valueSection, { opacity: contentOpacity }]}>
          {/* WHO/WHY — Primary value proposition */}
          <Text style={styles.headline}>
            Get things done.{'\n'}Get paid.
          </Text>

          {/* CONTEXT — Supporting explanation */}
          <Text style={styles.subheadline}>
            Post tasks and find help in minutes.{'\n'}
            Or earn money completing tasks nearby.
          </Text>
        </Animated.View>

        {/* SPACER — Pushes CTA to bottom of screen */}
        <View style={styles.spacer} />

        {/* LAYER 3: CTA SECTION — Anchored at bottom, NOT floating */}
        <Animated.View
          style={[
            styles.ctaSection,
            { paddingBottom: insets.bottom + 24, opacity: contentOpacity }
          ]}
        >
          {/* Primary Action — PURPLE button (NOT green) */}
          <TouchableOpacity
            style={styles.primaryButton}
            onPress={onGetStarted}
            activeOpacity={0.8}
          >
            <Text style={styles.primaryButtonText}>Get Started</Text>
          </TouchableOpacity>

          {/* Secondary Action */}
          <TouchableOpacity
            style={styles.secondaryButton}
            onPress={onSignIn}
            activeOpacity={0.7}
          >
            <Text style={styles.secondaryButtonText}>
              Already have an account?{' '}
              <Text style={styles.signInLink}>Sign in</Text>
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
  // ═══ CONTAINER ═══
  // NOTE: NO justifyContent: 'center' or alignItems: 'center' here
  // This is what makes it full-canvas instead of card-based
  container: {
    flex: 1,
    backgroundColor: COLORS.brand.black,
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
    backgroundColor: COLORS.brand.purple,  // PURPLE, not green
    opacity: 0.2,
    // iOS blur effect via shadow
    shadowColor: COLORS.brand.purple,      // PURPLE glow
    shadowOffset: { width: 0, height: 0 },
    shadowOpacity: 0.8,
    shadowRadius: 60,
  },

  // ═══ CONTENT LAYOUT ═══
  // Flows top-to-bottom with explicit spacing
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
    backgroundColor: COLORS.brand.purple,   // PURPLE logo container
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 16,
    // Purple glow on logo
    shadowColor: COLORS.brand.purple,
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.4,
    shadowRadius: 12,
  },
  logoText: {
    fontSize: 40,
    fontWeight: '700',
    color: COLORS.text.primary,
  },
  brandName: {
    fontSize: 28,
    fontWeight: '700',
    color: COLORS.text.primary,
    letterSpacing: -0.5,
  },

  // ═══ VALUE PROP SECTION ═══
  valueSection: {
    alignItems: 'center',
  },
  headline: {
    fontSize: 32,
    fontWeight: '700',
    color: COLORS.text.primary,
    textAlign: 'center',
    lineHeight: 40,
    marginBottom: 16,
  },
  subheadline: {
    fontSize: 17,
    fontWeight: '400',
    color: COLORS.text.secondary,
    textAlign: 'center',
    lineHeight: 24,
  },

  // ═══ SPACER ═══
  // Pushes CTA section to bottom
  spacer: {
    flex: 1,
    minHeight: 40,
  },

  // ═══ CTA SECTION ═══
  // Anchored at bottom, NOT floating as a card
  ctaSection: {
    width: '100%',
  },
  primaryButton: {
    backgroundColor: COLORS.brand.purple,   // PURPLE button, NOT green
    paddingVertical: 16,
    borderRadius: 14,
    alignItems: 'center',
    marginBottom: 16,
    // Purple glow on button
    shadowColor: COLORS.brand.purple,
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 8,
  },
  primaryButtonText: {
    fontSize: 17,
    fontWeight: '600',
    color: COLORS.text.primary,
  },
  secondaryButton: {
    alignItems: 'center',
    paddingVertical: 8,
  },
  secondaryButtonText: {
    fontSize: 15,
    color: COLORS.text.muted,
  },
  signInLink: {
    color: COLORS.brand.purpleMuted,        // Purple link, not green
    fontWeight: '600',
  },
});

export default EntryScreen;
