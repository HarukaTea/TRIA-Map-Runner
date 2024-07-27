--!nocheck

local SSS = game:GetService("ServerScriptService")

local Events = require(SSS.Modules.Data.ServerEvents)

repeat task.wait() until workspace:WaitForChild("Map", 999)

local MapLib = game.GetMapLib:Invoke()()


Events.ChangeLighting.SetCallback(function(_, data)
    local properties, postEffects = data.Properties, data.PostEffects

    MapLib:GetFeature("Lighting"):SetLighting(properties, postEffects)
end)


Events.ChangeMusic.SetCallback(function(_, data)
    local musicId, volume, startTick = data.MusicId, data.Volume, data.StartTick

    MapLib:ChangeMusic(musicId, volume, startTick)
end)
