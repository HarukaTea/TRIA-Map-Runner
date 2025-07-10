--!nocheck

local SSS = game:GetService("ServerScriptService")
local SS = game:GetService("ServerStorage")

local Bindables = require(SSS.HarukaServer.Library.ServerBindables)
local DelayCheck = require(SS.HarukaRes.Unloads.ButtonEvents._DelayEvent)


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

Bindables.BtnPressed:Connect(function(btnIndex: string)
	if btnIndex ~= realIndex then return end

	DelayCheck(script)

	local obj = script.Parent.Parent :: Instance
	if objList[obj.ClassName] then
		obj.CanCollide = false
		obj.Transparency = 1

	elseif obj:IsA("Model") then
		for _, child: Instance in obj:GetDescendants() do
			if objList[child.ClassName] then
				child.CanCollide = false
				child.Transparency = 1
			end
		end
	end
end)
