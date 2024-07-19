--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local HarukaLib = require(RepS.Modules.Packages.HarukaLib)

local Add, Empty = HarukaLib.Bin()

local char = script.Parent.Parent :: Model

Add(char.Humanoid.Touched:Connect(function(hit: BasePart)
    if hit and hit:GetAttribute("_action") == "Teleport" then

        if not hit:FindFirstChild("Destination") then return end

        char.PrimaryPart.CFrame = hit.Destination.CFrame

        if hit:GetAttribute("SetCameraFront") then
            local camera = workspace.CurrentCamera

            camera.CFrame = CFrame.new(camera.CFrame.Position, camera.CFrame.Position + hit.Destination.CFrame.LookVector)
        end
    end
end))

--// Clear
char.Humanoid.Died:Once(Empty)
