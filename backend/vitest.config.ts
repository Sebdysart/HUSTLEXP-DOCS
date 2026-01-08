import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    globals: true,
    environment: 'node',
    include: ['tests/**/*.test.ts'],
    exclude: ['node_modules'],
    testTimeout: 10000,
    hookTimeout: 10000,
    reporters: ['verbose'],
    // Run invariant tests in sequence to avoid race conditions
    sequence: {
      shuffle: false,
    },
    // Fail fast - if invariant test fails, stop immediately
    bail: 1,
  },
});
