/**
 * Runtime Guards Tests
 * 
 * Tests for UI_SPEC enforcement guards
 */

import {
  AnimationDurationGuard,
  ReducedMotionGuard,
  FirstTimeAnimationGuard,
  AnimationContextGuard,
  ForbiddenAnimationGuard,
  ColorContextGuard,
  StateConfirmationGuard,
  ScreenContextGuard,
  ViolationTracker,
} from '../runtimeGuards';
import { DURATION, FORBIDDEN_PATTERNS } from '../../constants/animations';

describe('AnimationDurationGuard', () => {
  it('should validate micro-feedback duration', () => {
    expect(AnimationDurationGuard.validate(100, 'MICRO_FEEDBACK')).toBe(true);
    expect(AnimationDurationGuard.validate(150, 'MICRO_FEEDBACK')).toBe(true);
    expect(AnimationDurationGuard.validate(200, 'MICRO_FEEDBACK')).toBe(false);
  });

  it('should validate state transition duration', () => {
    expect(AnimationDurationGuard.validate(300, 'STATE_TRANSITION')).toBe(true);
    expect(AnimationDurationGuard.validate(400, 'STATE_TRANSITION')).toBe(false);
  });

  it('should validate celebration duration', () => {
    expect(AnimationDurationGuard.validate(2000, 'CELEBRATION')).toBe(true);
    expect(AnimationDurationGuard.validate(2001, 'CELEBRATION')).toBe(false);
  });

  it('should allow indefinite loading animations', () => {
    expect(AnimationDurationGuard.validate(999999, 'LOADING')).toBe(true);
  });
});

describe('ReducedMotionGuard', () => {
  beforeEach(() => {
    ReducedMotionGuard._reducedMotionEnabled = false;
  });

  it('should return false when motion is not reduced', () => {
    expect(ReducedMotionGuard.shouldReduceMotion()).toBe(false);
  });

  it('should apply reduced motion to animation config', () => {
    const config = { duration: 300, useNativeDriver: true };
    ReducedMotionGuard._reducedMotionEnabled = true;
    
    const result = ReducedMotionGuard.applyReducedMotion(config);
    expect(result.duration).toBe(0);
    expect(result.useNativeDriver).toBe(false);
  });

  it('should not modify config when motion is not reduced', () => {
    const config = { duration: 300, useNativeDriver: true };
    ReducedMotionGuard._reducedMotionEnabled = false;
    
    const result = ReducedMotionGuard.applyReducedMotion(config);
    expect(result).toEqual(config);
  });
});

describe('AnimationContextGuard', () => {
  it('should block animation during active dispute', () => {
    const context = { screen: 'home', hasActiveDispute: true };
    expect(AnimationContextGuard.canAnimate(context)).toBe(false);
  });

  it('should block animation during onboarding', () => {
    const context = { screen: 'onboarding', isOnboarding: true };
    expect(AnimationContextGuard.canAnimate(context)).toBe(false);
  });

  it('should block animation during pending payment', () => {
    const context = { screen: 'home', hasPendingPayment: true };
    expect(AnimationContextGuard.canAnimate(context)).toBe(false);
  });

  it('should allow animation in normal context', () => {
    const context = { screen: 'home' };
    expect(AnimationContextGuard.canAnimate(context)).toBe(true);
  });
});

describe('ForbiddenAnimationGuard', () => {
  it('should detect forbidden patterns', () => {
    expect(ForbiddenAnimationGuard.isForbidden('confetti')).toBe(true);
    expect(ForbiddenAnimationGuard.isForbidden('infinite_loops')).toBe(true);
    expect(ForbiddenAnimationGuard.isForbidden('shake_vibrate')).toBe(true);
    expect(ForbiddenAnimationGuard.isForbidden('normal_animation')).toBe(false);
  });

  it('should validate animation patterns', () => {
    expect(ForbiddenAnimationGuard.validate('confetti')).toBe(false);
    expect(ForbiddenAnimationGuard.validate('fade_in')).toBe(true);
  });
});

describe('ColorContextGuard', () => {
  it('should validate XP color context', () => {
    expect(ColorContextGuard.validateXPColor('xp_display')).toBe(true);
    expect(ColorContextGuard.validateXPColor('level_indicator')).toBe(true);
    expect(ColorContextGuard.validateXPColor('task_card')).toBe(false);
  });

  it('should validate Money color context', () => {
    expect(ColorContextGuard.validateMoneyColor('escrow_state')).toBe(true);
    expect(ColorContextGuard.validateMoneyColor('payment_amount')).toBe(true);
    expect(ColorContextGuard.validateMoneyColor('decorative_button')).toBe(false);
  });

  it('should validate Status color context', () => {
    expect(ColorContextGuard.validateStatusColor('success_confirmation')).toBe(true);
    expect(ColorContextGuard.validateStatusColor('error_failure')).toBe(true);
    expect(ColorContextGuard.validateStatusColor('decorative_text')).toBe(false);
  });
});

describe('StateConfirmationGuard', () => {
  it('should allow matching states', () => {
    expect(StateConfirmationGuard.canDisplayState('COMPLETED', 'COMPLETED')).toBe(true);
  });

  it('should block mismatched states', () => {
    expect(StateConfirmationGuard.canDisplayState('COMPLETED', 'OPEN')).toBe(false);
  });

  it('should block optimistic updates', () => {
    expect(StateConfirmationGuard.blockOptimisticUpdate('COMPLETED', 'OPEN')).toBe(false);
  });
});

describe('ScreenContextGuard', () => {
  it('should allow XP colors on allowed screens', () => {
    expect(ScreenContextGuard.canShowXPColors('home')).toBe(true);
    expect(ScreenContextGuard.canShowXPColors('dashboard')).toBe(true);
    expect(ScreenContextGuard.canShowXPColors('profile')).toBe(true);
  });

  it('should block XP colors on forbidden screens', () => {
    expect(ScreenContextGuard.canShowXPColors('task_feed')).toBe(false);
    expect(ScreenContextGuard.canShowXPColors('task_detail')).toBe(false);
  });

  it('should allow Money colors on allowed screens', () => {
    expect(ScreenContextGuard.canShowMoneyColors('wallet')).toBe(true);
    expect(ScreenContextGuard.canShowMoneyColors('task_detail')).toBe(true);
  });

  it('should block celebration on forbidden screens', () => {
    expect(ScreenContextGuard.canShowCelebration('task_feed', {})).toBe(false);
    expect(ScreenContextGuard.canShowCelebration('dispute', {})).toBe(false);
    expect(ScreenContextGuard.canShowCelebration('onboarding', {})).toBe(false);
  });

  it('should allow celebration on allowed screens', () => {
    expect(ScreenContextGuard.canShowCelebration('home', {})).toBe(true);
    expect(ScreenContextGuard.canShowCelebration('task_detail', { justCompleted: true })).toBe(true);
  });
});

describe('ViolationTracker', () => {
  beforeEach(() => {
    ViolationTracker.clear();
  });

  it('should log violations', () => {
    ViolationTracker.log('COLOR', 'xp_color_outside_context', 'HomeScreen', {});
    expect(ViolationTracker.getViolations().length).toBe(1);
  });

  it('should assign correct severity', () => {
    ViolationTracker.log('COLOR', 'test', 'TestComponent', {});
    const violation = ViolationTracker.getViolations()[0];
    expect(violation.severity).toBe('ERROR');
  });

  it('should clear violations', () => {
    ViolationTracker.log('COLOR', 'test', 'TestComponent', {});
    ViolationTracker.clear();
    expect(ViolationTracker.getViolations().length).toBe(0);
  });
});
