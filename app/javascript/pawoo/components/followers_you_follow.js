import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';
import PropTypes from 'prop-types';
import FollowersYouFollowColumn from '../containers/followers_you_follow_column';
import { defineMessages } from 'react-intl';

const messages = defineMessages({
  title: { id: 'pawoo.followers_you_follow.title', defaultMessage: 'Followers you follow' },
});

export default class FollowersYouFollow extends ImmutablePureComponent {

  static propTypes = {
    targetAccountId: PropTypes.string.isRequired,
    accountIds: ImmutablePropTypes.list.isRequired,
    fetch: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  componentDidMount() {
    this.props.fetch(this.props.targetAccountId);
  };

  componentDidUpdate() {
    this.props.fetch(this.props.targetAccountId);
  };

  render() {
    const { accountIds, intl } = this.props;

    return accountIds.size > 0 ? (
      <div className='pawoo-followers-you-follow'>
        <p>{intl.formatMessage(messages.title)}</p>
        <div className='pawoo-followers-you-follow__account-list'>
          {accountIds.map(id => <FollowersYouFollowColumn accountId={id} key={id} />)}
        </div>
      </div>
    ) : null;
  };

}
