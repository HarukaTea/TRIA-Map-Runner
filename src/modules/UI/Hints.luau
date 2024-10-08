--!nocheck

local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")

local Components = require(RepS.Modules.UI.Vanilla)
local Events = require(RepS.Modules.Data.Events)
local Fusion = require(RepS.Modules.Packages.Fusion)
local Signals = require(RepS.Modules.Data.Signals)

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
			Fusion.New(scope, "Frame")({
				Name = "BG",
				BackgroundTransparency = 1,
				Size = fromScale(1, 0.85),
				ZIndex = 999,

				[Children] = {
					Components.UIListLayout(scope, {
						Padding = udNew(0, 5),
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
                        VerticalAlignment = Enum.VerticalAlignment.Bottom,
					}),

					Fusion.ForValues(scope, hintList, function(_, localScope: Fusion.Scope, hint: StringValue)
						local label = Components.TextLabel(localScope, {
							Name = "Hint",
							Size = ud2New(1, 0, 0, 24),
							Text = hint.Value,
							FontFace = Font.fromName("Nunito", Enum.FontWeight.Bold),
							TextColor3 = hint:GetAttribute("Color"),
							TextStrokeTransparency = 0,
							LayoutOrder = hint:GetAttribute("DisplayOrder"),
						})

						table.insert(localScope, task.delay(hint:GetAttribute("Duration") - 0.25, function()
							TS:Create(label, TweenInfo.new(0.2), { TextTransparency = 1 }):Play()
						end))

						return label
					end)
				},
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
		hintList:set(hintsFolder:GetChildren())
	end
	table.insert(scope, hintsFolder.ChildAdded:Connect(updateHints))
	table.insert(scope, hintsFolder.ChildRemoved:Connect(updateHints))


	---
	local displayOrder = 0
	local function _createHint(text: string, color: Color3 | string, duration: string?)
		local colorList = {
			RED = fromRGB(255, 0, 0),
			GREEN = fromRGB(0, 255, 0),
			BLUE = fromRGB(0, 0, 255),
			YELLOW = fromRGB(255, 255, 0),
			ORANGE = fromRGB(255, 165, 0),
			PURPLE = fromRGB(128, 0, 128),
			PINK = fromRGB(255, 192, 203),
			WHITE = fromRGB(255, 255, 255),
			BLACK = fromRGB(0, 0, 0),
			GREY = fromRGB(128, 128, 128),
			LIGHTGREY = fromRGB(192, 192, 192),
			DARKGREY = fromRGB(64, 64, 64),
			BROWN = fromRGB(165, 42, 42),
		}

		if typeof(color) == "string" then
			color = colorList[string.upper(color)] or fromRGB(255, 255, 255)
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
