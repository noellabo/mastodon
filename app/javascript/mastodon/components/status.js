import React from 'react';
import Immutable from 'immutable';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import Avatar from './avatar';
import AvatarOverlay from './avatar_overlay';
import Timestamp from './timestamp';
import DisplayName from './display_name';
import StatusContent from './status_content';
import StatusActionBar from './status_action_bar';
import { FormattedMessage } from 'react-intl';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { MediaGallery, VideoPlayer } from '../features/ui/util/async-components';

// We use the component (and not the container) since we do not want
// to use the progress bar to show download progress
import Bundle from '../features/ui/components/bundle';

export default class Status extends ImmutablePureComponent {

  static contextTypes = {
    router: PropTypes.object,
  };

  static propTypes = {
    status: ImmutablePropTypes.map,
    account: ImmutablePropTypes.map,
    onReply: PropTypes.func,
    onFavourite: PropTypes.func,
    onReblog: PropTypes.func,
    onDelete: PropTypes.func,
    onPin: PropTypes.func,
    onOpenMedia: PropTypes.func,
    onOpenVideo: PropTypes.func,
    onBlock: PropTypes.func,
    onEmbed: PropTypes.func,
    onHeightChange: PropTypes.func,
    me: PropTypes.number,
    boostModal: PropTypes.bool,
    autoPlayGif: PropTypes.bool,
    muted: PropTypes.bool,
    expandMedia: PropTypes.bool,
    squareMedia: PropTypes.bool,
    schedule: PropTypes.bool,
    onPin: PropTypes.func,
    displayPinned: PropTypes.bool,
    intersectionObserverWrapper: PropTypes.object,
    hidden: PropTypes.bool,
  };

  static defaultProps = {
    expandMedia: false,
  };

  state = {
    isExpanded: false,
  }

  // Avoid checking props that are functions (and whose equality will always
  // evaluate to false. See react-immutable-pure-component for usage.
  updateOnProps = [
    'status',
    'account',
    'me',
    'boostModal',
    'autoPlayGif',
    'muted',
    'hidden',
  ]

  updateOnStates = ['isExpanded']

  handleClick = () => {
    if (!this.context.router) {
      return;
    }

    const { status } = this.props;
    this.context.router.history.push(`/statuses/${status.getIn(['reblog', 'id'], status.get('id'))}`);
  }

  handleAccountClick = (e) => {
    if (this.context.router && e.button === 0) {
      const id = Number(e.currentTarget.getAttribute('data-id'));
      e.preventDefault();
      this.context.router.history.push(`/accounts/${id}`);
    }
  }

  handleExpandedToggle = () => {
    this.setState({ isExpanded: !this.state.isExpanded });
  };

  renderLoadingMediaGallery = () => {
    const { squareMedia } = this.props;
    return <div className='media_gallery' style={{ height: squareMedia ? 229 : 132 }} />;
  }

  renderLoadingVideoPlayer = () => {
    const { squareMedia } = this.props;
    return <div className='media-spoiler-video' style={{ height: squareMedia ? 229 : 132 }} />;
  }

  render () {
    let media = null;
    let statusAvatar;

    const { status, account, hidden, expandMedia, squareMedia, schedule, ...other } = this.props;
    const { isExpanded } = this.state;

    if (status === null) {
      return null;
    }

    if (hidden) {
      return (
        <div>
          {status.getIn(['account', 'display_name']) || status.getIn(['account', 'username'])}
          {status.get('content')}
        </div>
      );
    }

    if (this.props.displayPinned && status.get('pinned')) {
      const { displayPinned, intersectionObserverWrapper, ...otherProps } = this.props;

      return (
        <div className='status__wrapper pinned' ref={this.handleRef} data-id={status.get('id')} >
          <div className='status__prepend'>
            <div className='status__prepend-icon-wrapper'><i className='fa fa-fw fa-pin status__prepend-icon' /></div>
            <FormattedMessage id='status.pinned' defaultMessage='Pinned Toot' className='status__display-name muted' />
          </div>

          <Status {...otherProps} />
        </div>
      );
    }

    if (status.get('reblog', null) !== null && typeof status.get('reblog') === 'object') {
      const display_name_html = { __html: status.getIn(['account', 'display_name_html']) };

      return (
        <div className='status__wrapper' data-id={status.get('id')} >
          <div className='status__prepend'>
            <div className='status__prepend-icon-wrapper'><i className='fa fa-fw fa-retweet status__prepend-icon' /></div>
            <FormattedMessage id='status.reblogged_by' defaultMessage='{name} boosted' values={{ name: <a onClick={this.handleAccountClick} data-id={status.getIn(['account', 'id'])} href={status.getIn(['account', 'url'])} className='status__display-name muted'><strong dangerouslySetInnerHTML={display_name_html} /></a> }} />
          </div>

          <Status {...other} status={status.get('reblog')} account={status.get('account')} displayPinned={false} />
        </div>
      );
    }

    let attachments = status.get('media_attachments');
    if (status.getIn(['pixiv_cards'], Immutable.List()).size > 0) {
      attachments = status.get('pixiv_cards').map(card => {
        return Immutable.fromJS({
          id: Math.random().toString(),
          preview_url: card.get('image_url'),
          remote_url: '',
          text_url: card.get('url'),
          type: 'image',
          url: card.get('image_url'),
        });
      }).concat(attachments);
    }

    if (attachments.size > 0 && !this.props.muted) {
      if (attachments.some(item => item.get('type') === 'unknown')) {

      } else if (attachments.first().get('type') === 'video') {
        media = (
          <Bundle fetchComponent={VideoPlayer} loading={this.renderLoadingVideoPlayer}>
            {Component => <Component media={attachments.first()} sensitive={status.get('sensitive')} height={squareMedia ? 229 : 132} onOpenVideo={this.props.onOpenVideo} />}
          </Bundle>
        );
      } else {
        media = (
          <Bundle fetchComponent={MediaGallery} loading={this.renderLoadingMediaGallery} >
            {Component => <Component media={attachments} sensitive={status.get('sensitive')} height={squareMedia ? 229 : 132} onOpenMedia={this.props.onOpenMedia} autoPlayGif={this.props.autoPlayGif} expandMedia={expandMedia} />}
          </Bundle>
        );
      }
    }

    if (account === undefined || account === null) {
      statusAvatar = <Avatar account={status.get('account')} size={48} />;
    }else{
      statusAvatar = <AvatarOverlay account={status.get('account')} friend={account} />;
    }

    return (
      <div className={`status ${this.props.muted ? 'muted' : ''} status-${status.get('visibility')}`} data-id={status.get('id')}>
        <div className='status__info'>
          <a href={status.get('url')} className='status__time' target='_blank' rel='noopener'><Timestamp schedule={schedule} timestamp={status.get('created_at')} /></a>

          <a onClick={this.handleAccountClick} target='_blank' data-id={status.getIn(['account', 'id'])} href={status.getIn(['account', 'url'])} className='status__display-name'>
            <div className='status__avatar'>
              {statusAvatar}
            </div>

            <DisplayName account={status.get('account')} />
          </a>
        </div>

        <StatusContent status={status} onClick={this.handleClick} expanded={isExpanded} onExpandedToggle={this.handleExpandedToggle} />

        {media}

        <StatusActionBar {...this.props} />
      </div>
    );
  }

}
