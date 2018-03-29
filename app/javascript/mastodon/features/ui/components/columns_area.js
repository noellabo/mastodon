import React from 'react';
import PropTypes from 'prop-types';
import { injectIntl } from 'react-intl';
import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';

import ReactSwipeableViews from 'react-swipeable-views';
import { links, getIndex, getLink } from './tabs_bar';

import ColumnLoading from './column_loading';
import DrawerLoading from './drawer_loading';
import BundleColumnError from './bundle_column_error';

import detectPassiveEvents from 'detect-passive-events';
import { scrollRight } from '../../../scroll';
import PawooNavigationColumn from '../../../../pawoo/components/navigation_column';
import PawooSingleColumnOnboardingContainer from '../../../../pawoo/containers/single_column_onboarding_container';
import ColumnContainerWithHistory from '../../../../pawoo/containers/column_container_with_history';

@component => injectIntl(component, { withRef: true })
export default class ColumnsArea extends ImmutablePureComponent {

  static contextTypes = {
    router: PropTypes.object.isRequired,
  };

  static propTypes = {
    intl: PropTypes.object.isRequired,
    columns: ImmutablePropTypes.list.isRequired,
    isModalOpen: PropTypes.bool.isRequired,
    singleColumn: PropTypes.bool,
    children: PropTypes.node,
    pawooPage: PropTypes.string,
  };

  state = {
    shouldAnimate: false,
  };

  static childContextTypes = {
    pawooIsColumnWithHistory: PropTypes.bool,
    pawooColumnLocationKey: PropTypes.string,
    pawooPushHistory: PropTypes.func,
    pawooPopHistory: PropTypes.func,
  };

  getChildContext() {
    return ({
      pawooIsColumnWithHistory: false,
      pawooPushHistory: (path) => {this.context.router.history.push(path);},
      pawooPopHistory: () => {
        if (window.history && window.history.length === 1) {
          this.context.router.history.push('/');
        } else {
          this.context.router.history.goBack();
        }
      },
      pawooColumnLocationKey: this.context.router.route.location.key,
    });
  }

  componentWillReceiveProps() {
    this.setState({ shouldAnimate: false });
  }

  componentDidMount() {
    if (!this.props.singleColumn) {
      this.node.addEventListener('wheel', this.handleWheel,  detectPassiveEvents.hasSupport ? { passive: true } : false);
    }

    this.lastIndex   = getIndex(this.context.router.history.location.pathname);
    this.isRtlLayout = document.getElementsByTagName('body')[0].classList.contains('rtl');

    this.setState({ shouldAnimate: true });
  }

  componentWillUpdate(nextProps) {
    if (this.props.singleColumn !== nextProps.singleColumn && nextProps.singleColumn) {
      this.node.removeEventListener('wheel', this.handleWheel);
    }
  }

  componentDidUpdate(prevProps) {
    if (this.props.singleColumn !== prevProps.singleColumn && !this.props.singleColumn) {
      this.node.addEventListener('wheel', this.handleWheel,  detectPassiveEvents.hasSupport ? { passive: true } : false);
    }
    this.lastIndex = getIndex(this.context.router.history.location.pathname);
    this.setState({ shouldAnimate: true });
  }

  componentWillUnmount () {
    if (!this.props.singleColumn) {
      this.node.removeEventListener('wheel', this.handleWheel);
    }
  }

  handleChildrenContentChange() {
    if (!this.props.singleColumn) {
      const modifier = this.isRtlLayout ? -1 : 1;
      this._interruptScrollAnimation = scrollRight(this.node, (this.node.scrollWidth - window.innerWidth) * modifier);
    }
  }

  handleSwipe = (index) => {
    this.pendingIndex = index;

    const nextLinkTranslationId = links[index].props['data-preview-title-id'];
    const currentLinkSelector = '.tabs-bar__link.active';
    const nextLinkSelector = `.tabs-bar__link[data-preview-title-id="${nextLinkTranslationId}"]`;

    // HACK: Remove the active class from the current link and set it to the next one
    // React-router does this for us, but too late, feeling laggy.
    document.querySelector(currentLinkSelector).classList.remove('active');
    document.querySelector(nextLinkSelector).classList.add('active');
  }

  handleAnimationEnd = () => {
    if (typeof this.pendingIndex === 'number') {
      this.context.router.history.push(getLink(this.pendingIndex));
      this.pendingIndex = null;
    }
  }

  handleWheel = () => {
    if (typeof this._interruptScrollAnimation !== 'function') {
      return;
    }

    this._interruptScrollAnimation();
  }

  setRef = (node) => {
    this.node = node;
  }

  renderView = (link, index) => {
    const columnIndex = getIndex(this.context.router.history.location.pathname);
    const title = this.props.intl.formatMessage({ id: link.props['data-preview-title-id'] });
    const icon = link.props['data-preview-icon'];

    const view = (index === columnIndex) ?
      React.cloneElement(this.props.children) :
      <ColumnLoading title={title} icon={icon} />;

    return (
      <div className='columns-area' key={index}>
        {view}
      </div>
    );
  }

  renderLoading = columnId => () => {
    return columnId === 'COMPOSE' ? <DrawerLoading /> : <ColumnLoading />;
  }

  renderError = (props) => {
    return <BundleColumnError {...props} />;
  }

  render () {
    const { columns, children, singleColumn, isModalOpen, pawooPage } = this.props;
    const { shouldAnimate } = this.state;

    const pawooHasPinnedColumn = columns.some(column => column.get('id') !== 'COMPOSE');

    const columnIndex = getIndex(this.context.router.history.location.pathname);
    this.pendingIndex = null;

    if (singleColumn) {
      if (pawooPage === 'ONBOARDING') {
        return <PawooSingleColumnOnboardingContainer />;
      }

      return columnIndex !== -1 ? (
        <ReactSwipeableViews index={columnIndex} onChangeIndex={this.handleSwipe} onTransitionEnd={this.handleAnimationEnd} animateTransitions={shouldAnimate} springConfig={{ duration: '400ms', delay: '0s', easeFunction: 'ease' }} style={{ height: '100%' }}>
          {links.map(this.renderView)}
        </ReactSwipeableViews>
      ) : <div className='columns-area'>{children}</div>;
    }

    return (
      <div className={`columns-area ${ isModalOpen ? 'unscrollable' : '' }`} ref={this.setRef}>
        {columns.map(column => {
          return (
            <ColumnContainerWithHistory key={column.get('uuid')} column={column} />
          );
        })}

        <div style={{ display: 'flex', flex: pawooPage === 'DEFAULT' ? '1 330px' : null }}>
          {React.Children.map(children, child => React.cloneElement(child, { multiColumn: true, pawooHasPinnedColumn }))}
        </div>

        {pawooHasPinnedColumn || pawooPage !== 'DEFAULT' || <PawooNavigationColumn />}
      </div>
    );
  }

}
