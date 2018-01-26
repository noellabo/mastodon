import { start } from 'rails-ujs';
import ready from '../mastodon/ready';
import PawooGA from '../pawoo/actions/ga';
import 'font-awesome/css/font-awesome.css';

require.context('../images/', true);

start();
ready(() => {
  PawooGA.trackPage(window.location.pathname);
  PawooGA.startHeartbeat();
});
