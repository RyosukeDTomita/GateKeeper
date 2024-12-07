local basic_auth = require "basic_auth"

-- nginx.confのupstreamブロックを指定してload balance
local transfer_ip = "proxied_server"
local transfer_path = "/"

ngx.log(ngx.ERR, "hello, world")
-- basic_auth.basic_auth()

-- リクエストを転送する先を設定
ngx.var.pass = "https://" .. transfer_ip .. transfer_path

-- log
ngx.log(ngx.INFO, "request_url: ", transfer_ip .. ":" .. transfer_port .. transfer_path)
