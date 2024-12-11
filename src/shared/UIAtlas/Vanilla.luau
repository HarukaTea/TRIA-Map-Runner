--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local Fusion = require(RepS.Shared.Shared.Fusion)

local Components = {}

local color3New, v2New, udNew = Color3.new, Vector2.new, UDim.new
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
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Enabled = true
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
		BorderSizePixel = 0,
	})
end

--[[
	Return a transparent scrollable frame, with a center anchor, and no clips
]]
function Components.ScrollingFrame(scope: Fusion.Scope, props: table, listProps: table) : ScrollingFrame
	local absSize = Fusion.Value(scope, Vector2.new())
	local absContentSize = Fusion.Value(scope, Vector2.new())

	if listProps.Padding ~= nil then --- UIListLayout
		listProps[Fusion.Out("AbsoluteContentSize")] = absContentSize

		table.insert(props[Fusion.Children], 1, Fusion.New(scope, "UIListLayout")(listProps))

	elseif listProps.CellPadding ~= nil then --- UIGridLayout
		listProps[Fusion.Out("AbsoluteContentSize")] = absContentSize

		table.insert(props[Fusion.Children], 1, Fusion.New(scope, "UIGridLayout")(listProps))
	end

	return _createNewCompoent(scope, props, "ScrollingFrame", {
		BackgroundColor3 = fromRGB(30, 30, 30),
		BackgroundTransparency = 1,
		ScrollBarThickness = 5,
		ScrollBarImageColor3 = color3New(1, 1, 1),
		BorderSizePixel = 0,
		Size = fromScale(1, 1),

		CanvasSize = Fusion.Computed(scope, function(use)
			return if use(absContentSize).Y > use(absSize).Y then UDim2.fromOffset(0, use(absContentSize).Y + 26) else UDim2.fromOffset(0, 0)
		end),
		ScrollingEnabled = Fusion.Computed(scope, function(use)
			return if use(absContentSize).Y > use(absSize).Y then true else false
		end),

		[Fusion.Out("AbsoluteSize")] = absSize,
		[Fusion.Children] = props[Fusion.Children]
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
		BorderSizePixel = 0,
		Size = fromScale(1, 1),
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
		BorderSizePixel = 0,
		Size = fromScale(1, 1),
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
		BorderSizePixel = 0,
		Size = fromScale(1, 1),
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
		Size = fromScale(1, 1),
		Image = "",
		BorderSizePixel = 0,
		AutoButtonColor = false
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
		BorderSizePixel = 0,
	})
end

--[[
	Return a disabled border UIStroke, with a little transparent
]]
function Components.UIStroke(scope: Fusion.Scope, props: table) : UIStroke
	return _createNewCompoent(scope, props, "UIStroke", {
		Thickness = 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Color = color3New(1, 1, 1),
		Transparency = 0
	})
end

--[[
	Same as Components.UIStroke, but it's black and usually used for text
]]
function Components.TextUIStroke(scope: Fusion.Scope, props: table) : UIStroke
	return _createNewCompoent(scope, props, "UIStroke", {
		Thickness = 1,
		Transparency = 0,
	})
end

--[[
	Return a UICorner which can let GuiObject become round like a circle
]]
function Components.RoundUICorner(scope: Fusion.Scope) : UICorner
	return Fusion.New(scope, "UICorner")({ CornerRadius = udNew(0.5, 0) })
end

--[[
	Return a normal UIPadding with 0.1 scale of every direction
]]
function Components.UIPadding(scope: Fusion.Scope, props: table) : UIPadding
	return _createNewCompoent(scope, props, "UIPadding", {
		PaddingTop = udNew(0.1, 0),
		PaddingBottom = udNew(0.1, 0),
		PaddingLeft = udNew(0.1, 0),
		PaddingRight = udNew(0.1, 0)
	})
end

--[[
	A quick shortcut to UIAspectRatioConstraint
]]
function Components.UIAspectRatioConstraint(scope: Fusion.Scope, aspect: number?) : UIAspectRatioConstraint
	return _createNewCompoent(scope, { AspectRatio = aspect or 25.627 }, "UIAspectRatioConstraint", {
		AspectRatio = 25.627
	})
end

--[[
	Return a UIListLayout with different directions
]]
function Components.UIListLayout(scope: Fusion.Scope, props: table) : UIListLayout
	return _createNewCompoent(scope, props, "UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		FillDirection = Enum.FillDirection.Vertical,
		VerticalAlignment = Enum.VerticalAlignment.Top,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		Padding = udNew(0, 0)
	})
end

--[[
	Return a padding frame for scrolling frame
]]
function Components.PaddingFrame(scope: Fusion.Scope, name: string) : Frame
	return Components.Frame(scope, {
		Name = name,
		Size = UDim2.fromOffset(1, 1),
		LayoutOrder = if name == "AAA" then 0 else 99999
	})
end

--[[
	Return a most basic frame in UI structure, haruka style-ui only
]]
function Components.HarukaFrame(scope: Fusion.Scope, props: table) : Frame
	table.insert(props[Fusion.Children], 1, Components.UIAspectRatioConstraint(scope, 25.627))

	props.Size = UDim2.fromScale(1, 0.1)

	return Components.Frame(scope, props)
end

--[[
	Return a default billboardGui
]]
function Components.BillboardGui(scope: Fusion.Scope, props: table) : BillboardGui
	return _createNewCompoent(scope, props, "BillboardGui", {
		LightInfluence = 0,
		ZIndexBehavior = Enum.ZIndexBehavior.Global,
		ClipsDescendants = false,
		AlwaysOnTop = true,
		ResetOnSpawn = false,
		Active = true
	})
end

--[[
	Return a BlurEffect for UI objects only
]]
function Components.BlurFS(scope: Fusion.Scope, props: table) : BlurEffect
	return _createNewCompoent(scope, props, "BlurEffect", {
		Enabled = true,
		Name = "UIBlur"
	})
end

return Components
