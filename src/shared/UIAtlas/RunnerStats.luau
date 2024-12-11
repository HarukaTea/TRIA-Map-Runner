--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.Shared.UIAtlas.Vanilla)
local Fusion = require(RepS.Shared.Shared.Fusion)
local MapDataBook = require(RepS.Shared.Library.MapDataBook)
local HarukaLib = require(RepS.Shared.Shared.HarukaLib)
local TwilightTheme = require(RepS.Shared.Library.TwilightTheme)

local Pinia = require(RepS.Shared.UIAtlas.Pinia.RunnerStatsPinia)

local Children = Fusion.Children

local RunnerStats = {}
RunnerStats.__index = RunnerStats

local v2New = Vector2.new
local fromScale = UDim2.fromScale
local fromRGB = Color3.fromRGB

return function (plr: Player)
    local self = setmetatable({}, RunnerStats)

    self.plr = plr
    self.char = plr.Character or plr.CharacterAdded:Wait()

    repeat task.wait() until self.char:GetAttribute("CharDataLoaded")

    Pinia(self)

    local scope = self.scope :: Fusion.Scope
    Components.ScreenGui(scope, {
        Name = "RunnerStats",
        Parent = plr.PlayerGui,

        [Children] = {
            Components.HarukaFrame(scope, {
                Name = "Bottom",
                AnchorPoint = v2New(0.5, 1),
                Position = fromScale(0.5, 1),

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

                            Fusion.ForPairs(scope, { "Spectate", "Folder", "Settings" }, function(_, localScope: Fusion.Scope, index: number, selection: string)
                                return index, Components.ImageLabel(localScope, {
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
                                            return fromScale(math.clamp((use(self.oxygen) + use(self.tankOxygen)) / use(self.maxOxygen), 0, 1), 1)
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
                                    return "Oxygen: "..math.floor(use(self.oxygen) + use(self.tankOxygen))
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
                            return use(HarukaLib:ConvertTime(use(self.currentTime)))
                        end),
                        TextColor3 = Fusion.Computed(scope, function(use: Fusion.Use)
                            return if use(self.isSurvived) then TwilightTheme.green else Color3.new(1, 1, 1)
                        end),

                        [Children] = {
                            Components.TextUIStroke(scope, { Thickness = 1 })
                        }
                    })
                }
            })
        }
    })

    --// Clear
	local function onDead()
		Fusion.doCleanup(scope)

        self = nil
	end
	self.char.Humanoid.Died:Once(onDead)
end