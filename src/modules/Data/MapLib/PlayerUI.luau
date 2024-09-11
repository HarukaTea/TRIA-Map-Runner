--!nocheck

local Players = game:GetService("Players")
local RS = game:GetService("RunService")

local PlayerUI = {}

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

    if RS:IsClient() then
        ui:Clone().Parent = Players.LocalPlayer.PlayerGui
    end
end

return PlayerUI
