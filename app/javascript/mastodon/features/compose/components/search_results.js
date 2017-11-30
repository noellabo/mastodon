import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import { FormattedMessage } from 'react-intl';
import AccountContainer from '../../../containers/account_container';
import StatusContainer from '../../../containers/status_container';
import { Link } from 'react-router-dom';
import ImmutablePureComponent from 'react-immutable-pure-component';

export default class SearchResults extends ImmutablePureComponent {

  static propTypes = {
    results: ImmutablePropTypes.map.isRequired,
    isAdmin: PropTypes.bool,
    searchKeyword: PropTypes.string,
  };

  render () {
    const { results, searchKeyword, isAdmin } = this.props;

    let accounts, statuses, hashtags, search_header;
    let count = 0;

    if (results.get('accounts') && results.get('accounts').size > 0) {
      count   += results.get('accounts').size;
      accounts = (
        <div className='search-results__section'>
          {results.get('accounts').map(accountId => <AccountContainer key={accountId} id={accountId} />)}
        </div>
      );
    }

    if (results.get('statuses') && results.get('statuses').size > 0) {
      count   += results.get('statuses').size;
      statuses = (
        <div className='search-results__section'>
          {results.get('statuses').map(statusId => <StatusContainer key={statusId} id={statusId} />)}
        </div>
      );
    }

    if (results.get('hashtags') && results.get('hashtags').size > 0) {
      count += results.get('hashtags').size;
      hashtags = (
        <div className='search-results__section'>
          {results.get('hashtags').map(hashtag =>
            <Link key={hashtag} className='search-results__hashtag' to={`/timelines/tag/${hashtag}`}>
              #{hashtag}
            </Link>
          )}
        </div>
      );
    }

    if (isAdmin && searchKeyword.length > 0) {
      search_header = (
        <Link className='search-results__search-statuses' to={`/statuses/search/${searchKeyword}`}>
          <i className='fa fa-fw fa-search search-results__search-statuses-icon' />
          <FormattedMessage id='search_results.search_toots' defaultMessage='Search toots with "{keyword}"' values={{ keyword: searchKeyword }} />
        </Link>
      );
    } else {
      search_header = (
        <div className='search-results__header'>
          <FormattedMessage id='search_results.total' defaultMessage='{count, number} {count, plural, one {result} other {results}}' values={{ count }} />
        </div>
      );
    }

    return (
      <div className='search-results'>
        {search_header}
        {accounts}
        {statuses}
        {hashtags}
      </div>
    );
  }

}
