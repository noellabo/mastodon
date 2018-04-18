import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { Link } from 'react-router-dom';
import PropTypes from 'prop-types';
import classNames from 'classnames';
import { FormattedMessage, injectIntl, defineMessages } from 'react-intl';

const messages = defineMessages({
  show: { id: 'column_header.show_settings', defaultMessage: 'Show settings' },
  hide: { id: 'column_header.hide_settings', defaultMessage: 'Hide settings' },
  moveLeft: { id: 'column_header.moveLeft_settings', defaultMessage: 'Move column to the left' },
  moveRight: { id: 'column_header.moveRight_settings', defaultMessage: 'Move column to the right' },
  pawooMaximize: { id: 'pawoo.maximize', defaultMessage: 'Maximize' },
});

@injectIntl
export default class ColumnHeader extends React.PureComponent {

  static contextTypes = {
    router: PropTypes.object,
    pawooPopHistory: PropTypes.func,
  };

  static propTypes = {
    intl: PropTypes.object.isRequired,
    title: PropTypes.oneOfType([PropTypes.string.isRequired, PropTypes.node]).isRequired,
    icon: PropTypes.string,
    active: PropTypes.bool,
    multiColumn: PropTypes.bool,
    showBackButton: PropTypes.bool,
    children: PropTypes.node,
    pinned: PropTypes.bool,
    onPin: PropTypes.func,
    onMove: PropTypes.func,
    onClick: PropTypes.func,
    pawoo: ImmutablePropTypes.map,
    pawooUrl: PropTypes.string,
  };

  state = {
    collapsed: true,
    animating: false,
  };

  componentWillUpdate({ pawoo }) {
    if (pawoo && pawoo.get('collapsed')) {
      this.setState({ collapsed: true });
    }
  }

  handleToggleClick = (e) => {
    e.stopPropagation();
    this.setState({ collapsed: !this.state.collapsed, animating: true });

    if (this.state.collapsed && this.props.pawoo) {
      const onExpand = this.props.pawoo.get('onExpand');

      if (onExpand) {
        onExpand();
      }
    }
  }

  handleTitleClick = () => {
    this.props.onClick();
  }

  handleMoveLeft = () => {
    this.props.onMove(-1);
  }

  handleMoveRight = () => {
    this.props.onMove(1);
  }

  handleBackClick = () => {
    this.context.pawooPopHistory();
  }

  handleTransitionEnd = () => {
    this.setState({ animating: false });
  }

  render () {
    const { title, icon, active, children, pinned, onPin, multiColumn, showBackButton, intl: { formatMessage }, pawoo, pawooUrl } = this.props;
    const { collapsed, animating } = this.state;

    const wrapperClassName = classNames('column-header__wrapper', {
      'active': active,
    });

    const buttonClassName = classNames('column-header', {
      'active': active,
    });

    const collapsibleClassName = classNames('column-header__collapsible', {
      'collapsed': collapsed,
      'animating': animating,
    });

    const collapsibleButtonClassName = classNames('column-header__button', {
      'active': !collapsed,
    });

    let extraContent, pinButton, moveButtons, backButton, collapseButton;

    if (children) {
      extraContent = (
        <div key='extra-content' className='column-header__collapsible__extra'>
          {children}
        </div>
      );
    }

    if (multiColumn && pinned) {
      pinButton = <button key='pin-button' className='text-btn column-header__setting-btn' onClick={onPin}><i className='fa fa fa-times' /> <FormattedMessage id='column_header.unpin' defaultMessage='Unpin' /></button>;

      moveButtons = (
        <div key='move-buttons' className='column-header__setting-arrows'>
          <button title={formatMessage(messages.moveLeft)} aria-label={formatMessage(messages.moveLeft)} className='text-btn column-header__setting-btn' onClick={this.handleMoveLeft}><i className='fa fa-chevron-left' /></button>
          <button title={formatMessage(messages.moveRight)} aria-label={formatMessage(messages.moveRight)} className='text-btn column-header__setting-btn' onClick={this.handleMoveRight}><i className='fa fa-chevron-right' /></button>
        </div>
      );
    } else if (multiColumn) {
      pinButton = <button key='pin-button' className='text-btn column-header__setting-btn' onClick={onPin}><i className='fa fa fa-plus' /> <FormattedMessage id='column_header.pin' defaultMessage='Pin' /></button>;
    }

    if (!pinned && ((multiColumn && pawoo && pawoo.get('multiColumn')) || showBackButton)) {
      backButton = (
        <button onClick={this.handleBackClick} className='column-header__back-button'>
          <i className='fa fa-fw fa-chevron-left column-back-button__icon' />
          <FormattedMessage id='column_back_button.label' defaultMessage='Back' />
        </button>
      );
    }

    let pawooMaximizeButton;

    if (pinned && pawooUrl && pawoo && !pawoo.get('multiColumn')) {
      pawooMaximizeButton = (
        <Link
          className='column-header__button'
          onClick={pawoo.get('onCollapse')}
          style={{ margin: 'auto' }}
          to={pawooUrl}
        ><i aria-label={formatMessage(messages.pawooMaximize)} className='fa fa-window-maximize' /></Link>
      );
    }

    const collapsedContent = [
      extraContent,
    ];

    if (multiColumn) {
      collapsedContent.push(moveButtons);
      collapsedContent.push(pinButton);
    }

    if (children || multiColumn) {
      collapseButton = <button className={collapsibleButtonClassName} aria-label={formatMessage(collapsed ? messages.show : messages.hide)} aria-pressed={collapsed ? 'false' : 'true'} onClick={this.handleToggleClick}><i className='fa fa-sliders' /></button>;
    }

    return (
      <div className={wrapperClassName}>
        <h1 className={buttonClassName}>
          <button onClick={this.handleTitleClick}>
            {icon && <i className={`fa fa-fw fa-${icon} column-header__icon`} />}
            {title}
          </button>

          <div className='column-header__buttons'>
            {backButton}
            {pawooMaximizeButton}
            {collapseButton}
          </div>
        </h1>

        <div className={collapsibleClassName} tabIndex={collapsed ? -1 : null} onTransitionEnd={this.handleTransitionEnd}>
          <div className='column-header__collapsible-inner'>
            {(!collapsed || animating) && collapsedContent}
          </div>
        </div>
      </div>
    );
  }

}
