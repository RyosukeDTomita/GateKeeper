local basic_auth = require "basic_auth"

-- proxy_passを動的に設定する
local transfer_host = "https://example.com"
-- local transfer_host = "http://abehiroshi.la.coocan.jp"
local transfer_path = "/"
ngx.var.pass = transfer_host .. transfer_path

basic_auth.auth()

ngx.log(ngx.INFO, "PROXY_PASS: ", ngx.var.pass);
