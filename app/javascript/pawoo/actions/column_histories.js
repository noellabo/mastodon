export const COLUMN_HISTORY_PUSH = 'PAWOO_COLUMN_HISTORY_PUSH';
export const COLUMN_HISTORY_POP = 'PAWOO_COLUMN_HISTORY_POP';

export function pushColumnHistory(column, location) {
  return {
    type: COLUMN_HISTORY_PUSH,
    column: column,
    location: location,
  };
}

export function popColumnHistory(column) {
  return {
    type: COLUMN_HISTORY_POP,
    column: column,
  };
}
