import {
  refreshTimeline,
  expandTimeline,
} from '../../../mastodon/actions/timelines';

export const refreshMediaTimeline = () => refreshTimeline('media', '/api/v1/timelines/public', { local: true, media: true });

export const expandMediaTimeline = () => expandTimeline('media', '/api/v1/timelines/public', { local: true, media: true });
