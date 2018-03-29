import { fromJS } from 'immutable';
import { changeSetting } from '../../mastodon/actions/settings';
import initialState from '../../mastodon/initial_state';
import { defaultColumns } from '../../mastodon/reducers/settings';
import uuid from '../../mastodon/uuid';

const pawooOldLayout = fromJS([
  { id: 'COMPOSE', uuid: uuid(), params: {} },
  { id: 'HOME', uuid: uuid(), params: {} },
  { id: 'NOTIFICATIONS', uuid: uuid(), params: {} },
]);

export function upgradeLayout() {
  return (dispatch, getState) => {
    try {
      sessionStorage.setItem('pawoo:columns', JSON.stringify(getState().getIn(['settings', 'columns']).toJS()));
    } catch (e) {
      // [webkit-dev] DOM Storage and private browsing
      // https://lists.webkit.org/pipermail/webkit-dev/2009-May/007788.html
    }

    dispatch(changeSetting(['columns'], defaultColumns));
  };
}

export function upgradeLayoutAutomatically() {
  return (dispatch, getState) => {
    const columns = getState().getIn(['settings', 'columns']);

    if (columns.count() === 3 &&
        columns.every((column, index) => column.get('id') === pawooOldLayout.getIn([index, 'id'])) &&
        initialState.pawoo &&
        initialState.pawoo.last_settings_updated &&
        initialState.pawoo.last_settings_updated < 1522290629) {
      dispatch(upgradeLayout());
    }
  };
}

export function rollbackLayout() {
  const item = sessionStorage.getItem('pawoo:columns');

  return changeSetting(
    ['columns'],
    item === null ? pawooOldLayout : fromJS(JSON.parse(item))
  );
}
