--!nocheck

local RepS = game:GetService("ReplicatedStorage")
local RS = game:GetService("RunService")

local HarukaLib = require(RepS.Modules.Packages.HarukaLib)

local Fusion = require(RepS.Modules.Packages.Fusion)

return function (self: table)
    self.scope = Fusion.scoped({})
    local scope = self.scope :: Fusion.Scope

    local function Value(val: any)
        return Fusion.Value(scope, val)
    end

    self.oxygen = Value(100)
    self.tankOxygen = Value(0)
    self.maxOxygen = Value(100)

    self.isSurvived = Value(false)

    self.currentTime = Value(workspace.Map:GetAttribute("CurrentTime"))

    table.insert(scope, HarukaLib:Hydrate(self.char, {
        ["Attr-SelfOxygen"] = function(o2: number)
            self.oxygen:set(o2)
        end,
        ["Attr-TankOxygen"] = function(tank: number)
            self.tankOxygen:set(tank)
        end,
        ["Attr-MaxOxygen"] = function(maxo2: number)
            self.maxOxygen:set(maxo2)
        end,
        ["Attr-IsSurvived"] = function(state: boolean)
            self.isSurvived:set(state)
        end
    }))

    local timeCalConnection: RBXScriptConnection; timeCalConnection = RS.RenderStepped:Connect(function(dt)
        if Fusion.peek(self.isSurvived) then
            timeCalConnection:Disconnect()
            return
        end

        local nowTime = Fusion.peek(self.currentTime)
        self.currentTime:set(nowTime + dt)
    end)
    table.insert(scope, timeCalConnection)
end
