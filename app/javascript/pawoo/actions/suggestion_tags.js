import axios from 'axios';

export const SUGGESTION_TAGS_SUCCESS = 'PAWOO_SUGGESTION_TAGS_SUCCESS';
export const SUGGESTION_TAGS_FAIL = 'PAWOO_SUGGESTION_TAGS_FAIL';

export function refreshSuggestionTags(type) {
  return (dispatch) => {
    axios.get('/api/v1/suggestion_tags', { params: { type } })
      .then(response => {
        dispatch(refreshSuggestionTagsSuccess(type, response.data));
      })
      .catch(error => {
        dispatch(refreshSuggestionTagsFail(error));
      });
  };
}

export function refreshSuggestionTagsSuccess(suggestion_type, tags) {
  return {
    type: SUGGESTION_TAGS_SUCCESS,
    suggestion_type,
    tags,
  };
}

export function refreshSuggestionTagsFail(error) {
  return {
    type: SUGGESTION_TAGS_FAIL,
    error,
  };
}
