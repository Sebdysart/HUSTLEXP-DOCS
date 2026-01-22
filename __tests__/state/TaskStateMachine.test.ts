/**
 * TaskStateMachine Tests
 *
 * Tests for valid state transitions
 * AUTHORITY: PRODUCT_SPEC.md
 */

import { TaskStateMachine } from '../../reference/state/TaskStateMachine';

describe('TaskStateMachine', () => {
  describe('canTransition', () => {
    // OPEN state transitions
    describe('from OPEN', () => {
      it('can transition to ACCEPTED', () => {
        expect(TaskStateMachine.canTransition('OPEN', 'ACCEPTED')).toBe(true);
      });

      it('can transition to CANCELLED', () => {
        expect(TaskStateMachine.canTransition('OPEN', 'CANCELLED')).toBe(true);
      });

      it('can transition to EXPIRED', () => {
        expect(TaskStateMachine.canTransition('OPEN', 'EXPIRED')).toBe(true);
      });

      it('cannot transition to COMPLETED', () => {
        expect(TaskStateMachine.canTransition('OPEN', 'COMPLETED')).toBe(false);
      });

      it('cannot transition to PROOF_SUBMITTED', () => {
        expect(TaskStateMachine.canTransition('OPEN', 'PROOF_SUBMITTED')).toBe(
          false
        );
      });
    });

    // ACCEPTED state transitions
    describe('from ACCEPTED', () => {
      it('can transition to PROOF_SUBMITTED', () => {
        expect(
          TaskStateMachine.canTransition('ACCEPTED', 'PROOF_SUBMITTED')
        ).toBe(true);
      });

      it('can transition to CANCELLED', () => {
        expect(TaskStateMachine.canTransition('ACCEPTED', 'CANCELLED')).toBe(
          true
        );
      });

      it('can transition to EXPIRED', () => {
        expect(TaskStateMachine.canTransition('ACCEPTED', 'EXPIRED')).toBe(
          true
        );
      });

      it('cannot transition directly to COMPLETED', () => {
        expect(TaskStateMachine.canTransition('ACCEPTED', 'COMPLETED')).toBe(
          false
        );
      });
    });

    // PROOF_SUBMITTED state transitions
    describe('from PROOF_SUBMITTED', () => {
      it('can transition to COMPLETED', () => {
        expect(
          TaskStateMachine.canTransition('PROOF_SUBMITTED', 'COMPLETED')
        ).toBe(true);
      });

      it('can transition to DISPUTED', () => {
        expect(
          TaskStateMachine.canTransition('PROOF_SUBMITTED', 'DISPUTED')
        ).toBe(true);
      });

      it('cannot transition to CANCELLED directly', () => {
        expect(
          TaskStateMachine.canTransition('PROOF_SUBMITTED', 'CANCELLED')
        ).toBe(false);
      });
    });

    // DISPUTED state transitions
    describe('from DISPUTED', () => {
      it('can transition to COMPLETED', () => {
        expect(TaskStateMachine.canTransition('DISPUTED', 'COMPLETED')).toBe(
          true
        );
      });

      it('can transition to CANCELLED', () => {
        expect(TaskStateMachine.canTransition('DISPUTED', 'CANCELLED')).toBe(
          true
        );
      });
    });

    // Terminal states
    describe('terminal states', () => {
      it('COMPLETED cannot transition to anything', () => {
        expect(TaskStateMachine.canTransition('COMPLETED', 'OPEN')).toBe(false);
        expect(TaskStateMachine.canTransition('COMPLETED', 'CANCELLED')).toBe(
          false
        );
      });

      it('CANCELLED cannot transition to anything', () => {
        expect(TaskStateMachine.canTransition('CANCELLED', 'OPEN')).toBe(false);
        expect(TaskStateMachine.canTransition('CANCELLED', 'COMPLETED')).toBe(
          false
        );
      });

      it('EXPIRED cannot transition to anything', () => {
        expect(TaskStateMachine.canTransition('EXPIRED', 'OPEN')).toBe(false);
        expect(TaskStateMachine.canTransition('EXPIRED', 'ACCEPTED')).toBe(
          false
        );
      });
    });
  });

  describe('isTerminal', () => {
    it('COMPLETED is terminal', () => {
      expect(TaskStateMachine.isTerminal('COMPLETED')).toBe(true);
    });

    it('CANCELLED is terminal', () => {
      expect(TaskStateMachine.isTerminal('CANCELLED')).toBe(true);
    });

    it('EXPIRED is terminal', () => {
      expect(TaskStateMachine.isTerminal('EXPIRED')).toBe(true);
    });

    it('OPEN is not terminal', () => {
      expect(TaskStateMachine.isTerminal('OPEN')).toBe(false);
    });

    it('ACCEPTED is not terminal', () => {
      expect(TaskStateMachine.isTerminal('ACCEPTED')).toBe(false);
    });

    it('PROOF_SUBMITTED is not terminal', () => {
      expect(TaskStateMachine.isTerminal('PROOF_SUBMITTED')).toBe(false);
    });

    it('DISPUTED is not terminal', () => {
      expect(TaskStateMachine.isTerminal('DISPUTED')).toBe(false);
    });
  });
});
