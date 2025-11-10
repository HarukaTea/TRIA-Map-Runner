
-- Copyright (C) 2025 Tria
-- This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
-- If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.


local PlayersService = game:GetService("Players")

local Players = {}

--[[
    This function can be used to get all players in the current round.

    ``````lua
    --Teleports all players ingame to map.Destination.
    local PlayersFeature = Maplib:GetFeature("Players")
    local TeleportFeature = Maplib:GetFeature("Teleport")

    for _, player in pairs(PlayersFeature:GetPlayers()) do
        TeleportFeature:Teleport(player, map.Destination.Position)
    end
    ``````
]]
function Players:GetPlayers() : { Player }
    --- ignore this, just make it return all players cuz of testing environment
    return PlayersService:GetPlayers()
end

--[[
    This function can be used to get all the players
    which are in a radius from a position.

    ``````lua
    --Teleports all players that are within 5 studs from map.Spawn.
    local PlayersFeature = Maplib:GetFeature("Players")
    local TeleportFeature = Maplib:GetFeature("Teleport")

    for _, player in pairs(PlayersFeature:GetPlayersInRadius(map.Spawn.Position, 5)) do
        TeleportFeature:Teleport(player, map.Destination.Position)
    end
    ``````
]]
function Players:GetPlayersInRadius(position: Vector3, radius: number) : { Player? }
    if not position then return {} end
    if not radius then return {} end

    local playersInRadius = {}
    for _, plr: Player in PlayersService:GetPlayers() do
        local distance = plr:DistanceFromCharacter(position)

        if distance <= radius and distance > 0 then
            table.insert(playersInRadius, plr)
        end
    end

    return playersInRadius
end

return Players