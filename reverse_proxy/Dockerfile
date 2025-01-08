FROM openresty/openresty:1.21.4.1-0-bullseye-fat AS devcontainer

# NOTE: nginxの-pオプションの代わりにWORKDIRで指定
WORKDIR /usr/local/openresty
USER root

RUN apt-get update
# libreadline-def: For gcc build Lua
# libssl-dev, m4: For luarocks install http
RUN <<EOF bash -ex
apt-get install -y --no-install-recommends \
    gcc \
    unzip \
    make \
    libreadline-dev \
    libssl-dev \
    m4
EOF

# install Python3 to install HereRocks
RUN <<EOF bash -ex
apt-get install -y --no-install-recommends \
    python3 \
    python3-pip
    pip install hererocks
    rm -rf /var/lib/lists/
EOF

# install LuaRocks Lua
RUN hererocks lua54 -l 5.4 -r latest

# TODO: ライブラリをrockspeckとかで管理したい
RUN <<EOF bash -ex
PATH=$PATH":/usr/local/openresty/lua54/bin"
luarocks install lua-resty-redis
luarocks install lua-resty-template
luarocks install lua-resty-string
luarocks install http
luarocks install lua-resty-balancer
luarocks install lua-cjson
EOF

# www-dataユーザがコンテナ実行時に発生する権限エラーを修正
RUN <<EOF bash -ex
mkdir -p /usr/local/openresty/nginx/client_body_temp
mkdir -p /usr/local/openresty/nginx/proxy_temp
mkdir -p /usr/local/openresty/nginx/fastcgi_temp
mkdir -p /usr/local/openresty/nginx/uwsgi_temp
mkdir -p /usr/local/openresty/nginx/scgi_temp
touch /usr/local/openresty/nginx/logs/event.log
touch /usr/local/openresty/nginx/logs/nginx.pid
chown -R www-data:www-data /usr/local/openresty/nginx/logs/*
EOF

COPY ./conf/nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
COPY ./ /usr/local/openresty/reverse_proxy
EXPOSE 80
# Not using daemon mode.
USER www-data
CMD ["openresty", "-g", "daemon off;"]
