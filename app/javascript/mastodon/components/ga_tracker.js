import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { trackPage } from '../actions/ga';

const gaTracker = (WrappedComponent) => {

  const HOC = class extends Component {

    static propTypes = {
      location: PropTypes.object,
    };

    componentDidMount() {
      const page = this.props.location.pathname;
      trackPage(page);
    }

    componentWillReceiveProps(nextProps) {
      const currentPage = this.props.location.pathname;
      const nextPage = nextProps.location.pathname;

      if (currentPage !== nextPage) {
        trackPage(nextPage);
      }
    }

    render() {
      return <WrappedComponent {...this.props} />;
    }

  };

  return HOC;
};

export default gaTracker;
