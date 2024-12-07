# GateKeeper

![un license](https://img.shields.io/github/license/RyosukeDTomita/GateKeeper)-->

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

> [!NOTE]
> OpenResty process is running at 1
>
> ```
> root           1       0  0 09:38 ?        00:00:00 nginx: maste> r process openresty -g daemon off;
> ```
Therefore, killing the process will restart OpenResty.

```shell
kill 1
```

#### How to see the OpenResty log

> [!NOTE]
> access.log, error.log are redirected to stdout.
>
> ```
> ls -l /usr/local/openresty/nginx/logs/access.log 
lrwxrwxrwx 1 root root 11 May 25  2022 /usr/local/openresty/nginx/logs/access.log -> /dev/stdout
> ```

So, the easiest way is `docker logs`

```shell
# access.log, error.log
docker compose logs reverse_proxy_app
```

```
# eventlogs
cat /usr/local/openresty/nginx/logs/error.log
```

---
