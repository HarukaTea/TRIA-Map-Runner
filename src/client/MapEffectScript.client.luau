--!nocheck

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

--// setup maplib
local function setupMapLib()
    local mapLibRF = Instance.new("BindableFunction")
    mapLibRF.Name = "GetMapLib"
    mapLibRF.Parent = game
    mapLibRF.OnInvoke = function()
        return function ()
            return require(ReplicatedStorage.Modules.Data.MapLib)
        end
    end
end
setupMapLib()

--// Wait for map to load
repeat task.wait() until workspace:WaitForChild("Map", 999)

local Signals = require(ReplicatedStorage.Modules.Data.Signals)

local effectScript = workspace.Map:FindFirstChild("EffectScript") :: LocalScript
if not effectScript then
    Signals.CreateHint:Fire("EffectScript not found!")

    warn("EffectScript not found!")
    return
end

effectScript.Parent = Players.LocalPlayer.PlayerScripts

repeat RunService.RenderStepped:Wait() until workspace.Map:GetAttribute("ScriptsLoaded")

effectScript.Disabled = false
