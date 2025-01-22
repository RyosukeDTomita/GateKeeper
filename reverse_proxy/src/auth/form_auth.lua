local _M = {}
local resty_redis = require "resty.redis"
local redis = resty_redis:new()
local template = require "resty.template"
local resty_random = require "resty.random"
local SESSION_EXPIRATION_SECONDS = 3600


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


-- FormからユーザIDとパスワードを取得
local function get_login_info()
    ngx.req.read_body()
    local args = ngx.req.get_post_args()
    return args["user_id"], args["password"]
end


-- form_auth_cookieを生成してset_cookieする
local function set_form_auth_cookie(user_id)
    local random_bytes = resty_random.bytes(10)
    local encoded_random_bytes = ngx.encode_base64(random_bytes)
    local new_cookie = user_id .. encoded_random_bytes .. ngx.time()
    ngx.header["Set-Cookie"] = "form_auth_cookie=" .. new_cookie .. "; Path=/form; Max-Age=" .. SESSION_EXPIRATION_SECONDS .. "; HttpOnly=true"
    ngx.log(ngx.INFO, "Set-Cookie: ", new_cookie)
    return new_cookie
end


-- form_auth_cookieをredisに保存する
local function save_form_cookie(user_id, new_cookie)
    local redis = connect_redis("redis_app", 6379)
    local ok, err = redis:set("SESSION|" .. user_id, new_cookie)
    if not ok then
        -- redisにcookieを保存できない場合
        ngx.log(ngx.ERR, "failed to save cookie: ", err)
        return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
    end
    local ok, err = redis:expire("SESSION|" .. user_id, SESSION_EXPIRATION_SECONDS)
    if not ok then
        -- redisにcookieの有効期限を設定できない場合
        ngx.log(ngx.ERR, "failed to set expiration: ", err)
        return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
    end
    redis:close()
end


-- redisに保存済みのcookieを取得
local function get_saved_cookie(user_id)
    local redis = connect_redis("redis_app", 6379)
    local cookie, err = redis:get("SESSION|" .. user_id)
    if not cookie then
        -- redisからcookieが取得できない場合
        ngx.log(ngx.ERR, "failed to get cookie: ", err)
        return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
    end
    redis:close()
    return cookie
end


-- redisからユーザのパスワードを取得
local function get_user_password(user_id)
    local redis = connect_redis("redis_app", 6379)

    -- TODO: pwをハッシュにするとかしたい
    local password, err = redis:get("USER|" .. user_id)
    if not password then
        -- redisからユーザのパスワードが取得できない場合
        ngx.log(ngx.ERR, "failed to get", user_id "password: ", err)
        return nil
    end
    -- NOTE: 存在しないユーザの際にuserdata型が返ってしまい，500エラーが発生し，ユーザの推測ができてしまうので，nilを返す
    if type(password) == "userdata" then
        return nil
    end
    redis:close()
    return password
end


function _M.auth()
    -- リクエストがPOSTでない場合はログインページを表示
    if ngx.req.get_method() ~= "POST" then
        template.render("form_auth.html", {error = ""})
        return
    end

    local user_id, password = get_login_info()
    local form_cookie = ngx.var.cookie_form_auth_cookie -- NOTE: ngx.var.cookie_XXXでXXXのcookieを取得

    -- 既に払い出されたsession cookieがある場合は認証を通す
    ngx.log(ngx.INFO, "save_cookie: ", form_cookie)
    if form_cookie then
        local saved_cookie = get_saved_cookie(user_id)
        if form_cookie == saved_cookie then
            ngx.log(ngx.INFO, "SESSION COOKIE IS VALID: ", user_id)
            return
        end
    end

    ngx.log(ngx.INFO, "TRYING TO LOGIN: ", user_id)
    local saved_password = get_user_password(user_id)

    if password == saved_password then
        ngx.log(ngx.INFO, "LOGIN SUCCESS: ", user_id)
        local new_form_cookie = set_form_auth_cookie(user_id)
        save_form_cookie(user_id, new_form_cookie)
        return --NOTE: ngx.exit(ngx.HTTP_OK)を返すと，後続のコンテンツが表示されない
    else
        ngx.log(ngx.INFO, "LOGIN FAILED: ", user_id)
        template.render("form_auth.html", {error = "Failed to login"})
    end

end
return _M