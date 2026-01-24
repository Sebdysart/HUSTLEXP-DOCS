/**
 * TaskCard Component v2.0.0
 *
 * SPEC: specs/03-frontend/COMPONENT_LIBRARY.md §7
 * AUTHORITY: STITCH HTML specifications (Apple HIG)
 *
 * Task card for feed display with poster info, pricing, and eligibility.
 */

import React from 'react';
import { View, Text, TouchableOpacity, StyleSheet } from 'react-native';
import { Avatar } from './Avatar';
import { Badge } from './Badge';

// ═══════════════════════════════════════════════════════════════════════════
// AUTHORITATIVE TOKENS (from COLOR_AUTHORITY_RESOLUTION.md)
// ═══════════════════════════════════════════════════════════════════════════

const COLORS = {
  background: '#000000',
  elevated: '#1C1C1E',
  glass: {
    surface: 'rgba(28, 28, 30, 0.6)',
    border: 'rgba(255, 255, 255, 0.1)',
  },
  text: {
    primary: '#FFFFFF',
    secondary: '#E5E5EA',
    muted: '#8E8E93',
  },
  brand: {
    primary: '#1FAD7E',
  },
  apple: {
    orange: '#FF9500',
    red: '#FF3B30',
  },
};

const SPACING = {
  3: 12,
  4: 16,
};

const RADIUS = {
  '2xl': 24,
};

// ═══════════════════════════════════════════════════════════════════════════
// TASKCARD COMPONENT
// ═══════════════════════════════════════════════════════════════════════════

/**
 * @typedef {Object} TaskSummary
 * @property {string} id
 * @property {string} title
 * @property {string} category
 * @property {number} price_cents
 * @property {'STANDARD'|'LIVE'} mode
 * @property {string} deadline_at
 * @property {Object} poster
 * @property {string} poster.full_name
 * @property {string|null} poster.avatar_url
 * @property {1|2|3|4} poster.trust_tier
 */

/**
 * @typedef {Object} TaskCardProps
 * @property {TaskSummary} task - Task data
 * @property {() => void} onPress - Press handler
 * @property {boolean} [showDistance=false] - Show distance
 * @property {number} [distance] - Distance in miles
 * @property {boolean} [showEligibility=false] - Show eligibility blockers
 * @property {boolean} [isEligible=true] - User is eligible
 * @property {string} [eligibilityReason] - Why not eligible
 * @property {'default'|'compact'} [variant='default'] - Card style
 */

/**
 * Task card for feed display
 *
 * @param {TaskCardProps} props
 */
export function TaskCard({
  task,
  onPress,
  showDistance = false,
  distance,
  showEligibility = false,
  isEligible = true,
  eligibilityReason,
  variant = 'default',
}) {
  // Format price from cents to dollars
  const formatPrice = (cents) => {
    return `$${(cents / 100).toFixed(2)}`;
  };

  // Format deadline
  const formatDeadline = (dateString) => {
    const deadline = new Date(dateString);
    const now = new Date();
    const diffMs = deadline - now;
    const diffHours = Math.floor(diffMs / (1000 * 60 * 60));

    if (diffHours < 1) return 'Soon';
    if (diffHours < 24) return `${diffHours}h`;
    return `${Math.floor(diffHours / 24)}d`;
  };

  const isLive = task.mode === 'LIVE';

  return (
    <TouchableOpacity
      style={[styles.container, variant === 'compact' && styles.containerCompact]}
      onPress={onPress}
      activeOpacity={0.7}
    >
      {/* Live Mode Banner */}
      {isLive && (
        <View style={styles.liveBanner}>
          <Badge label="LIVE" variant="live" size="sm" />
        </View>
      )}

      {/* Header: Poster Info */}
      <View style={styles.header}>
        <Avatar
          source={task.poster.avatar_url}
          name={task.poster.full_name}
          size="sm"
          trustTier={task.poster.trust_tier}
        />
        <View style={styles.posterInfo}>
          <Text style={styles.posterName} numberOfLines={1}>
            {task.poster.full_name}
          </Text>
          <Text style={styles.trustTier}>
            Tier {task.poster.trust_tier}
          </Text>
        </View>
      </View>

      {/* Content */}
      <View style={styles.content}>
        <Text style={styles.title} numberOfLines={2}>
          {task.title}
        </Text>

        <View style={styles.metaRow}>
          <Text style={styles.category}>{task.category}</Text>
          {showDistance && distance !== undefined && (
            <Text style={styles.distance}> • {distance.toFixed(1)} mi</Text>
          )}
        </View>
      </View>

      {/* Footer: Price & Deadline */}
      <View style={styles.footer}>
        <Text style={styles.price}>{formatPrice(task.price_cents)}</Text>
        <Text style={styles.deadline}>
          Deadline: {formatDeadline(task.deadline_at)}
        </Text>
      </View>

      {/* Eligibility Blocker */}
      {showEligibility && !isEligible && (
        <View style={styles.eligibilityBanner}>
          <Text style={styles.eligibilityIcon}>⚠️</Text>
          <Text style={styles.eligibilityText}>
            {eligibilityReason || 'Not eligible'}
          </Text>
        </View>
      )}
    </TouchableOpacity>
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// STYLES
// ═══════════════════════════════════════════════════════════════════════════

const styles = StyleSheet.create({
  container: {
    backgroundColor: COLORS.glass.surface,
    borderRadius: RADIUS['2xl'],
    borderWidth: 1,
    borderColor: COLORS.glass.border,
    padding: SPACING[4],
    marginBottom: SPACING[3],
  },
  containerCompact: {
    padding: SPACING[3],
  },
  liveBanner: {
    marginBottom: SPACING[3],
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: SPACING[3],
  },
  posterInfo: {
    marginLeft: SPACING[3],
    flex: 1,
  },
  posterName: {
    color: COLORS.text.primary,
    fontSize: 14,
    fontWeight: '600',
  },
  trustTier: {
    color: COLORS.text.muted,
    fontSize: 12,
  },
  content: {
    marginBottom: SPACING[3],
  },
  title: {
    color: COLORS.text.primary,
    fontSize: 18,
    fontWeight: '600',
    lineHeight: 24,
    marginBottom: 4,
  },
  metaRow: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  category: {
    color: COLORS.text.secondary,
    fontSize: 14,
  },
  distance: {
    color: COLORS.text.muted,
    fontSize: 14,
  },
  footer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  price: {
    color: COLORS.brand.primary,
    fontSize: 20,
    fontWeight: '700',
  },
  deadline: {
    color: COLORS.text.muted,
    fontSize: 14,
  },
  eligibilityBanner: {
    flexDirection: 'row',
    alignItems: 'center',
    marginTop: SPACING[3],
    paddingTop: SPACING[3],
    borderTopWidth: 1,
    borderTopColor: COLORS.glass.border,
  },
  eligibilityIcon: {
    fontSize: 14,
    marginRight: 6,
  },
  eligibilityText: {
    color: COLORS.apple.orange,
    fontSize: 12,
    fontWeight: '500',
  },
});

export default TaskCard;
