--!nocheck

local ServerProcess = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Util = script.Parent.Parent.Util

local ReliableEvent = require(script.Parent.Parent.Event)
local Spawn = require(ReplicatedStorage.Modules.Packages.Spawn)
local Buffer = require(Util.Buffer)

local serverQueue = {}
local serverCallback = {}
local registeredIdentifier = {}

local queueOut = {}
local queueIn = {}

local function initializeEachPlayer(player: Player)
	if not player then return end
	if not queueOut[player] then queueOut[player] = {} end

	for _, Identifier: string in registeredIdentifier do
		if not player then break end

		if not queueOut[player][Identifier] then queueOut[player][Identifier] = {} end
		if not queueIn[Identifier][player] then queueIn[Identifier][player] = {} end
	end
end

Players.PlayerAdded:Connect(initializeEachPlayer)

function ServerProcess.insertQueue(Identifier: string, player: Player, ...: any)
	if not serverQueue[Identifier] then serverQueue[Identifier] = {} end
	if not serverQueue[Identifier][player] then serverQueue[Identifier][player] = {} end

	table.insert(serverQueue[Identifier][player], { ... })
end

function ServerProcess.add(Identifier: string)
	if not table.find(registeredIdentifier, Identifier) then
		table.insert(registeredIdentifier, Identifier)

		if not serverQueue[Identifier] then serverQueue[Identifier] = {} end
		if not serverCallback[Identifier] then serverCallback[Identifier] = {} end
		if not queueIn[Identifier] then queueIn[Identifier] = {} end

		for _, player: Player in ipairs(Players:GetPlayers()) do
			Spawn(initializeEachPlayer, player)
		end
	end
end

function ServerProcess.addCallback(Identifier: string, key: string, callback)
	serverCallback[Identifier][key] = callback
end

function ServerProcess.removeCallback(Identifier: string, key: string)
	serverCallback[Identifier][key] = nil
end

function ServerProcess.start()
	debug.setmemorycategory("Warp")
	local clock_limit = 1/60
	local past_clock = os.clock()

	RunService.PostSimulation:Connect(function()
		if (os.clock()-past_clock) >= (clock_limit - 0.006) then -- less potential to skip frames
			past_clock = os.clock()

			-- Reliable
			for Identifier: string, contents: { [Player]: { any } } in serverQueue do
				for player, content: any in contents do
					if #content > 0 and queueOut[player] then
						ReliableEvent:FireClient(player, Buffer.revert(Identifier), content)
					end
					serverQueue[Identifier][player] = nil
				end
				serverQueue[Identifier] = nil
			end
		end

		for _, Identifier: string in registeredIdentifier do
			local callback = serverCallback[Identifier] or nil
			if not callback then continue end

			-- Unreliable & Reliable
			for player, content in queueIn[Identifier] do
				if not callback then break end
				for _, incoming in content do
					if not callback then break end
					if #incoming == 0 then continue end
					for _, fn: any in callback do
						for i=1,#incoming do
							Spawn(fn, player, table.unpack(incoming[i] or {}))
						end
					end
				end
				queueIn[Identifier][player] = nil
			end
		end
	end)

	local function onServerNetworkReceive(player: Player, Identifier: any, data: any)
		if not Identifier or not data then return end
		Identifier = Buffer.convert(Identifier)

		if not serverQueue[Identifier] then serverQueue[Identifier] = {} end
		if not serverQueue[Identifier][player] then serverQueue[Identifier][player] = {} end
		if not queueIn[Identifier][player] then queueIn[Identifier][player] = {} end

		table.insert(queueIn[Identifier][player], data)
	end
	ReliableEvent.OnServerEvent:Connect(onServerNetworkReceive)
end

for _, player: Player in ipairs(Players:GetPlayers()) do
	Spawn(initializeEachPlayer, player)
end

return ServerProcess
