import React from 'react';
import PropTypes from 'prop-types';
import { Link } from 'react-router-dom';


const isModifiedEvent = event =>
  !!(event.metaKey || event.altKey || event.ctrlKey || event.shiftKey);

export default class WrappedLink extends React.Component {

  static propTypes = {
    onClick: PropTypes.func,
    target: PropTypes.string,
    replace: PropTypes.bool,
    to: PropTypes.oneOfType([PropTypes.string, PropTypes.object]).isRequired,
    innerRef: PropTypes.oneOfType([PropTypes.string, PropTypes.func]),
  };

  static contextTypes = {
    router: PropTypes.object,
    isColumnWithHistory: PropTypes.bool,
    pushHistory: PropTypes.func,
  };

  handleClick = event => {
    if (this.props.onClick) this.props.onClick(event);

    if (
      !event.defaultPrevented && // onClick prevented default
      event.button === 0 && // ignore everything but left clicks
      !this.props.target && // let browser handle "target=_blank" etc.
      !isModifiedEvent(event) // ignore clicks with modifier keys
    ) {
      event.preventDefault();

      const { history } = this.context.router;
      const { replace, to } = this.props;

      if (replace) {
        history.replace(to);
      } else {
        this.context.pushHistory(to);
      }
    }
  };

  render() {
    const { replace, to, innerRef, ...props } = this.props; // eslint-disable-line no-unused-vars

    if (this.context.isColumnWithHistory) {
      return (
        <a {...props} onClick={this.handleClick} ref={innerRef} />
      );
    } else {
      return(
        <Link {...props} to={to} replace={replace} innerRef={innerRef} />
      );
    }
  }

}
