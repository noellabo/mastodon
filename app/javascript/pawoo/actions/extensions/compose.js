export const COMPOSE_DATE_TIME_CHANGE = 'PAWOO_EXTENSION_COMPOSE_DATE_TIME_CHANGE';
export const COMPOSE_SUGGESTIONS_HASH_TAG_FETCH = 'PAWOO_EXTENSION_COMPOSE_SUGGESTIONS_HASH_TAG_FETCH';
export const COMPOSE_TAG_INSERT = 'PAWOO_EXTENSION_COMPOSE_TAG_INSERT';

export function changeComposeDateTime(value) {
  return {
    type: COMPOSE_DATE_TIME_CHANGE,
    value,
  };
};

export function fetchComposeSuggestionsHashTag(token) {
  return {
    type: COMPOSE_SUGGESTIONS_HASH_TAG_FETCH,
    token,
  };
};

export function insertTagCompose(tag) {
  return {
    type: COMPOSE_TAG_INSERT,
    tag,
  };
}
