--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local HarukaLib = require(RepS.Shared.Shared.HarukaLib)

local Add, Empty = HarukaLib.Bin()

local char = script:FindFirstAncestorOfClass("Model")

Add(char.Humanoid.Touched:Connect(function(hit: BasePart)
    if not hit then return end

    local action = hit:GetAttribute("_action") :: string?

    if action == "WalkSpeed" then
        char.Humanoid.WalkSpeed = hit:GetAttribute("WalkSpeed") or 20

    elseif action == "JumpPower" then
        char.Humanoid.JumpPower = hit:GetAttribute("JumpPower") or 50

    elseif action == "Kill" then
        char.Humanoid.Health = 0
    end
end))

--// Clear
char.Humanoid.Died:Once(Empty)
