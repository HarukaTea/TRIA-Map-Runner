--!nocheck

local RepS = game:GetService("ReplicatedStorage")
local RS = game:GetService("RunService")

local HarukaLib = require(RepS.Modules.Packages.HarukaLib)

local Fusion = require(RepS.Modules.Packages.Fusion)

return function (self: table)
    self.scope = Fusion.scoped({})
    local scope = self.scope :: Fusion.Scope

    self.oxygen = Fusion.Value(scope, 100)
    self.maxOxygen = Fusion.Value(scope, 100)

    self.currentTime = Fusion.Value(scope, workspace.Map:GetAttribute("CurrentTime"))

    table.insert(scope, HarukaLib:Hydrate(self.char, {
        ["Attr-CurrentOxygen"] = function(o2: number)
            self.oxygen:set(o2)
        end,
        ["Attr-MaxOxygen"] = function(maxo2: number)
            self.maxOxygen:set(maxo2)
        end
    }))

    table.insert(scope, RS.RenderStepped:Connect(function(dt)
        local nowTime = Fusion.peek(self.currentTime)

        self.currentTime:set(nowTime + dt)
    end))
end
