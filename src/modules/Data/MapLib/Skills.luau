--!nocheck

local Players = game:GetService("Players")
local RS = game:GetService("RunService")

local Skills = {}
Skills.__index = Skills

--[[
    This function can be used for toggling sliding on or off during a map.

    ``````lua
    local SkillsFeature = Maplib:GetFeature("Skills")

    SkillsFeature:ToggleSliding(false)
    task.wait(5)
    SkillsFeature:ToggleSliding(true)
    ``````
]]
function Skills:ToggleSliding(option: boolean)
    Skills:_Toggler("AllowSlide", option)
end

--[[
    This function can be used for toggling airdive on or off during a map.

    ``````lua
    local SkillsFeature = Maplib:GetFeature("Skills")

    SkillsFeature:ToggleAirDive(false)
    task.wait(5)
    SkillsFeature:ToggleAirDive(true)
    ``````
]]
function Skills:ToggleAirDive(option: boolean)
    Skills:_Toggler("AllowAirDive", option)
end

--// Private
function Skills:_Toggler(name: string, option: boolean)
    if not option then option = false end

    if RS:IsClient() then
        Players.LocalPlayer.Character:SetAttribute(name, option)

    elseif RS:IsServer() then
        for _, plr: Player in Players:GetPlayers() do
            if plr and plr.Character then plr.Character:SetAttribute(name, option) end
        end
    end
end

return table.freeze(setmetatable({}, Skills))
