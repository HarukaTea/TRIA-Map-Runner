
local RepS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")

local Components = require(RepS.HarukaShared.UIAtlas.HarukaComponents)
local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local HarukaListLayout = require(RepS.HarukaShared.Shared.HarukaListLayout)

local Children = Fusion.Children

local udNew = UDim.new
local fromScale = UDim2.fromScale


return function(plr: Player)
	local self = {}
	local scope = Fusion.scoped({})

	self.plr = plr
	self.char = plr.Character or plr.CharacterAdded:Wait()


	require(script.Pinia)(self)


	local UI = Components.HarukaScreenGui(scope, {
		Name = "TRIANotify",
		DisplayOrder = 5,
		Parent = plr.PlayerGui,

	}, {
		BottomProps = {
			AnchorPoint = Vector2.new(0.5, 0.8),
			Position = fromScale(0.5, 0.8),

			[Children] = {
				Components.Frame(scope, {
					Name = "Hints",

					[Children] = {
						Components.UIListLayout(scope, {
							Padding = udNew(0, 6),
							HorizontalAlignment = Enum.HorizontalAlignment.Center,
							VerticalAlignment = Enum.VerticalAlignment.Bottom,
						}),

						Fusion.ForValues(scope, self.HintList, function(_, scope: Fusion.Scope, hint: StringValue)
							local label = Components.TextLabel(scope, {
								Name = "Hint",
								Size = UDim2.fromScale(1, 0.5),
								Text = hint.Value,
								FontFace = Font.fromName("Nunito", Enum.FontWeight.Bold),
								TextColor3 = hint:GetAttribute("Color"),
								TextStrokeTransparency = 0,
								LayoutOrder = hint:GetAttribute("LayoutOrder")
							})


							HarukaLib:CreateTween(label, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, hint:GetAttribute("Duration") - 0.5), {
								TextStrokeTransparency = 1,
								TextTransparency = 1
							}):Play()

							return label
						end)
					}
				})
			}
		}
	})


	local AGLObj = HarukaListLayout.new(UI.Bottom.Hints.UIListLayout)
	AGLObj:Enable()
	table.insert(scope, AGLObj)


	return function ()
		Fusion.doCleanup(scope)
	end
end