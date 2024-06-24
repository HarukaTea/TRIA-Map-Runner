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

    local bgColor = Value(scope, fromRGB(30, 30, 30))
    local bgTextColor = Value(scope, fromRGB(255, 255, 255))
    local bgColor2 = Value(scope, fromRGB(30, 30, 30))
    local bgTextColor2 = Value(scope, fromRGB(255, 255, 255))

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
            Components.TextBox(scope, {
                Name = "Input",
                BackgroundTransparency = 0.5,
                Position = fromScale(0.625, 0),
                Size = fromScale(0.2, 1),
                TextColor3 = fromRGB(178, 178, 178),

                Text = Computed(scope, function(use)
                    return use(self.inputs[id])
                end),

                [Fusion.Out("Text")] = self.inputs[id],

                [Children] = { Components.RoundUICorner(scope) }
            }),
            Components.TextButton(scope, {
                Name = "Decrease",
                BackgroundTransparency = 0.2,
                Position = fromScale(0.455, 0),
                Size = fromScale(0.15, 1),
                Text = "<",

                BackgroundColor3 = Tween(scope, Computed(scope, function(use)
                    return use(bgColor)
                end), newTweenInfo(0.3)),
                TextColor3 = Tween(scope, Computed(scope, function(use)
                    return use(bgTextColor)
                end), newTweenInfo(0.3)),

                [OnEvent("MouseButton1Click")] = function()
                    local currentVal = peek(self.inputs[id])

                    if currentVal ~= "" and tonumber(currentVal) then
                        self.inputs[id]:set(tonumber(currentVal) - Priority[id])

                        if tonumber(currentVal) - Priority[id] < 0 then
                            self.inputs[id]:set(0)
                        end
                    end
                end,
                [OnEvent("MouseEnter")] = function()
                    bgColor:set(fromRGB(255, 255, 255))
                    bgTextColor:set(fromRGB())
                end,
                [OnEvent("MouseLeave")] = function()
                    bgColor:set(fromRGB(30, 30, 30))
                    bgTextColor:set(fromRGB(255, 255, 255))
                end,

                [Children] = { Components.RoundUICorner(scope) }
            }),
            Components.TextButton(scope, {
                Name = "Increase",
                BackgroundTransparency = 0.2,
                Position = fromScale(0.845, 0),
                Size = fromScale(0.15, 1),
                Text = ">",

                BackgroundColor3 = Tween(scope, Computed(scope, function(use)
                    return use(bgColor2)
                end), newTweenInfo(0.3)),
                TextColor3 = Tween(scope, Computed(scope, function(use)
                    return use(bgTextColor2)
                end), newTweenInfo(0.3)),

                [OnEvent("MouseButton1Click")] = function()
                    local currentVal = peek(self.inputs[id])

                    if currentVal ~= "" and tonumber(currentVal) then
                        self.inputs[id]:set(tonumber(currentVal) + Priority[id])
                    end
                end,
                [OnEvent("MouseEnter")] = function()
                    bgColor2:set(fromRGB(255, 255, 255))
                    bgTextColor2:set(fromRGB())
                end,
                [OnEvent("MouseLeave")] = function()
                    bgColor2:set(fromRGB(30, 30, 30))
                    bgTextColor2:set(fromRGB(255, 255, 255))
                end,

                [Children] = { Components.RoundUICorner(scope) }
            })
        }
    })
end

return TypeOption