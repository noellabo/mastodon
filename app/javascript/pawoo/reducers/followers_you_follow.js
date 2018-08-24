import { Map as ImmutableMap, fromJS } from 'immutable';
import { PAWOO_FOLLOWERS_YOU_FOLLOW_SUCCESS } from '../actions/followers_you_follow';
import { normalizeAccount } from '../../mastodon/actions/importer/normalizer';

const initialState = ImmutableMap();

export default function followerYouFollow(state = initialState, action) {
  if (action.type === PAWOO_FOLLOWERS_YOU_FOLLOW_SUCCESS) {
    return state.set(action.targetAccountId, fromJS(action.accounts.map(account => fromJS(normalizeAccount(account)))));
  };
  return state;
};
