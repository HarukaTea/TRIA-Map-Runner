--!nocheck

local RunService = game:GetService("RunService")
local RepS = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Promise = require(RepS.Modules.Packages.Promise)

local HarukaLib = {}


function HarukaLib:AddAttr(obj: Instance, attribute: string, val: number)
	if obj:GetAttribute(attribute) == nil then obj:SetAttribute(attribute, 0) end

	obj:SetAttribute(attribute, obj:GetAttribute(attribute) + val)
end


function HarukaLib:ClearAllAttributes(obj: Instance)
	for attribute, _ in obj:GetAttributes() do obj:SetAttribute(attribute, nil) end
end


function HarukaLib:IsInRegion(position: Vector3, regions: table) : BasePart
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


function HarukaLib:Hydrate(obj: Instance, props: table)
	local Add, Empty = HarukaLib.Bin()

	for prop, func in props do
		if string.find(prop, "Attr") then
			local _, endPos = string.find(prop, "Attr")
			local attr = string.sub(prop, endPos + 2)

			func(obj:GetAttribute(attr))

			Add(obj:GetAttributeChangedSignal(attr):Connect(function()
				func(obj:GetAttribute(attr))
			end))

		elseif string.find(prop, "Prop") then
			local _, endPos = string.find(prop, "Prop")
			local propName = string.sub(prop, endPos + 2)

			func(obj[propName])

			Add(obj:GetPropertyChangedSignal(propName):Connect(function()
				func(obj[propName])
			end))
		end
	end

	return Empty
end



function HarukaLib.Bin()
	local bin = {}

	local function doCleanup(item: any)
		if typeof(item) == "Instance" then
			item:Destroy()

		elseif typeof(item) == "RBXScriptConnection" then
			item:Disconnect()

		elseif typeof(item) == "function" then
			task.spawn(item)

		elseif typeof(item) == "thread" then
			if item then task.cancel(item) end

		elseif typeof(item) == "table" then
			if typeof(item.destroy) == "function" then
				item:destroy()

			elseif typeof(task.Destroy) == "function" then
				item:Destroy()

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
		doCleanup(bin)

		table.clear(bin)
	end
end


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


function HarukaLib:UITweenOut(ui: GuiObject, delaySec: number?)
	delaySec = delaySec or 0

	local transparencyProperties = {
		"BackgroundTransparency",
		"TextTransparency",
		"TextStrokeTransparency",
		"Transparency",
		"ImageTransparency",
		"GroupTransparency",
		"ScrollBarImageTransparency"
	}
	local tweenObjs = ui:GetDescendants()
	table.insert(tweenObjs, ui)


	local function _tweenGoal(obj: GuiObject, attr: string, tweenProps: table)
		if attr == "Transparency" and not obj:IsA("UIStroke") then return end

		pcall(function()
			local hasAttr = obj[attr]

			if hasAttr then tweenProps[attr] = 1 end
		end)
		pcall(function()
			obj.Interactable = false
		end)
	end
	local function _startTween(obj: GuiObject, tweenProps: table)
		if not obj then return end
		if not obj.Parent then return end

		TweenService:Create(obj, TweenInfo.new(1), tweenProps):Play()
	end

	for _, obj in tweenObjs do
		local tweenProps = {}
		for _, attr in transparencyProperties do
			_tweenGoal(obj, attr, tweenProps)
		end

		if delaySec > 0 then
			Promise.delay(delaySec):andThenCall(_startTween, obj, tweenProps)
		else
			_startTween(obj, tweenProps)
		end
	end
end


function HarukaLib:CombineRbxId(id: string?) : string
    if not id then
        warn("[ClientUtil]: Invalid Id")
        return "rbxassetid://0"
    end

    return "rbxassetid://".. id
end


function HarukaLib:ConvertTime(num: number) : string
	local ms = num * 1000
	local minutes = math.floor(ms / 60000)

	ms %= 60000
	local seconds = math.floor(ms / 1000)

	ms %= 1000

	return string.format("%d:%02d.%03d", minutes, seconds, ms)
end

return HarukaLib
