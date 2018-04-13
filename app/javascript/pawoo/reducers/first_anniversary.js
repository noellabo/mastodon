import { List as ImmutableList, Map as ImmutableMap } from 'immutable';
import {  TIMELINE_UPDATE } from '../../mastodon/actions/timelines';
import {
  FIRST_ANNIVERSARY_INITIALIZE_TIMELINE,
  FIRST_ANNIVERSARY_PUSH_MARGIN,
  FIRST_ANNIVERSARY_SHIFT_FROM_TIMELINE,
} from '../actions/first_anniversary';
import { me } from '../../mastodon/initial_state';

const initialState = ImmutableMap({
  statusIds: ImmutableList(),
  margin: 0,
});

let marginCounter = 0;

export default function firstAnniversary(state = initialState, action) {
  switch (action.type) {
  case FIRST_ANNIVERSARY_INITIALIZE_TIMELINE:
    return state.withMutations(mMap => {
      mMap.set('statusIds', ImmutableList(action.statuses.map((status) => status.id)).reverse());
      mMap.set('margin', 0);
    });
  case TIMELINE_UPDATE:
    if (action.timeline !== 'community') {
      return state;
    }

    const statusId = action.status.id;
    if (action.status.account.id === me) {
      return state.update('statusIds', list => list.includes(statusId) ? list : list.insert(15, statusId));
    }

    return state.update('statusIds', list => list.includes(statusId) ? list : list.push(statusId));
  case FIRST_ANNIVERSARY_PUSH_MARGIN:
    return state.update('statusIds', list => list.push(`margin-${marginCounter++}`));
  case FIRST_ANNIVERSARY_SHIFT_FROM_TIMELINE:
    return state.withMutations(mMap => {
      mMap.update('statusIds', list => list.shift());
      mMap.update('margin', margin => margin + action.height);
    });
  default:
    return state;
  }
}
