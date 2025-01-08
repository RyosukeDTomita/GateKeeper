#!/bin/bash
package_list="net-tools \
  curl \
  wget \
  rsync \
  unzip \
  zip \
  vim \
  jq \
  less \
  git \
  ca-certificates \
  iputils-ping \
  dnsutils \
  iproute2 \
  tcpdump \
  procps
"
apt-get update -y
apt-get install -y --no-install-recommends ${package_list[@]}
#rm -rf /var/lib/lists


# redis-cli
setup_redis_cli() {
  # 2回目以降のbuild時にはvolumeマウントしている/cacheをつかう
  cp /cache/redis-cli /usr/local/bin/redis-cli
  if command -v redis-cli > /dev/null 2>&1; then
    return 0
  fi
  REDIS_VERSION=7.4.1
  # NOTE: `./redis-cli -h redis_app -p 6379`で接続可能
  wget https://github.com/redis/redis/archive/refs/tags/${REDIS_VERSION}.tar.gz
  tar xzvf ${REDIS_VERSION}.tar.gz
  cd redis-${REDIS_VERSION}
  make
  cp src/redis-cli /usr/local/bin
  cp src/redis-cli /cache # NOTE: ビルド時間短縮のために/tmpをvolumeマウントしてキャッシュする
  cd ..
  rm ${REDIS_VERSION}.tar.gz
  rm -rf redis-${REDIS_VERSION}
}
setup_redis_cli


# hadolint
wget -O /usr/local/bin/hadolint https://github.com/hadolint/hadolint/releases/download/v2.10.0/hadolint-Linux-x86_64
chmod 755 /usr/local/bin/hadolint
cp /usr/local/bin/hadolint /cache