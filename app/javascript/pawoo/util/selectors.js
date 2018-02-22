import { fromJS } from 'immutable';
import uuid from '../../mastodon/uuid';

const pages = fromJS({
  ONBOARDING: [
    { id: 'PAWOO_ONBOARDING', uuid: uuid(), params: {} },
  ],
  SUGGESTED_ACCOUNTS: [
    { id: 'COMPOSE', uuid: uuid(), params: {} },
    { id: 'PAWOO_SUGGESTED_ACCOUNTS', uuid: uuid(), params: {} },
  ],
});

export function getColumns(state) {
  const page = state.getIn(['pawoo', 'page']);

  if (page === 'DEFAULT') {
    return state.getIn(['settings', 'columns']);
  }

  return pages.get(page);
}
