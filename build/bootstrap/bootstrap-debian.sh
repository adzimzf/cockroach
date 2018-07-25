#!/usr/bin/env bash
#
# On a Debian/Ubuntu system, bootstraps a docker install and the cockroach
# repo.

set -euxo pipefail

curl -fsSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | sudo apt-key add -
echo "deb https://deb.nodesource.com/node_6.x xenial main" | sudo tee /etc/apt/sources.list.d/nodesource.list

curl -fsSL https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

sudo apt-get update
sudo apt-get dist-upgrade -y
sudo apt-get install -y --no-install-recommends \
  mosh \
  autoconf \
  cmake \
  ccache \
  docker.io \
  libncurses-dev \
  make \
  gcc \
  g++ \
  git \
  nodejs \
  yarn

sudo adduser "${USER}" docker

# Configure environment variables.
echo 'export PATH="/usr/lib/ccache:${PATH}:/usr/local/go/bin"' >> ~/.bashrc_bootstrap
echo 'export COCKROACH_BUILDER_CCACHE=1' >> ~/.bashrc_bootstrap
echo '. ~/.bashrc_bootstrap' >> ~/.bashrc
. ~/.bashrc_bootstrap

# Install Go.
trap 'rm -f /tmp/go.tgz' EXIT
curl https://dl.google.com/go/go1.10.3.linux-amd64.tar.gz > /tmp/go.tgz
sha256sum - <<EOF
fa1b0e45d3b647c252f51f5e1204aba049cde4af177ef9f2181f43004f901035  /tmp/go.tgz
EOF
sudo tar -C /usr/local -zxf /tmp/go.tgz

# Clone CockroachDB.
go get -d github.com/cockroachdb/cockroach

# Install the Unison file-syncer.
. bootstrap/bootstrap-unison.sh
