
local MapDataBook = {}

MapDataBook.DifficultyColors = {
    [0] = Color3.fromRGB(255, 255, 255),
    [1] = Color3.fromRGB(35, 213, 41),
    [2] = Color3.fromRGB(237, 225, 86),
    [3] = Color3.fromRGB(205, 24, 54),
    [4] = Color3.fromRGB(98, 79, 184),
    [5] = Color3.fromRGB(239, 150, 54),
    [6] = Color3.fromRGB(162, 42, 102),
    [7] = Color3.fromRGB(255, 255, 255),

    ["Any"] = Color3.fromRGB(205, 24, 54)
}

MapDataBook.DifficultyNames = {
    [0] = "Unrated",
    [1] = "Easy",
    [2] = "Normal",
    [3] = "Hard",
    [4] = "Insane",
    [5] = "Extreme",
    [6] = "Divine",
    [7] = "Eternal",

    ["Any"] = "Unknown"
}

MapDataBook.DifficultyImages = {
    [0] = "rbxassetid://118178588512384",
    [1] = "rbxassetid://133699229277377",
    [2] = "rbxassetid://104421253473481",
    [3] = "rbxassetid://88790762185613",
    [4] = "rbxassetid://112661821254795",
    [5] = "rbxassetid://118339792441102",
    [6] = "rbxassetid://93969657563080",
    [7] = "rbxassetid://107020271457051",

    ["Any"] = "rbxassetid://119108618166999"
}

MapDataBook.SelectionIcons = {
    Spectate = "rbxassetid://11713565149",
    Folder = "rbxassetid://11713565892",
    Settings = "rbxassetid://11713567272"
}

MapDataBook.LiquidColors = {
    water = Color3.fromRGB(33, 84, 185),
    acid = Color3.fromRGB(0, 255, 0),
    lava = Color3.fromRGB(255, 0, 0),
}

return MapDataBook