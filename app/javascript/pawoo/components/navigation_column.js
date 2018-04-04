import React from 'react';
import Announcements from './announcements';
import WebTagLink from './web_tag_link';
import TrendTagsContainer from '../containers/trend_tags_container';

export default function NavigationColumn() {
  return (
    <div className='column' style={{ flexGrow: '0' }}>
      <TrendTagsContainer Tag={WebTagLink} scrollable />
      <div style={{ marginTop: '10px' }}>
        <Announcements />
      </div>
    </div>
  );
}
