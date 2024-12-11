--!nocheck

local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")

local Components = require(RepS.Shared.UIAtlas.Vanilla)
local Events = require(RepS.Shared.Library.Events)
local Fusion = require(RepS.Shared.Shared.Fusion)
local Signals = require(RepS.Shared.Library.Signals)

local TwilightTheme = require(RepS.Shared.Library.TwilightTheme)

local Children = Fusion.Children

local udNew, ud2New = UDim.new, UDim2.new
local fromScale = UDim2.fromScale
local fromRGB = Color3.fromRGB

return function(plr: Player)
	local scope = Fusion.scoped({})
	local hintList = Fusion.Value(scope, {})

	local char = plr.Character or plr.CharacterAdded:Wait()

	Components.ScreenGui(scope, {
		Name = "Hints",
		DisplayOrder = 5,
		Parent = plr.PlayerGui,

		[Children] = {
			Components.HarukaFrame(scope, {
				Name = "Bottom",
				AnchorPoint = Vector2.new(0.5, 0.8),
				Position = fromScale(0.5, 0.8),

				[Children] = {
					Components.Frame(scope, {
						Name = "Hints",

						[Children] = {
							Components.UIListLayout(scope, {
								Padding = udNew(0, 5),
								HorizontalAlignment = Enum.HorizontalAlignment.Center,
								VerticalAlignment = Enum.VerticalAlignment.Bottom,
							}),

							Fusion.ForValues(scope, hintList, function(_, localScope: Fusion.Scope, hint: StringValue)
								local label = Components.TextLabel(localScope, {
									Name = "Hint",
									Size = UDim2.fromScale(1, 0.5),
									Text = hint.Value,
									FontFace = Font.fromName("Nunito", Enum.FontWeight.Bold),
									TextColor3 = hint:GetAttribute("Color"),
									TextStrokeTransparency = 0,
									LayoutOrder = hint:GetAttribute("LayoutOrder")
								})

								table.insert(localScope, task.delay(hint:GetAttribute("Duration") - 0.25, function()
									TS:Create(label, TweenInfo.new(0.2), { TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
								end))

								return label
							end)
						}
					})
				}
			}),
		},
	})

	--// Connections

	local hintsFolder = Instance.new("Folder")
	hintsFolder.Name = "FALLEN_Container"
	hintsFolder.Parent = char
	table.insert(scope, hintsFolder)

	local function updateHints()
		task.wait()
		hintList:set(table.freeze(hintsFolder:GetChildren()))
	end
	table.insert(scope, hintsFolder.ChildAdded:Connect(updateHints))
	table.insert(scope, hintsFolder.ChildRemoved:Connect(updateHints))


	---
	local displayOrder = 0
	local function _createHint(text: string, color: Color3 | string, duration: string?)
		if typeof(color) == "string" then
			color = TwilightTheme[string.lower(color)] or fromRGB(255, 255, 255)
		end

		displayOrder += 1
		if displayOrder >= math.huge - 1 then displayOrder = 0 end

		duration = tonumber(duration) or 5

		local hint = Instance.new("StringValue")
		hint.Name = "Hint"
		hint.Value = text
		hint:SetAttribute("Duration", duration)
		hint:SetAttribute("Color", color)
		hint:SetAttribute("LayoutOrder", displayOrder)
		hint.Parent = hintsFolder
		Debris:AddItem(hint, duration)
	end
	table.insert(scope, Events.CreateHint.On(function(data)
		local text, color, duration = data.Hint, data.Color, data.Duration

		_createHint(text, color, duration)
	end))
	table.insert(scope, Signals.CreateHint:Connect(_createHint))


	--// Clear
	local function onDead()
		Fusion.doCleanup(scope)
	end
	char.Humanoid.Died:Once(onDead)
end
