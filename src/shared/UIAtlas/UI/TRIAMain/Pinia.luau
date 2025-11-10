
local RepS = game:GetService("ReplicatedStorage")
local RS = game:GetService("RunService")

local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local Fusion = require(RepS.HarukaShared.Shared.Fusion)


export type Self = {
    plr: Player,
    char: Model,
    scope: Fusion.Scope<any>,

    Oxygen: Fusion.Value<number>,
    TankOxygen: Fusion.Value<number>,
    MaxOxygen: Fusion.Value<number>,

    IsSurvived: Fusion.Value<boolean>,
    CurrentTime: Fusion.Value<number>,
}



return function (self: Self)
    self.scope = Fusion.scoped()
    local scope = self.scope :: Fusion.Scope

    local function Value<T>(val: T): Fusion.Value<T>
        return Fusion.Value(scope, val)
    end

    self.Oxygen = Value(100)
    self.TankOxygen = Value(0)
    self.MaxOxygen = Value(100)

    self.IsSurvived = Value(false)

    self.CurrentTime = Value(workspace.Map:GetAttribute("CurrentTime"))

    table.insert(scope, HarukaLib:Hydrate(self.char, {
        ["Attr-SelfOxygen"] = function(o2: number)
            self.Oxygen:set(o2)
        end,
        ["Attr-TankOxygen"] = function(tank: number)
            self.TankOxygen:set(tank)
        end,
        ["Attr-MaxOxygen"] = function(maxo2: number)
            self.MaxOxygen:set(maxo2)
        end,
        ["Attr-IsSurvived"] = function(state: boolean)
            self.IsSurvived:set(state)
        end
    }))

    local timeCalConnection: RBXScriptConnection; timeCalConnection = RS.RenderStepped:Connect(function(dt)
        if Fusion.peek(self.IsSurvived) then
            timeCalConnection:Disconnect()
            return
        end

        local nowTime = Fusion.peek(self.CurrentTime)
        self.CurrentTime:set(nowTime + dt)
    end)
    table.insert(scope, timeCalConnection)
end