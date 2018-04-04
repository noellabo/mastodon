import Immutable from 'immutable';
import { COLUMN_MEDIA_RESIZE } from '../actions/column_media';

const initialState = Immutable.Map({
  scale: null,
  single: null,
  wide: null,
});

function resize(state, { columnCount, defaultPage, single: givenSingle, window: givenWindow }) {
  const single = state.get('single') || givenSingle;
  const widthCandidate = (givenWindow.innerWidth - 300) / columnCount;
  const width = single ? givenWindow.innerWidth : Math.max(widthCandidate, 330);
  const wide = !defaultPage || width < givenWindow.innerHeight;
  let scale;

  if (!defaultPage || (!single && widthCandidate < 330)) {
    scale = '230px';
  } else if (!wide) {
    scale = '50vh';
  } else if (single) {
    scale = 'calc(50vw - 100px)';
  } else {
    scale = `calc((100vw - 300px)/${columnCount} - 100px)`;
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
