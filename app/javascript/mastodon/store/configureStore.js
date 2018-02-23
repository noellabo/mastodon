import { createStore, applyMiddleware, compose } from 'redux';
import thunk from 'redux-thunk';
import appReducer from '../reducers';
import loadingBarMiddleware from '../middleware/loading_bar';
import errorsMiddleware from '../middleware/errors';
import soundsMiddleware from '../middleware/sounds';
import pawooSubscribeHashTagHistory from '../../pawoo/subscribe_hash_tag_history';

export default function configureStore() {
  const store = createStore(appReducer, compose(applyMiddleware(
    thunk,
    loadingBarMiddleware({ promiseTypeSuffixes: ['REQUEST', 'SUCCESS', 'FAIL'] }),
    errorsMiddleware(),
    soundsMiddleware()
  ), window.devToolsExtension ? window.devToolsExtension() : f => f));

  pawooSubscribeHashTagHistory(store);

  return store;
};
