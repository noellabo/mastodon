import {
  FAVOURITED_STATUSES_FETCH_REQUEST,
  FAVOURITED_STATUSES_FETCH_SUCCESS,
  FAVOURITED_STATUSES_FETCH_FAIL,
  FAVOURITED_STATUSES_EXPAND_REQUEST,
  FAVOURITED_STATUSES_EXPAND_SUCCESS,
  FAVOURITED_STATUSES_EXPAND_FAIL,
} from '../actions/favourites';
import {
  PINNED_STATUSES_FETCH_SUCCESS,
} from '../actions/pin_statuses';
import {
  SCHEDULED_STATUSES_FETCH_SUCCESS as PAWOO_SCHEDULED_STATUSES_FETCH_SUCCESS,
  SCHEDULED_STATUSES_EXPAND_SUCCESS as PAWOO_SCHEDULED_STATUSES_EXPAND_SUCCESS,
  SCHEDULED_STATUSES_ADDITION as PAWOO_SCHEDULED_STATUSES_ADDITION,
} from '../../pawoo/actions/schedules';
import { Map as ImmutableMap, List as ImmutableList } from 'immutable';
import {
  FAVOURITE_SUCCESS,
  UNFAVOURITE_SUCCESS,
  PIN_SUCCESS,
  UNPIN_SUCCESS,
} from '../actions/interactions';

const initialState = ImmutableMap({
  favourites: ImmutableMap({
    next: null,
    loaded: false,
    items: ImmutableList(),
  }),
  pins: ImmutableMap({
    next: null,
    loaded: false,
    items: ImmutableList(),
  }),
  pawooSchedules: ImmutableMap({
    next: null,
    loaded: false,
    items: ImmutableList(),
  }),
});

const pawooInsertToDateSortedList = (state, listType, statuses, allStatuses) => {
  return state.update(listType, listMap => listMap.withMutations(map => {
    const compare = (i, j) => {
      if (i.created_at < j.created_at) {
        return -1;
      } else if (i.created_at > j.created_at) {
        return 1;
      } else {
        return 0;
      }
    };

    map.set('items', map.get('items')
      .map(id => ({ id, created_at: allStatuses.getIn([id, 'created_at']) }))
      .concat(statuses)
      .sort(compare)
      .map(item => item.id));
  }));
};

const normalizeList = (state, listType, statuses, next) => {
  return state.update(listType, listMap => listMap.withMutations(map => {
    map.set('next', next);
    map.set('loaded', true);
    map.set('isLoading', false);
    map.set('items', ImmutableList(statuses.map(item => item.id)));
  }));
};

const appendToList = (state, listType, statuses, next) => {
  return state.update(listType, listMap => listMap.withMutations(map => {
    map.set('next', next);
    map.set('isLoading', false);
    map.set('items', map.get('items').concat(statuses.map(item => item.id)));
  }));
};

const prependOneToList = (state, listType, status) => {
  return state.update(listType, listMap => listMap.withMutations(map => {
    map.set('items', map.get('items').unshift(status.get('id')));
  }));
};

const removeOneFromList = (state, listType, status) => {
  return state.update(listType, listMap => listMap.withMutations(map => {
    map.set('items', map.get('items').filter(item => item !== status.get('id')));
  }));
};

export default function statusLists(state = initialState, action) {
  switch(action.type) {
  case FAVOURITED_STATUSES_FETCH_REQUEST:
  case FAVOURITED_STATUSES_EXPAND_REQUEST:
    return state.setIn(['favourites', 'isLoading'], true);
  case FAVOURITED_STATUSES_FETCH_FAIL:
  case FAVOURITED_STATUSES_EXPAND_FAIL:
    return state.setIn(['favourites', 'isLoading'], false);
  case FAVOURITED_STATUSES_FETCH_SUCCESS:
    return normalizeList(state, 'favourites', action.statuses, action.next);
  case FAVOURITED_STATUSES_EXPAND_SUCCESS:
    return appendToList(state, 'favourites', action.statuses, action.next);
  case PAWOO_SCHEDULED_STATUSES_FETCH_SUCCESS:
    return normalizeList(state, 'pawooSchedules', action.statuses, action.next);
  case PAWOO_SCHEDULED_STATUSES_EXPAND_SUCCESS:
    return appendToList(state, 'pawooSchedules', action.statuses, action.next);
  case PAWOO_SCHEDULED_STATUSES_ADDITION:
    return pawooInsertToDateSortedList(state, 'pawooSchedules', action.statuses, action.allStatuses);
  case FAVOURITE_SUCCESS:
    return prependOneToList(state, 'favourites', action.status);
  case UNFAVOURITE_SUCCESS:
    return removeOneFromList(state, 'favourites', action.status);
  case PINNED_STATUSES_FETCH_SUCCESS:
    return normalizeList(state, 'pins', action.statuses, action.next);
  case PIN_SUCCESS:
    return prependOneToList(state, 'pins', action.status);
  case UNPIN_SUCCESS:
    return removeOneFromList(state, 'pins', action.status);
  default:
    return state;
  }
};
