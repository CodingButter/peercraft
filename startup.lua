local PeerCraft = require "peercraft"
local p2p = PeerCraft:new("CodingButter")
p2p:on("connected", function()
    print("connected")
end)
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

for k, v in pairs(p2p.getRooms("alobby")) do
    print(v.room .. " (" .. v.users .. ")")
end

p2p:connect("alobby", "aroom")
p2p:attachEventLoop(eventLoop)

