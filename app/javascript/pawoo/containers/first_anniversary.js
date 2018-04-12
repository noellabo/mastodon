import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import React from 'react';
import noop from 'lodash/noop';
import { injectIntl } from 'react-intl';
import { connect } from 'react-redux';
import Toggle from 'react-toggle';
import { scrollTopTimeline } from '../../mastodon/actions/timelines';
import { connectCommunityStream } from '../../mastodon/actions/streaming';
import { setPage } from '../actions/page';
import { pushMargin, shiftFromTimeline, initializeTimeline } from '../actions/first_anniversary';
import { resizeColumnMedia } from '../actions/column_media';
import Column from '../../mastodon/components/column';
import ColumnHeader from '../../mastodon/components/column_header';
import { Map as ImmutableMap, List as ImmutableList } from 'immutable';
import { createSelector } from 'reselect';
import { me } from '../../mastodon/initial_state';
import StatusContainer from '../../mastodon/containers/status_container';
import IconButton from '../../mastodon/components/icon_button';

const makeGetStatusIds = () => createSelector([
  (state) => state.getIn(['settings', 'community'], ImmutableMap()),
  (state) => state.getIn(['pawoo', 'first_anniversary', 'statusIds'], ImmutableList()),
  (state)           => state.get('statuses'),
], (columnSettings, statusIds, statuses) => {
  const rawRegex = columnSettings.getIn(['regex', 'body'], '').trim();
  let regex      = null;

  try {
    regex = rawRegex && new RegExp(rawRegex, 'i');
  } catch (e) {
    // Bad regex, don't affect filters
  }

  return statusIds.filter(id => {
    if (id.startsWith('margin')) {
      return true;
    }

    const statusForId = statuses.get(id);
    let showStatus    = true;

    if (columnSettings.getIn(['shows', 'reblog']) === false) {
      showStatus = showStatus && statusForId.get('reblog') === null;
    }

    if (columnSettings.getIn(['shows', 'reply']) === false) {
      showStatus = showStatus && (statusForId.get('in_reply_to_id') === null || statusForId.get('in_reply_to_account_id') === me);
    }

    if (showStatus && regex && statusForId.get('account') !== me) {
      const searchIndex = statusForId.get('reblog') ? statuses.getIn([statusForId.get('reblog'), 'search_index']) : statusForId.get('search_index');
      showStatus = !regex.test(searchIndex);
    }

    return showStatus;
  });
});

const makeMapStateToProps = () => {
  const getStatusIds = makeGetStatusIds();

  const mapStateToProps = (state) => ({
    statusIds: getStatusIds(state),
    margin: state.getIn(['pawoo', 'first_anniversary', 'margin'], 0),
  });

  return mapStateToProps;
};

@connect(makeMapStateToProps)
@injectIntl
export default class FirstAnniversary extends React.PureComponent {

  static propTypes = {
    statusIds: ImmutablePropTypes.list.isRequired,
    margin: PropTypes.number.isRequired,
    dispatch: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  static childContextTypes = {
    pawooPushHistory: PropTypes.func,
    pawooPopHistory: PropTypes.func,
  };

  state = {
    playBgm: true,
    mute: false,
  }

  getChildContext() {
    return ({
      pawooPushHistory: noop,
      pawooPopHistory: this.handlePopHistory,
    });
  }

  componentDidMount () {
    const { dispatch } = this.props;

    dispatch(scrollTopTimeline('community', true));
    dispatch(initializeTimeline());
    this.disconnect = dispatch(connectCommunityStream());
    this.timer = setInterval(this.checkVisibleStatuses, 2000);
    this.props.dispatch(resizeColumnMedia());
    this.startAudio();
  }

  componentWillUnmount () {
    if (this.disconnect) {
      this.disconnect();
      this.disconnect = null;
    }
    if (this.timer) {
      clearInterval(this.timer);
    }
    this.props.dispatch(resizeColumnMedia());
  }

  handlePopHistory = () => {
    this.props.dispatch(setPage('DEFAULT'));
  }

  handleToggle = () => {
    this.setState({ playBgm: !this.state.playBgm });
  }

  handleClickVolume = () => {
    this.setState({
      mute: !this.state.mute,
    });
  }

  setRef = (ele) => {
    this.titles = ele;
  }

  setBgmRef = (ele) => {
    this.bgm = ele;
  }

  setZouRef = (ele) => {
    this.zou = ele;
  }

  startAudio () {
    setTimeout(() => {
      const promise = this.bgm.play();
      if (promise instanceof Promise) {
        promise.catch(() => {
          this.bgm.muted = true;
          this.bgm.play();
          this.setState({ mute: true });
        });
      }
    }, 5000);

    setTimeout(() => {
      const promise = this.zou.play();
      if (promise instanceof Promise) {
        promise.catch(() => {
          this.zou.muted = true;
          this.zou.play();
          this.setState({ mute: true });
        });
      }
    }, 5000);
  }


  checkVisibleStatuses = () => {
    if (!this.titles) {
      return;
    }

    const { top: titlesTop, bottom: titlesBottom } = this.titles.getBoundingClientRect();

    // 最後の要素が見えたら余白を追加
    const lastChild = this.titles.querySelector('.pawoo-first-anniversary-column__titlecontent > div:last-child');
    if (!lastChild) {
      return;
    }

    const lastChildTop = lastChild.getBoundingClientRect().top;
    if (lastChildTop > titlesTop && lastChildTop < titlesBottom) {
      this.props.dispatch(pushMargin());
    }

    // 最初の要素が見えなくなったら消す
    const firstChild = this.titles.querySelector('.pawoo-first-anniversary-column__titlecontent > div:first-child');
    const firstChildBottom = firstChild.getBoundingClientRect().bottom;
    if (firstChildBottom < titlesTop) {
      const height = firstChild.offsetHeight;
      this.props.dispatch(shiftFromTimeline(height));
    }
  }

  render () {
    const { margin, statusIds } = this.props;
    const { playBgm, mute } = this.state;

    const heading = (
      <marquee className='pawoo-first-anniversary-header'>
        裏ページへようこそ
      </marquee>
    );

    return (
      <Column>
        <ColumnHeader icon='users' title={heading} showBackButton />

        <div className='pawoo-first-anniversary-column'>
          <audio src='https://img.pawoo.net/pawoo_first_anniversary/first_anniversary_bgm.mp3' loop muted={mute || !playBgm} ref={this.setBgmRef} />
          <audio src='https://img.pawoo.net/pawoo_first_anniversary/zou.mp3' loop muted={mute} ref={this.setZouRef} />

          <div className='pawoo-first-anniversary-column__gbm_toggle'>
            <Toggle checked={playBgm} onChange={this.handleToggle} />
          </div>
          <IconButton className='pawoo-first-anniversary-column__mute-button' title='mute' icon={mute ? 'volume-off' : 'volume-up'} onClick={this.handleClickVolume} size={24} />

          <div className='pawoo-first-anniversary-column__start'>
            A year since then…
          </div>
          <h1 className='pawoo-first-anniversary-column__logo'>
            Pawoo
            <div className='pawoo-first-anniversary-column__logo__sub'>
              Mastodon Hosted by pixiv
            </div>
          </h1>
          <div className='pawoo-first-anniversary-column__titles' ref={this.setRef}>
            <div className='pawoo-first-anniversary-column__titlecontent' style={{ marginTop: `${margin}px` }}>
              {statusIds.map((id) => id.startsWith('margin') ? (
                <div key={id} className='pawoo-first-anniversary-column__margin' />
              ) : (
                <StatusContainer key={id} id={id} />
                )
              )}
            </div>
          </div>
        </div>
      </Column>
    );
  }

}
