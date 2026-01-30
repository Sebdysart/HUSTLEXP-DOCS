/**
 * Avatar Component v2.0.0
 *
 * SPEC: specs/03-frontend/COMPONENT_LIBRARY.md §5
 * AUTHORITY: STITCH HTML specifications (Apple HIG)
 *
 * Displays user avatar with fallback initials and optional trust tier badge.
 */

import React, { useState } from 'react';
import { View, Image, Text, StyleSheet } from 'react-native';

// ═══════════════════════════════════════════════════════════════════════════
// AUTHORITATIVE TOKENS (from COLOR_AUTHORITY_RESOLUTION.md)
// ═══════════════════════════════════════════════════════════════════════════

const COLORS = {
  background: {
    elevated: '#1C1C1E',
  },
  text: {
    primary: '#FFFFFF',
  },
  tier: {
    1: '#71717A',  // Zinc 500 (Rookie)
    2: '#007AFF',  // Apple Blue (Verified)
    3: '#FF9500',  // Apple Orange (Trusted)
    4: '#FFD700',  // Gold (Elite)
  },
};

const SIZES = {
  sm: { diameter: 32, fontSize: 12, badgeSize: 8 },
  md: { diameter: 48, fontSize: 16, badgeSize: 12 },
  lg: { diameter: 64, fontSize: 20, badgeSize: 16 },
  xl: { diameter: 96, fontSize: 28, badgeSize: 24 },
};

// ═══════════════════════════════════════════════════════════════════════════
// AVATAR COMPONENT
// ═══════════════════════════════════════════════════════════════════════════

/**
 * @typedef {Object} AvatarProps
 * @property {string|null} [source] - Image URL
 * @property {string} name - User name (for fallback initials)
 * @property {'sm'|'md'|'lg'|'xl'} [size='md'] - Avatar size
 * @property {1|2|3|4} [trustTier] - Show trust tier badge
 * @property {boolean} [showVerified=false] - Show verified checkmark
 */

/**
 * Avatar with fallback initials and trust tier badge
 *
 * @param {AvatarProps} props
 */
export function Avatar({
  source,
  name,
  size = 'md',
  trustTier,
  showVerified = false,
}) {
  const [imageError, setImageError] = useState(false);
  const sizeConfig = SIZES[size];

  // Generate initials from name
  const getInitials = (fullName) => {
    if (!fullName) return '?';
    const parts = fullName.trim().split(' ');
    if (parts.length === 1) {
      return parts[0].charAt(0).toUpperCase();
    }
    return (parts[0].charAt(0) + parts[parts.length - 1].charAt(0)).toUpperCase();
  };

  const showImage = source && !imageError;
  const initials = getInitials(name);

  const containerStyle = {
    width: sizeConfig.diameter,
    height: sizeConfig.diameter,
    borderRadius: sizeConfig.diameter / 2,
  };

  return (
    <View style={[styles.container, containerStyle]}>
      {showImage ? (
        <Image
          source={{ uri: source }}
          style={[styles.image, containerStyle]}
          onError={() => setImageError(true)}
        />
      ) : (
        <View style={[styles.fallback, containerStyle]}>
          <Text style={[styles.initials, { fontSize: sizeConfig.fontSize }]}>
            {initials}
          </Text>
        </View>
      )}

      {/* Trust Tier Badge */}
      {trustTier && (
        <View
          style={[
            styles.tierBadge,
            {
              width: sizeConfig.badgeSize,
              height: sizeConfig.badgeSize,
              borderRadius: sizeConfig.badgeSize / 2,
              backgroundColor: COLORS.tier[trustTier],
            },
          ]}
        />
      )}

      {/* Verified Checkmark */}
      {showVerified && (
        <View style={[styles.verifiedBadge, { right: -2, bottom: -2 }]}>
          <Text style={styles.verifiedIcon}>✓</Text>
        </View>
      )}
    </View>
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// STYLES
// ═══════════════════════════════════════════════════════════════════════════

const styles = StyleSheet.create({
  container: {
    position: 'relative',
  },
  image: {
    resizeMode: 'cover',
  },
  fallback: {
    backgroundColor: COLORS.background.elevated,
    justifyContent: 'center',
    alignItems: 'center',
  },
  initials: {
    color: COLORS.text.primary,
    fontWeight: '600',
  },
  tierBadge: {
    position: 'absolute',
    right: 0,
    bottom: 0,
    borderWidth: 2,
    borderColor: '#000000',
  },
  verifiedBadge: {
    position: 'absolute',
    width: 16,
    height: 16,
    borderRadius: 8,
    backgroundColor: '#007AFF',
    justifyContent: 'center',
    alignItems: 'center',
  },
  verifiedIcon: {
    color: '#FFFFFF',
    fontSize: 10,
    fontWeight: '700',
  },
});

export default Avatar;
