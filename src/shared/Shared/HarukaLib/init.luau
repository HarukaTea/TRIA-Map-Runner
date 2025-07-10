--!nocheck

local CAS = game:GetService("ContextActionService")
local Debris = game:GetService("Debris")
local GuiService = game:GetService("GuiService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

local Signal = require(RepS.HarukaShared.Shared.Signal)


local Tween = require(script.HarukaTween)
local TableUtils = require(script.HarukaTableUtils)

local wait = task.wait

local HarukaLib = {}

--[[
	Helper function to convert a number to a string with a suffix.

    **Example:**
    ``````lua
    HarukaLib:NumberConvertToCurrencyString(1000, 2) --- 1.00K
    ``````
]]
function HarukaLib:NumberConvertToCurrencyString(number: number, decimalPlaces: number) : string
	local prefixes = { "", "K", "M", "B", "T", "Q", "Qi", "Sx", "Sp", "Oc", "No", "Dc", "Ud", "Dd" }
	local abbrFactor = math.floor(math.floor(math.log10(number)) / 3)

	decimalPlaces = decimalPlaces or 2
    local outputType = "%.".. tostring(decimalPlaces).. "f"

	if abbrFactor > 0 then
		if prefixes[abbrFactor + 1] then
			return string.format(outputType, number / 10 ^ (abbrFactor * 3)) .. prefixes[abbrFactor + 1]
		end
	end

	return tostring(number)
end


--[[
    Get the device type
]]
function HarukaLib:GetDevice() : "PC" | "Mobile" | "Console" | "VR"
	local device = "PC"

	if GuiService:IsTenFootInterface() then device = "Console" end
	if UIS.TouchEnabled then device = "Mobile" end
	if UIS.VREnabled then device = "VR" end

	return device
end


--[[
    Get the accurate device type
]]
function HarukaLib:GetAccurateDevice() : "PC" | "Xbox" | "PlayStation" | "Phone" | "Tablet" | "VR"
	local device = "PC"

	if GuiService:IsTenFootInterface() then
		local key = Enum.KeyCode.ButtonA

		if UIS:GetStringForKeyCode(key) == "ButtonA" then device = "Xbox" end
		if UIS:GetStringForKeyCode(key) == "ButtonCross" then device = "PlayStation" end
	end
	if UIS.TouchEnabled then
		local screenSize = workspace.CurrentCamera.ViewportSize

		if screenSize.X < screenSize.Y then
			if screenSize.X < 600 then device = "Phone" else device = "Tablet" end

		elseif screenSize.X > screenSize.Y then
			if screenSize.Y < 600 then device = "Phone" else device = "Tablet" end
		end
	end
	if UIS.VREnabled then device = "VR" end

	return device
end


--[[
	Increase attribute value for an instance.
	It will not work if attribute is not a number.

	But it will create a default value (0) if attribute is not exist.

	**Example:**
	``````lua
	obj.Health = 0
	HarukaLib:AddAttr(obj, "Health", 10) --- obj.Health = 10
	``````
]]
function HarukaLib:AddAttr(obj: Instance, attribute: string, val: number)
	if obj:GetAttribute(attribute) == nil then
		obj:SetAttribute(attribute, 0)
	end
	if typeof(obj:GetAttribute(attribute)) ~= "number" then
		return
	end

	obj:SetAttribute(attribute, obj:GetAttribute(attribute) + val)
end


--[[
	The same as `obj:ClearAllChildren()`, but it applies for attributes
]]
function HarukaLib:ClearAllAttributes(obj: Instance)
	for attribute: string, _ in obj:GetAttributes() do
		obj:SetAttribute(attribute, nil)
	end
end


--[[
	Detect if the given position is inside any of the given regions.
]]
function HarukaLib:IsInRegion(position: Vector3, regions: { BasePart }) : BasePart?
	local region: BasePart = nil

	for _, child: BasePart in regions do
		if not child:IsA("BasePart") then continue end

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



local COLOR_LIST = {
	["<blue>"] = [[<font color="#47a3ff">]],
	["<purple>"] = [[<font color="#8178ff">]],
	["<red>"] = [[<font color="#ff4a65">]],
	["<orange>"] = [[<font color="#ffaf57">]],
	["<yellow>"] = [[<font color="#fcff82">]],
	["<green>"] = [[<font color="#7bed9f">]],
	["<cyan>"] = [[<font color="#81ecec">]],
	["<white>"] = [[<font color="#ffffff">]],
	["<black>"] = [[<font color="#2d3436">]],
	["<pink>"] = [[<font color="#fd79a8">]],
	["<gray>"] = [[<font color="#747d8c">]],
	["<grey>"] = [[<font color="#747d8c">]],

	["</blue>"] = [[</font>]],
	["</purple>"] = [[</font>]],
	["</red>"] = [[</font>]],
	["</orange>"] = [[</font>]],
	["</yellow>"] = [[</font>]],
	["</green>"] = [[</font>]],
	["</cyan>"] = [[</font>]],
	["</white>"] = [[</font>]],
	["</black>"] = [[</font>]],
	["</pink>"] = [[</font>]],
	["</gray>"] = [[</font>]],
	["</grey>"] = [[</font>]],
}


--[[
	Transform a plain text to rich text, it will only work when `RichText = true`

	**Example:**
	``````lua
	HarukaLib:RichTextify("<blue>Hello</font>,<red>World</font>!")
	``````
]]
function HarukaLib:RichTextify(text: string) : string
	if not text then return "" end

	for oriTag: string, rbxColorTag: string in COLOR_LIST do
		text = string.gsub(text, oriTag, rbxColorTag)
	end

	return text
end


--[[
	Serialize and deserialize roblox types to a table.
	It only supports `CFrame`, `Vector3`, and `Color3`.
]]
function HarukaLib:PackData(method: "Pack" | "Unpack", val: any) : any
	local valType = typeof(val)

	if method == "Pack" then
		if valType == "CFrame" then
			return { "CFrame", val:GetComponents() }

		elseif valType == "Vector3" then
			return { "Vector3", math.floor(val.X), math.floor(val.Y), math.floor(val.Z) }

		elseif valType == "Color3" then
			return { "Color3", val.R, val.G, val.B }
		else
			return val
		end

	elseif method == "Unpack" then
		if valType ~= "table" then return val end
		valType = val[1] :: string

		if valType == "CFrame" then
			return CFrame.new(unpack(val, 2, #val))

		elseif valType == "Vector3" then
			return Vector3.new(unpack(val, 2, #val))

		elseif valType == "Color3" then
			return Color3.fromRGB(unpack(val, 2, #val))
		else
			return val
		end
	end

	return val
end


--[[
	Inspired by `Fusion.Hydrate`, it will add a tracker to the given props/attrs,
	and call it funcs when the value of the prop/attr is changed.

	Return a function to destroy the tracker.
]]
function HarukaLib:Hydrate(obj: Instance, props: { any })
	local Add, Empty = HarukaLib.Bin()

	for prop: string, func: (val: any) -> nil in props do
		if string.find(prop, "Attr") then
			local _, endPos = string.find(prop, "Attr")
			local attr = string.sub(prop, endPos + 2)

			local success, err = pcall(func, obj:GetAttribute(attr))
			if not success then
				warn(err)
			end

			Add(obj:GetAttributeChangedSignal(attr):Connect(function()
				func(obj:GetAttribute(attr))
			end))

		elseif string.find(prop, "Prop") then
			local _, endPos = string.find(prop, "Prop")
			local propName = string.sub(prop, endPos + 2)

			local success, err = pcall(func, obj[propName])
			if not success then
				warn(err)
			end

			Add(obj:GetPropertyChangedSignal(propName):Connect(function()
				func(obj[propName])
			end))
		end
	end

	return Empty
end


--[[
	Inspired by `Maid`, and `Fusion.doCleanup`, you can add anything to the bin.

	Return a function to destroy the items inside the bin, bin can reused.
]]
function HarukaLib.Bin()
	local bin = {}

	local function doCleanup(item: any)
		if typeof(item) == "Instance" then
			item:Destroy()

		elseif typeof(item) == "RBXScriptConnection" then
			item:Disconnect()

		elseif typeof(item) == "function" then
			pcall(item)

		elseif typeof(item) == "thread" then
			if item then task.cancel(item) end

		elseif typeof(item) == "table" then
			if typeof(item.destroy) == "function" then
				item:destroy()

			elseif typeof(item.Destroy) == "function" then
				item:Destroy()

			elseif typeof(item.Cancel) == "function" then
				item:Cancel()

			elseif typeof(item.cancel) == "function" then
				item:cancel()

			--- cancel any exist promises
			elseif getmetatable(item) then
				if item.prototype then item:cancel() end

			elseif item[1] ~= nil then
				for index = #item, 1, -1 do
					doCleanup(item[index])

					item[index] = nil
				end
			end
		end
	end

	return function (item: any)
		table.insert(bin, item)

		return item

	end, function()
		pcall(doCleanup, bin)

		table.clear(bin)
	end
end


--[[
	Inspired by `Timer`, just like `window.setInterval` in javascript
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
	Inspired by `AdvancedTweenV2`, it can tween any property of any instance.

	Return a signal class, it will fire when the tween is completed.
]]
function HarukaLib:Tween(obj: Instance, style: { any }, goal: any, needSignal: boolean)
	return Tween(obj, style, goal, needSignal)
end


--[[
	Inspired by `t`, it can typecheck any value in runtime
]]
function HarukaLib:TypeCheck(checkTask: "Integer" | "Min" | "Max" | "MinMax", val: any, props: {
	Min: number?,
	Max: number?
}) : boolean

	local success = pcall(function()
		if checkTask == "Integer" then
			assert(type(val) == "number")
			assert(val % 1 == 0)

		elseif checkTask == "Min" then
			assert(type(val) == "number")
			assert(val >= props.Min)

		elseif checkTask == "Max" then
			assert(type(val) == "number")
			assert(val <= props.Max)

		elseif checkTask == "MinMax" then
			assert(type(val) == "number")
			assert(val >= props.Min)
			assert(val <= props.Max)
		end
	end)

	return success
end


--[[
	Inspired by `Sol's RNG`, basically it will roll a thing depends on the weight you give

	**Example:**
	``````lua
	HarukaLib:RollLoot({
		["Gold"] = 50,
		["Diamond"] = 30,
		["Silver"] = 20
	})
	``````

	return a tuple of `(item, weight, entry)`
]]
function HarukaLib:RollLoot(loots: { [string]: number }, luck: number?) : (string, number, number)
	luck = luck or 1

	local lowestBound = 1e-3
	local weightAdjustment = 1e9

	luck = math.clamp(luck, lowestBound, math.huge)

	--// add items
	local items = {}
	local total = #items
	local totalWeight = 0

	for loot: string, weight: number in loots do
		local newWeight = weight * weightAdjustment
		local position = math.max(1, total + 1)

		if total > 0 then
			for index = total, 1, -1 do
				local item = items[index]
				if item.Weight <= newWeight then
					position = index
				else
					break
				end
			end
		end

		table.insert(items, position, {
			Weight = weight,
			Item = loot
		})

		totalWeight += weight
	end

	--// roll
	local bestScore, bestItem, entry = math.huge, nil, nil
	local value = math.max(lowestBound, totalWeight - math.floor(totalWeight * math.random() ^ luck))
	local upperBound = 0

	for index = #items, 1, -1 do
		local item = items[index]
		upperBound += item.Weight

		if value <= upperBound and item.Weight < bestScore then
			bestScore, bestItem, entry = item.Weight, item.Item, index
			break
		end
	end
	if not bestItem then
		local item = items[1]
		bestScore = item.Weight
		bestItem = item.Item
		entry = 1
	end

	return bestItem, bestScore / weightAdjustment, entry
end


--[[
	Inspired by `CutsceneService`, it will fire the signal class when the cutscene is completed.
]]
function HarukaLib:PlayCutscene(pointsTable: { BasePart }, duration: number)
	local camera = workspace.CurrentCamera
	local cutsceneSignal = Signal.new()

	--// Helper funcs
	local function _getCF(points: { any }, t: number) : CFrame
		local copy = { unpack(points) }

		local n = #copy
		for j = 1, n - 1 do
			for k = 1, n - j do
				copy[k] = copy[k]:Lerp(copy[k + 1], t)
			end
		end
		return copy[1]
	end

	--- sort points
	local points = {}

	table.sort(pointsTable, function(a, b)
		return tonumber(a.Name) < tonumber(b.Name)
	end)
	for _, point: BasePart in pointsTable do
		table.insert(points, point.CFrame)
	end


	camera.CameraType = Enum.CameraType.Scriptable

	local priority = Enum.RenderPriority.Camera.Value + 1
	local start = os.clock()
	local passedTime = 0

	pcall(function()
		RunService:BindToRenderStep("HarukaCutscene", priority, function()
			passedTime = os.clock() - start

			if passedTime <= duration then
				camera.CFrame = _getCF(points, passedTime / duration)
			else
				RunService:UnbindFromRenderStep("HarukaCutscene")

				cutsceneSignal:Fire("Completed")
				cutsceneSignal:Destroy()
			end
		end)
	end)

	return cutsceneSignal
end


--[[
	This is the util for `UIStrokeAdjustor`, return accurate thickness based on viewport size
]]
function HarukaLib:CalculateStrokeThickness(thickness: number, scale: number) : number
	local VPSize = workspace.CurrentCamera.ViewportSize
	local DESIGN_VP_SIZE = Vector2.new(1172, 471.2)

	local function _calScreenRatio() : number
		local x = VPSize.X / DESIGN_VP_SIZE.X
		local y = VPSize.Y / DESIGN_VP_SIZE.Y

		return (x + y) / 2
	end

	local finalThickness = thickness * _calScreenRatio() * scale
    finalThickness = math.clamp(finalThickness, 0, 999)

	return finalThickness
end


--[[
	It will freeze/unfreeze player controls
]]
function HarukaLib:FreezePlayerControls(action: "Freeze" | "Unfreeze")
    if action == "Freeze" then
        UIS.ModalEnabled = true

        CAS:BindActionAtPriority("FreezeControl", function()
            return Enum.ContextActionResult.Sink
        end, false, Enum.ContextActionPriority.High.Value, unpack(Enum.PlayerActions:GetEnumItems()))
    else
        UIS.ModalEnabled = false

        CAS:UnbindAction("FreezeControl")
    end
end


--[[
	Helper function to set the collision group of an object and its children
]]
function HarukaLib:SetCollisionGroup(obj: Instance, group: string)
	if HarukaLib:IsBasePartType(obj) then obj.CollisionGroup = group end

	for _, child: Instance in obj:GetChildren() do HarukaLib:SetCollisionGroup(child, group) end
end


--[[
	Helper function to combine id with the prefix `"rbxassetid://"`
]]
function HarukaLib:CombineRbxId(id: string | number)
    if not id then
        return "rbxassetid://0"
    end

    return "rbxassetid://".. id
end


--[[
	Helper function to ban a player, Server-Side ONLY
]]
function HarukaLib:BanPlayerByUserId(userId: number, properties: {
	Duration: number,
	DisplayReason: string,
	PrivateReason: string,
	ExcludeAltAccounts: boolean,
})
	local config = {
		UserIds = { userId },
		Duration = properties.Duration,
		DisplayReason = properties.DisplayReason,
		PrivateReason = properties.PrivateReason,
		ExcludeAltAccounts = properties.ExcludeAltAccounts,
		ApplyToUniverse = true
	}

	local success, err = pcall(function()
		Players:BanAsync(config)
	end)
	if not success then
		warn(err)
	end
end



--[[
	Helper function to unban a player, Server-Side ONLY
]]
function HarukaLib:UnbanPlayerByUserId(userId: number)
	local config = {
		UserIds = { userId },
		ApplyToUniverse = true
	}


	local success, err = pcall(function()
		Players:UnbanAsync(config)
	end)
	if not success then
		warn(err)
	end
end


--[[
	Helper function to tween the transparency of a UI element
]]
function HarukaLib:UITween(ui: GuiObject, style: "In" | "Out", props: {
	DelayTime: number?,
	TweenTime: number?,

	SetOriPropsWhenOut: boolean?,
	FollowOriPropsWhenIn: boolean?,
	TweenCallback: (clonedTweenOutUI: GuiObject) -> nil?,

	PosTweenStyle: "FromB2T" | "FromT2B" | "FromL2R" | "FromR2L"?,
	PosTweenBaseElement: GuiObject?,
	PosTweenOffset: number?
}?)
	props = props or {}


	if props.TweenCallback and style == "Out" then
		local clonedTweenOutUI = ui:Clone()
		clonedTweenOutUI.Parent = ui.Parent
		Debris:AddItem(clonedTweenOutUI, 1)

		ui = clonedTweenOutUI

		pcall(props.TweenCallback, clonedTweenOutUI)

	elseif props.TweenCallback and style == "In" then
		pcall(props.TweenCallback, ui)
	end

	props.DelayTime = props.DelayTime or 0
	props.TweenTime = props.TweenTime or 0.2

	local tweenInfo = TweenInfo.new(props.TweenTime,
		Enum.EasingStyle.Sine,
		Enum.EasingDirection.Out
	)
	local tweenObjs = ui:GetDescendants()
	table.insert(tweenObjs, ui)

	local function _tweenGoal(obj: GuiObject, attr: string, tweenProps: { any })
		if not obj then return end
		if not obj.Parent then return end

		pcall(function()
			local original = obj[attr] :: number?
			local attrOriginal = obj:GetAttribute("HarukaUITween_Ori_"..attr) :: number?

			if style == "In" then
				obj[attr] = 1

				if original ~= 1 then tweenProps[attr] = original end
				if props.FollowOriPropsWhenIn and attrOriginal and attrOriginal ~= 1 then
					tweenProps[attr] = attrOriginal
				end

			elseif style == "Out" then
				if obj[attr] then
					tweenProps[attr] = 1

					if props.SetOriPropsWhenOut and obj:GetAttribute("HarukaUITween_Ori_"..attr) == nil then
						obj:SetAttribute("HarukaUITween_Ori_"..attr, original)
					end
				end
			end
		end)
		pcall(function()
			obj.Interactable = false
		end)
	end
	local function _startTween(obj: GuiObject, tweenProps: { any })
		if not obj then return end
		if not obj.Parent then return end

		pcall(function()
			HarukaLib:CreateTween(obj, tweenInfo, tweenProps):Play()
		end)
		pcall(function()
			obj.Interactable = true
		end)
	end


	for _, obj: Instance in tweenObjs do
		local tweenProps = {}

		if not obj then continue end
		if not obj.Parent then continue end

		if obj:IsA("Frame") then
			if not obj.Visible then continue end

			_tweenGoal(obj, "BackgroundTransparency", tweenProps)

		elseif obj:IsA("TextLabel") or obj:IsA("TextButton") then
			if not obj.Visible then continue end

			_tweenGoal(obj, "BackgroundTransparency", tweenProps)
			_tweenGoal(obj, "TextTransparency", tweenProps)
			_tweenGoal(obj, "TextStrokeTransparency", tweenProps)

		elseif obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
			if not obj.Visible then continue end

			_tweenGoal(obj, "ImageTransparency", tweenProps)
			_tweenGoal(obj, "BackgroundTransparency", tweenProps)

		elseif obj:IsA("ScrollingFrame") then
			if not obj.Visible then continue end

			_tweenGoal(obj, "BackgroundTransparency", tweenProps)
			_tweenGoal(obj, "ScrollBarImageTransparency", tweenProps)

		elseif obj:IsA("CanvasGroup") then
			if not obj.Visible then continue end

			_tweenGoal(obj, "GroupTransparency", tweenProps)

		elseif obj:IsA("UIStroke") then
			if not obj.Enabled then continue end

			_tweenGoal(obj, "Transparency", tweenProps)
		else
			continue
		end

		if props.DelayTime > 0 then
			task.delay(props.DelayTime, _startTween, obj, tweenProps)
		else
			_startTween(obj, tweenProps)
		end
	end

	if props.PosTweenStyle and props.PosTweenBaseElement then
		local nowPos = props.PosTweenBaseElement.Position
		local goalPos = nowPos

		local offset = props.PosTweenOffset or 15.99 / 2
		local fixFactor = if style == "In" then 1 else -1

		if props.PosTweenStyle == "FromB2T" then
			goalPos = UDim2.new(nowPos.X.Scale, nowPos.X.Offset, nowPos.Y.Scale, nowPos.Y.Offset + offset * fixFactor)

		elseif props.PosTweenStyle == "FromT2B" then
			goalPos = UDim2.new(nowPos.X.Scale, nowPos.X.Offset, nowPos.Y.Scale, nowPos.Y.Offset - offset * fixFactor)

		elseif props.PosTweenStyle == "FromL2R" then
			goalPos = UDim2.new(nowPos.X.Scale, nowPos.X.Offset - offset * fixFactor, nowPos.Y.Scale, nowPos.Y.Offset)

		elseif props.PosTweenStyle == "FromR2L" then
			goalPos = UDim2.new(nowPos.X.Scale, nowPos.X.Offset + offset * fixFactor, nowPos.Y.Scale, nowPos.Y.Offset)
		end

		if style == "Out" then
			goalPos, nowPos = nowPos, goalPos
		end

		local function _tweenPosition()
			props.PosTweenBaseElement.Position = goalPos

			local tween = TweenService:Create(props.PosTweenBaseElement, tweenInfo, {
				Position = nowPos
			})
			tween.Completed:Once(function()
				props.PosTweenBaseElement.Position = if style == "In" then nowPos else goalPos

				tween:Destroy()
			end)
			tween:Play()
		end

		if props.DelayTime > 0 then
			task.delay(props.DelayTime, _tweenPosition)
		else
			_tweenPosition()
		end
	end
end


--[[
	Helper function to fix the correct result of `CFrame.lookAt` in RPG series
]]
function HarukaLib:CFLookAt(pos1: Vector3, pos2: Vector3) : CFrame
	local finalCFrame = CFrame.identity
	local lookAt = CFrame.lookAt(pos1, pos2)

	if lookAt == lookAt then
		finalCFrame = CFrame.new(pos1) * lookAt.Rotation

		local _, ry, _ = finalCFrame:ToOrientation()
		finalCFrame = CFrame.new(finalCFrame.Position) * CFrame.Angles(0, ry, 0).Rotation
	end

	return finalCFrame
end


--[[
	Helper function to format a number with comma separator

	**Example:**
	``````lua
	HarukaLib:CommaifyNumber(123456789) -- "123,456,789"
	``````
]]
function HarukaLib:CommaifyNumber(num: number | string) : string
	if not num then return "" end

	num = tostring(num)

	local result = ""
	for i = 1, #num do
		result ..= string.sub(num, i, i)
		if (#num - i) % 3 == 0 and i ~= #num then result ..= "," end
	end

	return result
end


--[[
	Helper function to format a number of seconds into a string of time format

	**Example:**
	``````lua
	HarukaLib:TimeifyNumber(123) -- "02:03"
	``````
]]
function HarukaLib:TimeifyNumber(seconds: number, shouldScaleToMs: boolean?) : string
	if seconds == nil then return "??:??" end
	if seconds <= 0 then return "00:00" end

	local minutes = math.floor(seconds / 60)
	local secs = seconds % 60

	if not shouldScaleToMs then
		return string.format("%02d:%02d", minutes, secs)
	else
		local ms = seconds * 1000
		minutes = math.floor(ms / 60000)

		ms %= 60000
		seconds = math.floor(ms / 1000)

		ms %= 1000

		return string.format("%d:%02d.%03d", minutes, seconds, ms)
	end
end


--[[
	A quick shortcut to `string.sub(UUID, 1, 8)`

	Example Output: `123e4567-e89b-12d3-a456-426655440000`
]]
function HarukaLib:GenerateUUID() : string
	return string.sub(HttpService:GenerateGUID(false), 1, 8)
end


--[[
	Similar with `PartCache`, but a lot simpler and faster.

	Returns:
	```lua
	local pool = HarukaLib:CreatePartPool(obj, initialAmount)

	pool:Get()
	pool:Return(obj)
	```
]]
function HarukaLib:CreatePartPool(obj: Instance, initialAmount: number?, container: Folder?)
	container = container or Instance.new("Folder")
	container.Name = "PartPool_"..obj.Name.."_"..HarukaLib:GenerateUUID()
	container.Parent = workspace


	local DISTANT_CF = CFrame.new(Vector3.one * 1599 * 40)

	initialAmount = initialAmount or 1
	initialAmount = math.ceil(initialAmount)

	obj = obj:Clone()
	obj.Parent = container

	local pool = {
		Object = obj,
		Available = {},
	}
	for _ = 1, initialAmount do
		local clone = pool.Object:Clone()
		clone.Parent = container

		table.insert(pool.Available, clone)
	end

	function pool:Get()
		local i = #pool.Available
		local finalObj = pool.Available[i]
		if finalObj then
			finalObj = table.remove(pool.Available, i)
			return finalObj
		else
			local newObj = pool.Object:Clone()
			newObj.Parent = container

			return newObj
		end
	end
	function pool:Return(object: Instance)
		object.CFrame = DISTANT_CF

		table.insert(pool.Available, object)
	end
	function pool:Destroy()
		container:Destroy()
	end

	return pool
end


--[[
	A simple function of Queue
]]
function HarukaLib.Queue()
	local Queue = {}
	Queue.__index = Queue

	function Queue.new()
		local self = setmetatable({
			First = 0,
			Last = -1,
			Queue = {},
			Locked = false,

			ElementAdded = Signal.new(),

		}, Queue)

		return self
	end


	function Queue:IsEmpty() : boolean
		return self.First > self.Last
	end
	function Queue:GetItemsInQueue() : number
		return #self.Queue
	end

	function Queue:SetLockState(state: boolean)
		self.Locked = state
	end
	function Queue:IsLocked() : boolean
		return self.Locked
	end


	function Queue:Push(value: any)
		local last = self.Last + 1
		self.Last = last
		self.Queue[last] = value

		if not self.Locked then
			self.ElementAdded:Fire()
		end
	end
	function Queue:Pop() : any?
		if self:IsEmpty() then
			return nil
		end

		local first = self.First
		local value = self.Queue[first]
		self.Queue[first] = nil
		self.First = first + 1

		return value
	end

	function Queue:Destroy()
		self.ElementAdded:Destroy()
	end

	return Queue.new()
end


--[[
	A list of helper functions to manipulate table
]]
HarukaLib.TableUtils = TableUtils


--[[
	A quick helper function to emit particles
]]
function HarukaLib:EmitParticles(obj: Instance, childrenOnly: boolean?)
	if childrenOnly then
		for _, child: ParticleEmitter in obj:GetChildren() do
			if not child:IsA("ParticleEmitter") then continue end

			child:Emit(child:GetAttribute("EmitCount") or 0)
		end
	else
		for _, child: ParticleEmitter in obj:GetDescendants() do
			if not child:IsA("ParticleEmitter") then continue end

			child:Emit(child:GetAttribute("EmitCount") or 0)
		end
	end
end


--[[
	Quickly judge if it's a part
]]
function HarukaLib:IsBasePartType(obj: Instance) : boolean
	return obj:IsA("BasePart") or obj:IsA("UnionOperation") or obj:IsA("CornerWedgePart")
end


--[[
	Quickly return an empty part for mocking
]]
function HarukaLib:CreateMockPart() : BasePart
	local part = Instance.new("Part")
	part.Anchored = true
	part.Name = "MockPart"
	part.Size = Vector3.one
	part.Transparency = 1
	part.CanCollide = false
	part.CanTouch = false
	part.CastShadow = false
	part.CanQuery = false
	part.Massless = true
	part.EnableFluidForces = false
	part.CollisionGroup = "NoCollision"

	return part
end


--[[
	Quickly return an empty part for mocking
]]
function HarukaLib:CreateMockModel() : BasePart
	local model = Instance.new("Model")
	model.Name = "MockModel"

	local part = HarukaLib:CreateMockPart()
	part.Parent = model

	model.PrimaryPart = part

	return model
end


--[[
	Quickly set all particles of an object to a state
]]
function HarukaLib:SetParticleState(obj: Instance, state: boolean, childrenOnly: boolean?)
	if childrenOnly then
		for _, child: ParticleEmitter in obj:GetChildren() do
			if not child:IsA("ParticleEmitter") then continue end

			child.Enabled = state
		end
	else
		for _, child: ParticleEmitter in obj:GetDescendants() do
			if not child:IsA("ParticleEmitter") then continue end

			child.Enabled = state
		end
	end
end


--[[
	template for creating a new `Tween`, and destroying it after it's done
]]
function HarukaLib:CreateTween(instance: Instance, tweenInfo: TweenInfo, tweenProperties: { [string]: any })
	local tweenObj = TweenService:Create(instance, tweenInfo, tweenProperties)

	tweenObj.Completed:Once(function()
		tweenObj:Destroy()
	end)

	return tweenObj
end


--[[
	Toggles the Enabled property ParticleEmitters (and Beams if IncludeBeams is true)
	in (Parent) to (Value), or reverses the value if (Switch)
]]
function HarukaLib:ZonitoToggleParticles(instance: Instance, val: boolean, reverse: boolean, includeBeams: boolean, childrenOnly: boolean?)
	if childrenOnly then
		for _, v in instance:GetChildren() do
			if v:IsA("ParticleEmitter") then
				if reverse then
					v.Enabled = not v.Enabled
				else
					v.Enabled = val
				end
			end
			if includeBeams and (v:IsA("Beam")) or (v:IsA("Trail")) then
				if reverse then
					v.Enabled = not v.Enabled
				else
					v.Enabled = val
				end
			end
		end
	else
		for _, v in instance:GetDescendants() do
			if v:IsA("ParticleEmitter") then
				if reverse then
					v.Enabled = not v.Enabled
				else
					v.Enabled = val
				end
			end
			if includeBeams and (v:IsA("Beam")) or (v:IsA("Trail")) then
				if reverse then
					v.Enabled = not v.Enabled
				else
					v.Enabled = val
				end
			end
		end
	end
end


HarukaLib.RichTextFormatter = if script:FindFirstChild("HarukaRichTextFormatter") then require(script.HarukaRichTextFormatter) else nil


return HarukaLib
