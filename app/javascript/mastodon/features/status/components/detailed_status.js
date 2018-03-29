import React from 'react';
import PropTypes from 'prop-types';
import Immutable from 'immutable';
import ImmutablePropTypes from 'react-immutable-proptypes';
import Avatar from '../../../components/avatar';
import DisplayName from '../../../components/display_name';
import StatusContent from '../../../components/status_content';
import MediaGallery from '../../../components/media_gallery';
import AttachmentList from '../../../components/attachment_list';
import Link from '../../../../pawoo/components/wrapped_link';
import { FormattedDate, FormattedNumber } from 'react-intl';
import CardContainer from '../containers/card_container';
import ImmutablePureComponent from 'react-immutable-pure-component';
import Video from '../../video';

export default class DetailedStatus extends ImmutablePureComponent {

  static contextTypes = {
    router: PropTypes.object,
    pawooPushHistory: PropTypes.func,
  };

  static propTypes = {
    status: ImmutablePropTypes.map.isRequired,
    onOpenMedia: PropTypes.func.isRequired,
    onOpenVideo: PropTypes.func.isRequired,
  };

  handleAccountClick = (e) => {
    if (e.button === 0) {
      e.preventDefault();
      this.context.pawooPushHistory(`/accounts/${this.props.status.getIn(['account', 'id'])}`);
    }

    e.stopPropagation();
  }

  handleOpenVideo = startTime => {
    this.props.onOpenVideo(this.props.status.getIn(['media_attachments', 0]), startTime);
  }

  render () {
    const status = this.props.status.get('reblog') ? this.props.status.get('reblog') : this.props.status;

    let media           = '';
    let applicationLink = '';
    let reblogLink = '';
    let reblogIcon = 'retweet';

    let attachments = status.get('media_attachments');
    if (attachments.size === 0 && status.getIn(['pixiv_cards'], Immutable.List()).size > 0) {
      attachments = status.get('pixiv_cards').map(card => {
        return Immutable.fromJS({
          id: Math.random().toString(),
          preview_url: card.get('image_url'),
          remote_url: '',
          text_url: card.get('url'),
          type: 'image',
          url: card.get('image_url'),
        });
      });
    }

    if (attachments.size > 0) {
      if (attachments.some(item => item.get('type') === 'unknown')) {
        media = <AttachmentList media={attachments} />;
      } else if (attachments.first().get('type') === 'video') {
        const video = attachments.first();

        media = (
          <Video
            preview={video.get('preview_url')}
            src={video.get('url')}
            height='50vh'
            onOpenVideo={this.handleOpenVideo}
            sensitive={status.get('sensitive')}
          />
        );
      } else {
        media = (
          <MediaGallery
            sensitive={status.get('sensitive')}
            media={attachments}
            onOpenMedia={this.props.onOpenMedia}
            pawooScale='50vh'
          />
        );
      }
    } else if (status.get('spoiler_text').length === 0) {
      media = <CardContainer onOpenMedia={this.props.onOpenMedia} statusId={status.get('id')} />;
    }

    if (status.get('application')) {
      applicationLink = <span> · <a className='detailed-status__application' href={status.getIn(['application', 'website'])} target='_blank' rel='noopener'>{status.getIn(['application', 'name'])}</a></span>;
    }

    if (status.get('visibility') === 'direct') {
      reblogIcon = 'envelope';
    } else if (status.get('visibility') === 'private') {
      reblogIcon = 'lock';
    }

    if (status.get('visibility') === 'private') {
      reblogLink = <i className={`fa fa-${reblogIcon}`} />;
    } else {
      reblogLink = (<Link to={`/statuses/${status.get('id')}/reblogs`} className='detailed-status__link'>
        <i className={`fa fa-${reblogIcon}`} />
        <span className='detailed-status__reblogs'>
          <FormattedNumber value={status.get('reblogs_count')} />
        </span>
      </Link>);
    }

    return (
      <div className='detailed-status'>
        <a href={status.getIn(['account', 'url'])} onClick={this.handleAccountClick} className='detailed-status__display-name'>
          <div className='detailed-status__display-avatar'><Avatar account={status.get('account')} size={48} /></div>
          <DisplayName account={status.get('account')} />
        </a>

        <StatusContent status={status} />

        {media}

        <div className='detailed-status__meta'>
          <a className='detailed-status__datetime' href={status.get('url')} target='_blank' rel='noopener'>
            <FormattedDate value={new Date(status.get('created_at'))} hour12={false} year='numeric' month='short' day='2-digit' hour='2-digit' minute='2-digit' />
          </a>{applicationLink} · {reblogLink} · <Link to={`/statuses/${status.get('id')}/favourites`} className='detailed-status__link'>
            <i className='fa fa-star' />
            <span className='detailed-status__favorites'>
              <FormattedNumber value={status.get('favourites_count')} />
            </span>
          </Link>
        </div>
      </div>
    );
  }

}
