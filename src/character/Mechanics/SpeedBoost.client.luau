--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local HarukaLib = require(RepS.Modules.Packages.HarukaLib)

local Add, Empty = HarukaLib.Bin()

local char = script.Parent.Parent :: Model

Add(char.Humanoid.Touched:Connect(function(hit: BasePart)
    if hit and hit:GetAttribute("_action") == "WalkSpeed" then
        char.Humanoid.WalkSpeed = hit:GetAttribute("WalkSpeed")
    end
end))

--// Clear
char.Humanoid.Died:Once(function()
    Empty()
end)
