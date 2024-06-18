--!nocheck

local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Spawn = require(ReplicatedStorage.Modules.Packages.Spawn)

local HarukaLib = {}

--[[
	Convert a number to string with abbr, for example, `10000` -> `10K`
]]
function HarukaLib:NumberConvert(number: number, type: string) : string
	local prefixes = { "", "K", "M", "B", "T", "Q", "Qi", "Sx", "Sp", "Oc", "No", "Dc", "Ud", "Dd" }
	local abbrFactor = math.floor(math.floor(math.log10(number)) / 3)

	if abbrFactor > 0 then
		if prefixes[abbrFactor + 1] then
			return string.format(type, number / 10 ^ (abbrFactor * 3)) .. prefixes[abbrFactor + 1]
		end
	end

	return tostring(number)
end

--[[
	Get player's current device, may not accurate
]]
function HarukaLib:GetDevice() : "PC" | "Mobile" | "Console" | "VR"
	local device = "PC"

	if GuiService:IsTenFootInterface() then device = "Console" end
	if UserInputService.TouchEnabled then device = "Mobile" end
	if UserInputService.VREnabled then device = "VR" end

	return device
end

--[[
	Get more accurate device, instead of a type
]]
function HarukaLib:GetAccurateDevice() : "PC" | "Tablet" | "Phone" | "Xbox" | "PlayStation" | "VR"
	local device = "PC"

	if GuiService:IsTenFootInterface() then
		local key = Enum.KeyCode.ButtonA

		if UserInputService:GetStringForKeyCode(key) == "ButtonA" then device = "Xbox" end
		if UserInputService:GetStringForKeyCode(key) == "ButtonCross" then device = "PlayStation" end
	end
	if UserInputService.TouchEnabled then
		local screenSize = workspace.CurrentCamera.ViewportSize

		if screenSize.X < screenSize.Y then
			if screenSize.X < 600 then device = "Phone" else device = "Tablet" end

		elseif screenSize.X > screenSize.Y then
			if screenSize.Y < 600 then device = "Phone" else device = "Tablet" end
		end
	end
	if UserInputService.VREnabled then device = "VR" end

	return device
end

--[[
	Update an attribute to a given value, equals to `Value += val`
]]
function HarukaLib:AddAttr(obj: Instance, attribute: string, val: number)
	obj:SetAttribute(attribute, obj:GetAttribute(attribute) + val)
end

--[[
	Clear all attributes from an instance, equals to `obj:ClearAllChildren()`
]]
function HarukaLib:ClearAllAttributes(obj: Instance)
	for attribute, _ in obj:GetAttributes() do obj:SetAttribute(attribute, nil) end
end

--[[
	Whether it's in the region with the given Vector3
]]
function HarukaLib:IsInRegion(position: Vector3, regions: table) : BasePart
	local region: BasePart = nil

	for _, child: BasePart in regions do
		local point = child.CFrame:PointToObjectSpace(position)

		if math.abs(point.X) < child.Size.X / 2
			and math.abs(point.Y) < child.Size.Y / 2
			and math.abs(point.Z) < child.Size.Z / 2 then

			region = child
			break
		end
	end

	return region
end

--[[
	Richtextify my self-created text format
]]
function HarukaLib:RichTextify(text: string) : string
	local colorList = {
		["<blue>"] = [[<font color="#70a1ff">]],
		["<purple>"] = [[<font color="#5352ed">]],
		["<red>"] = [[<font color="#ff4757">]],
		["<orange>"] = [[<font color="#ffa502">]],
		["<yellow>"] = [[<font color="#ffda79">]],
		["<green>"] = [[<font color="#7bed9f">]],
	}

	for oriTag: string, rbxColorTag: string in colorList do
		text = string.gsub(text, oriTag, rbxColorTag)
	end

	return text
end

--[[
	A simple serializer for datastore
]]
function HarukaLib:Serialize(val: CFrame | Vector3 | Color3) : any
	local valType = typeof(val)

	if valType == "CFrame" then
		return { "CFrame", val:GetComponents() }

	elseif valType == "Vector3" then
		return { "Vector3", math.floor(val.X), math.floor(val.Y), math.floor(val.Z) }

	elseif valType == "Color3" then
		return { "Color3", val.R, val.G, val.B }

	else
		return val --- return default
	end
end
function HarukaLib:Deserialize(val: table) : any
	if typeof(val) ~= "table" then return val end

	local valType = val[1] :: string

	if valType == "CFrame" then
		return CFrame.new(unpack(val, 2, #val))

	elseif valType == "Vector3" then
		return Vector3.new(unpack(val, 2, #val))

	elseif valType == "Color3" then
		return Color3.fromRGB(unpack(val, 2, #val))

	else
		return valType
	end
end

--[[
	A custom remade of `Fusion.Hydrate`, return a way to disconnect
]]
function HarukaLib:Hydrate(obj: Instance, props: table)
	local Add, Empty = HarukaLib.Bin()

	for prop, func in props do
		if string.find(prop, "Attr") then
			local _, endPos = string.find(prop, "Attr")
			local attr = string.sub(prop, endPos + 2)

			Add(obj:GetAttributeChangedSignal(attr):Connect(function()
				func(obj:GetAttribute(attr))
			end))

		elseif string.find(prop, "Prop") then
			local _, endPos = string.find(prop, "Prop")
			local propName = string.sub(prop, endPos + 2)

			Add(obj:GetPropertyChangedSignal(propName):Connect(function()
				func(obj[propName])
			end))
		end
	end

	return Empty
end

--[[
	A custom remade of `Bin`
]]
function HarukaLib.Bin()
	local bin = {}

	return function (item: any)
		bin[#bin + 1] = item

		return item

	end, function()
		for _, item: any in bin do
			if typeof(item) == "Instance" then
				item:Destroy()

			elseif typeof(item) == "RBXScriptConnection" then
				item:Disconnect()

			elseif typeof(item) == "function" then
				Spawn(item)

			elseif typeof(item) == "thread" then
				if item then task.cancel(item) end
			end
		end

		table.clear(bin)
	end
end

--[[
	A custom remade of `Clock`, provides a callback to disconnect
]]
function HarukaLib.Clock(tickTime: number, func: () -> ())
	local nowTime = 0
	local dropTime = tickTime * 10

	local connection = RunService.Heartbeat:Connect(function(deltaTime)
		nowTime += deltaTime

		if nowTime > dropTime then
			nowTime = 0
			func()

		elseif nowTime > tickTime then
			nowTime -= tickTime

			func()
		end
	end)

	return function ()
		connection:Disconnect()
	end
end

--[[
	A custom tween remade of `TweenService`, auto-play
]]
function HarukaLib:Tween(object: Instance, style: TweenInfo, goal: table)
	local properties = {}

	local dataTypes = {
		number = function(a, b, t)
			return a + ((b - a) * t)
		end,

		Vector3 = function(a, b, t)
			return a:Lerp(b, t)
		end
	}
	dataTypes.NumberSequence = function(a, b, t)
		local keyPoints = {}

		for index: number, keypoint: NumberSequenceKeypoint in a.Keypoints do
			local nextKeypoint = b.Keypoints[index] :: NumberSequenceKeypoint

			table.insert(keyPoints, NumberSequenceKeypoint.new(
				dataTypes.number(keypoint.Time, nextKeypoint.Time, t),
				dataTypes.number(keypoint.Value, nextKeypoint.Value, t),
				dataTypes.number(keypoint.Envelope, nextKeypoint.Envelope, t)
			))
		end

		return NumberSequence.new(keyPoints)
	end
	dataTypes.ColorSequence = function(a, b, t)
		local keyPoints = {}

		for index: number, keypoint: ColorSequenceKeypoint in a.KeyPoints do
			local nextKeypoint = b.Keypoints[index] :: ColorSequenceKeypoint

			table.insert(keyPoints, ColorSequenceKeypoint.new(
				dataTypes.number(keypoint.Time, nextKeypoint.Time, t),
				dataTypes.Vector3(keypoint.Value, nextKeypoint.Value, math.clamp(t, 0, 1))
			))
		end

		return ColorSequence.new(keyPoints)
	end
	dataTypes.NumberRange = function(a, b, t)
		return NumberRange.new(
			dataTypes.number(a.Min, b.Min, t),
			dataTypes.number(a.Max, b.Max, t)
		)
	end

	--// fill properties
	for name: string, _: any in goal do
		if name == "Pivot" then
			if not object:IsA("PVInstance") then
				warn(name.." is not allowed for this object! "..object:GetFullName())
				return
			end

			properties[name] = object:GetPivot()
		else
			properties[name] = object[name]
		end
	end

	--- update task
	local startTime = tick()
	task.defer(function()
		local reverse = false
		local repeated = 0

		while true do
			if not object.Parent then break end

			local alpha = (tick() - startTime) / style.Time
			local t = math.min(alpha, 1)

			if style.Reverses then alpha = 1 - t end

			-- Update
			local lerp = TweenService:GetValue(alpha, style.EasingStyle, style.EasingDirection)

			for name: string, val: any in goal do
				local original = properties[name]

				if name == "Pivot" then
					object:PivotTo(dataTypes.Vector3(original, val, lerp))
				else
					object[name] = dataTypes[typeof(val)](original, val, lerp)
				end
			end

			if t == 1 then
				if style.Reverses and not reverse then
					reverse = true
					startTime = tick()

				elseif repeated ~= style.RepeatCount then
					repeated += 1
					reverse = false
					startTime = tick()

				else
					break
				end
			end

			task.wait()
		end
	end)
end

--[[
	Number type check in run-time, inspired by `t`
]]
function HarukaLib:TypeCheck(checkTask: "Integer" | "Min" | "Max" | "MinMax", val: any, extra: number?, extra2: number?) : boolean
	local success = pcall(function()
		if checkTask == "Integer" then
			assert(type(val) == "number")
			assert(val % 1 == 0)

		elseif checkTask == "Min" then
			assert(type(val) == "number")
			assert(val >= extra)

		elseif checkTask == "Max" then
			assert(type(val) == "number")
			assert(val <= extra)

		elseif checkTask == "MinMax" then
			assert(type(val) == "number")
			assert(val > extra)
			assert(val < extra2)
		end
	end)

	return success
end

--[[
	custom remade of `LootPlan`
]]
function HarukaLib:RollLoot(loots: { [string]: number }) : string
	local lootList = {}

	for loot: string, weight: number in loots do
		local info = {
			Name = loot,
			Weight = weight
		}
		lootList[#lootList + 1] = info
	end

	-- simple sort
	table.sort(lootList, function(a, b)
		return a.Weight < b.Weight
	end)

	--- start to roll
	local result = Random.new():NextNumber()
	local aggregate = 0

	for _, loot: table in lootList do
		local chance = loot.Weight :: number

		if result < (chance + aggregate) / 100 then
			lootList = nil --// GC

			return loot.Name
		end

		aggregate += chance
	end
end

return HarukaLib
