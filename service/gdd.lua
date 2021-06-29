local skynet = require "skynet"
local st = require "skynet.sharetable"
local mc = require "skynet.multicast"

local channel

local CMD = {}

function CMD.query(filename)
    assert(channel)
    return st.query(filename)
end

function CMD.loadfiles(filenames)
    assert(type(filenames) == "table")
    for _, filename in pairs(filenames) do
        st.loadfile(filename)
    end
    channel:publish(filenames)
end

function CMD.channel()
    return channel.channel
end

skynet.start(function()
    channel = mc.new()
    skynet.dispatch("lua", function(_,_, cmd, ...)
        local f = CMD[cmd]
        assert(f, cmd)
        skynet.retpack(f(...))
    end)
end)

