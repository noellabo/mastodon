import { combineReducers } from 'redux-immutable';
import suggested_accounts from './suggested_accounts';

const reducers = {
  suggested_accounts,
};

export default combineReducers(reducers);
