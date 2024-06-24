--!nocheck

repeat task.wait() until workspace:WaitForChild("Map")

local char = script.Parent :: Model
local spawnLocation = workspace.Map.Special.Spawn :: BasePart

char.PrimaryPart = char.Humanoid.RootPart
char.Humanoid.BreakJointsOnDeath = false
char:PivotTo(spawnLocation.CFrame)

workspace.CurrentCamera.CFrame = char.PrimaryPart.CFrame

--// Clear
char.Humanoid.Died:Once(function()
    workspace.Map:Destroy()

    workspace.Sounds.Lobby:Play()
end)
