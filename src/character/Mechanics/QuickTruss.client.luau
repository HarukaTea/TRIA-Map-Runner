--!nocheck

local char = script.Parent.Parent :: Model

char.Humanoid.Jumping:Connect(function(isJumping: boolean)
    if isJumping then
        local vel = char.PrimaryPart.AssemblyLinearVelocity

        char.PrimaryPart.AssemblyLinearVelocity = Vector3.new(vel.X, char.Humanoid.JumpPower * 1.1, vel.Z)
    end
end)
