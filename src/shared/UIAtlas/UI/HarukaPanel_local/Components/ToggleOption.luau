
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)

local Children = Fusion.Children

local MapLib = game.GetMapLib:Invoke()()

local fromScale = UDim2.fromScale
local udNew = UDim.new
local v2New = Vector2.new
local newTweenInfo = TweenInfo.new
local fromRGB = Color3.fromRGB

local Texts = {
    Waters = "Fluids",
    Lights = "Light UP",
    Shadows = "Fog/Shadows",
    Shaders = "Post FXs",
    SkipBtns = "Auto Press",
    InfAir = "Safe Fluids",
    ForceSpeed = "Fixed Speed",
    ForceJump = "Fixed Jump",
    DisableKillbrick = "Killbricks",
    ShowMedals = "Tag Medals"
}

return function (scope: Fusion.Scope<any>, props: {
    ToggleId: string,
    Order: number,

}, self: table) : Frame

    local isSelecting = Fusion.Value(scope, false)

    return Components.Frame(scope, {
        Name = "ToggleOption_"..props.ToggleId,
        Size = fromScale(0.9, 0.11),
        LayoutOrder = props.Order,

        [Children] = {
            Components.UIAspectRatioConstraint(scope, 6.919),

            Components.TextLabel(scope, {
                Name = "Title",
                Size = fromScale(0.6, 1),
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = Texts[props.ToggleId],

                [Children] = {
                    Components.UIPadding(scope, {
                        PaddingLeft = udNew(0.03, 0),
                        PaddingRight = udNew(0.03, 0)
                    })
                }
            }),
            Components.Frame(scope, {
                Name = "Toggle",
                AnchorPoint = v2New(0, 0.5),
                Position = fromScale(0.65, 0.5),
                Size = fromScale(0.35, 0.7),
                BackgroundColor3 = fromRGB(),
                BackgroundTransparency = 0,

                [Children] = {
                    Components.RoundUICorner(scope),
                    Components.HoverImageButton(scope, {
                        ZIndex = 3,

                        [Fusion.OnEvent("MouseButton1Click")] = function()
                            self.Inputs[props.ToggleId]:set(not Fusion.peek(self.Inputs[props.ToggleId]))

                            local result = Fusion.peek(self.Inputs[props.ToggleId])

                            MapLib:Alert(`[Fallen Panel] {Texts[props.ToggleId]} has set to {if result then "true" else "false"}`, if result then "green" else "red", 3)
                        end,
                        [Fusion.OnEvent("MouseEnter")] = function()
                            isSelecting:set(true)
                        end,
                        [Fusion.OnEvent("MouseLeave")] = function()
                            isSelecting:set(false)
                        end
                    }),
                    Components.UIStroke(scope, {
                        Thickness = 2,

                        Enabled = Fusion.Computed(scope, function(use: Fusion.Use)
                            return use(isSelecting)
                        end)
                    }),


                    Components.Frame(scope, {
                        Name = "Switch",
                        AnchorPoint = v2New(),
                        Size = fromScale(0.5, 1),
                        BackgroundTransparency = 0,

                        BackgroundColor3 = Fusion.Tween(scope, Fusion.Computed(scope, function(use: Fusion.Use)
                            return if not use(self.Inputs[props.ToggleId]) then Color3.fromHex('#ff6b81') else Color3.fromHex('#2ed573')
                        end), newTweenInfo(0.2)),
                        Position = Fusion.Tween(scope, Fusion.Computed(scope, function(use: Fusion.Use)
                            return if use(self.Inputs[props.ToggleId]) then fromScale(0.5, 0) else fromScale(0, 0)
                        end), newTweenInfo(0.2)),

                        [Children] = { Components.RoundUICorner(scope) }
                    })
                }
            })
        }
    })
end