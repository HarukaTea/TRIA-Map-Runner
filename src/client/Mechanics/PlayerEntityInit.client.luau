
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

repeat task.wait() until workspace:GetAttribute("Haruka_MapPreloadRun")


local Promise = require(ReplicatedStorage.HarukaShared.Shared.Promise)


local player = Players.LocalPlayer


local PlayerLib = {}


function PlayerLib:Init()
    self:_InitUI()
end


function PlayerLib:_InitUI()
    for _, module in ReplicatedStorage.HarukaShared.UIAtlas.UI:GetChildren() do
        if string.find(module.Name, ".spec") then warn(module.Name) continue end
        if not string.find(module.Name, "_local") then continue end

        Promise.try(require(module), player):catch(function(err)
            warn(tostring(err))
        end)
    end
end


PlayerLib:Init()

workspace:SetAttribute("Haruka_PlayerClientInited", true)
