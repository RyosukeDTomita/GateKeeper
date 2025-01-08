local _M = {}
local resty_redis = require "resty.redis"
local redis = resty_redis:new()
local resty_md5 = require "resty.md5"
local str = require "resty.string"
local resty_random = require "resty.random"
-- NOTE: attempt to call global 'create_nonce' (a nil value)が出ることがあるので先に宣言しておく
local create_nonce
local md5_hash
local create_www_authenticate
local connect_redis


-- nonceを生成する関数
local function create_nonce()
    -- NOTE: ETagの代わりに乱数を使う
    local random_bytes = resty_random.bytes
    local nonce = ngx.encode_base64(ngx.time() .. ":" .. random_bytes(3) .. ":" .. ngx.var.secret_data)
    return nonce
end


local function create_www_authenticate()
    local nonce = create_nonce()
    return 'Digest realm="' .. ngx.var.host .. '/digest Restricted", qop="auth", nonce="' .. nonce .. ', algorithm=MD5"'
end


-- Authorizationヘッダが空の時にDigest認証のポップアップを出す。
local function is_authorization_header()
    if not ngx.var.http_authorization then
        local nonce = create_nonce()
        ngx.header["WWW-Authenticate"] = create_www_authenticate()
        ngx.log(ngx.INFO, "WWW-Authenticate: ", ngx.header["WWW-Authenticate"])
        ngx.exit(ngx.HTTP_UNAUTHORIZED)
    end
end


-- redisに接続する。compose.yamlのサービス名で名前解決できる
local function connect_redis(redis_fqdn, redis_port)
    local ok, err = redis:connect(redis_fqdn, redis_port)
    if not ok then
        -- redisに接続できない場合
        ngx.log(ngx.ERR, "failed to connect Redis: ", err)
        return ngx.exit(500)
    end
    return redis
end


-- Authorizationヘッダをパースしてユーザ名、パスワードのハッシュ、nonceを取得
local function parse_authorization_header()
    local authorization = ngx.var.http_authorization
    local auth_params = {}
    -- NOTE: qop, ncの値が""で囲まれていないので，後から取得する
    for k, v in string.gmatch(authorization, '(%w+)="([^"]+)"') do
        auth_params[k] = v
    end
    
    local username = auth_params.username
    local realm = auth_params.realm
    local nonce = auth_params.nonce
    local uri = auth_params.uri
    local response = auth_params.response
    local qop = authorization:match('qop=([^,]+)')
    local nc = authorization:match('nc=([^,]+)')
    local cnonce = auth_params.cnonce
    --ngx.log(ngx.INFO, "Parsed Authorization - username: ", username, ", realm: ", realm, ", nonce: ", nonce, ", uri: ", uri, ", response: ", response, ", qop: ", qop, ", nc: ", nc, ", cnonce: ", cnonce)
    return username, realm, nonce, uri, response, qop, nc, cnonce
end


-- redisからユーザIDに対応するパスワードを取得する。
local function get_password_hash(user_id)
    local redis = connect_redis("redis_app", 6379)

    local password, err = redis:get("USER|" .. user_id)
    if not password then
        ngx.log(ngx.ERR, "failed to get password: ", err)
        return nil
    end
    -- NOTE: 存在しないユーザの際にuserdata型が返ってしまい，500エラーが発生し，ユーザの推測ができてしまうので，nilを返す
    if type(password) == "userdata" then
        return nil
    end
    return password
end


-- MD5ハッシュを計算する関数
local function md5_hash(data)
    local md5 = resty_md5:new()
    md5:update(data)
    return str.to_hex(md5:final())
end


function _M.auth()
    is_authorization_header()

    local username, realm, nonce, uri, response, qop, nc, cnonce = parse_authorization_header()
    ngx.log(ngx.INFO, "TRYING TO LOGIN: ", username)

    local password = get_password_hash(username)
    if not password then
        ngx.log(ngx.INFO, "NOT FOUND: ", username)
        local nonce = create_nonce()
        ngx.header["WWW-Authenticate"] = create_www_authenticate()
        ngx.exit(ngx.HTTP_UNAUTHORIZED)
    end

    -- HA1 = MD5(username:realm:password)
    local ha1 = md5_hash(username .. ":" .. realm .. ":" .. password)
    -- HA2 = MD5(method:digestURI)
    local ha2 = md5_hash(ngx.req.get_method() .. ":" .. uri)
    -- response = MD5(HA1:nonce:nc:cnonce:qop:HA2)
    local expected_response = md5_hash(ha1 .. ":" .. nonce .. ":" .. nc .. ":" .. cnonce .. ":" .. qop .. ":" .. ha2)

    if response == expected_response then
        ngx.log(ngx.INFO, "LOGIN SUCCESS: ", username)
        return --NOTE: ngx.exit(ngx.HTTP_OK)を返すと，後続のコンテンツが表示されない
    else
        --認証失敗時には再度Digest認証のポップアップを出す
        ngx.log(ngx.INFO, "LOGIN FAILED: ", username)
        local nonce = create_nonce()
        ngx.header["WWW-Authenticate"] = create_www_authenticate()
        ngx.exit(ngx.HTTP_UNAUTHORIZED)
    end
end
return _M
