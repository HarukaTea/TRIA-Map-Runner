--!nocheck

local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local RF = game:GetService("ReplicatedFirst")
local RepS = game:GetService("ReplicatedStorage")
local SG = game:GetService("StarterGui")
local TS = game:GetService("TweenService")

local plr = Players.LocalPlayer


local function _createTempHolderGui()
    local holderGui = Instance.new("ScreenGui")
    holderGui.Name = "Temp_LoadScreen"
    holderGui.ScreenInsets = Enum.ScreenInsets.None
    holderGui.ClipToDeviceSafeArea = false
    holderGui.DisplayOrder = 998
    holderGui.Parent = plr.PlayerGui

    local frame = Instance.new("Frame")
    frame.Name = "Full"
    frame.Size = UDim2.fromScale(1, 1)
    frame.Position = UDim2.fromScale(0.5, 0.5)
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.BackgroundColor3 = Color3.fromRGB(28, 28, 37)
    frame.BackgroundTransparency = 0
    frame.ZIndex = 0
    frame.Parent = holderGui

    local bottom = Instance.new("Frame")
    bottom.Name = "Bottom"
    bottom.Size = UDim2.fromScale(1, 0.1)
    bottom.Position = UDim2.fromScale(0, 1)
    bottom.AnchorPoint = Vector2.new(0, 1)
    bottom.BackgroundTransparency = 1
    bottom.ZIndex = 1

    local uiAspectRatio = Instance.new("UIAspectRatioConstraint")
    uiAspectRatio.AspectRatio = 25.627
    uiAspectRatio.Parent = bottom


    local text = Instance.new("TextLabel")
    text.Name = "LoadingText"
    text.Position = UDim2.fromScale(0, -0.3)
    text.Size = UDim2.fromScale(1, 0.5)
    text.Text = "Initializing..."
    text.BackgroundTransparency = 1
    text.FontFace = Font.fromName("SourceSansPro", Enum.FontWeight.Bold)
    text.TextColor3 = Color3.fromRGB(255, 255, 255)
    text.TextScaled = true
    text.Parent = bottom

    bottom.Parent = holderGui

    return holderGui
end


do
    RF:RemoveDefaultLoadingScreen()

    SG:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
    SG:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)
end



do
    local holderGui = _createTempHolderGui()

    if not game.Loaded then
        game.Loaded:Wait()
    end

    repeat task.wait() until RepS:WaitForChild("HarukaShared", 999)
    repeat task.wait() until workspace:GetAttribute("Haruka_MapPreloadRun")


    local setting = workspace.Map:WaitForChild("Settings", 999) :: Configuration
    local mainSettings = setting.Main :: Configuration
    local mapDifficultyConfig = mainSettings:GetAttribute("Difficulty") or 0
    local mapNameConfig = mainSettings:GetAttribute("Name") or "[Unknown Map]"
    local mapImageConfig = mainSettings:GetAttribute("Image") or ""
    local creator = mainSettings:GetAttribute("Creator") or "[Unknown Creator]"

    local TwilightTheme = require(RepS.HarukaShared.Library.TwilightTheme)
    local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
    local Fusion = require(RepS.HarukaShared.Shared.Fusion)
    local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
    local MapDataBook = require(RepS.HarukaShared.Library.MapDataBook)

    local Children = Fusion.Children

    local scope = Fusion.scoped({})
    local function Value(val: any)
        return Fusion.Value(scope, val)
    end

    local mapNameAbsPos = Value(Vector2.zero)
    local mapNameAbsSize = Value(Vector2.zero)
    local mapNameSelfSize = Value(Vector2.zero)

    local function TRIAVividGradient() : UIGradient
        return Fusion.New(scope, "UIGradient")({
            Color = TwilightTheme.gradient
        })
    end
    local function ProgressBar() : Frame
        local bar = Fusion.New(scope, "Frame")({
            Name = "ProgressBar",
            Size = UDim2.fromScale(0, 0.1),
            Position = UDim2.fromScale(0, 1),
            AnchorPoint = Vector2.new(0, 1),
            ZIndex = 10,

            [Children] = { TRIAVividGradient() }
        })

        task.spawn(function()
            HarukaLib:CreateTween(bar, TweenInfo.new(1), {
                Size = UDim2.fromScale(0.3, 0.1)
            }):Play()

            repeat task.wait() until workspace.Map:GetAttribute("IsLoaded")

            HarukaLib:CreateTween(bar, TweenInfo.new(1), {
                Size = UDim2.fromScale(1, 0.1),
                BackgroundTransparency = 1
            }):Play()
        end)

        return bar
    end
    local function Triangle(props: {
        Position: UDim2, Size: UDim2, Index: number
    }) : Frame

        return Fusion.New(scope, "Frame")({
            Name = "Triangle",
            BackgroundColor3 = Color3.fromRGB(23, 0, 34),
            Rotation = 45,
            Size = props.Size,
            SizeConstraint = Enum.SizeConstraint.RelativeYY,
            ZIndex = 0,

            [Fusion.Out("AbsoluteSize")] = mapNameSelfSize,

            Position = Fusion.Computed(scope, function(use: Fusion.Use)
                if props.Index == 2 then
                    local absX = use(mapNameAbsPos).X
                    local x = use(mapNameAbsSize).X
                    local selfX = use(mapNameSelfSize).X / 2

                    return UDim2.new(0, absX + x - selfX, 0.32, 0)
                else
                    return props.Position
                end
            end)
        })
    end
    local UI = Components.HarukaScreenGui(scope, {
        Name = "LoadingScreen",
        DisplayOrder = 999,
        ScreenInsets = Enum.ScreenInsets.None,
        Parent = plr.PlayerGui,

        [Children] = {
            Components.HarukaFrame(scope, {
                Name = "Bottom",
                AnchorPoint = Vector2.new(0.5, 1),
                Position = UDim2.fromScale(0.5, 1),

                [Children] = {
                    ProgressBar(),

                    Fusion.New(scope, "Frame")({
                        Name = "Difficulty",
                        Position = UDim2.fromScale(-0.01, -0.5),
                        Size = UDim2.fromScale(0.08, 1.5),
                        BackgroundColor3 = Color3.fromRGB(23, 0, 34),
                        ZIndex = 3,

                        [Children] = {
                            Components.HoverImageButton(scope, {
                                Active = false,
                                Name = "IconBG",
                                Position = UDim2.fromScale(0.6, 0.5),
                                Size = UDim2.fromScale(0.8, 0.8),
                                SizeConstraint = Enum.SizeConstraint.RelativeYY,

                                [Children] = {
                                    Components.RoundUICorner(scope),
                                    Components.HoverImageButton(scope, {
                                        Active = false,
                                        Name = "Icon",
                                        Size = UDim2.fromScale(0.7, 0.7),
                                        SizeConstraint = Enum.SizeConstraint.RelativeYY,
                                        Image = MapDataBook.DifficultyImages[mapDifficultyConfig],

                                        [Children] = { Components.RoundUICorner(scope) }
                                    })
                                }
                            })
                        }
                    }),
                    Fusion.New(scope, "Frame")({
                        Name = "MapName",
                        Position = UDim2.fromScale(0.08, 0),
                        Size = UDim2.fromScale(0, 1),
                        AutomaticSize = Enum.AutomaticSize.X,
                        BackgroundColor3 = Color3.fromRGB(23, 0, 34),
                        ZIndex = 3,

                        [Fusion.Out("AbsoluteSize")] = mapNameAbsSize,
                        [Fusion.Out("AbsolutePosition")] = mapNameAbsPos,

                        [Children] = {
                            Components.TextLabel(scope, {
                                Name = "MapName",
                                AutomaticSize = Enum.AutomaticSize.X,
                                Size = UDim2.fromScale(0, 1),
                                FontFace = Font.fromName("Nunito", Enum.FontWeight.Bold),
                                TextXAlignment = Enum.TextXAlignment.Right,
                                Text = mapNameConfig,

                                [Children] = {
                                    TRIAVividGradient(),

                                    Components.UIPadding(scope, {
                                        PaddingLeft = UDim.new(0.2, 0),
                                        PaddingRight = UDim.new(0.2, 0),
                                        PaddingTop = UDim.new(0.2, 0),
                                        PaddingBottom = UDim.new(0.2, 0)
                                    })
                                }
                            })
                        }
                    }),
                    Components.ImageLabel(scope, {
                        Name = "TRIA_OS_LOGO",
                        Size = UDim2.fromScale(2.5, 2.5),
                        Position = UDim2.fromScale(0.88, -2.2),
                        SizeConstraint = Enum.SizeConstraint.RelativeYY,
                        Image = "rbxassetid://135598338652447",
                        ImageColor3 = MapDataBook.DifficultyColors[mapDifficultyConfig],
                    }),
                    Components.TextLabel(scope, {
                        Name = "Creators",
                        Position = UDim2.fromScale(0.09, -0.4),
                        Size = UDim2.fromScale(0.8, 0.4),
                        FontFace = Font.fromName("Nunito", Enum.FontWeight.Bold),
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Text = creator,
                    }),

                    Triangle({ Position = UDim2.fromScale(0.02, 0.04), Size = UDim2.fromScale(2.5, 2.5), Index = 1 }),
                    Triangle({ Position = nil, Size = UDim2.fromScale(1.5, 1.5), Index = 2 })
                }
            })
        }
    }, {
        FullProps = {
            BackgroundTransparency = 0,
            ZIndex = 0,

            [Children] = {
                Components.ImageLabel(scope, {
                    Name = "MapImage",
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.fromScale(0.5, 0.5),
                    Image = HarukaLib:CombineRbxId(mapImageConfig),
                })
            }
        },

        BottomProps = {
            [Children] = {
                ProgressBar(),

                Fusion.New(scope, "Frame")({
                    Name = "Difficulty",
                    Position = UDim2.fromScale(-0.01, -0.5),
                    Size = UDim2.fromScale(0.08, 1.5),
                    BackgroundColor3 = Color3.fromRGB(23, 0, 34),
                    ZIndex = 3,

                    [Children] = {
                        Components.HoverImageButton(scope, {
                            Active = false,
                            Name = "IconBG",
                            Position = UDim2.fromScale(0.6, 0.5),
                            Size = UDim2.fromScale(0.8, 0.8),
                            SizeConstraint = Enum.SizeConstraint.RelativeYY,

                            [Children] = {
                                Components.RoundUICorner(scope),
                                Components.HoverImageButton(scope, {
                                    Active = false,
                                    Name = "Icon",
                                    Size = UDim2.fromScale(0.7, 0.7),
                                    SizeConstraint = Enum.SizeConstraint.RelativeYY,
                                    Image = MapDataBook.DifficultyImages[mapDifficultyConfig],

                                    [Children] = { Components.RoundUICorner(scope) }
                                })
                            }
                        })
                    }
                }),
                Fusion.New(scope, "Frame")({
                    Name = "MapName",
                    Position = UDim2.fromScale(0.08, 0),
                    Size = UDim2.fromScale(0, 1),
                    AutomaticSize = Enum.AutomaticSize.X,
                    BackgroundColor3 = Color3.fromRGB(23, 0, 34),
                    ZIndex = 3,

                    [Fusion.Out("AbsoluteSize")] = mapNameAbsSize,
                    [Fusion.Out("AbsolutePosition")] = mapNameAbsPos,

                    [Children] = {
                        Components.TextLabel(scope, {
                            Name = "MapName",
                            AutomaticSize = Enum.AutomaticSize.X,
                            Size = UDim2.fromScale(0, 1),
                            FontFace = Font.fromName("Nunito", Enum.FontWeight.Bold),
                            TextXAlignment = Enum.TextXAlignment.Right,
                            Text = mapNameConfig,

                            [Children] = {
                                TRIAVividGradient(),

                                Components.UIPadding(scope, {
                                    PaddingLeft = UDim.new(0.2, 0),
                                    PaddingRight = UDim.new(0.2, 0),
                                    PaddingTop = UDim.new(0.2, 0),
                                    PaddingBottom = UDim.new(0.2, 0)
                                })
                            }
                        })
                    }
                }),
                Components.ImageLabel(scope, {
                    Name = "TRIA_OS_LOGO",
                    Size = UDim2.fromScale(2.5, 2.5),
                    Position = UDim2.fromScale(0.88, -2.2),
                    SizeConstraint = Enum.SizeConstraint.RelativeYY,
                    Image = "rbxassetid://135598338652447",
                    ImageColor3 = MapDataBook.DifficultyColors[mapDifficultyConfig],
                }),
                Components.TextLabel(scope, {
                    Name = "Creators",
                    Position = UDim2.fromScale(0.09, -0.4),
                    Size = UDim2.fromScale(0.8, 0.4),
                    FontFace = Font.fromName("Nunito", Enum.FontWeight.Bold),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Text = creator,
                }),

                Triangle({ Position = UDim2.fromScale(0.02, 0.04), Size = UDim2.fromScale(2.5, 2.5), Index = 1 }),
                Triangle({ Position = nil, Size = UDim2.fromScale(1.5, 1.5), Index = 2 })
            }
        }
    })
    HarukaLib:UITween(UI, "In", {
        TweenCallback = function()
            Debris:AddItem(holderGui, 1)
        end
    })


    repeat task.wait() until workspace.Map:GetAttribute("IsLoaded")

    HarukaLib:UITween(UI, "Out", {
        TweenCallback = function()
            Fusion.doCleanup(scope)
        end
    })
end
