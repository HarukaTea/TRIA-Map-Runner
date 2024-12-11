--!nocheck

local Players = game:GetService("Players")
local SSS = game:GetService("ServerScriptService")
local SS = game:GetService("ServerStorage")

local Signals = require(SSS.Server.Modules.Library.ServerSignals)
local TEMPLATE = require(SSS.Server.Modules.Library.CharTemplate)

repeat task.wait() until workspace:GetAttribute("MapPreInited")

local char = script:FindFirstAncestorOfClass("Model")
local spawnLocation = workspace.Map.Special.Spawn :: BasePart
local plr = Players:GetPlayerFromCharacter(char)

local function setup()
    char.PrimaryPart = char.Humanoid.RootPart

    char.Humanoid.UseJumpPower = true
    char.Humanoid.WalkSpeed = 20
    char.Humanoid.JumpPower = 50

    char:PivotTo(spawnLocation.CFrame * CFrame.new(0, 3, 0))

    char.PrimaryPart.Anchored = true

    for attr: string, val: any in TEMPLATE do
        char:SetAttribute(attr, val)
    end

    --// Give noclip
    local noclip = Instance.new("HopperBin")
    noclip.Name = "Noclip"
    noclip:SetAttribute("Speed", 60)
    SS.Resources.Unloads.NoclipControl:Clone().Parent = noclip

    noclip.Parent = plr.Backpack

    repeat task.wait() until workspace.Map:GetAttribute("IsStarted")

    char.PrimaryPart.Anchored = false

    char:SetAttribute("AllowAirDive", workspace.Map:GetAttribute("AllowAirDive"))
    char:SetAttribute("AllowSlide", workspace.Map:GetAttribute("AllowSlide"))

    char:SetAttribute("CharDataLoaded", true)
end
setup()


local function clear()
    plr.Backpack:ClearAllChildren()

    task.delay(3, function()
        Signals.ReloadCharacter:Fire(plr)
    end)
end
char.Humanoid.Died:Once(clear)
