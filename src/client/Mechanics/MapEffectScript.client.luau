--!nocheck

local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local RS = game:GetService("RunService")
local SSS = game:GetService("ServerScriptService")
local SS = game:GetService("ServerStorage")

local Signals = require(RepS.Shared.Library.Signals)

--// setup maplib
local function setupMapLib()
    local function _returnMapLib()
        return function ()
            return require(RepS.Shared.Library.MapLib)
        end
    end

    local mapLibRF = Instance.new("BindableFunction")
    mapLibRF.Name = "GetMapLib"
    mapLibRF.Parent = game
    mapLibRF.OnInvoke = _returnMapLib

    --// Map libs old
    local bindables = Instance.new("Folder")
    bindables.Name = "Bindables"
    bindables.Parent = SS

    local mapLibRFOLD = Instance.new("BindableFunction")
    mapLibRFOLD.Name = "GetMapLib"
    mapLibRFOLD.Parent = bindables
    mapLibRFOLD.OnInvoke = function()
        Signals.CreateHint:Fire("This map is using the old maplib, read console for more info.", "red", "5")

        _returnMapLib()
    end

    --// Map runtime v1.0 compatibility
    local runtime = RepS.Shared.Library.Runtime:Clone()
    runtime.Parent = SSS


    workspace:SetAttribute("MapLibClientLoaded", true)
end
setupMapLib()

--// Wait for map to load
repeat task.wait() until workspace:GetAttribute("MapPreInited")
repeat task.wait() until workspace.Map:GetAttribute("IsLoaded")

local effectScript = workspace.Map:FindFirstChild("EffectScript") :: LocalScript
if not effectScript then
    warn("[TRIA MAP TESTER] EffectScript not found!")
    return
end

effectScript.Parent = Players.LocalPlayer.PlayerScripts

repeat RS.RenderStepped:Wait() until workspace:GetAttribute("MapScriptsInited")

effectScript.Disabled = false
