--!nocheck

local LightingService = game:GetService("Lighting")
local RepS = game:GetService("ReplicatedStorage")
local RS = game:GetService("RunService")

local Events = nil
if RS:IsClient() then
    Events = require(RepS.Shared.Library.Events)
end

local Lighting = {}

--[[
    This function can to be used to change the lighting of a map mid round.

    We discourage usage of changing lighting with game.Lighting[Property] = value
    cause it doesnt replicate for spectators.
]]
function Lighting:SetLighting(
    properties: {[string]: any},
    postEffects: {[string]: {[string]: any}}
)

    if RS:IsClient() then
        Events.ChangeLighting.Fire({ Properties = properties, PostEffects = postEffects })
    else
        for property: string, value: any in properties do
            pcall(function() LightingService[property] = value end)
        end
        for effect: string, info: table in postEffects do
            if not LightingService:FindFirstChild(effect) then continue end

            for property: string, value: any in info do
                pcall(function() LightingService[effect][property] = value end)
            end
        end
    end
end

return Lighting
