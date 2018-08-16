import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { connect } from 'react-redux';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import PropTypes from 'prop-types';
import StatusListContainer from '../ui/containers/status_list_container';
import Column from '../../components/column';
import ColumnHeader from '../../components/column_header';
import { expandCommunityTimeline } from '../../actions/timelines';
import { addColumn, removeColumn, moveColumn, changeColumnParams } from '../../actions/columns';
import ColumnSettingsContainer from './containers/column_settings_container';
// import SectionHeadline from './components/section_headline';
import { connectCommunityStream, pawooAddListener, pawooRemoveListener } from '../../actions/streaming';

const messages = defineMessages({
  title: { id: 'column.community', defaultMessage: 'Local timeline' },
});

const mapStateToProps = (state, { onlyMedia }) => ({
  hasUnread: state.getIn(['timelines', `community${onlyMedia ? ':media' : ''}`, 'unread']) > 0,
});

@connect(mapStateToProps)
@injectIntl
export default class CommunityTimeline extends React.PureComponent {

  static defaultProps = {
    onlyMedia: false,
  };

  static propTypes = {
    dispatch: PropTypes.func.isRequired,
    columnId: PropTypes.string,
    intl: PropTypes.object.isRequired,
    hasUnread: PropTypes.bool,
    multiColumn: PropTypes.bool,
    onlyMedia: PropTypes.bool,
    pawoo: ImmutablePropTypes.map.isRequired,
  };

  pawooListener = null;

  handlePin = () => {
    const { columnId, dispatch, onlyMedia } = this.props;

    if (columnId) {
      dispatch(removeColumn(columnId));
    } else {
      dispatch(addColumn('COMMUNITY', { other: { onlyMedia } }));
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
    const { dispatch, onlyMedia } = this.props;

    dispatch(expandCommunityTimeline({ onlyMedia }));
    this.disconnect = dispatch(connectCommunityStream({ onlyMedia }));
  }

  componentDidUpdate (prevProps) {
    if (prevProps.onlyMedia !== this.props.onlyMedia) {
      const { dispatch, onlyMedia } = this.props;

      this.disconnect();
      dispatch(expandCommunityTimeline({ onlyMedia }));
      this.disconnect = dispatch(connectCommunityStream({ onlyMedia }));

      if (this.pawooListener) {
        pawooRemoveListener(`community${prevProps.onlyMedia ? ':media' : ''}`, this.pawooListener);
        pawooAddListener(`community${this.props.onlyMedia ? ':media' : ''}`, this.pawooListener);
      }
    }
  }

  componentWillUnmount () {
    if (this.disconnect) {
      this.disconnect();
      this.disconnect = null;
    }

    pawooRemoveListener(`community${this.props.onlyMedia ? ':media' : ''}`, this.pawooListener);
  }

  setRef = c => {
    this.column = c;
  }

  handleLoadMore = maxId => {
    const { dispatch, onlyMedia } = this.props;

    dispatch(expandCommunityTimeline({ maxId, onlyMedia }));
  }

  handleHeadlineLinkClick = e => {
    const { columnId, dispatch } = this.props;
    const onlyMedia = /\/media$/.test(e.currentTarget.href);

    dispatch(changeColumnParams(columnId, { other: { onlyMedia } }));
  }

  pawooSetIconRef = c => {
    const timelineId = `community${this.props.onlyMedia ? ':media' : ''}`;

    this.pawooListener = () => {
      c.classList.remove('pawoo-extension-column-header__icon--animation');

      // Trigger layout
      c.offsetWidth; // eslint-disable-line no-unused-expressions

      c.classList.add('pawoo-extension-column-header__icon--animation');
    };

    pawooRemoveListener(timelineId, this.pawooListener);
    pawooAddListener(timelineId, this.pawooListener);
  };

  render () {
    const { intl, hasUnread, columnId, multiColumn, onlyMedia, pawoo } = this.props;
    const pinned = !!columnId;

    // pending
    //
    // const headline = (
    //   <SectionHeadline
    //     timelineId='community'
    //     to='/timelines/public/local'
    //     pinned={pinned}
    //     onlyMedia={onlyMedia}
    //     onClick={this.handleHeadlineLinkClick}
    //   />
    // );

    return (
      <Column ref={this.setRef}>
        <ColumnHeader
          icon='users'
          active={hasUnread}
          title={intl.formatMessage(messages.title)}
          onPin={this.handlePin}
          onMove={this.handleMove}
          onClick={this.handleHeaderClick}
          pinned={pinned}
          multiColumn={multiColumn}
          pawoo={pawoo}
          pawooIconRef={this.pawooSetIconRef}
          pawooUrl='/timelines/public/local'
        >
          <ColumnSettingsContainer />
        </ColumnHeader>

        <StatusListContainer
          // prepend={headline}
          scrollKey={`community_timeline-${columnId}`}
          timelineId={`community${onlyMedia ? ':media' : ''}`}
          onLoadMore={this.handleLoadMore}
          emptyMessage={<FormattedMessage id='empty_column.community' defaultMessage='The local timeline is empty. Write something publicly to get the ball rolling!' />}
        />
      </Column>
    );
  }

}
