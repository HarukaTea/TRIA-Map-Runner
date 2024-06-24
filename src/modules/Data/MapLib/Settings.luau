--!nocheck

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Events, Signals = nil, nil
if RunService:IsServer() then
    Events = require(game:GetService("ServerScriptService").Modules.Data.ServerEvents)
else
    Signals = require(ReplicatedStorage.Modules.Data.Signals)
end

local Settings = {}
Settings.__index = Settings

--[[
    This function can be used to get the value of a setting.

    ``````lua
    -- Changes the camera FOV to an arbitrary number and then sets it back to the saved settings value.
    local SettingsFeature = Maplib:GetFeature("Settings")

    local camera = workspace.CurrentCamera

    camera.FieldOFView = 120
    task.wait(3)
    camera.FieldOFView = SettingsFeature:GetSetting("Field Of View")
    ``````
]]
function Settings:GetSetting(setting: string)
    if not setting then return end

    if RunService:IsClient() then
        Signals.CreateHint:Fire("Settings feature isn't supported in studio environment!")

    elseif RunService:IsServer() then
        Events.CreateHint:FireAll("You can only call Settings feature in client!")
    end
end

return table.freeze(setmetatable({}, Settings))
