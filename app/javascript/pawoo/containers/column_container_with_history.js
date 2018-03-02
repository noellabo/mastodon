import React from 'react';
import { connect } from 'react-redux';
import { matchPath } from 'react-router-dom';
import PropTypes from 'prop-types';
import ImmutablePureComponent from 'react-immutable-pure-component';
import ImmutablePropTypes from 'react-immutable-proptypes';
import ScrollBehavior from 'scroll-behavior';

import BundleContainer from '../../mastodon/features/ui/containers/bundle_container';
import ColumnLoading from '../../mastodon/features/ui/components/column_loading';
import DrawerLoading from '../../mastodon/features/ui/components/drawer_loading';
import BundleColumnError from '../../mastodon/features/ui/components/bundle_column_error';
import { pushColumnHistory, popColumnHistory, saveScrollToStore } from '../actions/column_histories';

import {
  Compose,
  Notifications,
  HomeTimeline,
  CommunityTimeline,
  PublicTimeline,
  HashtagTimeline,
  FavouritedStatuses,
  ListTimeline,
  MediaTimeline,
  SuggestionTags,
  Status,
  Reblogs,
  Favourites,
} from '../../mastodon/features/ui/util/async-components';
// import * as PawooComponents from '../util/async-components';

const componentMap = {
  'COMPOSE': {
    component: Compose,
    match: null,
  },
  'HOME': {
    component: HomeTimeline,
    match: { path: '/timelines/home' },
  },
  'PUBLIC': {
    component: PublicTimeline,
    match: { path: '/timelines/public' },
  },
  'COMMUNITY': {
    component: CommunityTimeline,
    match: { path: '/timelines/public/local' },
  },
  'HASHTAG': {
    component: HashtagTimeline,
    match: { path: '/timelines/tag/:id' },
  },
  'LIST': {
    component: ListTimeline,
    match: { path: '/timelines/list/:id' },
  },
  'NOTIFICATIONS': {
    component: Notifications,
    match: { path: '/notifications' },
  },
  'FAVOURITES': {
    component: FavouritedStatuses,
    match: { path: '/favourites' },
  },
  'STATUS': {
    component: Status,
    match: { path: '/statuses/:statusId', exact: true },
  },
  'STATUS_REBLOGS': {
    component: Reblogs,
    match: { path: '/statuses/:statusId/reblogs' },
  },
  'STATUS_FAVOURITES': {
    component: Favourites,
    match: { path: '/statuses/:statusId/favourites' },
  },
  'MEDIA': {
    component: MediaTimeline,
    match: { path: '/timelines/public/media' },
  },
  'SUGGESTION_TAGS': {
    component: SuggestionTags,
    match: null,
  },
};

class ColumnStateStorage {

  constructor(readFromStore, saveToStore) {
    this.readFromStore = readFromStore;
    this.saveToStore = saveToStore;
  }

  read(location) {
    return this.readFromStore(location.get('uuid'));
  }

  save(location, key, value) {
    this.saveToStore(location.get('uuid'), value);
  }

}

const mapStateToProps = (state, props) => ({
  columnHistory: state.getIn(['pawoo', 'column_histories']).get(props.column.get('uuid')),
});

const mapDispatchToProps = (dispatch, props) => ({
  pushColumnHistory: (id, params) => dispatch(pushColumnHistory(props.column, id, params)),
  popColumnHistory: () => dispatch(popColumnHistory(props.column)),
  saveScrollToStore: (key, value) => dispatch(saveScrollToStore(props.column, key, value)),
});

@connect(mapStateToProps, mapDispatchToProps)
export default class ColumnContainerWithHistory extends ImmutablePureComponent {

  static contextTypes = {
    router: PropTypes.object,
  };

  static propTypes = {
    column: ImmutablePropTypes.map.isRequired,
    columnHistory: ImmutablePropTypes.stack.isRequired,
    pushColumnHistory: PropTypes.func.isRequired,
    popColumnHistory: PropTypes.func.isRequired,
    saveScrollToStore: PropTypes.func.isRequired,
  };

  static childContextTypes = {
    isColumnWithHistory: PropTypes.bool,
    columnHistory: ImmutablePropTypes.stack,
    pushHistory: PropTypes.func,
    popHistory: PropTypes.func,
    scrollBehavior: PropTypes.object,
  };

  constructor(props, context) {
    super(props, context);

    this.scrollBehavior = new ScrollBehavior({
      addTransitionHook: this.handleHook,
      stateStorage: new ColumnStateStorage(this.getScrollPosition, this.props.saveScrollToStore),
      getCurrentLocation: () => this.props.columnHistory.first(),
      shouldUpdateScroll: this.shouldUpdateScroll,
    });

    this.scrollBehavior.updateScroll(null, this.props.columnHistory.first());
  }

  pushHistory = (path, newColumn = false) => {
    if (newColumn) {
      this.context.router.history.push(path);
      return;
    }

    let match = null;
    const matchedId = Object.keys(componentMap).find((key) => {
      if (componentMap[key].match) {
        match = matchPath(path, componentMap[key].match);
        return match;
      } else {
        return null;
      }
    });

    if (match) {
      this.props.pushColumnHistory(matchedId, match.params);
    } else {
      this.context.router.history.push(path);
    }
  };

  getChildContext() {
    return ({
      isColumnWithHistory: true,
      columnHistory: this.props.columnHistory,
      pushHistory: this.pushHistory,
      popHistory: this.props.popColumnHistory,
      scrollBehavior: this,
    });
  }

  handleHook = (callback) => {
    this.transitionHook = callback;
    return () => {
      this.transitionHook = () => {};
    };
  };

  shouldUpdateScroll = () => {
    return true;
  };

  registerElement = (key, element, shouldUpdateScroll) => {
    this.scrollBehavior.registerElement(
      key, element, shouldUpdateScroll, this.getScrollContext(),
    );
  };

  unregisterElement = (key) => {
    this.scrollBehavior.unregisterElement(key);
  };

  getScrollContext = () => {
    return this.props.columnHistory.first().get('uuid');
  };

  getScrollPosition = () => {
    return this.props.columnHistory.first().get('scrollPosition').toJS();
  };

  componentDidUpdate(prevProps) {
    const prevScrollContext = prevProps.columnHistory.first().get('uuid');

    if (prevScrollContext === this.getScrollContext()) return;

    this.scrollBehavior.updateScroll(prevScrollContext, this.getScrollContext());
  }

  componentWillUnmount() {
    this.scrollBehavior.stop();
  }

  renderLoading = columnId => () => {
    return columnId === 'COMPOSE' ? <DrawerLoading /> : <ColumnLoading />;
  };

  renderError = (props) => {
    return <BundleColumnError {...props} />;
  };

  render () {
    const { column, columnHistory } = this.props;
    const topColumn = columnHistory.first();
    const params = topColumn.get('params', null) === null ? null : topColumn.get('params').toJS();
    return (
      <BundleContainer fetchComponent={componentMap[topColumn.get('id')].component} loading={this.renderLoading(column.get('id'))} error={this.renderError}>
        {SpecificComponent => <SpecificComponent columnId={column.get('uuid')} params={params} multiColumn />}
      </BundleContainer>
    );
  }

}
