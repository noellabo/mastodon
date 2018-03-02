import { fromJS } from 'immutable';

import uuid from '../../mastodon/uuid';

export const COLUMN_HISTORY_PUSH = 'PAWOO_COLUMN_HISTORY_PUSH';
export const COLUMN_HISTORY_POP = 'PAWOO_COLUMN_HISTORY_POP';
export const COLUMN_HISTORY_SAVE_SCROLL = 'PAWOO_COLUMN_HISTORY_SAVE_SCROLL';

export function pushColumnHistory(column, id, params) {
  const location = fromJS({
    id,
    params,
    uuid: uuid(),
    scrollPosition: [0, 0],
  });
  return {
    type: COLUMN_HISTORY_PUSH,
    column: column,
    location: location,
  };
}

export function popColumnHistory(column) {
  return {
    type: COLUMN_HISTORY_POP,
    column: column,
  };
}

export function saveScrollToStore(column, key, value) {
  return {
    type: COLUMN_HISTORY_SAVE_SCROLL,
    column: column,
    key: key,
    value: fromJS(value),
  };
}
