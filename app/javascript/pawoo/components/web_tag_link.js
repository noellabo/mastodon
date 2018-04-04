import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { Link } from 'react-router-dom';

export default class WebTagLink extends ImmutablePureComponent {

  static propTypes = {
    tag: ImmutablePropTypes.map.isRequired,
  };

  render () {
    const name = this.props.tag.get('name');
    return <Link to={`/timelines/tag/${name}`}>#{name}</Link>;
  }

}
