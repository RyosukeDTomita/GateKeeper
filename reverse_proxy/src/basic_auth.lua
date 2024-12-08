local _M = {}
local resty_redis = require "resty.redis"
local redis = resty_redis:new()

function _M.basic_auth()
    -- リクエストヘッダからBasic認証情報を取得
    local auth_header = ngx.var.http_Authorization
    if not auth_header then
        ngx.header["WWW-Authenticate"] = 'Basic realm="Please enter your ID and password."'
        ngx.exit(ngx.HTTP_UNAUTHORIZED)
    end
    -- redisに接続 compose.yamlのサービス名で名前解決できる
    local ok, err = redis:connect("redis_app", 6379)
    if not ok then
        ngx.log(ngx.ERR, "failed to connect Redis: ", err)
        return ngx.exit(500)
    end

end