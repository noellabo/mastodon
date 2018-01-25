import { connect } from 'react-redux';
import { makeGetSuggestedAccount } from '../selectors';
import { openModal } from '../actions/modal';
import SuggestedAccount from '../components/suggested_account';
import {
  followAccount,
  unfollowAccount,
} from '../actions/accounts';

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
      dispatch(unfollowAccount(account.get('id')));
    } else {
      dispatch(followAccount(account.get('id')));
    }
  },

  onOpenMedia (media, index) {
    dispatch(openModal('MEDIA', { media, index }));
  },

  onOpenVideo (media, time) {
    dispatch(openModal('VIDEO', { media, time }));
  },
});

export default connect(makeMapStateToProps, mapDispatchToProps)(SuggestedAccount);
