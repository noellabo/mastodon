import { combineReducers } from 'redux-immutable';
import page from './page';
import suggested_accounts from './suggested_accounts';
import reports from './reports';

const reducers = {
  page,
  suggested_accounts,
  reports,
};

export default combineReducers(reducers);
