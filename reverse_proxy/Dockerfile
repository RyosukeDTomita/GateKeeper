FROM openresty/openresty:1.21.4.1-0-bullseye-fat AS devcontainer
WORKDIR /usr/local/openresty

ARG OpenRestyVersion="1.25.3.2"
USER root

RUN apt-get update

RUN <<EOF bash -ex
apt install -y --no-install-recommends \
    gcc \
    unzip \
    make \
    libreadline-dev
EOF

# install Python3 to install HereRocks
RUN <<EOF bash -ex
apt install -y --no-install-recommends \
    python3 \
    python3-pip
    pip install hererocks
    rm -rf /var/lib/lists/
EOF

# install LuaRocks
RUN hererocks lua54 -l 5.4 -r latest

# install lua libraries
RUN <<EOF bash -ex
PATH=$PATH":/usr/local/openresty/lua54/bin"
luarocks install lua-resty-redis
EOF


# FROM devcontainer AS deploy
# # nginxの-pオプションの代わりにWORKDIRを指定
# WORKDIR /usr/local/openresty/reverse_proxy
# COPY ./conf/nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
# EXPOSE 80
# # Not using daemon mode.
# CMD ["openresty", "-g", "daemon off;"]
