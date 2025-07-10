--!nocheck

local CS = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")


local Promise = require(ReplicatedStorage.HarukaShared.Shared.Promise)


local wait = task.wait
local buttonRotateTween = TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, -1, true, 0)



local function locatorFX(marker: BillboardGui)
    wait()
    repeat wait() until marker:GetAttribute("Active")

    TS:Create(marker.Corners, buttonRotateTween, { Rotation = -720 }):Play()
end

for _, marker in CS:GetTagged("ButtonMarker") do
    Promise.try(locatorFX, marker)
end
CS:GetInstanceAddedSignal("ButtonMarker"):Connect(locatorFX)

