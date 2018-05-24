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

export function changeLayoutAutomatically() {
  return (dispatch, getState) => {
    const columns = getState().getIn(['settings', 'columns']);

    if (initialState.pawoo) {
      if ((initialState.pawoo.last_settings_updated < 1522290629 &&
            columns.count() === 3 &&
            columns.every((column, index) => column.get('id') === pawooOldLayout.getIn([index, 'id']))) ||
          (initialState.pawoo.last_settings_updated < 1524043770 &&
            columns.count() === 1)) {
        dispatch(changeSetting(['columns'], defaultColumns));
      } else if (initialState.pawoo.last_settings_updated > 1522290629 &&
                 initialState.pawoo.last_settings_updated < 1524043770) {
        dispatch(changeSetting(['pawoo', 'multiColumn'], true));
      }
    }
  };
}
