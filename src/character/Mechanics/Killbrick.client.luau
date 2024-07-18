--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local HarukaLib = require(RepS.Modules.Packages.HarukaLib)

local Add, Empty = HarukaLib.Bin()

local char = script.Parent.Parent :: Model

Add(char.Humanoid.Touched:Connect(function(hit: BasePart)
    if hit and hit:GetAttribute("_action") == "Kill" then
        char.Humanoid.Health = 0
    end
end))

--// Clear
char.Humanoid.Died:Once(Empty)
