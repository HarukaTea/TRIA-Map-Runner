--!nocheck

local Client = {}
Client.__index = Client

local Util = script.Parent.Util

local ClientProcess = require(script.ClientProcess)
local Key = require(Util.Key)
local Serdes = require(Util.Serdes)
local Buffer = require(Util.Buffer)

function Client.new(Identifier: string, conf: table)
	local self = setmetatable({}, Client)

	self._buffer = Buffer.new()
	self._buffer:wu8(Serdes(Identifier, conf and conf.yieldWait))
	self.id = Buffer.convert(self._buffer:build())
	self.fn = {}
	self._conf = table.freeze(conf or {})
	self.IsConnected = false

	ClientProcess.add(self.id)
	self._buffer:remove()

	return self
end

function Client:Fire(...: any)
	ClientProcess.insertQueue(self.id, ...)
end

function Client:Connect(callback: (args: any) -> ()): string
	local key = tostring(Key())

	table.insert(self.fn, key)
	self.IsConnected = #self.fn > 0

	ClientProcess.addCallback(self.id, key, callback)

	return key
end

function Client:DisconnectAll()
	for _, key: string in self.fn do
		self:Disconnect(key)
	end
end

function Client:Disconnect(key: string): boolean
	ClientProcess.removeCallback(self.id, key)

	table.remove(self.fn, table.find(self.fn, key))
	self.IsConnected = #self.fn > 0

	return table.find(self.fn, key) == nil
end

Client.Destroy = Client.DisconnectAll

return Client.new
