--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

local Children = Fusion.Children

local fromScale = UDim2.fromScale
local udNew = UDim.new
local v2New = Vector2.new
local newTweenInfo = TweenInfo.new
local fromRGB = Color3.fromRGB

local Texts = {
    Waters = "Waters",
    Lights = "Self-Light",
    Shadows = "Shadows",
    Shaders = "Shaders",
    SkipBtns = "Skip Btns",
    InfAir = "Inf Air",
}

local function ToggleOption(id: string, self: table) : Frame
    return Components.Frame({
        Name = "ToggleOption",
        Size = fromScale(1, 0.12),

        [Children] = {
            Fusion.New("UIAspectRatioConstraint")({ AspectRatio = 6.449 }),
            Components.TextLabel({
                Name = "Title",
                Size = fromScale(0.6, 1),
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = Texts[id],

                [Children] = {
                    Fusion.New("UIPadding")({
                        PaddingBottom = udNew(0.1, 0),
                        PaddingTop = udNew(0.1, 0),
                        PaddingLeft = udNew(0.03, 0)
                    })
                }
            }),
            Components.Frame({
                Name = "Toggle",
                AnchorPoint = v2New(0, 0.5),
                Position = fromScale(0.65, 0.5),
                Size = fromScale(0.35, 0.7),
                BackgroundColor3 = fromRGB(),
                BackgroundTransparency = 0.5,

                [Children] = {
                    Components.RoundUICorner(),
                    Components.HoverImageButton({
                        Name = id,
                        ZIndex = 3,

                        [Fusion.OnEvent("MouseButton1Click")] = function()
                            self.inputs[id]:set(not Fusion.peek(self.inputs[id]))
                        end
                    }),
                    Components.Frame({
                        AnchorPoint = v2New(),
                        Size = fromScale(0.5, 1),
                        BackgroundTransparency = 0,

                        BackgroundColor3 = Fusion.Tween(Fusion.Computed(function(use)
                            return if not use(self.inputs[id]) then fromRGB(255, 85, 127) else fromRGB(76, 152, 113)
                        end), newTweenInfo(0.2)),
                        Position = Fusion.Tween(Fusion.Computed(function(use)
                            return if use(self.inputs[id]) then fromScale(0.5, 0) else fromScale(0, 0)
                        end), newTweenInfo(0.2)),

                        [Children] = { Components.RoundUICorner() }
                    })
                }
            })
        }
    })
end

return ToggleOption
