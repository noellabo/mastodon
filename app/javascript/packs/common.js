import { start } from 'rails-ujs';
import { startHeartbeat } from '../mastodon/actions/ga';
import 'font-awesome/css/font-awesome.css';

require.context('../images/', true);

start();
startHeartbeat();
