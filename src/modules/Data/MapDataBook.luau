--!nocheck

local MapDataBook = {}

MapDataBook.DifficultyColors = {
    [1] = Color3.fromRGB(35, 213, 41),
    [2] = Color3.fromRGB(237, 225, 86),
    [3] = Color3.fromRGB(205, 24, 54),
    [4] = Color3.fromRGB(98, 79, 184),
    [5] = Color3.fromRGB(239, 150, 54),
    [6] = Color3.fromRGB(125, 15, 79),
    [7] = Color3.fromRGB(255, 255, 255),

    ["Unrated"] = Color3.fromRGB(255, 255, 255)
}

MapDataBook.DifficultyNames = {
    [1] = "Easy",
    [2] = "Normal",
    [3] = "Hard",
    [4] = "Insane",
    [5] = "Extreme",
    [6] = "Divine",
    [7] = "Eternal",

    ["Unrated"] = "Unrated"
}

return MapDataBook
