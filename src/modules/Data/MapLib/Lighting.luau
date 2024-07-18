--!nocheck

local LightingService = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Events = nil
if RunService:IsClient() then
    Events = require(ReplicatedStorage.Modules.Data.Events)
end

local Lighting = {}
Lighting.__index = Lighting

--[[
    This function can to be used to change the lighting of a map mid round.

    We discourage usage of changing lighting with game.Lighting[Property] = value
    cause it doesnt replicate for spectators.
]]
function Lighting:SetLighting(
    properties: {[string]: any},
    postEffects: {[string]: {[string]: any}}
)

    if RunService:IsClient() then
        Events.ChangeLighting:Fire(properties, postEffects)
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

return table.freeze(setmetatable({}, Lighting))
