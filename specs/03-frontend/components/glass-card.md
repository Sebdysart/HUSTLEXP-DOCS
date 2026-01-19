# GlassCard

## Purpose
Structural container for grouped content. Non-interactive.

## Variants

### primary
- background: rgba(28,28,30,0.6)
- border: rgba(255,255,255,0.08)
- borderWidth: 1
- borderRadius: 16
- padding: 20

### secondary
- background: rgba(28,28,30,0.4)
- border: rgba(255,255,255,0.05)
- borderWidth: 1
- borderRadius: 12
- padding: 16

## Props
- `variant?: 'primary' | 'secondary'` (default: 'primary')
- `children: React.ReactNode`
- `style?: ViewStyle` (optional override)

## Forbidden
- No task logic
- No headers
- No actions
- No icons

## Used By
- E2 Eligibility Mismatch
- E3 Trust Tier Locked

## Status
LOCKED v1
