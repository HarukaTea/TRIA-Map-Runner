--!nocheck

local SSS = game:GetService("ServerScriptService")

local Events = require(SSS.Modules.Data.ServerEvents)

repeat task.wait() until workspace:WaitForChild("Map", 999)

local MapLib = game.GetMapLib:Invoke()()

local function changeLighting(
    _,
    properties: {[string]: any},
    postEffects: {[string]: {[string]: any}}
)
    MapLib:GetFeature("Lighting"):SetLighting(properties, postEffects)
end
Events.ChangeLighting:Connect(changeLighting)

local function changeMusic(_, musicId: string, volume: number, startTick: number)
    MapLib:ChangeMusic(musicId, volume, startTick)
end
Events.ChangeMusic:Connect(changeMusic)
