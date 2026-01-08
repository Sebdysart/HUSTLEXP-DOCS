/**
 * TasksScreen - Task feed with filters
 * 
 * SPEC: UI_SPEC.md §6 - Screen-specific rules
 * - Celebration: ❌ Forbidden
 * - Animation: Card hover only
 * - XP Colors: ❌ Forbidden
 */

import React from 'react';
import { View, StyleSheet, SafeAreaView, FlatList } from 'react-native';
import { HXText } from '../components/Text';
import { Card } from '../components/Card';
import { Button } from '../components/Button';
import { COLORS, MONEY, GRAY } from '../constants/colors';
import { SPACING } from '../constants/spacing';

// Placeholder task data
const PLACEHOLDER_TASKS = [
  { id: '1', title: 'Help move furniture', price: 5000, location: 'Campus' },
  { id: '2', title: 'Pick up groceries', price: 2500, location: 'Downtown' },
  { id: '3', title: 'Deliver package', price: 1500, location: 'Library' },
];

function TaskCard({ task }) {
  return (
    <Card variant="elevated" style={styles.taskCard}>
      <View style={styles.taskHeader}>
        <HXText variant="h4">{task.title}</HXText>
        {/* Money color only for escrow states - using neutral here */}
        <HXText variant="h4" style={{ color: GRAY[900] }}>
          ${(task.price / 100).toFixed(0)}
        </HXText>
      </View>
      <HXText variant="bodySmall" color="secondary">{task.location}</HXText>
      <Button 
        title="View Details" 
        variant="secondary" 
        size="sm"
        style={styles.viewButton}
        onPress={() => {}}
      />
    </Card>
  );
}

export function TasksScreen() {
  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <HXText variant="h2">Tasks</HXText>
        <HXText variant="bodySmall" color="secondary">
          Find tasks near you
        </HXText>
      </View>

      <FlatList
        data={PLACEHOLDER_TASKS}
        keyExtractor={(item) => item.id}
        renderItem={({ item }) => <TaskCard task={item} />}
        contentContainerStyle={styles.list}
        ListEmptyComponent={
          <Card variant="outlined" style={styles.emptyCard}>
            <HXText variant="body" color="secondary" align="center">
              No tasks available
            </HXText>
          </Card>
        }
      />
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: COLORS.background,
  },
  header: {
    padding: SPACING[4],
    paddingBottom: SPACING[2],
  },
  list: {
    padding: SPACING[4],
    paddingTop: SPACING[2],
  },
  taskCard: {
    marginBottom: SPACING[3],
    padding: SPACING[4],
  },
  taskHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: SPACING[1],
  },
  viewButton: {
    marginTop: SPACING[3],
  },
  emptyCard: {
    padding: SPACING[8],
  },
});

export default TasksScreen;
