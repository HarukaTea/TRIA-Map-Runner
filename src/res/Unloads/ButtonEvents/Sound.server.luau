--!nocheck

local SSS = game:GetService("ServerScriptService")
local SS = game:GetService("ServerStorage")

local Bindables = require(SSS.HarukaServer.Library.ServerBindables)
local DelayCheck = require(SS.HarukaRes.Unloads.ButtonEvents._DelayEvent)


local index = string.sub(script.Parent.Name, 7)
local realIndex = string.gsub(index, "%a", "")

Bindables.BtnPressed:Connect(function(btnIndex: string)
	if btnIndex ~= realIndex then return end

	DelayCheck(script)

	local obj = script.Parent :: Sound
	if not obj:IsA("Sound") then return end

	obj:Play()
end)
