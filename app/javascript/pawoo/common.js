import GA from './actions/ga';
import loadPolyfills from '../mastodon/load_polyfills';

require.context('./images/', true);

function main() {
  const ready = require('../mastodon/ready').default;
  ready(() => {
    GA.trackPage(window.location.pathname);
    GA.startHeartbeat();
  });
}

loadPolyfills().then(main).catch(error => {
  console.error(error);
});
