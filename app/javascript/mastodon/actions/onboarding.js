import { changeSetting, saveSettings } from './settings';
import { setPage as pawooSetPage } from '../../pawoo/actions/page';
import PawooGA from '../../pawoo/actions/ga';

const pawooGaCategory = 'Onboarding';

export function showOnboardingOnce() {
  return (dispatch, getState) => {
    const alreadySeen = getState().getIn(['settings', 'onboarded']);

    if (!alreadySeen || true) {
      dispatch(pawooSetPage('ONBOARDING'));
      dispatch(changeSetting(['onboarded'], true));
      dispatch(saveSettings());

      PawooGA.event({ eventCategory: pawooGaCategory, eventAction: 'Show' });
    }
  };
};
