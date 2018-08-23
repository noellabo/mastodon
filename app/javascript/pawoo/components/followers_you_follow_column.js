import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import Avatar from '../../mastodon/components/avatar';
import DisplayName from '../../mastodon/components/display_name';
import Permalink from '../../mastodon/components/permalink';

export default class FollowersYouFollowColumn extends React.PureComponent {

  static propTypes = {
    account: ImmutablePropTypes.map.isRequired,
  }

  render() {
    const { account } = this.props;

    return (
      <div className='account'>
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
