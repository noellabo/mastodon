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

@connect()
export default class CommunityTimeline extends React.PureComponent {

  static propTypes = {
    dispatch: PropTypes.func.isRequired,
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

    this.polling = setInterval(() => {
      dispatch(refreshCommunityTimeline());
    }, 3000);
  }

  componentWillUnmount () {
    if (typeof this.polling !== 'undefined') {
      clearInterval(this.polling);
      this.polling = null;
    }
  }

  handleLoadMore = () => {
    this.props.dispatch(expandCommunityTimeline());
  }

  render () {
    return (
      <Column ref={this.setRef}>
        <ColumnHeader
          icon='users'
          title={(
            <div style={{ display: 'inline-block', verticalAlign: 'top' }}>
              <div>Pawooのローカルタイムライン</div>
              <div style={{ fontSize: '12px' }}>投稿をリアルタイムに流しています</div>
            </div>
          )}
          onClick={this.handleHeaderClick}
        />

        <StatusListContainer
          timelineId='community'
          loadMore={this.handleLoadMore}
          scrollKey='standalone_community_timeline'
          trackScroll={false}
        />
      </Column>
    );
  }

}
