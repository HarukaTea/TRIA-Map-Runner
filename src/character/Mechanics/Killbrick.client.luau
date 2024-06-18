--!nocheck

local char = script.Parent.Parent :: Model

char.Humanoid.Touched:Connect(function(hit)
    if hit and hit:GetAttribute("_action") == "Kill" then
        char.Humanoid.Health = 0
    end
end)
