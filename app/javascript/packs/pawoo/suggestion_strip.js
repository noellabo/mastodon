import loadPolyfills from '../../mastodon/load_polyfills';

function loaded() {
  const SuggestionStripContainer = require('../../pawoo/containers/standalone/suggestion_strip_container').default;
  const React                    = require('react');
  const ReactDOM                 = require('react-dom');
  const mountNode                = document.getElementById('pawoo-suggestion-strip');
  const props                    = JSON.parse(mountNode.getAttribute('data-props'));

  ReactDOM.render(<SuggestionStripContainer {...props} />, mountNode);
}

function main() {
  const ready = require('../../mastodon/ready').default;
  ready(loaded);
}

loadPolyfills().then(main).catch(error => {
  console.error(error);
});
