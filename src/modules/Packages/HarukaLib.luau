--!nocheck

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Spawn = require(ReplicatedStorage.Modules.Packages.Spawn)

local HarukaLib = {}


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


function HarukaLib.Bin()
	local bin = {}

	local function doCleanup(item: any)
		if typeof(item) == "Instance" then
			item:Destroy()

		elseif typeof(item) == "RBXScriptConnection" then
			item:Disconnect()

		elseif typeof(item) == "function" then
			Spawn(item)

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

return HarukaLib
