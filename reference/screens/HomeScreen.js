/**
 * HomeScreen - Dashboard with XP display
 * 
 * SPEC: UI_SPEC.md §6 - Screen-specific rules
 * - Celebration: Context-dependent
 * - XP Colors: Allowed (XP displayed here)
 * - ONBOARDING_SPEC §13.2: Shows LockedGamificationUI before first RELEASED escrow
 * 
 * RULES:
 * - Posters: Never show gamification (ONB-3)
 * - Workers pre-unlock: Show LockedGamificationUI
 * - Workers post-unlock: Show active gamification
 */

import React, { useState, useEffect } from 'react';
import { View, StyleSheet, SafeAreaView } from 'react-native';
import { HXText } from '../components/Text';
import { Card } from '../components/Card';
import { LockedGamificationUI } from '../components/LockedGamificationUI';
import { COLORS, XP } from '../constants/colors';
import { SPACING } from '../constants/spacing';
import apiClient from '../utils/apiClient';

export function HomeScreen({ userId, userRole }) {
  const [onboardingStatus, setOnboardingStatus] = useState(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    if (userId) {
      loadOnboardingStatus();
    } else {
      setIsLoading(false);
    }
  }, [userId]);

  const loadOnboardingStatus = async () => {
    try {
      const status = await apiClient.getUserOnboardingStatus(userId);
      setOnboardingStatus(status);
    } catch (error) {
      console.error('[HomeScreen] Failed to load onboarding status', error);
      // Default to unlocked if check fails
      setOnboardingStatus({ hasCompletedFirstTask: true });
    } finally {
      setIsLoading(false);
    }
  };

  // Determine if gamification should be shown
  const shouldShowGamification = () => {
    // Posters never see gamification (ONB-3)
    if (userRole === 'poster') {
      return false;
    }

    // Workers/dual users see gamification
    return userRole === 'worker' || userRole === 'dual';
  };

  // Determine if gamification is locked (pre-first RELEASED escrow)
  const isGamificationLocked = () => {
    if (!onboardingStatus) return true; // Default to locked while loading
    return !onboardingStatus.hasCompletedFirstTask;
  };

  if (isLoading) {
    return (
      <SafeAreaView style={styles.container}>
        <View style={styles.content}>
          <HXText variant="body" color="secondary">Loading...</HXText>
        </View>
      </SafeAreaView>
    );
  }

  const showGamification = shouldShowGamification();
  const locked = isGamificationLocked();

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.content}>
        <HXText variant="h2">Dashboard</HXText>
        <HXText variant="bodySmall" color="secondary" style={styles.subtitle}>
          Welcome back
        </HXText>

        {/* Gamification Display */}
        {showGamification ? (
          locked ? (
            // Pre-unlock: Show locked gamification UI (ONBOARDING_SPEC §13.2)
            <LockedGamificationUI />
          ) : (
            // Post-unlock: Show active gamification (XP colors allowed per UI_SPEC §6)
            <Card variant="elevated" style={styles.xpCard}>
              <HXText variant="caption" color="secondary">TOTAL XP</HXText>
              <HXText variant="h1" style={{ color: XP.PRIMARY }}>0</HXText>
              <HXText variant="bodySmall" color="secondary">Level 1 • Rookie</HXText>
            </Card>
          )
        ) : (
          // Poster: No gamification (ONB-3)
          <Card variant="outlined" style={styles.posterCard}>
            <HXText variant="body" color="secondary">
              Your tasks and payments
            </HXText>
          </Card>
        )}

        {/* Stats Card */}
        <Card variant="outlined" style={styles.statsCard}>
          <HXText variant="label">Quick Stats</HXText>
          <View style={styles.statsRow}>
            <View style={styles.stat}>
              <HXText variant="h3">0</HXText>
              <HXText variant="caption" color="secondary">Tasks</HXText>
            </View>
            {showGamification && !locked && (
              <View style={styles.stat}>
                <HXText variant="h3">0</HXText>
                <HXText variant="caption" color="secondary">Streak</HXText>
              </View>
            )}
            <View style={styles.stat}>
              <HXText variant="h3">$0</HXText>
              <HXText variant="caption" color="secondary">Earned</HXText>
            </View>
          </View>
        </Card>
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: COLORS.background,
  },
  content: {
    flex: 1,
    padding: SPACING[4],
  },
  subtitle: {
    marginBottom: SPACING[6],
  },
  xpCard: {
    alignItems: 'center',
    paddingVertical: SPACING[6],
    marginBottom: SPACING[4],
  },
  posterCard: {
    padding: SPACING[4],
    marginBottom: SPACING[4],
    alignItems: 'center',
  },
  statsCard: {
    padding: SPACING[4],
  },
  statsRow: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    marginTop: SPACING[4],
  },
  stat: {
    alignItems: 'center',
  },
});

export default HomeScreen;
