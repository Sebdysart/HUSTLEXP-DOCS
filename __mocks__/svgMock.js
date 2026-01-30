/**
 * SVG Mock for Jest
 *
 * Returns a mock React component for SVG imports
 */

const React = require('react');

module.exports = 'SvgMock';
module.exports.ReactComponent = (props) =>
  React.createElement('svg', { ...props, 'data-testid': 'svg-mock' });
