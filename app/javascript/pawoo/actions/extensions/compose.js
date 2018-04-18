export const COMPOSE_DATE_TIME_CHANGE = 'PAWOO_EXTENSION_COMPOSE_DATE_TIME_CHANGE';
export const COMPOSE_TAG_INSERT = 'PAWOO_EXTENSION_COMPOSE_TAG_INSERT';

export function changeComposeDateTime(value) {
  return {
    type: COMPOSE_DATE_TIME_CHANGE,
    value,
  };
};

export function insertTagCompose(tag) {
  return {
    type: COMPOSE_TAG_INSERT,
    tag,
  };
}
