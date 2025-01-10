# GateKeeper

![un license](https://img.shields.io/github/license/RyosukeDTomita/GateKeeper)

## INDEX

- [ABOUT](#about)
- [ENVIRONMENT](#environment)
- [PREPARING](#preparing)
- [HOW TO USE](#how-to-use)

---

## ABOUT

I used OpenResty to create a reverse proxy to try various authentication methods.

---

## ENVIRONMENT

- openresty/openresty:1.21.4.1-0-bullseye-fat
- redis:8.0-M02-bookworm

---

## PREPARING

1. install VSCode, Docker
2. install VSCode Extensions *Dev ContainerS*
3. On the VSCode, `Ctrl shift p` and run `Dev Containers: Rebuild Containers`

---

## HOW TO USE

```shell
docker compose up -d
```

### For Dev Containers

On the VSCode, `Ctrl shift p` and run `Dev Containers: Rebuild Containers`

#### How to restart OpenResty

In the Dev Containers, OpenResty is not started using the `CMD` directive in the Dcokerfile. Because, to restart OpenResty, it would require rebuilding the container. It takes a lot of times.

> [!NOTE]
> Since OpenResty is running as a persistent process to keep the container running, stopping openresty will stop the container.

Instead, I set here in the devcontainer.json.

```json
  "overrideCommand": true,
  "postStartCommand": "openresty",
```

This allows for restarting openresty using shell command, as `overrideCommand` is used for the container's persistent process.

```shell
openresty -s reload
```

> [!NOTE]
> - Sometime, `openresty -s reload` not work well, then `openresty -s stop` and restart `openresty`.
> - If use `postCreateCommand` instead of `PostStartCommand`, the following error occures.
>
>   ```
>   nginx: [alert] could not open error log file: open() "/usr/local/openresty/logs/error.log" failed (2: No such file or directory)
>   2025/01/08 00:55:23 [emerg] 1630#1630: open() "/usr/local/openresty/conf/nginx.conf" failed (2: No such file or directory)
>   ```

#### How to see the OpenResty log

> [!NOTE]
> access.log, error.log are redirected to stdout.
>
> ```shell
> ls -l /usr/local/openresty/nginx/logs/access.log 
> lrwxrwxrwx 1 root root 11 May 25  2022 /usr/local/openresty/nginx/logs/access.log -> /dev/stdout
> ```

So, the easiest way is `docker logs`

```shell
# access.log, error.log
docker compose logs reverse_proxy_app
```

```shell
# eventlogs
cat /usr/local/openresty/nginx/logs/error.log
```

---
