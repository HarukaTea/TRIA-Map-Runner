--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

local Children, Tween, Computed, OnEvent, Value, peek =
    Fusion.Children, Fusion.Tween, Fusion.Computed, Fusion.OnEvent, Fusion.Value, Fusion.peek

local fromScale = UDim2.fromScale
local udNew = UDim.new
local fromRGB = Color3.fromRGB
local newTweenInfo = TweenInfo.new

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

local function TypeOption(id: string, self: table) : Frame
    local scope = self.scope :: table

    local isSelecting = Value(scope, false)
    local isSelecting2 = Value(scope, false)

    return Components.Frame(scope, {
        Name = "TypeOption",
        Size = fromScale(1, 0.12),

        [Children] = {
            Fusion.New(scope, "UIAspectRatioConstraint")({ AspectRatio = 6.449 }),
            Components.TextLabel(scope, {
                Name = "Title",
                Size = fromScale(0.7, 1),
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = Texts[id],

                [Children] = {
                    Fusion.New(scope, "UIPadding")({
                        PaddingBottom = udNew(0.1, 0),
                        PaddingTop = udNew(0.1, 0),
                        PaddingLeft = udNew(0.03, 0)
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

                BackgroundColor3 = Tween(scope, Computed(scope, function(use: Fusion.Use)
                    return if use(isSelecting) then fromRGB(255, 255, 255) else fromRGB(30, 30, 30)
                end), newTweenInfo(0.3)),
                TextColor3 = Tween(scope, Computed(scope, function(use: Fusion.Use)
                    return if use(isSelecting) then fromRGB() else fromRGB(255, 255, 255)
                end), newTweenInfo(0.3)),

                [OnEvent("MouseButton1Click")] = function()
                    local currentVal = tonumber(peek(self.inputs[id])) or Priority[id]

                    currentVal -= Priority[id]
                    if currentVal < 0 then currentVal = 0 end

                    self.inputs[id]:set(currentVal)
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

                BackgroundColor3 = Tween(scope, Computed(scope, function(use: Fusion.Use)
                    return if use(isSelecting2) then fromRGB(255, 255, 255) else fromRGB(30, 30, 30)
                end), newTweenInfo(0.3)),
                TextColor3 = Tween(scope, Computed(scope, function(use: Fusion.Use)
                    return if use(isSelecting2) then fromRGB() else fromRGB(255, 255, 255)
                end), newTweenInfo(0.3)),

                [OnEvent("MouseButton1Click")] = function()
                    local currentVal = tonumber(peek(self.inputs[id])) or Priority[id]

                    currentVal += Priority[id]
                    if currentVal < 0 then currentVal = 0 end

                    self.inputs[id]:set(currentVal)
                end,
                [OnEvent("MouseEnter")] = function()
                    isSelecting2:set(true)
                end,
                [OnEvent("MouseLeave")] = function()
                    isSelecting2:set(false)
                end,

                [Children] = { Components.RoundUICorner(scope) }
            }),

            Components.TextBox(scope, {
                Name = "Input",
                BackgroundTransparency = 0.5,
                Position = fromScale(0.625, 0),
                Size = fromScale(0.2, 1),
                TextColor3 = fromRGB(178, 178, 178),

                Text = Computed(scope, function(use: Fusion.Use)
                    return use(self.inputs[id])
                end),

                [Children] = { Components.RoundUICorner(scope) }
            }),
        }
    })
end

return TypeOption