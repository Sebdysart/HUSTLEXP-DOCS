/**
 * DEPRECATED: This file is superseded by .eslintrc.json
 *
 * ESLint resolves config files in priority order: .eslintrc.js > .eslintrc.json.
 * To avoid conflicts, this file now delegates to .eslintrc.json.
 *
 * The canonical configuration lives in .eslintrc.json which includes:
 * - TypeScript support
 * - React/React Native rules
 * - HustleXP custom rule stubs
 * - Proper parser configuration
 *
 * See .eslintrc.json for the active configuration.
 * See ESLINT_CUSTOM_RULES.md for custom plugin implementation details.
 */

const jsonConfig = require('./.eslintrc.json');
module.exports = jsonConfig;
