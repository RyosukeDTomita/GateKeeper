#!/bin/bash

# NOTE: nginx.confのlua_package_pathをコピペ LUA_PATHの設定が必要
export LUA_PATH="/usr/local/openresty/lualib/?.lua;/usr/local/openresty/luajit/libs/?.lua;/usr/local/openresty/luajit/share/luajit-2.1.0-beta3/jit/?.lua;/usr/local/openresty/reverse_proxy/src/?.lua;/usr/local/openresty/reverse_proxy/src/auth/?.lua;/usr/local/openresty/lualib/resty/?.lua;/usr/local/openresty/lualib/ngx/?.lua;/usr/local/openresty/?.lua;/usr/local/openresty/luajit21/share/lua/5.1/?.lua"

pushd ../
    # NOTE: ffiはluajitでのみしかサポートされていないため，https://github.com/lunarmodules/busted/issues/369 を参考に修正
    /usr/local/openresty/luajit21/bin/busted --helper=/usr/local/openresty/reverse_proxy/tests/helper.lua -p _test tests
popd
