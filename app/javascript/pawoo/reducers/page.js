import { PAGE_SET } from '../actions/page';

export default function page(state = 'DEFAULT', action) {
  switch (action.type) {
  case PAGE_SET:
    return action.page;
  default:
    return state;
  }
}
