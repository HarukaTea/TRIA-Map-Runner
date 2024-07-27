--!nocheck

local HttpService = game:GetService("HttpService")
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.Modules.UI.Vanilla)
local Events = require(RepS.Modules.Data.Events)
local Fusion = require(RepS.Modules.Packages.Fusion)
local Signals = require(RepS.Modules.Data.Signals)

local Children = Fusion.Children

local wait = task.wait
local v2New, udNew, ud2New = Vector2.new, UDim.new, UDim2.new
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
			Components.Frame(scope, {
				Name = "BG",
                AnchorPoint = v2New(),
				Position = fromScale(0, 0),
				Size = fromScale(1, 0.85),
				ZIndex = 999,

				[Children] = {
					Fusion.New(scope, "UIListLayout")({
						Padding = udNew(0, 5),
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
                        VerticalAlignment = Enum.VerticalAlignment.Bottom,
						SortOrder = Enum.SortOrder.LayoutOrder
					}),

					Fusion.ForValues(scope, hintList, function(_, localScope, info: table)
						return Components.TextLabel(localScope, {
							Name = "Hint",
							Size = ud2New(1, 0, 0, 24),
							Text = info.Text,
							FontFace = Font.fromName("Nunito", Enum.FontWeight.Bold),
							TextColor3 = info.Color,
							TextStrokeTransparency = 0,
							LayoutOrder = info.DisplayOrder,
						})
					end)
				},
			}),

		},
	})

	--// Connections
	local displayOrder = 0
	local function _createHint(text: string, color: Color3 | string, duration: string?)
		local uniqueId = HttpService:GenerateGUID(false)
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

		local info = {
			Id = uniqueId,
			Text = text or "",
			Color = color or fromRGB(255, 255, 255),
			Duration = tonumber(duration) or 5,
			DisplayOrder = displayOrder
		}
		displayOrder += 1
		if displayOrder >= math.huge - 1 then displayOrder = 0 end

		local new = Fusion.peek(hintList)
		new[uniqueId] = info

		hintList:set(new)

		wait(info.Duration)
		local future = Fusion.peek(hintList)
		if future[uniqueId] then future[uniqueId] = nil end

		hintList:set(future)
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
