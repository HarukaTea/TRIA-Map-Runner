--!nocheck

local RS = game:GetService("RunService")
local SSS = game:GetService("ServerScriptService")

local Events = nil
if RS:IsServer() then
    Events = require(SSS.HarukaServer.Library.ServerEvents)
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

return Teleport
