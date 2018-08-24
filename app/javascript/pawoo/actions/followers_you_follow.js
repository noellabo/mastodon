import api from '../../mastodon/api';

export const PAWOO_FOLLOWERS_YOU_FOLLOW_SUCCESS = 'PAWOO_FOLLOWERS_YOU_FOLLOW_SUCCESS';

export function fetchFollowersYouFollow(targetAccountId) {
  return (dispatch, getState) => {
    api(getState).get(`/api/v1/followers_you_follow/${targetAccountId}`).then(response => {
      dispatch(fetchFollowersYouFollowSuccess(targetAccountId, response.data));
    }).catch(e => console.warn(e));
  };
};

export function fetchFollowersYouFollowSuccess(targetAccountId, accounts) {
  return {
    type: PAWOO_FOLLOWERS_YOU_FOLLOW_SUCCESS,
    accounts,
    targetAccountId,
  };
};
