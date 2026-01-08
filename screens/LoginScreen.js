/**
 * LoginScreen - User login
 * 
 * SPEC COMPLIANCE:
 * - A4: Touch targets minimum 44px (using Button component)
 * - C3: No gradients on buttons
 * - A2: Focus states visible on inputs
 */

import React, { useState } from 'react';
import { 
  View, 
  StyleSheet, 
  SafeAreaView, 
  KeyboardAvoidingView,
  Platform,
  TouchableOpacity,
} from 'react-native';
import { HXText } from '../components/Text';
import { Button } from '../components/Button';
import { Input } from '../components/Input';
import { Card } from '../components/Card';
import { COLORS, GRAY } from '../constants/colors';
import { SPACING } from '../constants/spacing';

export function LoginScreen({ navigation }) {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const handleLogin = async () => {
    setError('');
    
    if (!email || !password) {
      setError('Please fill in all fields');
      return;
    }
    
    setLoading(true);
    
    // TODO: Implement actual auth logic
    // For now, simulate login
    setTimeout(() => {
      setLoading(false);
      // Navigate to main app on success
      // navigation.replace('Main');
    }, 1500);
  };

  return (
    <SafeAreaView style={styles.container}>
      <KeyboardAvoidingView 
        behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
        style={styles.keyboardView}
      >
        <View style={styles.content}>
          {/* Header */}
          <View style={styles.header}>
            <HXText variant="h1">HustleXP</HXText>
            <HXText variant="body" color="secondary" style={styles.subtitle}>
              Sign in to continue
            </HXText>
          </View>

          {/* Form */}
          <Card variant="outlined" style={styles.formCard}>
            {error ? (
              <HXText variant="bodySmall" color="error" style={styles.error}>
                {error}
              </HXText>
            ) : null}

            <Input
              label="Email"
              value={email}
              onChangeText={setEmail}
              placeholder="your@email.com"
              keyboardType="email-address"
              autoCapitalize="none"
              autoComplete="email"
            />

            <Input
              label="Password"
              value={password}
              onChangeText={setPassword}
              placeholder="Enter password"
              secureTextEntry
              autoComplete="password"
              style={styles.passwordInput}
            />

            <TouchableOpacity 
              onPress={() => navigation.navigate('ForgotPassword')}
              style={styles.forgotButton}
            >
              <HXText variant="bodySmall" color="secondary">
                Forgot password?
              </HXText>
            </TouchableOpacity>

            <Button
              title="Sign In"
              onPress={handleLogin}
              loading={loading}
              style={styles.submitButton}
            />
          </Card>

          {/* Sign Up Link */}
          <View style={styles.signupContainer}>
            <HXText variant="body" color="secondary">
              Don't have an account?{' '}
            </HXText>
            <TouchableOpacity onPress={() => navigation.navigate('Signup')}>
              <HXText variant="body" weight="semibold" style={{ color: GRAY[900] }}>
                Sign Up
              </HXText>
            </TouchableOpacity>
          </View>
        </View>
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: COLORS.background,
  },
  keyboardView: {
    flex: 1,
  },
  content: {
    flex: 1,
    padding: SPACING[4],
    justifyContent: 'center',
  },
  header: {
    alignItems: 'center',
    marginBottom: SPACING[8],
  },
  subtitle: {
    marginTop: SPACING[2],
  },
  formCard: {
    padding: SPACING[4],
  },
  error: {
    marginBottom: SPACING[3],
    textAlign: 'center',
  },
  passwordInput: {
    marginTop: SPACING[3],
  },
  forgotButton: {
    alignSelf: 'flex-end',
    marginTop: SPACING[2],
    marginBottom: SPACING[4],
    // A4: Touch target padding
    paddingVertical: SPACING[2],
  },
  submitButton: {
    marginTop: SPACING[2],
  },
  signupContainer: {
    flexDirection: 'row',
    justifyContent: 'center',
    marginTop: SPACING[6],
  },
});

export default LoginScreen;
