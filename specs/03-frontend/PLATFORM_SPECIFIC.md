# HustleXP Platform-Specific Guidelines

**AUTHORITY:** FRONTEND_ARCHITECTURE.md, DESIGN_SYSTEM.md
**STATUS:** Constitutional Reference for Cursor
**VERSION:** 1.0.0

This document defines platform-specific handling for iOS and Android. Cursor MUST follow these patterns.

---

## Table of Contents

1. [Safe Areas](#1-safe-areas)
2. [Status Bar](#2-status-bar)
3. [Navigation Patterns](#3-navigation-patterns)
4. [Keyboard Handling](#4-keyboard-handling)
5. [Platform-Specific Styles](#5-platform-specific-styles)
6. [Screen-by-Screen Safe Area Guide](#6-screen-by-screen-safe-area-guide)

---

## 1. Safe Areas

### 1.1 SafeAreaView Setup

Always use `react-native-safe-area-context`:

```typescript
import {
  SafeAreaProvider,
  SafeAreaView,
  useSafeAreaInsets,
} from 'react-native-safe-area-context';

// Wrap app root
const App = () => (
  <SafeAreaProvider>
    <NavigationContainer>
      {/* ... */}
    </NavigationContainer>
  </SafeAreaProvider>
);
```

### 1.2 SafeAreaView Usage

```typescript
// Full screen with safe area
const Screen = ({ children }) => (
  <SafeAreaView style={styles.container} edges={['top', 'bottom']}>
    {children}
  </SafeAreaView>
);

// Only top safe area (for screens with tab bar)
const ScreenWithTabBar = ({ children }) => (
  <SafeAreaView style={styles.container} edges={['top']}>
    {children}
  </SafeAreaView>
);

// Custom safe area handling
const CustomScreen = () => {
  const insets = useSafeAreaInsets();

  return (
    <View style={[
      styles.container,
      { paddingTop: insets.top, paddingBottom: insets.bottom }
    ]}>
      {/* content */}
    </View>
  );
};
```

### 1.3 Edge Specification

| Scenario | edges prop |
|----------|------------|
| Full screen (no tab bar) | `['top', 'bottom']` |
| Screen with tab bar | `['top']` |
| Modal | `['top', 'bottom']` |
| Bottom sheet | `['bottom']` |
| Scrollable content | `['top']` (bottom handled by ScrollView) |

### 1.4 Safe Area Insets Reference

**iPhone with notch (X/11/12/13/14/15):**
- Top: 47-59px (varies by model)
- Bottom: 34px

**iPhone without notch (SE/8):**
- Top: 20px (status bar only)
- Bottom: 0px

**Android (varies):**
- Top: 24-48px (status bar)
- Bottom: 0-48px (navigation bar, depends on gesture nav)

---

## 2. Status Bar

### 2.1 Status Bar Configuration

```typescript
import { StatusBar } from 'expo-status-bar';

// Light content (for dark backgrounds)
<StatusBar style="light" />

// Dark content (for light backgrounds)
<StatusBar style="dark" />

// Auto (based on color scheme)
<StatusBar style="auto" />
```

### 2.2 Per-Screen Status Bar

```typescript
import { useFocusEffect } from '@react-navigation/native';
import { StatusBar } from 'expo-status-bar';

const DarkScreen = () => {
  useFocusEffect(() => {
    // Set status bar style when screen is focused
    return () => {
      // Optionally reset when leaving
    };
  });

  return (
    <>
      <StatusBar style="light" />
      {/* dark content */}
    </>
  );
};
```

### 2.3 Status Bar by Screen Type

| Screen Type | Status Bar Style |
|-------------|------------------|
| Standard screens | `dark` |
| Dark header/hero | `light` |
| Onboarding | `dark` |
| Modal overlay | `light` (over dark backdrop) |
| Full-screen image | `light` |

---

## 3. Navigation Patterns

### 3.1 iOS vs Android Defaults

| Pattern | iOS | Android |
|---------|-----|---------|
| Back gesture | Swipe from left edge | Hardware/gesture back |
| Modal presentation | Slide up, card style | Fade or slide up |
| Tab bar | Bottom, labeled | Bottom, may use Material style |
| Header | Large title support | Standard Material header |

### 3.2 Navigation Header

```typescript
import { useNavigation } from '@react-navigation/native';
import { Platform } from 'react-native';

// Platform-specific header config
const screenOptions = {
  headerStyle: {
    backgroundColor: '#FFFFFF',
    ...Platform.select({
      ios: {
        shadowColor: 'transparent',
      },
      android: {
        elevation: 0,
      },
    }),
  },
  headerTitleStyle: {
    fontSize: 17,
    fontWeight: '600',
  },
  headerBackTitleVisible: false, // iOS only
};
```

### 3.3 Back Button

```typescript
// Custom back button
const BackButton = () => {
  const navigation = useNavigation();

  return (
    <TouchableOpacity
      onPress={() => navigation.goBack()}
      style={styles.backButton}
      hitSlop={{ top: 10, bottom: 10, left: 10, right: 10 }}
    >
      <ChevronLeft size={24} color={GRAY[900]} />
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  backButton: {
    width: 44,
    height: 44,
    justifyContent: 'center',
    alignItems: 'center',
    marginLeft: Platform.OS === 'ios' ? -8 : 0,
  },
});
```

### 3.4 Tab Bar

```typescript
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';

const Tab = createBottomTabNavigator();

const TabNavigator = () => (
  <Tab.Navigator
    screenOptions={{
      tabBarStyle: {
        height: Platform.OS === 'ios' ? 83 : 56, // Accounts for safe area on iOS
        paddingBottom: Platform.OS === 'ios' ? 28 : 8,
        paddingTop: 8,
      },
      tabBarLabelStyle: {
        fontSize: 11,
        fontWeight: '500',
      },
      tabBarActiveTintColor: GRAY[900],
      tabBarInactiveTintColor: GRAY[400],
    }}
  >
    {/* tabs */}
  </Tab.Navigator>
);
```

---

## 4. Keyboard Handling

### 4.1 KeyboardAvoidingView

```typescript
import { KeyboardAvoidingView, Platform } from 'react-native';

const FormScreen = () => (
  <KeyboardAvoidingView
    style={styles.container}
    behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
    keyboardVerticalOffset={Platform.OS === 'ios' ? 64 : 0} // Header height
  >
    <ScrollView>
      {/* form fields */}
    </ScrollView>
  </KeyboardAvoidingView>
);
```

### 4.2 Keyboard Dismiss

```typescript
import {
  Keyboard,
  TouchableWithoutFeedback,
} from 'react-native';

const DismissKeyboard = ({ children }) => (
  <TouchableWithoutFeedback onPress={Keyboard.dismiss} accessible={false}>
    {children}
  </TouchableWithoutFeedback>
);
```

### 4.3 Keyboard Events

```typescript
import { useEffect } from 'react';
import { Keyboard, Platform } from 'react-native';

const useKeyboard = () => {
  const [keyboardHeight, setKeyboardHeight] = useState(0);
  const [keyboardVisible, setKeyboardVisible] = useState(false);

  useEffect(() => {
    const showEvent = Platform.OS === 'ios' ? 'keyboardWillShow' : 'keyboardDidShow';
    const hideEvent = Platform.OS === 'ios' ? 'keyboardWillHide' : 'keyboardDidHide';

    const showSubscription = Keyboard.addListener(showEvent, (e) => {
      setKeyboardHeight(e.endCoordinates.height);
      setKeyboardVisible(true);
    });

    const hideSubscription = Keyboard.addListener(hideEvent, () => {
      setKeyboardHeight(0);
      setKeyboardVisible(false);
    });

    return () => {
      showSubscription.remove();
      hideSubscription.remove();
    };
  }, []);

  return { keyboardHeight, keyboardVisible };
};
```

---

## 5. Platform-Specific Styles

### 5.1 Platform.select

```typescript
import { Platform, StyleSheet } from 'react-native';

const styles = StyleSheet.create({
  shadow: {
    ...Platform.select({
      ios: {
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.1,
        shadowRadius: 4,
      },
      android: {
        elevation: 4,
      },
    }),
  },

  font: {
    fontFamily: Platform.select({
      ios: 'System',
      android: 'Roboto',
    }),
  },
});
```

### 5.2 Platform-Specific Components

```typescript
const Divider = () => (
  <View
    style={[
      styles.divider,
      Platform.OS === 'android' && styles.dividerAndroid,
    ]}
  />
);

const styles = StyleSheet.create({
  divider: {
    height: StyleSheet.hairlineWidth,
    backgroundColor: GRAY[200],
  },
  dividerAndroid: {
    height: 1, // Android may not render hairline well
  },
});
```

### 5.3 Touch Feedback

```typescript
import { Platform, Pressable, TouchableOpacity } from 'react-native';

// iOS: Use opacity feedback
// Android: Use ripple effect
const Button = ({ onPress, children }) => {
  if (Platform.OS === 'android') {
    return (
      <Pressable
        onPress={onPress}
        android_ripple={{ color: 'rgba(0, 0, 0, 0.1)' }}
        style={styles.button}
      >
        {children}
      </Pressable>
    );
  }

  return (
    <TouchableOpacity
      onPress={onPress}
      activeOpacity={0.7}
      style={styles.button}
    >
      {children}
    </TouchableOpacity>
  );
};
```

---

## 6. Screen-by-Screen Safe Area Guide

### Auth Screens

| Screen | Safe Edges | Notes |
|--------|------------|-------|
| Login | `['top', 'bottom']` | Full screen, no tab bar |
| Signup | `['top', 'bottom']` | Full screen |
| ForgotPassword | `['top', 'bottom']` | Full screen |

### Onboarding Screens

| Screen | Safe Edges | Notes |
|--------|------------|-------|
| Framing | `['top', 'bottom']` | Full bleed optional |
| Calibration | `['top', 'bottom']` | Buttons near bottom |
| RoleConfirmation | `['top', 'bottom']` | - |
| PreferenceLock | `['top', 'bottom']` | CTA at bottom |

### Main App Screens (Tab Bar)

| Screen | Safe Edges | Notes |
|--------|------------|-------|
| Home | `['top']` | Tab bar handles bottom |
| Tasks (Feed) | `['top']` | Scrollable content |
| Tasks (History) | `['top']` | - |
| Wallet | `['top']` | - |
| Profile | `['top']` | - |

### Detail Screens

| Screen | Safe Edges | Notes |
|--------|------------|-------|
| TaskDetail | `['top']` | Has fixed CTA at bottom |
| ProofSubmit | `['top']` | KeyboardAvoidingView handles bottom |
| Conversation | `['top']` | Input at bottom with keyboard handling |
| DisputeDetail | `['top']` | - |

### Modal Screens

| Screen | Safe Edges | Notes |
|--------|------------|-------|
| FilterSheet | `['bottom']` | Bottom sheet |
| ConfirmModal | `['top', 'bottom']` | Centered modal |
| PhotoViewer | `['top', 'bottom']` | Full screen |

### Settings Screens

| Screen | Safe Edges | Notes |
|--------|------------|-------|
| Settings | `['top']` | Tab bar present |
| Account | `['top']` | Pushed screen |
| Notifications | `['top']` | - |
| Payment | `['top']` | - |
| Privacy | `['top']` | - |

---

## Screen Template

```typescript
import { SafeAreaView, useSafeAreaInsets } from 'react-native-safe-area-context';
import { StatusBar } from 'expo-status-bar';
import { Platform, KeyboardAvoidingView } from 'react-native';

interface ScreenProps {
  children: React.ReactNode;
  hasTabBar?: boolean;
  hasKeyboard?: boolean;
  statusBarStyle?: 'light' | 'dark';
}

const Screen = ({
  children,
  hasTabBar = false,
  hasKeyboard = false,
  statusBarStyle = 'dark',
}: ScreenProps) => {
  const insets = useSafeAreaInsets();

  const edges: ('top' | 'bottom')[] = hasTabBar ? ['top'] : ['top', 'bottom'];

  const content = (
    <SafeAreaView style={styles.container} edges={edges}>
      {children}
    </SafeAreaView>
  );

  if (hasKeyboard) {
    return (
      <>
        <StatusBar style={statusBarStyle} />
        <KeyboardAvoidingView
          style={styles.flex}
          behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
          keyboardVerticalOffset={Platform.OS === 'ios' ? 0 : 20}
        >
          {content}
        </KeyboardAvoidingView>
      </>
    );
  }

  return (
    <>
      <StatusBar style={statusBarStyle} />
      {content}
    </>
  );
};

const styles = StyleSheet.create({
  flex: {
    flex: 1,
  },
  container: {
    flex: 1,
    backgroundColor: '#FFFFFF',
  },
});

export default Screen;
```

**Usage:**

```typescript
// Tab screen
<Screen hasTabBar>
  <TaskList />
</Screen>

// Full screen with form
<Screen hasKeyboard>
  <LoginForm />
</Screen>

// Modal
<Screen statusBarStyle="light">
  <ModalContent />
</Screen>
```

---

## Platform Detection Helper

```typescript
import { Platform, Dimensions } from 'react-native';

export const isIOS = Platform.OS === 'ios';
export const isAndroid = Platform.OS === 'android';

// Check for iPhone with notch (X and later)
const { height, width } = Dimensions.get('window');
export const hasNotch = isIOS && (height >= 812 || width >= 812);

// Check for Android gesture navigation
// Note: This is approximate, actual detection requires native code
export const hasGestureNav = isAndroid && Platform.Version >= 29;
```

---

**END OF PLATFORM-SPECIFIC GUIDELINES**
