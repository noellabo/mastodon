import React from 'react';
import PropTypes from 'prop-types';
import { ScrollContainer } from 'react-router-scroll-4';

export default class WrappedScrollContainer extends React.Component {

  static propTypes = {
    scrollKey: PropTypes.string.isRequired,
    shouldUpdateScroll: PropTypes.func,
    children: PropTypes.element.isRequired,
  };

  static contextTypes = {
    isColumnWithHistory: PropTypes.bool,
  };

  render() {
    if (this.context.isColumnWithHistory) {
      return React.Children.only(this.props.children);
    }

    const { scrollKey, shouldUpdateScroll } = this.props;

    return(
      <ScrollContainer scrollKey={scrollKey} shouldUpdateScroll={shouldUpdateScroll}>
        { React.Children.only(this.props.children) }
      </ScrollContainer>
    );
  }

}
