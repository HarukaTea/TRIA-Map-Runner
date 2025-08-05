--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)

local Children = Fusion.Children


local fromScale = UDim2.fromScale
local udNew = UDim.new
local fromRGB = Color3.fromRGB

local TITLES = {
    Controls = "CONTROLS",
    Map = "MAP",
    Checkpoints = "TELEPORT",
    CheckpointsNormal = "CHECKPOINTS",
    CheckpointsTune = "TUNE",
    DEBUG = "DEBUG"
}


return function (scope: Fusion.Scope, props: {
    TitleId: string,
    Order: number,

}) : Frame

    return Components.Frame(scope, {
        Name = "TitleSection_"..props.TitleId,
        Size = fromScale(0.9, 0.11),
        LayoutOrder = props.Order,
        ClipsDescendants = true,

        [Children] = {
            Components.UIAspectRatioConstraint(scope, 6.919),

            Components.UIListLayout(scope, {
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                VerticalAlignment = Enum.VerticalAlignment.Center,
            }),

            Components.Frame(scope, {
                Name = "Line",
                Size = fromScale(1, 0.1),
                LayoutOrder = 1,
                BackgroundTransparency = 0.5,
                BackgroundColor3 = Components.WHITE_COLOR,
            }),
            Components.TextLabel(scope, {
                Name = "Title",
                Size = fromScale(0, 1),
                AutomaticSize = Enum.AutomaticSize.X,
                Text = TITLES[props.TitleId],
                TextTransparency = 0.5,
                LayoutOrder = 2,

                [Children] = {
                    Components.UIPadding(scope, {
                        PaddingTop = udNew(0.1, 0),
                        PaddingBottom = udNew(0.1, 0),
                        PaddingLeft = udNew(0, 9),
                        PaddingRight = udNew(0, 9)
                    })
                }
            }),
            Components.Frame(scope, {
                Name = "Line",
                Size = fromScale(1, 0.1),
                LayoutOrder = 3,
                BackgroundTransparency = 0.5,
                BackgroundColor3 = Components.WHITE_COLOR,
            }),
        }
    })
end