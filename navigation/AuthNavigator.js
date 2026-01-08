/**
 * AuthNavigator - Authentication flow stack
 * 
 * SPEC COMPLIANCE:
 * - UI_SPEC.md §6: Auth screens (Login, Signup, Forgot Password)
 * - AUDIT-21: No replay on navigation
 */

import React from 'react';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { LoginScreen, SignupScreen, ForgotPasswordScreen } from '../screens';
import { GRAY } from '../constants/colors';

const Stack = createNativeStackNavigator();

export function AuthNavigator() {
  return (
    <Stack.Navigator
      screenOptions={{
        headerShown: false,
        contentStyle: { backgroundColor: '#FFFFFF' },
        // Prevent animation replay on back navigation
        animation: 'fade',
      }}
    >
      <Stack.Screen 
        name="Login" 
        component={LoginScreen}
      />
      <Stack.Screen 
        name="Signup" 
        component={SignupScreen}
      />
      <Stack.Screen 
        name="ForgotPassword" 
        component={ForgotPasswordScreen}
      />
    </Stack.Navigator>
  );
}

export default AuthNavigator;
