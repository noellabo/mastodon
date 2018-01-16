import loadPolyfills from '../mastodon/load_polyfills';

require.context('../images/', true);

function loaded() {
  const ScheduledStatusesContainer = require('../mastodon/containers/scheduled_statuses_container').default;
  const React = require('react');
  const ReactDOM = require('react-dom');
  const mountNode = document.getElementById('mastodon-scheduled-statuses');

  if (mountNode !== null) {
    const props = JSON.parse(mountNode.getAttribute('data-props'));
    ReactDOM.render(<ScheduledStatusesContainer {...props} />, mountNode);
  }
}

function main() {
  const ready = require('../mastodon/ready').default;
  ready(loaded);
}

loadPolyfills().then(main).catch(error => {
  console.error(error);
});
