--!nocheck

local Lighting = game:GetService("Lighting")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local SoundService = game:GetService("SoundService")

local BezierLib = require(ReplicatedStorage.Modules.Packages.BezierLib)
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
    ReplicatedStorage.Package.Unloads.WaterBlur:Clone().Parent = Lighting
    ReplicatedStorage.Package.Unloads.WaterColor:Clone().Parent = Lighting

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
local function setupButtons()
    local buttons = mapModel.Special:FindFirstChild("Button") :: Folder
    if not buttons then return end

    local events = Instance.new("Folder")
    events.Name = "ButtonEvents"
    events.Parent = mapModel

    local buttonColorSettings = mapModel.Settings.Button :: Folder
    local default = buttonColorSettings.Default :: Configuration
    local group = buttonColorSettings.Group :: Configuration
    local pathChild = buttonColorSettings.PathChild :: Configuration

    for _, button: Model in buttons:GetChildren() do
        if button:IsA("Model") and string.find(button.Name, "_Button") then
            if not button:FindFirstChild("Hitbox") then continue end

            local index = string.sub(button.Name, 8)
            local realIndex = tonumber(index)

            local color = default:GetAttribute("InactiveColor") :: Color3
            if button:GetAttribute("Group") then
                if realIndex and realIndex == 1 then
                    color = group:GetAttribute("ActiveColor") :: Color3

                elseif realIndex and realIndex ~= 1 then
                    color = group:GetAttribute("InactiveColor") :: Color3
                end
            else
                if realIndex and realIndex == 1 then
                    color = default:GetAttribute("ActiveColor") :: Color3

                elseif realIndex and realIndex ~= 1 then
                    color = default:GetAttribute("InactiveColor") :: Color3

                elseif not realIndex then
                    color = pathChild:GetAttribute("InactiveColor") :: Color3
                end
            end

            local event: BindableEvent
            if realIndex == nil then
                --- path buttons
                print("Path button")
            else
                event = Instance.new("BindableEvent")
                event.Name = "Button"..index
                event.Parent = events
            end

            local marker = ReplicatedStorage.Package.Unloads.ButtonMarker:Clone() :: BillboardGui
            marker.Corners.ImageColor3 = color
            marker.Parent = button

            button.Hitbox.Touched:Connect(function(hit: BasePart)
                if hit and hit.Parent and hit.Parent:FindFirstChildOfClass("Humanoid") then
                    if button:GetAttribute("Hit") then return end

                    button:SetAttribute("Hit", true)
                    workspace.Sounds.SFXs.BtnPressed:Play()

                    Events.CreateHint:FireAll("Button #"..index.." Pressed by "..plr.DisplayName)

                    event:Fire(Players:GetPlayerFromCharacter(hit.Parent))
                    button:Destroy()
                end
            end)
        end
    end
end
local function setupZipline()
    for _, child: Instance in mapModel:GetDescendants() do
        if child.Name == "Zipline" and child:IsA("Model") then
            local configuration = child:FindFirstChildOfClass("Configuration")

            for _, descendant: BasePart in child:GetChildren() do
                if descendant:IsA("BasePart") then
                    descendant.Material = configuration:GetAttribute("Material")
                    descendant.Color = configuration:GetAttribute("Color")

                    for attr: string, val: any in configuration:GetAttributes() do
                        descendant:SetAttribute(attr, val)
                    end
                end
            end
            for attr: string, val: any in configuration:GetAttributes() do
                child:SetAttribute(attr, val)
            end

            BezierLib:Run(child)
        end
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
    sound.SoundGroup = SoundService.Underwater
    sound.Parent = mapModel

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

    mapModel:SetAttribute("ScriptsLoaded", true)
end
local function setupMain()
    Promise.new(function()
        setupMapLib()
        setupMap()
        setupLighting()
        setupVariants()
        setupButtons()
        setupZipline()

        --- starting
        local soundId = setupSound()
        local timeout = 8

        repeat
            task.wait(2)
            timeout -= 2
            Events.CreateHint:FireAll("Waiting for map to load, please wait...", nil, 1.5)
        until timeout < 0 or mapModel.MapMusic.IsLoaded == true

        Events.CreateHint:FireAll("Load completed! Get ready...3..2..1...", nil, 3)
        mapModel:SetAttribute("IsLoaded", true)

        task.wait(3)
        mapModel.MapMusic:Play()
        workspace.Sounds.Lobby:Stop()

        plr.Character.PrimaryPart.Anchored = false

        local mainSettings = setting.Main :: Configuration
        local mapName = mainSettings:GetAttribute("Name") or "?"
        local difficulty = mainSettings:GetAttribute("Difficulty") or "Unrated"
        local creator = mainSettings:GetAttribute("Creator") or "?"

        workspace.Sounds.SFXs.MapStart:Play()

        Events.CreateHint:FireAll(
            `{mapName} [{MapDataBook.DifficultyNames[difficulty]}] by {creator}`,
            MapDataBook.DifficultyColors[difficulty],
            3
        )

        Spawn(function()
            task.wait(5)
            Promise.new(function()
                local productInfo = MarketplaceService:GetProductInfo(soundId)
                if productInfo then
                    Events.CreateHint:FireAll(`Music: {productInfo.Name}`, Color3.fromRGB(125, 15, 79), 4)
                end

            end):Catch(function(err)
                warn(err)
            end)
        end)

        setupScripts()

        --// wait for finish
        Spawn(function()
            task.wait(mainSettings:GetAttribute("MaxTime") or 120)

            Events.CreateHint:FireAll("Round Ended...")
            workspace.Sounds.Lobby:Play()
        end)

    end):Catch(function(err)
        Events.CreateHint:FireAll("Map setup failed, fatal error happened", nil, 6)
        while task.wait(6) do
            Events.CreateHint:FireAll("Map setup failed, fatal error happened", nil, 6)
        end

        warn(err)
    end)
end
setupMain()
