--!nocheck

local ClientProcess = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Util = script.Parent.Parent.Util

local ReliableEvent = require(script.Parent.Parent.Event)
local Spawn = require(ReplicatedStorage.Modules.Packages.Spawn)
local Buffer = require(Util.Buffer)

local clientQueue = {}
local clientCallback = {}
local registeredIdentifier = {}
local queueIn = {}

function ClientProcess.insertQueue(Identifier: string, ...: any)
	if not clientQueue[Identifier] then clientQueue[Identifier] = {} end

	table.insert(clientQueue[Identifier], { ... })
end

function ClientProcess.add(Identifier: any)
	if not table.find(registeredIdentifier, Identifier) then
		table.insert(registeredIdentifier, Identifier)

		if not clientQueue[Identifier] then clientQueue[Identifier] = {} end
		if not clientCallback[Identifier] then clientCallback[Identifier] = {} end
		if not queueIn[Identifier] then queueIn[Identifier] = {} end
	end
end

function ClientProcess.addCallback(Identifier: string, key: string, callback)
	clientCallback[Identifier][key] = callback
end

function ClientProcess.removeCallback(Identifier: string, key: string)
	clientCallback[Identifier][key] = nil
end

function ClientProcess.start()
	debug.setmemorycategory("Warp")
	local clock_limit = 1/60
	local past_clock = os.clock()

	RunService.PostSimulation:Connect(function()
		if (os.clock()-past_clock) >= (clock_limit - 0.006) then -- less potential to skip frames
			past_clock = os.clock()

			-- Reliable
			for Identifier: string, data: any in clientQueue do
				if #data > 0 then
					ReliableEvent:FireServer(Buffer.revert(Identifier), data)

					clientQueue[Identifier] = nil
				end
			end
		end

		for _, Identifier: string in registeredIdentifier do
			-- Unreliable & Reliable
			local callback = clientCallback[Identifier] or nil
			if not callback then continue end

			if queueIn[Identifier] then
				for _, packedDatas: any in queueIn[Identifier] do
					if #packedDatas == 0 then continue end
					for _, fn: any in callback do
						for i=1,#packedDatas do
							Spawn(fn, table.unpack(packedDatas[i] or {}))
						end
					end
				end
				queueIn[Identifier] = nil
			end
		end
	end)

	local function onClientNetworkReceive(Identifier: any, data: any)
		if not Identifier or not data then return end
		Identifier = Buffer.convert(Identifier)

		if not queueIn[Identifier] then queueIn[Identifier] = {} end

		table.insert(queueIn[Identifier], data)
	end
	ReliableEvent.OnClientEvent:Connect(onClientNetworkReceive)
end

return ClientProcess
