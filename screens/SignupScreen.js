/**
 * SignupScreen - User registration
 * 
 * SPEC COMPLIANCE:
 * - A4: Touch targets minimum 44px
 * - C3: No gradients on buttons
 * - BUILD_GUIDE: user_type (hustler/client), email, full_name required
 */

import React, { useState } from 'react';
import { 
  View, 
  StyleSheet, 
  SafeAreaView, 
  KeyboardAvoidingView,
  Platform,
  TouchableOpacity,
  ScrollView,
} from 'react-native';
import { HXText } from '../components/Text';
import { Button } from '../components/Button';
import { Input } from '../components/Input';
import { Card } from '../components/Card';
import { COLORS, GRAY } from '../constants/colors';
import { SPACING } from '../constants/spacing';

export function SignupScreen({ navigation }) {
  const [fullName, setFullName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [userType, setUserType] = useState('hustler'); // 'hustler' or 'client'
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const handleSignup = async () => {
    setError('');
    
    if (!fullName || !email || !password || !confirmPassword) {
      setError('Please fill in all fields');
      return;
    }
    
    if (password !== confirmPassword) {
      setError('Passwords do not match');
      return;
    }
    
    if (password.length < 8) {
      setError('Password must be at least 8 characters');
      return;
    }
    
    setLoading(true);
    
    // TODO: Implement actual signup logic
    setTimeout(() => {
      setLoading(false);
    }, 1500);
  };

  return (
    <SafeAreaView style={styles.container}>
      <KeyboardAvoidingView 
        behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
        style={styles.keyboardView}
      >
        <ScrollView 
          contentContainerStyle={styles.scrollContent}
          showsVerticalScrollIndicator={false}
        >
          {/* Header */}
          <View style={styles.header}>
            <HXText variant="h1">Create Account</HXText>
            <HXText variant="body" color="secondary" style={styles.subtitle}>
              Join the hustle
            </HXText>
          </View>

          {/* User Type Selection */}
          <View style={styles.typeContainer}>
            <HXText variant="label" style={styles.typeLabel}>I want to:</HXText>
            <View style={styles.typeButtons}>
              <TouchableOpacity
                style={[
                  styles.typeButton,
                  userType === 'hustler' && styles.typeButtonActive,
                ]}
                onPress={() => setUserType('hustler')}
              >
                <HXText 
                  variant="body" 
                  weight={userType === 'hustler' ? 'semibold' : 'regular'}
                  style={userType === 'hustler' ? styles.typeTextActive : null}
                >
                  Earn (Hustler)
                </HXText>
              </TouchableOpacity>
              <TouchableOpacity
                style={[
                  styles.typeButton,
                  userType === 'client' && styles.typeButtonActive,
                ]}
                onPress={() => setUserType('client')}
              >
                <HXText 
                  variant="body"
                  weight={userType === 'client' ? 'semibold' : 'regular'}
                  style={userType === 'client' ? styles.typeTextActive : null}
                >
                  Post Tasks (Client)
                </HXText>
              </TouchableOpacity>
            </View>
          </View>

          {/* Form */}
          <Card variant="outlined" style={styles.formCard}>
            {error ? (
              <HXText variant="bodySmall" color="error" style={styles.error}>
                {error}
              </HXText>
            ) : null}

            <Input
              label="Full Name"
              value={fullName}
              onChangeText={setFullName}
              placeholder="Your full name"
              autoComplete="name"
            />

            <Input
              label="Email"
              value={email}
              onChangeText={setEmail}
              placeholder="your@email.com"
              keyboardType="email-address"
              autoCapitalize="none"
              autoComplete="email"
              style={styles.inputSpacing}
            />

            <Input
              label="Password"
              value={password}
              onChangeText={setPassword}
              placeholder="Min 8 characters"
              secureTextEntry
              autoComplete="new-password"
              style={styles.inputSpacing}
            />

            <Input
              label="Confirm Password"
              value={confirmPassword}
              onChangeText={setConfirmPassword}
              placeholder="Re-enter password"
              secureTextEntry
              autoComplete="new-password"
              style={styles.inputSpacing}
            />

            <Button
              title="Create Account"
              onPress={handleSignup}
              loading={loading}
              style={styles.submitButton}
            />
          </Card>

          {/* Login Link */}
          <View style={styles.loginContainer}>
            <HXText variant="body" color="secondary">
              Already have an account?{' '}
            </HXText>
            <TouchableOpacity onPress={() => navigation.navigate('Login')}>
              <HXText variant="body" weight="semibold" style={{ color: GRAY[900] }}>
                Sign In
              </HXText>
            </TouchableOpacity>
          </View>
        </ScrollView>
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
  scrollContent: {
    flexGrow: 1,
    padding: SPACING[4],
    justifyContent: 'center',
  },
  header: {
    alignItems: 'center',
    marginBottom: SPACING[6],
  },
  subtitle: {
    marginTop: SPACING[2],
  },
  typeContainer: {
    marginBottom: SPACING[4],
  },
  typeLabel: {
    marginBottom: SPACING[2],
  },
  typeButtons: {
    flexDirection: 'row',
    gap: SPACING[3],
  },
  typeButton: {
    flex: 1,
    paddingVertical: SPACING[3],
    paddingHorizontal: SPACING[4],
    borderRadius: 8,
    borderWidth: 1,
    borderColor: GRAY[300],
    alignItems: 'center',
    // A4: Touch target minimum 44px
    minHeight: 48,
    justifyContent: 'center',
  },
  typeButtonActive: {
    borderColor: GRAY[900],
    backgroundColor: GRAY[100],
  },
  typeTextActive: {
    color: GRAY[900],
  },
  formCard: {
    padding: SPACING[4],
  },
  error: {
    marginBottom: SPACING[3],
    textAlign: 'center',
  },
  inputSpacing: {
    marginTop: SPACING[3],
  },
  submitButton: {
    marginTop: SPACING[4],
  },
  loginContainer: {
    flexDirection: 'row',
    justifyContent: 'center',
    marginTop: SPACING[6],
  },
});

export default SignupScreen;
