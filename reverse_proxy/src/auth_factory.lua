local _M = {}
local basic_auth = require "basic_auth"
local digest_auth = require "digest_auth"
local form_auth = require "form_auth"

local _M = {}

function _M.get_auth_instance(auth_type)
    if auth_type == "basic" then
        return require "basic_auth"
    elseif auth_type == "digest" then
        return require "digest_auth"
    elseif auth_type == "form" then
        return require "form_auth"
    else
        error("Invalid authentication type: " .. auth_type)
    end
end

return _M
