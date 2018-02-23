import { List as ImmutableList, Map as ImmutableMap } from 'immutable';
import api, { getLinks } from '../../../mastodon/api';
import {
  refreshTimeline,
  refreshTimelineRequest,
  refreshTimelineSuccess,
  refreshTimelineFail,
  expandTimeline,
  expandTimelineRequest,
  expandTimelineSuccess,
  expandTimelineFail,
} from '../../../mastodon/actions/timelines';

export function refreshPinnedStatusTimeline(accountId) {
  return function (dispatch, getState) {
    const timelineId = `account:${accountId}:pinned_status`;
    const timeline = getState().getIn(['timelines', timelineId], ImmutableMap());

    if (timeline.get('isLoading') || (timeline.get('online') && !timeline.get('isPartial'))) {
      return;
    }

    let skipLoading = timeline.get('loaded');

    dispatch(refreshTimelineRequest(timelineId, skipLoading));

    api(getState).get(`/api/v1/accounts/${accountId}/pinned_statuses`).then(response => {
      if (response.status === 206) {
        dispatch(refreshTimelineSuccess(timelineId, [], skipLoading, null, true));
      } else {
        const next = getLinks(response).refs.find(link => link.rel === 'next');
        dispatch(refreshTimelineSuccess(timelineId, response.data, skipLoading, next ? next.uri : null, false));

        // PinnedStatusは表示のために例外的に全件取得する
        if (next) {
          dispatchNextPinnedStatusesTimeline(dispatch, accountId);
        }
      }
    }).catch(error => {
      dispatch(refreshTimelineFail(timelineId, error, skipLoading));
    });
  };
};

export const refreshMediaTimeline = () => refreshTimeline('media', '/api/v1/timelines/public', { local: true, media: true });

export function expandPinnedStatusesTimeline(accountId) {
  return (dispatch, getState) => {
    const timelineId = `account:${accountId}:pinned_status`;
    const timeline = getState().getIn(['timelines', timelineId], ImmutableMap());
    const ids      = timeline.get('items', ImmutableList());

    if (timeline.get('isLoading') || ids.size === 0) {
      return;
    }

    // pinned_statusはソートがID順ではないので、nextを使う
    const nextUrl = timeline.get('next');
    const path = nextUrl || `/api/v1/accounts/${accountId}/pinned_statuses`;

    dispatch(expandTimelineRequest(timelineId));

    api(getState).get(path).then(response => {
      const next = getLinks(response).refs.find(link => link.rel === 'next');
      dispatch(expandTimelineSuccess(timelineId, response.data, next ? next.uri : null));

      // PinnedStatusは表示のために例外的に全件取得する
      if (next) {
        dispatchNextPinnedStatusesTimeline(dispatch, accountId);
      }
    }).catch(error => {
      dispatch(expandTimelineFail(timelineId, error));
    });
  };
};

export const expandMediaTimeline = () => expandTimeline('media', '/api/v1/timelines/public', { local: true, media: true });

// PinnedStatusは表示のために例外的に全件取得する
// 数件のpinしか存在しないユーザーなら、1度目のリクエストで完了している。
// 今後、アクセスが多いかつ大量のPinnedStatusをもつアカウントが現れたら、実装方法を変えるかもしれない
function dispatchNextPinnedStatusesTimeline(dispatch, accountId) {
  setTimeout(() => dispatch(expandPinnedStatusesTimeline(accountId)), 300);
}
