local _M = {}
local resty_redis = require "resty.redis"
local redis = resty_redis:new()


-- WWW-Authenticateヘッダを返すhelper関数
local function send_www_authorization_header()
    -- Basic認証のポップアップを出す。
    ngx.header["WWW-Authenticate"] = 'Basic realm="' .. ngx.var.host .. '/basic Restricted"'
    ngx.exit(ngx.HTTP_UNAUTHORIZED)
end


-- Authorizationヘッダからuseridとpasswordを取得
local function decode_userid_and_password()
    local authorization = ngx.var.http_Authorization
    local base64_decode = ngx.decode_base64(string.sub(authorization, 7)) -- " Basic "を削除してbase64デコード
    local userid, password = base64_decode:match("([^:]+):([^:]+)")
    return userid, password
end


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


-- redisからユーザのパスワードを取得
local function get_user_password(user_id)
    local redis = connect_redis("redis_app", 6379)

    -- TODO: pwをハッシュにするとかしたい
    local password, err = redis:get("USER|" .. user_id)
    if not password then
        -- redisからユーザのパスワードが取得できない場合
        ngx.log(ngx.ERR, "failed to get", user_id "password: ", err)
        return
    end
    redis:close()
    return password
end


function _M.auth()
    if not ngx.var.http_Authorization then
        send_www_authorization_header()
    end

    local user_id, password = decode_userid_and_password()
    ngx.log(ngx.INFO, "TRYING TO LOGIN: ", user_id)
    local saved_password = get_user_password(user_id)

    if password == saved_password then
        ngx.log(ngx.INFO, "LOGIN SUCCESS: ", user_id)
        return --NOTE: ngx.exit(ngx.HTTP_OK)を返すと，後続のコンテンツが表示されない
    else
        send_www_authorization_header()
        ngx.log(ngx.INFO, "LOGIN FAILED: ", user_id)
    end
end
return _M
