local skynet = require "skynet"
local mc = require "skynet.multicast"
local st = require "skynet.sharetable"

local shared
local channel

local M

local function init()
    assert(not shared)
    assert(not channel)
    shared = skynet.uniqueservice "shared"
    local name = skynet.call(shared, "lua", "channel")
    channel = mc.new {
        channel = name,
        dispatch = function (_, _, filenames)
            for _, filename in pairs(filenames) do
                if M[filename] then
                    M[filename] = nil
                end
            end
        end
    }
end


M = setmetatable({}, {__index = function(self, filename)
    if not shared then
        init()
    end

    local obj = st.query(filename)
    if obj then
        self[filename] = obj
    end
    return obj
end})

return M