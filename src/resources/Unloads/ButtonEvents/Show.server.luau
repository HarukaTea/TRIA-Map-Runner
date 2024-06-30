--!nocheck

local SSS = game:GetService("ServerScriptService")

local Signals = require(SSS.Modules.Data.ServerSignals)

local objList = {
	["BasePart"] = true,
	["Part"] = true,
	["UnionOperation"] = true,
	["TrussPart"] = true,
	["WedgePart"] = true,
	["CornerWedgePart"] = true
}

local index = string.sub(script.Parent.Name, 6)
local realIndex = string.gsub(index, "%a", "")

Signals.BtnPressed:Connect(function(btnIndex: string)
	if btnIndex ~= realIndex then return end

	if script.Parent:FindFirstChild("_Delay") then
		local delayTime = script.Parent["_Delay"].Value :: number
		task.wait(delayTime)
	end

	local obj = script.Parent.Parent :: Instance
	if objList[obj.ClassName] then
		obj.CanCollide = true
		obj.Transparency = 0

	elseif obj:IsA("Model") then
		for _, child in obj:GetDescendants() do
			if objList[child.ClassName] then
				obj.CanCollide = true
				obj.Transparency = 0
			end
		end
	end
end)