import classNames from 'classnames';
import React from 'react';
import ComposeFormContainer from './containers/compose_form_container';
import NavigationContainer from './containers/navigation_container';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { connect } from 'react-redux';
import { mountCompose, unmountCompose } from '../../actions/compose';
import { Link } from 'react-router-dom';
import { injectIntl, defineMessages } from 'react-intl';
import SearchContainer from './containers/search_container';
import Motion from '../ui/util/optional_motion';
import spring from 'react-motion/lib/spring';
import SearchResultsContainer from './containers/search_results_container';
import { changeComposing } from '../../actions/compose';
import {
  rollbackLayout as pawooRollbackLayout,
  upgradeLayout as pawooUpgradeLayout,
} from '../../../pawoo/actions/layout';
import { setPage as pawooSetPage } from '../../../pawoo/actions/page';
import Announcements from '../../../pawoo/components/announcements';
import PawooWebTagLink from '../../../pawoo/components/web_tag_link';
import TrendTagsContainer from '../../../pawoo/containers/trend_tags_container';
import elephantUIPlane from '../../../pawoo/images/pawoo-ui.png';

const messages = defineMessages({
  start: { id: 'getting_started.heading', defaultMessage: 'Getting started' },
  home_timeline: { id: 'tabs_bar.home', defaultMessage: 'Home' },
  notifications: { id: 'tabs_bar.notifications', defaultMessage: 'Notifications' },
  suggested_accounts: { id: 'column.suggested_accounts', defaultMessage: 'Active Users' },
  community: { id: 'navigation_bar.community_timeline', defaultMessage: 'Local timeline' },
  help: { id: 'navigation_bar.help', defaultMessage: 'Help' },
});

const mapStateToProps = state => ({
  columns: state.getIn(['settings', 'columns']),
  showSearch: state.getIn(['search', 'submitted']) && !state.getIn(['search', 'hidden']),
  pawooHasUnreadNotifications: state.getIn(['notifications', 'unread']) > 0,
  pawooMultiColumn: state.getIn(['settings', 'pawoo', 'multiColumn']),
});

@connect(mapStateToProps)
@injectIntl
export default class Compose extends React.PureComponent {

  static propTypes = {
    dispatch: PropTypes.func.isRequired,
    columns: ImmutablePropTypes.list.isRequired,
    multiColumn: PropTypes.bool,
    showSearch: PropTypes.bool,
    intl: PropTypes.object.isRequired,
    pawooHasUnreadNotifications: PropTypes.bool,
    pawooMultiColumn: PropTypes.bool,
  };

  componentDidMount () {
    this.props.dispatch(mountCompose());
  }

  componentWillUnmount () {
    this.props.dispatch(unmountCompose());
  }

  onFocus = () => {
    this.props.dispatch(changeComposing(true));
  }

  onBlur = () => {
    this.props.dispatch(changeComposing(false));
  }

  pawooHandleClick = () => {
    this.props.dispatch(pawooSetPage('DEFAULT'));
  }

  pawooHandleRollBack = () => {
    this.props.dispatch(pawooRollbackLayout());
  }

  pawooHandleUpgrade = () => {
    this.props.dispatch(pawooUpgradeLayout());
  }

  render () {
    const { multiColumn, showSearch, intl } = this.props;

    let header = '';

    if (multiColumn) {
      const { columns, pawooHasUnreadNotifications } = this.props;
      header = (
        <nav className='drawer__header'>
          <Link to='/getting-started' className='drawer__tab' onClick={this.pawooHandleClick} title={intl.formatMessage(messages.start)} aria-label={intl.formatMessage(messages.start)}><i role='img' className='fa fa-fw fa-asterisk' /></Link>
          {!columns.some(column => column.get('id') === 'HOME') && (
            <Link to='/timelines/home' className='drawer__tab' onClick={this.pawooHandleClick} title={intl.formatMessage(messages.home_timeline)} aria-label={intl.formatMessage(messages.home_timeline)}><i role='img' className='fa fa-fw fa-home' /></Link>
          )}
          {!columns.some(column => column.get('id') === 'NOTIFICATIONS') && (
            <Link to='/notifications' className={classNames('drawer__tab', { 'pawoo-extension-drawer__tab--unread': pawooHasUnreadNotifications })} onClick={this.pawooHandleClick} title={intl.formatMessage(messages.notifications)} aria-label={intl.formatMessage(messages.notifications)}><i role='img' className='fa fa-fw fa-bell' /></Link>
          )}
          {!columns.some(column => column.get('id') === 'COMMUNITY') && (
            <Link to='/timelines/public/local' className='drawer__tab' onClick={this.pawooHandleClick} title={intl.formatMessage(messages.community)} aria-label={intl.formatMessage(messages.community)}><i role='img' className='fa fa-fw fa-users' /></Link>
          )}
          <Link to='/suggested_accounts' className='drawer__tab' onClick={this.pawooHandleClick} title={intl.formatMessage(messages.suggested_accounts)} aria-label={intl.formatMessage(messages.suggested_accounts)}><i role='img' className='fa fa-fw fa-user-plus' /></Link>
          <a href='https://pawoo.pixiv.help' target='_blank' rel='noopener' className='drawer__tab' title={intl.formatMessage(messages.help)} aria-label={intl.formatMessage(messages.help)}><i role='img' className='fa fa-fw fa-question-circle' /></a>
        </nav>
      );
    }

    return (
      <div className='drawer'>
        {header}

        <SearchContainer />

        <div className='drawer__pager'>
          <div className='drawer__inner' onFocus={this.onFocus}>
            <NavigationContainer onClose={this.onBlur} />
            <ComposeFormContainer />

            {(!multiColumn || this.props.pawooMultiColumn) && (
              <React.Fragment>
                <div style={{ marginBottom: '10px' }}><Announcements /></div>
                <div className='drawer__block'>
                  <TrendTagsContainer Tag={PawooWebTagLink} />
                </div>
              </React.Fragment>
            )}
            {multiColumn && !this.props.pawooMultiColumn && (
              <div className='landing-strip pawoo-extension-landing-strip--embedded'>
                <p>
                  Pawooが新しいレイアウトになりました！もちろん、元のレイアウトに戻したり、
                  <a href='https://pawoo.pixiv.help/hc/ja/articles/115002872273-%E3%82%BF%E3%82%B0%E3%81%AE%E3%83%94%E3%83%B3%E7%95%99%E3%82%81%E3%81%AF%E3%81%A9%E3%81%93%E3%81%A7%E8%A8%AD%E5%AE%9A%E3%81%99%E3%82%8B%E3%81%AE%E3%81%A7%E3%81%99%E3%81%8B-'>ピン留めして自分好みに変えることもできます</a>。
                </p>
                <button className='button' onClick={this.pawooHandleRollBack}>元に戻すにはこちら</button>
              </div>
            )}

            {multiColumn && (
              <div className='drawer__inner__mastodon'>
                <img alt='' draggable='false' src={elephantUIPlane} />
              </div>
            )}
          </div>

          <Motion defaultStyle={{ x: -100 }} style={{ x: spring(showSearch ? 0 : -100, { stiffness: 210, damping: 20 }) }}>
            {({ x }) => (
              <div className='drawer__inner darker' style={{ transform: `translateX(${x}%)`, visibility: x === -100 ? 'hidden' : 'visible' }}>
                <SearchResultsContainer />
              </div>
            )}
          </Motion>
        </div>
      </div>
    );
  }

}
