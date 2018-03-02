import Immutable from 'immutable';

import { COLUMN_ADD, COLUMN_REMOVE } from '../../mastodon/actions/columns';
import { COLUMN_HISTORY_PUSH, COLUMN_HISTORY_POP, COLUMN_HISTORY_SAVE_SCROLL } from '../actions/column_histories';
import { STORE_HYDRATE } from '../../mastodon/actions/store';
import { defaultColumns } from '../../mastodon/reducers/settings';

const initialState = Immutable.Map();

const addColumnHistory = (state, uuid, location) => {
  return state.set(uuid, Immutable.Stack([location]));
};

const removeColumnHistory = (state, uuid) => {
  return state.delete(uuid);
};

const pushColumnHistory = (state, column, location) => {
  return state.update(column.get('uuid'), history => history.push(location));
};

const popColumnHistory = (state, column) => {
  return state.update(column.get('uuid'), history => history.pop());
};

const saveScroll = (state, column, key, value) => {
  return state.update(
    column.get('uuid'),
    (history) => {
      return history.map((location) => {
        if (location.get('uuid') === key) return location.set('scrollPosition', value);
        return location;
      });
    }
  );
};

const hydrate = (state, hydratedState = defaultColumns) => {
  state = hydratedState.reduce(
    function(map, item) {
      item = item.set('scrollPosition', Immutable.fromJS([0, 0]));
      return map.set(item.get('uuid'), Immutable.Stack([item]));
    }, Immutable.Map()
  );
  return state;
};

export default function column_histories(state = initialState, action) {
  switch (action.type) {
  case STORE_HYDRATE:
    return hydrate(state, action.state.getIn(['settings', 'columns']));
  case COLUMN_ADD:
    return addColumnHistory(state, action.uuid, Immutable.fromJS({ id: action.id, uuid: action.uuid, params: action.params, scrollPosition: [0, 0] }));
  case COLUMN_REMOVE:
    return removeColumnHistory(state, action.uuid);
  case COLUMN_HISTORY_PUSH:
    return pushColumnHistory(state, action.column, action.location);
  case COLUMN_HISTORY_POP:
    return popColumnHistory(state, action.column);
  case COLUMN_HISTORY_SAVE_SCROLL:
    return saveScroll(state, action.column, action.key, action.value);
  default:
    return state;
  }
}
