import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { fetchAccount } from '../../actions/accounts';
import { expandAccountMediaTimeline } from '../../actions/timelines';
import StatusList from '../../components/status_list';
import LoadingIndicator from '../../components/loading_indicator';
import Column from '../ui/components/column';
import HeaderContainer from './../account_timeline/containers/header_container';
import ColumnBackButton from '../../components/column_back_button';
import Immutable from 'immutable';

const mapStateToProps = (state, props) => ({
  statusIds: state.getIn(['timelines', `account:${props.params.accountId}:media`, 'items'], Immutable.List()),
  isLoading: state.getIn(['timelines', `account:${props.params.accountId}:media`, 'isLoading']),
  hasMore:   state.getIn(['timelines', `account:${props.params.accountId}:media`, 'hasMore']),
});

class AccountMediaTimeline extends React.PureComponent {

  static propTypes = {
    params: PropTypes.object.isRequired,
    dispatch: PropTypes.func.isRequired,
    statusIds: ImmutablePropTypes.list,
    isLoading: PropTypes.bool,
    hasMore: PropTypes.bool,
  };

  componentWillMount () {
    this.props.dispatch(fetchAccount(this.props.params.accountId));
    this.props.dispatch(expandAccountMediaTimeline(this.props.params.accountId));
  }

  componentWillReceiveProps(nextProps) {
    if (nextProps.params.accountId !== this.props.params.accountId && nextProps.params.accountId) {
      this.props.dispatch(fetchAccount(nextProps.params.accountId));
      this.props.dispatch(expandAccountMediaTimeline(nextProps.params.accountId));
    }
  }

  handleLoadMore = maxId => {
    if (this.props.hasMore) {
      this.props.dispatch(expandAccountMediaTimeline(this.props.params.accountId, { maxId }));
    }
  }

  render () {
    const { statusIds, isLoading, hasMore } = this.props;

    if (!statusIds && isLoading) {
      return (
        <Column>
          <LoadingIndicator />
        </Column>
      );
    }

    return (
      <Column>
        <ColumnBackButton />
        <StatusList
          prepend={<HeaderContainer accountId={this.props.params.accountId} />}
          statusIds={statusIds}
          isLoading={isLoading}
          hasMore={hasMore}
          onLoadMore={this.handleLoadMore}
          scrollKey={'account_media_timeline'}
        />
      </Column>
    );
  }

};

export default connect(mapStateToProps)(AccountMediaTimeline);
