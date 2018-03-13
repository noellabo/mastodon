/* global ga:false */

// Load GA
/* eslint-disable */
(function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
})(window,document,'script','https://www.google-analytics.com/analytics.js','ga');
/* eslint-enable */

const isProduction = process.env.NODE_ENV === 'production';
const option = (() => {
  const userIdElement = document.querySelector('meta[name=pawoo-ga-uid]');
  if (userIdElement) {
    const userId = userIdElement.getAttribute('content');
    if (userId) {
      return { userId };
    }
  }
  return {};
})();

ga('create', 'UA-1830249-136', option);

export const event = (params) => {
  if (isProduction) {
    ga('send', { hitType: 'event', ...params });
  }
};

export const startHeartbeat = () => {
  if (!isProduction) {
    return null;
  }

  return setInterval(() => {
    event({
      eventCategory: 'Heartbeat',
      eventAction: 'Heartbeat',
    });
  }, 10 * 60 * 1000);
};

export const trackPage = (page) => {
  if (!isProduction || page.indexOf('/admin/') === 0) {
    return;
  }

  ga('set', 'page', page);
  ga('send', 'pageview');
};

export default {
  event,
  startHeartbeat,
  trackPage,
};
