/**
 * HustleXP Tab Navigator
 * 
 * Main app navigation with 4 tabs:
 * - Home (Dashboard)
 * - Tasks (Task Feed)
 * - Profile (XP, Badges)
 * - Wallet (Earnings)
 */

import React from 'react';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { Ionicons } from '@expo/vector-icons';

import { HomeScreen } from '../screens/HomeScreen';
import { TasksScreen } from '../screens/TasksScreen';
import { ProfileScreen } from '../screens/ProfileScreen';
import { WalletScreen } from '../screens/WalletScreen';

import { COLORS, GRAY, XP } from '../constants/colors';
import { TOUCH } from '../constants/spacing';

const Tab = createBottomTabNavigator();

function TabBarIcon({ name, focused, color }) {
  return (
    <Ionicons 
      name={focused ? name : `${name}-outline`} 
      size={24} 
      color={color} 
    />
  );
}

export function TabNavigator() {
  return (
    <Tab.Navigator
      screenOptions={{
        headerShown: false,
        tabBarActiveTintColor: GRAY[900],
        tabBarInactiveTintColor: GRAY[400],
        tabBarStyle: {
          backgroundColor: COLORS.background,
          borderTopColor: COLORS.border,
          borderTopWidth: 1,
          // A4: Touch targets minimum 44px
          height: 84,
          paddingBottom: 28,
          paddingTop: 8,
        },
        tabBarLabelStyle: {
          fontSize: 12,
          fontWeight: '500',
        },
      }}
    >
      <Tab.Screen
        name="Home"
        component={HomeScreen}
        options={{
          tabBarIcon: ({ focused, color }) => (
            <TabBarIcon name="home" focused={focused} color={color} />
          ),
        }}
      />
      <Tab.Screen
        name="Tasks"
        component={TasksScreen}
        options={{
          tabBarIcon: ({ focused, color }) => (
            <TabBarIcon name="list" focused={focused} color={color} />
          ),
        }}
      />
      <Tab.Screen
        name="Profile"
        component={ProfileScreen}
        options={{
          tabBarIcon: ({ focused, color }) => (
            <TabBarIcon name="person" focused={focused} color={color} />
          ),
        }}
      />
      <Tab.Screen
        name="Wallet"
        component={WalletScreen}
        options={{
          tabBarIcon: ({ focused, color }) => (
            <TabBarIcon name="wallet" focused={focused} color={color} />
          ),
        }}
      />
    </Tab.Navigator>
  );
}

export default TabNavigator;
