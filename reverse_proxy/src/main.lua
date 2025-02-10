local resty_redis = require "resty.redis"
local redis = resty_redis:new()
local basic_auth = require "basic_auth"
local digest_auth = require "digest_auth"
local form_auth = require "form_auth"


-- redisに接続する。compose.yamlのサービス名で名前解決できる
local function connect_redis(redis_fqdn, redis_port)
    local ok, err = redis:connect(redis_fqdn, redis_port)
    if not ok then
        -- redisに接続できない場合
        ngx.log(ngx.ERR, "failed to connect Redis: ", err)
        return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
    end
    return redis
end


-- redisからACLを取得
local function get_acl(request_uri)
    local redis = connect_redis("redis_app", 6379)
    local acl_hash, err = redis:hgetall("ACL|" .. request_uri)
    -- acl_hashが空
    if not acl_hash or #acl_hash == 0 then
        ngx.log(ngx.ERR, "acl_hash is empty")
        return ngx.exit(ngx.HTTP_NOT_FOUND)
    end
    if err then
        ngx.log(ngx.ERR, "failed to get ACL: ", err)
        return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
    end

    local acl = redis:array_to_hash(acl_hash)
    redis:close()
    return acl
end


-- 認証タイプに応じた認証インスタンスを生成
local function createAuthMap(authType)
    if authType == "basic" then
        return basic_auth
    elseif authType == "digest" then
        return digest_auth
    elseif authType == "form" then
        return form_auth
    else
        error("Invalid authentication type: " .. authType)
    end
end


-- NOTE: 簡易的なURLの正規化をしてredisのキーとして利用している
local request_uri = ngx.var.request_uri:gsub("/", "")
-- /にアクセスした場合にはindex.htmlを返す。
if request_uri == "" then
    ngx.var.pass = "http://" .. ngx.var.hostname .. "/index.html"
    return
end

local acl = get_acl(request_uri)
-- proxy_passを更新して転送先のURLを設定
ngx.var.pass = acl.proxy_pass .. "/" -- NOTE: 末尾に/をつけないと$request_urlの値が末尾につくため，404エラーになる

local auth_instance = createAuthMap(acl["authentication_type"])
auth_instance.auth()

ngx.log(ngx.INFO, "PROXY_PASS: ", ngx.var.pass, ", REQUEST_URI: ",
        ngx.var.request_uri, ", AUTH_TYPE: ", acl["authentication_type"]);

