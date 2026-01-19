/**
 * FirstXPCelebration Component Tests
 * 
 * Tests for first XP celebration animation
 */

import React from 'react';
import { render, waitFor } from '@testing-library/react-native';
import { FirstXPCelebration } from '../FirstXPCelebration';

// Mock Animated
jest.mock('react-native', () => {
  const RN = jest.requireActual('react-native');
  return {
    ...RN,
    Animated: {
      ...RN.Animated,
      timing: jest.fn((value, config) => ({
        start: jest.fn((callback) => {
          if (config.toValue !== undefined) {
            value.setValue(config.toValue);
          }
          callback && callback();
        }),
      })),
      parallel: jest.fn((animations) => ({
        start: jest.fn((callback) => {
          animations.forEach(anim => anim.start && anim.start());
          callback && callback();
        }),
      })),
      sequence: jest.fn((animations) => ({
        start: jest.fn((callback) => {
          animations.forEach(anim => anim.start && anim.start());
          callback && callback();
        }),
      })),
    },
  };
});

describe('FirstXPCelebration', () => {
  beforeEach(() => {
    jest.useFakeTimers();
  });

  afterEach(() => {
    jest.useRealTimers();
  });

  it('should render XP amount', () => {
    const { getByText } = render(
      <FirstXPCelebration
        xpAmount={100}
        levelProgress={0.5}
        onComplete={jest.fn()}
      />
    );

    expect(getByText('100')).toBeTruthy();
    expect(getByText('XP Earned')).toBeTruthy();
  });

  it('should show "First Task Complete!" message', () => {
    const { getByText } = render(
      <FirstXPCelebration
        xpAmount={100}
        levelProgress={0.5}
        onComplete={jest.fn()}
      />
    );

    expect(getByText('First Task Complete!')).toBeTruthy();
  });

  it('should show badge unlock when badgeUnlocked is true', () => {
    const { getByText } = render(
      <FirstXPCelebration
        xpAmount={100}
        levelProgress={0.5}
        badgeUnlocked={true}
        onComplete={jest.fn()}
      />
    );

    expect(getByText('Badge Unlocked')).toBeTruthy();
  });

  it('should call onComplete after animation', async () => {
    const onComplete = jest.fn();
    render(
      <FirstXPCelebration
        xpAmount={100}
        levelProgress={0.5}
        onComplete={onComplete}
      />
    );

    jest.advanceTimersByTime(2000);

    await waitFor(() => {
      expect(onComplete).toHaveBeenCalled();
    });
  });

  it('should skip animations when reducedMotion is true', () => {
    const onComplete = jest.fn();
    render(
      <FirstXPCelebration
        xpAmount={100}
        levelProgress={0.5}
        reducedMotion={true}
        onComplete={onComplete}
      />
    );

    // Should complete immediately with reduced motion
    expect(onComplete).toHaveBeenCalled();
  });
});
