--!nocheck

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

local Signals = require(ReplicatedStorage.Modules.Data.Signals)

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

    --// Map libs old
    local bindables = Instance.new("Folder")
    bindables.Name = "Bindables"
    bindables.Parent = ServerStorage

    local mapLibRFOLD = Instance.new("BindableFunction")
    mapLibRFOLD.Name = "GetMapLib"
    mapLibRFOLD.Parent = bindables
    mapLibRFOLD.OnInvoke = function()
        Signals.CreateHint:Fire("This map is using the old maplib, read console for more info.", "red", "5")

        return function ()
            return require(ReplicatedStorage.Modules.Data.MapLib)
        end
    end

    --// Map runtime v1.0 compatibility
    local runtime = ReplicatedStorage.Modules.Data.Runtime:Clone()
    runtime.Parent = ServerScriptService
end
setupMapLib()

--// Wait for map to load
repeat task.wait() until workspace:WaitForChild("Map", 999)
repeat task.wait() until workspace.Map:GetAttribute("IsLoaded")

local effectScript = workspace.Map:FindFirstChild("EffectScript") :: LocalScript
if not effectScript then
    warn("EffectScript not found!")
    return
end

effectScript.Parent = Players.LocalPlayer.PlayerScripts

repeat RunService.RenderStepped:Wait() until workspace.Map:GetAttribute("ScriptsLoaded")

effectScript.Disabled = false
