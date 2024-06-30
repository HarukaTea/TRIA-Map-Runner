--!nocheck

local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)

local Children = Fusion.Children

local v2New, udNew = Vector2.new, UDim.new
local fromScale = UDim2.fromScale
local fromRGB = Color3.fromRGB

return function (plr: Player)
    local scope = Fusion.scoped({})

    local char = plr.Character or plr.CharacterAdded:Wait()
    local oxygen = Fusion.Value(scope, 100)
    local maxOxygen = Fusion.Value(scope, 100)

    table.insert(scope, HarukaLib:Hydrate(char, {
        ["Attr-CurrentOxygen"] = function(o2: number)
            oxygen:set(o2)
        end,
        ["Attr-MaxOxygen"] = function(maxo2: number)
            maxOxygen:set(maxo2)
        end
    }))

    Components.ScreenGui(scope, {
        Name = "RunnerStats",
        Parent = plr.PlayerGui,

        [Children] = {
            Components.Frame(scope, {
                Name = "Bottom",
                AnchorPoint = v2New(0.5, 1),
                Position = fromScale(0.5, 0.97),
                Size = fromScale(1, 0.1),

                [Children] = {
                    Fusion.New(scope, "UIAspectRatioConstraint")({ AspectRatio = 25.111 }),
                    Fusion.New(scope, "UIListLayout")({
                        Padding = udNew(0.015, 0),
                        FillDirection = Enum.FillDirection.Horizontal,
                        VerticalAlignment = Enum.VerticalAlignment.Center,
                        HorizontalAlignment = Enum.HorizontalAlignment.Left,
                    }),

                    Components.Frame(scope, {
                        Name = "1-Padding",
                        Size = UDim2.new(0, 1, 0, 1),
                    }),

                    Components.ImageLabel(scope, {
                        Name = "A-RunnerAvatar",
                        Image = Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48),
                        Size = fromScale(0.8, 0.8),
                        SizeConstraint = Enum.SizeConstraint.RelativeYY,
                        BackgroundTransparency = 0,

                        [Children] = {
                            Components.RoundUICorner(scope)
                        }
                    }),
                    Components.Frame(scope, {
                        Name = "B-OxygenBar",
                        Size = fromScale(0.2, 0.5),
                        BackgroundTransparency = 0,

                        [Children] = {
                            Components.RoundUICorner(scope),

                            Components.Frame(scope, {
                                Name = "Bar",
                                AnchorPoint = v2New(),
                                Position = fromScale(0, 0),
                                BackgroundColor3 = fromRGB(71, 103, 162),
                                BackgroundTransparency = 0,

                                Size = Fusion.Tween(scope, Fusion.Computed(scope, function(use)
                                    return fromScale(math.clamp(use(oxygen) / use(maxOxygen), 0, 1), 1)
                                end), TweenInfo.new(0.5, Enum.EasingStyle.Back)),

                                [Children] = {
                                    Components.RoundUICorner(scope)
                                }
                            }),
                            Components.TextLabel(scope, {
                                Name = "Title",
                                ZIndex = 2,
                                Size = fromScale(1, 1),
                                Text = "AIR",
                                TextXAlignment = Enum.TextXAlignment.Left,

                                [Children] = {
                                    Fusion.New(scope, "UIPadding")({
                                        PaddingTop = udNew(0.1, 0),
                                        PaddingBottom = udNew(0.1, 0),
                                        PaddingLeft = udNew(0.05, 0),
                                        PaddingRight = udNew(0.05, 0),
                                    })
                                }
                            }),
                            Components.TextLabel(scope, {
                                Name = "OxygenStats",
                                ZIndex = 2,
                                Size = fromScale(1, 1),
                                TextXAlignment = Enum.TextXAlignment.Right,

                                Text = Fusion.Computed(scope, function(use)
                                    return use(oxygen).."/"..use(maxOxygen)
                                end),

                                [Children] = {
                                    Fusion.New(scope, "UIPadding")({
                                        PaddingTop = udNew(0.1, 0),
                                        PaddingBottom = udNew(0.1, 0),
                                        PaddingLeft = udNew(0.05, 0),
                                        PaddingRight = udNew(0.05, 0),
                                    })
                                }
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
	char.Humanoid.Died:Once(onDead)
end