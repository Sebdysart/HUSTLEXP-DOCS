/**
 * ForgotPasswordScreen - Password reset request
 * 
 * SPEC COMPLIANCE:
 * - A4: Touch targets minimum 44px
 * - C3: No gradients on buttons
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

export function ForgotPasswordScreen({ navigation }) {
  const [email, setEmail] = useState('');
  const [loading, setLoading] = useState(false);
  const [sent, setSent] = useState(false);
  const [error, setError] = useState('');

  const handleReset = async () => {
    setError('');
    
    if (!email) {
      setError('Please enter your email');
      return;
    }
    
    setLoading(true);
    
    // TODO: Implement actual password reset logic
    setTimeout(() => {
      setLoading(false);
      setSent(true);
    }, 1500);
  };

  if (sent) {
    return (
      <SafeAreaView style={styles.container}>
        <View style={styles.content}>
          <View style={styles.successContainer}>
            <HXText variant="h2" style={styles.successTitle}>
              Check Your Email
            </HXText>
            <HXText variant="body" color="secondary" style={styles.successText}>
              We've sent password reset instructions to {email}
            </HXText>
            <Button
              title="Back to Sign In"
              onPress={() => navigation.navigate('Login')}
              style={styles.backButton}
            />
          </View>
        </View>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={styles.container}>
      <KeyboardAvoidingView 
        behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
        style={styles.keyboardView}
      >
        <View style={styles.content}>
          {/* Back Button */}
          <TouchableOpacity 
            onPress={() => navigation.goBack()}
            style={styles.backNav}
          >
            <HXText variant="body" color="secondary">← Back</HXText>
          </TouchableOpacity>

          {/* Header */}
          <View style={styles.header}>
            <HXText variant="h2">Reset Password</HXText>
            <HXText variant="body" color="secondary" style={styles.subtitle}>
              Enter your email and we'll send you reset instructions
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

            <Button
              title="Send Reset Link"
              onPress={handleReset}
              loading={loading}
              style={styles.submitButton}
            />
          </Card>
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
  backNav: {
    position: 'absolute',
    top: SPACING[4],
    left: SPACING[4],
    // A4: Touch target
    paddingVertical: SPACING[2],
    paddingHorizontal: SPACING[2],
  },
  header: {
    marginBottom: SPACING[6],
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
  submitButton: {
    marginTop: SPACING[4],
  },
  successContainer: {
    alignItems: 'center',
  },
  successTitle: {
    marginBottom: SPACING[3],
  },
  successText: {
    textAlign: 'center',
    marginBottom: SPACING[6],
  },
  backButton: {
    width: '100%',
  },
});

export default ForgotPasswordScreen;
