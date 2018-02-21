export default function subscribe(store) {
  let lastHistory = store.getState().getIn(['compose', 'pawoo', 'hashTagHistory']);

  store.subscribe(() => {
    const history = store.getState().getIn(['compose', 'pawoo', 'hashTagHistory']);

    if (lastHistory.equals(history)) {
      return;
    }

    try {
      localStorage.setItem('hash_tag_history', JSON.stringify(history.toJS()));
    } catch (e) {
      //ignore
    }

    lastHistory = history;
  });
}
