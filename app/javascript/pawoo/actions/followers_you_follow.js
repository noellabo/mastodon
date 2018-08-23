import axios from 'axios';

export const FOLLOWERS_YOU_FOLLOW_SUCCESS = 'FOLLOWERS_YOU_FOLLOW_SUCCESS';

export function fetchFollowersYouFollow(targetAccountId) {
  return (dispatch) => {
    axios.get(`/api/v1/followers_you_follow/${targetAccountId}`).then(response => {
      dispatch(fetchFollowersYouFollowSuccess(response.data));
    }).catch(e => console.warn(e));
  };
};

export function fetchFollowersYouFollowSuccess(accounts) {
  return {
    type: FOLLOWERS_YOU_FOLLOW_SUCCESS,
    accounts,
  };
};
