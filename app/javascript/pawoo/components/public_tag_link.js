import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';

export default class PublicTagLink extends ImmutablePureComponent {

  static propTypes = {
    tag: ImmutablePropTypes.map.isRequired,
  };

  render () {
    return (
      <a href={this.props.tag.get('url')}>
        #{this.props.tag.get('name')}
      </a>
    );
  }

}
