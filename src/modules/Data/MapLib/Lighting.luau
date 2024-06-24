--!nocheck

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Events, Signals = nil, nil
if RunService:IsClient() then
    Events = require(ReplicatedStorage.Modules.Data.Events)
else
    Signals = require(game:GetService("ServerScriptService").Modules.Data.ServerSignals)
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
        Signals.ChangeLighting:Fire(properties, postEffects)
    end
end

return table.freeze(setmetatable({}, Lighting))
