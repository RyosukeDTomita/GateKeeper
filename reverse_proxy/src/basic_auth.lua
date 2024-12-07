local resty_redis = require "resty.redis"
local redis = resty_redis:new()

function _M.basic_auth()
    -- redisに接続 compose.yamlのサービス名で名前解決できる
    local ok, err = redis:connect("redis_app", 6379)
    if not ok then
        ngx.log(ngx.ERR, "failed to connect Redis: ", err)
        return ngx.exit(500)
    end

    -- redisから環境変数を取得
    local env = redis:get("ENV")
    if err or env == ngx.null then
        ngx.log(ngx.ERR, "failed to get ENV: ", err)
        return ngx.exit(500)
    end

    ngx.log(INFO, "ENV: ", env)
end