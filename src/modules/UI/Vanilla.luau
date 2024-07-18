--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Fusion = require(RepS.Modules.Packages.Fusion)

local Components = {}

local color3New, v2New, ud2New, udNew = Color3.new, Vector2.new, UDim2.new, UDim.new
local fromScale = UDim2.fromScale
local fromRGB = Color3.fromRGB
local fontFromName = Font.fromName

local function _createNewCompoent(scope: Fusion.Scope, props: table, uiType: string, default: table) : GuiObject
	for prop: string, val: any in props do
		default[prop] = val
	end

	return Fusion.New(scope, uiType)(default)
end

--[[
	Return a ScreenGui, without clips and insets
]]
function Components.ScreenGui(scope: Fusion.Scope, props: table) : ScreenGui
	return _createNewCompoent(scope, props, "ScreenGui", {
		ClipToDeviceSafeArea = false,
		ScreenInsets = Enum.ScreenInsets.None,
		IgnoreGuiInset = true,

		AutoLocalize = false,
	})
end

--[[
	Return a transparent frame, with a center anchor, and max size
]]
function Components.Frame(scope: Fusion.Scope, props: table) : Frame
	return _createNewCompoent(scope, props, "Frame", {
		AnchorPoint = v2New(0.5, 0.5),
		Position = fromScale(0.5, 0.5),
		Size = fromScale(1, 1),
		BackgroundColor3 = fromRGB(30, 30, 30),
		BackgroundTransparency = 1,

		AutoLocalize = false,
	})
end

--[[
	Return a transparent scrollable frame, with a center anchor, and no clips
]]
function Components.ScrollingFrame(scope: Fusion.Scope, props: table) : ScrollingFrame
	return _createNewCompoent(scope, props, "ScrollingFrame", {
		BackgroundColor3 = fromRGB(30, 30, 30),
		BackgroundTransparency = 1,
		AnchorPoint = v2New(0.5, 0.5),
		Position = fromScale(0.5, 0.5),
		CanvasSize = fromScale(0, 0),
		ScrollBarThickness = 0,

		AutoLocalize = false,
	})
end

--[[
	Return a transparent background text, with SourceSansPro bold font, white color
]]
function Components.TextLabel(scope: Fusion.Scope, props: table) : TextLabel
	return _createNewCompoent(scope, props, "TextLabel", {
		BackgroundColor3 = fromRGB(30, 30, 30),
		BackgroundTransparency = 1,
		FontFace = Font.fromName("SourceSansPro", Enum.FontWeight.Bold),
		TextScaled = true,
		TextColor3 = color3New(1, 1, 1),
		TextStrokeColor3 = color3New(),

		AutoLocalize = false,
	})
end

--[[
	Return a textbox, with SourceSansPro bold font, white color
]]
function Components.TextBox(scope: Fusion.Scope, props: table) : TextBox
	return _createNewCompoent(scope, props, "TextBox", {
		BackgroundColor3 = color3New(),
		ClearTextOnFocus = false,
		FontFace = fontFromName("SourceSansPro", Enum.FontWeight.Bold),
		Text = "",
		TextColor3 = color3New(1, 1, 1),
		TextScaled = true,

		AutoLocalize = false,
	})
end

--[[
	Return an empty transparent background image
]]
function Components.ImageLabel(scope: Fusion.Scope, props: table) : ImageLabel
	return _createNewCompoent(scope, props, "ImageLabel", {
		BackgroundColor3 = color3New(),
		BackgroundTransparency = 1,
		Image = "",

		AutoLocalize = false,
	})
end

--[[
	Return a clickable empty transparent image, but with center anchor and full size
]]
function Components.HoverImageButton(scope: Fusion.Scope, props: table) : ImageButton
	return _createNewCompoent(scope, props, "ImageButton", {
		Name = "Hover",
		BackgroundColor3 = color3New(),
		BackgroundTransparency = 1,
		AnchorPoint = v2New(0.5, 0.5),
		Position = fromScale(0.5, 0.5),
		Size = ud2New(1, 0, 1, 0),
		Image = "",

		AutoLocalize = false,
	})
end

--[[
	Return a clickable text, with SourceSansPro bold font, and black background
]]
function Components.TextButton(scope: Fusion.Scope, props: table) : TextButton
	return _createNewCompoent(scope, props, "TextButton", {
		AutoButtonColor = true,
		BackgroundColor3 = fromRGB(30, 30, 30),
		FontFace = Font.fromName("SourceSansPro", Enum.FontWeight.Bold),
		TextColor3 = color3New(1, 1, 1),
		TextScaled = true,

		AutoLocalize = false,
	})
end

--[[
	Return a disabled border UIStroke, with a little transparent
]]
function Components.UIStroke(scope: Fusion.Scope, props: table) : UIStroke
	return _createNewCompoent(scope, props, "UIStroke", {
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Color = color3New(1, 1, 1),
		Transparency = 0.3,
		Enabled = false,
	})
end

--[[
	Same as Components.UIStroke, but it's black and usually used for text
]]
function Components.TextUIStroke(scope: Fusion.Scope, props: table) : UIStroke
	return _createNewCompoent(scope, props, "UIStroke", {
		Transparency = 0.3,
	})
end

--[[
	Return a UICorner which can let GuiObject become round like a circle
]]
function Components.RoundUICorner(scope: Fusion.Scope) : UICorner
	return Fusion.New(scope, "UICorner")({ CornerRadius = udNew(0.5, 0) })
end


--// Custom
function Components.BGShadow(scope: Fusion.Scope) : Frame
	return Components.Frame(scope, {
        Name = "Shadow",
        BackgroundTransparency = 0.15,
        ZIndex = 0,
        Visible = false,

		AutoLocalize = false,
    })
end

return Components
