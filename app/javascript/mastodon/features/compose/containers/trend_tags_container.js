import { connect }   from 'react-redux';
import TrendTags from '../components/trend_tags';
import { refreshTrendTags } from '../../../../pawoo/actions/trend_tags';
import { insertTagCompose } from '../../../../pawoo/actions/extensions/compose';
import PawooGA from '../../../../pawoo/actions/ga';

const pawooGaCategory = 'Compose';

const mapStateToProps = state => {
  return {
    tags: state.getIn(['pawoo', 'trend_tags', 'tags']),
  };
};

const mapDispatchToProps = dispatch => ({
  refreshTrendTags () {
    dispatch(refreshTrendTags());
  },
  insertTagCompose (tag) {
    PawooGA.event({ eventCategory: pawooGaCategory, eventAction: 'SelectTrendTags' });

    dispatch(insertTagCompose(tag));
  },
});

export default connect(mapStateToProps, mapDispatchToProps)(TrendTags);
