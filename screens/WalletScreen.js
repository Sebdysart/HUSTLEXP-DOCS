/**
 * WalletScreen - Earnings, payouts
 * 
 * SPEC: UI_SPEC.md §2 Color Authority
 * - Money colors (MONEY.held, MONEY.released, MONEY.disputed) 
 *   ONLY for escrow states
 */

import React from 'react';
import { View, StyleSheet, SafeAreaView, ScrollView } from 'react-native';
import { HXText } from '../components/Text';
import { Card } from '../components/Card';
import { Button } from '../components/Button';
import { COLORS, MONEY, GRAY } from '../constants/colors';
import { SPACING } from '../constants/spacing';

export function WalletScreen() {
  return (
    <SafeAreaView style={styles.container}>
      <ScrollView contentContainerStyle={styles.content}>
        <HXText variant="h2">Wallet</HXText>
        <HXText variant="bodySmall" color="secondary" style={styles.subtitle}>
          Your earnings and payouts
        </HXText>

        {/* Balance Card */}
        <Card variant="elevated" style={styles.balanceCard}>
          <HXText variant="caption" color="secondary">AVAILABLE BALANCE</HXText>
          <HXText variant="h1">$0.00</HXText>
          <Button 
            title="Withdraw" 
            disabled 
            style={styles.withdrawButton}
            onPress={() => {}}
          />
        </Card>

        {/* Pending Earnings */}
        <HXText variant="label" color="secondary" style={styles.sectionTitle}>
          PENDING EARNINGS
        </HXText>
        <Card variant="outlined" style={styles.pendingCard}>
          <View style={styles.pendingRow}>
            <HXText variant="body">In Escrow</HXText>
            {/* MONEY.held color for FUNDED escrow state */}
            <HXText variant="body" weight="semibold" style={{ color: MONEY.held }}>
              $0.00
            </HXText>
          </View>
          <HXText variant="caption" color="tertiary" style={styles.pendingHint}>
            Funds held until task completion
          </HXText>
        </Card>

        {/* Transaction History */}
        <HXText variant="label" color="secondary" style={styles.sectionTitle}>
          RECENT TRANSACTIONS
        </HXText>
        <Card variant="outlined" style={styles.historyCard}>
          <HXText variant="body" color="secondary" align="center">
            No transactions yet
          </HXText>
        </Card>

        {/* Payout Settings */}
        <HXText variant="label" color="secondary" style={styles.sectionTitle}>
          PAYOUT SETTINGS
        </HXText>
        <Card variant="outlined" style={styles.settingsCard}>
          <View style={styles.settingRow}>
            <HXText variant="body">Payment Method</HXText>
            <HXText variant="body" color="secondary">Not set</HXText>
          </View>
          <Button 
            title="Connect Bank Account" 
            variant="secondary"
            style={styles.connectButton}
            onPress={() => {}}
          />
        </Card>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: COLORS.background,
  },
  content: {
    padding: SPACING[4],
  },
  subtitle: {
    marginBottom: SPACING[4],
  },
  balanceCard: {
    alignItems: 'center',
    paddingVertical: SPACING[6],
    paddingHorizontal: SPACING[4],
  },
  withdrawButton: {
    marginTop: SPACING[4],
    width: '100%',
  },
  sectionTitle: {
    marginTop: SPACING[6],
    marginBottom: SPACING[3],
    textTransform: 'uppercase',
    letterSpacing: 1,
  },
  pendingCard: {
    padding: SPACING[4],
  },
  pendingRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  pendingHint: {
    marginTop: SPACING[2],
  },
  historyCard: {
    padding: SPACING[6],
  },
  settingsCard: {
    padding: SPACING[4],
  },
  settingRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: SPACING[3],
  },
  connectButton: {
    marginTop: SPACING[2],
  },
});

export default WalletScreen;
