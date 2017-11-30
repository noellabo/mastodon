import React from 'react';
import { connect, Provider } from 'react-redux';
import PropTypes from 'prop-types';
import configureStore from '../store/configureStore';
import { showOnboardingOnce } from '../actions/onboarding';
import { BrowserRouter, Route } from 'react-router-dom';
import { ScrollContext } from 'react-router-scroll';
import CommunityTimeline from '../features/community_timeline';
import ScheduledStatuses from '../features/scheduled_statuses';
import Compose from '../features/compose';
import UI from '../features/ui';
import { hydrateStore } from '../actions/store';
import { connectUserStream } from '../actions/streaming';
import { IntlProvider, addLocaleData } from 'react-intl';
import { getLocale } from '../locales';

const { localeData, messages } = getLocale();
addLocaleData(localeData);

export const store = configureStore();
const hydrateAction = hydrateStore(JSON.parse(document.getElementById('initial-state').textContent));
store.dispatch(hydrateAction);

export default class Mastodon extends React.PureComponent {

  static propTypes = {
    locale: PropTypes.string.isRequired,
  };

  componentWillMount() {
    this.appmode = store.getState().getIn(['meta', 'appmode']);
  }

  componentDidMount() {
    if (this.appmode !== 'default') return;

    this.disconnect = store.dispatch(connectUserStream());

    // Desktop notifications
    // Ask after 1 minute
    if (typeof window.Notification !== 'undefined' && Notification.permission === 'default') {
      window.setTimeout(() => Notification.requestPermission(), 60 * 1000);
    }

    // Protocol handler
    // Ask after 5 minutes
    if (typeof navigator.registerProtocolHandler !== 'undefined') {
      const handlerUrl = window.location.protocol + '//' + window.location.host + '/intent?uri=%s';
      window.setTimeout(() => navigator.registerProtocolHandler('web+mastodon', handlerUrl, 'Mastodon'), 5 * 60 * 1000);
    }

    store.dispatch(showOnboardingOnce());
  }

  componentWillUnmount () {
    if (this.disconnect) {
      this.disconnect();
      this.disconnect = null;
    }
  }

  render () {
    const { locale } = this.props;

    if (this.appmode === 'scheduledStatuses') {
      return (
        <IntlProvider locale={locale} messages={messages}>
          <Provider store={store}>
            <BrowserRouter basename='/admin/scheduled_statuses'>
              <ScrollContext>
                <UI className='scheduled_statuses__container' intent>
                  <Compose schedule />
                  <Route path='*' component={connect(() => ({ standalone: true }))(ScheduledStatuses)} />
                </UI>
              </ScrollContext>
            </BrowserRouter>
          </Provider>
        </IntlProvider>
      );
    }

    if (this.appmode === 'about') {
      return (
        <IntlProvider locale={locale} messages={messages}>
          <Provider store={store}>
            <BrowserRouter basename='/about'>
              <ScrollContext>
                <UI intent>
                  <Route path='*' component={connect(() => ({ standalone: true }))(CommunityTimeline)} />
                </UI>
              </ScrollContext>
            </BrowserRouter>
          </Provider>
        </IntlProvider>
      );
    }

    if (this.appmode === 'default') {
      return (
        <IntlProvider locale={locale} messages={messages}>
          <Provider store={store}>
            <BrowserRouter basename='/web'>
              <ScrollContext>
                <Route path='/' component={UI} />
              </ScrollContext>
            </BrowserRouter>
          </Provider>
        </IntlProvider>
      );
    }

    return <div />;
  }

}
