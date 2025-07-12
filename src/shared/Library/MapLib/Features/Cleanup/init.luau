--!nocheck

local Players = game:GetService("Players")
local RS = game:GetService("RunService")

local Janitor = require(script.Janitor)


local player = Players.LocalPlayer
local conn: RBXScriptConnection

local Cleanup = {}

Cleanup._Janitors = Janitor:_GetAllJanitors()
Cleanup.Janitor = Janitor

type Janitor = table

--// Private

local function doCleanUp()
    for _, janitor: Janitor in Janitor:_GetAllJanitors() do
        if Janitor.isJanitor(janitor) then
            janitor:Destroy()
        end
    end
end
if RS:IsClient() then
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
end

--[[
    This method returns a Janitor class with the given name
]]
function Cleanup:GetJanitor(janitorName: string | number) : Janitor
    self._Janitors = Janitor:_GetAllJanitors()

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
    self._Janitors = Janitor:_GetAllJanitors()

    return self._Janitors
end

return Cleanup
