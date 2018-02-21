import axios from 'axios';

export const TREND_TAGS_SUCCESS = 'TREND_TAGS_SUCCESS';

export function refreshTrendTags() {
  return (dispatch) => {
    axios.get('/api/v1/trend_tags?limit=7')
      .then(response => {
        dispatch(refreshTrendTagsSuccess(response.data));
      });
  };
}

export function refreshTrendTagsSuccess(tags) {
  return {
    type: TREND_TAGS_SUCCESS,
    tags,
  };
}
