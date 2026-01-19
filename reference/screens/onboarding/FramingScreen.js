/**
 * FramingScreen - Phase 0 Framing Screen (ONBOARDING_SPEC §14)
 * 
 * DESIGN PRINCIPLES:
 * - White or neutral surface background
 * - No brand gradients
 * - No motion
 * - No progress indicator
 * - Single CTA button
 * 
 * PURPOSE: Establish system authority without asking permission
 * 
 * SPEC: ONBOARDING_SPEC.md §14 (Phase 0 Framing Screen)
 */

import React from 'react';
import { 
  View, 
  StyleSheet, 
  SafeAreaView,
} from 'react-native';
import { HXText } from '../../components/Text';
import { Button } from '../../components/Button';
import { COLORS, NEUTRAL } from '../../constants/colors';
import { SPACING } from '../../constants/spacing';

export function FramingScreen({ navigation }) {
  const handleContinue = () => {
    navigation.replace('Calibration');
  };

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.content}>
        <View style={styles.textContainer}>
          <HXText variant="h2" style={styles.headline}>
            HustleXP supports two ways to use the platform.
          </HXText>
          
          <HXText variant="body" color="secondary" style={styles.subheadline}>
            We'll configure your experience based on how you respond.
          </HXText>
        </View>

        <View style={styles.actionContainer}>
          <Button
            title="Continue"
            onPress={handleContinue}
            size="lg"
          />
        </View>
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: NEUTRAL.BACKGROUND,
  },
  content: {
    flex: 1,
    paddingHorizontal: SPACING[6],
    justifyContent: 'center',
  },
  textContainer: {
    marginBottom: SPACING[12],
  },
  headline: {
    textAlign: 'center',
    marginBottom: SPACING[4],
    lineHeight: 36,
  },
  subheadline: {
    textAlign: 'center',
    lineHeight: 24,
  },
  actionContainer: {
    marginTop: SPACING[8],
  },
});

export default FramingScreen;
