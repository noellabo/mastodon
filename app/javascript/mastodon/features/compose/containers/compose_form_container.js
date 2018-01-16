import { connect } from 'react-redux';
import ComposeForm from '../components/compose_form';
import { uploadCompose } from '../../../actions/compose';
import {
  changeCompose,
  submitCompose,
  clearComposeSuggestions,
  fetchComposeSuggestions,
  selectComposeSuggestion,
  changeComposeDateTime,
  changeComposeSpoilerText,
  insertEmojiCompose,
  requestImageCache,
  insertTagCompose,
} from '../../../actions/compose';

const mapStateToProps = state => ({
  text: state.getIn(['compose', 'text']),
  published: state.getIn(['compose', 'published']),
  suggestion_token: state.getIn(['compose', 'suggestion_token']),
  suggestions: state.getIn(['compose', 'suggestions']),
  spoiler: state.getIn(['compose', 'spoiler']),
  spoiler_text: state.getIn(['compose', 'spoiler_text']),
  privacy: state.getIn(['compose', 'privacy']),
  focusDate: state.getIn(['compose', 'focusDate']),
  preselectDate: state.getIn(['compose', 'preselectDate']),
  is_submitting: state.getIn(['compose', 'is_submitting']),
  is_uploading: state.getIn(['compose', 'is_uploading']),
  me: state.getIn(['compose', 'me']),
  showSearch: state.getIn(['search', 'submitted']) && !state.getIn(['search', 'hidden']),
  hash_tag_suggestions: state.getIn(['compose', 'hash_tag_suggestions']),
  hash_tag_token: state.getIn(['compose', 'hash_tag_token']),
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
    dispatch(insertEmojiCompose(position, data));
  },

  onSelectTimeLimit (tag) {
    dispatch(insertTagCompose(tag));
  },

  onInsertHashtag (tag) {
    dispatch(insertTagCompose(tag));
  },

});

export default connect(mapStateToProps, mapDispatchToProps)(ComposeForm);
