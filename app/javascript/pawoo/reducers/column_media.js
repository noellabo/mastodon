import Immutable from 'immutable';
import { COLUMN_MEDIA_RESIZE } from '../actions/column_media';

const initialState = Immutable.Map({
  scale: null,
  single: null,
  wide: null,
});

function resize(state, { columnCount, defaultPage, single: givenSingle, window: givenWindow }) {
  const single = state.get('single') || givenSingle;
  let scale;
  let wide;

  if (single) {
    wide = givenWindow.innerWidth - 30 < givenWindow.innerHeight / 2;

    if (wide) {
      scale = 'calc(100vw - 100px)';
    } else {
      scale = 'calc(50vh - 70px)';
    }
  } else {
    const widthCandidate = (givenWindow.innerWidth - 300) / columnCount;
    const width = Math.max(widthCandidate, 330);
    wide = !defaultPage || Math.min(width, 400) < givenWindow.innerHeight;

    if (!defaultPage || widthCandidate < 330) {
      scale = '230px';
    } else if (!wide) {
      scale = '50vh';
    } else if (width > 500) {
      scale = '400px';
    } else {
      scale = `calc((100vw - 300px)/${columnCount} - 100px)`;
    }
  }

  return state.merge({ scale, single, wide });
}

export default function columnMedia(state = initialState, action) {
  switch (action.type) {
  case COLUMN_MEDIA_RESIZE:
    return resize(state, action);
  default:
    return state;
  }
}
