--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)

local MapLib = game.GetMapLib:Invoke()()

local New, OnEvent = Fusion.New, Fusion.OnEvent

local fromScale = UDim2.fromScale
local udNew = UDim.new
local fromRGB = Color3.fromRGB

local Texts = {
    AddCheck = "Add Checkpoint (X)",
    ClearCheck = "Clear All",
    ActivateAllBtns = "Activate Buttons",
    DEBUG = "_DEBUG ONLY"
}

return function (scope: Fusion.Scope, props: {
    ButtonId: string,
    CheckPoint: CFrame | BasePart?,
    Index: number?,
    Order: number,

}, self: table) : TextButton

    props = props or {}

    local isSelecting = Fusion.Value(scope, false)
    local index = props.Order
    if props.Index then
        local isTune = props.ButtonId == "CheckTPTune"
        index = math.ceil(props.Index + 1 + (isTune and 23 or 233))
    end

    return Components.TextButton(scope, {
        Name = "ButtonOption_"..props.ButtonId,
        Size = fromScale(0.9, 0.11),
        AutoButtonColor = false,
        LayoutOrder = index,

        Text = Fusion.Computed(scope, function()
            if props.ButtonId == "CheckTP" then
                return "Check #"..props.Index

            elseif props.ButtonId == "CheckTPTune" then
                return props.CheckPoint.Name
            else
                return Texts[props.ButtonId]
            end
        end),

        BackgroundColor3 = Fusion.Computed(scope, function(use: Fusion.Use)
            return if use(isSelecting) then fromRGB(255, 255, 255) else fromRGB(28, 28, 37)
        end),
        TextColor3 = Fusion.Computed(scope, function(use: Fusion.Use)
            return if use(isSelecting) then fromRGB() else fromRGB(255, 255, 255)
        end),

        [OnEvent("MouseButton1Click")] = function()
            if props.ButtonId == "AddCheck" then
                local checkPoint = Instance.new("CFrameValue")
                checkPoint.Value = self.plr.Character.PrimaryPart.CFrame
                checkPoint.Name = "_Checkpoint"
                checkPoint.Parent = self.CheckPointsContainer

                MapLib:Alert(`[Fallen Panel] Checkpoint Added!`, "green", 3)

            elseif props.ButtonId == "ClearCheck" then
                self.CheckPointsContainer:ClearAllChildren()

                MapLib:Alert("[Fallen Panel] All Checkpoints Cleared!", "red", 3)

            elseif props.ButtonId == "CheckTP" then
                self.plr.Character.PrimaryPart.CFrame = props.CheckPoint * CFrame.new(0, 2.7, 0)

            elseif props.ButtonId == "CheckTPTune" then
                self.plr.Character.PrimaryPart.CFrame = props.CheckPoint.CFrame * CFrame.new(0, 2.7, 0)

            elseif props.ButtonId == "ActivateAllBtns" then
                for _, btn: Instance in workspace:GetDescendants() do
                    self:_detectButton(btn)
                end

                MapLib:Alert("[Fallen Panel] Buttons Activated!", "green", 3)


            elseif props.ButtonId == "DEBUG" then
                for _, descendant in workspace:GetDescendants() do
                    if descendant.Name == "Tune" and descendant:IsA("Folder") and descendant:FindFirstAncestorOfClass("Model") then
                        for _, child in descendant:GetChildren() do
                            warn(child.Name)
                        end
                    end
                end
                for _, descendant in workspace:GetDescendants() do
                    if descendant.Name == "Tower2" and descendant:IsA("BasePart") then
                        warn(descendant.Parent)
                    end
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
            Components.UIAspectRatioConstraint(scope, 6.919),
            Components.UIPadding(scope, {}),

            New(scope, "UICorner")({ CornerRadius = udNew(0.25, 0) }),
        }
    })
end
