#!/bin/bash

set -eux -o pipefail

# debian packages
export DEBIAN_FRONTEND=noninteractive
base_debs="\
  apt-transport-https \
  ca-certificates \
  curl \
"
debs="\
  $(cat Aptfile) \
  autoconf \
  automake \
  bison \
  bzip2 \
  g++ \
  gawk \
  gcc \
  git \
  imagemagick \
  libav-tools \
  libffi-dev \
  libgdbm-dev \
  libgmp-dev \
  libncurses5-dev \
  libpq-dev \
  libreadline6-dev \
  libssl-dev \
  libtool \
  libyaml-dev \
  make \
  netcat-openbsd \
  openssh-client \
  patch \
  pkg-config \
  postgresql-client-9.5 \
  python \
  yarn \
  zlib1g-dev \
"
cat <<APT_CONF > /etc/apt/apt.conf.d/docker-mastodon-circleci.conf
APT::Install-Recommends "0";
APT::Install-Suggests "0";
APT_CONF
cat <<PREFERENCES > /etc/apt/preferences.d/docker-mastodon-circleci
Package: libav-tools
Pin: release n=jessie-backports
Pin-Priority: 510
PREFERENCES
if ! dpkg --verify $base_debs; then
  apt-get update -qq
  apt-get upgrade -y
  apt-get install -y $base_debs
  apt-get clean
fi
if ! dpkg --verify $debs; then
  # yarn
  curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
  echo 'deb https://dl.yarnpkg.com/debian/ stable main' > /etc/apt/sources.list.d/yarn.list

  # archived
  sed -i '/jessie-updates/d' /etc/apt/sources.list
  echo "Acquire::Check-Valid-Until false;" >> /etc/apt/apt.conf.d/10-nocheckvalid

  # ffmpeg
  echo 'deb http://archive.debian.org/debian jessie-backports main' > /etc/apt/sources.list.d/jessie-backports.list

  # postgresql
  curl -Lf https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
  echo 'deb http://apt.postgresql.org/pub/repos/apt/ jessie-pgdg main' > /etc/apt/sources.list.d/pgdg.list

  apt-get update -qq
  apt-get install -y $debs
  apt-get clean
fi

# node
export NVM_DIR=$HOME/.nvm
if [ ! -f $NVM_DIR/nvm.sh ]; then
  curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.2/install.sh | bash
fi
set +eu
. $NVM_DIR/nvm.sh
if ! nvm use; then
  nvm install $(cat .nvmrc)
  nvm use
  nvm cache clear
  rm -f /usr/local/node
  ln -s $(dirname $(dirname $(nvm which $(cat .nvmrc)))) /usr/local/node
  hash -r
fi
nvm deactivate
set -eu

# ruby
cat <<GEMRC > ~/.gemrc
install: --no-document
update: --no-document
GEMRC
export PATH=$HOME/.rbenv/bin:$PATH
hash -r
if ! which rbenv > /dev/null; then
  curl -Lf https://github.com/rbenv/rbenv/archive/master.tar.gz | tar zxf -
  mv rbenv-master ~/.rbenv
  hash -r
fi
eval "$(rbenv init -)"
if ! rbenv version-name > /dev/null; then
  # Force upgrade ruby-build to find latest ruby archive
  rm -fr ~/.rbenv/plugins/ruby-build
  curl -Lf https://github.com/rbenv/ruby-build/archive/master.tar.gz | tar zxf -
  mkdir -p ~/.rbenv/plugins
  mv ruby-build-master ~/.rbenv/plugins/ruby-build

  CONFIGURE_OPTS='--disable-install-doc' rbenv install $(cat .ruby-version)
  gem update --system
  gem install bundler --force
fi

if [ -v LOCAL_DOMAIN ]; then
  echo 127.0.0.1 $LOCAL_DOMAIN >> /etc/hosts
fi

if [ ! -v CI ] || ! $CI; then
  dpkg-query -W --showformat='${Installed-Size;10}\t${Package}\n' | sort -k1,1n | tail -n 50
  (du -d 5 -m / | grep -v '^0' | sort -n | tail -n 50) || true
fi
