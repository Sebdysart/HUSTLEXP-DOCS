# PrimaryActionButton

## Purpose
Neutral primary action button. No icon slot. No variants.

## Specifications
- width: 100%
- height: 52
- backgroundColor: #8E8E93 (primaryAction token)
- borderRadius: 12
- justifyContent: center
- alignItems: center
- shadowColor: #8E8E93
- shadowOffset: { width: 0, height: 0 }
- shadowOpacity: 0.4
- shadowRadius: 20
- elevation: 8
- label fontSize: 16
- label fontWeight: 700
- label color: #FFFFFF (textPrimary token)
- disabled opacity: 0.5

## Props
- `label: string`
- `onPress: () => void`
- `disabled?: boolean` (default: false)

## Forbidden
- No icon slot
- No color variants
- No size variants

## Used By
- E2 Eligibility Mismatch
- E3 Trust Tier Locked

## Status
LOCKED v1
