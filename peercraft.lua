local json = require "json"
local class = require "class"
local PEER_LOBBY = "http://beastcraft.codingbutter.com:8888/"
local WS_SERVER = "ws://beastcraft.codingbutter.com:3028"
local P2P = class({
    dispatch = {
        connected = function()
        end
    },
    constructor = function(self, computerusername)
        self.username = computerusername or os.getComputerID()
        self.peers = {}
        self.ws, self.err = http.websocket(WS_SERVER)
        if self.ws then
            self.connected = true
        end
    end,
    attachEventLoop = function(self, eventLoop)
        parallel.waitForAll(function()
            while self.connected do
                local msg = self.ws.receive()
                self:parseMessage(msg)
            end
        end, function()
            local timeId = os.startTimer(60)
            while self.connected == true do
                local timer = os.pullEvent("timer")
                if timer[2] == timeId and self.id and self.lobby and self.room then
                    self:joinRoom()
                    timeId = os.startTimer(60)
                end
            end
        end, eventLoop)
    end,
    captureRecieved = function(self)

    end,
    parseMessage = function(self, msg)
        local event = json.decode(msg)
        local eventMsg = event.event
        local payload = event.payload
        if eventMsg == "peerId" then
            self.id = payload
            self:joinRoom()
            self:send("peer_added", {
                message = "Hello"
            }, self.peers)
            self.dispatch["connected"]()
        else
            if eventMsg == "peer_added" then
                self:joinRoom()
            end
            local peer = event.peer
            if self.dispatch[eventMsg] then
                self.dispatch[eventMsg](payload, peer)
            end
        end
    end,
    send = function(self, event, payload, peerIds)
        local peers = peerIds or self.peers
        if type(peers) ~= "table" then
            peers = {peerIds}
        end
        self.ws.send(json.encode({
            event = event,
            peer = {
                peerid = self.id,
                username = self.username
            },
            payload = payload,
            peers = peers
        }))
    end,
    on = function(self, eventusername, func)
        self.dispatch[eventusername] = func
    end,
    getPeers = function(self)
        return self.peers
    end,
    getRooms = function(lobby)
        local request = http.get(PEER_LOBBY .. lobby)
        return json.decode(request.readAll())
    end,
    joinRoom = function(self)
        local requestUrl = PEER_LOBBY .. self.lobby .. "/" .. self.room .. "/" .. self.id .. "/" .. self.username
        if password then
            requestUrl = requestUrl .. "?password=" .. password
        end
        local response = json.decode(http.get(requestUrl).readAll())

        self.peers = response.error and {} or response

    end,
    connect = function(self, lobby, room, password)
        self.lobby = lobby
        self.room = room
        self.password = password
        self:send("connect", {
            username = self.username
        })

    end,
    close = function(self)
        self.connected = false
        self.ws.close()
    end
})
return P2P
