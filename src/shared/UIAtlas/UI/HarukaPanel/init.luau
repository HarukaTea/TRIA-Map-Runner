--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)

local Pinia = require(script.Pinia)

local ButtonOption = require(script.Components.ButtonOption)
local TypeOption = require(script.Components.TypeOption)
local ToggleOption = require(script.Components.ToggleOption)

local Children, Computed, OnEvent = Fusion.Children, Fusion.Computed, Fusion.OnEvent

local v2New = Vector2.new
local fromScale = UDim2.fromScale

local HarukaPanel = {}
HarukaPanel.__index = HarukaPanel

return function (plr: Player)
    local self = setmetatable({}, HarukaPanel)

    workspace:WaitForChild("Map", 999)
    repeat task.wait() until workspace.Map:GetAttribute("IsStarted")

    self.char = plr.Character or plr.CharacterAdded:Wait()
    self.plr = plr

    Pinia(self)

    local scope = self.scope :: table
    local isSelecting = Fusion.Value(scope, false)

    Components.ScreenGui(scope, {
        Name = "HarukaPanel",
        DisplayOrder = 100,
        Parent = plr.PlayerGui,

        [Children] = {
            Components.HarukaFrame(scope, {
                Name = "Bottom",
                AnchorPoint = v2New(0.5, 1),
                Position = fromScale(0.5, 1),

                [Children] = {
                    Components.TextButton(scope, {
                        Name = "OpenBtn",
                        Position = fromScale(0.84, -0.1),
                        Size = fromScale(0.15, 0.5),
                        Text = "Fallen Panel (C)",

                        [Children] = {
                            Fusion.New(scope, "UIPadding")({
                                PaddingTop = UDim.new(0.05, 0),
                                PaddingBottom = UDim.new(0.05, 0)
                            }),
                            Fusion.New(scope, "UICorner")({ CornerRadius = UDim.new(0.2, 0) }),

                            Components.UIStroke(scope, {
                                Thickness = 2.5,

                                Transparency = Fusion.Tween(scope, Fusion.Computed(scope, function(use: Fusion.Use)
                                    return if use(isSelecting) then 0.3 else 1
                                end), TweenInfo.new(0.2))
                            })
                        },
                        [OnEvent("MouseButton1Click")] = function()
                            self.panelOpen:set(not Fusion.peek(self.panelOpen))
                        end,
                        [OnEvent("MouseEnter")] = function()
                            isSelecting:set(true)
                        end,
                        [OnEvent("MouseLeave")] = function()
                            isSelecting:set(false)
                        end
                    }),

                    Components.Frame(scope, {
                        Name = "PanelBG",
                        Position = fromScale(0.915, -2.8),
                        BackgroundTransparency = 0,
                        Size = fromScale(0.15, 5),

                        Visible = Computed(scope, function(use)
                            return use(self.panelOpen)
                        end),

                        [Children] = {
                            Fusion.New(scope, "UICorner")({ CornerRadius = UDim.new(0.02, 0) }),
                            Components.ScrollingFrame(scope, {
                                Name = "Panel",
                                AnchorPoint = v2New(0.5, 0.5),
                                Position = fromScale(0.5, 0.5),
                                Size = fromScale(0.9, 0.9),
                                ScrollBarThickness = 0,

                                [Children] = {
                                    TypeOption("Speed", self),
                                    ToggleOption("ForceSpeed", self),

                                    TypeOption("Jump", self),
                                    ToggleOption("ForceJump", self),

                                    TypeOption("Noclip", self),

                                    ToggleOption("Waters", self),
                                    ToggleOption("Lights", self),
                                    ToggleOption("Shadows", self),
                                    ToggleOption("Shaders", self),

                                    TypeOption("Buttons", self),
                                    ToggleOption("SkipBtns", self),
                                    ButtonOption("ActivateAllBtns", self),

                                    ToggleOption("InfAir", self),

                                    ButtonOption("AddCheck", self),
                                    ButtonOption("ClearCheck", self),

                                    Fusion.ForValues(scope, self.checkPoints, function(_, localScope: table, checkPoint: CFrame)
                                        return ButtonOption("Checkpoint", self, checkPoint, localScope)
                                    end)
                                }
                            }, {
                                Padding = UDim.new(0, 8),
                                SortOrder = Enum.SortOrder.LayoutOrder,
                                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                            })
                        }
                    })
                }
            })
        }
    })

    --// Clear
	local function onDead()
		Fusion.doCleanup(scope)
	end
	self.char.Humanoid.Died:Once(onDead)
end
