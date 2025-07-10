--!nocheck

--// UI Theme: Twilight Duo

return {
	font = Font.fromName("Nunito", Enum.FontWeight.Regular),
	fontBold = Font.fromName("Nunito", Enum.FontWeight.Bold),
	fontLight = Font.fromName("Nunito", Enum.FontWeight.Light),
	fontSize = 26,

	text = Color3.fromHex("#ffffff"),
	grayText = Color3.fromHex("#bcbcbc"),
	background = Color3.fromHex("#1e1e1e"),
	background2 = Color3.fromHex("#141414"),
	element = Color3.fromHex("#151515"),
	element2 = Color3.fromHex("#282828"),
	element3 = Color3.fromHex("#828282"),

	white = Color3.fromHex('#ffffff'),
	red = Color3.fromHex('#ff6b81'),
	green = Color3.fromHex('#2ed573'),
	blue = Color3.fromHex('#1e90ff'),
	yellow = Color3.fromHex('#fdcb6e'),
	pink = Color3.fromHex('#fd79a8'),
	cyan = Color3.fromHex('#81ecec'),

	ease = TweenInfo.new(0.115, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),

	gradient = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromHex("#C5C5C5")),
		ColorSequenceKeypoint.new(1, Color3.fromHex("#686868"))
	})
}