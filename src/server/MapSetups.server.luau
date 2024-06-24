--!nocheck

local Lighting = game:GetService("Lighting")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Events = require(ServerScriptService.Modules.Data.ServerEvents)
local MapDataBook = require(ReplicatedStorage.Modules.Data.MapDataBook)
local Promise = require(ReplicatedStorage.Modules.Packages.Promise)
local Spawn = require(ReplicatedStorage.Modules.Packages.Spawn)

local mapModel: Model = nil
local setting: Configuration = nil

repeat task.wait() until Players:FindFirstChildOfClass("Player")

local plr = Players:FindFirstChildOfClass("Player")
repeat task.wait() until plr.Character or plr.CharacterAdded:Wait()

local function setupMapLib()
    --// Map libs
    local mapLibRF = Instance.new("BindableFunction")
    mapLibRF.Name = "GetMapLib"
    mapLibRF.Parent = game
    mapLibRF.OnInvoke = function()
        return function ()
            return require(ReplicatedStorage.Modules.Data.MapLib)
        end
    end
end
local function setupMap()
    mapModel = Instance.new("Model")
    mapModel.Name = "Map"

    for _, child: Instance in workspace:GetChildren() do
        if child:IsA("Camera") then continue end
        if child:IsA("Terrain") then continue end
        if child.Name == "Sounds" then continue end
        if child == plr.Character then continue end

        child.Parent = mapModel
    end

    mapModel.Parent = workspace
    setting = mapModel.Settings
end
local function setupLighting()
    local lightingSettings = setting.Lighting :: Configuration

    Lighting:ClearAllChildren()
    for _, child: Instance in lightingSettings:GetChildren() do
        child.Parent = Lighting
    end
    for attr: string, val: any in lightingSettings:GetAttributes() do
        Lighting[attr] = val
    end
end
local function setupVariants()
    local variantFolder = mapModel.Special:FindFirstChild("Variant") :: Folder
    if not variantFolder then return end

    local variants = {}
    for _, child: Instance in variantFolder:GetChildren() do
        if child:IsA("Folder") then variants[#variants + 1] = child end
    end

    if #variants < 1 then return end
    local randomVariant = math.random(1, #variants)

    for index, variant: Folder in variants do
        if index == randomVariant then continue end

        variant:Destroy()
    end
end
local function setupSound() : string
    local soundSettings = setting:FindFirstChild("Music") :: Configuration
    if not soundSettings then soundSettings = setting.Main :: Configuration end

    local sound = Instance.new("Sound")
    sound.Name = "MapMusic"
    sound.SoundId = "rbxassetid://"..soundSettings:GetAttribute("Music") or ""
    sound.Volume = soundSettings:GetAttribute("Volume") or soundSettings:GetAttribute("MusicVolume") or 0
    sound.Looped = true

    sound.Parent = mapModel
    sound:Play()

    return soundSettings:GetAttribute("Music")
end
local function setupScripts()
    local mapScript = mapModel:FindFirstChild("MapScript") :: Script
    local mapLocalScript = mapModel:FindFirstChild("LocalMapScript") :: LocalScript
    local effectScript = mapModel:FindFirstChild("EffectScript") :: LocalScript

    if not mapScript or not mapLocalScript or not effectScript then
        Events.CreateHint:FireAll("Map scripts not found!", nil, 6)
        return
    end

    mapScript.Disabled = false

    local mapLocalScriptClone = mapLocalScript:Clone()
    mapLocalScriptClone.Disabled = false
    mapLocalScriptClone.Parent = plr.Character
end
local function setupMain()
    Promise.new(function()
        setupMapLib()
        setupMap()
        setupLighting()
        setupVariants()

        --- starting
        task.wait(2)
        local soundId = setupSound()

        local mainSettings = setting.Main :: Configuration

        local mapName = mainSettings:GetAttribute("Name") or "?"
        local difficulty = mainSettings:GetAttribute("Difficulty") or "Unrated"
        local creator = mainSettings:GetAttribute("Creator") or "?"

        workspace.Sounds.SFXs.MapStart:Play()

        Events.CreateHint:FireAll(`{mapName} by {creator}`, MapDataBook.DifficultyColors[difficulty], 3)

        Spawn(function()
            task.wait(2)
            Promise.new(function()
                local productInfo = MarketplaceService:GetProductInfo(soundId)
                if productInfo then
                    Events.CreateHint:FireAll(`Music: {productInfo.Name}`, Color3.fromHex('#e74c3c'), 4)
                end

            end):Catch(function(err)
                warn(err)
            end)
        end)

        setupScripts()

    end):Catch(function(err)
        Events.CreateHint:FireAll("Map setup failed, fatal error happened", nil, 6)

        warn(err)
    end)
end
setupMain()
