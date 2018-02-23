import { SUGGESTION_TAGS_SUCCESS } from '../actions/suggestion_tags';
import Immutable from 'immutable';

const initialState = Immutable.Map({
  tags: Immutable.List(),
});

export default function trendtags(state = initialState, action) {
  switch(action.type) {
  case SUGGESTION_TAGS_SUCCESS:
    return state.set(action.suggestion_type, Immutable.fromJS(action.tags));
  default:
    return state;
  }
}
