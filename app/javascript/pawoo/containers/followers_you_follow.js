import { connect } from 'react-redux';
import { List as ImmutableList } from 'immutable';
import { fetchFollowersYouFollow } from '../actions/followers_you_follow';
import FollowersYouFollow from '../components/followers_you_follow';

const mapStateToProps = (state, props) => ({
  accounts: state.getIn(['pawoo', 'followers_you_follow', props.targetAccount.get('id')]) || ImmutableList(),
});

const mapDispatchToProps = dispatch => ({
  fetch: targetAccountId => dispatch(fetchFollowersYouFollow(targetAccountId)),
});

export default connect(mapStateToProps, mapDispatchToProps)(FollowersYouFollow);
