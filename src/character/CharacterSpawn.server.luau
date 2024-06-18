--!nocheck

repeat task.wait() until workspace:WaitForChild("Map")

local char = script.Parent :: Model
local spawnLocation = workspace.Map.Special.Spawn :: BasePart

char.PrimaryPart = char.Humanoid.RootPart
char:PivotTo(spawnLocation.CFrame)

workspace.CurrentCamera.CFrame = char.PrimaryPart.CFrame
