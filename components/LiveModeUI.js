/**
 * LiveModeUI - Live Mode visual components (UI_SPEC §13)
 * 
 * LIVE MODE INDICATORS:
 * - LIVE_INDICATOR: Red-500 - Live badge, active broadcast
 * - STANDARD_INDICATOR: Gray-500 - Standard mode, neutral
 * - LIVE_ACTIVE: Green-500 - Hustler Live Mode active
 * - LIVE_COOLDOWN: Amber-500 - Hustler in cooldown
 * 
 * FORBIDDEN IN LIVE MODE:
 * - Countdown timers (creates panic)
 * - Urgency copy ("Act now!", "Limited time!", "Hurry!")
 * - Pulsing or flashing animations
 * - Sound effects beyond system default
 * 
 * SPEC: UI_SPEC.md §13
 */

import React from 'react';
import { View, StyleSheet, TouchableOpacity } from 'react-native';
import { HXText } from './Text';
import { Card } from './Card';
import { LIVE_MODE, MONEY, NEUTRAL, GRAY } from '../constants/colors';
import { SPACING } from '../constants/spacing';

/**
 * LiveTaskCard - Live task card display (UI_SPEC §13.2)
 */
export function LiveTaskCard({ 
  taskTitle,
  posterName,
  posterTier,
  amount,
  hustlerReceives,
  distance,
  escrowState,
  onAccept,
}) {
  return (
    <Card variant="elevated" style={styles.liveCard}>
      {/* Live Badge */}
      <View style={styles.liveBadge}>
        <View style={[styles.liveDot, { backgroundColor: LIVE_MODE.INDICATOR }]} />
        <HXText variant="caption" style={{ color: LIVE_MODE.INDICATOR }}>
          LIVE
        </HXText>
      </View>

      {/* Task Info */}
      <HXText variant="h3" style={styles.taskTitle}>
        {taskTitle}
      </HXText>
      <HXText variant="bodySmall" color="secondary" style={styles.posterInfo}>
        {posterName} • {posterTier}
      </HXText>

      {/* Money Breakdown */}
      <View style={styles.moneySection}>
        <HXText variant="body" style={styles.moneyAmount}>
          💰 ${amount.toFixed(2)} (you receive ~${hustlerReceives.toFixed(2)})
        </HXText>
      </View>

      {/* Location */}
      <View style={styles.locationSection}>
        <HXText variant="bodySmall" color="secondary">
          📍 {distance} miles away
        </HXText>
      </View>

      {/* Escrow Status */}
      <View style={styles.escrowSection}>
        <HXText variant="bodySmall" style={{ color: MONEY.POSITIVE }}>
          ✅ Escrow: {escrowState}
        </HXText>
      </View>

      {/* Accept Button */}
      <TouchableOpacity
        style={styles.acceptButton}
        onPress={onAccept}
        activeOpacity={0.7}
      >
        <HXText variant="body" style={styles.acceptButtonText}>
          Accept Task
        </HXText>
      </TouchableOpacity>
    </Card>
  );
}

/**
 * LiveModeToggle - Hustler Live Mode toggle (UI_SPEC §13.3)
 */
export function LiveModeToggle({ 
  isActive,
  isCooldown,
  cooldownMinutes,
  sessionStats,
  onToggle,
}) {
  const statusColor = isActive 
    ? LIVE_MODE.ACTIVE 
    : isCooldown 
    ? LIVE_MODE.COOLDOWN 
    : LIVE_MODE.STANDARD;

  return (
    <Card variant="elevated" style={styles.toggleCard}>
      <HXText variant="h3" style={styles.toggleTitle}>
        LIVE MODE
      </HXText>

      <TouchableOpacity
        style={[
          styles.toggleButton,
          { backgroundColor: isActive ? statusColor : GRAY[200] },
        ]}
        onPress={onToggle}
        disabled={isCooldown}
      >
        <HXText variant="body" style={styles.toggleButtonText}>
          {isActive ? '● ACTIVE' : isCooldown ? `COOLDOWN (${cooldownMinutes}m)` : 'INACTIVE'}
        </HXText>
      </TouchableOpacity>

      {isActive && sessionStats && (
        <View style={styles.sessionStats}>
          <HXText variant="bodySmall" color="secondary">
            🟢 Actively available
          </HXText>
          <HXText variant="bodySmall" color="secondary">
            Session: {sessionStats.duration} min • Tasks: {sessionStats.tasks} • Earned: ${sessionStats.earned.toFixed(2)}
          </HXText>
        </View>
      )}

      {isCooldown && (
        <View style={styles.cooldownInfo}>
          <HXText variant="bodySmall" color="secondary">
            Cooldown: {cooldownMinutes} minutes remaining
          </HXText>
        </View>
      )}
    </Card>
  );
}

/**
 * PosterLiveConfirmation - Poster confirmation when hustler accepts (UI_SPEC §13.4)
 */
export function PosterLiveConfirmation({
  hustlerName,
  hustlerTier,
  tasksCompleted,
  eta,
  distance,
}) {
  return (
    <Card variant="elevated" style={styles.confirmationCard}>
      <View style={styles.confirmationHeader}>
        <View style={[styles.statusIndicator, { backgroundColor: LIVE_MODE.ACTIVE }]} />
        <HXText variant="h3" style={{ color: LIVE_MODE.ACTIVE }}>
          HUSTLER ON THE WAY
        </HXText>
      </View>

      <View style={styles.hustlerInfo}>
        <HXText variant="h2" style={styles.hustlerName}>
          {hustlerName}
        </HXText>
        <HXText variant="bodySmall" color="secondary">
          ⭐ {hustlerTier} • {tasksCompleted} tasks completed
        </HXText>
      </View>

      <View style={styles.etaSection}>
        <HXText variant="body" style={styles.eta}>
          ETA: ~{eta} minutes
        </HXText>
        <HXText variant="bodySmall" color="secondary">
          Distance: {distance}
        </HXText>
      </View>
    </Card>
  );
}

const styles = StyleSheet.create({
  liveCard: {
    padding: SPACING[4],
    marginBottom: SPACING[4],
  },
  liveBadge: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: SPACING[3],
  },
  liveDot: {
    width: 8,
    height: 8,
    borderRadius: 4,
    marginRight: SPACING[2],
  },
  taskTitle: {
    marginBottom: SPACING[2],
  },
  posterInfo: {
    marginBottom: SPACING[3],
  },
  moneySection: {
    marginBottom: SPACING[2],
  },
  moneyAmount: {
    fontWeight: '600',
  },
  locationSection: {
    marginBottom: SPACING[2],
  },
  escrowSection: {
    marginBottom: SPACING[4],
  },
  acceptButton: {
    backgroundColor: LIVE_MODE.INDICATOR,
    paddingVertical: SPACING[4],
    borderRadius: 8,
    alignItems: 'center',
  },
  acceptButtonText: {
    color: NEUTRAL.TEXT_INVERSE,
    fontWeight: '600',
  },
  toggleCard: {
    padding: SPACING[4],
    marginBottom: SPACING[4],
  },
  toggleTitle: {
    marginBottom: SPACING[4],
  },
  toggleButton: {
    paddingVertical: SPACING[4],
    borderRadius: 8,
    alignItems: 'center',
    marginBottom: SPACING[3],
  },
  toggleButtonText: {
    color: NEUTRAL.TEXT_INVERSE,
    fontWeight: '600',
  },
  sessionStats: {
    marginTop: SPACING[3],
  },
  cooldownInfo: {
    marginTop: SPACING[3],
  },
  confirmationCard: {
    padding: SPACING[5],
    alignItems: 'center',
  },
  confirmationHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: SPACING[5],
  },
  statusIndicator: {
    width: 12,
    height: 12,
    borderRadius: 6,
    marginRight: SPACING[2],
  },
  hustlerInfo: {
    alignItems: 'center',
    marginBottom: SPACING[4],
  },
  hustlerName: {
    marginBottom: SPACING[2],
  },
  etaSection: {
    alignItems: 'center',
  },
  eta: {
    fontWeight: '600',
    marginBottom: SPACING[1],
  },
});

export default {
  LiveTaskCard,
  LiveModeToggle,
  PosterLiveConfirmation,
};
