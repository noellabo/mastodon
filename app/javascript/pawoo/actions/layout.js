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
  return dispatch => {
    sessionStorage.removeItem('pawoo:columns');
    dispatch(changeSetting(['pawoo', 'multiColumn'], false));
  };
}

export function changeLayoutAutomatically() {
  return (dispatch, getState) => {
    const columns = getState().getIn(['settings', 'columns']);

    if (initialState.pawoo) {
      if ((initialState.pawoo.last_settings_updated < 1522290629 &&
            columns.count() === 3 &&
            columns.every((column, index) => column.get('id') === pawooOldLayout.getIn([index, 'id']))) ||
          (initialState.pawoo.last_settings_updated < 1524038370 &&
            columns.count() === 1)) {
        try {
          sessionStorage.setItem('pawoo:columns', JSON.stringify(getState().getIn(['settings', 'columns']).toJS()));
        } catch (e) {
          // [webkit-dev] DOM Storage and private browsing
          // https://lists.webkit.org/pipermail/webkit-dev/2009-May/007788.html
        }

        dispatch(changeSetting(['columns'], defaultColumns));
      } else if (initialState.pawoo.last_settings_updated > 1522290629 &&
                 initialState.pawoo.last_settings_updated < 1524038370) {
        dispatch(changeSetting(['pawoo', 'multiColumn'], true));
      }
    }
  };
}

export function rollbackLayout() {
  return dispatch => {
    const item = sessionStorage.getItem('pawoo:columns');

    if (item !== null) {
      dispatch(changeSetting(['columns'], fromJS(JSON.parse(item))));
    }

    dispatch(changeSetting(['pawoo', 'multiColumn'], true));
  };
}
