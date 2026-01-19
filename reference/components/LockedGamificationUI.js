/**
 * LockedGamificationUI - Pre-unlock gamification display (ONBOARDING_SPEC §13.2, UI_SPEC §12.2)
 * 
 * DISPLAYED WHEN:
 * - User role = 'worker' OR 'dual'
 * - xp_first_celebration_shown_at IS NULL (no first RELEASED escrow yet)
 * 
 * VISUAL STATE:
 * - XP counter: Visible, "0 XP", static
 * - Level indicator: "Level 1 • Locked"
 * - Streak counter: "Inactive"
 * - Badges: Greyed silhouettes
 * - Progress bar: Empty, no fill
 * - "Unlocks after first task" label: Visible
 * 
 * FORBIDDEN:
 * - Animated XP gain
 * - Progress bar movement
 * - Numbers increasing
 * - Celebrations
 * - Unlocked badge visuals
 * - Active streak fire/glow
 * 
 * SPEC: ONBOARDING_SPEC.md §13.2, UI_SPEC.md §12.2
 */

import React from 'react';
import { View, StyleSheet } from 'react-native';
import { HXText } from './Text';
import { Card } from './Card';
import { XP, NEUTRAL, GRAY } from '../constants/colors';
import { SPACING } from '../constants/spacing';

export function LockedGamificationUI() {
  return (
    <View style={styles.container}>
      {/* XP Display - Static, locked */}
      <Card variant="elevated" style={styles.xpCard}>
        <HXText variant="caption" color="secondary">TOTAL XP</HXText>
        <HXText 
          variant="h1" 
          style={[styles.xpAmount, { color: GRAY[400] }]} // Gray, not XP color
        >
          0
        </HXText>
        <HXText variant="bodySmall" color="secondary">
          Level 1 • Locked
        </HXText>
      </Card>

      {/* Progress Bar - Empty, no fill */}
      <View style={styles.progressContainer}>
        <View style={styles.progressTrack}>
          {/* No fill - empty bar */}
        </View>
        <HXText variant="caption" color="secondary" style={styles.unlockLabel}>
          Unlocks after first task
        </HXText>
      </View>

      {/* Streak Counter - Inactive */}
      <View style={styles.streakContainer}>
        <HXText variant="body" color="secondary">STREAK</HXText>
        <HXText variant="h3" style={{ color: GRAY[400] }}>Inactive</HXText>
      </View>

      {/* Badges - Greyed silhouettes */}
      <View style={styles.badgesContainer}>
        <HXText variant="body" color="secondary" style={styles.badgesLabel}>
          BADGES
        </HXText>
        <View style={styles.badgesGrid}>
          {[1, 2, 3, 4].map((i) => (
            <View key={i} style={styles.badgeSilhouette}>
              <HXText variant="h2" style={{ color: GRAY[300] }}>🔒</HXText>
            </View>
          ))}
        </View>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    padding: SPACING[4],
  },
  xpCard: {
    alignItems: 'center',
    paddingVertical: SPACING[6],
    marginBottom: SPACING[4],
  },
  xpAmount: {
    fontSize: 48,
    fontWeight: 'bold',
    marginVertical: SPACING[2],
  },
  progressContainer: {
    marginBottom: SPACING[6],
  },
  progressTrack: {
    height: 8,
    backgroundColor: NEUTRAL.BACKGROUND_TERTIARY,
    borderRadius: 4,
    marginBottom: SPACING[2],
  },
  unlockLabel: {
    textAlign: 'center',
  },
  streakContainer: {
    alignItems: 'center',
    marginBottom: SPACING[6],
    paddingVertical: SPACING[4],
    borderTopWidth: 1,
    borderBottomWidth: 1,
    borderColor: GRAY[200],
  },
  badgesContainer: {
    marginTop: SPACING[4],
  },
  badgesLabel: {
    marginBottom: SPACING[3],
    textAlign: 'center',
  },
  badgesGrid: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    flexWrap: 'wrap',
  },
  badgeSilhouette: {
    width: 60,
    height: 60,
    borderRadius: 30,
    backgroundColor: GRAY[100],
    justifyContent: 'center',
    alignItems: 'center',
    margin: SPACING[2],
    opacity: 0.5,
  },
});

export default LockedGamificationUI;
