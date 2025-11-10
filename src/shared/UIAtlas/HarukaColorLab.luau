
local HarukaColorLab = {}


HarukaColorLab.COLOR_SERIES = {}


HarukaColorLab.COLOR_SERIES.Genshin = {
    Background = Color3.fromHex('#1c1c25'),

    Text = Color3.fromHex('#ece5d8'),
    Text2 = Color3.fromHex('#f6f2ee'),

    KeyText = Color3.fromHex('#ffcc33'),
    KeyText2 = Color3.fromHex('#37ffff'),
    WarnText = Color3.fromHex('#ff5e41'),

    WaterElement = Color3.fromHex('#80c0ff'),
    FireElement = Color3.fromHex('#ff9999'),
    WindElement = Color3.fromHex('#80ffd7'),
    ThunderElement = Color3.fromHex('#ffacff'),
    GrassElement = Color3.fromHex('#99ff88'),
    IceElement = Color3.fromHex('#99ffff'),
    EarthElement = Color3.fromHex('#ffe699')
}


HarukaColorLab.COLOR_SERIES.AzurPromilia = {
    Background = Color3.fromHex('#eeece9'),

    Green = Color3.fromHex('#7bd99f'),
    Red = Color3.fromHex('#ff7675'),
    Blue = Color3.fromHex('#7ce4f8'),
}


HarukaColorLab.COLOR_SERIES.Muelsyse = {
    Background = Color3.fromHex('#100e0a'),
    BackgroundLighter = Color3.fromHex('#25292f'),

    Text = Color3.fromHex('#f3dfb8'),
}


--// legacy references


HarukaColorLab.BLACK_COLOR = HarukaColorLab.COLOR_SERIES.Muelsyse.Background
HarukaColorLab.WHITE_COLOR = HarukaColorLab.COLOR_SERIES.Genshin.Text
HarukaColorLab.RED_COLOR = HarukaColorLab.COLOR_SERIES.AzurPromilia.Red
HarukaColorLab.GREEN_COLOR = HarukaColorLab.COLOR_SERIES.AzurPromilia.Green
HarukaColorLab.BLUE_COLOR = HarukaColorLab.COLOR_SERIES.AzurPromilia.Blue


return HarukaColorLab