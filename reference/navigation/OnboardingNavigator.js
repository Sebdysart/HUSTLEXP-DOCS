/**
 * OnboardingNavigator - Role inference + authority priming flow
 * 
 * FLOW:
 * 1. Calibration (3-5 questions)
 * 2. RoleConfirmation (system decision with appeal)
 * 3. PreferenceLock (role-gated preferences)
 * → Main app
 * 
 * NO chatbots. NO surveys. NO quizzes.
 * This is SYSTEM CALIBRATION.
 */

import React from 'react';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { 
  FramingScreen,
  CalibrationScreen, 
  RoleConfirmationScreen, 
  PreferenceLockScreen,
} from '../screens/onboarding';
import { TabNavigator } from './TabNavigator';

const Stack = createNativeStackNavigator();

export function OnboardingNavigator() {
  return (
    <Stack.Navigator
      screenOptions={{
        headerShown: false,
        contentStyle: { backgroundColor: '#FFFFFF' },
        animation: 'fade', // Subtle, professional
      }}
    >
      <Stack.Screen 
        name="Framing" 
        component={FramingScreen}
      />
      <Stack.Screen 
        name="Calibration" 
        component={CalibrationScreen}
      />
      <Stack.Screen 
        name="RoleConfirmation" 
        component={RoleConfirmationScreen}
      />
      <Stack.Screen 
        name="PreferenceLock" 
        component={PreferenceLockScreen}
      />
      <Stack.Screen 
        name="Main" 
        component={TabNavigator}
      />
    </Stack.Navigator>
  );
}

export default OnboardingNavigator;
