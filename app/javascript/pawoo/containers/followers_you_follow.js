import { connect } from 'react-redux';
import { injectIntl } from 'react-intl';
import { fetchFollowersYouFollow } from '../actions/followers_you_follow';
import FollowersYouFollow from '../components/followers_you_follow';

const mapStateToProps = state => ({
  accounts: state.getIn(['pawoo', 'followers_you_follow']),
});

const mapDispatchToProps = dispatch => ({
  fetch: targetAccountId => dispatch(fetchFollowersYouFollow(targetAccountId)),
});

export default injectIntl(connect(mapStateToProps, mapDispatchToProps)(FollowersYouFollow));
