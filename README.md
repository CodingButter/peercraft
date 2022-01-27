# P2P
## Extend Your Reach
P2P is a library that harneses the power of websockets to connect your application to CC computers everywhere. Not just on your server. 

## Features

- Create your own lobby 
- Create Rooms
- Connect to peers
- Send and receive data through events
- Send data to every peer or just one.

## Installation


```sh
git clone https://github.com/CodingButter/peercraft.git
```
```lua
pastebin get smA8CZbF peercraft.lua --For un-minified version
pastebin get YsgPsjJR peercraft.lua --For minified version
```


## Usage
```lua
local PeerCraft = require "peercraft" -- require peercraft
local p2p = PeerCraft:new("Evil CodingButter") -- create a new instance passing an optional username defaults to the computer label
local eventLoop = function() -- create a work loop but do not run it yet
    while true do
        local event = table.pack(os.pullEventRaw("mouse_click"))
        p2p:send(event[1], {event[3], event[4]}) -- Sending data just requires a event for the other computers to listen for and a payload to send them
    end
end

for k, v in pairs(p2p.getRooms("alobby")) do -- to get all the rooms just pass in the lobby name 
    print(v.room .. " (" .. v.users .. ")") -- get rooms returns an array of rooms with room>roomname users>number of current peers in the room and public> a boolean whether a password is required
end
-- p2p:on requires an event to listen on and a function for all but the connect event you will receive a payload and the peer information of who sent the event
p2p:on("connected", function()
    print("connected")
end)
p2p:on("peer_added", function(payload, peer)
    print(peer.username .. " joined")
end)

p2p:on("mouse_click", function(payload, peer)
    print(peer.username .. " clicked at position:" .. payload[1] .. "," .. payload[2])
end)

p2p:connect("alobby", "aroom"--[[,optional password]]) --  if the room doesn't exist this command will create it and add you to the peer list of that room
p2p:attachEventLoop(eventLoop) -- Once you've connected you can attach your event loop and start handling your logic how you please
```

