
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local MapDataBook = require(RepS.HarukaShared.Library.MapDataBook)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local TwilightTheme = require(RepS.HarukaShared.Library.TwilightTheme)

local Children = Fusion.Children


local v2New = Vector2.new
local fromScale = UDim2.fromScale
local fromRGB = Color3.fromRGB


local Pinia = require(script.Pinia)



return function (plr: Player)
    local self = {} :: Pinia.Self

    self.plr = plr
    self.char = plr.Character or plr.CharacterAdded:Wait()

    repeat task.wait() until self.char:GetAttribute("_CharDataLoaded")


    Pinia(self)


    local scope = self.scope :: Fusion.Scope<any>
    Components.HarukaScreenGui(scope, {
        Name = "TRIAMain",
        Parent = plr.PlayerGui,

    }, {
        BottomProps = {
            [Children] = {
                Fusion.New(scope, "Frame")({
                    Name = "FakeBG",
                    BackgroundColor3 = fromRGB(30, 30, 30),
                    Size = fromScale(0.27, 1),
                    ZIndex = 0,
                }),

                Fusion.New(scope, "Frame")({
                    Name = "Selections",
                    BackgroundTransparency = 1,
                    AnchorPoint = v2New(0, 0.5),
                    Position = fromScale(0.01, 0.5),
                    Size = fromScale(0.09, 0.5),

                    [Children] = {
                        Components.UIListLayout(scope, {
                            VerticalAlignment = Enum.VerticalAlignment.Center,
                            FillDirection = Enum.FillDirection.Horizontal,
                            Padding = UDim.new(0.1, 0)
                        }),

                        Fusion.ForPairs(scope, { "Spectate", "Folder", "Settings" }, function(_, scope: Fusion.Scope<any>, index: number, selection: string)
                            return index, Components.ImageLabel(scope, {
                                Name = selection,
                                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                                Image = MapDataBook.SelectionIcons[selection],
                            })
                        end)
                    }

                }),

                Fusion.New(scope, "Frame")({
                    Name = "OxygenBG",
                    BackgroundColor3 = fromRGB(30, 30, 30),
                    Position = fromScale(0.1, 0),
                    Size = fromScale(0.16, 1),
                    BackgroundTransparency = 1,

                    [Children] = {
                        Components.UIListLayout(scope, {
                            HorizontalAlignment = Enum.HorizontalAlignment.Center,
                            VerticalAlignment = Enum.VerticalAlignment.Center,
                            Padding = UDim.new(0.1, 0)
                        }),
                        Fusion.New(scope, "Frame")({
                            Name = "OxygenBarBG",
                            Size = fromScale(0.9, 0.1),
                            LayoutOrder = 1,
                            BackgroundColor3 = fromRGB(),

                            [Children] = {
                                Fusion.New(scope, "Frame")({
                                    Name = "OxygenBar",

                                    Size = Fusion.Tween(scope, Fusion.Computed(scope, function(use: Fusion.Use)
                                        return fromScale(math.clamp((use(self.Oxygen) + use(self.TankOxygen)) / use(self.MaxOxygen), 0, 1), 1)
                                    end), TweenInfo.new(0.5)),

                                    [Children] = {
                                        Fusion.New(scope, "UIGradient")({
                                            Color = TwilightTheme.gradient
                                        })
                                    }
                                })
                            }
                        }),
                        Components.TextLabel(scope, {
                            Name = "OxygenStats",
                            Size = fromScale(0.9, 0.45),
                            LayoutOrder = 0,
                            FontFace = Font.fromName("Nunito", Enum.FontWeight.Bold),

                            Text = Fusion.Computed(scope, function(use: Fusion.Use)
                                return "Oxygen: "..math.floor(use(self.Oxygen) + use(self.TankOxygen))
                            end)
                        })
                    }

                }),
                Fusion.New(scope, "Frame")({
                    Name = "TriangleBorder",
                    ZIndex = 0,
                    AnchorPoint = v2New(0, 0.5),
                    Size = fromScale(2, 2),
                    SizeConstraint = Enum.SizeConstraint.RelativeYY,
                    Position = fromScale(0.23, 1.35),
                    Rotation = 45,
                    BackgroundColor3 = fromRGB(30, 30, 30),

                    [Children] = {
                        Fusion.New(scope, "UICorner")({ CornerRadius = UDim.new(0.1, 0) })
                    }
                }),

                Components.TextLabel(scope, {
                    Name = "Timer",
                    AnchorPoint = v2New(0.5, 0),
                    Position = fromScale(0.5, 0.4),
                    Size = fromScale(0.98, 0.45),
                    FontFace = Font.fromName("Nunito", Enum.FontWeight.Bold),
                    TextXAlignment = Enum.TextXAlignment.Right,

                    Text = Fusion.Computed(scope, function(use: Fusion.Use)
                        return use(HarukaLib:TimeifyNumber(use(self.CurrentTime), true))
                    end),
                    TextColor3 = Fusion.Computed(scope, function(use: Fusion.Use)
                        return if use(self.IsSurvived) then TwilightTheme.green else Color3.new(1, 1, 1)
                    end),

                    [Children] = {
                        Components.TextUIStroke(scope, { Thickness = 1 })
                    }
                })
            }
        }
    })


    return function ()
        Fusion.doCleanup(scope)
    end
end