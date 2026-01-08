/**
 * HustleXP App Entry Point
 * 
 * FLOW:
 * 1. Not authenticated → AuthNavigator (Login/Signup)
 * 2. Authenticated, not onboarded → OnboardingNavigator (Role inference)
 * 3. Authenticated + onboarded → TabNavigator (Main app)
 * 
 * Set flags below to test different flows:
 * - isAuthenticated = false → Login screen
 * - isAuthenticated = true, isOnboarded = false → Onboarding
 * - isAuthenticated = true, isOnboarded = true → Main app
 */

import React, { useState } from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { TabNavigator, AuthNavigator, OnboardingNavigator } from './navigation';

const RootStack = createNativeStackNavigator();

export default function App() {
  // Auth state (TODO: Replace with real auth)
  const [isAuthenticated, setIsAuthenticated] = useState(true);
  
  // Onboarding state (TODO: Replace with AsyncStorage check)
  // Set to FALSE to test onboarding flow
  const [isOnboarded, setIsOnboarded] = useState(false);

  return (
    <NavigationContainer>
      <RootStack.Navigator screenOptions={{ headerShown: false }}>
        {!isAuthenticated ? (
          // Not logged in → Auth flow
          <RootStack.Screen name="Auth" component={AuthNavigator} />
        ) : !isOnboarded ? (
          // Logged in but not onboarded → Onboarding flow
          <RootStack.Screen name="Onboarding" component={OnboardingNavigator} />
        ) : (
          // Fully onboarded → Main app
          <RootStack.Screen name="Main" component={TabNavigator} />
        )}
      </RootStack.Navigator>
    </NavigationContainer>
  );
}
