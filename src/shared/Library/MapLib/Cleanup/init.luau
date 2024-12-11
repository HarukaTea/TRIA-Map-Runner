--!nocheck

local Players = game:GetService("Players")
local RS = game:GetService("RunService")

local Cleanup = {}

Cleanup._Janitors = {}
Cleanup.Janitor = require(script.Janitor)

type Janitor = table

--// Private

local function doCleanUp()
    for _, janitor: Janitor in Cleanup._Janitors do
        if janitor.isJanitor then janitor:Destroy() end
    end
end
if RS:IsClient() then
    local char = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
    char:WaitForChild("Humanoid").Died:Once(doCleanUp)

    local conn; conn = char:GetAttributeChangedSignal("IsSurvived"):Connect(function()
        if char:GetAttribute("IsSurvived") then
            doCleanUp()

            conn:Disconnect()
        end
    end)
end

--[[
    This method returns a Janitor class with the given name
]]
function Cleanup:GetJanitor(janitorName: string | number) : Janitor
    if self._Janitors[janitorName] then
        return self._Janitors[janitorName]
    else
        return self._Janitors[#self._Janitors]
    end
end

--[[
    This method returns all the active Janitor classes.
]]
function Cleanup:GetJanitors() : { Janitor? }
    return self._Janitors
end

return Cleanup
