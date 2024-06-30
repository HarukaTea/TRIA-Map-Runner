--!nocheck

local SSS = game:GetService("ServerScriptService")

local Signals = require(SSS.Modules.Data.ServerSignals)

local index = string.sub(script.Parent.Name, 7)
local realIndex = string.gsub(index, "%a", "")

Signals.BtnPressed:Connect(function(btnIndex: string)
	if btnIndex ~= realIndex then return end

	if script.Parent:FindFirstChild("_Delay") then
		local delayTime = script.Parent["_Delay"].Value :: number
		task.wait(delayTime)
	end

	local obj = script.Parent :: Sound

	obj:Play()
end)
