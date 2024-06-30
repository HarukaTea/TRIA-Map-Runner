--!nocheck

local Lighting = game:GetService("Lighting")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local SoundService = game:GetService("SoundService")

local BezierLib = require(ReplicatedStorage.Modules.Packages.BezierLib)
local Events = require(ServerScriptService.Modules.Data.ServerEvents)
local MapDataBook = require(ReplicatedStorage.Modules.Data.MapDataBook)
local Promise = require(ReplicatedStorage.Modules.Packages.Promise)
local Spawn = require(ReplicatedStorage.Modules.Packages.Spawn)
local Signals = require(ServerScriptService.Modules.Data.ServerSignals)
local WaterLib = require(ReplicatedStorage.Modules.Data.WaterLib)

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

    local btnIndex = 1

    for _, button: Model in buttons:GetChildren() do
        if button:IsA("Model") and string.find(button.Name, "_Button") then
            if not button:FindFirstChild("Hitbox") then continue end
            if not button:FindFirstChild("Light") then continue end

            local index = string.sub(button.Name, 8)
            local realIndex = tonumber(index)
            local realrealIndex = string.gsub(index, "%a", "")

            local buttonStates = {
                Default = {
                    Active = default:GetAttribute("ActiveColor") :: Color3,
                    InActive = default:GetAttribute("InactiveColor") :: Color3,
                    Activated = default:GetAttribute("ActivatedColor") :: Color3,
                },
                Group = {
                    Active = group:GetAttribute("ActiveColor") :: Color3,
                    InActive = group:GetAttribute("InactiveColor") :: Color3,
                    Activated = group:GetAttribute("ActivatedColor") :: Color3,
                },
                PathChild = {
                    Active = pathChild:GetAttribute("ActiveColor") :: Color3,
                    InActive = pathChild:GetAttribute("InactiveColor") :: Color3,
                    Activated = pathChild:GetAttribute("ActivatedColor") :: Color3,
                }
            }

            button:SetAttribute("Index", realrealIndex)

            local event: BindableEvent
            if realIndex == nil then
                button:SetAttribute("PathChild", true)

                if not events:FindFirstChild("Button"..realrealIndex) then
                    event = Instance.new("BindableEvent")
                    event.Name = "Button"..realrealIndex
                    event.Parent = events
                else
                    event = events:FindFirstChild("Button"..realrealIndex)
                end
            else
                event = Instance.new("BindableEvent")
                event.Name = "Button"..index
                event.Parent = events
            end

            local marker = ReplicatedStorage.Package.Unloads.ButtonMarker:Clone() :: BillboardGui
            marker.Parent = button
            if button:GetAttribute("Group") then
                marker.Corners.ImageColor3 = buttonStates.Group.InActive
            elseif button:GetAttribute("PathChild") then
                marker.Corners.ImageColor3 = buttonStates.PathChild.InActive
            else
                marker.Corners.ImageColor3 = buttonStates.Default.InActive
            end

            if string.find(button.Name, "_Button1") then
                if button:GetAttribute("Group") then
                    marker.Corners.ImageColor3 = buttonStates.Group.Active
                elseif button:GetAttribute("PathChild") then
                    marker.Corners.ImageColor3 = buttonStates.PathChild.Active
                else
                    marker.Corners.ImageColor3 = buttonStates.Default.Active
                end
            end

            button.Hitbox.Touched:Connect(function(hit: BasePart)
                if hit
                    and hit.Parent
                    and hit.Parent:FindFirstChildOfClass("Humanoid") then

                    if button:GetAttribute("Hit") then return end
                    if button:GetAttribute("Index") ~= tostring(btnIndex) then
                        Events.CreateHint:FireAll("Press previous buttons first!")
                        return
                    end

                    if button:GetAttribute("Group") then
                        --- nothing, cuz it's solo test
                    end
                    if button:GetAttribute("PathChild") then
                        --- activate all buttons in the path
                        for _, child: Model in buttons:GetChildren() do
                            if child:IsA("Model") and string.find(child.Name, "_Button") then
                                if child:GetAttribute("Index") == tostring(btnIndex) then
                                    local nextMarker = child:FindFirstChild("ButtonMarker") :: BillboardGui

                                    child.Light.Color = buttonStates.PathChild.Activated
                                    child:SetAttribute("Hit", true)

                                    nextMarker.Enabled = false
                                end
                            end
                        end
                    end

                    button:SetAttribute("Hit", true)
                    workspace.Sounds.SFXs.BtnPressed:Play()
                    marker.Enabled = false

                    if button:GetAttribute("Group") then
                        button.Light.Color = buttonStates.Group.Activated
                    elseif button:GetAttribute("PathChild") then
                        button.Light.Color = buttonStates.PathChild.Activated
                    else
                        button.Light.Color = buttonStates.Default.Activated
                    end

                    Events.CreateHint:FireAll("Button #"..button:GetAttribute("Index").." Pressed by "..plr.DisplayName)

                    event:Fire(Players:GetPlayerFromCharacter(hit.Parent))
                    Signals.BtnPressed:Fire(realrealIndex)

                    btnIndex += 1

                    for _, child: Model in buttons:GetChildren() do
                        if child:IsA("Model") and string.find(child.Name, "_Button") then
                            if child:GetAttribute("Index") == tostring(btnIndex) then
                                local nextMarker = child:FindFirstChild("ButtonMarker") :: BillboardGui

                                if button:GetAttribute("Group") then
                                    nextMarker.Corners.ImageColor3 = buttonStates.Group.Active
                                elseif button:GetAttribute("PathChild") then
                                    nextMarker.Corners.ImageColor3 = buttonStates.PathChild.Active
                                else
                                    nextMarker.Corners.ImageColor3 = buttonStates.Default.Active
                                end

                                if child:GetAttribute("Group") then
                                    child.Light.Color = buttonStates.Group.Active
                                elseif child:GetAttribute("PathChild") then
                                    child.Light.Color = buttonStates.PathChild.Active
                                else
                                    child.Light.Color = buttonStates.Default.Active
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end
local function setupButtonFuncs()
    for _, child: Instance in mapModel:GetDescendants() do
        if child:IsA("ObjectValue") then
            if string.find(child.Name, "_Destroy") then
                ServerStorage.Resources.Unloads.ButtonEvents.Fade:Clone().Parent = child

            elseif string.find(child.Name, "_Fall") then
                ServerStorage.Resources.Unloads.ButtonEvents.Fall:Clone().Parent = child

            elseif string.find(child.Name, "_Show") then
                ServerStorage.Resources.Unloads.ButtonEvents.Show:Clone().Parent = child

            elseif string.find(child.Name, "_Hide") then
                ServerStorage.Resources.Unloads.ButtonEvents.Hide:Clone().Parent = child

            elseif string.find(child.Name, "_Explode") then
                ServerStorage.Resources.Unloads.ButtonEvents.Explode:Clone().Parent = child
            end

        elseif child:IsA("Sound") and string.find(child.Name, "_Sound") then
            ServerStorage.Resources.Unloads.ButtonEvents.Sound:Clone().Parent = child
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
local function setupWaters()
    local customAttrs = setting.Liquids :: Configuration

    local function _setCustomWater(water: BasePart)
        if water:GetAttribute("Type") == "custom" then
            water:SetAttribute("OxygenDepletion", customAttrs.custom:GetAttribute("OxygenDepletion"))
            water.Color = customAttrs.custom:GetAttribute("Color")
        end
    end

    for _, water: BasePart in WaterLib._Waters do
        _setCustomWater(water)
    end
    WaterLib._WaterAdded:Connect(_setCustomWater)
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
        setupButtonFuncs()
        setupZipline()
        setupWaters()

        --- starting
        local soundId = setupSound()
        local timeout = 8

        repeat
            task.wait(2)
            timeout -= 2
        until timeout < 0 or mapModel.MapMusic.IsLoaded == true

        mapModel:SetAttribute("IsLoaded", true)

        task.wait(1.5)
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
        warn(err)

        while task.wait(6) do
            Events.CreateHint:FireAll("Map setup failed, fatal error happened", nil, 6)
            warn(err)
        end

        warn(err)
    end)
end
setupMain()
