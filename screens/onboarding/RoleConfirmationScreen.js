/**
 * RoleConfirmationScreen - Authority Confirmation (HARDENED)
 * 
 * GAP 1 FIX: Different UI behavior per certainty tier
 * - STRONG: "We'll set you up as..." (current flow)
 * - MODERATE: Softer copy, still inferential
 * - WEAK: Force explicit choice, log ambiguity
 */

import React, { useState } from 'react';
import { 
  View, 
  StyleSheet, 
  SafeAreaView,
  TouchableOpacity,
} from 'react-native';
import { HXText } from '../../components/Text';
import { Button } from '../../components/Button';
import { COLORS, GRAY } from '../../constants/colors';
import { SPACING } from '../../constants/spacing';
import { 
  computeRoleConfidence,
  inferRole,
  getConfirmationCopy,
  UserRole,
  RoleCertainty,
} from '../../state/OnboardingStateMachine';

export function RoleConfirmationScreen({ navigation, route }) {
  const { context, responses } = route.params;
  
  const [roleConfidence] = useState(() => computeRoleConfidence(context, responses));
  const [inferredRole] = useState(() => inferRole(roleConfidence));
  const [confirmationCopy] = useState(() => 
    getConfirmationCopy(roleConfidence.certaintyTier, inferredRole)
  );
  
  // GAP 1: WEAK certainty forces explicit choice from start
  const [selectedRole, setSelectedRole] = useState(
    confirmationCopy.requiresExplicitChoice ? null : inferredRole
  );
  const [showAdjust, setShowAdjust] = useState(
    confirmationCopy.requiresExplicitChoice
  );

  const roleDisplay = {
    [UserRole.WORKER]: {
      title: 'Worker',
      description: 'Earn by completing tasks',
    },
    [UserRole.POSTER]: {
      title: 'Poster', 
      description: 'Get things done by others',
    },
  };

  const handleContinue = () => {
    if (!selectedRole) return; // Can't continue without selection
    
    const roleOverride = selectedRole !== inferredRole ? selectedRole : null;
    navigation.replace('PreferenceLock', {
      context,
      responses,
      roleOverride,
      certaintyTier: roleConfidence.certaintyTier,
      inconsistencyFlags: roleConfidence.inconsistencies?.flags || [],
    });
  };

  const handleToggleRole = (role) => {
    setSelectedRole(role);
  };

  // GAP 2: Show warning if inconsistencies detected
  const hasInconsistencies = roleConfidence.inconsistencies?.hasInconsistencies;

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.content}>
        {/* Header - copy varies by certainty tier */}
        <View style={styles.headerContainer}>
          {roleConfidence.certaintyTier !== RoleCertainty.WEAK && (
            <HXText variant="body" color="secondary" style={styles.subtitle}>
              Based on your responses
            </HXText>
          )}
          <HXText variant="h2" style={styles.title}>
            {confirmationCopy.headline}
          </HXText>
          {confirmationCopy.subtext && (
            <HXText variant="body" color="secondary" style={styles.subtext}>
              {confirmationCopy.subtext}
            </HXText>
          )}
        </View>

        {/* Role display - only show if not forcing explicit choice */}
        {!confirmationCopy.requiresExplicitChoice && selectedRole && (
          <View style={styles.roleContainer}>
            <HXText variant="h1" style={styles.roleTitle}>
              {roleDisplay[selectedRole].title}
            </HXText>
            <HXText variant="body" color="secondary">
              {roleDisplay[selectedRole].description}
            </HXText>
          </View>
        )}

        {/* Confidence indicator - subtle, hide for WEAK */}
        {roleConfidence.certaintyTier !== RoleCertainty.WEAK && 
         roleConfidence.confidence > 0.3 && (
          <View style={styles.confidenceContainer}>
            <View style={styles.confidenceBar}>
              <View 
                style={[
                  styles.confidenceFill, 
                  { 
                    width: `${Math.max(roleConfidence.worker, roleConfidence.poster) * 100}%`,
                    backgroundColor: roleConfidence.certaintyTier === RoleCertainty.STRONG 
                      ? GRAY[600] 
                      : GRAY[400],
                  }
                ]} 
              />
            </View>
          </View>
        )}

        {/* GAP 2: Inconsistency notice (subtle) */}
        {hasInconsistencies && (
          <View style={styles.inconsistencyNotice}>
            <HXText variant="caption" color="secondary">
              Your responses showed mixed signals — that's okay, most people use both sides.
            </HXText>
          </View>
        )}

        {/* Role selection - always show for WEAK, toggle for others */}
        {!showAdjust && !confirmationCopy.requiresExplicitChoice ? (
          <TouchableOpacity 
            style={styles.adjustButton}
            onPress={() => setShowAdjust(true)}
          >
            <HXText variant="bodySmall" color="secondary">
              Adjust role
            </HXText>
          </TouchableOpacity>
        ) : (
          <View style={styles.roleToggleContainer}>
            <TouchableOpacity
              style={[
                styles.roleOption,
                selectedRole === UserRole.WORKER && styles.roleOptionSelected,
              ]}
              onPress={() => handleToggleRole(UserRole.WORKER)}
            >
              <HXText 
                variant="body" 
                weight={selectedRole === UserRole.WORKER ? 'semibold' : 'regular'}
              >
                Worker
              </HXText>
              <HXText variant="caption" color="secondary">
                Earn by completing tasks
              </HXText>
            </TouchableOpacity>
            <TouchableOpacity
              style={[
                styles.roleOption,
                selectedRole === UserRole.POSTER && styles.roleOptionSelected,
              ]}
              onPress={() => handleToggleRole(UserRole.POSTER)}
            >
              <HXText 
                variant="body"
                weight={selectedRole === UserRole.POSTER ? 'semibold' : 'regular'}
              >
                Poster
              </HXText>
              <HXText variant="caption" color="secondary">
                Get things done
              </HXText>
            </TouchableOpacity>
          </View>
        )}

        {/* Continue */}
        <View style={styles.actionContainer}>
          <Button
            title="Continue"
            onPress={handleContinue}
            size="lg"
            disabled={!selectedRole}
          />
          <HXText variant="caption" color="secondary" style={styles.switchNote}>
            You can switch anytime in settings
          </HXText>
        </View>
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: COLORS.background,
  },
  content: {
    flex: 1,
    paddingHorizontal: SPACING[6],
    justifyContent: 'center',
  },
  headerContainer: {
    alignItems: 'center',
    marginBottom: SPACING[2],
  },
  subtitle: {
    marginBottom: SPACING[1],
  },
  title: {
    textAlign: 'center',
  },
  subtext: {
    textAlign: 'center',
    marginTop: SPACING[2],
  },
  roleContainer: {
    alignItems: 'center',
    marginVertical: SPACING[6],
  },
  roleTitle: {
    fontSize: 48,
    marginBottom: SPACING[2],
  },
  confidenceContainer: {
    paddingHorizontal: SPACING[8],
    marginBottom: SPACING[4],
  },
  confidenceBar: {
    height: 4,
    backgroundColor: GRAY[200],
    borderRadius: 2,
  },
  confidenceFill: {
    height: 4,
    borderRadius: 2,
  },
  inconsistencyNotice: {
    paddingHorizontal: SPACING[4],
    paddingVertical: SPACING[3],
    backgroundColor: GRAY[50],
    borderRadius: 8,
    marginBottom: SPACING[4],
  },
  adjustButton: {
    alignSelf: 'center',
    paddingVertical: SPACING[3],
    paddingHorizontal: SPACING[4],
    marginBottom: SPACING[6],
  },
  roleToggleContainer: {
    flexDirection: 'row',
    gap: SPACING[3],
    marginBottom: SPACING[6],
  },
  roleOption: {
    flex: 1,
    paddingVertical: SPACING[4],
    paddingHorizontal: SPACING[3],
    borderRadius: 12,
    borderWidth: 1,
    borderColor: GRAY[300],
    alignItems: 'center',
    minHeight: 80, // A4: ≥44px
    justifyContent: 'center',
  },
  roleOptionSelected: {
    borderColor: GRAY[900],
    backgroundColor: GRAY[100],
  },
  actionContainer: {
    marginTop: SPACING[4],
  },
  switchNote: {
    textAlign: 'center',
    marginTop: SPACING[3],
  },
});

export default RoleConfirmationScreen;
