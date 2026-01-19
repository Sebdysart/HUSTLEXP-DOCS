/**
 * FirstXPCelebration - First XP celebration animation (ONBOARDING_SPEC §13.4, UI_SPEC §12.4)
 * 
 * TRIGGERS WHEN:
 * - xp_first_celebration_shown_at IS NULL
 * - AND first XP awarded
 * - AND user role = 'worker' OR 'dual'
 * 
 * VISUAL SEQUENCE (2000ms max):
 * - 0-300ms: XP number fade in + scale 1.0→1.1→1.0
 * - 300-800ms: Progress bar linear fill
 * - 800-1200ms: "First Task Complete!" fade in
 * - 1200-1800ms: Badge unlock (if earned)
 * - 1800-2000ms: Settle to static
 * 
 * CONSTRAINTS:
 * - No confetti (UI_SPEC §3.2 M2)
 * - No sound
 * - No shake/vibrate
 * - Server-tracked: xp_first_celebration_shown_at
 * - Reduced motion: All instant, no animation
 * 
 * SPEC: ONBOARDING_SPEC.md §13.4, UI_SPEC.md §12.4
 */

import React, { useEffect, useRef, useState } from 'react';
import { View, StyleSheet, Animated } from 'react-native';
import { HXText } from './Text';
import { XP, NEUTRAL } from '../constants/colors';
import { SPACING } from '../constants/spacing';
import { FIRST_XP_CELEBRATION } from '../constants/animations';

export function FirstXPCelebration({ 
  xpAmount, 
  levelProgress, 
  badgeUnlocked,
  onComplete,
  reducedMotion = false,
}) {
  const [isVisible, setIsVisible] = useState(true);
  const xpScaleAnim = useRef(new Animated.Value(0)).current;
  const xpOpacityAnim = useRef(new Animated.Value(0)).current;
  const progressAnim = useRef(new Animated.Value(0)).current;
  const messageOpacityAnim = useRef(new Animated.Value(0)).current;
  const badgeOpacityAnim = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    if (reducedMotion) {
      // Reduced motion: All instant
      xpOpacityAnim.setValue(1);
      progressAnim.setValue(levelProgress);
      messageOpacityAnim.setValue(1);
      if (badgeUnlocked) {
        badgeOpacityAnim.setValue(1);
      }
      setTimeout(() => {
        setIsVisible(false);
        onComplete?.();
      }, 100);
      return;
    }

    // Sequence 1: XP number fade in + scale (0-300ms)
    Animated.parallel([
      Animated.timing(xpOpacityAnim, {
        toValue: 1,
        duration: FIRST_XP_CELEBRATION.XP_NUMBER_FADE_IN,
        useNativeDriver: true,
      }),
      Animated.sequence([
        Animated.timing(xpScaleAnim, {
          toValue: 1.1,
          duration: 150,
          useNativeDriver: true,
        }),
        Animated.timing(xpScaleAnim, {
          toValue: 1.0,
          duration: 150,
          useNativeDriver: true,
        }),
      ]),
    ]).start();

    // Sequence 2: Progress bar fill (300-800ms)
    setTimeout(() => {
      Animated.timing(progressAnim, {
        toValue: levelProgress,
        duration: FIRST_XP_CELEBRATION.PROGRESS_BAR_FILL,
        useNativeDriver: false,
      }).start();
    }, 300);

    // Sequence 3: Message fade in (800-1200ms)
    setTimeout(() => {
      Animated.timing(messageOpacityAnim, {
        toValue: 1,
        duration: FIRST_XP_CELEBRATION.MESSAGE_FADE_IN,
        useNativeDriver: true,
      }).start();
    }, 800);

    // Sequence 4: Badge unlock (1200-1800ms)
    if (badgeUnlocked) {
      setTimeout(() => {
        Animated.timing(badgeOpacityAnim, {
          toValue: 1,
          duration: FIRST_XP_CELEBRATION.BADGE_UNLOCK,
          useNativeDriver: true,
        }).start();
      }, 1200);
    }

    // Sequence 5: Settle to static (1800-2000ms)
    setTimeout(() => {
      setIsVisible(false);
      onComplete?.();
    }, FIRST_XP_CELEBRATION.TOTAL);
  }, []);

  if (!isVisible) return null;

  return (
    <View style={styles.container}>
      <Animated.View
        style={[
          styles.xpContainer,
          {
            opacity: xpOpacityAnim,
            transform: [{ scale: xpScaleAnim }],
          },
        ]}
      >
        <HXText variant="h1" style={[styles.xpAmount, { color: XP.PRIMARY }]}>
          {xpAmount}
        </HXText>
        <HXText variant="caption" color="secondary">
          XP Earned
        </HXText>
      </Animated.View>

      <View style={styles.progressContainer}>
        <View style={styles.progressTrack}>
          <Animated.View
            style={[
              styles.progressFill,
              {
                width: progressAnim.interpolate({
                  inputRange: [0, 1],
                  outputRange: ['0%', '100%'],
                }),
                backgroundColor: XP.PRIMARY,
              },
            ]}
          />
        </View>
      </View>

      <Animated.View
        style={[
          styles.messageContainer,
          { opacity: messageOpacityAnim },
        ]}
      >
        <HXText variant="h3" style={styles.message}>
          First Task Complete!
        </HXText>
      </Animated.View>

      {badgeUnlocked && (
        <Animated.View
          style={[
            styles.badgeContainer,
            { opacity: badgeOpacityAnim },
          ]}
        >
          <View style={styles.badge}>
            <HXText variant="h2">🏆</HXText>
          </View>
          <HXText variant="caption" color="secondary">
            Badge Unlocked
          </HXText>
        </Animated.View>
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    backgroundColor: 'rgba(255, 255, 255, 0.95)',
    justifyContent: 'center',
    alignItems: 'center',
    zIndex: 1000,
  },
  xpContainer: {
    alignItems: 'center',
    marginBottom: SPACING[6],
  },
  xpAmount: {
    fontSize: 64,
    fontWeight: 'bold',
    marginBottom: SPACING[2],
  },
  progressContainer: {
    width: '80%',
    marginBottom: SPACING[6],
  },
  progressTrack: {
    height: 8,
    backgroundColor: NEUTRAL.BACKGROUND_TERTIARY,
    borderRadius: 4,
    overflow: 'hidden',
  },
  progressFill: {
    height: '100%',
    borderRadius: 4,
  },
  messageContainer: {
    marginBottom: SPACING[4],
  },
  message: {
    textAlign: 'center',
    color: XP.PRIMARY,
  },
  badgeContainer: {
    alignItems: 'center',
  },
  badge: {
    width: 80,
    height: 80,
    borderRadius: 40,
    backgroundColor: XP.BACKGROUND,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: SPACING[2],
  },
});

export default FirstXPCelebration;
