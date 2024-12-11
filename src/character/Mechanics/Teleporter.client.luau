--!nocheck

local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")

local HarukaLib = require(RepS.Shared.Shared.HarukaLib)
local MapLib = require(RepS.Shared.Library.MapLib)

local TeleportFeature = MapLib:GetFeature("Teleport")

local Add, Empty = HarukaLib.Bin()

local plr = Players.LocalPlayer
local char = script:FindFirstAncestorOfClass("Model")

Add(char.Humanoid.Touched:Connect(function(hit: BasePart)
    if hit and hit:GetAttribute("_action") == "Teleport" then
        if not hit:FindFirstChild("Destination") then return end

        TeleportFeature:Teleport(plr, hit.Destination.CFrame, hit:GetAttribute("SetCameraFront"))
    end
end))

--// Clear
char.Humanoid.Died:Once(Empty)
