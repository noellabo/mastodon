import { List as ImmutableList } from 'immutable';
import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import StatusListContainer from '../../ui/containers/status_list_container';
import {
  refreshCommunityTimeline,
  expandCommunityTimeline,
} from '../../../actions/timelines';
import Column from '../../../components/column';
import ColumnHeader from '../../../components/column_header';
import { injectIntl } from 'react-intl';
import { connectCommunityStream } from '../../../actions/streaming';
import initialState from '../../../initial_state';

import pawooLogo from '../../../../pawoo/images/logo_elephant.png';

const mapStateToProps = state => ({
  pawooStatusCount: state.getIn(['timelines', 'community', 'items'], ImmutableList()).count(),
});

@connect(mapStateToProps)
@injectIntl
export default class CommunityTimeline extends React.PureComponent {

  static propTypes = {
    dispatch: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
    pawooStatusCount: PropTypes.number.isRequired,
  };

  handleHeaderClick = () => {
    this.column.scrollTop();
  }

  setRef = c => {
    this.column = c;
  }

  componentDidMount () {
    const { dispatch } = this.props;

    dispatch(refreshCommunityTimeline());
    this.disconnect = dispatch(connectCommunityStream());
  }

  componentWillUnmount () {
    if (this.disconnect) {
      this.disconnect();
      this.disconnect = null;
    }
  }

  handleLoadMore = () => {
    this.props.dispatch(expandCommunityTimeline());
  }

  render () {
    return (
      <Column ref={this.setRef}>
        <ColumnHeader
          title={(
            <div className='pawoo-extension-standalone-community'>
              <img src={pawooLogo} />
              \ {initialState.pawoo.user_count}人が、{initialState.pawoo.status_count + this.props.pawooStatusCount}回パウってます /
            </div>
          )}
          onClick={this.handleHeaderClick}
        />

        <StatusListContainer
          timelineId='community'
          loadMore={this.handleLoadMore}
          scrollKey='standalone_public_timeline'
          trackScroll={false}
          pawooMediaScale='230px'
        />
      </Column>
    );
  }

}
