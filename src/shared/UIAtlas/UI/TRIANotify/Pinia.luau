
local Debris = game:GetService("Debris")
local RepS = game:GetService("ReplicatedStorage")

local Events = require(RepS.HarukaShared.Library.Events)
local Bindables = require(RepS.HarukaShared.Library.Bindables)
local FusionComponents = require(RepS.HarukaShared.UIAtlas.FusionComponents)
local TwilightTheme = require(RepS.HarukaShared.Library.TwilightTheme)

local Fusion = require(RepS.HarukaShared.Shared.Fusion)


return function (self: table)
    self.scope = Fusion.scoped({})
    local scope = self.scope :: Fusion.Scope


    local hintsFolder = Instance.new("Folder")
	hintsFolder.Name = "Haruka_UIHints_Container"
	hintsFolder.Parent = game:GetService("ServerStorage")
	table.insert(scope, hintsFolder)


    self.HintList = FusionComponents.useFolder(scope, hintsFolder)



	local displayOrder = 0
	local function _createHint(text: string, color: Color3 | string, duration: string?)
		if typeof(color) == "string" then
			color = TwilightTheme[string.lower(color)] or Color3.fromRGB(255, 255, 255)
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
	table.insert(scope, Bindables.CreateHint:Connect(_createHint))
end