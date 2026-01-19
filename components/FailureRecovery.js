/**
 * FailureRecovery - Graceful failure UX component (UI_SPEC §15)
 * 
 * PRINCIPLE: Every negative outcome has:
 * 1. Clear explanation of what happened
 * 2. Concrete impact (if any)
 * 3. Specific next step
 * 4. NO shame language
 * 
 * FORBIDDEN COPY:
 * - Shame language ("You failed", "Your fault", "Mistake")
 * - Punitive language ("Penalty", "Punished", "Strike", "Warning")
 * - Vague impact ("Consequences", "Action taken", "Noted")
 * - Passive aggressive ("Unfortunately", "Regrettably", "We had to")
 * 
 * REQUIRED ELEMENTS:
 * - WHAT HAPPENED (always explain)
 * - IMPACT (always specify)
 * - WHAT YOU CAN DO (always provide action)
 * - Recovery path (always show hope)
 * 
 * SPEC: UI_SPEC.md §15
 */

import React from 'react';
import { View, StyleSheet, ScrollView } from 'react-native';
import { HXText } from './Text';
import { Button } from './Button';
import { Card } from './Card';
import { STATUS, NEUTRAL, GRAY } from '../constants/colors';
import { SPACING } from '../constants/spacing';

export function FailureRecovery({ 
  title,
  whatHappened,
  impact = [],
  actions = [],
  recoveryContext,
  variant = 'neutral', // 'neutral' | 'task_failed' | 'trust_tier_change' | 'dispute_lost'
}) {
  return (
    <ScrollView style={styles.container}>
      <View style={styles.content}>
        {/* Header */}
        <View style={styles.header}>
          <HXText variant="h2" style={styles.title}>
            {title}
          </HXText>
        </View>

        {/* WHAT HAPPENED */}
        <Card variant="outlined" style={styles.section}>
          <HXText variant="label" style={styles.sectionLabel}>
            WHAT HAPPENED
          </HXText>
          <HXText variant="body" style={styles.sectionContent}>
            {whatHappened}
          </HXText>
        </Card>

        {/* IMPACT */}
        {impact.length > 0 && (
          <Card variant="outlined" style={styles.section}>
            <HXText variant="label" style={styles.sectionLabel}>
              IMPACT
            </HXText>
            {impact.map((item, index) => (
              <View key={index} style={styles.impactItem}>
                <HXText variant="body" color="secondary">
                  • {item}
                </HXText>
              </View>
            ))}
          </Card>
        )}

        {/* WHAT YOU CAN DO */}
        {actions.length > 0 && (
          <View style={styles.actionsSection}>
            <HXText variant="label" style={styles.sectionLabel}>
              WHAT YOU CAN DO
            </HXText>
            {actions.map((action, index) => (
              <Button
                key={index}
                title={action.label}
                onPress={action.onPress}
                variant={index === 0 ? 'primary' : 'secondary'}
                size="lg"
                style={styles.actionButton}
              />
            ))}
          </View>
        )}

        {/* Recovery Context */}
        {recoveryContext && (
          <View style={styles.recoverySection}>
            <HXText variant="body" color="secondary" style={styles.recoveryText}>
              {recoveryContext}
            </HXText>
          </View>
        )}
      </View>
    </ScrollView>
  );
}

// Pre-configured failure screens

export function TaskFailedScreen({ taskTitle, onDispute, onAccept }) {
  return (
    <FailureRecovery
      title="This task didn't complete successfully"
      whatHappened="The poster reported the task wasn't completed as described."
      impact={[
        'No payment for this task',
        'Trust score: No change (first occurrence)',
      ]}
      actions={[
        { label: 'Dispute This Decision', onPress: onDispute },
        { label: 'Accept and Move On', onPress: onAccept },
      ]}
      recoveryContext="Your next completed task restores normal standing."
    />
  );
}

export function TrustTierChangeScreen({ fromTier, toTier, reason, recoveryPath }) {
  return (
    <FailureRecovery
      title="Your trust tier has changed"
      whatHappened={`${fromTier} → ${toTier}`}
      impact={[
        reason,
        'Some task types may be less visible to you',
        'Your earnings potential is unchanged',
      ]}
      actions={[
        { label: 'Got It', onPress: () => {} },
      ]}
      recoveryContext={recoveryPath}
    />
  );
}

export function DisputeLostScreen({ amount, reason, onViewDetails }) {
  return (
    <FailureRecovery
      title="Dispute resolved"
      whatHappened="DECISION: In favor of poster"
      impact={[
        `Payment of $${amount.toFixed(2)} refunded to poster`,
        'This counts as an incomplete task',
      ]}
      actions={[
        { label: 'View Details', onPress: onViewDetails },
        { label: 'Got It', onPress: () => {} },
      ]}
      recoveryContext="This is one outcome. Your overall record still shows 47 successful completions."
    />
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
  header: {
    marginBottom: SPACING[6],
  },
  title: {
    textAlign: 'center',
  },
  section: {
    padding: SPACING[4],
    marginBottom: SPACING[4],
  },
  sectionLabel: {
    marginBottom: SPACING[3],
    color: NEUTRAL.TEXT,
  },
  sectionContent: {
    lineHeight: 24,
  },
  impactItem: {
    marginBottom: SPACING[2],
  },
  actionsSection: {
    marginTop: SPACING[4],
    marginBottom: SPACING[4],
  },
  actionButton: {
    marginBottom: SPACING[3],
  },
  recoverySection: {
    marginTop: SPACING[4],
    padding: SPACING[4],
    backgroundColor: GRAY[50],
    borderRadius: 8,
  },
  recoveryText: {
    textAlign: 'center',
    lineHeight: 24,
  },
});

export default FailureRecovery;
