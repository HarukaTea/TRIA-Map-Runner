--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local HarukaLib = require(RepS.Modules.Packages.HarukaLib)

local Add, Empty = HarukaLib.Bin()

local char = script.Parent.Parent :: Model

Add(char.Humanoid.Jumping:Connect(function(isJumping: boolean)
    if isJumping then
        local vel = char.PrimaryPart.AssemblyLinearVelocity

        char.PrimaryPart.AssemblyLinearVelocity = Vector3.new(vel.X, char.Humanoid.JumpPower * 1.1, vel.Z)
    end
end))

--// Clear
char.Humanoid.Died:Once(function()
    Empty()
end)
