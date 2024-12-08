--local basic_auth = require "basic_auth"

-- nginx.confのupstreamブロックを指定してload balance
local transfer_ip = "proxied_server"
-- proxy_passにupstreamを指定する場合は，Host headerの上書きが必要
ngx.var.host_header = "abehiroshi.la.coocan.jp"
-- local transfer_ip = "abehiroshi.la.coocan.jp"
-- local transfer_ip = "example.com"
local transfer_path = "/"

ngx.var.pass = "http://" .. transfer_ip .. transfer_path

-- basic_auth.basic_auth()

ngx.log(ngx.INFO, "request_url: ", ngx.var.pass);
