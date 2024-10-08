--!nocheck

local Players = game:GetService("Players")
local SSS = game:GetService("ServerScriptService")

local Signals = require(SSS.Modules.Data.ServerSignals)

--// Private

repeat task.wait() until workspace:GetAttribute("ServerInited")

local function setup(plr: Player)
    Signals.ReloadCharacter:Fire(plr)
end

for _, plr in Players:GetPlayers() do
	task.spawn(setup, plr)
end
Players.PlayerAdded:Connect(setup)
