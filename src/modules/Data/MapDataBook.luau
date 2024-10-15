--!nocheck

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
    [0] = "rbxassetid://104327402477140",
    [1] = "rbxassetid://80817781041683",
    [2] = "rbxassetid://89143893248340",
    [3] = "rbxassetid://108859790870162",
    [4] = "rbxassetid://107591299966218",
    [5] = "rbxassetid://98607427980748",
    [6] = "rbxassetid://87219169779163",
    [7] = "rbxassetid://80817781041683",

    ["Any"] = "rbxassetid://79547062877066"
}

MapDataBook.SelectionIcons = {
    Spectate = "rbxassetid://137783292161525",
    Folder = "rbxassetid://132791194708413",
    Settings = "rbxassetid://73509030455641"
}

return MapDataBook
