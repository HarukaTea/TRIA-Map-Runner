
local Lighting = game:GetService("Lighting")
local RepS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")

local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local WaterLib = require(RepS.HarukaShared.Library.WaterLib)

local currentWater: BasePart = nil

repeat task.wait() until workspace:GetAttribute("Haruka_MapPreloadRun")
repeat task.wait() until workspace.Map:GetAttribute("IsLoaded")


local function _bindSound(sound: Sound)
    if sound:IsA("Sound") then sound.SoundGroup = SoundService.Underwater end
end
local function _bindMesh(water: BasePart)
    if water:GetAttribute("Meshless") then return end
    if string.find(water.Name, "_Gas") then return end

    if not water:FindFirstChild("WaterMesh") then
        local mesh = Instance.new("BlockMesh")
        mesh.Name = "WaterMesh"
        mesh.Scale = Vector3.new(1, 0, 1)
        mesh.Offset = Vector3.new(0, water.Size.Y / 2, 0)
        mesh.Parent = water
    end
end


for _, child: Instance in workspace:GetDescendants() do
    _bindSound(child)
end
for _, child: BasePart in WaterLib._Waters do
    _bindMesh(child)
end
WaterLib._WaterAdded:Connect(_bindMesh)
workspace.DescendantAdded:Connect(_bindSound)
workspace.ChildAdded:Connect(_bindSound)


RunService.RenderStepped:Connect(function()
    currentWater = HarukaLib:IsInRegion(workspace.CurrentCamera.CFrame.Position, WaterLib._Waters)

    local isInWater = if currentWater then true else false
    if currentWater and string.find(currentWater.Name, "_Gas") then isInWater = false end

    Lighting.WaterBlur.Enabled = isInWater
    Lighting.WaterColor.Enabled = isInWater

    SoundService.Underwater.Equalizer.Enabled = isInWater
    Lighting.WaterColor.TintColor = if isInWater then Color3.new(1, 1, 1):Lerp(currentWater.Color, 0.65) else Color3.new(1, 1, 1)
end)