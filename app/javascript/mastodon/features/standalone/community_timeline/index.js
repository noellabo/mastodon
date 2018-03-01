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
import { connectCommunityStream } from '../../../actions/streaming';

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
          pawooMediaScale='330px'
          pawooWideMedia
        />
      </Column>
    );
  }

}
