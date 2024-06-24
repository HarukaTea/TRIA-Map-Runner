--!nocheck

local Lighting = game:GetService("Lighting")
local SSS = game:GetService("ServerScriptService")

local Events = require(SSS.Modules.Data.ServerEvents)
local Signals = require(SSS.Modules.Data.ServerSignals)


local function changeLighting(
    plr: Player,
    properties: {[string]: any},
    postEffects: {[string]: {[string]: any}}
)
    if typeof(plr) == "table" then
        plr = properties
        properties = postEffects
    end

    for property: string, value: any in properties do
        pcall(function()
            Lighting[property] = value
        end)
    end
    for effect: string, info: table in postEffects do
        if not Lighting:FindFirstChild(effect) then continue end

        for property: string, value: any in info do
            pcall(function()
                Lighting[effect][property] = value
            end)
        end
    end
end
Events.ChangeLighting:Connect(changeLighting)
Signals.ChangeLighting:Connect(changeLighting)