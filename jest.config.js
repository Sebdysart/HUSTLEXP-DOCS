/**
 * HustleXP Jest Configuration
 *
 * AUTHORITY: FRONTEND_ARCHITECTURE.md
 * STATUS: Test infrastructure setup
 */

module.exports = {
  preset: 'jest-expo',
  testEnvironment: 'node',
  setupFilesAfterEnv: ['<rootDir>/jest.setup.js'],
  testMatch: [
    '**/__tests__/**/*.test.[jt]s?(x)',
    '**/?(*.)+(spec|test).[jt]s?(x)',
  ],
  moduleFileExtensions: ['ts', 'tsx', 'js', 'jsx', 'json', 'node'],
  transformIgnorePatterns: [
    'node_modules/(?!(jest-)?react-native|@react-native|@react-native-community|@react-navigation|expo(nent)?|@expo(nent)?/.*|react-navigation|@sentry/react-native|native-base|react-native-svg|lucide-react-native)',
  ],
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/src/$1',
    '^@/components$': '<rootDir>/reference/components',
    '^@/constants$': '<rootDir>/reference/constants',
    '^@/state$': '<rootDir>/reference/state',
    '^@/navigation$': '<rootDir>/reference/navigation',
    '^@/screens$': '<rootDir>/reference/screens',
    '^@/assets/(.*)$': '<rootDir>/assets/$1',
    '^@/types$': '<rootDir>/src/types',
    '\\.svg$': '<rootDir>/__mocks__/svgMock.js',
  },
  collectCoverageFrom: [
    'src/**/*.{ts,tsx}',
    'reference/**/*.{js,jsx}',
    '!**/__tests__/**',
    '!**/node_modules/**',
    '!**/*.d.ts',
  ],
  coverageThreshold: {
    global: {
      branches: 70,
      functions: 70,
      lines: 70,
      statements: 70,
    },
  },
  testPathIgnorePatterns: ['/node_modules/', '/dist/', '/.expo/'],
  globals: {
    'ts-jest': {
      tsconfig: 'tsconfig.json',
    },
  },
};
