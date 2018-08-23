import { List as ImmutableList, fromJS } from 'immutable';
import { FOLLOWERS_YOU_FOLLOW_SUCCESS } from '../actions/followers_you_follow';
import { normalizeAccount } from '../../mastodon/actions/importer/normalizer';

const initialState = ImmutableList();

export default function followerYouFollow(state = initialState, action) {
  if (action.type === FOLLOWERS_YOU_FOLLOW_SUCCESS) {
    state = fromJS(action.accounts.map(account => fromJS(normalizeAccount(account))));
  };
  return state;
};
