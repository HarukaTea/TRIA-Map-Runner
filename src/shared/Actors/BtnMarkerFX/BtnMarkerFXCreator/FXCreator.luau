--!nocheck

local CS = game:GetService("CollectionService")
local TS = game:GetService("TweenService")

local wait = task.wait

local buttonRotateTween = TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, -1, true, 0)

local function locatorFX(marker: BillboardGui)
    wait()
    repeat wait() until marker:GetAttribute("Active")

    TS:Create(marker.Corners, buttonRotateTween, { Rotation = -720 }):Play()
end

for _, marker in CS:GetTagged("ButtonMarker") do
    locatorFX(marker)
end
CS:GetInstanceAddedSignal("ButtonMarker"):Connect(locatorFX)

return true
