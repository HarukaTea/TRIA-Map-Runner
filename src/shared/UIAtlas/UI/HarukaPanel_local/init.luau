--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local ButtonOption = require(script.Components.ButtonOption)
local TypeOption = require(script.Components.TypeOption)
local ToggleOption = require(script.Components.ToggleOption)
local TitleSection = require(script.Components.TitleSection)

local Children, Computed, OnEvent = Fusion.Children, Fusion.Computed, Fusion.OnEvent

local v2New = Vector2.new
local fromScale = UDim2.fromScale


return function (plr: Player)
    local self = {}

    self.scope = Fusion.scoped()
    self.plr = plr


    require(script.Pinia)(self)


    local scope = self.scope :: Fusion.Scope
    local isSelecting = Fusion.Value(scope, false)


    local device = HarukaLib:GetAccurateDevice()
    local isMobile = false
    if device == "Phone" then
        isMobile = true
    end

    local BUTTON_POS = fromScale(0.99, -0.5 + 0.2)
    local PANEL_POS = fromScale(0.99, -5.7 + 0.2)
    if isMobile and device == "Phone" then
        BUTTON_POS = fromScale(0.99, 0.3)
        PANEL_POS = fromScale(0.99, -5.7 + 1 - 0.3)
    end

    self.UI = nil; self.UI = Components.HarukaScreenGui(scope, {
        Name = "HarukaPanel",
        DisplayOrder = 15,
        AutoLocalize = false,
        Parent = plr.PlayerGui,

    }, {
        BottomProps = {
            [Children] = {
                Components.TextButton(scope, {
                    Name = "OpenBtn",
                    AnchorPoint = v2New(1, 0),
                    Position = BUTTON_POS,
                    Size = fromScale(0.165, 0.5),
                    Text = "Fallen Panel (C)",
                    BackgroundTransparency = 0.2,
                    AutoLocalize = false,

                    [Children] = {
                        Components.UIPadding(scope, {
                            PaddingTop = UDim.new(0.05, 0),
                            PaddingBottom = UDim.new(0.05, 0),
                        }),
                        Fusion.New(scope, "UICorner")({ CornerRadius = UDim.new(0.25, 0) }),

                        Components.UIStroke(scope, {
                            Thickness = 2,

                            Transparency = Fusion.Computed(scope, function(use: Fusion.Use)
                                return if use(isSelecting) then 0 else 1
                            end)
                        })
                    },
                    [OnEvent("MouseButton1Click")] = function()
                        self.PanelOpen:set(not Fusion.peek(self.PanelOpen))
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
                    AnchorPoint = v2New(1, 0),
                    Position = PANEL_POS,
                    BackgroundTransparency = 0.2,
                    Size = fromScale(0.165, 5),
                    AutoLocalize = false,

                    Visible = Computed(scope, function(use)
                        return use(self.PanelOpen)
                    end),

                    [Children] = {
                        Fusion.New(scope, "UICorner")({ CornerRadius = UDim.new(0.04, 0) }),

                        Components.ScrollingFrame(scope, {
                            Name = "Panel",
                            AnchorPoint = v2New(0.5, 0.5),
                            Position = fromScale(0.5, 0.5),
                            ScrollingDirection = Enum.ScrollingDirection.Y,

                            [Children] = {
                                Components.PaddingFrame(scope, "AAA"),

                                --- controls
                                TitleSection(scope, { TitleId = "Controls", Order = 1, }, self),

                                TypeOption(scope, { TypeId = "Speed", Order = 2, }, self),
                                ToggleOption(scope, { ToggleId = "ForceSpeed", Order = 3, }, self),

                                TypeOption(scope, { TypeId = "Jump", Order = 4, }, self),
                                ToggleOption(scope, { ToggleId = "ForceJump", Order = 5, }, self),

                                TypeOption(scope, { TypeId = "Noclip", Order = 6, }, self),

                                --- map
                                TitleSection(scope, { TitleId = "Map", Order = 7, }, self),

                                --ButtonOption(scope, { ButtonId = "TimeStopMap", Order = 8, }, self),

                                ToggleOption(scope, { ToggleId = "Waters", Order = 9, }, self),
                                ToggleOption(scope, { ToggleId = "Lights", Order = 10, }, self),
                                ToggleOption(scope, { ToggleId = "Shadows", Order = 11, }, self),
                                ToggleOption(scope, { ToggleId = "Shaders", Order = 12, }, self),
                                ToggleOption(scope, { ToggleId = "DisableKillbrick", Order = 13, }, self),
                                ToggleOption(scope, { ToggleId = "ShowMedals", Order = 14, }, self),

                                TypeOption(scope, { TypeId = "Buttons", Order = 15, }, self),
                                ToggleOption(scope, { ToggleId = "SkipBtns", Order = 16, }, self),
                                ButtonOption(scope, { ButtonId = "ActivateAllBtns", Order = 17, }, self),

                                ToggleOption(scope, { ToggleId = "InfAir", Order = 18, }, self),

                                --- checkpoints
                                TitleSection(scope, { TitleId = "Checkpoints", Order = 19, }, self),

                                ButtonOption(scope, { ButtonId = "AddCheck", Order = 20, }, self),
                                ButtonOption(scope, { ButtonId = "ClearCheck", Order = 21, }, self),


                                TitleSection(scope, { TitleId = "CheckpointsTune", Order = 22, }, self),

                                Fusion.ForPairs(scope, self.TuneCheckPoints, function(_, scope: table, index: number, part: BasePart)
                                    return index, ButtonOption(scope, {
                                        ButtonId = "CheckTPTune", CheckPoint = part, Index = index,
                                    }, self)
                                end),

                                TitleSection(scope, { TitleId = "CheckpointsNormal", Order = 233, }, self),

                                Fusion.ForPairs(scope, self.CheckPoints, function(_, scope: table, index: number, checkPoint: CFrameValue)
                                    return index, ButtonOption(scope, {
                                        ButtonId = "CheckTP", CheckPoint = checkPoint.Value, Index = index,
                                    }, self)
                                end),


                                Components.PaddingFrame(scope, "ZZZ"),
                            }
                        }, {
                            Padding = UDim.new(0, 8),
                            HorizontalAlignment = Enum.HorizontalAlignment.Center,
                        })
                    }
                })
            }
        }
    })
end
