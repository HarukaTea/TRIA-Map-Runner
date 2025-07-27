--!nocheck

-- Copyright (C) 2025 Tria
-- This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
-- If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RS = game:GetService("RunService")

local PlayerUI = {}


local player = Players.LocalPlayer
local conn


function PlayerUI.new()
    local self = setmetatable({}, PlayerUI)

    self.MapUIs = {}


    local function doCleanUp()
        for _, gui: ScreenGui in self.MapUIs do
            gui:Destroy()
        end
        for _, gui: ScreenGui in CollectionService:GetTagged("MapUIEntity") do
            gui:Destroy()
        end
        table.clear(self.MapUIs)
    end
    local function _AutoCleanup(char: Model)
        if conn then return end

        char:WaitForChild("Humanoid").Died:Once(doCleanUp)

        conn = char:GetAttributeChangedSignal("IsSurvived"):Connect(function()
            if char:GetAttribute("IsSurvived") then
                doCleanUp()
                conn:Disconnect()
                conn = nil
            end
        end)
    end
    _AutoCleanup(player.Character or player.CharacterAdded:Wait())
    player.CharacterAdded:Connect(_AutoCleanup)



    function self:LoadUI(...)
        PlayerUI:LoadUI(...)
    end


    return self
end



--[[
    This function can be used to load a ScreenGui from the map into the players PlayerGUI.

    ``````lua
    -- Loads an UI for everyone in the round
    local PlayersFeature = Maplib:GetFeature("Players")
    local PlayerUI = MapLib:GetFeature("PlayerUI")

    local ui = map:WaitForChild("MyGUI")

    for _, player in pairs(PlayersFeature:GetPlayers()) do
        if player and player.Character then
            PlayerUI:LoadUI(ui)
        end
    end
    ``````
]]
function PlayerUI:LoadUI(ui: ScreenGui)
    if not ui then return end
    if not ui:IsA("ScreenGui") then
        error("UI must be a ScreenGui")
        return
    end

    if RS:IsClient() then
        local clonedUI = ui:Clone() :: ScreenGui
        clonedUI.Parent = player.PlayerGui

        table.insert(self.MapUIs, clonedUI)
    end
end

return PlayerUI
