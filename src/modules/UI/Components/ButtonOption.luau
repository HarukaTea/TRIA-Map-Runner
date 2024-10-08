--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)

local MapLib = game.GetMapLib:Invoke()()

local New, OnEvent = Fusion.New, Fusion.OnEvent

local fromScale = UDim2.fromScale
local udNew = UDim.new
local fromRGB = Color3.fromRGB
local newTweenInfo = TweenInfo.new
local tFind = table.find

local Texts = {
    AddCheck = "Add Checkpoint (X)",
    ClearCheck = "Clear Checkpoints",
    ActivateAllBtns = "Press Buttons"
}

local function ButtonOption(id: string, self: table, checkPoint: CFrame?, scope: table?) : TextButton
    if not scope then scope = self.scope end

    local isSelecting = Fusion.Value(scope, false)
    local index = 0
    if checkPoint then index = tFind(Fusion.peek(self.checkPoints), checkPoint) end

    return Components.TextButton(scope, {
        Name = "ButtonOption",
        Size = fromScale(1, 0.12),
        Text = if id == "Checkpoint" then "Checkpoint "..index else Texts[id],
        AutoButtonColor = false,

        BackgroundColor3 = Fusion.Tween(scope, Fusion.Computed(scope, function(use: Fusion.Use)
            return if use(isSelecting) then fromRGB(255, 255, 255) else fromRGB(30, 30, 30)
        end), newTweenInfo(0.3)),
        TextColor3 = Fusion.Tween(scope, Fusion.Computed(scope, function(use: Fusion.Use)
            return if use(isSelecting) then fromRGB() else fromRGB(255, 255, 255)
        end), newTweenInfo(0.3)),

        [OnEvent("MouseButton1Click")] = function()
            if id == "AddCheck" then
                local cTable = Fusion.peek(self.checkPoints)

                cTable[#cTable + 1] = self.char.PrimaryPart.CFrame
                self.checkPoints:set(cTable)

                MapLib:Alert("Checkpoint added!", "white", 3)

            elseif id == "ClearCheck" then
                self.checkPoints:set({})

            elseif id == "Checkpoint" then
                self.char.PrimaryPart.CFrame = checkPoint

            elseif id == "ActivateAllBtns" then
                for _, btn in workspace:GetDescendants() do
                    self:_detectButton(btn)
                end
            end
        end,
        [OnEvent("MouseEnter")] = function()
            isSelecting:set(true)
        end,
        [OnEvent("MouseLeave")] = function()
            isSelecting:set(false)
        end,

        [Fusion.Children] = {
            Components.UIAspectRatioConstraint(scope, 6.449),

            New(scope, "UICorner")({ CornerRadius = udNew(0.2, 0) }),
            New(scope, "UIPadding")({
                PaddingTop = udNew(0.1, 0),
                PaddingBottom = udNew(0.1, 0)
            })
        }
    })
end

return ButtonOption
