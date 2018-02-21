import { combineReducers } from 'redux-immutable';
import suggested_accounts from './suggested_accounts';
import reports from './reports';

const reducers = {
  suggested_accounts,
  reports,
};

export default combineReducers(reducers);
