import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import Avatar from './avatar';
import DisplayName from './display_name';
import MediaGallery from './media_gallery';
import Video from '../features/video';
import Permalink from './permalink';
import IconButton from './icon_button';
import { defineMessages, injectIntl } from 'react-intl';
import { me } from '../initial_state';

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
          <Video
            preview={video.get('preview_url')}
            src={video.get('url')}
            height={132}
            onOpenVideo={this.handleOpenVideo}
            sensitive={status.get('sensitive')}
          />
        );
      } else {
        media = <MediaGallery media={attachments} height={132} onOpenMedia={this.props.onOpenMedia} autoPlayGif={false} expandMedia={false} lineMedia />;
      }

      media = (<div className='account__suggested_accounts_media'>{media}</div>);
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
      <div className='account'>
        <div className='account__wrapper'>
          <Permalink key={account.get('id')} className='account__display-name' href={account.get('url')} to={`/accounts/${account.get('id')}`}>
            <div className='account__avatar-wrapper'><Avatar account={account} size={36} /></div>
            <DisplayName account={account} />
          </Permalink>

          <div className='account__relationship'>
            {buttons}
          </div>
        </div>

        {media}
      </div>
    );
  }

}
