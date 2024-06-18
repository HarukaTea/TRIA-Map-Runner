--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

local Children, OnEvent = Fusion.Children, Fusion.OnEvent

local fromScale = UDim2.fromScale
local udNew = UDim.new

local uiStrokeState = Fusion.Value(false)

local function OpenButton(self: table) : TextButton
    return Components.TextButton({
        Name = "OpenBtn",
        Position = fromScale(0.84, -0.1),
        Size = fromScale(0.15, 0.5),
        Text = "Haruka Panel",
        BackgroundTransparency = 0.2,
        AutoLocalize = false,

        [Children] = {
            Fusion.New("UIPadding")({
                PaddingTop = udNew(0.05, 0),
                PaddingBottom = udNew(0.05, 0)
            }),
            Fusion.New("UICorner")({ CornerRadius = udNew(0.2, 0) }),
            Components.UIStroke({
                Thickness = 3,
                Enabled = Fusion.Computed(function(use)
                    return use(uiStrokeState)
                end)
            })
        },
        [OnEvent("MouseButton1Click")] = function()
            self.panelOpen:set(not Fusion.peek(self.panelOpen))
        end,
        [OnEvent("MouseEnter")] = function()
            uiStrokeState:set(true)
        end,
        [OnEvent("MouseLeave")] = function()
            uiStrokeState:set(false)
        end
    })
end

return OpenButton
