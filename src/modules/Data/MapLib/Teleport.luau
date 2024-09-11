--!nocheck

local RunService = game:GetService("RunService")

local Teleport = {}

--[[
    This function can be used to teleport players.

    ``````lua
    --Teleports all players ingame to map.Destination and makes the camera face the front.
    local PlayersFeature = Maplib:GetFeature("Players")
    local TeleportFeature = Maplib:GetFeature("Teleport")

    for _, player in pairs(PlayersFeature:GetPlayers()) do
        TeleportFeature:Teleport(player, map.Destination.Position, true)
    end
    ``````
]]
function Teleport:Teleport(
    players: { Player? } | Player,
    endingPosition: CFrame | Vector3,
    faceFront: boolean?
)

    if RunService:IsClient() then
        if not players then return end
        if not endingPosition then return end
        if not faceFront then faceFront = false end

        if typeof(players) ~= "table" then players = { players } end
        if typeof(endingPosition) ~= "CFrame" then endingPosition = CFrame.new(endingPosition) end

        for _, plr: Player in players do
            if plr and plr.Character then
                plr.Character:PivotTo(endingPosition)

                if faceFront then
                    local camera = workspace.CurrentCamera
                    camera.CFrame = CFrame.new(camera.CFrame.Position, camera.CFrame.Position + endingPosition.LookVector)
                end
            end
        end
    end
end

return Teleport
