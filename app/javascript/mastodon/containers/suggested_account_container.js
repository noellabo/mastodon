import { connect } from 'react-redux';
import { makeGetSuggestedAccount } from '../selectors';
import { openModal } from '../actions/modal';
import SuggestedAccount from '../components/suggested_account';
import PawooGA from '../../pawoo/actions/ga';
import {
  followAccount,
  unfollowAccount,
} from '../actions/accounts';

const pawooGaCategory = 'SuggestedAccount';

const makeMapStateToProps = () => {
  const getAccount = makeGetSuggestedAccount();

  const mapStateToProps = (state, props) => ({
    account: getAccount(state, props.id),
  });

  return mapStateToProps;
};

const mapDispatchToProps = (dispatch) => ({
  onFollow (account) {
    if (account.getIn(['relationship', 'following'])) {
      PawooGA.event({ category: pawooGaCategory, action: 'Follow' });

      dispatch(unfollowAccount(account.get('id')));
    } else {
      PawooGA.event({ category: pawooGaCategory, action: 'Unollow' });

      dispatch(followAccount(account.get('id')));
    }
  },

  onOpenMedia (media, index) {
    PawooGA.event({ category: pawooGaCategory, action: 'OpenMedia' });

    dispatch(openModal('MEDIA', { media, index }));
  },

  onOpenVideo (media, time) {
    PawooGA.event({ category: pawooGaCategory, action: 'OpenVideo' });

    dispatch(openModal('VIDEO', { media, time }));
  },
});

export default connect(makeMapStateToProps, mapDispatchToProps)(SuggestedAccount);
