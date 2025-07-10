--!nocheck

local Players = game:GetService("Players")
local SSS = game:GetService("ServerScriptService")

local ServerBindables = require(SSS.HarukaServer.Library.ServerBindables)


repeat task.wait() until workspace:GetAttribute("Haruka_ServerInited")


local function setup(plr: Player)
    ServerBindables.RToSpawnChar:Fire(plr)
end

for _, plr in Players:GetPlayers() do
	task.spawn(setup, plr)
end
Players.PlayerAdded:Connect(setup)
