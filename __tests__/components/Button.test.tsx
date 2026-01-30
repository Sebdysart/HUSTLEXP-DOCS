/**
 * Button Component Tests
 *
 * Tests for the HustleXP Button component
 * AUTHORITY: COMPONENT_LIBRARY.md
 */

import React from 'react';
import { render, fireEvent, waitFor } from '@testing-library/react-native';
import { Button } from '../../reference/components/Button';

describe('Button', () => {
  describe('Rendering', () => {
    it('renders with title', () => {
      const { getByText } = render(
        <Button title="Click me" onPress={() => {}} />
      );
      expect(getByText('Click me')).toBeTruthy();
    });

    it('renders primary variant by default', () => {
      const { getByRole } = render(
        <Button title="Primary" onPress={() => {}} />
      );
      const button = getByRole('button');
      expect(button).toBeTruthy();
    });

    it('renders secondary variant', () => {
      const { getByText } = render(
        <Button title="Secondary" variant="secondary" onPress={() => {}} />
      );
      expect(getByText('Secondary')).toBeTruthy();
    });

    it('renders ghost variant', () => {
      const { getByText } = render(
        <Button title="Ghost" variant="ghost" onPress={() => {}} />
      );
      expect(getByText('Ghost')).toBeTruthy();
    });

    it('renders danger variant', () => {
      const { getByText } = render(
        <Button title="Danger" variant="danger" onPress={() => {}} />
      );
      expect(getByText('Danger')).toBeTruthy();
    });
  });

  describe('Sizes', () => {
    it('renders small size', () => {
      const { getByText } = render(
        <Button title="Small" size="sm" onPress={() => {}} />
      );
      expect(getByText('Small')).toBeTruthy();
    });

    it('renders medium size by default', () => {
      const { getByText } = render(
        <Button title="Medium" onPress={() => {}} />
      );
      expect(getByText('Medium')).toBeTruthy();
    });

    it('renders large size', () => {
      const { getByText } = render(
        <Button title="Large" size="lg" onPress={() => {}} />
      );
      expect(getByText('Large')).toBeTruthy();
    });
  });

  describe('States', () => {
    it('calls onPress when pressed', () => {
      const onPress = jest.fn();
      const { getByText } = render(
        <Button title="Press me" onPress={onPress} />
      );

      fireEvent.press(getByText('Press me'));
      expect(onPress).toHaveBeenCalledTimes(1);
    });

    it('does not call onPress when disabled', () => {
      const onPress = jest.fn();
      const { getByText } = render(
        <Button title="Disabled" disabled onPress={onPress} />
      );

      fireEvent.press(getByText('Disabled'));
      expect(onPress).not.toHaveBeenCalled();
    });

    it('does not call onPress when loading', () => {
      const onPress = jest.fn();
      const { getByRole } = render(
        <Button title="Loading" loading onPress={onPress} />
      );

      fireEvent.press(getByRole('button'));
      expect(onPress).not.toHaveBeenCalled();
    });

    it('shows loading indicator when loading', () => {
      const { queryByText, getByRole } = render(
        <Button title="Loading" loading onPress={() => {}} />
      );

      // Title should not be visible when loading
      expect(queryByText('Loading')).toBeNull();
      // Button should still be present
      expect(getByRole('button')).toBeTruthy();
    });
  });

  describe('Accessibility', () => {
    it('has button accessibility role', () => {
      const { getByRole } = render(
        <Button title="Accessible" onPress={() => {}} />
      );
      expect(getByRole('button')).toBeTruthy();
    });

    it('uses title as accessibility label by default', () => {
      const { getByLabelText } = render(
        <Button title="My Button" onPress={() => {}} />
      );
      expect(getByLabelText('My Button')).toBeTruthy();
    });

    it('uses custom accessibility label when provided', () => {
      const { getByLabelText } = render(
        <Button
          title="Submit"
          accessibilityLabel="Submit the form"
          onPress={() => {}}
        />
      );
      expect(getByLabelText('Submit the form')).toBeTruthy();
    });

    it('indicates disabled state to accessibility', () => {
      const { getByRole } = render(
        <Button title="Disabled" disabled onPress={() => {}} />
      );
      expect(getByRole('button').props.accessibilityState.disabled).toBe(true);
    });
  });

  describe('Full Width', () => {
    it('renders full width when specified', () => {
      const { getByText } = render(
        <Button title="Full Width" fullWidth onPress={() => {}} />
      );
      expect(getByText('Full Width')).toBeTruthy();
    });
  });
});
