--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)

local Children = Fusion.Children

return function (scope: Fusion.Scope, props: {
    Adornee: BasePart

}, self: table) : Frame

    return Components.BillboardGui(scope, {
        Name = "Marker",
        Size = UDim2.fromOffset(45, 45),

        Adornee = props.Adornee,
        Parent = self.plr.PlayerGui.HarukaPanel,

        [Children] = {
            Components.Frame(scope, {
                Name = "MarkerFrame",
                BackgroundColor3 = Color3.fromRGB(244, 223, 120),
                BackgroundTransparency = 0.1,
                Rotation = 45,
                Size = UDim2.fromScale(0.2, 0.2),
                ZIndex = 999,

                [Children] = {
                    Fusion.New(scope, "UICorner")({ CornerRadius = UDim.new(0.2, 0) }),
                    Components.UIStroke(scope, {
                        Color = Color3.new(),
                        Thickness = 3
                    })
                }
            }),
            Components.TextLabel(scope, {
                Name = "Marker",
                AnchorPoint = Vector2.new(0.5, 0),
                Position = UDim2.fromScale(0.5, -0.1),
                Size = UDim2.fromScale(1, 0.35),
                ZIndex = 999,
                FontFace = Font.fromName("GothamSSm", Enum.FontWeight.Bold),
                TextColor3 = Color3.fromRGB(244, 223, 120),
                AutoLocalize = false,
                Text = "Medal",

                [Children] = {
                    Components.TextUIStroke(scope, { Thickness = 3 })
                }
            })
        }
    })
end
