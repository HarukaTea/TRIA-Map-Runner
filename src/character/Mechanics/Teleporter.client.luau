--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Signals = require(RepS.Modules.Data.Signals)

local char = script.Parent.Parent :: Model

char.Humanoid.Touched:Connect(function(hit: BasePart)
    if hit and hit:GetAttribute("_action") == "Teleport" then

        if not hit:FindFirstChild("Destination") then
            Signals.CreateHint:Fires("Can't find destination part! Did you forget that?", nil, 6)
            return
        end

        char:PivotTo(hit.Destination.CFrame)

        if hit:GetAttribute("SetCameraFront") then
            local camera = workspace.CurrentCamera

            camera.CFrame = CFrame.new(camera.CFrame.Position, camera.CFrame.Position + hit.Destination.CFrame.LookVector)
        end
    end
end)
