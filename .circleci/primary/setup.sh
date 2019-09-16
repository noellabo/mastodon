#!/bin/bash

set -eux -o pipefail

# debian packages
export DEBIAN_FRONTEND=noninteractive
base_debs="\
  ca-certificates \
  curl \
  gnupg \
"
debs="\
  $(cat Aptfile) \
  git \
  imagemagick \
  libssl-dev \
  libreadline-dev \
  zlib1g-dev \
  autoconf \
  bison \
  build-essential \
  libyaml-dev \
  libreadline-dev \
  libncurses5-dev \
  libffi-dev \
  libgdbm-dev \
  postgresql-client-9.5 \
  python \
  yarn \
"
cat <<APT_CONF > /etc/apt/apt.conf.d/docker-mastodon-circleci.conf
APT::Install-Recommends "0";
APT::Install-Suggests "0";
APT_CONF
if ! dpkg --verify $base_debs; then
  apt update -qq
  apt upgrade -y
  apt install -y $base_debs
  apt clean
fi
if ! dpkg --verify $debs; then
  # yarn
  curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
  echo 'deb https://dl.yarnpkg.com/debian/ stable main' > /etc/apt/sources.list.d/yarn.list

  # postgresql
  curl -Lf https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
  echo 'deb http://apt.postgresql.org/pub/repos/apt/ buster-pgdg main' > /etc/apt/sources.list.d/pgdg.list

  apt update -qq
  apt install -y $debs
  apt clean
fi

# node
export NVM_DIR=$HOME/.nvm
if [ ! -f $NVM_DIR/nvm.sh ]; then
  mkdir -p $NVM_DIR
  curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash
fi
set +eu
. $NVM_DIR/nvm.sh
if ! nvm use; then
  nvm install $(cat .nvmrc)
  nvm use $(cat .nvmrc)
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
