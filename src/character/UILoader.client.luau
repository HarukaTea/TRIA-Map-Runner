--!nocheck

local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")

local Spawn = require(RepS.Modules.Packages.Spawn)

local plr = Players.LocalPlayer

local uiModules = {
    RepS.Modules.UI.Hints,
    RepS.Modules.UI.HarukaPanel
}
for _, module: ModuleScript in uiModules do
    Spawn(function() require(module)(plr) end)
end
