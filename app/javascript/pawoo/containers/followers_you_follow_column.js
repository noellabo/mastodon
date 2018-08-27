import React from 'react';
import Avatar from '../../mastodon/components/avatar';
import DisplayName from '../../mastodon/components/display_name';
import Permalink from '../../mastodon/components/permalink';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import { makeGetAccount } from '../../mastodon/selectors';

const makeMapStateToProps = () => {
  const getAccount = makeGetAccount();

  const mapStateToProps = (state, props) => ({
    account: getAccount(state, props.accountId),
  });

  return mapStateToProps;
};

@connect(makeMapStateToProps)
export default class FollowersYouFollowColumn extends ImmutablePureComponent {

  static propTypes = {
    accountId: PropTypes.string.isRequired,
  };

  render() {
    const { account } = this.props;

    return (
      <div className='account multi-column'>
        <div className='account__wrapper'>
          <Permalink key={account.get('id')} className='account__display-name' href={account.get('url')} to={`/accounts/${account.get('id')}`}>
            <div className='account__avatar-wrapper'><Avatar account={account} size={36} /></div>
            <DisplayName account={account} />
          </Permalink>
        </div>
      </div>
    );
  }

}
