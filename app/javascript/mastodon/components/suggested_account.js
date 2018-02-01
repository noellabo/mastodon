import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import Avatar from './avatar';
import DisplayName from './display_name';
import Permalink from './permalink';
import IconButton from './icon_button';
import { defineMessages, injectIntl } from 'react-intl';
import { MediaGallery, Video } from '../features/ui/util/async-components';
import { me } from '../initial_state';

// We use the component (and not the container) since we do not want
// to use the progress bar to show download progress
import Bundle from '../features/ui/components/bundle';

const messages = defineMessages({
  follow: { id: 'account.follow', defaultMessage: 'Follow' },
  unfollow: { id: 'account.unfollow', defaultMessage: 'Unfollow' },
  requested: { id: 'account.requested', defaultMessage: 'Awaiting approval' },
  unblock: { id: 'account.unblock', defaultMessage: 'Unblock @{name}' },
  unmute: { id: 'account.unmute', defaultMessage: 'Unmute @{name}' },
});

@injectIntl
export default class SuggestedAccount extends React.PureComponent {

  static propTypes = {
    account: ImmutablePropTypes.map.isRequired,
    onFollow: PropTypes.func.isRequired,
    onOpenVideo: PropTypes.func.isRequired,
    onOpenMedia: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  handleFollow = () => {
    this.props.onFollow(this.props.account);
  }

  renderLoadingMediaGallery = () => {
    return <div className='media_gallery' style={{ height: 132 }} />;
  }

  renderLoadingVideoPlayer = () => {
    return <div className='media-spoiler-video' style={{ height: 132 }} />;
  }

  handleOpenVideo = startTime => {
    const { account } = this.props;

    this.props.onOpenVideo(account.getIn(['media_attachments', 0]), startTime);
  }

  render () {
    const { account, intl } = this.props;

    if (!account) {
      return <div />;
    }

    let buttons;
    let media = '';
    let attachments = account.get('media_attachments');

    if (attachments.size > 0) {
      if (attachments.some(item => item.get('type') === 'unknown')) {
        // Do nothing
      } else if (attachments.first().get('type') === 'video') {
        const video = attachments.first();
        media = (
          <Bundle fetchComponent={Video} loading={this.renderLoadingVideoPlayer} >
            {Component => (
              <Component
                preview={video.get('preview_url')}
                src={video.get('url')}
                width={274}
                height={132}
                onOpenVideo={this.handleOpenVideo}
              />
            )}
          </Bundle>
        );
      } else {
        media = (
          <Bundle fetchComponent={MediaGallery} loading={this.renderLoadingMediaGallery} >
            {Component => <Component media={attachments} height={132} onOpenMedia={this.props.onOpenMedia} lineMedia />}
          </Bundle>
        );
      }
    }

    if (account.get('id') !== me && account.get('relationship', null) !== null) {
      const following = account.getIn(['relationship', 'following']);
      const requested = account.getIn(['relationship', 'requested']);
      const blocking  = account.getIn(['relationship', 'blocking']);
      const muting  = account.getIn(['relationship', 'muting']);

      // NOTE: blocking/mutingはそもそもロードされないはず
      if (requested) {
        buttons = <IconButton disabled icon='hourglass' title={intl.formatMessage(messages.requested)} />;
      } else if (blocking) {
        buttons = <IconButton active icon='unlock-alt' title={intl.formatMessage(messages.unblock, { name: account.get('username') })} onClick={this.handleBlock} />;
      } else if (muting) {
        buttons = <IconButton active icon='volume-up' title={intl.formatMessage(messages.unmute, { name: account.get('username') })} onClick={this.handleMute} />;
      } else {
        buttons = <IconButton icon={following ? 'user-times' : 'user-plus'} title={intl.formatMessage(following ? messages.unfollow : messages.follow)} onClick={this.handleFollow} active={following} />;
      }
    }

    return (
      <div className='account suggested_account'>
        <div className='account__wrapper'>
          <Permalink key={account.get('id')} className='account__display-name' href={account.get('url')} to={`/accounts/${account.get('id')}`}>
            <div className='account__avatar-wrapper'><Avatar account={account} size={36} /></div>
            <DisplayName account={account} />
          </Permalink>

          <div className='account__relationship'>
            {buttons}
          </div>
        </div>

        <div className='suggested_account__media'>{media}</div>
      </div>
    );
  }

}
