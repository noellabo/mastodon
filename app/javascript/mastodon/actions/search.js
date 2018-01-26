import api from '../api';
import PawooGA from '../../pawoo/actions/ga';

import {
  refreshTimelineRequest,
  refreshTimelineSuccess,
  refreshTimelineFail,
  expandTimelineRequest,
  expandTimelineSuccess,
  expandTimelineFail,
} from './timelines';

const pawooGaCategory = 'Search';

export const SEARCH_CHANGE = 'SEARCH_CHANGE';
export const SEARCH_CLEAR  = 'SEARCH_CLEAR';
export const SEARCH_SHOW   = 'SEARCH_SHOW';

export const SEARCH_FETCH_REQUEST = 'SEARCH_FETCH_REQUEST';
export const SEARCH_FETCH_SUCCESS = 'SEARCH_FETCH_SUCCESS';
export const SEARCH_FETCH_FAIL    = 'SEARCH_FETCH_FAIL';

export const STATUS_SEARCH_TIMELINE_REFRESH_SUCCESS = 'STATUS_SEARCH_TIMELINE_REFRESH_SUCCESS';
export const STATUS_SEARCH_TIMELINE_EXPAND_SUCCESS  = 'STATUS_SEARCH_TIMELINE_EXPAND_SUCCESS';

const FETCH_TOOTS_NUM_PER_PAGE = 20;

export function changeSearch(value) {
  return {
    type: SEARCH_CHANGE,
    value,
  };
};

export function clearSearch() {
  return {
    type: SEARCH_CLEAR,
  };
};

export function submitSearch() {
  return (dispatch, getState) => {
    const value = getState().getIn(['search', 'value']);

    if (value.length === 0) {
      return;
    }

    dispatch(fetchSearchRequest());

    PawooGA.event({ category: pawooGaCategory, action: 'Submit' });

    api(getState).get('/api/v1/search', {
      params: {
        q: value,
        resolve: true,
      },
    }).then(response => {
      dispatch(fetchSearchSuccess(response.data));
    }).catch(error => {
      dispatch(fetchSearchFail(error));
    });
  };
};

export function fetchSearchRequest() {
  return {
    type: SEARCH_FETCH_REQUEST,
  };
};

export function fetchSearchSuccess(results) {
  return {
    type: SEARCH_FETCH_SUCCESS,
    results,
    accounts: results.accounts,
    statuses: results.statuses,
  };
};

export function fetchSearchFail(error) {
  return {
    type: SEARCH_FETCH_FAIL,
    error,
  };
};

export function showSearch() {
  return {
    type: SEARCH_SHOW,
  };
};

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

    dispatch(refreshTimelineRequest(timelineId, skipLoading));

    api(getState).get(`/api/v1/search/statuses/${keyword}`, { params }).then(response => {
      const hitsTotal = response.data.hits_total;
      const statuses = hitsTotal > 0 ? response.data.statuses : [];

      dispatch(refreshTimelineSuccess(timelineId, statuses, skipLoading, calculateHasNext(page, hitsTotal)));
      dispatch(refreshStatusSearchTimelineSuccess(timelineId, page, hitsTotal));
    }).catch(error => {
      dispatch(refreshTimelineFail(keyword, error, skipLoading));
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
