import { combineReducers } from 'redux-immutable';
import timelines from './timelines';
import meta from './meta';
import alerts from './alerts';
import { loadingBarReducer } from 'react-redux-loading-bar';
import modal from './modal';
import user_lists from './user_lists';
import accounts from './accounts';
import accounts_counters from './accounts_counters';
import statuses from './statuses';
import relationships from './relationships';
import settings from './settings';
import push_notifications from './push_notifications';
import status_lists from './status_lists';
import cards from './cards';
import reports from './reports';
import suggested_accounts from './suggested_accounts';
import trend_tags from './trend_tags';
import suggestion_tags from './suggestion_tags';
import contexts from './contexts';
import compose from './compose';
import search from './search';
import media_attachments from './media_attachments';
import notifications from './notifications';
import height_cache from './height_cache';

const reducers = {
  timelines,
  meta,
  alerts,
  loadingBar: loadingBarReducer,
  modal,
  user_lists,
  status_lists,
  accounts,
  accounts_counters,
  statuses,
  relationships,
  settings,
  push_notifications,
  cards,
  reports,
  contexts,
  compose,
  search,
  media_attachments,
  notifications,
  height_cache,
  suggested_accounts,
  trend_tags,
  suggestion_tags,
};

export default combineReducers(reducers);
