
local RepS = game:GetService("ReplicatedStorage")

local Signal = require(RepS.HarukaShared.Shared.Signal)

local WaterLib = {}

WaterLib._WaterAdded = Signal.new()
WaterLib._Waters = {}

function WaterLib:_BindWater(water: BasePart)
    if water:IsA("BasePart") and (string.find(water.Name, "_Liquid") or string.find(water.Name, "_Gas")) then
        table.insert(WaterLib._Waters, water)

        WaterLib._WaterAdded:Fire(water)
    end
end
function WaterLib:_UnbindWater(water: BasePart)
    if water:IsA("BasePart") and (string.find(water.Name, "_Liquid") or string.find(water.Name, "_Gas")) then
        table.remove(WaterLib._Waters, table.find(WaterLib._Waters, water))
    end
end

workspace.DescendantAdded:Connect(function(descendant: Instance)
    WaterLib:_BindWater(descendant)
end)
workspace.DescendantRemoving:Connect(function(descendant: Instance)
    WaterLib:_UnbindWater(descendant)
end)
for _, child: Instance in workspace:GetDescendants() do
    WaterLib:_BindWater(child)
end

return WaterLib