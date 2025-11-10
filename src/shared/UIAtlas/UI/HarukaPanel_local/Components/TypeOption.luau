
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)

local Children, Computed, OnEvent, Value, peek =
    Fusion.Children, Fusion.Computed, Fusion.OnEvent, Fusion.Value, Fusion.peek

local fromScale = UDim2.fromScale
local udNew = UDim.new
local fromRGB = Color3.fromRGB

local Texts = {
    Speed = "Speed",
    Jump = "Jump",
    Noclip = "Noclip",
    Buttons = "Buttons"
}
local Priority = {
    Speed = 5,
    Jump = 10,
    Noclip = 10,
    Buttons = 1
}

return function (scope: Fusion.Scope, props: {
    TypeId: string,
    Order: number,

}, self: table) : Frame

    local isSelecting = Value(scope, false)
    local isSelecting2 = Value(scope, false)

    return Components.Frame(scope, {
        Name = "TypeOption_"..props.TypeId,
        Size = fromScale(0.9, 0.11),
        LayoutOrder = props.Order,

        [Children] = {
            Components.UIAspectRatioConstraint(scope, 6.919),

            Components.TextLabel(scope, {
                Name = "Title",
                Size = fromScale(0.45, 1),
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = Texts[props.TypeId],

                [Children] = {
                    Components.UIPadding(scope, {
                        PaddingLeft = udNew(0.03, 0),
                        PaddingRight = udNew(0.03, 0)
                    })
                }
            }),

            Components.TextButton(scope, {
                Name = "Decrease",
                BackgroundTransparency = 0.2,
                Position = fromScale(0.455, 0),
                Size = fromScale(0.15, 1),
                Text = "<",
                AutoButtonColor = false,
                FontFace = Font.fromName("MontSerrat", Enum.FontWeight.Bold),

                BackgroundColor3 = Computed(scope, function(use: Fusion.Use)
                    return if use(isSelecting) then fromRGB(255, 255, 255) else fromRGB(28, 28, 37)
                end),
                TextColor3 = Computed(scope, function(use: Fusion.Use)
                    return if use(isSelecting) then fromRGB() else fromRGB(255, 255, 255)
                end),

                [OnEvent("MouseButton1Click")] = function()
                    local currentVal = peek(self.Inputs[props.TypeId]) or Priority[props.TypeId]

                    currentVal -= Priority[props.TypeId]
                    if currentVal < 0 then currentVal = 0 end

                    self.Inputs[props.TypeId]:set(currentVal)
                end,
                [OnEvent("MouseEnter")] = function()
                    isSelecting:set(true)
                end,
                [OnEvent("MouseLeave")] = function()
                    isSelecting:set(false)
                end,

                [Children] = { Components.RoundUICorner(scope) }
            }),
            Components.TextButton(scope, {
                Name = "Increase",
                BackgroundTransparency = 0.2,
                Position = fromScale(0.845, 0),
                Size = fromScale(0.15, 1),
                Text = ">",
                AutoButtonColor = false,
                FontFace = Font.fromName("MontSerrat", Enum.FontWeight.Bold),

                BackgroundColor3 = Computed(scope, function(use: Fusion.Use)
                    return if use(isSelecting2) then fromRGB(255, 255, 255) else fromRGB(28, 28, 37)
                end),
                TextColor3 = Computed(scope, function(use: Fusion.Use)
                    return if use(isSelecting2) then fromRGB() else fromRGB(255, 255, 255)
                end),

                [OnEvent("MouseButton1Click")] = function()
                    local currentVal = peek(self.Inputs[props.TypeId]) or Priority[props.TypeId]

                    currentVal += Priority[props.TypeId]
                    if currentVal < 0 then currentVal = 0 end

                    self.Inputs[props.TypeId]:set(currentVal)
                end,
                [OnEvent("MouseEnter")] = function()
                    isSelecting2:set(true)
                end,
                [OnEvent("MouseLeave")] = function()
                    isSelecting2:set(false)
                end,

                [Children] = { Components.RoundUICorner(scope) }
            }),

            Components.TextLabel(scope, {
                Name = "Input",
                BackgroundTransparency = 0.5,
                Position = fromScale(0.625, 0),
                Size = fromScale(0.2, 1),
                TextColor3 = fromRGB(178, 178, 178),

                Text = Computed(scope, function(use: Fusion.Use)
                    return use(self.Inputs[props.TypeId])
                end),

                [Children] = { Components.RoundUICorner(scope) }
            }),
        }
    })
end