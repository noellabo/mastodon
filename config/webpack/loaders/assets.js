const path = require('path');
const { env, publicPath } = require('../configuration.js');

const pawooImagePath = path.join('app', 'javascript', 'images', 'pawoo');
const pawooImageFullPath = path.resolve(pawooImagePath);
const pawooImagePathRegexp = new RegExp(`^${pawooImagePath}/`);

module.exports = {
  test: /\.(jpg|jpeg|png|gif|svg|eot|ttf|woff|woff2|mp4)$/i,
  use: [{
    loader: 'file-loader',
    options: {
      publicPath,
      name (file) {
        if (env.NODE_ENV === 'production') {
          return file.startsWith(pawooImageFullPath) ? '[path][name]-[hash].[ext]' : '[name]-[hash].[ext]';
        }

        return file.startsWith(pawooImageFullPath) ? '[path][name].[ext]' : '[name].[ext]';
      },
      outputPath(url) {
        if (pawooImagePathRegexp.test(url)) {
          return url.replace(pawooImagePathRegexp, 'pawoo/');
        } else {
          return path.basename(url);
        }
      },
    },
  }],
};
