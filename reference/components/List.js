/**
 * List Component v2.0.0
 *
 * SPEC: specs/03-frontend/COMPONENT_LIBRARY.md §11
 * AUTHORITY: STITCH HTML specifications (Apple HIG)
 *
 * Optimized FlatList wrapper with loading, empty, and error states.
 */

import React from 'react';
import {
  View,
  Text,
  FlatList,
  ActivityIndicator,
  StyleSheet,
  RefreshControl,
} from 'react-native';

// ═══════════════════════════════════════════════════════════════════════════
// AUTHORITATIVE TOKENS (from COLOR_AUTHORITY_RESOLUTION.md)
// ═══════════════════════════════════════════════════════════════════════════

const COLORS = {
  background: '#000000',
  text: {
    primary: '#FFFFFF',
    secondary: '#E5E5EA',
    muted: '#8E8E93',
  },
  brand: {
    primary: '#1FAD7E',
  },
  apple: {
    gray: '#8E8E93',
  },
};

const SPACING = {
  2: 8,
  3: 12,
  4: 16,
  6: 24,
  8: 32,
};

// ═══════════════════════════════════════════════════════════════════════════
// EMPTY STATE COMPONENT
// ═══════════════════════════════════════════════════════════════════════════

function EmptyState({ message, icon }) {
  return (
    <View style={styles.emptyContainer}>
      {icon && <Text style={styles.emptyIcon}>{icon}</Text>}
      <Text style={styles.emptyMessage}>{message}</Text>
    </View>
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// LOADING FOOTER COMPONENT
// ═══════════════════════════════════════════════════════════════════════════

function LoadingFooter({ isLoading }) {
  if (!isLoading) return null;

  return (
    <View style={styles.footerLoader}>
      <ActivityIndicator size="small" color={COLORS.brand.primary} />
    </View>
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// LIST COMPONENT
// ═══════════════════════════════════════════════════════════════════════════

/**
 * @typedef {Object} ListProps
 * @property {Array} data - List data
 * @property {(item: any) => React.ReactNode} renderItem - Render function
 * @property {(item: any) => string} keyExtractor - Key extractor
 * @property {boolean} [isLoading=false] - Initial loading state
 * @property {boolean} [isLoadingMore=false] - Loading more items
 * @property {boolean} [isRefreshing=false] - Pull-to-refresh active
 * @property {() => void} [onRefresh] - Pull-to-refresh handler
 * @property {() => void} [onEndReached] - End reached handler
 * @property {number} [onEndReachedThreshold=0.5] - End threshold
 * @property {string} [emptyMessage='No items'] - Empty state message
 * @property {string} [emptyIcon] - Empty state icon
 * @property {React.ReactNode} [ListHeaderComponent] - Header component
 * @property {number} [itemSeparatorHeight=12] - Separator height
 * @property {Object} [contentContainerStyle] - Content container style
 */

/**
 * Optimized FlatList with built-in states
 *
 * @param {ListProps} props
 */
export function List({
  data,
  renderItem,
  keyExtractor,
  isLoading = false,
  isLoadingMore = false,
  isRefreshing = false,
  onRefresh,
  onEndReached,
  onEndReachedThreshold = 0.5,
  emptyMessage = 'No items',
  emptyIcon,
  ListHeaderComponent,
  itemSeparatorHeight = 12,
  contentContainerStyle,
}) {
  // Initial loading state
  if (isLoading && (!data || data.length === 0)) {
    return (
      <View style={styles.loadingContainer}>
        <ActivityIndicator size="large" color={COLORS.brand.primary} />
      </View>
    );
  }

  // Empty state
  const ListEmptyComponent = () => (
    <EmptyState message={emptyMessage} icon={emptyIcon} />
  );

  // Item separator
  const ItemSeparatorComponent = () => (
    <View style={{ height: itemSeparatorHeight }} />
  );

  // Footer with loading indicator
  const ListFooterComponent = () => (
    <LoadingFooter isLoading={isLoadingMore} />
  );

  return (
    <FlatList
      data={data}
      renderItem={renderItem}
      keyExtractor={keyExtractor}
      ListHeaderComponent={ListHeaderComponent}
      ListEmptyComponent={ListEmptyComponent}
      ListFooterComponent={ListFooterComponent}
      ItemSeparatorComponent={ItemSeparatorComponent}
      onEndReached={onEndReached}
      onEndReachedThreshold={onEndReachedThreshold}
      refreshControl={
        onRefresh ? (
          <RefreshControl
            refreshing={isRefreshing}
            onRefresh={onRefresh}
            tintColor={COLORS.brand.primary}
          />
        ) : undefined
      }
      contentContainerStyle={[
        styles.contentContainer,
        data?.length === 0 && styles.emptyContentContainer,
        contentContainerStyle,
      ]}
      showsVerticalScrollIndicator={false}
    />
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// STYLES
// ═══════════════════════════════════════════════════════════════════════════

const styles = StyleSheet.create({
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingVertical: SPACING[8],
  },
  contentContainer: {
    paddingHorizontal: SPACING[4],
    paddingVertical: SPACING[4],
  },
  emptyContentContainer: {
    flex: 1,
    justifyContent: 'center',
  },
  emptyContainer: {
    alignItems: 'center',
    paddingVertical: SPACING[8],
  },
  emptyIcon: {
    fontSize: 48,
    marginBottom: SPACING[4],
  },
  emptyMessage: {
    color: COLORS.text.muted,
    fontSize: 16,
    textAlign: 'center',
  },
  footerLoader: {
    paddingVertical: SPACING[6],
    alignItems: 'center',
  },
});

export default List;
