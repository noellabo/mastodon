export const COLUMN_MEDIA_RESIZE = 'PAWOO_COLUMN_MEDIA_RESIZE';

export function resizeColumnMedia(single) {
  return (dispatch, getState) => dispatch({
    type: COLUMN_MEDIA_RESIZE,
    columnCount: getState().getIn(['pawoo', 'page']) === 'PAWOO_FIRST_ANNIVERSARY' ? 1 : getState().getIn(['settings', 'columns']).count(),
    defaultPage: ['DEFAULT', 'PAWOO_FIRST_ANNIVERSARY'].includes(getState().getIn(['pawoo', 'page'])),
    single,
    window: { innerWidth, innerHeight },
  });
}
