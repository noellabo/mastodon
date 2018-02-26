import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { Link } from 'react-router-dom';
import { debounce } from 'lodash';
import { List as ImmutableList } from 'immutable';
import { defineMessages, injectIntl } from 'react-intl';
import {
  fetchSuggestedAccounts,
  expandSuggestedAccounts,
} from '../actions/suggested_accounts';
import ScrollableList from '../../mastodon/components/scrollable_list';
import SuggestedAccountContainer from './suggested_account_container';
import Column from '../../mastodon/features/ui/components/column';
import ColumnBackButtonSlim from '../../mastodon/components/column_back_button_slim';

const mapStateToProps = (state) => ({
  accountIds: state.getIn(['pawoo', 'suggested_accounts', 'items'], ImmutableList()),
  hasMore: !!state.getIn(['pawoo', 'suggested_accounts', 'next']),
  isLoading: state.getIn(['pawoo', 'suggested_accounts', 'isLoading'], true),
});

const messages = defineMessages({
  title: { id: 'column.suggested_accounts', defaultMessage: 'Active Users' },
  goToLocalTimeline: { id: 'suggested_accounts.go_to_local_timeline', defaultMessage: 'Go To Local Timeline' },
});

const buttonStyle = {
  display: 'block',
  lineHeight: 0,
  padding: '25px 0',
  fontSize: '16px',
};

@connect(mapStateToProps)
@injectIntl
export default class SuggestedAccounts extends React.PureComponent {

  static propTypes = {
    intl: PropTypes.object.isRequired,
    dispatch: PropTypes.func.isRequired,
    accountIds: ImmutablePropTypes.list,
    hasMore: PropTypes.bool.isRequired,
    isLoading: PropTypes.bool.isRequired,
  };

  componentDidMount () {
    const { accountIds, hasMore } = this.props;

    if (accountIds.size === 0 && !hasMore) {
      this.props.dispatch(fetchSuggestedAccounts());
    }
  }

  handleScrollToBottom = debounce(() => {
    this.props.dispatch(expandSuggestedAccounts());
  }, 300, { leading: true });

  render () {
    const { accountIds, hasMore, isLoading, intl } = this.props;

    let scrollableContent = null;

    if (isLoading && this.scrollableContent) {
      scrollableContent = this.scrollableContent;
    } else if (accountIds.size > 0 || hasMore) {
      scrollableContent = accountIds.map((id) => (
        <SuggestedAccountContainer key={id} id={id} />
      ));
    } else {
      scrollableContent = null;
    }

    return (
      <Column icon='user' active={false} heading={intl.formatMessage(messages.title)}>
        <ColumnBackButtonSlim />

        <ScrollableList
          scrollKey='suggested_accounts'
          trackScroll
          isLoading={isLoading}
          hasMore={hasMore}
          onScrollToBottom={this.handleScrollToBottom}
        >
          {scrollableContent}
        </ScrollableList>

        <Link className='button' style={buttonStyle} to='/timelines/public/local'>
          {intl.formatMessage(messages.goToLocalTimeline)}
        </Link>
      </Column>
    );
  }

}
