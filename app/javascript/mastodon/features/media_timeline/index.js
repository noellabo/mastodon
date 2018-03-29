import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import StatusListContainer from '../ui/containers/status_list_container';
import Column from '../../components/column';
import ColumnHeader from '../../components/column_header';
import {
  refreshMediaTimeline,
  expandMediaTimeline,
} from '../../../pawoo/actions/extensions/timelines';
import { addColumn, removeColumn, moveColumn } from '../../actions/columns';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import ColumnSettingsContainer from './containers/column_settings_container';
import { connectMediaStream } from '../../actions/streaming';

const messages = defineMessages({
  title: { id: 'column.media', defaultMessage: 'Media timeline' },
});

const mapStateToProps = state => ({
  hasUnread: state.getIn(['timelines', 'media', 'unread']) > 0,
  streamingAPIBaseURL: state.getIn(['meta', 'streaming_api_base_url']),
  accessToken: state.getIn(['meta', 'access_token']),
});

class MediaTimeline extends React.PureComponent {

  static propTypes = {
    dispatch: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
    columnId: PropTypes.string,
    multiColumn: PropTypes.bool,
    hasUnread: PropTypes.bool,
    pawooHasPinnedColumn: PropTypes.bool,
  };

  handlePin = () => {
    const { columnId, dispatch } = this.props;

    if (columnId) {
      dispatch(removeColumn(columnId));
    } else {
      dispatch(addColumn('MEDIA', {}));
    }
  }

  handleMove = (dir) => {
    const { columnId, dispatch } = this.props;
    dispatch(moveColumn(columnId, dir));
  }

  handleHeaderClick = () => {
    this.column.scrollTop();
  }

  componentDidMount () {
    const { dispatch } = this.props;

    dispatch(refreshMediaTimeline());
    this.disconnect = dispatch(connectMediaStream());
  }

  componentWillUnmount () {
    if (this.disconnect) {
      this.disconnect();
      this.disconnect = null;
    }
  }

  setRef = c => {
    this.column = c;
  }

  handleLoadMore = () => {
    this.props.dispatch(expandMediaTimeline());
  }

  render () {
    const { intl, columnId, hasUnread, multiColumn, pawooHasPinnedColumn } = this.props;
    const pinned = !!columnId;

    return (
      <Column ref={this.setRef}>
        <ColumnHeader
          icon='image'
          active={hasUnread}
          title={intl.formatMessage(messages.title)}
          onPin={this.handlePin}
          onMove={this.handleMove}
          onClick={this.handleHeaderClick}
          pinned={pinned}
          multiColumn={multiColumn}
          pawooHasPinnedColumn={pawooHasPinnedColumn}
        >
          <ColumnSettingsContainer />
        </ColumnHeader>
        <StatusListContainer
          timelineId='media'
          loadMore={this.handleLoadMore}
          scrollKey={`media_timeline-${columnId}`}
          emptyMessage={<FormattedMessage id='empty_column.public' defaultMessage='There is nothing here! Write something publicly, or manually follow users from other instances to fill it up' />}
        />
      </Column>
    );
  }

};

export default connect(mapStateToProps)(injectIntl(MediaTimeline));
