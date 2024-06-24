--!nocheck

local char = script.Parent.Parent :: Model

char.Humanoid.RootPart.Touched:Connect(function(hit: BasePart)
    if hit and hit:GetAttribute("_action") == "WalkSpeed" then
        char.Humanoid.WalkSpeed = hit:GetAttribute("WalkSpeed") or 20
    end
end)
