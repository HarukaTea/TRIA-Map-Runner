--!nocheck

local Lighting = game:GetService("Lighting")
local RepS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")

local HarukaLib = require(RepS.Modules.Packages.HarukaLib)
local WaterLib = require(RepS.Modules.Data.WaterLib)

local currentWater: BasePart = nil

repeat task.wait() until workspace:WaitForChild("Map", 999)
repeat task.wait() until workspace.Map:GetAttribute("IsLoaded")

--// Apply sound
local function _bindSound(sound: Sound)
    if sound:IsA("Sound") then sound.SoundGroup = SoundService.Underwater end
end

for _, child: Instance in workspace:GetDescendants() do
    _bindSound(child)
end
workspace.DescendantAdded:Connect(_bindSound)
workspace.ChildAdded:Connect(_bindSound)

--- update
RunService.RenderStepped:Connect(function()
    currentWater = HarukaLib:IsInRegion(workspace.CurrentCamera.CFrame.Position, WaterLib._Waters)

    local isInWater = if currentWater then true else false

    Lighting.WaterBlur.Enabled = isInWater
    Lighting.WaterColor.Enabled = isInWater

    SoundService.Underwater.Equalizer.Enabled = isInWater
    Lighting.WaterColor.TintColor = if isInWater then Color3.new(1, 1, 1):Lerp(currentWater.Color, 0.65) else Color3.new(1, 1, 1)
end)