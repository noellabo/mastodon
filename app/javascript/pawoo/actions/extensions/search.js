import api from '../../../mastodon/api';
import {
  expandTimelineRequest,
  expandTimelineSuccess,
  expandTimelineFail,
} from '../../../mastodon/actions/timelines';

export const STATUS_SEARCH_TIMELINE_REFRESH_SUCCESS = 'PAWOO_EXTENSION_STATUS_SEARCH_TIMELINE_REFRESH_SUCCESS';
export const STATUS_SEARCH_TIMELINE_EXPAND_SUCCESS  = 'PAWOO_EXTENSION_STATUS_SEARCH_TIMELINE_EXPAND_SUCCESS';

const FETCH_TOOTS_NUM_PER_PAGE = 20;

function calculateHasNext(page, hitsTotal){
  const maxPage = Math.ceil(hitsTotal / FETCH_TOOTS_NUM_PER_PAGE);
  return page <= maxPage;
}

export function refreshStatusSearchTimeline(keyword) {
  return (dispatch, getState) => {
    const timelineId = `status_search:${keyword}`;
    const skipLoading = false;
    const page = 1;

    const params = {
      limit: FETCH_TOOTS_NUM_PER_PAGE,
      page: page,
    };

    dispatch(expandTimelineRequest(timelineId, skipLoading));

    api(getState).get(`/api/v1/search/statuses/${keyword}`, { params }).then(response => {
      const hitsTotal = response.data.hits_total;
      const statuses = hitsTotal > 0 ? response.data.statuses : [];

      dispatch(expandTimelineSuccess(timelineId, statuses, skipLoading, calculateHasNext(page, hitsTotal)));
      dispatch(refreshStatusSearchTimelineSuccess(timelineId, page, hitsTotal));
    }).catch(error => {
      dispatch(expandTimelineFail(keyword, error, skipLoading));
    });
  };
};

export function expandStatusSearchTimeline(keyword) {
  return (dispatch, getState) => {
    const timelineId = `status_search:${keyword}`;
    const hitsTotal = getState().getIn(['timelines', timelineId, 'hitsTotal']);
    const page = getState().getIn(['timelines', timelineId, 'page']) + 1;
    const next = calculateHasNext(page, hitsTotal);

    if(!next){
      return;
    }

    dispatch(expandTimelineRequest(timelineId));

    api(getState).get(`/api/v1/search/statuses/${keyword}`, {
      params: {
        limit: FETCH_TOOTS_NUM_PER_PAGE,
        page,
      },
    }).then(response => {
      const statuses = hitsTotal > 0 ? response.data.statuses : [];
      dispatch(expandTimelineSuccess(timelineId, statuses, calculateHasNext(page, hitsTotal)));
      dispatch(expandStatusSearchTimelineSuccess(timelineId, page));
    }).catch(error => {
      dispatch(expandTimelineFail(timelineId, error));
    });
  };
};

export function refreshStatusSearchTimelineSuccess(timeline, page, hitsTotal) {
  return {
    type: STATUS_SEARCH_TIMELINE_REFRESH_SUCCESS,
    timeline,
    page,
    hitsTotal,
  };
};

export function expandStatusSearchTimelineSuccess(timeline, page) {
  return {
    type: STATUS_SEARCH_TIMELINE_EXPAND_SUCCESS,
    timeline,
    page,
  };
};
