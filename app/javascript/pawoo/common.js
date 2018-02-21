import ready from '../mastodon/ready';

require.context('./images/', true);

ready(() => {
  GA.trackPage(window.location.pathname);
  GA.startHeartbeat();
});
