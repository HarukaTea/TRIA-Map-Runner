--!nocheck

local char = script.Parent.Parent :: Model

char.Humanoid.Touched:Connect(function(hit: BasePart)
    if hit and hit:GetAttribute("_action") == "JumpPower" then
        char.Humanoid.JumpPower = hit:GetAttribute("JumpPower") or 50
    end
end)
