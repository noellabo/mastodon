import React from 'react';
import PropTypes from 'prop-types';
import Link from '../../../../pawoo/components/wrapped_link';

const ColumnLink = ({ icon, text, to, href, method, badge, ...other }) => {
  const badgeElement = typeof badge !== 'undefined' ? <span className='column-link__badge'>{badge}</span> : null;

  if (href) {
    return (
      <a href={href} className='column-link' data-method={method} {...other}>
        <i className={`fa fa-fw fa-${icon} column-link__icon`} />
        {text}
        {badgeElement}
      </a>
    );
  } else {
    return (
      <Link to={to} className='column-link'>
        <i className={`fa fa-fw fa-${icon} column-link__icon`} />
        {text}
        {badgeElement}
      </Link>
    );
  }
};

ColumnLink.propTypes = {
  icon: PropTypes.string.isRequired,
  text: PropTypes.string.isRequired,
  to: PropTypes.string,
  href: PropTypes.string,
  method: PropTypes.string,
  badge: PropTypes.node,
};

export default ColumnLink;
