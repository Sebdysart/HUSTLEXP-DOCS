/**
 * CalibrationScreen - Role inference probes
 * 
 * DESIGN PRINCIPLES:
 * - Single sentence prompts
 * - Binary/ternary choices only
 * - No explanations
 * - No emojis
 * - No "why we ask"
 * - Neutral, professional copy
 * 
 * SPEC: A4 touch targets ≥44px
 */

import React, { useState } from 'react';
import { 
  View, 
  StyleSheet, 
  SafeAreaView,
  TouchableOpacity,
  Animated,
} from 'react-native';
import { HXText } from '../../components/Text';
import { COLORS, GRAY } from '../../constants/colors';
import { SPACING } from '../../constants/spacing';
import { 
  CALIBRATION_QUESTIONS,
  captureContext,
} from '../../state/OnboardingStateMachine';

export function CalibrationScreen({ navigation }) {
  const [currentIndex, setCurrentIndex] = useState(0);
  const [responses, setResponses] = useState({});
  const [context] = useState(() => captureContext());
  const [fadeAnim] = useState(new Animated.Value(1));
  
  const currentQuestion = CALIBRATION_QUESTIONS[currentIndex];
  const totalQuestions = CALIBRATION_QUESTIONS.length;
  const progress = (currentIndex + 1) / totalQuestions;

  const handleSelect = (optionId) => {
    const newResponses = {
      ...responses,
      [currentQuestion.id]: optionId,
    };
    setResponses(newResponses);

    // Fade transition (≤300ms per M1)
    Animated.timing(fadeAnim, {
      toValue: 0,
      duration: 150,
      useNativeDriver: true,
    }).start(() => {
      if (currentIndex < totalQuestions - 1) {
        setCurrentIndex(currentIndex + 1);
        Animated.timing(fadeAnim, {
          toValue: 1,
          duration: 150,
          useNativeDriver: true,
        }).start();
      } else {
        navigation.replace('RoleConfirmation', {
          context,
          responses: newResponses,
        });
      }
    });
  };

  return (
    <SafeAreaView style={styles.container}>
      {/* Progress bar - minimal */}
      <View style={styles.progressContainer}>
        <View style={styles.progressTrack}>
          <View style={[styles.progressFill, { width: `${progress * 100}%` }]} />
        </View>
      </View>

      <Animated.View style={[styles.content, { opacity: fadeAnim }]}>
        <View style={styles.questionContainer}>
          <HXText variant="h2" style={styles.prompt}>
            {currentQuestion.prompt}
          </HXText>
        </View>

        <View style={styles.optionsContainer}>
          {currentQuestion.options.map((option) => (
            <TouchableOpacity
              key={option.id}
              style={styles.optionButton}
              onPress={() => handleSelect(option.id)}
              activeOpacity={0.7}
            >
              <HXText variant="body" style={styles.optionText}>
                {option.label}
              </HXText>
            </TouchableOpacity>
          ))}
        </View>
      </Animated.View>

      <TouchableOpacity 
        style={styles.skipButton}
        onPress={() => {
          navigation.replace('RoleConfirmation', { context, responses });
        }}
      >
        <HXText variant="caption" color="secondary">Skip</HXText>
      </TouchableOpacity>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: COLORS.background,
  },
  progressContainer: {
    paddingHorizontal: SPACING[6],
    paddingTop: SPACING[4],
  },
  progressTrack: {
    height: 2,
    backgroundColor: GRAY[200],
    borderRadius: 1,
  },
  progressFill: {
    height: 2,
    backgroundColor: GRAY[900],
    borderRadius: 1,
  },
  content: {
    flex: 1,
    paddingHorizontal: SPACING[6],
    justifyContent: 'center',
  },
  questionContainer: {
    marginBottom: SPACING[8],
  },
  prompt: {
    textAlign: 'center',
    lineHeight: 36,
  },
  optionsContainer: {
    gap: SPACING[3],
  },
  optionButton: {
    backgroundColor: COLORS.surface,
    borderWidth: 1,
    borderColor: GRAY[200],
    borderRadius: 12,
    paddingVertical: SPACING[4],
    paddingHorizontal: SPACING[5],
    minHeight: 56, // A4: ≥44px
    justifyContent: 'center',
    alignItems: 'center',
  },
  optionText: {
    textAlign: 'center',
  },
  skipButton: {
    alignSelf: 'center',
    paddingVertical: SPACING[4],
    paddingHorizontal: SPACING[6],
    marginBottom: SPACING[4],
  },
});

export default CalibrationScreen;
