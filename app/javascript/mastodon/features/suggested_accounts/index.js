import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import LoadingIndicator from '../../components/loading_indicator';
import Link from 'react-router-dom/Link';
import {
  fetchSuggestedAccounts,
  expandSuggestedAccounts,
} from '../../actions/suggested_accounts';
import { ScrollContainer } from 'react-router-scroll-4';
import { defineMessages, injectIntl } from 'react-intl';
import SuggestedAccountContainer from '../../containers/suggested_account_container';
import Column from '../ui/components/column';
import LoadMore from '../../components/load_more';
import ColumnBackButtonSlim from '../../components/column_back_button_slim';

const mapStateToProps = (state) => ({
  accountIds: state.getIn(['user_lists', 'suggested_accounts', 'items']),
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

class SuggestedAccounts extends React.PureComponent {

  static propTypes = {
    intl: PropTypes.object.isRequired,
    dispatch: PropTypes.func.isRequired,
    accountIds: ImmutablePropTypes.list,
  };

  componentWillMount () {
    this.props.dispatch(fetchSuggestedAccounts());
  }

  handleScroll = (e) => {
    const { scrollTop, scrollHeight, clientHeight } = e.target;

    if (scrollTop === scrollHeight - clientHeight) {
      this.props.dispatch(expandSuggestedAccounts());
    }
  }

  handleLoadMore = (e) => {
    e.preventDefault();
    this.props.dispatch(expandSuggestedAccounts());
  }

  render () {
    const { accountIds, intl } = this.props;

    if (!accountIds) {
      return (
        <Column>
          <LoadingIndicator />
        </Column>
      );
    }

    return (
      <Column icon='user' active={false} heading={intl.formatMessage(messages.title)}>
        <ColumnBackButtonSlim />

        <ScrollContainer scrollKey='suggested_accounts'>
          <div className='scrollable suggested_accounts__scrollable' onScroll={this.handleScroll}>
            <div className='suggested_accounts'>
              {accountIds.map(id => <SuggestedAccountContainer key={id} id={id} withNote={false} />)}
              <LoadMore onClick={this.handleLoadMore} />
            </div>
          </div>
        </ScrollContainer>

        <Link className='button' style={buttonStyle} to='/timelines/public/local'>
          {intl.formatMessage(messages.goToLocalTimeline)}
        </Link>
      </Column>
    );
  }

}

export default connect(mapStateToProps)(injectIntl(SuggestedAccounts));
