-- backend_appはcompose.yamlのサービス名であり，これを使って名前解決できる。
local transfer_ip = "backend_app"
local transfer_port = 8000
local transfer_path = "/"

-- リクエストを転送する先を設定
ngx.ctx.ip = transfer_ip
ngx.ctx.port = transfer_port
ngx.var.pass = "http://" .. transfer_ip .. ":" .. transfer_port .. transfer_path

-- log
ngx.log(ngx.INFO, "request_url: ", url)
print("request_url: ", url)
-- nginxのリクエストヘッダにcookieを設定
ngx.req.set_header("Cookie", "my_cookie=set_header")


