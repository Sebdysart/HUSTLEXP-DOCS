/**
 * PreferenceLockScreen - Post-role preference capture
 * 
 * PURPOSE: Collect preferences AFTER role is established
 * WHY NOW: Role context makes answers truthful
 * 
 * Worker preferences: task types, availability, price bands
 * Poster preferences: task categories, budget range, urgency
 */

import React, { useState } from 'react';
import { 
  View, 
  StyleSheet, 
  SafeAreaView,
  ScrollView,
  TouchableOpacity,
} from 'react-native';
import { HXText } from '../../components/Text';
import { Button } from '../../components/Button';
import { Card } from '../../components/Card';
import { COLORS, GRAY } from '../../constants/colors';
import { SPACING } from '../../constants/spacing';
import { 
  createOnboardingResult,
  UserRole,
} from '../../state/OnboardingStateMachine';

// Worker-specific preferences
const WORKER_TASK_TYPES = [
  { id: 'errands', label: 'Errands & Deliveries' },
  { id: 'cleaning', label: 'Cleaning & Organization' },
  { id: 'moving', label: 'Moving & Heavy Lifting' },
  { id: 'tech', label: 'Tech Support' },
  { id: 'handyman', label: 'Handyman Tasks' },
  { id: 'other', label: 'Other / Flexible' },
];

const AVAILABILITY_OPTIONS = [
  { id: 'weekday_morning', label: 'Weekday mornings' },
  { id: 'weekday_evening', label: 'Weekday evenings' },
  { id: 'weekend', label: 'Weekends' },
  { id: 'flexible', label: 'Flexible / Anytime' },
];

// Poster-specific preferences  
const POSTER_CATEGORIES = [
  { id: 'home', label: 'Home & Personal' },
  { id: 'business', label: 'Business Tasks' },
  { id: 'events', label: 'Events & Special' },
  { id: 'recurring', label: 'Recurring Needs' },
];

const URGENCY_OPTIONS = [
  { id: 'asap', label: 'Usually urgent' },
  { id: 'planned', label: 'Usually planned ahead' },
  { id: 'flexible', label: 'Varies' },
];

export function PreferenceLockScreen({ navigation, route }) {
  const { context, responses, roleOverride } = route.params;
  
  // Determine final role
  const finalRole = roleOverride || 
    (responses.motivation === 'income' || responses.motivation === 'both' 
      ? UserRole.WORKER 
      : UserRole.POSTER);
  
  const isWorker = finalRole === UserRole.WORKER;
  
  // Preference state
  const [selectedTypes, setSelectedTypes] = useState([]);
  const [selectedAvailability, setSelectedAvailability] = useState([]);
  const [selectedUrgency, setSelectedUrgency] = useState(null);
  const [loading, setLoading] = useState(false);

  const toggleType = (id) => {
    setSelectedTypes(prev => 
      prev.includes(id) 
        ? prev.filter(t => t !== id)
        : [...prev, id]
    );
  };

  const toggleAvailability = (id) => {
    setSelectedAvailability(prev =>
      prev.includes(id)
        ? prev.filter(a => a !== id)
        : [...prev, id]
    );
  };

  const handleComplete = async () => {
    setLoading(true);
    
    // Create complete onboarding result
    const result = createOnboardingResult(context, responses, roleOverride);
    
    // Add preferences to result
    result.preferences = isWorker
      ? {
          taskTypes: selectedTypes,
          availability: selectedAvailability,
        }
      : {
          categories: selectedTypes,
          urgency: selectedUrgency,
        };
    
    // TODO: Save to backend/storage
    console.log('Onboarding complete:', result);
    
    // Simulate save
    setTimeout(() => {
      setLoading(false);
      // Navigate to main app
      navigation.reset({
        index: 0,
        routes: [{ name: 'Main' }],
      });
    }, 500);
  };

  const canContinue = selectedTypes.length > 0;

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView 
        contentContainerStyle={styles.scrollContent}
        showsVerticalScrollIndicator={false}
      >
        {/* Header */}
        <View style={styles.header}>
          <HXText variant="h2">
            {isWorker ? 'What tasks interest you?' : 'What do you need help with?'}
          </HXText>
          <HXText variant="body" color="secondary" style={styles.subtitle}>
            Select all that apply
          </HXText>
        </View>

        {/* Task types / Categories */}
        <View style={styles.section}>
          <View style={styles.optionGrid}>
            {(isWorker ? WORKER_TASK_TYPES : POSTER_CATEGORIES).map((item) => (
              <TouchableOpacity
                key={item.id}
                style={[
                  styles.chipButton,
                  selectedTypes.includes(item.id) && styles.chipSelected,
                ]}
                onPress={() => toggleType(item.id)}
              >
                <HXText 
                  variant="bodySmall"
                  style={selectedTypes.includes(item.id) ? styles.chipTextSelected : null}
                >
                  {item.label}
                </HXText>
              </TouchableOpacity>
            ))}
          </View>
        </View>

        {/* Availability (Worker) or Urgency (Poster) */}
        <View style={styles.section}>
          <HXText variant="label" style={styles.sectionLabel}>
            {isWorker ? 'When are you available?' : 'How urgent are your tasks usually?'}
          </HXText>
          
          {isWorker ? (
            <View style={styles.optionGrid}>
              {AVAILABILITY_OPTIONS.map((item) => (
                <TouchableOpacity
                  key={item.id}
                  style={[
                    styles.chipButton,
                    selectedAvailability.includes(item.id) && styles.chipSelected,
                  ]}
                  onPress={() => toggleAvailability(item.id)}
                >
                  <HXText 
                    variant="bodySmall"
                    style={selectedAvailability.includes(item.id) ? styles.chipTextSelected : null}
                  >
                    {item.label}
                  </HXText>
                </TouchableOpacity>
              ))}
            </View>
          ) : (
            <View style={styles.optionList}>
              {URGENCY_OPTIONS.map((item) => (
                <TouchableOpacity
                  key={item.id}
                  style={[
                    styles.radioButton,
                    selectedUrgency === item.id && styles.radioSelected,
                  ]}
                  onPress={() => setSelectedUrgency(item.id)}
                >
                  <View style={styles.radioOuter}>
                    {selectedUrgency === item.id && <View style={styles.radioInner} />}
                  </View>
                  <HXText variant="body">{item.label}</HXText>
                </TouchableOpacity>
              ))}
            </View>
          )}
        </View>
      </ScrollView>

      {/* Action */}
      <View style={styles.actionContainer}>
        <Button
          title="Get Started"
          onPress={handleComplete}
          loading={loading}
          disabled={!canContinue}
          size="lg"
        />
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: COLORS.background,
  },
  scrollContent: {
    padding: SPACING[5],
    paddingBottom: SPACING[20],
  },
  header: {
    marginBottom: SPACING[6],
  },
  subtitle: {
    marginTop: SPACING[2],
  },
  section: {
    marginBottom: SPACING[6],
  },
  sectionLabel: {
    marginBottom: SPACING[3],
  },
  optionGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: SPACING[2],
  },
  chipButton: {
    paddingVertical: SPACING[3],
    paddingHorizontal: SPACING[4],
    borderRadius: 20,
    borderWidth: 1,
    borderColor: GRAY[300],
    backgroundColor: COLORS.surface,
    minHeight: 44, // A4
  },
  chipSelected: {
    borderColor: GRAY[900],
    backgroundColor: GRAY[900],
  },
  chipTextSelected: {
    color: COLORS.surface,
  },
  optionList: {
    gap: SPACING[3],
  },
  radioButton: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: SPACING[3],
    paddingHorizontal: SPACING[4],
    borderRadius: 12,
    borderWidth: 1,
    borderColor: GRAY[200],
    gap: SPACING[3],
    minHeight: 52, // A4
  },
  radioSelected: {
    borderColor: GRAY[900],
    backgroundColor: GRAY[50],
  },
  radioOuter: {
    width: 20,
    height: 20,
    borderRadius: 10,
    borderWidth: 2,
    borderColor: GRAY[400],
    alignItems: 'center',
    justifyContent: 'center',
  },
  radioInner: {
    width: 10,
    height: 10,
    borderRadius: 5,
    backgroundColor: GRAY[900],
  },
  actionContainer: {
    padding: SPACING[5],
    paddingBottom: SPACING[8],
    backgroundColor: COLORS.background,
    borderTopWidth: 1,
    borderTopColor: GRAY[100],
  },
});

export default PreferenceLockScreen;
