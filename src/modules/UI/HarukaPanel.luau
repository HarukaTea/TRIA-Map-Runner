--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

local OpenButton = require(RepS.Modules.UI.Components.OpenButton)
local Panel = require(RepS.Modules.UI.Views.Panel)

local Children = Fusion.Children

local v2New = Vector2.new
local fromScale = UDim2.fromScale

local HarukaPanel = {}
HarukaPanel.__index = HarukaPanel

return function (plr: Player)
    local self = setmetatable({}, HarukaPanel)

    self.char = plr.Character or plr.CharacterAdded:Wait()
    self.plr = plr
    self.scope = Fusion.scoped({})

    local scope = self.scope :: table
    Components.ScreenGui(scope, {
        Name = "HarukaPanel",
        DisplayOrder = 100,
        Parent = plr.PlayerGui,

        [Children] = {
            Components.Frame(scope, {
                Name = "Bottom",
                AnchorPoint = v2New(0.5, 1),
                Position = fromScale(0.5, 1),
                Size = fromScale(1, 0.1),

                [Children] = {
                    Fusion.New(scope, "UIAspectRatioConstraint")({ AspectRatio = 25.111 }),

                    OpenButton(self),
                    Panel(self)
                }
            })
        }
    })

    --// Clear
	local function onDead()
		Fusion.doCleanup(scope)
	end
	self.char.Humanoid.Died:Once(onDead)
end
