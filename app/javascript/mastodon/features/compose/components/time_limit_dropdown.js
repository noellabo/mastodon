import React from 'react';
import Dropdown, { DropdownTrigger, DropdownContent } from 'react-simple-dropdown'; // TODO
import PropTypes from 'prop-types';
import { injectIntl, defineMessages } from 'react-intl';

const messages = defineMessages({
  days: { id: 'time_limit.days', defaultMessage: '{days, number} {days, plural, one {day} other {days}} later' },
  hours: { id: 'time_limit.hours', defaultMessage: '{hours, number} {hours, plural, one {hour} other {hours}} later' },
  minutes: { id: 'time_limit.minutes', defaultMessage: '{minutes, number} {minutes, plural, one {minute} other {minutes}} later' },
  select_time_limit: { id: 'time_limit.select_time_limit', defaultMessage: 'Specify the time of automatic disappearance (Beta)' },
  time_limit_note: { id: 'time_limit.time_limit_note', defaultMessage: 'Note: If specified, it will not be delivered to external instances.' },
});

const dropdownStyle = {
  position: 'absolute',
  right: '3px',
  top: '35px',
};

@injectIntl
export default class TimeLimitDropdown extends React.PureComponent {

  static propTypes = {
    onSelectTimeLimit: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  handleClick = (e) => {
    const value = e.currentTarget.getAttribute('data-value');
    this.dropdown.hide();
    this.props.onSelectTimeLimit(value);
  }

  setRef = (c) => {
    this.dropdown = c;
  }

  render () {
    const { intl } = this.props;

    const options = [
      { value: '#exp1m', text: intl.formatMessage(messages.minutes, { minutes: 1 }) },
      { value: '#exp10m', text: intl.formatMessage(messages.minutes, { minutes: 10 }) },
      { value: '#exp1h', text: intl.formatMessage(messages.hours, { hours: 1 }) },
      { value: '#exp12h', text: intl.formatMessage(messages.hours, { hours: 12 }) },
      { value: '#exp1d', text: intl.formatMessage(messages.days, { days: 1 }) },
      { value: '#exp7d', text: intl.formatMessage(messages.days, { days: 7 }) },
    ];

    return (
      <Dropdown className='time-limit-dropdown' ref={this.setRef} style={dropdownStyle}>
        <DropdownTrigger className='icon-button inverted' title={intl.formatMessage(messages.select_time_limit)}>
          <i className='fa fa-fw fa-clock-o' aria-hidden='true' />
        </DropdownTrigger>

        <DropdownContent className='dropdown__left'>
          <div className='time-limit-dropdown__dropdown'>
            <div className='time-limit-dropdown__header'>
              <strong>{intl.formatMessage(messages.select_time_limit)}</strong>
              <div className='time-limit-dropdown__header_note'>
                <strong>{intl.formatMessage(messages.time_limit_note)}</strong>
              </div>
            </div>
            <div className='time-limit-dropdown__options'>
              {options.map(item =>
                <div role='button' tabIndex='0' key={item.value} onClick={this.handleClick} data-value={item.value} className='time-limit-dropdown__option'>
                  <div className='time-limit-dropdown__option__content'>
                    {item.text}
                  </div>
                </div>
              )}
            </div>
          </div>
        </DropdownContent>
      </Dropdown>
    );
  }

}
