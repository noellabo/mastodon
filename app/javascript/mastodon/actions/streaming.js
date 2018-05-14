import { connectStream } from '../stream';
import {
  updateTimeline,
  deleteFromTimelines,
  expandHomeTimeline,
  disconnectTimeline,
} from './timelines';
import { updateNotifications, expandNotifications } from './notifications';
import { getLocale } from '../locales';

const { messages } = getLocale();

export function connectTimelineStream (timelineId, path, { pawooShouldUpdateTimeline = null, pollingRefresh = null } = {}) {

  return connectStream (path, pollingRefresh, (dispatch, getState) => {
    const locale = getState().getIn(['meta', 'locale']);
    return {
      onDisconnect() {
        dispatch(disconnectTimeline(timelineId));
      },

      onReceive (data) {
        switch(data.event) {
        case 'update':
          const status = JSON.parse(data.payload);
          if (!pawooShouldUpdateTimeline || pawooShouldUpdateTimeline(status)) {
            dispatch(updateTimeline(timelineId, status));
          }
          break;
        case 'delete':
          dispatch(deleteFromTimelines(data.payload));
          break;
        case 'notification':
          dispatch(updateNotifications(JSON.parse(data.payload), messages, locale));
          break;
        }
      },
    };
  });
}

function refreshHomeTimelineAndNotification (dispatch) {
  dispatch(expandHomeTimeline());
  dispatch(expandNotifications());
}

function pawooHasMediaAttachment (status) {
  return status.media_attachments.length > 0;
}

export const connectUserStream = () => connectTimelineStream('home', 'user', { pollingRefresh: refreshHomeTimelineAndNotification });
export const connectCommunityStream = () => connectTimelineStream('community', 'public:local');
export const connectMediaStream = () => connectTimelineStream('media', 'public:local', { pawooShouldUpdateTimeline: pawooHasMediaAttachment });
export const connectPublicStream = () => connectTimelineStream('public', 'public');
export const connectHashtagStream = (tag) => connectTimelineStream(`hashtag:${tag}`, `hashtag&tag=${tag}`);
export const connectDirectStream = () => connectTimelineStream('direct', 'direct');
export const connectListStream = (id) => connectTimelineStream(`list:${id}`, `list&list=${id}`);
