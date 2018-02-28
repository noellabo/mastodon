import React from 'react';
import { connect } from 'react-redux';
import ImmutablePureComponent from 'react-immutable-pure-component';
import ImmutablePropTypes from 'react-immutable-proptypes';

import BundleContainer from '../../mastodon/features/ui/containers/bundle_container';
import ColumnLoading from '../../mastodon/features/ui/components/column_loading';
import DrawerLoading from '../../mastodon/features/ui/components/drawer_loading';
import BundleColumnError from '../../mastodon/features/ui/components/bundle_column_error';

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
  'COMPOSE': Compose,
  'HOME': HomeTimeline,
  'NOTIFICATIONS': Notifications,
  'PUBLIC': PublicTimeline,
  'COMMUNITY': CommunityTimeline,
  'HASHTAG': HashtagTimeline,
  'FAVOURITES': FavouritedStatuses,
  'LIST': ListTimeline,
  'MEDIA': MediaTimeline,
  'SUGGESTION_TAGS': SuggestionTags,
  'STATUS': Status,
  'STATUS_REBLOGS': Reblogs,
  'STATUS_FAVOURITES': Favourites,
};

const mapStateToProps = (state, props) => ({
  columnHistory: state.getIn(['pawoo', 'column_histories']).get(props.column.get('uuid')),
});

@connect(mapStateToProps)
export default class ColumnContainer extends ImmutablePureComponent { // TODO: Componentへの変更を検討

  static childContextTypes = {
    columnHistory: ImmutablePropTypes.stack,
  };

  static propTypes = {
    column: ImmutablePropTypes.map.isRequired,
    columnHistory: ImmutablePropTypes.stack.isRequired,
  };

  getChildContext() {
    return ({
      columnHistory: this.props.columnHistory,
    });
  }

  renderLoading = columnId => () => {
    return columnId === 'COMPOSE' ? <DrawerLoading /> : <ColumnLoading />;
  };

  renderError = (props) => {
    return <BundleColumnError {...props} />;
  };

  render () {
    const { column, columnHistory } = this.props;
    const params = column.get('params', null) === null ? null : column.get('params').toJS();
    return (
      <BundleContainer fetchComponent={componentMap[columnHistory.first().get('id')]} loading={this.renderLoading(column.get('id'))} error={this.renderError}>
        {SpecificComponent => <SpecificComponent columnId={column.get('uuid')} params={params} multiColumn />}
      </BundleContainer>
    );
  }

}
