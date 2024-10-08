--!native
--!optimize 2
--!nocheck
--!nolint
--#selene: allow(unused_variable, incorrect_standard_library_use, global_usage)
-- Server generated by Zap v0.6.14 (https://github.com/red-blox/zap)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local outgoing_buff: buffer
local outgoing_used: number
local outgoing_size: number
local outgoing_inst: { Instance }
local outgoing_apos: number

local incoming_buff: buffer
local incoming_read: number
local incoming_inst: { Instance }
local incoming_ipos: number

-- thanks to https://dom.rojo.space/binary.html#cframe
local CFrameSpecialCases = {
	CFrame.Angles(0, 0, 0),
	CFrame.Angles(math.rad(90), 0, 0),
	CFrame.Angles(0, math.rad(180), math.rad(180)),
	CFrame.Angles(math.rad(-90), 0, 0),
	CFrame.Angles(0, math.rad(180), math.rad(90)),
	CFrame.Angles(0, math.rad(90), math.rad(90)),
	CFrame.Angles(0, 0, math.rad(90)),
	CFrame.Angles(0, math.rad(-90), math.rad(90)),
	CFrame.Angles(math.rad(-90), math.rad(-90), 0),
	CFrame.Angles(0, math.rad(-90), 0),
	CFrame.Angles(math.rad(90), math.rad(-90), 0),
	CFrame.Angles(0, math.rad(90), math.rad(180)),
	CFrame.Angles(0, math.rad(-90), math.rad(180)),
	CFrame.Angles(0, math.rad(180), math.rad(0)),
	CFrame.Angles(math.rad(-90), math.rad(-180), math.rad(0)),
	CFrame.Angles(0, math.rad(0), math.rad(180)),
	CFrame.Angles(math.rad(90), math.rad(180), math.rad(0)),
	CFrame.Angles(0, math.rad(0), math.rad(-90)),
	CFrame.Angles(0, math.rad(-90), math.rad(-90)),
	CFrame.Angles(0, math.rad(-180), math.rad(-90)),
	CFrame.Angles(0, math.rad(90), math.rad(-90)),
	CFrame.Angles(math.rad(90), math.rad(90), 0),
	CFrame.Angles(0, math.rad(90), 0),
	CFrame.Angles(math.rad(-90), math.rad(90), 0),
}

local function alloc(len: number)
	if outgoing_used + len > outgoing_size then
		while outgoing_used + len > outgoing_size do
			outgoing_size = outgoing_size * 2
		end

		local new_buff = buffer.create(outgoing_size)
		buffer.copy(new_buff, 0, outgoing_buff, 0, outgoing_used)

		outgoing_buff = new_buff
	end

	outgoing_apos = outgoing_used
	outgoing_used = outgoing_used + len

	return outgoing_apos
end

local function read(len: number)
	local pos = incoming_read
	incoming_read = incoming_read + len

	return pos
end

local function save()
	return {
		buff = outgoing_buff,
		used = outgoing_used,
		size = outgoing_size,
		inst = outgoing_inst,
	}
end

local function load(data: {
	buff: buffer,
	used: number,
	size: number,
	inst: { Instance },
})
	outgoing_buff = data.buff
	outgoing_used = data.used
	outgoing_size = data.size
	outgoing_inst = data.inst
end

local function load_empty()
	outgoing_buff = buffer.create(64)
	outgoing_used = 0
	outgoing_size = 64
	outgoing_inst = {}
end

load_empty()

local types = {}
if not RunService:IsRunning() then
	local noop = function() end
	return table.freeze({
		SendEvents = noop,
		CreateHint = table.freeze({
			Fire = noop,
			FireAll = noop,
			FireExcept = noop,
			FireList = noop,
			FireSet = noop
		}),
		ChangeMusic = table.freeze({
			SetCallback = noop
		}),
		ChangeLighting = table.freeze({
			SetCallback = noop
		}),
	}) :: Events
end
local Players = game:GetService("Players")

if RunService:IsClient() then
	error("Cannot use the server module on the client!")
end

local remotes = ReplicatedStorage:FindFirstChild("ZAP")
if remotes == nil then
	remotes = Instance.new("Folder")
	remotes.Name = "ZAP"
	remotes.Parent = ReplicatedStorage
end

local reliable = remotes:FindFirstChild("HARUKA_RELIABLE")
if reliable == nil then
	reliable = Instance.new("RemoteEvent")
	reliable.Name = "HARUKA_RELIABLE"
	reliable.Parent = remotes
end

local unreliable = remotes:FindFirstChild("HARUKA_UNRELIABLE")
if unreliable == nil then
	unreliable = Instance.new("UnreliableRemoteEvent")
	unreliable.Name = "HARUKA_UNRELIABLE"
	unreliable.Parent = remotes
end

local player_map = {}

local function load_player(player: Player)
	if player_map[player] then
		load(player_map[player])
	else
		load_empty()
	end
end

Players.PlayerRemoving:Connect(function(player)
	player_map[player] = nil
end)

local function SendEvents()
	for player, outgoing in player_map do
		if outgoing.used > 0 then
			local buff = buffer.create(outgoing.used)
			buffer.copy(buff, 0, outgoing.buff, 0, outgoing.used)

			reliable:FireClient(player, buff, outgoing.inst)

			outgoing.buff = buffer.create(64)
			outgoing.used = 0
			outgoing.size = 64
			table.clear(outgoing.inst)
		end
	end
end

RunService.Heartbeat:Connect(SendEvents)

local events = table.create(3)
reliable.OnServerEvent:Connect(function(player, buff, inst)
	incoming_buff = buff
	incoming_inst = inst
	incoming_read = 0
	incoming_ipos = 0
	local len = buffer.len(buff)
	while incoming_read < len do
		local id = buffer.readu8(buff, read(1))
		if id == 2 then
			local value
			value = {}
			local len_1 = buffer.readu16(incoming_buff, read(2))
			value.MusicId = buffer.readstring(incoming_buff, read(len_1), len_1)
			if buffer.readu8(incoming_buff, read(1)) == 1 then
				local len_2 = buffer.readu16(incoming_buff, read(2))
				value.Volume = buffer.readstring(incoming_buff, read(len_2), len_2)
			else
				value.Volume = nil
			end
			if buffer.readu8(incoming_buff, read(1)) == 1 then
				local len_3 = buffer.readu16(incoming_buff, read(2))
				value.StartTick = buffer.readstring(incoming_buff, read(len_3), len_3)
			else
				value.StartTick = nil
			end
			if events[2] then
				task.spawn(events[2], player, value)
			end
		elseif id == 3 then
			local value
			value = {}
			if buffer.readu8(incoming_buff, read(1)) == 1 then
				incoming_ipos = incoming_ipos + 1
				value.Properties = incoming_inst[incoming_ipos]
			else
				value.Properties = nil
			end
			if buffer.readu8(incoming_buff, read(1)) == 1 then
				incoming_ipos = incoming_ipos + 1
				value.PostEffects = incoming_inst[incoming_ipos]
			else
				value.PostEffects = nil
			end
			if events[3] then
				task.spawn(events[3], player, value)
			end
		else
			error("Unknown event id")
		end
	end
end)
local returns = {
	SendEvents = SendEvents,
	CreateHint = {
		Fire = function(Player: Player, Value: ({
			Hint: (string),
			Color: ((unknown)),
			Duration: ((string)?),
		}))
			load_player(Player)
			alloc(1)
			buffer.writeu8(outgoing_buff, outgoing_apos, 1)
			local len_1 = #Value.Hint
			alloc(2)
			buffer.writeu16(outgoing_buff, outgoing_apos, len_1)
			alloc(len_1)
			buffer.writestring(outgoing_buff, outgoing_apos, Value.Hint, len_1)
			if Value.Color == nil then
				alloc(1)
				buffer.writeu8(outgoing_buff, outgoing_apos, 0)
			else
				alloc(1)
				buffer.writeu8(outgoing_buff, outgoing_apos, 1)
				table.insert(outgoing_inst, Value.Color)
			end
			if Value.Duration == nil then
				alloc(1)
				buffer.writeu8(outgoing_buff, outgoing_apos, 0)
			else
				alloc(1)
				buffer.writeu8(outgoing_buff, outgoing_apos, 1)
				local len_2 = #Value.Duration
				alloc(2)
				buffer.writeu16(outgoing_buff, outgoing_apos, len_2)
				alloc(len_2)
				buffer.writestring(outgoing_buff, outgoing_apos, Value.Duration, len_2)
			end
			player_map[Player] = save()
		end,
		FireAll = function(Value: ({
			Hint: (string),
			Color: ((unknown)),
			Duration: ((string)?),
		}))
			load_empty()
			alloc(1)
			buffer.writeu8(outgoing_buff, outgoing_apos, 1)
			local len_1 = #Value.Hint
			alloc(2)
			buffer.writeu16(outgoing_buff, outgoing_apos, len_1)
			alloc(len_1)
			buffer.writestring(outgoing_buff, outgoing_apos, Value.Hint, len_1)
			if Value.Color == nil then
				alloc(1)
				buffer.writeu8(outgoing_buff, outgoing_apos, 0)
			else
				alloc(1)
				buffer.writeu8(outgoing_buff, outgoing_apos, 1)
				table.insert(outgoing_inst, Value.Color)
			end
			if Value.Duration == nil then
				alloc(1)
				buffer.writeu8(outgoing_buff, outgoing_apos, 0)
			else
				alloc(1)
				buffer.writeu8(outgoing_buff, outgoing_apos, 1)
				local len_2 = #Value.Duration
				alloc(2)
				buffer.writeu16(outgoing_buff, outgoing_apos, len_2)
				alloc(len_2)
				buffer.writestring(outgoing_buff, outgoing_apos, Value.Duration, len_2)
			end
			local buff, used, inst = outgoing_buff, outgoing_used, outgoing_inst
			for _, player in Players:GetPlayers() do
				load_player(player)
				alloc(used)
				buffer.copy(outgoing_buff, outgoing_apos, buff, 0, used)
				table.move(inst, 1, #inst, #outgoing_inst + 1, outgoing_inst)
				player_map[player] = save()
			end
		end,
		FireExcept = function(Except: Player, Value: ({
			Hint: (string),
			Color: ((unknown)),
			Duration: ((string)?),
		}))
			load_empty()
			alloc(1)
			buffer.writeu8(outgoing_buff, outgoing_apos, 1)
			local len_1 = #Value.Hint
			alloc(2)
			buffer.writeu16(outgoing_buff, outgoing_apos, len_1)
			alloc(len_1)
			buffer.writestring(outgoing_buff, outgoing_apos, Value.Hint, len_1)
			if Value.Color == nil then
				alloc(1)
				buffer.writeu8(outgoing_buff, outgoing_apos, 0)
			else
				alloc(1)
				buffer.writeu8(outgoing_buff, outgoing_apos, 1)
				table.insert(outgoing_inst, Value.Color)
			end
			if Value.Duration == nil then
				alloc(1)
				buffer.writeu8(outgoing_buff, outgoing_apos, 0)
			else
				alloc(1)
				buffer.writeu8(outgoing_buff, outgoing_apos, 1)
				local len_2 = #Value.Duration
				alloc(2)
				buffer.writeu16(outgoing_buff, outgoing_apos, len_2)
				alloc(len_2)
				buffer.writestring(outgoing_buff, outgoing_apos, Value.Duration, len_2)
			end
			local buff, used, inst = outgoing_buff, outgoing_used, outgoing_inst
			for _, player in Players:GetPlayers() do
				if player ~= Except then
					load_player(player)
					alloc(used)
					buffer.copy(outgoing_buff, outgoing_apos, buff, 0, used)
					table.move(inst, 1, #inst, #outgoing_inst + 1, outgoing_inst)
					player_map[player] = save()
				end
			end
		end,
		FireList = function(List: { Player }, Value: ({
			Hint: (string),
			Color: ((unknown)),
			Duration: ((string)?),
		}))
			load_empty()
			alloc(1)
			buffer.writeu8(outgoing_buff, outgoing_apos, 1)
			local len_1 = #Value.Hint
			alloc(2)
			buffer.writeu16(outgoing_buff, outgoing_apos, len_1)
			alloc(len_1)
			buffer.writestring(outgoing_buff, outgoing_apos, Value.Hint, len_1)
			if Value.Color == nil then
				alloc(1)
				buffer.writeu8(outgoing_buff, outgoing_apos, 0)
			else
				alloc(1)
				buffer.writeu8(outgoing_buff, outgoing_apos, 1)
				table.insert(outgoing_inst, Value.Color)
			end
			if Value.Duration == nil then
				alloc(1)
				buffer.writeu8(outgoing_buff, outgoing_apos, 0)
			else
				alloc(1)
				buffer.writeu8(outgoing_buff, outgoing_apos, 1)
				local len_2 = #Value.Duration
				alloc(2)
				buffer.writeu16(outgoing_buff, outgoing_apos, len_2)
				alloc(len_2)
				buffer.writestring(outgoing_buff, outgoing_apos, Value.Duration, len_2)
			end
			local buff, used, inst = outgoing_buff, outgoing_used, outgoing_inst
			for _, player in List do
				load_player(player)
				alloc(used)
				buffer.copy(outgoing_buff, outgoing_apos, buff, 0, used)
				table.move(inst, 1, #inst, #outgoing_inst + 1, outgoing_inst)
				player_map[player] = save()
			end
		end,
		FireSet = function(Set: { [Player]: true }, Value: ({
			Hint: (string),
			Color: ((unknown)),
			Duration: ((string)?),
		}))
			load_empty()
			alloc(1)
			buffer.writeu8(outgoing_buff, outgoing_apos, 1)
			local len_1 = #Value.Hint
			alloc(2)
			buffer.writeu16(outgoing_buff, outgoing_apos, len_1)
			alloc(len_1)
			buffer.writestring(outgoing_buff, outgoing_apos, Value.Hint, len_1)
			if Value.Color == nil then
				alloc(1)
				buffer.writeu8(outgoing_buff, outgoing_apos, 0)
			else
				alloc(1)
				buffer.writeu8(outgoing_buff, outgoing_apos, 1)
				table.insert(outgoing_inst, Value.Color)
			end
			if Value.Duration == nil then
				alloc(1)
				buffer.writeu8(outgoing_buff, outgoing_apos, 0)
			else
				alloc(1)
				buffer.writeu8(outgoing_buff, outgoing_apos, 1)
				local len_2 = #Value.Duration
				alloc(2)
				buffer.writeu16(outgoing_buff, outgoing_apos, len_2)
				alloc(len_2)
				buffer.writestring(outgoing_buff, outgoing_apos, Value.Duration, len_2)
			end
			local buff, used, inst = outgoing_buff, outgoing_used, outgoing_inst
			for player in Set do
				load_player(player)
				alloc(used)
				buffer.copy(outgoing_buff, outgoing_apos, buff, 0, used)
				table.move(inst, 1, #inst, #outgoing_inst + 1, outgoing_inst)
				player_map[player] = save()
			end
		end,
	},
	ChangeMusic = {
		SetCallback = function(Callback: (Player, ({
			MusicId: (string),
			Volume: ((string)?),
			StartTick: ((string)?),
		})) -> ()): () -> ()
			events[2] = Callback
			return function()
				events[2] = nil
			end
		end,
	},
	ChangeLighting = {
		SetCallback = function(Callback: (Player, ({
			Properties: ((unknown)),
			PostEffects: ((unknown)),
		})) -> ()): () -> ()
			events[3] = Callback
			return function()
				events[3] = nil
			end
		end,
	},
}
type Events = typeof(returns)
return returns
