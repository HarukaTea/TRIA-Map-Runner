--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local WaterLib = require(RepS.Modules.Data.WaterLib)

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

for _, child: BasePart in WaterLib._Waters do
    _bindMesh(child)
end
WaterLib._WaterAdded:Connect(_bindMesh)
