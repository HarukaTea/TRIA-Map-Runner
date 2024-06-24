--!nocheck

local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local RS = game:GetService("RunService")

local Signal = require(RepS.Modules.Packages.Signal)
local Spawn = require(RepS.Modules.Packages.Spawn)

local Events, Signals = nil, nil
if RS:IsServer() then
    Events = require(game:GetService("ServerScriptService").Modules.Data.ServerEvents)
    Signals = nil

elseif RS:IsClient() then
    Events = nil
    Signals = require(RepS.Modules.Data.Signals)
end

local MapLib = {}
MapLib.__index = MapLib

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
    if RS:IsClient() then
        Signals.CreateHint:Fire(message, color, duration)

    elseif RS:IsServer() then
        Events.CreateHint:FireAll(message, color, duration)
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
    local music = workspace.Map.MapMusic :: Sound

    music.SoundId = tonumber(musicId) or ""
    music.Volume = volume or 0.5
    music.TimePosition = startTick or 0
end

--[[
    This method can be used to run functions once a specific button has been pressed.

    ``````lua
    MapLib:GetButtonEvent(1):Connect(function(player: Player?)
        print("Button #1 was pressed by "..player.Name)
    end)
    ``````
]]
function MapLib:GetButtonEvent(buttonId: number | string)
    if RS:IsServer() then
        buttonId = if type(buttonId) == "number" then "Button"..buttonId else buttonId

        local event = workspace.Map.ButtonEvents:FindFirstChild(buttonId) :: BindableEvent
        return event.Event
    end
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
    return Players:GetPlayers()
end

--[[
    Used to move `PVInstances`

    ``````lua
    MapLib:Move(map.MovingPart1, Vector3.new(12, 0, 0), 3)
    ``````
]]
function MapLib:Move(moveable: PVInstance, movement: Vector3, duration: number?)
    Spawn(function()
        MapLib:_Move(moveable, movement, duration, false)
    end)
end
MapLib.MovePart = MapLib.Move

--[[
    Used to move `PVInstances`, but relatively, respect its rotation

    ``````lua
    MapLib:MoveRelative(map.MovingPart1, Vector3.new(12, 0, 0), 3)
    ``````
]]
function MapLib:MoveRelative(moveable: PVInstance, movement: Vector3, duration: number?)
    Spawn(function()
        MapLib:_Move(moveable, movement, duration, true)
    end)
end
MapLib.MovePartLocal = MapLib.MoveRelative

--[[
    This method can be used to change the state of a luquid,
    There are 3 default types you can choose, which are `water`, `acid` and `lava`

    ``````lua
    MapLib:SetLiquidType(map.Liquid1, "water")
    ``````
]]
function MapLib:SetLiquidType(liquid: BasePart, liquidType: string)
    if not liquid then return end
    if not liquidType then return end

    liquid:SetAttribute("Type", liquidType)
end

function MapLib:Survive()
    --// TODO
end

--[[
    This method is used to get any features listed in the features list.
]]
function MapLib:GetFeature(feature: string)
    if not feature then return end
    if not RepS.Modules.Data.MapLib:FindFirstChild(feature) then
        if RS:IsClient() then
            Signals.CreateHint:Fire("No feature named "..feature.."!", "yellow", 5)

        elseif RS:IsServer() then
            Events.CreateHint:FireAll("No feature named "..feature.."!", "yellow", 5)
        end
        return
    end

    return require(RepS.Modules.Data.MapLib[feature])
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

return table.freeze(setmetatable({}, MapLib))
