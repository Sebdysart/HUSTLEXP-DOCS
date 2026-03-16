# HustleXP React Native Migration — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Scaffold a production-ready React Native (Expo bare) project at `~/HustleXP/hustlexp-rn` with full infrastructure wired, all design tokens ported, and all 65 screens built across 4 phases.

**Architecture:** New GitHub repo `Sebdysart/hustlexp-rn`. Expo SDK 52 bare workflow. tRPC client hits existing Railway backend unchanged. Revolut motion language in Reanimated 3 + Skia. See design doc: `docs/plans/2026-03-16-react-native-migration-design.md`

**Tech Stack:** Expo 52 bare, Expo Router v3, Reanimated 3, Skia, NativeWind v4, @trpc/client, @trpc/react-query, @react-native-firebase/auth, @stripe/stripe-react-native, Zustand, MMKV, EAS

---

## Task 1: Create GitHub Repo + Clone

**Files:**
- Create: `~/HustleXP/hustlexp-rn/` (directory from gh + scaffold)

**Step 1: Create private GitHub repo**
```bash
gh repo create Sebdysart/hustlexp-rn --private --description "HustleXP React Native (iOS + Android)"
```
Expected: `✓ Created repository Sebdysart/hustlexp-rn`

**Step 2: Scaffold Expo bare project**
```bash
cd ~/HustleXP
npx create-expo-app@latest hustlexp-rn --template bare-minimum
cd hustlexp-rn
```
Expected: Project created with `package.json`, `app.json`, `App.tsx`, `android/`, `ios/`

**Step 3: Remove default template files + init git remote**
```bash
rm App.tsx README.md 2>/dev/null; true
git remote add origin https://github.com/Sebdysart/hustlexp-rn.git
```

**Step 4: Install Expo Router**
```bash
npx expo install expo-router expo-constants expo-linking expo-status-bar expo-splash-screen react-native-safe-area-context react-native-screens
```

**Step 5: Update app.json for Expo Router**

Edit `app.json` — add `"scheme": "hustlexp"` and `"web": { "bundler": "metro" }` and update main to `expo-router/entry`:
```json
{
  "expo": {
    "name": "HustleXP",
    "slug": "hustlexp",
    "scheme": "hustlexp",
    "version": "1.0.0",
    "orientation": "portrait",
    "icon": "./assets/icon.png",
    "userInterfaceStyle": "dark",
    "splash": {
      "image": "./assets/splash.png",
      "resizeMode": "contain",
      "backgroundColor": "#0B0B0F"
    },
    "ios": {
      "supportsTablet": false,
      "bundleIdentifier": "com.hustlexp.app"
    },
    "android": {
      "adaptiveIcon": {
        "foregroundImage": "./assets/adaptive-icon.png",
        "backgroundColor": "#0B0B0F"
      },
      "package": "com.hustlexp.app"
    },
    "plugins": [
      "expo-router",
      "expo-font"
    ]
  }
}
```

**Step 6: Update package.json main entry**

In `package.json`, set `"main": "expo-router/entry"`

**Step 7: Commit**
```bash
git add -A
git commit -m "feat: scaffold Expo bare project with Expo Router"
git push -u origin main
```

---

## Task 2: Install All Dependencies

**Files:**
- Modify: `package.json`

**Step 1: Install animation + rendering stack**
```bash
cd ~/HustleXP/hustlexp-rn
npx expo install react-native-reanimated react-native-gesture-handler @shopify/react-native-skia
```

**Step 2: Install API + auth + payments**
```bash
npx expo install @trpc/client @trpc/react-query @tanstack/react-query superjson
npx expo install @react-native-firebase/app @react-native-firebase/auth @react-native-firebase/messaging
npx expo install @stripe/stripe-react-native
```

**Step 3: Install state + storage**
```bash
npx expo install zustand react-native-mmkv
```

**Step 4: Install native feature modules**
```bash
npx expo install expo-location expo-camera expo-image-picker expo-local-authentication expo-haptics expo-notifications expo-font expo-secure-store
npx expo install react-native-maps react-native-sse react-native-ssl-pinning
```

**Step 5: Install styling**
```bash
npm install nativewind tailwindcss
npx tailwindcss init
```

**Step 6: Configure Babel for Reanimated + NativeWind**

Edit `babel.config.js`:
```js
module.exports = function (api) {
  api.cache(true);
  return {
    presets: ['babel-preset-expo'],
    plugins: [
      'nativewind/babel',
      'react-native-reanimated/plugin', // MUST be last
    ],
  };
};
```

**Step 7: Configure tailwind.config.js**
```js
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ['./app/**/*.{js,jsx,ts,tsx}', './src/**/*.{js,jsx,ts,tsx}'],
  theme: {
    extend: {
      colors: {
        brandBlack: '#0B0B0F',
        brandPurple: '#5B2DFF',
        brandPurpleLight: '#7A4DFF',
        brandPurpleGlow: '#8B5CF6',
        accentPurple: '#8B5CF6',
        accentViolet: '#A78BFA',
        successGreen: '#34C759',
        moneyGreen: '#1FAD7E',
        errorRed: '#FF3B30',
        warningOrange: '#FF9500',
        infoBlue: '#007AFF',
        instantYellow: '#FFD900',
        xpGold: '#FFD700',
        backgroundElevated: '#1C1C1E',
        surfaceSecondary: '#141417',
        textSecondary: '#E5E5EA',
        textMuted: '#8E8E93',
      },
    },
  },
  plugins: [],
};
```

**Step 8: Configure TypeScript strict mode**

Edit `tsconfig.json`:
```json
{
  "extends": "expo/tsconfig.base",
  "compilerOptions": {
    "strict": true,
    "baseUrl": ".",
    "paths": {
      "@/*": ["src/*"]
    }
  }
}
```

**Step 9: Install iOS pods**
```bash
cd ios && pod install && cd ..
```

**Step 10: Commit**
```bash
git add -A
git commit -m "feat: install full dependency stack (Reanimated, Firebase, Stripe, NativeWind)"
```

---

## Task 3: Design Tokens + Theme

**Files:**
- Create: `src/design/tokens.ts`
- Create: `src/design/typography.ts`
- Create: `src/design/spacing.ts`
- Create: `src/design/motion.ts`

**Step 1: Create color tokens (port of ColorTokens.swift)**

Create `src/design/tokens.ts`:
```ts
// HustleXP Color System — port of ColorTokens.swift
// Authority: COLOR_SEMANTICS_LAW.md

export const colors = {
  // Layer 1: Brand Canvas
  brandBlack: '#0B0B0F',
  brandPurple: '#5B2DFF',
  brandPurpleLight: '#7A4DFF',
  brandPurpleGlow: '#8B5CF6',

  // Layer 2: Brand Accent
  accentPurple: '#8B5CF6',
  accentViolet: '#A78BFA',

  // Layer 3: Success/Money (ONLY after user action succeeds)
  successGreen: '#34C759',
  moneyGreen: '#1FAD7E',

  // Layer 4: Status
  errorRed: '#FF3B30',
  warningOrange: '#FF9500',
  warningYellow: '#FF9500',
  infoBlue: '#007AFF',
  liveRed: '#FF3B30',
  instantYellow: '#FFD900',

  // Layer 5a: Unlockable feature colors
  squadGold: '#F59E0B',
  squadGoldLight: '#FCD34D',
  recurringBlue: '#3B82F6',
  recurringBlueLight: '#93C5FD',

  // Layer 5: Feature colors
  aiPurple: '#8B5CF6',

  // Layer 6: Neutrals
  textPrimary: '#FFFFFF',
  textSecondary: '#E5E5EA',
  textMuted: '#8E8E93',
  textTertiary: 'rgba(255,255,255,0.4)',
  backgroundBlack: '#000000',
  backgroundElevated: '#1C1C1E',
  glassSurface: 'rgba(28,28,30,0.6)',
  glassBorder: 'rgba(255,255,255,0.1)',
  surfaceElevated: '#1C1C1E',
  surfacePrimary: '#1C1C1E',
  surfaceSecondary: '#141417',
  surfaceDefault: '#141417',
  surfaceBorder: 'rgba(255,255,255,0.2)',
  borderSubtle: 'rgba(255,255,255,0.2)',

  // Semantic aliases
  buttonPrimary: '#5B2DFF',
  buttonSecondary: '#1C1C1E',
  buttonDanger: '#FF3B30',
  badgeActive: '#007AFF',
  badgePending: '#FF9500',
  badgeComplete: '#34C759',
  badgeCancelled: '#FF3B30',
  tierRookie: '#8E8E93',
  tierVerified: '#007AFF',
  tierTrusted: '#34C759',
  tierElite: '#8B5CF6',
  tierMaster: '#FF9500',

  // Heat map
  heatLow: '#3B82F6',
  heatMedium: '#FBBF24',
  heatHigh: '#F97316',
  heatHot: '#EF4444',
  geofenceBoundary: '#5B2DFF',
  movementPath: '#007AFF',
  walkingRoute: '#5B2DFF',
  mapGrid: 'rgba(255,255,255,0.15)',

  // XP
  xpGold: '#FFD700',
} as const;

export type ColorToken = keyof typeof colors;
```

**Step 2: Create motion constants**

Create `src/design/motion.ts`:
```ts
import { Easing } from 'react-native-reanimated';

// Revolut motion design language for HustleXP
// Iron law: ease-out only, no springs, no bounce, no overshoot
export const EASE_OUT = Easing.bezier(0.22, 0, 0.36, 1);

export const durations = {
  fast: 250,
  normal: 400,
  slow: 600,
  overlay: 300,
  badge: 450,
  ring: 600,
  shine: 500,
  breath: 1050,
} as const;

// Animation timing presets
export const timing = (duration: number) => ({
  duration,
  easing: EASE_OUT,
});
```

**Step 3: Create typography**

Create `src/design/typography.ts`:
```ts
export const typography = {
  // Display
  display: { fontSize: 32, fontWeight: '700' as const, letterSpacing: 8 },
  heading: { fontSize: 24, fontWeight: '700' as const },
  subheading: { fontSize: 18, fontWeight: '600' as const },

  // Body
  body: { fontSize: 16, fontWeight: '400' as const },
  bodyBold: { fontSize: 16, fontWeight: '600' as const },
  caption: { fontSize: 13, fontWeight: '400' as const },
  label: { fontSize: 11, fontWeight: '500' as const, letterSpacing: 4 },
} as const;
```

**Step 4: Commit**
```bash
git add src/
git commit -m "feat: port design tokens, motion constants, typography from Swift"
```

---

## Task 4: App Entry + Root Layout + Navigation Shell

**Files:**
- Create: `app/_layout.tsx`
- Create: `app/index.tsx`
- Create: `src/lib/firebase.ts`
- Create: `src/store/authStore.ts`
- Create: `src/hooks/useAuth.ts`

**Step 1: Create Firebase initializer**

Create `src/lib/firebase.ts`:
```ts
import auth from '@react-native-firebase/auth';

export { auth };

export const signInWithEmailPassword = (email: string, password: string) =>
  auth().signInWithEmailAndPassword(email, password);

export const createUserWithEmailPassword = (email: string, password: string) =>
  auth().createUserWithEmailAndPassword(email, password);

export const signOut = () => auth().signOut();

export const getCurrentUser = () => auth().currentUser;

export const getIdToken = async (): Promise<string | null> => {
  const user = auth().currentUser;
  if (!user) return null;
  return user.getIdToken();
};
```

**Step 2: Create auth store**

Create `src/store/authStore.ts`:
```ts
import { create } from 'zustand';
import { FirebaseAuthTypes } from '@react-native-firebase/auth';

interface AuthState {
  user: FirebaseAuthTypes.User | null;
  isLoading: boolean;
  setUser: (user: FirebaseAuthTypes.User | null) => void;
  setLoading: (loading: boolean) => void;
}

export const useAuthStore = create<AuthState>((set) => ({
  user: null,
  isLoading: true,
  setUser: (user) => set({ user }),
  setLoading: (isLoading) => set({ isLoading }),
}));
```

**Step 3: Create useAuth hook**

Create `src/hooks/useAuth.ts`:
```ts
import { useEffect } from 'react';
import auth from '@react-native-firebase/auth';
import { useAuthStore } from '@/store/authStore';

export const useAuth = () => {
  const { user, isLoading, setUser, setLoading } = useAuthStore();

  useEffect(() => {
    const unsubscribe = auth().onAuthStateChanged((firebaseUser) => {
      setUser(firebaseUser);
      setLoading(false);
    });
    return unsubscribe;
  }, []);

  return { user, isLoading };
};
```

**Step 4: Create root layout**

Create `app/_layout.tsx`:
```tsx
import { useEffect } from 'react';
import { Stack, useRouter, useSegments } from 'expo-router';
import { GestureHandlerRootView } from 'react-native-gesture-handler';
import { QueryClientProvider } from '@tanstack/react-query';
import { StatusBar } from 'expo-status-bar';
import { useAuth } from '@/hooks/useAuth';
import { queryClient } from '@/lib/trpc';

function AuthGate({ children }: { children: React.ReactNode }) {
  const { user, isLoading } = useAuth();
  const segments = useSegments();
  const router = useRouter();

  useEffect(() => {
    if (isLoading) return;
    const inAuth = segments[0] === '(auth)';
    const inOnboarding = segments[0] === '(onboarding)';

    if (!user && !inAuth) {
      router.replace('/(auth)/login');
    } else if (user && (inAuth || inOnboarding)) {
      // TODO: check onboarding complete flag, route to (hustler) or (poster)
      router.replace('/(hustler)/');
    }
  }, [user, isLoading, segments]);

  return <>{children}</>;
}

export default function RootLayout() {
  return (
    <GestureHandlerRootView style={{ flex: 1, backgroundColor: '#0B0B0F' }}>
      <QueryClientProvider client={queryClient}>
        <AuthGate>
          <Stack screenOptions={{ headerShown: false, contentStyle: { backgroundColor: '#0B0B0F' } }} />
        </AuthGate>
        <StatusBar style="light" />
      </QueryClientProvider>
    </GestureHandlerRootView>
  );
}
```

**Step 5: Create splash redirect**

Create `app/index.tsx`:
```tsx
import { Redirect } from 'expo-router';

export default function Index() {
  return <Redirect href="/(auth)/login" />;
}
```

**Step 6: Commit**
```bash
git add app/ src/
git commit -m "feat: root layout, auth gate, Firebase auth store"
```

---

## Task 5: tRPC Client

**Files:**
- Create: `src/lib/trpc.ts`

**Step 1: Create tRPC client (mirrors TRPCClient.swift)**

Create `src/lib/trpc.ts`:
```ts
import { createTRPCClient, httpBatchLink } from '@trpc/client';
import { createTRPCReact } from '@trpc/react-query';
import { QueryClient } from '@tanstack/react-query';
import superjson from 'superjson';
import auth from '@react-native-firebase/auth';
import type { AppRouter } from '../../../hustlexp-ai-backend/src/router'; // type import only

const BACKEND_URL = __DEV__
  ? 'https://hustlexp-ai-backend-staging-production.up.railway.app'
  : 'https://hustlexp-ai-backend-production.up.railway.app';

export const trpc = createTRPCReact<AppRouter>();

export const queryClient = new QueryClient({
  defaultOptions: {
    queries: { retry: 2, staleTime: 30_000 },
    mutations: { retry: 0 },
  },
});

const getAuthHeader = async (): Promise<Record<string, string>> => {
  const user = auth().currentUser;
  if (!user) return {};
  const token = await user.getIdToken();
  return { Authorization: `Bearer ${token}` };
};

export const trpcClient = trpc.createClient({
  links: [
    httpBatchLink({
      url: `${BACKEND_URL}/trpc`,
      transformer: superjson,
      headers: getAuthHeader,
    }),
  ],
});
```

**Step 2: Commit**
```bash
git add src/lib/trpc.ts
git commit -m "feat: tRPC client with Firebase auth header injection"
```

---

## Task 6: EAS Configuration + GitHub Actions

**Files:**
- Create: `eas.json`
- Create: `.github/workflows/ci.yml`

**Step 1: Create eas.json**
```json
{
  "cli": { "version": ">= 7.0.0" },
  "build": {
    "development": {
      "developmentClient": true,
      "distribution": "internal",
      "env": { "APP_ENV": "development" }
    },
    "preview": {
      "distribution": "internal",
      "env": { "APP_ENV": "staging" },
      "ios": { "simulator": false },
      "android": { "buildType": "apk" }
    },
    "production": {
      "env": { "APP_ENV": "production" },
      "ios": { "credentialsSource": "remote" },
      "android": { "credentialsSource": "remote" }
    }
  },
  "submit": {
    "production": {
      "ios": {},
      "android": {}
    }
  }
}
```

**Step 2: Initialize EAS**
```bash
npx eas-cli init
```
Expected: Links project to Expo account

**Step 3: Create GitHub Actions CI**

Create `.github/workflows/ci.yml`:
```yaml
name: CI
on:
  pull_request:
    branches: [main]
  push:
    branches: [main]

jobs:
  typecheck:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci
      - run: npx tsc --noEmit

  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci
      - run: npx eslint . --ext .ts,.tsx --max-warnings 0
```

**Step 4: Commit**
```bash
git add eas.json .github/
git commit -m "feat: EAS build config + GitHub Actions CI"
git push
```

---

## Task 7: Phase 1 — Auth Screens

**Files:**
- Create: `app/(auth)/_layout.tsx`
- Create: `app/(auth)/login.tsx`
- Create: `app/(auth)/signup.tsx`
- Create: `app/(auth)/phone-verification.tsx`
- Create: `app/(auth)/forgot-password.tsx`

**Step 1: Create auth layout**

Create `app/(auth)/_layout.tsx`:
```tsx
import { Stack } from 'expo-router';

export default function AuthLayout() {
  return (
    <Stack
      screenOptions={{
        headerShown: false,
        contentStyle: { backgroundColor: '#0B0B0F' },
        animation: 'fade',
      }}
    />
  );
}
```

**Step 2: Create LoginScreen**

Create `app/(auth)/login.tsx`:
```tsx
import { useState } from 'react';
import { View, Text, TextInput, TouchableOpacity, ActivityIndicator, KeyboardAvoidingView, Platform } from 'react-native';
import { useRouter } from 'expo-router';
import { signInWithEmailPassword } from '@/lib/firebase';
import { colors } from '@/design/tokens';

export default function LoginScreen() {
  const router = useRouter();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleLogin = async () => {
    if (!email || !password) return;
    setLoading(true);
    setError(null);
    try {
      await signInWithEmailPassword(email, password);
      // Auth state listener in root layout handles redirect
    } catch (err: any) {
      setError(err.message ?? 'Sign in failed');
    } finally {
      setLoading(false);
    }
  };

  return (
    <KeyboardAvoidingView
      behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
      style={{ flex: 1, backgroundColor: colors.brandBlack }}
    >
      <View style={{ flex: 1, justifyContent: 'center', paddingHorizontal: 24 }}>
        {/* Logo / wordmark */}
        <Text style={{ color: colors.textPrimary, fontSize: 32, fontWeight: '700', marginBottom: 8 }}>
          HustleXP
        </Text>
        <Text style={{ color: colors.textMuted, fontSize: 16, marginBottom: 48 }}>
          Sign in to your account
        </Text>

        {error && (
          <Text style={{ color: colors.errorRed, marginBottom: 16, fontSize: 14 }}>{error}</Text>
        )}

        <TextInput
          value={email}
          onChangeText={setEmail}
          placeholder="Email"
          placeholderTextColor={colors.textMuted}
          keyboardType="email-address"
          autoCapitalize="none"
          style={{
            backgroundColor: colors.backgroundElevated,
            color: colors.textPrimary,
            borderRadius: 12,
            padding: 16,
            fontSize: 16,
            marginBottom: 12,
          }}
        />

        <TextInput
          value={password}
          onChangeText={setPassword}
          placeholder="Password"
          placeholderTextColor={colors.textMuted}
          secureTextEntry
          style={{
            backgroundColor: colors.backgroundElevated,
            color: colors.textPrimary,
            borderRadius: 12,
            padding: 16,
            fontSize: 16,
            marginBottom: 24,
          }}
        />

        <TouchableOpacity
          onPress={handleLogin}
          disabled={loading}
          style={{
            backgroundColor: colors.brandPurple,
            borderRadius: 12,
            padding: 16,
            alignItems: 'center',
            marginBottom: 16,
          }}
        >
          {loading ? (
            <ActivityIndicator color={colors.textPrimary} />
          ) : (
            <Text style={{ color: colors.textPrimary, fontSize: 16, fontWeight: '600' }}>Sign In</Text>
          )}
        </TouchableOpacity>

        <TouchableOpacity
          onPress={() => router.push('/(auth)/forgot-password')}
          style={{ alignItems: 'center', marginBottom: 12 }}
        >
          <Text style={{ color: colors.brandPurpleLight, fontSize: 14 }}>Forgot password?</Text>
        </TouchableOpacity>

        <TouchableOpacity
          onPress={() => router.push('/(auth)/signup')}
          style={{ alignItems: 'center' }}
        >
          <Text style={{ color: colors.textMuted, fontSize: 14 }}>
            No account? <Text style={{ color: colors.brandPurpleLight }}>Sign up</Text>
          </Text>
        </TouchableOpacity>
      </View>
    </KeyboardAvoidingView>
  );
}
```

**Step 3: Create SignupScreen**

Create `app/(auth)/signup.tsx`:
```tsx
import { useState } from 'react';
import { View, Text, TextInput, TouchableOpacity, ActivityIndicator, KeyboardAvoidingView, Platform, ScrollView } from 'react-native';
import { useRouter } from 'expo-router';
import { createUserWithEmailPassword } from '@/lib/firebase';
import { colors } from '@/design/tokens';

export default function SignupScreen() {
  const router = useRouter();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleSignup = async () => {
    if (!email || !password) return;
    if (password !== confirmPassword) {
      setError('Passwords do not match');
      return;
    }
    setLoading(true);
    setError(null);
    try {
      await createUserWithEmailPassword(email, password);
      router.replace('/(onboarding)/welcome');
    } catch (err: any) {
      setError(err.message ?? 'Sign up failed');
    } finally {
      setLoading(false);
    }
  };

  return (
    <KeyboardAvoidingView
      behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
      style={{ flex: 1, backgroundColor: colors.brandBlack }}
    >
      <ScrollView contentContainerStyle={{ flexGrow: 1, justifyContent: 'center', paddingHorizontal: 24 }}>
        <Text style={{ color: colors.textPrimary, fontSize: 28, fontWeight: '700', marginBottom: 8 }}>
          Create Account
        </Text>
        <Text style={{ color: colors.textMuted, fontSize: 16, marginBottom: 40 }}>
          Join HustleXP today
        </Text>

        {error && (
          <Text style={{ color: colors.errorRed, marginBottom: 16, fontSize: 14 }}>{error}</Text>
        )}

        {[
          { value: email, setter: setEmail, placeholder: 'Email', keyboard: 'email-address' as const, secure: false },
          { value: password, setter: setPassword, placeholder: 'Password', keyboard: 'default' as const, secure: true },
          { value: confirmPassword, setter: setConfirmPassword, placeholder: 'Confirm Password', keyboard: 'default' as const, secure: true },
        ].map(({ value, setter, placeholder, keyboard, secure }) => (
          <TextInput
            key={placeholder}
            value={value}
            onChangeText={setter}
            placeholder={placeholder}
            placeholderTextColor={colors.textMuted}
            keyboardType={keyboard}
            autoCapitalize="none"
            secureTextEntry={secure}
            style={{
              backgroundColor: colors.backgroundElevated,
              color: colors.textPrimary,
              borderRadius: 12,
              padding: 16,
              fontSize: 16,
              marginBottom: 12,
            }}
          />
        ))}

        <TouchableOpacity
          onPress={handleSignup}
          disabled={loading}
          style={{
            backgroundColor: colors.brandPurple,
            borderRadius: 12,
            padding: 16,
            alignItems: 'center',
            marginTop: 12,
            marginBottom: 16,
          }}
        >
          {loading ? (
            <ActivityIndicator color={colors.textPrimary} />
          ) : (
            <Text style={{ color: colors.textPrimary, fontSize: 16, fontWeight: '600' }}>Create Account</Text>
          )}
        </TouchableOpacity>

        <TouchableOpacity onPress={() => router.back()} style={{ alignItems: 'center' }}>
          <Text style={{ color: colors.textMuted, fontSize: 14 }}>
            Have an account? <Text style={{ color: colors.brandPurpleLight }}>Sign in</Text>
          </Text>
        </TouchableOpacity>
      </ScrollView>
    </KeyboardAvoidingView>
  );
}
```

**Step 4: Create PhoneVerificationScreen + ForgotPasswordScreen (stubs wired to tRPC)**

Create `app/(auth)/phone-verification.tsx`:
```tsx
import { View, Text } from 'react-native';
import { colors } from '@/design/tokens';
export default function PhoneVerificationScreen() {
  return (
    <View style={{ flex: 1, backgroundColor: colors.brandBlack, justifyContent: 'center', alignItems: 'center' }}>
      <Text style={{ color: colors.textPrimary, fontSize: 20, fontWeight: '600' }}>Phone Verification</Text>
      <Text style={{ color: colors.textMuted, marginTop: 8 }}>SMS OTP flow — Phase 2</Text>
    </View>
  );
}
```

Create `app/(auth)/forgot-password.tsx`:
```tsx
import { useState } from 'react';
import { View, Text, TextInput, TouchableOpacity, ActivityIndicator, KeyboardAvoidingView, Platform } from 'react-native';
import { useRouter } from 'expo-router';
import auth from '@react-native-firebase/auth';
import { colors } from '@/design/tokens';

export default function ForgotPasswordScreen() {
  const router = useRouter();
  const [email, setEmail] = useState('');
  const [loading, setLoading] = useState(false);
  const [sent, setSent] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleReset = async () => {
    if (!email) return;
    setLoading(true);
    setError(null);
    try {
      await auth().sendPasswordResetEmail(email);
      setSent(true);
    } catch (err: any) {
      setError(err.message ?? 'Failed to send reset email');
    } finally {
      setLoading(false);
    }
  };

  return (
    <KeyboardAvoidingView
      behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
      style={{ flex: 1, backgroundColor: colors.brandBlack }}
    >
      <View style={{ flex: 1, justifyContent: 'center', paddingHorizontal: 24 }}>
        <TouchableOpacity onPress={() => router.back()} style={{ marginBottom: 32 }}>
          <Text style={{ color: colors.brandPurpleLight, fontSize: 16 }}>← Back</Text>
        </TouchableOpacity>

        <Text style={{ color: colors.textPrimary, fontSize: 28, fontWeight: '700', marginBottom: 8 }}>
          Reset Password
        </Text>

        {sent ? (
          <Text style={{ color: colors.successGreen, fontSize: 16, marginTop: 16 }}>
            Reset email sent. Check your inbox.
          </Text>
        ) : (
          <>
            {error && <Text style={{ color: colors.errorRed, marginBottom: 16 }}>{error}</Text>}
            <TextInput
              value={email}
              onChangeText={setEmail}
              placeholder="Email"
              placeholderTextColor={colors.textMuted}
              keyboardType="email-address"
              autoCapitalize="none"
              style={{
                backgroundColor: colors.backgroundElevated,
                color: colors.textPrimary,
                borderRadius: 12,
                padding: 16,
                fontSize: 16,
                marginBottom: 20,
                marginTop: 16,
              }}
            />
            <TouchableOpacity
              onPress={handleReset}
              disabled={loading}
              style={{ backgroundColor: colors.brandPurple, borderRadius: 12, padding: 16, alignItems: 'center' }}
            >
              {loading ? <ActivityIndicator color="#fff" /> : <Text style={{ color: '#fff', fontWeight: '600' }}>Send Reset Email</Text>}
            </TouchableOpacity>
          </>
        )}
      </View>
    </KeyboardAvoidingView>
  );
}
```

**Step 5: Commit**
```bash
git add app/(auth)/
git commit -m "feat: auth screens — login, signup, forgot-password, phone-verify"
```

---

## Task 8: Phase 1 — Onboarding Screens

**Files:**
- Create: `app/(onboarding)/_layout.tsx`
- Create: `app/(onboarding)/welcome.tsx`
- Create: `app/(onboarding)/role-selection.tsx`
- Create: `app/(onboarding)/profile-setup.tsx`
- Create: `app/(onboarding)/skills.tsx`
- Create: `app/(onboarding)/permissions.tsx`
- Create: `app/(onboarding)/complete.tsx`

**Step 1: Create onboarding layout**

Create `app/(onboarding)/_layout.tsx`:
```tsx
import { Stack } from 'expo-router';
export default function OnboardingLayout() {
  return <Stack screenOptions={{ headerShown: false, contentStyle: { backgroundColor: '#0B0B0F' }, animation: 'slide_from_right' }} />;
}
```

**Step 2: Create WelcomeScreen**

Create `app/(onboarding)/welcome.tsx`:
```tsx
import { View, Text, TouchableOpacity } from 'react-native';
import { useRouter } from 'expo-router';
import { colors } from '@/design/tokens';

export default function WelcomeScreen() {
  const router = useRouter();
  return (
    <View style={{ flex: 1, backgroundColor: colors.brandBlack, justifyContent: 'space-between', padding: 40 }}>
      <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center' }}>
        <View style={{ width: 80, height: 80, backgroundColor: colors.brandPurple, borderRadius: 24, marginBottom: 32 }} />
        <Text style={{ color: colors.textPrimary, fontSize: 36, fontWeight: '700', textAlign: 'center', marginBottom: 16 }}>
          Welcome to{'\n'}HustleXP
        </Text>
        <Text style={{ color: colors.textMuted, fontSize: 17, textAlign: 'center', lineHeight: 26 }}>
          Earn money doing tasks in your neighborhood. Level up. Build your reputation.
        </Text>
      </View>
      <TouchableOpacity
        onPress={() => router.push('/(onboarding)/role-selection')}
        style={{ backgroundColor: colors.brandPurple, borderRadius: 16, padding: 18, alignItems: 'center' }}
      >
        <Text style={{ color: colors.textPrimary, fontSize: 17, fontWeight: '700' }}>Get Started</Text>
      </TouchableOpacity>
    </View>
  );
}
```

**Step 3: Create RoleSelectionScreen**

Create `app/(onboarding)/role-selection.tsx`:
```tsx
import { useState } from 'react';
import { View, Text, TouchableOpacity } from 'react-native';
import { useRouter } from 'expo-router';
import { colors } from '@/design/tokens';
import { useAuthStore } from '@/store/authStore';

type Role = 'hustler' | 'poster';

export default function RoleSelectionScreen() {
  const router = useRouter();
  const [selected, setSelected] = useState<Role | null>(null);

  const roles = [
    { id: 'hustler' as Role, title: 'Hustler', subtitle: 'Complete tasks and earn money', emoji: '💪' },
    { id: 'poster' as Role, title: 'Poster', subtitle: 'Post tasks and get things done', emoji: '📋' },
  ];

  return (
    <View style={{ flex: 1, backgroundColor: colors.brandBlack, padding: 24, justifyContent: 'space-between' }}>
      <View style={{ marginTop: 60 }}>
        <Text style={{ color: colors.textPrimary, fontSize: 28, fontWeight: '700', marginBottom: 8 }}>
          How will you use HustleXP?
        </Text>
        <Text style={{ color: colors.textMuted, fontSize: 16, marginBottom: 40 }}>
          You can switch roles later in settings.
        </Text>

        {roles.map((role) => (
          <TouchableOpacity
            key={role.id}
            onPress={() => setSelected(role.id)}
            style={{
              backgroundColor: selected === role.id ? colors.brandPurple : colors.backgroundElevated,
              borderRadius: 16,
              padding: 20,
              marginBottom: 12,
              flexDirection: 'row',
              alignItems: 'center',
              borderWidth: 1,
              borderColor: selected === role.id ? colors.brandPurpleLight : 'transparent',
            }}
          >
            <Text style={{ fontSize: 32, marginRight: 16 }}>{role.emoji}</Text>
            <View>
              <Text style={{ color: colors.textPrimary, fontSize: 18, fontWeight: '700' }}>{role.title}</Text>
              <Text style={{ color: colors.textMuted, fontSize: 14, marginTop: 2 }}>{role.subtitle}</Text>
            </View>
          </TouchableOpacity>
        ))}
      </View>

      <TouchableOpacity
        onPress={() => selected && router.push('/(onboarding)/profile-setup')}
        disabled={!selected}
        style={{
          backgroundColor: selected ? colors.brandPurple : colors.backgroundElevated,
          borderRadius: 16,
          padding: 18,
          alignItems: 'center',
        }}
      >
        <Text style={{ color: selected ? colors.textPrimary : colors.textMuted, fontSize: 17, fontWeight: '700' }}>
          Continue
        </Text>
      </TouchableOpacity>
    </View>
  );
}
```

**Step 4: Create profile-setup, skills, permissions, complete screens**

Create `app/(onboarding)/profile-setup.tsx`:
```tsx
import { useState } from 'react';
import { View, Text, TextInput, TouchableOpacity, ScrollView, KeyboardAvoidingView, Platform } from 'react-native';
import { useRouter } from 'expo-router';
import { colors } from '@/design/tokens';

export default function ProfileSetupScreen() {
  const router = useRouter();
  const [firstName, setFirstName] = useState('');
  const [lastName, setLastName] = useState('');
  const [bio, setBio] = useState('');

  return (
    <KeyboardAvoidingView behavior={Platform.OS === 'ios' ? 'padding' : 'height'} style={{ flex: 1, backgroundColor: colors.brandBlack }}>
      <ScrollView contentContainerStyle={{ flexGrow: 1, padding: 24 }}>
        <Text style={{ color: colors.textPrimary, fontSize: 28, fontWeight: '700', marginBottom: 8, marginTop: 60 }}>
          Set up your profile
        </Text>
        <Text style={{ color: colors.textMuted, fontSize: 16, marginBottom: 40 }}>This is how others will see you.</Text>

        {[
          { label: 'First Name', value: firstName, setter: setFirstName },
          { label: 'Last Name', value: lastName, setter: setLastName },
        ].map(({ label, value, setter }) => (
          <View key={label} style={{ marginBottom: 16 }}>
            <Text style={{ color: colors.textSecondary, fontSize: 13, marginBottom: 6 }}>{label}</Text>
            <TextInput
              value={value}
              onChangeText={setter}
              placeholder={label}
              placeholderTextColor={colors.textMuted}
              style={{ backgroundColor: colors.backgroundElevated, color: colors.textPrimary, borderRadius: 12, padding: 16, fontSize: 16 }}
            />
          </View>
        ))}

        <View style={{ marginBottom: 40 }}>
          <Text style={{ color: colors.textSecondary, fontSize: 13, marginBottom: 6 }}>Bio (optional)</Text>
          <TextInput
            value={bio}
            onChangeText={setBio}
            placeholder="Tell people about yourself..."
            placeholderTextColor={colors.textMuted}
            multiline
            numberOfLines={3}
            style={{ backgroundColor: colors.backgroundElevated, color: colors.textPrimary, borderRadius: 12, padding: 16, fontSize: 16, minHeight: 80, textAlignVertical: 'top' }}
          />
        </View>

        <TouchableOpacity
          onPress={() => router.push('/(onboarding)/skills')}
          style={{ backgroundColor: colors.brandPurple, borderRadius: 16, padding: 18, alignItems: 'center' }}
        >
          <Text style={{ color: colors.textPrimary, fontSize: 17, fontWeight: '700' }}>Continue</Text>
        </TouchableOpacity>
      </ScrollView>
    </KeyboardAvoidingView>
  );
}
```

Create `app/(onboarding)/skills.tsx`:
```tsx
import { useState } from 'react';
import { View, Text, TouchableOpacity, ScrollView } from 'react-native';
import { useRouter } from 'expo-router';
import { colors } from '@/design/tokens';

const SKILLS = ['Delivery', 'Cleaning', 'Moving', 'Handyman', 'Tech Help', 'Errands', 'Photography', 'Writing', 'Design', 'Tutoring', 'Cooking', 'Pet Care'];

export default function SkillsScreen() {
  const router = useRouter();
  const [selected, setSelected] = useState<string[]>([]);

  const toggle = (skill: string) =>
    setSelected((prev) => prev.includes(skill) ? prev.filter((s) => s !== skill) : [...prev, skill]);

  return (
    <View style={{ flex: 1, backgroundColor: colors.brandBlack, padding: 24 }}>
      <Text style={{ color: colors.textPrimary, fontSize: 28, fontWeight: '700', marginBottom: 8, marginTop: 60 }}>
        What are your skills?
      </Text>
      <Text style={{ color: colors.textMuted, fontSize: 16, marginBottom: 32 }}>
        Select all that apply. This helps match you to the right tasks.
      </Text>
      <ScrollView showsVerticalScrollIndicator={false} style={{ flex: 1 }}>
        <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 10 }}>
          {SKILLS.map((skill) => {
            const isSelected = selected.includes(skill);
            return (
              <TouchableOpacity
                key={skill}
                onPress={() => toggle(skill)}
                style={{
                  backgroundColor: isSelected ? colors.brandPurple : colors.backgroundElevated,
                  borderRadius: 100,
                  paddingHorizontal: 16,
                  paddingVertical: 10,
                  borderWidth: 1,
                  borderColor: isSelected ? colors.brandPurpleLight : 'transparent',
                }}
              >
                <Text style={{ color: isSelected ? colors.textPrimary : colors.textMuted, fontWeight: '600' }}>{skill}</Text>
              </TouchableOpacity>
            );
          })}
        </View>
      </ScrollView>
      <TouchableOpacity
        onPress={() => router.push('/(onboarding)/permissions')}
        style={{ backgroundColor: colors.brandPurple, borderRadius: 16, padding: 18, alignItems: 'center', marginTop: 24 }}
      >
        <Text style={{ color: colors.textPrimary, fontSize: 17, fontWeight: '700' }}>
          {selected.length > 0 ? `Continue with ${selected.length} skill${selected.length > 1 ? 's' : ''}` : 'Skip for now'}
        </Text>
      </TouchableOpacity>
    </View>
  );
}
```

Create `app/(onboarding)/permissions.tsx`:
```tsx
import { View, Text, TouchableOpacity } from 'react-native';
import { useRouter } from 'expo-router';
import * as Location from 'expo-location';
import * as Notifications from 'expo-notifications';
import { colors } from '@/design/tokens';

export default function PermissionsScreen() {
  const router = useRouter();

  const requestAll = async () => {
    await Location.requestForegroundPermissionsAsync();
    await Notifications.requestPermissionsAsync();
    router.push('/(onboarding)/complete');
  };

  return (
    <View style={{ flex: 1, backgroundColor: colors.brandBlack, justifyContent: 'space-between', padding: 40 }}>
      <View style={{ flex: 1, justifyContent: 'center' }}>
        <Text style={{ color: colors.textPrimary, fontSize: 28, fontWeight: '700', marginBottom: 16 }}>
          Allow permissions
        </Text>
        <Text style={{ color: colors.textMuted, fontSize: 16, lineHeight: 26, marginBottom: 40 }}>
          HustleXP needs location to show you nearby tasks and notifications to keep you updated on your earnings and new opportunities.
        </Text>
        {[
          { icon: '📍', title: 'Location', desc: 'Find tasks near you' },
          { icon: '🔔', title: 'Notifications', desc: 'Stay updated on tasks and earnings' },
        ].map(({ icon, title, desc }) => (
          <View key={title} style={{ flexDirection: 'row', alignItems: 'center', marginBottom: 24 }}>
            <Text style={{ fontSize: 28, marginRight: 16 }}>{icon}</Text>
            <View>
              <Text style={{ color: colors.textPrimary, fontWeight: '600', fontSize: 16 }}>{title}</Text>
              <Text style={{ color: colors.textMuted, fontSize: 14 }}>{desc}</Text>
            </View>
          </View>
        ))}
      </View>
      <View>
        <TouchableOpacity
          onPress={requestAll}
          style={{ backgroundColor: colors.brandPurple, borderRadius: 16, padding: 18, alignItems: 'center', marginBottom: 12 }}
        >
          <Text style={{ color: colors.textPrimary, fontSize: 17, fontWeight: '700' }}>Enable All</Text>
        </TouchableOpacity>
        <TouchableOpacity onPress={() => router.push('/(onboarding)/complete')} style={{ alignItems: 'center' }}>
          <Text style={{ color: colors.textMuted, fontSize: 15 }}>Skip for now</Text>
        </TouchableOpacity>
      </View>
    </View>
  );
}
```

Create `app/(onboarding)/complete.tsx`:
```tsx
import { useEffect } from 'react';
import { View, Text } from 'react-native';
import { useRouter } from 'expo-router';
import Animated, { useSharedValue, useAnimatedStyle, withTiming, withDelay } from 'react-native-reanimated';
import { colors, EASE_OUT } from '@/design/tokens';
import { timing } from '@/design/motion';

export default function OnboardingCompleteScreen() {
  const router = useRouter();
  const opacity = useSharedValue(0);
  const scale = useSharedValue(0.9);

  const animatedStyle = useAnimatedStyle(() => ({
    opacity: opacity.value,
    transform: [{ scale: scale.value }],
  }));

  useEffect(() => {
    opacity.value = withTiming(1, timing(400));
    scale.value = withTiming(1, timing(400));
    const timer = setTimeout(() => router.replace('/(hustler)/'), 2500);
    return () => clearTimeout(timer);
  }, []);

  return (
    <View style={{ flex: 1, backgroundColor: colors.brandBlack, justifyContent: 'center', alignItems: 'center' }}>
      <Animated.View style={[{ alignItems: 'center' }, animatedStyle]}>
        <Text style={{ fontSize: 72, marginBottom: 24 }}>🚀</Text>
        <Text style={{ color: colors.textPrimary, fontSize: 32, fontWeight: '700', marginBottom: 12 }}>You're in.</Text>
        <Text style={{ color: colors.textMuted, fontSize: 17 }}>Let's start hustling.</Text>
      </Animated.View>
    </View>
  );
}
```

**Step 5: Commit**
```bash
git add app/(onboarding)/
git commit -m "feat: onboarding flow — welcome, role, profile, skills, permissions, complete"
```

---

## Task 9: Phase 2 — Hustler Tab Shell + Home Screen

**Files:**
- Create: `app/(hustler)/_layout.tsx`
- Create: `app/(hustler)/index.tsx`
- Create: `app/(hustler)/feed.tsx`
- Create: `app/(hustler)/earnings.tsx`
- Create: `app/(hustler)/profile.tsx`

**Step 1: Create Hustler tab navigator**

Create `app/(hustler)/_layout.tsx`:
```tsx
import { Tabs } from 'expo-router';
import { colors } from '@/design/tokens';

export default function HustlerLayout() {
  return (
    <Tabs
      screenOptions={{
        headerShown: false,
        tabBarStyle: {
          backgroundColor: colors.backgroundElevated,
          borderTopColor: colors.borderSubtle,
          borderTopWidth: 1,
          height: 84,
          paddingBottom: 28,
        },
        tabBarActiveTintColor: colors.brandPurple,
        tabBarInactiveTintColor: colors.textMuted,
        tabBarLabelStyle: { fontSize: 11, fontWeight: '600' },
      }}
    >
      <Tabs.Screen name="index" options={{ title: 'Home', tabBarIcon: ({ color }) => <TabIcon emoji="🏠" color={color} /> }} />
      <Tabs.Screen name="feed" options={{ title: 'Tasks', tabBarIcon: ({ color }) => <TabIcon emoji="📋" color={color} /> }} />
      <Tabs.Screen name="earnings" options={{ title: 'Earnings', tabBarIcon: ({ color }) => <TabIcon emoji="💰" color={color} /> }} />
      <Tabs.Screen name="profile" options={{ title: 'Profile', tabBarIcon: ({ color }) => <TabIcon emoji="👤" color={color} /> }} />
    </Tabs>
  );
}

function TabIcon({ emoji, color }: { emoji: string; color: string }) {
  const { Text } = require('react-native');
  return <Text style={{ fontSize: 22 }}>{emoji}</Text>;
}
```

**Step 2: Create HustlerHomeScreen**

Create `app/(hustler)/index.tsx`:
```tsx
import { View, Text, ScrollView, TouchableOpacity, RefreshControl } from 'react-native';
import { useRouter } from 'expo-router';
import { useState } from 'react';
import { colors } from '@/design/tokens';
import { trpc } from '@/lib/trpc';

export default function HustlerHomeScreen() {
  const router = useRouter();
  const [refreshing, setRefreshing] = useState(false);

  // TODO: wire to trpc.user.getProfile + trpc.task.getFeed
  // Placeholder structure — replace with real tRPC queries in Phase 2 wiring pass

  return (
    <ScrollView
      style={{ flex: 1, backgroundColor: colors.brandBlack }}
      contentContainerStyle={{ paddingBottom: 32 }}
      refreshControl={<RefreshControl refreshing={refreshing} onRefresh={() => setRefreshing(false)} tintColor={colors.brandPurple} />}
    >
      {/* Header */}
      <View style={{ paddingHorizontal: 20, paddingTop: 60, paddingBottom: 20 }}>
        <Text style={{ color: colors.textMuted, fontSize: 14 }}>Good morning 👋</Text>
        <Text style={{ color: colors.textPrimary, fontSize: 26, fontWeight: '700', marginTop: 4 }}>
          Ready to hustle?
        </Text>
      </View>

      {/* XP Bar */}
      <View style={{ marginHorizontal: 20, backgroundColor: colors.backgroundElevated, borderRadius: 16, padding: 16, marginBottom: 20 }}>
        <View style={{ flexDirection: 'row', justifyContent: 'space-between', marginBottom: 8 }}>
          <Text style={{ color: colors.textPrimary, fontWeight: '600' }}>Level 1 · Rookie</Text>
          <Text style={{ color: colors.xpGold, fontWeight: '600' }}>0 / 500 XP</Text>
        </View>
        <View style={{ height: 6, backgroundColor: colors.surfaceSecondary, borderRadius: 3 }}>
          <View style={{ height: 6, width: '0%', backgroundColor: colors.brandPurple, borderRadius: 3 }} />
        </View>
      </View>

      {/* Quick stats */}
      <View style={{ flexDirection: 'row', paddingHorizontal: 20, gap: 12, marginBottom: 24 }}>
        {[
          { label: 'Tasks Done', value: '0', color: colors.successGreen },
          { label: 'Earned', value: '$0', color: colors.xpGold },
          { label: 'Rating', value: '—', color: colors.brandPurpleLight },
        ].map(({ label, value, color }) => (
          <View key={label} style={{ flex: 1, backgroundColor: colors.backgroundElevated, borderRadius: 12, padding: 14, alignItems: 'center' }}>
            <Text style={{ color, fontSize: 22, fontWeight: '700' }}>{value}</Text>
            <Text style={{ color: colors.textMuted, fontSize: 12, marginTop: 2 }}>{label}</Text>
          </View>
        ))}
      </View>

      {/* CTA */}
      <TouchableOpacity
        onPress={() => router.push('/(hustler)/feed')}
        style={{ marginHorizontal: 20, backgroundColor: colors.brandPurple, borderRadius: 16, padding: 18, alignItems: 'center' }}
      >
        <Text style={{ color: colors.textPrimary, fontSize: 17, fontWeight: '700' }}>Find Tasks Near You</Text>
      </TouchableOpacity>
    </ScrollView>
  );
}
```

**Step 3: Create feed, earnings, profile placeholder screens**

Create `app/(hustler)/feed.tsx`:
```tsx
import { View, Text, FlatList, TouchableOpacity } from 'react-native';
import { useRouter } from 'expo-router';
import { colors } from '@/design/tokens';

// Placeholder — Phase 2 wires real tRPC data
const PLACEHOLDER_TASKS = [
  { id: '1', title: 'Help move furniture', price: 45, distance: '0.3 mi', category: 'Moving' },
  { id: '2', title: 'Grocery delivery', price: 22, distance: '0.7 mi', category: 'Errands' },
  { id: '3', title: 'Dog walking (1hr)', price: 18, distance: '0.2 mi', category: 'Pet Care' },
];

export default function HustlerFeedScreen() {
  const router = useRouter();
  return (
    <View style={{ flex: 1, backgroundColor: colors.brandBlack }}>
      <View style={{ paddingHorizontal: 20, paddingTop: 60, paddingBottom: 16 }}>
        <Text style={{ color: colors.textPrimary, fontSize: 24, fontWeight: '700' }}>Tasks Near You</Text>
      </View>
      <FlatList
        data={PLACEHOLDER_TASKS}
        keyExtractor={(item) => item.id}
        contentContainerStyle={{ paddingHorizontal: 20, paddingBottom: 32 }}
        renderItem={({ item }) => (
          <TouchableOpacity
            onPress={() => router.push(`/(hustler)/task/${item.id}`)}
            style={{ backgroundColor: colors.backgroundElevated, borderRadius: 16, padding: 16, marginBottom: 12 }}
          >
            <View style={{ flexDirection: 'row', justifyContent: 'space-between', alignItems: 'flex-start' }}>
              <Text style={{ color: colors.textPrimary, fontSize: 16, fontWeight: '600', flex: 1 }}>{item.title}</Text>
              <Text style={{ color: colors.xpGold, fontSize: 18, fontWeight: '700' }}>${item.price}</Text>
            </View>
            <View style={{ flexDirection: 'row', marginTop: 8, gap: 12 }}>
              <Text style={{ color: colors.textMuted, fontSize: 13 }}>📍 {item.distance}</Text>
              <Text style={{ color: colors.brandPurpleLight, fontSize: 13 }}>{item.category}</Text>
            </View>
          </TouchableOpacity>
        )}
      />
    </View>
  );
}
```

Create `app/(hustler)/earnings.tsx`:
```tsx
import { View, Text, ScrollView } from 'react-native';
import { colors } from '@/design/tokens';
export default function EarningsScreen() {
  return (
    <ScrollView style={{ flex: 1, backgroundColor: colors.brandBlack }}>
      <View style={{ paddingHorizontal: 20, paddingTop: 60 }}>
        <Text style={{ color: colors.textPrimary, fontSize: 24, fontWeight: '700', marginBottom: 24 }}>Earnings</Text>
        <View style={{ backgroundColor: colors.backgroundElevated, borderRadius: 16, padding: 24, alignItems: 'center', marginBottom: 20 }}>
          <Text style={{ color: colors.textMuted, fontSize: 14, marginBottom: 8 }}>Total Earned</Text>
          <Text style={{ color: colors.xpGold, fontSize: 48, fontWeight: '700' }}>$0.00</Text>
          <Text style={{ color: colors.textMuted, fontSize: 13, marginTop: 4 }}>All time</Text>
        </View>
      </View>
    </ScrollView>
  );
}
```

Create `app/(hustler)/profile.tsx`:
```tsx
import { View, Text, TouchableOpacity } from 'react-native';
import { useRouter } from 'expo-router';
import { signOut } from '@/lib/firebase';
import { colors } from '@/design/tokens';
export default function HustlerProfileScreen() {
  const router = useRouter();
  return (
    <View style={{ flex: 1, backgroundColor: colors.brandBlack, padding: 24 }}>
      <Text style={{ color: colors.textPrimary, fontSize: 24, fontWeight: '700', marginTop: 60, marginBottom: 40 }}>Profile</Text>
      <TouchableOpacity onPress={() => router.push('/(settings)/')} style={{ backgroundColor: colors.backgroundElevated, borderRadius: 12, padding: 16, marginBottom: 12 }}>
        <Text style={{ color: colors.textPrimary }}>⚙️  Settings</Text>
      </TouchableOpacity>
      <TouchableOpacity onPress={async () => { await signOut(); }} style={{ backgroundColor: colors.errorRed, borderRadius: 12, padding: 16, marginTop: 'auto' }}>
        <Text style={{ color: colors.textPrimary, fontWeight: '600', textAlign: 'center' }}>Sign Out</Text>
      </TouchableOpacity>
    </View>
  );
}
```

**Step 4: Create task detail dynamic route**

Create `app/(hustler)/task/[id].tsx`:
```tsx
import { View, Text, ScrollView, TouchableOpacity } from 'react-native';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { colors } from '@/design/tokens';

export default function HustlerTaskDetailScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const router = useRouter();

  // TODO Phase 2: wire trpc.task.getById.useQuery({ taskId: id })

  return (
    <ScrollView style={{ flex: 1, backgroundColor: colors.brandBlack }}>
      <View style={{ padding: 24, paddingTop: 60 }}>
        <TouchableOpacity onPress={() => router.back()} style={{ marginBottom: 24 }}>
          <Text style={{ color: colors.brandPurpleLight, fontSize: 16 }}>← Back</Text>
        </TouchableOpacity>
        <Text style={{ color: colors.textPrimary, fontSize: 24, fontWeight: '700', marginBottom: 8 }}>Task Details</Text>
        <Text style={{ color: colors.textMuted }}>Task ID: {id}</Text>
        <Text style={{ color: colors.textMuted, marginTop: 8 }}>Full details wire in Phase 2</Text>
        <TouchableOpacity
          style={{ backgroundColor: colors.brandPurple, borderRadius: 16, padding: 18, alignItems: 'center', marginTop: 40 }}
          onPress={() => router.push(`/(hustler)/task-in-progress/${id}`)}
        >
          <Text style={{ color: colors.textPrimary, fontSize: 17, fontWeight: '700' }}>Accept Task</Text>
        </TouchableOpacity>
      </View>
    </ScrollView>
  );
}
```

**Step 5: Commit**
```bash
git add app/(hustler)/
git commit -m "feat: Hustler tab shell — home, feed, earnings, profile, task detail"
```

---

## Task 10: Phase 2 — Poster Tab Shell

**Files:**
- Create: `app/(poster)/_layout.tsx`
- Create: `app/(poster)/index.tsx`
- Create: `app/(poster)/create-task.tsx`
- Create: `app/(poster)/task/[id].tsx`
- Create: `app/(poster)/active-tasks.tsx`
- Create: `app/(poster)/history.tsx`
- Create: `app/(poster)/profile.tsx`

**Step 1: Create Poster tab navigator**

Create `app/(poster)/_layout.tsx`:
```tsx
import { Tabs } from 'expo-router';
import { colors } from '@/design/tokens';
export default function PosterLayout() {
  return (
    <Tabs screenOptions={{
      headerShown: false,
      tabBarStyle: { backgroundColor: colors.backgroundElevated, borderTopColor: colors.borderSubtle, height: 84, paddingBottom: 28 },
      tabBarActiveTintColor: colors.brandPurple,
      tabBarInactiveTintColor: colors.textMuted,
      tabBarLabelStyle: { fontSize: 11, fontWeight: '600' },
    }}>
      <Tabs.Screen name="index" options={{ title: 'Home' }} />
      <Tabs.Screen name="active-tasks" options={{ title: 'Active' }} />
      <Tabs.Screen name="history" options={{ title: 'History' }} />
      <Tabs.Screen name="profile" options={{ title: 'Profile' }} />
    </Tabs>
  );
}
```

**Step 2: Create PosterHomeScreen**

Create `app/(poster)/index.tsx`:
```tsx
import { View, Text, ScrollView, TouchableOpacity } from 'react-native';
import { useRouter } from 'expo-router';
import { colors } from '@/design/tokens';
export default function PosterHomeScreen() {
  const router = useRouter();
  return (
    <ScrollView style={{ flex: 1, backgroundColor: colors.brandBlack }} contentContainerStyle={{ padding: 24, paddingBottom: 40 }}>
      <Text style={{ color: colors.textPrimary, fontSize: 26, fontWeight: '700', marginTop: 60, marginBottom: 8 }}>Post a Task</Text>
      <Text style={{ color: colors.textMuted, marginBottom: 32 }}>Get things done in your area</Text>
      {[
        { label: 'Standard Task', desc: 'Set a time and find a Hustler', emoji: '📋', route: '/(poster)/create-task' },
        { label: 'ASAP Task', desc: 'Get someone now', emoji: '⚡️', route: '/(poster)/asap-task' },
        { label: 'AI Task', desc: 'Let AI scope it for you', emoji: '🤖', route: '/(poster)/ai-task' },
      ].map(({ label, desc, emoji, route }) => (
        <TouchableOpacity
          key={label}
          onPress={() => router.push(route as any)}
          style={{ backgroundColor: colors.backgroundElevated, borderRadius: 16, padding: 20, marginBottom: 12, flexDirection: 'row', alignItems: 'center' }}
        >
          <Text style={{ fontSize: 32, marginRight: 16 }}>{emoji}</Text>
          <View>
            <Text style={{ color: colors.textPrimary, fontWeight: '700', fontSize: 16 }}>{label}</Text>
            <Text style={{ color: colors.textMuted, fontSize: 13, marginTop: 2 }}>{desc}</Text>
          </View>
        </TouchableOpacity>
      ))}
    </ScrollView>
  );
}
```

**Step 3: Create remaining poster screens as functional stubs**

Create `app/(poster)/create-task.tsx`:
```tsx
import { View, Text, TouchableOpacity, ScrollView, TextInput, KeyboardAvoidingView, Platform } from 'react-native';
import { useRouter } from 'expo-router';
import { useState } from 'react';
import { colors } from '@/design/tokens';
export default function CreateTaskScreen() {
  const router = useRouter();
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [price, setPrice] = useState('');
  return (
    <KeyboardAvoidingView behavior={Platform.OS === 'ios' ? 'padding' : 'height'} style={{ flex: 1, backgroundColor: colors.brandBlack }}>
      <ScrollView contentContainerStyle={{ padding: 24, paddingBottom: 40 }}>
        <TouchableOpacity onPress={() => router.back()} style={{ marginTop: 60, marginBottom: 24 }}>
          <Text style={{ color: colors.brandPurpleLight }}>← Back</Text>
        </TouchableOpacity>
        <Text style={{ color: colors.textPrimary, fontSize: 24, fontWeight: '700', marginBottom: 32 }}>Create Task</Text>
        {[
          { label: 'Task Title', value: title, setter: setTitle, placeholder: 'e.g. Help me move a couch' },
          { label: 'Budget ($)', value: price, setter: setPrice, placeholder: '25', keyboard: 'numeric' },
        ].map(({ label, value, setter, placeholder, keyboard }) => (
          <View key={label} style={{ marginBottom: 16 }}>
            <Text style={{ color: colors.textSecondary, fontSize: 13, marginBottom: 6 }}>{label}</Text>
            <TextInput value={value} onChangeText={setter} placeholder={placeholder} placeholderTextColor={colors.textMuted} keyboardType={(keyboard as any) ?? 'default'} style={{ backgroundColor: colors.backgroundElevated, color: colors.textPrimary, borderRadius: 12, padding: 16, fontSize: 16 }} />
          </View>
        ))}
        <View style={{ marginBottom: 32 }}>
          <Text style={{ color: colors.textSecondary, fontSize: 13, marginBottom: 6 }}>Description</Text>
          <TextInput value={description} onChangeText={setDescription} placeholder="Describe what needs to be done..." placeholderTextColor={colors.textMuted} multiline numberOfLines={4} style={{ backgroundColor: colors.backgroundElevated, color: colors.textPrimary, borderRadius: 12, padding: 16, fontSize: 16, minHeight: 100, textAlignVertical: 'top' }} />
        </View>
        <TouchableOpacity style={{ backgroundColor: colors.brandPurple, borderRadius: 16, padding: 18, alignItems: 'center' }}>
          <Text style={{ color: colors.textPrimary, fontSize: 17, fontWeight: '700' }}>Post Task</Text>
        </TouchableOpacity>
      </ScrollView>
    </KeyboardAvoidingView>
  );
}
```

Create remaining stubs `app/(poster)/active-tasks.tsx`, `app/(poster)/history.tsx`, `app/(poster)/profile.tsx`, `app/(poster)/task/[id].tsx`, `app/(poster)/asap-task.tsx`, `app/(poster)/ai-task.tsx` as simple placeholder screens following the same pattern (View + Text with route-appropriate copy).

**Step 4: Commit**
```bash
git add app/(poster)/
git commit -m "feat: Poster tab shell — home, create-task, active, history, profile"
```

---

## Task 11: Shared + Settings + Edge Screens

**Files:**
- Create: `app/(shared)/messages/index.tsx`
- Create: `app/(shared)/messages/[id].tsx`
- Create: `app/(shared)/dispute/[id].tsx`
- Create: `app/(shared)/notifications.tsx`
- Create: `app/(settings)/_layout.tsx`
- Create: `app/(settings)/index.tsx`
- Create: `app/(edge)/maintenance.tsx`
- Create: `app/(edge)/network-error.tsx`
- Create: `app/(edge)/force-update.tsx`

**Step 1: Create MessagesInboxScreen**

Create `app/(shared)/messages/index.tsx`:
```tsx
import { View, Text, FlatList, TouchableOpacity } from 'react-native';
import { useRouter } from 'expo-router';
import { colors } from '@/design/tokens';

const PLACEHOLDER_CONVOS = [
  { id: '1', name: 'Marcus T.', preview: 'On my way!', time: '2m ago', unread: 1 },
  { id: '2', name: 'Sarah K.', preview: 'Task completed ✓', time: '1h ago', unread: 0 },
];

export default function MessagesInboxScreen() {
  const router = useRouter();
  return (
    <View style={{ flex: 1, backgroundColor: colors.brandBlack }}>
      <Text style={{ color: colors.textPrimary, fontSize: 24, fontWeight: '700', padding: 24, paddingTop: 60 }}>Messages</Text>
      <FlatList
        data={PLACEHOLDER_CONVOS}
        keyExtractor={(i) => i.id}
        renderItem={({ item }) => (
          <TouchableOpacity
            onPress={() => router.push(`/(shared)/messages/${item.id}`)}
            style={{ flexDirection: 'row', alignItems: 'center', padding: 16, borderBottomWidth: 1, borderBottomColor: colors.borderSubtle }}
          >
            <View style={{ width: 48, height: 48, backgroundColor: colors.brandPurple, borderRadius: 24, marginRight: 12, justifyContent: 'center', alignItems: 'center' }}>
              <Text style={{ color: colors.textPrimary, fontWeight: '700', fontSize: 16 }}>{item.name[0]}</Text>
            </View>
            <View style={{ flex: 1 }}>
              <Text style={{ color: colors.textPrimary, fontWeight: '600' }}>{item.name}</Text>
              <Text style={{ color: colors.textMuted, fontSize: 13 }}>{item.preview}</Text>
            </View>
            <View style={{ alignItems: 'flex-end' }}>
              <Text style={{ color: colors.textMuted, fontSize: 12 }}>{item.time}</Text>
              {item.unread > 0 && (
                <View style={{ backgroundColor: colors.brandPurple, borderRadius: 10, width: 20, height: 20, justifyContent: 'center', alignItems: 'center', marginTop: 4 }}>
                  <Text style={{ color: '#fff', fontSize: 11, fontWeight: '700' }}>{item.unread}</Text>
                </View>
              )}
            </View>
          </TouchableOpacity>
        )}
      />
    </View>
  );
}
```

**Step 2: Create SettingsMain screen**

Create `app/(settings)/_layout.tsx`:
```tsx
import { Stack } from 'expo-router';
export default function SettingsLayout() {
  return <Stack screenOptions={{ headerShown: false, contentStyle: { backgroundColor: '#0B0B0F' }, animation: 'slide_from_right' }} />;
}
```

Create `app/(settings)/index.tsx`:
```tsx
import { View, Text, TouchableOpacity, ScrollView } from 'react-native';
import { useRouter } from 'expo-router';
import { signOut } from '@/lib/firebase';
import { colors } from '@/design/tokens';

const SECTIONS = [
  { title: 'Account', route: '/(settings)/account', icon: '👤' },
  { title: 'Payment', route: '/(settings)/payment', icon: '💳' },
  { title: 'Notifications', route: '/(settings)/notifications', icon: '🔔' },
  { title: 'Privacy', route: '/(settings)/privacy', icon: '🔒' },
  { title: 'Subscription', route: '/(settings)/subscription', icon: '⭐️' },
  { title: 'Verification', route: '/(settings)/verification', icon: '✓' },
  { title: 'Help', route: '/(settings)/help', icon: '❓' },
];

export default function SettingsMainScreen() {
  const router = useRouter();
  return (
    <ScrollView style={{ flex: 1, backgroundColor: colors.brandBlack }} contentContainerStyle={{ padding: 24, paddingBottom: 60 }}>
      <TouchableOpacity onPress={() => router.back()} style={{ marginTop: 60, marginBottom: 24 }}>
        <Text style={{ color: colors.brandPurpleLight }}>← Back</Text>
      </TouchableOpacity>
      <Text style={{ color: colors.textPrimary, fontSize: 28, fontWeight: '700', marginBottom: 32 }}>Settings</Text>
      {SECTIONS.map(({ title, route, icon }) => (
        <TouchableOpacity
          key={title}
          onPress={() => router.push(route as any)}
          style={{ flexDirection: 'row', alignItems: 'center', backgroundColor: colors.backgroundElevated, borderRadius: 12, padding: 16, marginBottom: 8 }}
        >
          <Text style={{ fontSize: 22, marginRight: 14 }}>{icon}</Text>
          <Text style={{ color: colors.textPrimary, fontSize: 16, flex: 1 }}>{title}</Text>
          <Text style={{ color: colors.textMuted }}>›</Text>
        </TouchableOpacity>
      ))}
      <TouchableOpacity
        onPress={async () => { await signOut(); }}
        style={{ backgroundColor: colors.errorRed, borderRadius: 12, padding: 16, alignItems: 'center', marginTop: 24 }}
      >
        <Text style={{ color: colors.textPrimary, fontWeight: '700' }}>Sign Out</Text>
      </TouchableOpacity>
    </ScrollView>
  );
}
```

**Step 3: Create edge screens**

Create `app/(edge)/maintenance.tsx`:
```tsx
import { View, Text } from 'react-native';
import { colors } from '@/design/tokens';
export default function MaintenanceScreen() {
  return (
    <View style={{ flex: 1, backgroundColor: colors.brandBlack, justifyContent: 'center', alignItems: 'center', padding: 40 }}>
      <Text style={{ fontSize: 64, marginBottom: 24 }}>🔧</Text>
      <Text style={{ color: colors.textPrimary, fontSize: 24, fontWeight: '700', marginBottom: 8, textAlign: 'center' }}>Down for Maintenance</Text>
      <Text style={{ color: colors.textMuted, textAlign: 'center', lineHeight: 24 }}>We'll be back shortly. Thanks for your patience.</Text>
    </View>
  );
}
```

Create `app/(edge)/network-error.tsx`:
```tsx
import { View, Text, TouchableOpacity } from 'react-native';
import { colors } from '@/design/tokens';
export default function NetworkErrorScreen() {
  return (
    <View style={{ flex: 1, backgroundColor: colors.brandBlack, justifyContent: 'center', alignItems: 'center', padding: 40 }}>
      <Text style={{ fontSize: 64, marginBottom: 24 }}>📡</Text>
      <Text style={{ color: colors.textPrimary, fontSize: 24, fontWeight: '700', marginBottom: 8 }}>No Connection</Text>
      <Text style={{ color: colors.textMuted, textAlign: 'center', marginBottom: 32 }}>Check your internet and try again.</Text>
      <TouchableOpacity style={{ backgroundColor: colors.brandPurple, borderRadius: 14, paddingHorizontal: 32, paddingVertical: 14 }}>
        <Text style={{ color: colors.textPrimary, fontWeight: '700' }}>Retry</Text>
      </TouchableOpacity>
    </View>
  );
}
```

Create `app/(edge)/force-update.tsx`:
```tsx
import { View, Text, TouchableOpacity, Linking } from 'react-native';
import { colors } from '@/design/tokens';
export default function ForceUpdateScreen() {
  return (
    <View style={{ flex: 1, backgroundColor: colors.brandBlack, justifyContent: 'center', alignItems: 'center', padding: 40 }}>
      <Text style={{ fontSize: 64, marginBottom: 24 }}>⬆️</Text>
      <Text style={{ color: colors.textPrimary, fontSize: 24, fontWeight: '700', marginBottom: 8 }}>Update Required</Text>
      <Text style={{ color: colors.textMuted, textAlign: 'center', marginBottom: 32 }}>A new version of HustleXP is available and required to continue.</Text>
      <TouchableOpacity
        onPress={() => Linking.openURL('https://apps.apple.com')}
        style={{ backgroundColor: colors.brandPurple, borderRadius: 14, paddingHorizontal: 32, paddingVertical: 14 }}
      >
        <Text style={{ color: colors.textPrimary, fontWeight: '700' }}>Update Now</Text>
      </TouchableOpacity>
    </View>
  );
}
```

**Step 4: Commit**
```bash
git add app/(shared)/ app/(settings)/ app/(edge)/
git commit -m "feat: shared screens (messages, settings), edge screens (maintenance, network, force-update)"
```

---

## Task 12: Revolut-Grade Animations

**Files:**
- Create: `src/animations/RankUpView.tsx`
- Create: `src/animations/XPBurstView.tsx`
- Create: `src/animations/constants.ts`

**Step 1: Create animation constants**

Create `src/animations/constants.ts`:
```ts
import { Easing } from 'react-native-reanimated';

// Revolut motion design language — iron law
// ease-out only, no springs, no bounce, no overshoot
// max 1 focal point, max 5 elements, max 1 ring, no particles
export const EASE_OUT = Easing.bezier(0.22, 0, 0.36, 1);

export const t = (duration: number) => ({ duration, easing: EASE_OUT });
```

**Step 2: Create RankUpView (port of RankUpView.swift)**

Create `src/animations/RankUpView.tsx`:
```tsx
import { useEffect } from 'react';
import { View, Text, StyleSheet, Dimensions } from 'react-native';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withTiming,
  withDelay,
  withSequence,
  runOnJS,
} from 'react-native-reanimated';
import { Canvas, Path, Skia, LinearGradient, vec, Group, ClipPath } from '@shopify/react-native-skia';
import { colors } from '@/design/tokens';
import { EASE_OUT, t } from './constants';

const { width, height } = Dimensions.get('window');
const CX = width / 2;
const CY = height * 0.42;

interface Props {
  tier: string;
  onComplete: () => void;
}

// Shield path scaled to 120×136 canvas (matching Swift ShieldShape)
const SHIELD_PATH = 'M60,0 L120,24 L120,80 Q120,120 60,136 Q0,120 0,80 L0,24 Z';

export function RankUpView({ tier, onComplete }: Props) {
  const overlayOpacity = useSharedValue(0);
  const glowOpacity = useSharedValue(0);
  const badgeScale = useSharedValue(0.85);
  const badgeOpacity = useSharedValue(0);
  const badgeY = useSharedValue(6);
  const ringRadius = useSharedValue(64);
  const ringOpacity = useSharedValue(0);
  const rankLabelOpacity = useSharedValue(0);
  const tierLabelOpacity = useSharedValue(0);

  useEffect(() => {
    // t=0: overlay in
    overlayOpacity.value = withTiming(1, t(250));

    // t=200: glow in
    glowOpacity.value = withDelay(200, withTiming(0.28, t(450)));

    // t=300: badge entrance
    badgeOpacity.value = withDelay(300, withTiming(1, t(450)));
    badgeScale.value = withDelay(300, withTiming(1, t(450)));
    badgeY.value = withDelay(300, withTiming(0, t(450)));

    // t=550: ring expand
    ringOpacity.value = withDelay(550, withTiming(0.35, t(100)));
    ringRadius.value = withDelay(550, withTiming(105, t(600)));

    // t=650: rank label
    rankLabelOpacity.value = withDelay(650, withTiming(0.45, t(300)));

    // t=780: tier label
    tierLabelOpacity.value = withDelay(780, withTiming(1, t(350)));

    // t=2300: all out
    overlayOpacity.value = withDelay(2300, withTiming(0, t(300)));
    glowOpacity.value = withDelay(2300, withTiming(0, t(300)));
    badgeOpacity.value = withDelay(2300, withTiming(0, t(300)));
    rankLabelOpacity.value = withDelay(2300, withTiming(0, t(300)));
    tierLabelOpacity.value = withDelay(2300, withTiming(0, t(300)));
    ringOpacity.value = withDelay(2300, withTiming(0, t(300)));

    // t=2800: callback
    const timer = setTimeout(() => onComplete(), 2800);
    return () => clearTimeout(timer);
  }, []);

  const overlayStyle = useAnimatedStyle(() => ({ opacity: overlayOpacity.value }));
  const badgeStyle = useAnimatedStyle(() => ({
    opacity: badgeOpacity.value,
    transform: [{ scale: badgeScale.value }, { translateY: badgeY.value }],
  }));
  const rankStyle = useAnimatedStyle(() => ({ opacity: rankLabelOpacity.value }));
  const tierStyle = useAnimatedStyle(() => ({ opacity: tierLabelOpacity.value }));

  // Skia shield path
  const skiaPath = Skia.Path.MakeFromSVGString(SHIELD_PATH)!;

  return (
    <Animated.View style={[StyleSheet.absoluteFill, styles.container, overlayStyle]}>
      {/* Ambient glow — Skia circle */}
      <Canvas style={StyleSheet.absoluteFill} pointerEvents="none">
        <Group opacity={glowOpacity.value}>
          {/* Glow circle via blur would need Skia blur filter — simplified as opacity */}
        </Group>
      </Canvas>

      {/* Badge */}
      <Animated.View style={[{ position: 'absolute', top: CY - 68, left: CX - 60 }, badgeStyle]}>
        <Canvas style={{ width: 120, height: 136 }}>
          <Path path={skiaPath}>
            <LinearGradient
              start={vec(60, 0)}
              end={vec(60, 136)}
              colors={['#6E3FFF', '#3A18CC']}
            />
          </Path>
        </Canvas>
        {/* Crown emoji overlay */}
        <Text style={{ position: 'absolute', top: 52, left: 0, right: 0, textAlign: 'center', fontSize: 28 }}>👑</Text>
      </Animated.View>

      {/* Typography */}
      <Animated.Text style={[styles.rankLabel, { top: CY + 80 }, rankStyle]}>
        RANK ACHIEVED
      </Animated.Text>
      <Animated.Text style={[styles.tierLabel, { top: CY + 106 }, tierStyle]}>
        {tier}
      </Animated.Text>
    </Animated.View>
  );
}

const styles = StyleSheet.create({
  container: {
    backgroundColor: 'rgba(11,11,15,0.92)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  rankLabel: {
    position: 'absolute',
    left: 0,
    right: 0,
    textAlign: 'center',
    color: 'rgba(255,255,255,0.45)',
    fontSize: 11,
    fontWeight: '600',
    letterSpacing: 4,
  },
  tierLabel: {
    position: 'absolute',
    left: 0,
    right: 0,
    textAlign: 'center',
    color: colors.xpGold,
    fontSize: 32,
    fontWeight: '700',
    letterSpacing: 8,
  },
});
```

**Step 3: Create XPBurstView (Revolut-grade rebuild)**

Create `src/animations/XPBurstView.tsx`:
```tsx
import { useEffect } from 'react';
import { View, Text, StyleSheet } from 'react-native';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withTiming,
  withDelay,
} from 'react-native-reanimated';
import { colors } from '@/design/tokens';
import { t } from './constants';

interface Props {
  xpAmount: number;
  onComplete: () => void;
}

// Revolut-grade XP burst: 5 elements max, single focal point, ease-out only
// Elements: dark overlay, ambient ring, XP number, label, pulse ring
export function XPBurstView({ xpAmount, onComplete }: Props) {
  const overlayOpacity = useSharedValue(0);
  const ringScale = useSharedValue(0.6);
  const ringOpacity = useSharedValue(0);
  const numberOpacity = useSharedValue(0);
  const numberScale = useSharedValue(0.8);
  const labelOpacity = useSharedValue(0);

  useEffect(() => {
    overlayOpacity.value = withTiming(1, t(200));
    ringOpacity.value = withDelay(100, withTiming(0.3, t(400)));
    ringScale.value = withDelay(100, withTiming(1, t(600)));
    numberOpacity.value = withDelay(250, withTiming(1, t(350)));
    numberScale.value = withDelay(250, withTiming(1, t(350)));
    labelOpacity.value = withDelay(400, withTiming(0.7, t(300)));

    // Fade out at t=1400
    overlayOpacity.value = withDelay(1400, withTiming(0, t(300)));
    ringOpacity.value = withDelay(1400, withTiming(0, t(300)));
    numberOpacity.value = withDelay(1400, withTiming(0, t(300)));
    labelOpacity.value = withDelay(1400, withTiming(0, t(300)));

    const timer = setTimeout(onComplete, 1800);
    return () => clearTimeout(timer);
  }, []);

  const overlayStyle = useAnimatedStyle(() => ({ opacity: overlayOpacity.value }));
  const ringStyle = useAnimatedStyle(() => ({ opacity: ringOpacity.value, transform: [{ scale: ringScale.value }] }));
  const numberStyle = useAnimatedStyle(() => ({ opacity: numberOpacity.value, transform: [{ scale: numberScale.value }] }));
  const labelStyle = useAnimatedStyle(() => ({ opacity: labelOpacity.value }));

  return (
    <Animated.View style={[StyleSheet.absoluteFill, styles.container, overlayStyle]} pointerEvents="none">
      {/* Element 1: ambient ring */}
      <Animated.View style={[styles.ring, ringStyle]} />

      {/* Element 2: XP number */}
      <Animated.Text style={[styles.xpNumber, numberStyle]}>
        +{xpAmount}
      </Animated.Text>

      {/* Element 3: XP label */}
      <Animated.Text style={[styles.xpLabel, labelStyle]}>
        XP
      </Animated.Text>
    </Animated.View>
  );
}

const styles = StyleSheet.create({
  container: {
    backgroundColor: 'rgba(11,11,15,0.7)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  ring: {
    position: 'absolute',
    width: 200,
    height: 200,
    borderRadius: 100,
    borderWidth: 1,
    borderColor: colors.brandPurple,
  },
  xpNumber: {
    color: colors.xpGold,
    fontSize: 72,
    fontWeight: '700',
    letterSpacing: -2,
  },
  xpLabel: {
    color: 'rgba(255,215,0,0.7)',
    fontSize: 18,
    fontWeight: '600',
    letterSpacing: 6,
    marginTop: 4,
  },
});
```

**Step 4: Commit**
```bash
git add src/animations/
git commit -m "feat: Revolut-grade animations — RankUpView (Skia shield) + XPBurstView (Reanimated 3)"
```

---

## Task 13: Push to GitHub + Verify Build

**Step 1: Final push**
```bash
cd ~/HustleXP/hustlexp-rn
git push origin main
```

**Step 2: Verify TypeScript**
```bash
npx tsc --noEmit
```
Expected: 0 errors

**Step 3: Verify Metro starts**
```bash
npx expo start --clear
```
Expected: Metro bundler starts, QR code shown, no import errors

**Step 4: Verify iOS build (simulator)**
```bash
npx expo run:ios
```
Expected: App launches on iOS simulator, renders LoginScreen with HustleXP branding

**Step 5: Verify Android build (emulator)**
```bash
npx expo run:android
```
Expected: App launches on Android emulator, same LoginScreen

**Step 6: Final commit**
```bash
git add -A
git commit -m "feat: full Phase 1-4 React Native scaffold — 65 screens, Revolut animations, EAS configured"
git push
```

---

## Summary

After completing all 13 tasks:

- ✅ New GitHub repo `Sebdysart/hustlexp-rn`
- ✅ Expo SDK 52 bare workflow, TypeScript strict
- ✅ All 65 screens built (functional stubs + fully wired auth + onboarding)
- ✅ Design tokens ported 1:1 from ColorTokens.swift
- ✅ Revolut motion language in Reanimated 3 (RankUpView + XPBurstView)
- ✅ tRPC client wired to Railway backend
- ✅ Firebase Auth with auth gate
- ✅ EAS Build configured (dev/preview/production)
- ✅ GitHub Actions CI (type-check + lint)
- ✅ iOS + Android verified

**Phase 2 (next sprint):** Wire all placeholder tRPC calls with real data using `trpc.router.procedure.useQuery/useMutation` patterns throughout all screens.
