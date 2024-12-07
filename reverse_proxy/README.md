# OpenResty Reverse Proxy Document

## INDEX

- [Lua Script](#lua-script)
- [OpenResty](#openresty)

---

## Lua Script

### hererocks

[hererocks GitHub](https://github.com/mpeterv/hererocks)

> hererocks is a single file Python 2.7/3.x script for installing Lua (or LuaJIT) and LuaRocks, its package manager, into a local directory. It configures Lua to only see packages installed by that bundled version of LuaRocks, so that the installation is isolated.

hererocksを使ってLuaとluarocksをインストールしている。

### How to add Lua library

ライブラリはluarocksを使って管理する

```shell
luarocks install lua-resty-redis
luarocks install lua-resty-template
```

---

## OpenResty(nginx)

[OpenResty](https://openresty.org/en/)

### What's OpenResty

[3つのnginxをうまく使い分けよう](https://engineering.mercari.com/blog/entry/2016-05-25-170108/)

nginx can be devided into 4 types.

- nginx
- NGINX Plus: on business
- OpenResty: nginx + ngx_lua + third party module + resty + LUa/LuaJIT
- Tengine: Forked by alibaba from the original nginx

### nginx.conf

[Configuration File's Structure](https://nginx.org/en/docs/beginners_guide.html)

> nginx consists of modules which are controlled by directives specified in the configuration file. Directives are divided into simple directives and block directives. A simple directive consists of the name and parameters separated by spaces and ends with a semicolon (;). A block directive has the same structure as a simple directive, but instead of the semicolon it ends with a set of additional instructions surrounded by braces ({ and }). If a block directive can have other directives inside braces, it is called a context (examples: events, http, server, and location).

nginx.confは以下で構成される。
- Simple directive: パラメータと値を空白で区切ってセミコロンで終わる 。e.g. `worker_processes 1;`
- block directive: {}で囲まれる。
  - block directiveの中にblock directiveが記載される場合はこれをcontextと呼ぶ。

> The events and http directives reside in the main context, server in http, and location in server. 

- main(明示的に書かない)
  - http
    - server
    - location
  - events


#### `server` block

> Generally, the configuration file may include several server blocks distinguished by ports on which they listen to and by server names. Once nginx decides which server processes a request, it tests the URI specified in the request’s header against the parameters of the location directives defined inside the server block.

- `listen`するポートが変わると`server`ブロックを分けるのが一般的

```
http {
  server {
    listen 80;
    location / {
      root /data/www;
    }
  }
}
```


#### `location` block

> This location block specifies the “/” prefix compared with the URI from the request. For matching requests, the URI will be added to the path specified in the root directive, that is, to /data/www, to form the path to the requested file on the local file system.

- `location`で指定したパスにアクセスされた時に`root`に指定したパスに配信される。
- [locationの優先順位が記載されているブログ](https://paulownia.hatenablog.com/entry/2018/07/21/140906)

```

    location / {
      root /data/www;
    }
```

#### Reverse Proxy

> In the first location block, put the proxy_pass directive with the protocol, name and port of the proxied server specified in the parameter (in our case, it is http://localhost:8080):

`proxy_pass`にプロキシされるサーバを指定する。

```
server {
    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
    }

    location /images/ {
        root /data;
    }
}
```
[Passing Request Headers](https://docs.nginx.com/nginx/admin-guide/web-server/reverse-proxy/)

> By default, NGINX redefines two header fields in proxied requests, “Host” and “Connection”, and eliminates the header fields whose values are empty strings. “Host” is set to the $proxy_host variable, and “Connection” is set to close.
NGINXではプロキシされるリクエストに対してデフォルトでは以下を実施している。
- HTTPヘッダーの`Host`と`Connection`が上書きされている。
  - `Host`: (`$proxy_pass`に指定したFQDN)`$proxy_host`に書き換わる
  > [!NOTE]
  > [nginx公式ドキュメント](https://nginx.org/en/docs/http/ngx_http_proxy_module.html#var_proxy_host)に以下の記述がある。
  >> `$proxy_host`
  >> name and port of a proxied server as specified in the proxy_pass directive;
  > つまり，`proxy_pass`を設定すると`$proxy_host`が書き換わる
  - `Connection`: closeに変わる
- 値が空文字列のヘッダフィールドを削除する --> 逆にプロキシされるリクエストから消したいヘッダは空にすると良い。

> To change these setting, as well as modify other header fields, use the proxy_set_header directive. This directive can be specified in a location or higher. It can also be specified in a particular server context or in the http block. For example:

#### events

[Nginx Documentation events](https://nginx.org/en/docs/ngx_core_module.html#events)

> Provides the configuration file context in which the directives that affect connection processing are specified. 

接続処理に関係のあるディレクティブを指定する。

- `worker_connections`: 同時最大接続数

#### upstream

upstreamはngx_http_upstream_moduleモジュールの機能である。
[Module ngx_http_upstream_module](https://nginx.org/en/docs/http/ngx_http_upstream_module.html)

> The ngx_http_upstream_module module is used to define groups of servers that can be referenced by the proxy_pass, fastcgi_pass, uwsgi_pass, scgi_pass, memcached_pass, and grpc_pass directives.

- サーバのグループを定義するために使用される。
- 重み付けをしてロードバランシングすることもできる。

```
upstream backend {
    server backend1.example.com       weight=5;
    server backend2.example.com:8080;
    server unix:/tmp/backend3;

    server backup1.example.com:8080   backup;
    server backup2.example.com:8080   backup;
}
```

> [!NOTE]
> `upstream backend`を定義した場合`proxy_pass`などでhttp://backendを指定した場合に名前解決される。

#### Alphabetical index of variables

[Alphabetical index of variables](https://nginx.org/en/docs/varindex.html)にnginx.conf内で使用できる事前定義された変数がだいたい記載されていそう

#### Error Log level

nginxではlogレベルを使うことで出力するログを制御できる。

[nginxのログレベルについて](https://blowin.hatenadiary.com/entry/2016/04/27/nginx%E3%81%AE%E3%82%A8%E3%83%A9%E3%83%BC%E3%83%AD%E3%82%B0%E5%87%BA%E5%8A%9B%E6%96%B9%E6%B3%95%E3%81%A8%E7%A2%BA%E8%AA%8D)
TODO: そのうちちゃんと公式ドキュメントを読む

> - emerg: Emergency situations where the system is in an unusable state.

> - alert: Severe situation where action is needed promptly.

> - crit: Important problems that need to be addressed.

> - error: An Error has occurred. Something was unsuccessful.

> - warn: Something out of the ordinary happened, but not a cause for concern.

> - notice: Something normal, but worth noting has happened.

> - info: An informational message that might be nice to know.

> - debug: Debugging information that can be useful to pinpoint where a problem is occurring.



