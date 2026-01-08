/**
 * ProfileScreen - XP progress, badges, stats
 * 
 * SPEC: UI_SPEC.md §6 + §4 Badge System
 * - XP Colors: Allowed (XP displayed)
 * - Badges: Never scale beyond 1.0, no pulse, no mount animations
 * - Badge glow: Only obsidian tier, max 12% opacity
 */

import React from 'react';
import { View, StyleSheet, SafeAreaView, ScrollView } from 'react-native';
import { HXText } from '../components/Text';
import { Card } from '../components/Card';
import { COLORS, XP, BADGE, GRAY } from '../constants/colors';
import { SPACING, RADIUS } from '../constants/spacing';

// Badge component following BADGE RENDER LOCK rules
function BadgeDisplay({ name, tier, earned }) {
  const materials = {
    1: BADGE.steel,
    2: BADGE.alloy,
    3: BADGE.gold,
    4: BADGE.obsidian,
  };
  const material = materials[tier] || materials[1];
  
  return (
    <View style={styles.badge}>
      <View style={[
        styles.badgeIcon,
        { 
          backgroundColor: material.start,
          opacity: earned ? 1 : 0.3,
        },
        // Glow only for obsidian tier, max 12% opacity
        tier === 4 && earned && styles.obsidianGlow,
      ]}>
        {/* Badge icon placeholder - no animations on mount */}
      </View>
      <HXText variant="caption" color={earned ? 'primary' : 'tertiary'}>
        {name}
      </HXText>
    </View>
  );
}

export function ProfileScreen() {
  return (
    <SafeAreaView style={styles.container}>
      <ScrollView contentContainerStyle={styles.content}>
        <HXText variant="h2">Profile</HXText>
        
        {/* XP Progress - XP colors allowed */}
        <Card variant="elevated" style={styles.xpSection}>
          <HXText variant="caption" color="secondary">LEVEL PROGRESS</HXText>
          <View style={styles.levelRow}>
            <HXText variant="h3" style={{ color: XP.primary }}>Level 1</HXText>
            <HXText variant="bodySmall" color="secondary">Rookie</HXText>
          </View>
          
          {/* Progress bar - XP secondary color allowed */}
          <View style={styles.progressContainer}>
            <View style={styles.progressBg}>
              <View style={[styles.progressFill, { width: '0%' }]} />
            </View>
            <HXText variant="caption" color="secondary">0 / 100 XP</HXText>
          </View>
        </Card>

        {/* Badges Section */}
        <HXText variant="label" color="secondary" style={styles.sectionTitle}>
          BADGES
        </HXText>
        <Card variant="outlined" style={styles.badgesCard}>
          <View style={styles.badgesGrid}>
            <BadgeDisplay name="First Task" tier={1} earned={false} />
            <BadgeDisplay name="Week Streak" tier={1} earned={false} />
            <BadgeDisplay name="Pro Hustler" tier={2} earned={false} />
            <BadgeDisplay name="Elite" tier={3} earned={false} />
          </View>
        </Card>

        {/* Stats */}
        <HXText variant="label" color="secondary" style={styles.sectionTitle}>
          STATISTICS
        </HXText>
        <Card variant="outlined" style={styles.statsCard}>
          <View style={styles.statRow}>
            <HXText variant="body">Tasks Completed</HXText>
            <HXText variant="body" weight="semibold">0</HXText>
          </View>
          <View style={styles.statRow}>
            <HXText variant="body">Current Streak</HXText>
            <HXText variant="body" weight="semibold">0 days</HXText>
          </View>
          <View style={styles.statRow}>
            <HXText variant="body">Trust Tier</HXText>
            <HXText variant="body" weight="semibold">1 (Verified)</HXText>
          </View>
        </Card>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: COLORS.background,
  },
  content: {
    padding: SPACING[4],
  },
  xpSection: {
    marginTop: SPACING[4],
    padding: SPACING[4],
  },
  levelRow: {
    flexDirection: 'row',
    alignItems: 'baseline',
    gap: SPACING[2],
    marginTop: SPACING[2],
  },
  progressContainer: {
    marginTop: SPACING[4],
  },
  progressBg: {
    height: 8,
    backgroundColor: GRAY[200],
    borderRadius: RADIUS.full,
    overflow: 'hidden',
    marginBottom: SPACING[2],
  },
  progressFill: {
    height: '100%',
    backgroundColor: XP.primary,
    borderRadius: RADIUS.full,
  },
  sectionTitle: {
    marginTop: SPACING[6],
    marginBottom: SPACING[3],
    textTransform: 'uppercase',
    letterSpacing: 1,
  },
  badgesCard: {
    padding: SPACING[4],
  },
  badgesGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: SPACING[4],
  },
  badge: {
    alignItems: 'center',
    width: 70,
  },
  badgeIcon: {
    width: 48,
    height: 48,
    borderRadius: RADIUS.full,
    marginBottom: SPACING[2],
    // Scale is 1.0 - BADGE RENDER LOCK enforced
  },
  obsidianGlow: {
    // Max 12% opacity glow per spec
    shadowColor: XP.primary,
    shadowOffset: { width: 0, height: 0 },
    shadowOpacity: 0.12,
    shadowRadius: 8,
  },
  statsCard: {
    padding: SPACING[4],
  },
  statRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    paddingVertical: SPACING[2],
    borderBottomWidth: 1,
    borderBottomColor: COLORS.border,
  },
});

export default ProfileScreen;
