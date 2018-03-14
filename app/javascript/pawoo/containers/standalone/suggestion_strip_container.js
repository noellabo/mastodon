import Immutable from 'immutable';
import PropTypes from 'prop-types';
import React from 'react';
import { FormattedMessage, IntlProvider, addLocaleData } from 'react-intl';
import { getLocale } from '../../../mastodon/locales';
import PublicTagLink from '../../components/public_tag_link';
import SuggestedAccount from '../../components/suggested_account';
import TrendTags from '../../components/trend_tags';

const { localeData, messages } = getLocale();

addLocaleData(localeData);

export default function StandaloneSuggestionTagsContainer({ locale, accounts, tags }) {
  return (
    <IntlProvider locale={locale} messages={messages}>
      <React.Fragment>
        <section>
          <h1 className='pawoo-subcolumn__header'>
            <i
              className='fa fa-user-plus pawoo-subcolumn__header__icon'
              role='presentation'
            />
            <FormattedMessage
              id='column.suggested_accounts'
              defaultMessage='Active Users'
            />
          </h1>
          <ul className='pawoo-subcolumn--suggested-accounts__body scrollable'>
            {accounts.map(account => (
              <li key={account.id}>
                <SuggestedAccount
                  account={Immutable.fromJS(account)}
                  target=''
                />
              </li>
            ))}
          </ul>
        </section>
        <TrendTags tags={Immutable.fromJS(tags)} Tag={PublicTagLink} />
      </React.Fragment>
    </IntlProvider>
  );
}

StandaloneSuggestionTagsContainer.propTypes = {
  locale: PropTypes.string.isRequired,
  accounts: PropTypes.array.isRequired,
  tags: PropTypes.array.isRequired,
};
