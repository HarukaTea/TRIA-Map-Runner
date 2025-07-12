--!nocheck


-- Copyright (C) 2025 Tria
-- This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
-- If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.


local LightingService = game:GetService("Lighting")
local RepS = game:GetService("ReplicatedStorage")
local RS = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")


local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local Events = nil
if RS:IsClient() then
    Events = require(RepS.HarukaShared.Library.Events)
elseif RS:IsServer() then
    Events = require(ServerScriptService.HarukaServer.Library.ServerEvents)
end

local Lighting = {}


function Lighting.new(MapLib)
    local self = setmetatable({}, Lighting)
    self.map = MapLib.map
    self.cache = {}

    for _, child: Instance in LightingService:GetChildren() do
        self.cache[child.Name] = child
    end

    function self:SetLighting(...)
        Lighting:SetLighting(...)
    end
    function self:EaseLighting(...)
        Lighting:EaseLighting(...)
    end

    return self
end

--[[
    This function can to be used to change the lighting of a map mid round. We discourage usage of changing lighting
    with `game.Lighting[Property] = value` cause it doesnt replicate for spectators
]]
function Lighting:SetLighting(
    properties: {[string]: any},
    postEffects: {[string]: {[string]: any}}?
)

    properties = properties or {}
    postEffects = postEffects or {}

    if RS:IsServer() then
        Events.ChangeLighting.FireAll({ Properties = properties, PostEffects = postEffects })
    else
        for property: string, value: any in properties do
            LightingService[property] = value
        end
        for effect: string, info: table in postEffects do
            for property: string, value: any in info do
                local instance = self.cache[effect]
                if instance then
                    instance[property] = value
                end
            end
        end
    end
end



--[=[
	This function can to be used to change the lighting of a map mid round. We discourage usage of changing lighting
	with `game.Lighting[Property] = value` cause it doesnt replicate for spectators.

	**Example:**
    ```lua
	local LightingFeature = MapLib:GetFeature("Lighting")
	-- Tweens Fog to White and to Black 10 times
    for i = 1, 10 do
        LightingFeature:EaseLighting(TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
            FogEnd = 200,
            FogStart = 0,
            FogColor = Color3.fromRGB(255, 0, 0)
        })

        task.wait(1)
    end
	```
]=]
function Lighting:EaseLighting(
    tweenInfo: TweenInfo,
    properties: { [string]: any },
    postEffects: { [string]: { [string]: any } }
)
    tweenInfo = tweenInfo or TweenInfo.new(1)
    properties = properties or {}
    postEffects = postEffects or {}


    if RS:IsServer() then
        Events.ChangeLightingEase.FireAll({ Properties = properties, PostEffects = postEffects, TweenInfo = tweenInfo })
    else
        HarukaLib:CreateTween(LightingService, tweenInfo, properties):Play()

        for effect: string, info: table in postEffects do
            local instance = self.cache[effect]
            if instance then
                HarukaLib:CreateTween(instance, tweenInfo, info)
            end
        end
    end
end



return Lighting
