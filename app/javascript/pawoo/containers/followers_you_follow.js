import { connect } from 'react-redux';
import { List as ImmutableList } from 'immutable';
import { fetchFollowersYouFollow } from '../actions/followers_you_follow';
import FollowersYouFollow from '../components/followers_you_follow';

const mapStateToProps = (state, props) => ({
  accountIds: state.getIn(['pawoo', 'followers_you_follow', props.targetAccountId], ImmutableList()),
});

const mapDispatchToProps = dispatch => ({
  fetch: targetAccountId => dispatch(fetchFollowersYouFollow(targetAccountId)),
});

export default connect(mapStateToProps, mapDispatchToProps)(FollowersYouFollow);
