import { connect } from 'react-redux';
import ComposeForm from '../components/compose_form';
import { uploadCompose } from '../../../actions/compose';
import PawooGA from '../../../../pawoo/actions/ga';
import {
  changeCompose,
  submitCompose,
  clearComposeSuggestions,
  fetchComposeSuggestions,
  selectComposeSuggestion,
  changeComposeSpoilerText,
  insertEmojiCompose,
} from '../../../actions/compose';
import {
  changeComposeDateTime,
  insertTagCompose,
} from '../../../../pawoo/actions/extensions/compose';
import { requestImageCache } from '../../../../pawoo/actions/pixiv_twitter_images';

const pawooGaCategory = 'Compose';

const mapStateToProps = state => ({
  text: state.getIn(['compose', 'text']),
  published: state.getIn(['compose', 'pawoo', 'published']),
  suggestion_token: state.getIn(['compose', 'suggestion_token']),
  suggestions: state.getIn(['compose', 'suggestions']),
  spoiler: state.getIn(['compose', 'spoiler']),
  spoiler_text: state.getIn(['compose', 'spoiler_text']),
  privacy: state.getIn(['compose', 'privacy']),
  focusDate: state.getIn(['compose', 'focusDate']),
  preselectDate: state.getIn(['compose', 'preselectDate']),
  is_submitting: state.getIn(['compose', 'is_submitting']),
  is_uploading: state.getIn(['compose', 'is_uploading']),
  showSearch: state.getIn(['search', 'submitted']) && !state.getIn(['search', 'hidden']),
});

const mapDispatchToProps = (dispatch) => ({

  onChange (text) {
    dispatch(changeCompose(text));
    const pattern = /(https?:\/\/(?:www|touch)\.pixiv\.net\/(?:member|member_illust|novel\/show|novel\/member)\.php[^\n\s]+)/gm;
    if (pattern.test(text)) {
      text.match(pattern).forEach(url => {
        dispatch(requestImageCache(url));
      });
    }
  },

  onSubmit () {
    dispatch(submitCompose());
  },

  onClearSuggestions () {
    dispatch(clearComposeSuggestions());
  },

  onFetchSuggestions (token) {
    dispatch(fetchComposeSuggestions(token));
  },

  onSuggestionSelected (position, token, accountId) {
    dispatch(selectComposeSuggestion(position, token, accountId));
  },

  onChangeDateTime (dateTime) {
    dispatch(changeComposeDateTime(dateTime));
  },

  onChangeSpoilerText (checked) {
    dispatch(changeComposeSpoilerText(checked));
  },

  onPaste (files) {
    dispatch(uploadCompose(files));
  },

  onPickEmoji (position, data) {
    PawooGA.event({ eventCategory: pawooGaCategory, eventAction: 'PickEmoji' });
    dispatch(insertEmojiCompose(position, data));
  },

  onSelectTimeLimit (tag) {
    PawooGA.event({ eventCategory: pawooGaCategory, eventAction: 'SelectTimeLimit' });
    dispatch(insertTagCompose(tag));
  },

  onInsertHashtag (tag) {
    PawooGA.event({ eventCategory: pawooGaCategory, eventAction: 'InsertHashtag' });
    dispatch(insertTagCompose(tag));
  },

});

export default connect(mapStateToProps, mapDispatchToProps)(ComposeForm);
