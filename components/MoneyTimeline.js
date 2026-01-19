/**
 * MoneyTimeline - Financial legibility component (UI_SPEC §14)
 * 
 * PURPOSE: Transform HustleXP from a gig app into a financial planning tool
 * 
 * ANSWERS:
 * - What money do I have NOW?
 * - What money is COMING?
 * - What money is BLOCKED?
 * 
 * CATEGORIES:
 * - AVAILABLE NOW: Withdrawable (escrow.state = RELEASED AND transferred)
 * - TODAY: Recent releases (Released in last 24h)
 * - COMING SOON: Earned not released (escrow.state = FUNDED AND task in progress)
 * - BLOCKED: Frozen in dispute (escrow.state = LOCKED_DISPUTE)
 * 
 * FORBIDDEN:
 * - Charts, graphs, gambling visuals
 * - Vague language ("Pending", "Processing", "Soon")
 * - Over-optimism ("Potential earnings", "Could earn", "Up to")
 * 
 * SPEC: UI_SPEC.md §14
 */

import React from 'react';
import { View, StyleSheet, ScrollView } from 'react-native';
import { HXText } from './Text';
import { Card } from './Card';
import { MONEY, NEUTRAL, GRAY } from '../constants/colors';
import { SPACING } from '../constants/spacing';

export function MoneyTimeline({ timelineData }) {
  const {
    availableNow = 0,
    today = [],
    comingSoon = [],
    blocked = [],
  } = timelineData || {};

  return (
    <ScrollView style={styles.container}>
      <View style={styles.content}>
        {/* AVAILABLE NOW */}
        <View style={styles.section}>
          <HXText variant="h3" style={styles.sectionTitle}>
            AVAILABLE NOW
          </HXText>
          <Card variant="elevated" style={styles.availableCard}>
            <HXText variant="h1" style={[styles.amount, { color: MONEY.POSITIVE }]}>
              ${availableNow.toFixed(2)}
            </HXText>
            <HXText variant="bodySmall" color="secondary" style={styles.transferHint}>
              Transfer to bank
            </HXText>
          </Card>
        </View>

        {/* TODAY */}
        {today.length > 0 && (
          <View style={styles.section}>
            <HXText variant="h3" style={styles.sectionTitle}>
              TODAY
            </HXText>
            {today.map((entry, index) => (
              <View key={index} style={styles.timelineEntry}>
                <HXText variant="body" style={[styles.entryAmount, { color: MONEY.POSITIVE }]}>
                  + ${entry.amount.toFixed(2)}
                </HXText>
                <HXText variant="bodySmall" color="secondary">
                  {entry.taskTitle} — Released {entry.releasedAt}
                </HXText>
              </View>
            ))}
          </View>
        )}

        {/* COMING SOON */}
        {comingSoon.length > 0 && (
          <View style={styles.section}>
            <HXText variant="h3" style={styles.sectionTitle}>
              COMING SOON
            </HXText>
            {comingSoon.map((entry, index) => (
              <View key={index} style={styles.timelineEntry}>
                <HXText variant="body" style={[styles.entryAmount, { color: MONEY.NEUTRAL }]}>
                  + ${entry.amount.toFixed(2)}
                </HXText>
                <HXText variant="bodySmall" color="secondary">
                  {entry.taskTitle} — {entry.context}
                </HXText>
              </View>
            ))}
          </View>
        )}

        {/* BLOCKED */}
        {blocked.length > 0 && (
          <View style={styles.section}>
            <HXText variant="h3" style={styles.sectionTitle}>
              BLOCKED
            </HXText>
            {blocked.map((entry, index) => (
              <View key={index} style={styles.timelineEntry}>
                <HXText variant="body" style={[styles.entryAmount, { color: MONEY.LOCKED }]}>
                  ⚠️ ${entry.amount.toFixed(2)}
                </HXText>
                <HXText variant="bodySmall" color="secondary">
                  {entry.taskTitle} — {entry.reason}
                </HXText>
              </View>
            ))}
          </View>
        )}

        {/* Empty state */}
        {today.length === 0 && comingSoon.length === 0 && blocked.length === 0 && (
          <View style={styles.emptyState}>
            <HXText variant="body" color="secondary" style={styles.emptyText}>
              No transactions yet
            </HXText>
          </View>
        )}
      </View>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: NEUTRAL.BACKGROUND,
  },
  content: {
    padding: SPACING[4],
  },
  section: {
    marginBottom: SPACING[6],
  },
  sectionTitle: {
    marginBottom: SPACING[3],
    color: NEUTRAL.TEXT,
  },
  availableCard: {
    padding: SPACING[5],
    alignItems: 'center',
  },
  amount: {
    fontSize: 48,
    fontWeight: 'bold',
    marginBottom: SPACING[2],
  },
  transferHint: {
    marginTop: SPACING[2],
  },
  timelineEntry: {
    paddingVertical: SPACING[3],
    borderBottomWidth: 1,
    borderBottomColor: GRAY[200],
  },
  entryAmount: {
    fontWeight: '600',
    marginBottom: SPACING[1],
  },
  emptyState: {
    paddingVertical: SPACING[8],
    alignItems: 'center',
  },
  emptyText: {
    textAlign: 'center',
  },
});

export default MoneyTimeline;
