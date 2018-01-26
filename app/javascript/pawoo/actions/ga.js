import ReactGA from 'react-ga';

ReactGA.initialize('UA-1830249-136');

const isProduction = process.env.NODE_ENV === 'production';

export const event = (...args) => {
  if (isProduction) {
    ReactGA.event(...args);
  }
};

export const startHeartbeat = () => {
  if (!isProduction) {
    return null;
  }

  return setInterval(() => {
    ReactGA.event({
      category: 'Heartbeat',
      action: 'Heartbeat',
    });
  }, 10 * 60 * 1000);
};

export const trackPage = (page) => {
  if (!isProduction || page.indexOf('/admin/') === 0) {
    return;
  }

  const options = {};

  const userIdElement = document.querySelector('meta[name=pawoo-ga-uid]');
  if (userIdElement) {
    const userId = userIdElement.getAttribute('content');
    if (userId) {
      options.userId = userId;
    }
  }

  ReactGA.set({
    page,
    ...options,
  });
  ReactGA.pageview(page);
};

export default {
  event,
  startHeartbeat,
  trackPage,
};
