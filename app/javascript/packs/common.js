import { init } from '@sentry/browser';
import { start } from 'rails-ujs';
import 'font-awesome/css/font-awesome.css';
import '../pawoo/common';

if (process.env.PAWOO_SENTRY) {
  init({ dsn: process.env.PAWOO_SENTRY });
}

require.context('../images/', true);

start();
