import { expandTimeline } from '../../../mastodon/actions/timelines';

export const expandMediaTimeline = () => expandTimeline('media', '/api/v1/timelines/public', { local: true, media: true });
