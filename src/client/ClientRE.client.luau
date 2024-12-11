--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Events = require(RepS.Shared.Library.Events)
local MapLib = require(RepS.Shared.Library.MapLib)

local TeleportFeature = MapLib:GetFeature("Teleport")


Events.TeleportPlayer.SetCallback(function(data)
    local player, destination, faceFront = data.Player, data.Destination, data.FaceFront

    TeleportFeature:Teleport(player, destination, faceFront)
end)


Events.MapRoundEnding.SetCallback(function(_)
    MapLib.RoundEnding:Fire()
end)
