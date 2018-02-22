import { changeSetting, saveSettings } from './settings';
import { setPage as pawooSetPage } from '../../pawoo/actions/page';

export function showOnboardingOnce() {
  return (dispatch, getState) => {
    const alreadySeen = getState().getIn(['settings', 'onboarded']);

    if (!alreadySeen) {
      dispatch(pawooSetPage('ONBOARDING'));
      dispatch(changeSetting(['onboarded'], true));
      dispatch(saveSettings());
    }
  };
};
