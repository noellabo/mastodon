import { setPage } from './page';
import api from '../../mastodon/api';
import PawooGA from './ga';

export const FIRST_ANNIVERSARY_PUSH_MARGIN = 'FIRST_ANNIVERSARY_PUSH_MARGIN';
export const FIRST_ANNIVERSARY_SHIFT_FROM_TIMELINE = 'FIRST_ANNIVERSARY_SHIFT_FROM_TIMELINE';
export const FIRST_ANNIVERSARY_INITIALIZE_TIMELINE = 'FIRST_ANNIVERSARY_INITIALIZE_TIMELINE';
export const FIRST_ANNIVERSARY_INSERT_TIMELINE = 'FIRST_ANNIVERSARY_INSERT_TIMELINE';

const pawooGaCategory = 'FirstAnniversary';
const domParser = new DOMParser();
const april14 = 1523631600000;

export function startFirstAnniversary(status) {
  return (dispatch) => {
    if (Math.floor((new Date()).getTime()) < april14) {
      return;
    }

    const command = domParser.parseFromString(status.content, 'text/html').documentElement.textContent.trim()
      .replace(/[・ ]/g, '')
      .replace(/↑/g, '上')
      .replace(/↓/g, '下')
      .replace(/←/g, '左')
      .replace(/→/g, '右')
      .replace(/[aａＡ]/g, 'A')
      .replace(/[bｂＢ]/g, 'B');

    if (command !== '上上下下左右左右BA') {
      return;
    }

    PawooGA.event({ eventCategory: pawooGaCategory, eventAction: 'Start' });
    dispatch(setPage('PAWOO_FIRST_ANNIVERSARY'));
  };
}

export function insertOwnStatus(status) {
  return (dispatch) => {
    const titles = document.querySelector('.pawoo-first-anniversary-column__titles');

    if (!titles) {
      return;
    }

    const titlesHeight = document.querySelector('.pawoo-first-anniversary-column__titles').offsetHeight;
    let contentHeight = 0;

    const index = [].findIndex.call(document.querySelectorAll('.pawoo-first-anniversary-column__titlecontent > div'), (content) => {
      contentHeight += content.offsetHeight;
      return contentHeight > titlesHeight;
    });

    dispatch({
      type: FIRST_ANNIVERSARY_INSERT_TIMELINE,
      index: index < 0 ? 15 : index + 3, // 対象の2つ下
      status,
    });
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
