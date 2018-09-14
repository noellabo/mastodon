import loadPolyfills from '../../mastodon/load_polyfills';

function loaded() {
  const GalleryContainer = require('../../pawoo/containers/standalone/gallery_container').default;
  const React            = require('react');
  const ReactDOM         = require('react-dom');
  const mountNode        = document.getElementById('pawoo-gallery');
  const props            = JSON.parse(mountNode.getAttribute('data-props'));

  ReactDOM.render(<GalleryContainer {...props} />, mountNode);
}

function main() {
  const ready = require('../../mastodon/ready').default;
  ready(loaded);
}

loadPolyfills().then(main).catch(error => {
  console.error(error);
});
