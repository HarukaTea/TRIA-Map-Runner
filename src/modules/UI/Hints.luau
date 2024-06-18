--!nocheck

local HttpService = game:GetService("HttpService")
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.Modules.UI.Vanilla)
local Events = require(RepS.Modules.Data.Events)
local Fusion = require(RepS.Modules.Packages.Fusion)
local Signals = require(RepS.Modules.Data.Signals)
local Spawn = require(RepS.Modules.Packages.Spawn)

local Children = Fusion.Children

local wait = task.wait
local v2New, udNew, ud2New = Vector2.new, UDim.new, UDim2.new
local fromScale = UDim2.fromScale
local fromRGB = Color3.fromRGB

return function(plr: Player)
	local scope = Fusion.scoped({})
	local hintList = Fusion.Value(scope, {})

	local char = plr.Character or plr.CharacterAdded:Wait()
	local twiceHalfTween = TweenInfo.new(0.3)

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
                        VerticalAlignment = Enum.VerticalAlignment.Bottom
					}),

					Fusion.ForValues(scope, hintList, function(_, localScope, info: table)
						local trans = Fusion.Value(localScope, 0)
						Spawn(function()
							wait(info.Duration)
							trans:set(1, true)

							wait(0.3)
							local now = Fusion.peek(hintList)
							if now[info.Id] then now[info.Id] = nil end

							hintList:set(now)
						end)

						return Components.TextLabel(localScope, {
							Name = "Hint",
							Size = ud2New(1, 0, 0, 27),
							Text = info.Text,
							FontFace = Font.fromName("Nunito", Enum.FontWeight.Bold),
							TextColor3 = info.Color,

							TextTransparency = Fusion.Tween(localScope, Fusion.Computed(localScope, function(use)
								return use(trans)
							end), twiceHalfTween),
							TextStrokeTransparency = Fusion.Tween(localScope, Fusion.Computed(localScope, function(use)
								return use(trans)
							end), twiceHalfTween),
						})
					end)
				},
			}),

		},
	})

	--// Connections
	local function _createHint(text: string, duration: number, color: Color3?)
		local uniqueId = HttpService:GenerateGUID(false)
		local info = {
			Id = uniqueId,
			Text = text or "",
			Color = color or fromRGB(255, 255, 255),
			Duration = duration or 2
		}

		local new = Fusion.peek(hintList)
		new[uniqueId] = info

		hintList:set(new)
	end
	Events.CreateHint:Connect(_createHint)
	Signals.CreateHint:Connect(_createHint)

	--// Clear
	local function onDead()
		Events.CreateHint:DisconnectAll()
		Signals.CreateHint:DisconnectAll()

		Fusion.doCleanup(scope)
	end
	char.Humanoid.Died:Once(onDead)
end
