local P2P = require "P2P"
local p2p = P2P:new()

p2p:on("peer_added", function(payload, peer)
    print(peer.username .. " joined")
end)

p2p:on("mouse_click", function(payload, peer)
    print(peer.username .. " clicked at position:" .. payload[1] .. "," .. payload[2])
end)

local eventLoop = function()
    while true do
        local event = table.pack(os.pullEventRaw("mouse_click"))
        p2p:send(event[1], {event[3], event[4]})
    end
end

p2p:connect({
    eventLoop = eventLoop,
    lobby = "alobby",
    room = "aroom"
})

