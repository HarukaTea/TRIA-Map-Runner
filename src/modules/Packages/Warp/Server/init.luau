--!nocheck

local Server = {}
Server.__index = Server

local Players = game:GetService("Players")
local Util = script.Parent.Util

local ServerProcess = require(script.ServerProcess)
local Key = require(Util.Key)
local Serdes = require(Util.Serdes)
local Buffer = require(Util.Buffer)

function Server.new(Identifier: string, conf: table?)
	local self = setmetatable({}, Server)

	self._buffer = Buffer.new()
	self._buffer:wu8(Serdes(Identifier))
	self.id = Buffer.convert(self._buffer:build())
	self.fn = {}
	self._conf = table.freeze(conf or {})
	self.IsConnected = false

	ServerProcess.add(self.id)
	self._buffer:remove()

	return self
end

function Server:Fire(player: Player, ...: any)
	ServerProcess.insertQueue(self.id, player, ...)
end

function Server:FireAll(...: any)
	for _, player: Player in ipairs(Players:GetPlayers()) do
		if player then ServerProcess.insertQueue(self.id, player, ...) end
	end
end

function Server:FireAllExpect(plrs: { Player }, ...: any)
	for _, player: Player in ipairs(Players:GetPlayers()) do
		if table.find(plrs, player) then continue end

		if player then ServerProcess.insertQueue(self.id, player, ...) end
	end
end

function Server:FireAllInRange(range: number, from: Vector3, data: { any }, except: { Player }?)
	for _, player: Player in ipairs(Players:GetPlayers()) do
		if (except and table.find(except, player)) or not player.Character or not player.Character.PrimaryPart or (player.Character.PrimaryPart.Position - from).Magnitude < range then continue end

		if player then ServerProcess.insertQueue(self.id, player, table.unpack(data)) end
	end
end


function Server:Connect(callback: (plyer: Player, args: any) -> ()): string
	local key = tostring(Key())
	table.insert(self.fn, key)
	ServerProcess.addCallback(self.id, key, callback)
	self.IsConnected = #self.fn > 0
	return key
end


function Server:DisconnectAll()
	for _, key: string in self.fn do
		self:Disconnect(key)
	end
end

function Server:Disconnect(key: string): boolean
	ServerProcess.removeCallback(self.id, key)

	table.remove(self.fn, table.find(self.fn, key))
	self.IsConnected = #self.fn > 0

	return table.find(self.fn, key) == nil
end

return Server.new