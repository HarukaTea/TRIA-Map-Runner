--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

local Children = Fusion.Children

local fromScale = UDim2.fromScale
local udNew = UDim.new

local Texts = {
    Speed = "Speed",
    Jump = "Jump Power",
    Noclip = "Noclip Speed",
    Buttons = "Buttons"
}
local PlaceHolderTexts = {
    Speed = "20",
    Jump = "50",
    Noclip = "20",
    Buttons = "1"
}

local function TypeOption(id: string, self: table) : Frame
    return Components.Frame({
        Name = "TypeOption",
        Size = fromScale(1, 0.12),

        [Children] = {
            Fusion.New("UIAspectRatioConstraint")({ AspectRatio = 6.449 }),
            Components.TextLabel({
                Name = "Title",
                Size = fromScale(0.7, 1),
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
            Components.TextBox({
                Name = "Input",
                BackgroundTransparency = 0.5,
                Position = fromScale(0.7, 0),
                Size = fromScale(0.3, 1),
                PlaceholderText = PlaceHolderTexts[id],

                [Fusion.Out("Text")] = self.inputs[id],

                [Children] = { Components.RoundUICorner() }
            })
        }
    })
end

return TypeOption