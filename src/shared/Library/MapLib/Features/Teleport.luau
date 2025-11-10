
-- Copyright (C) 2025 Tria
-- This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
-- If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.


local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RS = game:GetService("RunService")
local SSS = game:GetService("ServerScriptService")

local Events = nil
if RS:IsServer() then
    Events = require(SSS.HarukaServer.Library.ServerEvents)
elseif RS:IsClient() then
    Events = require(ReplicatedStorage.HarukaShared.Library.Events)
end

local Teleport = {}

--[[
	This function can be used to teleport players.

	```lua
	--Teleports all players ingame to map.Destination and makes the camera face the front.
	local PlayersFeature = MapLib:GetFeature("Players")
	local TeleportFeature = MapLib:GetFeature("Teleport")

	for _, player in pairs(PlayersFeature:GetPlayers()) do
		TeleportFeature:Teleport(player, map.Destination.Position, true)
	end
	```
]]
function Teleport:Teleport(
    players: { Player? } | Player,
    endingPosition: CFrame | Vector3,
    faceFront: boolean?
)

    if RS:IsClient() then
        if not players then return end
        if not endingPosition then return end
        if not faceFront then faceFront = false end

        if typeof(players) ~= "table" then players = { players } end
        if typeof(endingPosition) ~= "CFrame" then endingPosition = CFrame.new(endingPosition) end

        for _, plr: Player in players do
            if plr and plr.Character then
                local char = plr.character

                char:PivotTo(CFrame.lookAt(endingPosition.Position, endingPosition.Position + endingPosition.LookVector))
                if faceFront then
                    workspace.CurrentCamera.CFrame = CFrame.fromOrientation(
                        -math.pi / 4,
                        (select(2, char.PrimaryPart.CFrame:ToOrientation())),
                        0
                    ) + endingPosition.Position
                end
            end
        end
    else
        for _, player: Player in players do
            Events.TeleportPlayer.Fire(player, {
                Player = player,
                Destination = endingPosition,
                FaceFront = faceFront
            })
        end
    end
end


if RS:IsClient() then
    Events.TeleportPlayer.On(function(data)
        local player, destination, faceFront = data.Player, data.Destination, data.FaceFront

        Teleport:Teleport(player, destination, faceFront)
    end)
end

return Teleport