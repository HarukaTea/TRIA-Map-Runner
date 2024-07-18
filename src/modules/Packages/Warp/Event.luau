--!nocheck

local RunService = game:GetService("RunService")

if RunService:IsServer() then
	if not script:FindFirstChild("Reliable") then
		Instance.new("RemoteEvent", script).Name = "Reliable"
	end

elseif not script:FindFirstChild("Reliable") then
	repeat task.wait() until script:FindFirstChild("Reliable")
end

return script.Reliable
