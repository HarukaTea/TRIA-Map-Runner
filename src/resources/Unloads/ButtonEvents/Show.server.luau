--!nocheck

local SSS = game:GetService("ServerScriptService")
local SS = game:GetService("ServerStorage")

local Signals = require(SSS.Server.Modules.Library.ServerSignals)

local DelayCheck = require(SS.Resources.Unloads.ButtonEvents._DelayEvent)

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

	DelayCheck(script)

	local obj = script.Parent.Parent :: Instance
	if objList[obj.ClassName] then
		obj.CanCollide = true
		obj.Transparency = 0

	elseif obj:IsA("Model") then
		for _, child: Instance in obj:GetDescendants() do
			if objList[child.ClassName] then
				child.CanCollide = true
				child.Transparency = 0
			end
		end
	end
end)
