import {
  PAWOO_REPORT_INIT,
  PAWOO_REPORT_SUBMIT_REQUEST,
  PAWOO_REPORT_SUBMIT_SUCCESS,
  PAWOO_REPORT_SUBMIT_FAIL,
  PAWOO_REPORT_CANCEL,
  PAWOO_REPORT_STATUS_TOGGLE,
  PAWOO_REPORT_COMMENT_CHANGE,
  PAWOO_REPORT_FORWARD_CHANGE,
  PAWOO_REPORT_TYPE_CHANGE,
} from '../actions/reports';
import { Map as ImmutableMap, Set as ImmutableSet } from 'immutable';

const initialState = ImmutableMap({
  new: ImmutableMap({
    isSubmitting: false,
    account_id: null,
    status_ids: ImmutableSet(),
    comment: '',
    forward: false,
    report_type: null,
  }),
});

export default function reports(state = initialState, action) {
  switch(action.type) {
  case PAWOO_REPORT_INIT:
    return state.withMutations(map => {
      map.setIn(['new', 'isSubmitting'], false);
      map.setIn(['new', 'account_id'], action.account.get('id'));

      if (state.getIn(['new', 'account_id']) !== action.account.get('id')) {
        map.setIn(['new', 'status_ids'], action.status ? ImmutableSet([action.status.getIn(['reblog', 'id'], action.status.get('id'))]) : ImmutableSet());
        map.setIn(['new', 'comment'], '');
        map.setIn(['new', 'report_type'], null);
      } else if (action.status) {
        map.updateIn(['new', 'status_ids'], ImmutableSet(), set => set.add(action.status.getIn(['reblog', 'id'], action.status.get('id'))));
      }
    });
  case PAWOO_REPORT_STATUS_TOGGLE:
    return state.updateIn(['new', 'status_ids'], ImmutableSet(), set => {
      if (action.checked) {
        return set.add(action.statusId);
      }

      return set.remove(action.statusId);
    });
  case PAWOO_REPORT_COMMENT_CHANGE:
    return state.setIn(['new', 'comment'], action.comment);
  case PAWOO_REPORT_FORWARD_CHANGE:
    return state.setIn(['new', 'forward'], action.forward);
  case PAWOO_REPORT_TYPE_CHANGE:
    return state.setIn(['new', 'report_type'], action.reportType);
  case PAWOO_REPORT_SUBMIT_REQUEST:
    return state.setIn(['new', 'isSubmitting'], true);
  case PAWOO_REPORT_SUBMIT_FAIL:
    return state.setIn(['new', 'isSubmitting'], false);
  case PAWOO_REPORT_CANCEL:
  case PAWOO_REPORT_SUBMIT_SUCCESS:
    return state.withMutations(map => {
      map.setIn(['new', 'account_id'], null);
      map.setIn(['new', 'status_ids'], ImmutableSet());
      map.setIn(['new', 'comment'], '');
      map.setIn(['new', 'isSubmitting'], false);
      map.setIn(['new', 'report_type'], 'other');
    });
  default:
    return state;
  }
};
