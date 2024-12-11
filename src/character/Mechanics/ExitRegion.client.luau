--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local HarukaLib = require(RepS.Shared.Shared.HarukaLib)
local WaterLib = require(RepS.Shared.Library.WaterLib)
local Signals = require(RepS.Shared.Library.Signals)

local Add, Empty = HarukaLib.Bin()

repeat task.wait() until workspace:GetAttribute("MapPreInited")

local MapLib = game.GetMapLib:Invoke()()
local map = MapLib.map

local char = script:FindFirstAncestorOfClass("Model")

local touchCD = false
Add(char.Humanoid.RootPart.Touched:Connect(function(hit: BasePart)
    if hit and hit.Name == "ExitRegion" and not char:GetAttribute("IsSurvived") then
        if touchCD then return end

        touchCD = true
        task.delay(0.5, function()
            touchCD = false
        end)

        local check = true

        for _, button: Model in map.Special.Button:GetChildren() do
            if button:IsA("Model") and string.find(button.Name, "_Button") then
                if not button:GetAttribute("Hit") then check = false break end
            end
        end

        if not check then
            Signals.CreateHint:Fire("You need to press all buttons first!", "yellow", 4)
            return
        end

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
            for _, child: Instance in WaterLib._Waters do
                if child and child:GetAttribute("Type") ~= "water" and not string.find(child.Name, "_Gas") then
                    MapLib:SetLiquidType(child, "water")
                end
            end

            workspace.Sounds.SFXs.Survived:Play()
            MapLib:Alert("Survived", "green", 4)

            task.wait(0.5)
            for _, block: BasePart in exitBlocks do
                block.CanCollide = true
            end
        end
    end
}))

--// Clear
char.Humanoid.Died:Once(Empty)