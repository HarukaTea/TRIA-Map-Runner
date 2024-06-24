--!nocheck

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// setup maplib
local mapLibRF = Instance.new("BindableFunction")
mapLibRF.Name = "GetMapLib"
mapLibRF.Parent = game
mapLibRF.OnInvoke = function()
    return function ()
        return require(ReplicatedStorage.Modules.Data.MapLib)
    end
end

repeat task.wait() until workspace:WaitForChild("Map")

local Signals = require(ReplicatedStorage.Modules.Data.Signals)

local effectScript = workspace.Map:FindFirstChild("EffectScript") :: LocalScript
if not effectScript then
    Signals.CreateHint:Fire("EffectScript not found!")
    return
end

effectScript.Parent = Players.LocalPlayer.PlayerScripts
effectScript.Disabled = false
