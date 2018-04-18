import React from 'react';
import PropTypes from 'prop-types';

import Column from '../../../components/column';
import ColumnHeader from '../../../components/column_header';
import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';

export default class ColumnLoading extends ImmutablePureComponent {

  static propTypes = {
    title: PropTypes.oneOfType([PropTypes.node, PropTypes.string]),
    icon: PropTypes.string,
    pawoo: ImmutablePropTypes.map.isRequired,
  };

  static defaultProps = {
    title: '',
    icon: '',
  };

  render() {
    let { title, icon, pawoo } = this.props;
    return (
      <Column>
        <ColumnHeader icon={icon} title={title} multiColumn={false} focusable={false} pawoo={pawoo} />
        <div className='scrollable' />
      </Column>
    );
  }

}
