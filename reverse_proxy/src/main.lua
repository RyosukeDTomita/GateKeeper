local resty_redis = require "resty.redis"
local redis = resty_redis:new()
local basic_auth = require "basic_auth"
local digest_auth = require "digest_auth"

-- redisからACLを取得して認証方式を選択する
local function get_acl(request_uri)
    -- redisに接続。 compose.yamlのサービス名で名前解決できる
    local ok, err = redis:connect("redis_app", 6379)
    if not ok then
        -- redisに接続できない場合
        ngx.log(ngx.ERR, "failed to connect Redis: ", err)
        return ngx.exit(500)
    end
    local acl_hash, err = redis:hgetall("ACL|" .. request_uri)
    -- acl_hashが{}の場合は404を返す
    if not next(acl_hash) then
        ngx.log(ngx.INFO, "acl_hash is empty")
        return ngx.exit(404)
    end
    -- TODL: ディレクトリの存在が露呈しないように修正
    if err then
        ngx.log(ngx.ERR, "failed to get ACL: ", err)
        return ngx.exit(500)
    end

    local acl = redis:array_to_hash(acl_hash)
    redis:close()
    return acl
end


-- NOTE: 簡易的なURLの正規化をしてredisのキーとして利用する
local request_uri = ngx.var.request_uri:gsub("/", "")

-- /にアクセスした場合にはindex.htmlを返す。
if request_uri == "" then
    ngx.var.pass = "http://" .. ngx.var.hostname .. "/index.html"
    return
end

-- redisのaclから転送先のurlを取得する
local acl = get_acl(request_uri)
ngx.var.pass = acl.proxy_pass .. "/" -- NOTE: 末尾に/をつけないと$request_urlの値が末尾につくため，404エラーになる

-- localhost/basicにアクセスした場合
if acl["authentication_type"] == "basic" then
    basic_auth.auth()
-- localhost/digestにアクセスした場合
elseif acl["authentication_type"] == "digest" then
    digest_auth.auth()
end

ngx.log(ngx.INFO, "PROXY_PASS: ", ngx.var.pass, ", REQUEST_URI: ",
        ngx.var.request_uri, ", AUTH_TYPE: ", acl["authentication_type"]);
