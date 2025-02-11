describe("auth_factory.lua get_auth_instance", function()
    -- NOTE: ngxのモックが必要だったので雑に作成。ngxをモックする公式のライブラリはなさそう
    _G.ngx = {
        var = {},
        log = function() end,
        ERR = "ERR",
        INFO = "INFO",
        HTTP_INTERNAL_SERVER_ERROR = 500,
        exit = function() end,
        re = {match = function() return nil end},
        location = {},
        config = {prefix = function()
            return "/usr/local/openresty/nginx/"
        end},
        get_phase = function() return "init" end,
        socket = {
            tcp = function()
                return {
                    settimeout = function() end,
                    connect = function() return true end,
                    setkeepalive = function() end,
                    close = function() end,
                    send = function() return true end,
                    receive = function() return nil end
                }
            end
        }
    }

    local auth_factory = require "auth_factory"

    it("should return basic auth instance", function()
        local auth_instance = auth_factory.get_auth_instance("basic")
        assert.is.equal(auth_instance, require "basic_auth")
    end)

    it("should return digest auth instance", function()
        local auth_instance = auth_factory.get_auth_instance("digest")
        assert.is.equal(auth_instance, require "digest_auth")
    end)

    it("should return form auth instance", function()
        local auth_instance = auth_factory.get_auth_instance("form")
        assert.is.equal(auth_instance, require "form_auth")
    end)

    it("should throw error for invalid auth type", function()
        assert.has_error(function()
            auth_factory.get_auth_instance("invalid")
        end, "Invalid authentication type: invalid")
    end)
end)
