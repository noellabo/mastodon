import classNames from 'classnames';
import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import Link from 'react-router-dom/Link';
import PropTypes from 'prop-types';
import { defineMessages, injectIntl } from 'react-intl';

const messages = defineMessages({
  title: { id: 'trend_tags.title', defaultMessage: 'Suggested tag' },
});

@injectIntl
export default class TrendTagsSection extends React.PureComponent {

  static propTypes = {
    scrollable: PropTypes.bool,
    tags: ImmutablePropTypes.list.isRequired,
    refreshTrendTags: PropTypes.func.isRequired,
    insertTagCompose: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  componentDidMount () {
    this.props.refreshTrendTags();
    this.interval = setInterval(() => {
      this.props.refreshTrendTags();
    }, 1000 * 60 * 20);
  }

  componentWillUnmount () {
    clearInterval(this.interval);
  }

  handleToggleClick = (e) => {
    const tag = e.currentTarget.getAttribute('data-tag');
    this.props.insertTagCompose(`#${tag}`);
  }

  render () {
    if (this.props.tags.size === 0) {
      return null;
    }

    const { intl, scrollable } = this.props;
    return (
      <div className='trend-tags'>
        <div className='trend-tags__header'>
          <i className='fa fa-line-chart trend-tags__header__icon' aria-hidden='true' />
          <div className='trend-tags__header__name'>
            {intl.formatMessage(messages.title)}
          </div>
        </div>
        <div className={classNames('suggestion-tags__body', { scrollable })} style={{ contain: 'none' }}>
          <ul>
            {this.props.tags.map(tag => (
              <li key={tag.get('name')}>
                <div className='suggestion-tags__content'>
                  <Link className='suggestion-tags__name' to={`/timelines/tag/${tag.get('name')}`}>
                    #{tag.get('name')}
                  </Link>
                  <div className={`suggestion-tags__description ${tag.get('type') === 'suggestion' ? 'suggestion' : ''}`}>{tag.get('description')}</div>
                </div>
                <button className='suggestion-tags__button' data-tag={tag.get('name')} onClick={this.handleToggleClick}><i className='fa fa-pencil' /></button>
              </li>
            ))}
          </ul>
        </div>
      </div>
    );
  }

};
