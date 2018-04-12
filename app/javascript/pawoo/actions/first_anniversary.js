import { setPage } from './page';
import api from '../../mastodon/api';
import PawooGA from './ga';

export const FIRST_ANNIVERSARY_PUSH_MARGIN = 'FIRST_ANNIVERSARY_PUSH_MARGIN';
export const FIRST_ANNIVERSARY_SHIFT_FROM_TIMELINE = 'FIRST_ANNIVERSARY_SHIFT_FROM_TIMELINE';
export const FIRST_ANNIVERSARY_INITIALIZE_TIMELINE = 'FIRST_ANNIVERSARY_INITIALIZE_TIMELINE';

const pawooGaCategory = 'FirstAnniversary';
const domParser = new DOMParser();
const april14 = 1523631600000;

export function startFirstAnniversary(status) {
  return (dispatch) => {
    if (Math.floor((new Date()).getTime()) < april14) {
      return;
    }

    const command = domParser.parseFromString(status.content, 'text/html').documentElement.textContent.trim()
      .replace('・', '')
      .replace(' ', '')
      .replace(' ', '')
      .replace('　', '')
      .replace('↑', '上')
      .replace('↓', '下')
      .replace('←', '左')
      .replace('→', '右')
      .replace('a', 'A')
      .replace('ａ', 'A')
      .replace('Ａ', 'A')
      .replace('b', 'B')
      .replace('ｂ', 'B')
      .replace('Ｂ', 'B');

    if (command !== '上上下下左右左右BA') {
      return;
    }

    PawooGA.event({ eventCategory: pawooGaCategory, eventAction: 'Start' });
    dispatch(setPage('PAWOO_FIRST_ANNIVERSARY'));
  };
}

export function initializeTimeline() {
  return function (dispatch, getState) {
    api(getState).get('/api/v1/timelines/public', { params: { local: true } }).then(response => {
      dispatch({
        type: FIRST_ANNIVERSARY_INITIALIZE_TIMELINE,
        statuses: response.status === 206 ? [] : response.data,
      });
    }).catch(error => {
      console.error(error);
    });
  };
};

export function pushMargin() {
  return {
    type: FIRST_ANNIVERSARY_PUSH_MARGIN,
  };
}

export function shiftFromTimeline (height) {
  return {
    type: FIRST_ANNIVERSARY_SHIFT_FROM_TIMELINE,
    height,
  };
}
