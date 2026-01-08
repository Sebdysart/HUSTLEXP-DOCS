/**
 * HomeScreen - Dashboard with XP display
 * 
 * SPEC: UI_SPEC.md §6 - Screen-specific rules
 * - Celebration: Context-dependent
 * - XP Colors: Allowed (XP displayed here)
 */

import React from 'react';
import { View, StyleSheet, SafeAreaView } from 'react-native';
import { HXText } from '../components/Text';
import { Card } from '../components/Card';
import { COLORS, XP } from '../constants/colors';
import { SPACING } from '../constants/spacing';

export function HomeScreen() {
  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.content}>
        <HXText variant="h2">Dashboard</HXText>
        <HXText variant="bodySmall" color="secondary" style={styles.subtitle}>
          Welcome back
        </HXText>

        {/* XP Display - XP colors allowed here per UI_SPEC §6 */}
        <Card variant="elevated" style={styles.xpCard}>
          <HXText variant="caption" color="secondary">TOTAL XP</HXText>
          <HXText variant="h1" style={{ color: XP.primary }}>0</HXText>
          <HXText variant="bodySmall" color="secondary">Level 1 • Rookie</HXText>
        </Card>

        <Card variant="outlined" style={styles.statsCard}>
          <HXText variant="label">Quick Stats</HXText>
          <View style={styles.statsRow}>
            <View style={styles.stat}>
              <HXText variant="h3">0</HXText>
              <HXText variant="caption" color="secondary">Tasks</HXText>
            </View>
            <View style={styles.stat}>
              <HXText variant="h3">0</HXText>
              <HXText variant="caption" color="secondary">Streak</HXText>
            </View>
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
