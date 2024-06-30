--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local HarukaLib = require(RepS.Modules.Packages.HarukaLib)

local Add, Empty = HarukaLib.Bin()

repeat task.wait() until workspace:WaitForChild("Map", 999)

local MapLib = game.GetMapLib:Invoke()()
local map = MapLib.map

local char = script.Parent.Parent :: Model

Add(char.Humanoid.Touched:Connect(function(hit: BasePart)
    if hit and hit.Name == "ExitRegion" and not char:GetAttribute("IsSurvived") then
        char:SetAttribute("IsSurvived", true)
    end
end))
Add(HarukaLib:Hydrate(char, {
    ["Attr-IsSurvived"] = function(state: boolean)
        if state then
            local exitBlocks = {}

            for _, child: Instance in map:GetDescendants() do
                if child:IsA("BasePart") and child.Name == "ExitBlock" then
                    exitBlocks[#exitBlocks + 1] = child
                end
            end
            for _, child: Instance in map:GetDescendants() do
                if child:IsA("BasePart") and string.find(child.Name, "_Liquid") then
                    MapLib:SetLiquidType(child, "water")
                end
            end

            task.wait(0.5)
            for _, block: BasePart in exitBlocks do
                block.CanCollide = true
            end

            workspace.Sounds.SFXs.Survived:Play()
            MapLib:Alert("Survived", Color3.fromRGB(0, 255, 0), 4)
        end
    end
}))

--// Clear
char.Humanoid.Died:Once(function()
    Empty()
end)