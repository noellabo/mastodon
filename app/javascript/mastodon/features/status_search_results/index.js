import React from 'react';
import { connect } from 'react-redux';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import Immutable from 'immutable';
import {
  refreshStatusSearchTimeline,
  expandStatusSearchTimeline,
} from '../../../pawoo/actions/extensions/search';
import Column from '../../components/column';
import ColumnHeader from '../../components/column_header';
import { FormattedMessage } from 'react-intl';
import LoadingIndicator from '../../components/loading_indicator';
import StatusList from '../../components/status_list';

const mapStateToProps = (state, props) => {
  return {
    statusIds: state.getIn(['timelines', `status_search:${props.params.keyword}`, 'items'], Immutable.List()),
    isLoading: state.getIn(['timelines', `status_search:${props.params.keyword}`, 'isLoading']),
    hasMore: !!state.getIn(['timelines', `status_search:${props.params.keyword}`, 'next']),
  };
};

class StatusSearchResults extends React.PureComponent {

  static propTypes = {
    params: PropTypes.object.isRequired,
    dispatch: PropTypes.func.isRequired,
    statusIds: ImmutablePropTypes.list,
    isLoading: PropTypes.bool,
    hasMore: PropTypes.bool,
    pawoo: ImmutablePropTypes.map.isRequired,
  };

  componentWillMount (){
    this.props.dispatch(refreshStatusSearchTimeline(this.props.params.keyword));
  }

  componentWillReceiveProps(nextProps) {
    if (nextProps.params.keyword !== this.props.params.keyword && nextProps.params.keyword) {
      this.props.dispatch(refreshStatusSearchTimeline(nextProps.params.keyword));
    }
  }

  setRef = c => {
    this.column = c;
  }

  handleHeaderClick = () => {
    this.column.scrollTop();
  }

  handleLoadMore = () => {
    if (!this.props.isLoading && this.props.hasMore) {
      this.props.dispatch(expandStatusSearchTimeline(this.props.params.keyword));
    }
  }

  render () {
    const { statusIds, isLoading, params, pawoo } = this.props;
    const keyword = params.keyword;
    const column_header = <FormattedMessage id='column.search_toots' defaultMessage='Search: "{keyword}"' values={{ keyword }} />;

    if (!statusIds && isLoading) {
      return (
        <Column>
          <LoadingIndicator />
        </Column>
      );
    }

    return (
      <Column ref={this.setRef}>
        <ColumnHeader
          icon='search'
          active={false}
          title={column_header}
          onClick={this.handleHeaderClick}
          pinned={false}
          multiColumn={false}
          showBackButton
          pawoo={pawoo}
          pawooUrl={`/statuses/search/${keyword}`}
        />

        <StatusList
          scrollKey='status_search_results'
          statusIds={statusIds}
          isLoading={isLoading}
          onLoadMore={this.handleLoadMore}
          emptyMessage={<FormattedMessage id='empty_column.search_toots' defaultMessage='No toots found.' />}
        />
      </Column>
    );
  }

};

export default connect(mapStateToProps)(StatusSearchResults);
