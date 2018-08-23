import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import FollowersYouFollowColumn from './followers_you_follow_column';

export default class FollowersYouFollow extends React.PureComponent {

  static propTypes = {
    targetAccount: ImmutablePropTypes.map.isRequired,
    accounts: ImmutablePropTypes.list.isRequired,
    fetch: PropTypes.func.isRequired,
  }

  componentDidMount() {
    this.props.fetch(this.props.targetAccount.get('id'));
  }

  render() {
    const { accounts } = this.props;

    return accounts.size > 0 ? (
      <div className='pawoo-followers-you-follow'>
        <p>知り合いのフォローワー</p>
        {this.props.accounts.map(account => <FollowersYouFollowColumn account={account} key={account.get('id')} />)}
      </div>
    ) : null;
  }

}
