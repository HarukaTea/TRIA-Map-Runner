--!native
--!optimize 2
--!nocheck
--!nolint
--#selene: allow(unused_variable, incorrect_standard_library_use, global_usage)
-- Client generated by Zap v0.6.15 (https://github.com/red-blox/zap)
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
			On = noop
		}),
		ChangeMusic = table.freeze({
			Fire = noop
		}),
		ChangeLighting = table.freeze({
			Fire = noop
		}),
		TeleportPlayer = table.freeze({
			SetCallback = noop
		}),
		ForceReset = table.freeze({
			Fire = noop
		}),
		MapRoundEnding = table.freeze({
			SetCallback = noop
		}),
	}) :: Events
end
if RunService:IsServer() then
	error("Cannot use the client module on the server!")
end
local remotes = ReplicatedStorage:WaitForChild("ZAP")
local reliable = remotes:WaitForChild("HARUKA_RELIABLE")
local unreliable = remotes:WaitForChild("HARUKA_UNRELIABLE")

assert(reliable:IsA("RemoteEvent"), "Expected HARUKA_RELIABLE to be a RemoteEvent")
assert(unreliable:IsA("UnreliableRemoteEvent"), "Expected HARUKA_UNRELIABLE to be an UnreliableRemoteEvent")


local function SendEvents()
	if outgoing_used ~= 0 then
		local buff = buffer.create(outgoing_used)
		buffer.copy(buff, 0, outgoing_buff, 0, outgoing_used)

		reliable:FireServer(buff, outgoing_inst)

		outgoing_buff = buffer.create(64)
		outgoing_used = 0
		outgoing_size = 64
		table.clear(outgoing_inst)
	end
end

RunService.Heartbeat:Connect(SendEvents)

local events = table.create(6)
local event_queue: { [number]: { any } } = table.create(6)
events[1] = {}
event_queue[1] = {}
event_queue[4] = {}
event_queue[6] = {}
reliable.OnClientEvent:Connect(function(buff, inst)
	incoming_buff = buff
	incoming_inst = inst
	incoming_read = 0
	incoming_ipos = 0
	local len = buffer.len(buff)
	while incoming_read < len do
		local id = buffer.readu8(buff, read(1))
		if id == 1 then
			local value
			value = {}
			if buffer.readu8(incoming_buff, read(1)) == 1 then
				local len_1 = buffer.readu16(incoming_buff, read(2))
				value.Hint = buffer.readstring(incoming_buff, read(len_1), len_1)
			else
				value.Hint = nil
			end
			if buffer.readu8(incoming_buff, read(1)) == 1 then
				incoming_ipos = incoming_ipos + 1
				value.Color = incoming_inst[incoming_ipos]
			else
				value.Color = nil
			end
			if buffer.readu8(incoming_buff, read(1)) == 1 then
				local len_2 = buffer.readu16(incoming_buff, read(2))
				value.Duration = buffer.readstring(incoming_buff, read(len_2), len_2)
			else
				value.Duration = nil
			end
			if events[1][1] then
				for _, cb in events[1] do
					task.spawn(cb, value)
				end
			else
				table.insert(event_queue[1], value)
				if #event_queue[1] > 64 then
					warn(`[ZAP] {#event_queue[1]} events in queue for CreateHint. Did you forget to attach a listener?`)
				end
			end
		elseif id == 4 then
			local value
			value = {}
			if buffer.readu8(incoming_buff, read(1)) == 1 then
				incoming_ipos = incoming_ipos + 1
				value.Player = incoming_inst[incoming_ipos]
				assert(value.Player == nil or value.Player:IsA("Player"))
			else
				value.Player = nil
			end
			if buffer.readu8(incoming_buff, read(1)) == 1 then
				local pos_1 = Vector3.new(buffer.readf32(incoming_buff, read(4)), buffer.readf32(incoming_buff, read(4)), buffer.readf32(incoming_buff, read(4)))
				local axisangle_1 = Vector3.new(buffer.readf32(incoming_buff, read(4)), buffer.readf32(incoming_buff, read(4)), buffer.readf32(incoming_buff, read(4)))
				local angle_1 = axisangle_1.Magnitude
				if angle_1 ~= 0 then
					value.Destination = CFrame.fromAxisAngle(axisangle_1, angle_1) + pos_1
				else
					value.Destination = CFrame.new(pos_1)
				end
			else
				value.Destination = nil
			end
			if buffer.readu8(incoming_buff, read(1)) == 1 then
				value.FaceFront = buffer.readu8(incoming_buff, read(1)) == 1
			else
				value.FaceFront = nil
			end
			if events[4] then
				task.spawn(events[4], value)
			else
				table.insert(event_queue[4], value)
				if #event_queue[4] > 64 then
					warn(`[ZAP] {#event_queue[4]} events in queue for TeleportPlayer. Did you forget to attach a listener?`)
				end
			end
		elseif id == 6 then
			local value
			value = {}
			if events[6] then
				task.spawn(events[6], value)
			else
				table.insert(event_queue[6], value)
				if #event_queue[6] > 64 then
					warn(`[ZAP] {#event_queue[6]} events in queue for MapRoundEnding. Did you forget to attach a listener?`)
				end
			end
		else
			error("Unknown event id")
		end
	end
end)
local returns = {
	SendEvents = SendEvents,
	ChangeMusic = {
		Fire = function(Value: ({
			MusicId: ((string)?),
			Volume: ((string)?),
			StartTick: ((string)?),
		}))
			alloc(1)
			buffer.writeu8(outgoing_buff, outgoing_apos, 2)
			if Value.MusicId == nil then
				alloc(1)
				buffer.writeu8(outgoing_buff, outgoing_apos, 0)
			else
				alloc(1)
				buffer.writeu8(outgoing_buff, outgoing_apos, 1)
				local len_1 = #Value.MusicId
				alloc(2)
				buffer.writeu16(outgoing_buff, outgoing_apos, len_1)
				alloc(len_1)
				buffer.writestring(outgoing_buff, outgoing_apos, Value.MusicId, len_1)
			end
			if Value.Volume == nil then
				alloc(1)
				buffer.writeu8(outgoing_buff, outgoing_apos, 0)
			else
				alloc(1)
				buffer.writeu8(outgoing_buff, outgoing_apos, 1)
				local len_2 = #Value.Volume
				alloc(2)
				buffer.writeu16(outgoing_buff, outgoing_apos, len_2)
				alloc(len_2)
				buffer.writestring(outgoing_buff, outgoing_apos, Value.Volume, len_2)
			end
			if Value.StartTick == nil then
				alloc(1)
				buffer.writeu8(outgoing_buff, outgoing_apos, 0)
			else
				alloc(1)
				buffer.writeu8(outgoing_buff, outgoing_apos, 1)
				local len_3 = #Value.StartTick
				alloc(2)
				buffer.writeu16(outgoing_buff, outgoing_apos, len_3)
				alloc(len_3)
				buffer.writestring(outgoing_buff, outgoing_apos, Value.StartTick, len_3)
			end
		end,
	},
	ChangeLighting = {
		Fire = function(Value: ({
			Properties: (({ [(string)]: ((unknown)) })?),
			PostEffects: (({ [(string)]: (({ [(string)]: ((unknown)) })?) })?),
		}))
			alloc(1)
			buffer.writeu8(outgoing_buff, outgoing_apos, 3)
			if Value.Properties == nil then
				alloc(1)
				buffer.writeu8(outgoing_buff, outgoing_apos, 0)
			else
				alloc(1)
				buffer.writeu8(outgoing_buff, outgoing_apos, 1)
				local len_pos_1 = alloc(2)
				local len_1 = 0
				for k_1, v_1 in Value.Properties do
					len_1 = len_1 + 1
					local len_2 = #k_1
					alloc(2)
					buffer.writeu16(outgoing_buff, outgoing_apos, len_2)
					alloc(len_2)
					buffer.writestring(outgoing_buff, outgoing_apos, k_1, len_2)
					if v_1 == nil then
						alloc(1)
						buffer.writeu8(outgoing_buff, outgoing_apos, 0)
					else
						alloc(1)
						buffer.writeu8(outgoing_buff, outgoing_apos, 1)
						table.insert(outgoing_inst, v_1)
					end
				end
				buffer.writeu16(outgoing_buff, len_pos_1, len_1)
			end
			if Value.PostEffects == nil then
				alloc(1)
				buffer.writeu8(outgoing_buff, outgoing_apos, 0)
			else
				alloc(1)
				buffer.writeu8(outgoing_buff, outgoing_apos, 1)
				local len_pos_2 = alloc(2)
				local len_3 = 0
				for k_2, v_2 in Value.PostEffects do
					len_3 = len_3 + 1
					local len_4 = #k_2
					alloc(2)
					buffer.writeu16(outgoing_buff, outgoing_apos, len_4)
					alloc(len_4)
					buffer.writestring(outgoing_buff, outgoing_apos, k_2, len_4)
					if v_2 == nil then
						alloc(1)
						buffer.writeu8(outgoing_buff, outgoing_apos, 0)
					else
						alloc(1)
						buffer.writeu8(outgoing_buff, outgoing_apos, 1)
						local len_pos_3 = alloc(2)
						local len_5 = 0
						for k_3, v_3 in v_2 do
							len_5 = len_5 + 1
							local len_6 = #k_3
							alloc(2)
							buffer.writeu16(outgoing_buff, outgoing_apos, len_6)
							alloc(len_6)
							buffer.writestring(outgoing_buff, outgoing_apos, k_3, len_6)
							if v_3 == nil then
								alloc(1)
								buffer.writeu8(outgoing_buff, outgoing_apos, 0)
							else
								alloc(1)
								buffer.writeu8(outgoing_buff, outgoing_apos, 1)
								table.insert(outgoing_inst, v_3)
							end
						end
						buffer.writeu16(outgoing_buff, len_pos_3, len_5)
					end
				end
				buffer.writeu16(outgoing_buff, len_pos_2, len_3)
			end
		end,
	},
	ForceReset = {
		Fire = function(Value: ({
		}))
			alloc(1)
			buffer.writeu8(outgoing_buff, outgoing_apos, 5)
		end,
	},
	CreateHint = {
		On = function(Callback: (Value: ({
			Hint: ((string)?),
			Color: ((unknown)),
			Duration: ((string)?),
		})) -> ())
			table.insert(events[1], Callback)
			for _, value in event_queue[1] do
				task.spawn(Callback, value)
			end
			event_queue[1] = {}
			return function()
				table.remove(events[1], table.find(events[1], Callback))
			end
		end,
	},
	TeleportPlayer = {
		SetCallback = function(Callback: (Value: ({
			Player: ((Player)?),
			Destination: ((CFrame)?),
			FaceFront: ((boolean)?),
		})) -> ()): () -> ()
			events[4] = Callback
			for _, value in event_queue[4] do
				task.spawn(Callback, value)
			end
			event_queue[4] = {}
			return function()
				events[4] = nil
			end
		end,
	},
	MapRoundEnding = {
		SetCallback = function(Callback: (Value: ({
		})) -> ()): () -> ()
			events[6] = Callback
			for _, value in event_queue[6] do
				task.spawn(Callback, value)
			end
			event_queue[6] = {}
			return function()
				events[6] = nil
			end
		end,
	},
}
type Events = typeof(returns)
return returns
