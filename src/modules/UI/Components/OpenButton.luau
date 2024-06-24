--!nocheck

local CAS = game:GetService("ContextActionService")
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

local Children, OnEvent = Fusion.Children, Fusion.OnEvent

local fromScale = UDim2.fromScale
local udNew = UDim.new

local function OpenButton(self: table) : TextButton
    local scope = self.scope :: table
    local uiStrokeState = Fusion.Value(scope, false)

    local function _setPanelOpen(_, inputState: Enum.UserInputState)
        if inputState ~= Enum.UserInputState.Begin then return end

        self.panelOpen:set(not Fusion.peek(self.panelOpen))
    end
    CAS:BindAction("HarukaPanelSetOpen", _setPanelOpen, false, Enum.KeyCode.C)

    return Components.TextButton(scope, {
        Name = "OpenBtn",
        Position = fromScale(0.84, -0.1),
        Size = fromScale(0.15, 0.5),
        Text = "Fallen Panel (C)",
        BackgroundTransparency = 0.2,
        AutoLocalize = false,

        [Children] = {
            Fusion.New(scope, "UIPadding")({
                PaddingTop = udNew(0.05, 0),
                PaddingBottom = udNew(0.05, 0)
            }),
            Fusion.New(scope, "UICorner")({ CornerRadius = udNew(0.2, 0) }),

            Components.UIStroke(scope, {
                Thickness = 2.5,
                Enabled = Fusion.Computed(scope, function(use)
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
