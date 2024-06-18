--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

local New, OnEvent = Fusion.New, Fusion.OnEvent

local fromScale = UDim2.fromScale
local udNew = UDim.new
local fromRGB = Color3.fromRGB
local newTweenInfo = TweenInfo.new

local Texts = {
    SetCheck = "Set Checkpoint (C)",
    ReturnCheck = "Teleport Back (T)"
}

local function ButtonOption(id: string, self: table) : TextButton

    local bgColor = Fusion.Value(fromRGB(30, 30, 30))
    local bgTextColor = Fusion.Value(fromRGB(255, 255, 255))

    return Components.TextButton({
        Name = "ButtonOption",
        Size = fromScale(1, 0.12),
        Text = Texts[id],

        BackgroundColor3 = Fusion.Tween(Fusion.Computed(function(use)
            return use(bgColor)
        end), newTweenInfo(0.3)),
        TextColor3 = Fusion.Tween(Fusion.Computed(function(use)
            return use(bgTextColor)
        end), newTweenInfo(0.3)),

        [OnEvent("MouseButton1Click")] = function()
            if id == "SetCheck" then
                self.inputs[id]:set(self.plr.Character.PrimaryPart.CFrame)

            elseif id == "ReturnCheck" then
                self.plr.Character:PivotTo(Fusion.peek(self.inputs.SetCheck))
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

        [Fusion.Children] = {
            New("UIAspectRatioConstraint")({ AspectRatio = 6.449 }),
            New("UICorner")({ CornerRadius = udNew(0.2, 0) }),
            New("UIPadding")({
                PaddingTop = udNew(0.1, 0),
                PaddingBottom = udNew(0.1, 0)
            })
        }
    })
end

return ButtonOption
