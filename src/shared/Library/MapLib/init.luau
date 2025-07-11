--!nocheck

-- Copyright (C) 2025 Tria
-- This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
-- If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.


local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local RS = game:GetService("RunService")
local SSS = game:GetService("ServerScriptService")
local TS = game:GetService("TweenService")

local MapDataBook = require(RepS.HarukaShared.Library.MapDataBook)
local Signal = require(RepS.HarukaShared.Shared.Signal)
local Promise = require(RepS.HarukaShared.Shared.Promise)

local isServer, isClient = RS:IsServer(), RS:IsClient()

local Events, Bindables = nil, nil
if isServer then
    Events = require(SSS.HarukaServer.Library.ServerEvents)
    Bindables = require(SSS.HarukaServer.Library.ServerBindables)

elseif isClient then
    Events = require(RepS.HarukaShared.Library.Events)
    Bindables = require(RepS.HarukaShared.Library.Bindables)
end

repeat task.wait() until workspace:GetAttribute("Haruka_MapPreloadRun")

local MapLib = {}

MapLib.map = workspace.Map
MapLib.Map = workspace.Map
MapLib.RoundEnding = Signal.new()

--[[
    This method can be used to send an alert, these alerts can be customized by color and duration.
    ``````lua
    MapLib:Alert("Hello world!", Color3.new(255, 255, 255), 3)
    ``````
]]
function MapLib:Alert(message: string, color: Color3 | string, duration: number?)
    message = message or ""
    color = color or "white"
    duration = tostring(duration) or "3"

    if isClient then
        Bindables.CreateHint:Fire(message, color, duration)

    elseif isServer then
        Events.CreateHint.FireAll({ Hint = message, Color = color, Duration = duration })
    end
end

--[[
    This method can be used to change the current music playing in a map,
    this also replicates to people spectating.

    ``````lua
    MapLib:ChangeMusic(1234567890, 0.5, 0)
    ``````
]]
function MapLib:ChangeMusic(musicId: number, volume: number?, startTick: number?)
    if isClient then
        musicId = tostring(musicId) or ""
        volume = tostring(volume) or "0.5"
        startTick = tostring(startTick) or "0"

        Events.ChangeMusic.Fire({ MusicId = musicId, Volume = volume, StartTick = startTick })

    elseif isServer then
        local music = workspace.Map.MapMusic :: Sound

        music.SoundId = if tonumber(musicId) then "rbxassetid://"..musicId else musicId
        music.Volume = volume
        music.TimePosition = startTick

        music:Play()

        Promise.delay(3):andThen(function()
            if musicId == "" or musicId == nil then return end

            local productInfo = MarketplaceService:GetProductInfo(musicId)
            if productInfo then
                Events.CreateHint.FireAll({
                    Hint = `Music: {productInfo.Name}`,
                    Color = Color3.fromRGB(125, 15, 79),
                })
            end
        end)
    end
end

--[[
    This method can be used to run functions once a specific button has been pressed.

    ``````lua
    MapLib:GetButtonEvent(1):Connect(function(player: Player?)
        print("Button #1 was pressed by "..player.Name)
    end)
    ``````
]]
function MapLib:GetButtonEvent(buttonId: number | string) : RBXScriptConnection
    buttonId = if type(buttonId) == "number" then "Button"..buttonId else buttonId

    local event = workspace.Map.ButtonEvents:FindFirstChild(buttonId) :: BindableEvent
    return event.Event
end

--[[
    This method returns a table containing players currently in a map.

    ``````lua
    local players = MapLib:GetPlayers()

    for _, player in pairs(players) do
        print(player.Name)
    end
    ``````
]]
function MapLib:GetPlayers() : { Player }
    --- ignore this, just make it return all players cuz of testing environment
    return Players:GetPlayers()
end

--[[
    Used to move `PVInstances`

    ``````lua
    MapLib:Move(map.MovingPart1, Vector3.new(12, 0, 0), 3)
    ``````
]]
function MapLib:Move(moveable: PVInstance, movement: Vector3, duration: number?)
    task.spawn(function()
        MapLib:_Move(moveable, movement, duration, false)
    end)
end
MapLib.MovePart = MapLib.Move
MapLib.MoveModel = MapLib.Move

--[[
    Used to move `PVInstances`, but relatively, respect its rotation

    ``````lua
    MapLib:MoveRelative(map.MovingPart1, Vector3.new(12, 0, 0), 3)
    ``````
]]
function MapLib:MoveRelative(moveable: PVInstance, movement: Vector3, duration: number?)
    task.spawn(function()
        MapLib:_Move(moveable, movement, duration, true)
    end)
end
MapLib.MovePartLocal = MapLib.MoveRelative
MapLib.MoveModelLocal = MapLib.MoveRelative

--[[
    This method can be used to change the state of a luquid,
    There are 3 default types you can choose, which are `water`, `acid` and `lava`

    ``````lua
    MapLib:SetLiquidType(map.Liquid1, "water")
    ``````
]]
function MapLib:SetLiquidType(liquid: BasePart, liquidType: string, tweenDuration: number?, stateDelay: number?)
    if not liquid then return end
    if not liquidType then return end

    local finalLiquidColor = MapDataBook.LiquidColors[liquidType]
    local finalOxygenDepletion = 1

    if liquidType == "custom" then
        local liquidSettings = MapLib.map.Settings.Liquids :: Configuration | Folder
        local customAttr = liquidSettings:FindFirstChild("custom") :: Configuration
        local customAttrOld = liquidSettings:FindFirstChild("Custom") :: Configuration

        if not customAttr and not customAttrOld then return end
        if customAttrOld and not customAttr then customAttr = customAttrOld end

        finalLiquidColor = customAttr:GetAttribute("Color")
        finalOxygenDepletion = customAttr:GetAttribute("OxygenDepletion")
    end

    TS:Create(liquid, TweenInfo.new(tweenDuration or 1), { Color = finalLiquidColor }):Play()
    task.delay(stateDelay or 1, function()
        liquid:SetAttribute("OxygenDepletion", finalOxygenDepletion)
        liquid:SetAttribute("Type", liquidType)
    end)
end

--[[
    This method can be used to make a player survive
    the round without touching the ExitRegion.

    ``````lua
    local Players = game:GetService("Players")
    local MapLib = game.GetMapLib:Invoke()()

    script.Parent.Touched:Connect(function(other)
        local player = Players:GetPlayerFromCharacter(other.Parent)
        if player then
            MapLib:Survive(player)
        end
    end)
    ``````
]]
function MapLib:Survive(player: Player)
    if not player.Character then return end

    player.Character:SetAttribute("IsSurvived", true)
end

--[[
    This method is used to get any features listed in the features list.
]]
function MapLib:GetFeature(feature: string) : table
    if not feature then return end
    if not RepS.HarukaShared.Library.MapLib:FindFirstChild(feature) then return end


    local featureModule = require(RepS.HarukaShared.Library.MapLib[feature])
    if featureModule.new then
        return featureModule.new(MapLib)
    end

    return require(RepS.HarukaShared.Library.MapLib[feature])
end

--// Private

function MapLib:_Move(moveable: PVInstance, movement: Vector3, duration: number?, relative: boolean?)
    if duration == 0 or duration == nil then
		moveable:PivotTo(relative and moveable:GetPivot() * CFrame.new(movement) or moveable:GetPivot() + movement)
		return nil
	end

	local moved = Vector3.zero
	local move = movement / duration
	local endTick = tick() + duration

	local connection
	connection = RS.PreSimulation:Connect(function(deltaTime)
		if tick() < endTick then
			moved += move * deltaTime
			moveable:PivotTo(
				relative and moveable:GetPivot() * CFrame.new(move * deltaTime)
					or moveable:GetPivot() + (move * deltaTime)
			)
		else
			connection:Disconnect()
			moveable:PivotTo(
				relative and moveable:GetPivot() * CFrame.new(movement - moved)
					or moveable:GetPivot() + (movement - moved)
			)
		end
	end)
end


if RS:IsClient() then
    Events.MapRoundEnding.SetCallback(function()
        MapLib.RoundEnding:Fire()
    end)

    Events.ChangeLighting.On(function(data)
        local LightingFeature = MapLib:GetFeature("Lighting")


        LightingFeature:SetLighting(data.Properties, data.PostEffects)
    end)

    Events.ChangeLightingEase.On(function(data)
        local LightingFeature = MapLib:GetFeature("Lighting")


        LightingFeature:EaseLighting(data.TweenInfo, data.Properties, data.PostEffects)
    end)
end



return MapLib
