--!strict
--!native
--!optimize 2

local RunService = game:GetService("RunService")

if RunService:IsServer() then
	require(script.Server.ServerProcess).start()

	return require(script.Server)
else
	require(script.Client.ClientProcess).start()

	return require(script.Client)
end
