--!nocheck

local Lighting = game:GetService("Lighting")
local MarketplaceService = game:GetService("MarketplaceService")
local MaterialService = game:GetService("MaterialService")
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local SS = game:GetService("ServerStorage")
local SoundS = game:GetService("SoundService")

local Events = require(SSS.Server.Modules.Library.ServerEvents)
local MapDataBook = require(RepS.Shared.Library.MapDataBook)
local HarukaLib = require(RepS.Shared.Shared.HarukaLib)
local Promise = require(RepS.Shared.Shared.Promise)
local Signals = require(SSS.Server.Modules.Library.ServerSignals)
local WaterLib = require(RepS.Shared.Library.WaterLib)

local mapModel: Model = nil
local setting: Configuration = nil

repeat task.wait() until Players:FindFirstChildOfClass("Player")


local function setupMapLib()
    --// Map libs
    local function _returnMapLib()
        return function ()
            return require(RepS.Shared.Library.MapLib)
        end
    end

    local mapLibRF = Instance.new("BindableFunction")
    mapLibRF.Name = "GetMapLib"
    mapLibRF.Parent = game
    mapLibRF.OnInvoke = _returnMapLib

    --// Map libs old
    local bindables = Instance.new("Folder")
    bindables.Name = "Bindables"
    bindables.Parent = SS

    local mapLibRFOLD = Instance.new("BindableFunction")
    mapLibRFOLD.Name = "GetMapLib"
    mapLibRFOLD.Parent = bindables
    mapLibRFOLD.OnInvoke = function()
        Events.CreateHint.FireAll({
            Hint = "This map is using the old maplib, read console for more info.",
            Color = "red",
            Duration = "5"
        })

        _returnMapLib()
    end

    --// Map runtime v1.0 compatibility
    local runtime = RepS.Shared.Library.Runtime:Clone()
    runtime.Parent = SSS


    workspace:SetAttribute("MapLibInited", true)
end
local function setupMap()
    mapModel = Instance.new("Model")
    mapModel.Name = "Map"

    for _, child: Instance in workspace:GetChildren() do
        if child:IsA("Camera") then continue end
        if child:IsA("Terrain") then continue end
        if child.Name == "Sounds" then continue end
        if Players:GetPlayerFromCharacter(child) then continue end

        child.Parent = mapModel
    end
    mapModel:PivotTo(CFrame.identity * mapModel:GetPivot().Rotation)
    mapModel:SetAttribute("CurrentTime", 0)

    --- disable all scripts before loading the map
    for _, child: Instance in mapModel:GetDescendants() do
        if child:IsA("Script") then child.Disabled = true end
        if child:IsA("LocalScript") then child.Disabled = true end
    end

    mapModel.Parent = workspace
    setting = mapModel.Settings


    workspace:SetAttribute("MapModelInited", true)
end
local function setupLighting()
    local lightingSettings = setting.Lighting :: Configuration

    Lighting:ClearAllChildren()
    RepS.Package.Unloads.WaterBlur:Clone().Parent = Lighting
    RepS.Package.Unloads.WaterColor:Clone().Parent = Lighting

    for _, child: Instance in lightingSettings:GetChildren() do
        child.Parent = Lighting
    end
    for attr: string, val: any in lightingSettings:GetAttributes() do
        pcall(function() Lighting[attr] = val end)
    end


    workspace:SetAttribute("MapLightingInited", true)
end
local function setupMaterials()
    --- there might be an unexpected error here
    pcall(function()
        local materialSettings = setting:FindFirstChild("Materials") :: Configuration

        if materialSettings then
            if not materialSettings:GetAttribute("Use2022Materials") then
                for _, child: Instance in mapModel:GetDescendants() do
                    if child:IsA("BasePart") or child:IsA("UnionOperation") or child:IsA("CornerWedgePart") then
                        if MaterialService:FindFirstChild(child.Material.Name.."_Pre2022") then
                            child.MaterialVariant = child.Material.Name.."_Pre2022"
                        end
                    end
                end
            end
        end


        workspace:SetAttribute("MapMaterialsInited", true)
    end)
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


    workspace:SetAttribute("MapVariantsInited", true)
end
local function setupButtons()
    local buttons = mapModel.Special:FindFirstChild("Button") :: Folder
    if not buttons then return end

    local events = Instance.new("Folder")
    events.Name = "ButtonEvents"
    events.Parent = mapModel

    local buttonColorSettings = mapModel.Settings.Button :: Folder
    local default = buttonColorSettings:FindFirstChild("Default") :: Configuration
    local group = buttonColorSettings:FindFirstChild("Group")  :: Configuration
    local pathChild = buttonColorSettings:FindFirstChild("PathChild")  :: Configuration

    local btnIndex = 1

    for _, button: Model in buttons:GetChildren() do
        if button:IsA("Model") and string.find(button.Name, "_Button") then
            if not button:FindFirstChild("Hitbox") then continue end
            if not button:FindFirstChild("Light") then continue end

            local index = string.sub(button.Name, 8)
            local realIndex = tonumber(index)
            local realrealIndex = string.gsub(index, "%a", "")

            local buttonStates = nil
            if not default or not group or not pathChild then
                warn("[Button Init] MapLib is outdated...")

                buttonStates = {
                    Default = {
                        Active = buttonColorSettings:GetAttribute("EnabledColor") :: Color3,
                        InActive = buttonColorSettings:GetAttribute("DisabledColor") :: Color3,
                        Activated = buttonColorSettings:GetAttribute("PressedColor") :: Color3,
                    },
                }
                buttonStates.Group = buttonStates.Default
                buttonStates.PathChild = buttonStates.Default

            else
                buttonStates = {
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
            end


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

            local marker = RepS.Package.Unloads.ButtonMarker:Clone() :: BillboardGui
            marker:AddTag("ButtonMarker")
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
                marker:SetAttribute("Active", true)
            end

            button.Hitbox.Touched:Connect(function(hit: BasePart)
                if hit
                    and hit.Parent
                    and hit.Parent:FindFirstChildOfClass("Humanoid") then

                    if not Players:GetPlayerFromCharacter(hit.Parent) then return end
                    if button:GetAttribute("Hit") then return end
                    if button:GetAttribute("Index") ~= tostring(btnIndex) then
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

                    local toucher = Players:GetPlayerFromCharacter(hit.Parent)
                    Events.CreateHint.FireAll({
                        Hint = "Button #"..button:GetAttribute("Index").." Pressed by "..toucher.DisplayName,
                        Color = "white"
                    })

                    event:Fire(toucher)
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
                                nextMarker:SetAttribute("Active", true)

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


    workspace:SetAttribute("MapButtonsInited", true)
end
local function setupButtonFuncs()
    for _, child: Instance in mapModel:GetDescendants() do
        if child:IsA("ObjectValue") then
            if string.find(child.Name, "_Destroy") then
                SS.Resources.Unloads.ButtonEvents.Fade:Clone().Parent = child

            elseif string.find(child.Name, "_Fall") then
                SS.Resources.Unloads.ButtonEvents.Fall:Clone().Parent = child

            elseif string.find(child.Name, "_Show") then
                SS.Resources.Unloads.ButtonEvents.Show:Clone().Parent = child

            elseif string.find(child.Name, "_Hide") then
                SS.Resources.Unloads.ButtonEvents.Hide:Clone().Parent = child

            elseif string.find(child.Name, "_Explode") then
                SS.Resources.Unloads.ButtonEvents.Explode:Clone().Parent = child
            end

        elseif child:IsA("Sound") and string.find(child.Name, "_Sound") then
            SS.Resources.Unloads.ButtonEvents.Sound:Clone().Parent = child
        end
    end


    workspace:SetAttribute("MapButtonFuncsInited", true)
end
local function setupWaters()
    local liquidSettings = setting:FindFirstChild("Liquids") or setting:FindFirstChild("Fluid") :: Configuration

    local function _setCustomWater(water: BasePart)
        if water:GetAttribute("Type") == "custom" then
            local customAttr = liquidSettings:FindFirstChild("custom") :: Configuration
            local customAttrOld = liquidSettings:FindFirstChild("Custom") :: Configuration

            if not customAttr and not customAttrOld then return end
            if customAttrOld and not customAttr then customAttr = customAttrOld end

            water:SetAttribute("OxygenDepletion", customAttr:GetAttribute("OxygenDepletion"))
            water.Color = customAttr:GetAttribute("Color")
        end
    end

    for _, water: BasePart in WaterLib._Waters do
        _setCustomWater(water)
    end
    WaterLib._WaterAdded:Connect(_setCustomWater)


    workspace:SetAttribute("MapWatersInited", true)
end
local function setupSkills()
    local skillSettings = setting:FindFirstChild("Skills") :: Configuration

    if not skillSettings then return end

    mapModel:SetAttribute("AllowAirDive", skillSettings:GetAttribute("AllowAirDive"))
    mapModel:SetAttribute("AllowSlide", skillSettings:GetAttribute("AllowSliding"))


    workspace:SetAttribute("MapSkillsInited", true)
end
local function setupSound() : string
    local soundSettings = setting:FindFirstChild("Music") :: Configuration | Sound
    if not soundSettings then soundSettings = setting.Main :: Configuration end

    local soundId = ""

    if soundSettings:IsA("Configuration") then
        local sound = Instance.new("Sound")
        sound.Name = "MapMusic"
        sound.SoundId = "rbxassetid://"..soundSettings:GetAttribute("Music") or ""
        sound.Volume = soundSettings:GetAttribute("Volume") or soundSettings:GetAttribute("MusicVolume") or 0
        sound.Looped = true
        sound.SoundGroup = SoundS.Underwater
        sound.Parent = mapModel

        soundId = tostring(soundSettings:GetAttribute("Music"))

    elseif soundSettings:IsA("Sound") then
        soundSettings.Name = "MapMusic"
        soundSettings.Parent = mapModel

        soundId = string.match(tostring(soundSettings.SoundId), "%d+")
    end


    workspace:SetAttribute("MapSoundInited", true)

    return soundId
end
local function setupScripts()
    local mapScript = mapModel:FindFirstChild("MapScript") :: Script
    local mapLocalScript = mapModel:FindFirstChild("LocalMapScript") :: LocalScript

    if mapScript then
        mapScript.Disabled = false
    end
    if mapLocalScript then
        mapLocalScript.Disabled = false

        for _, player: Player in Players:GetPlayers() do
            mapLocalScript:Clone().Parent = player.Character
        end

        mapLocalScript:Destroy()
    end

    --- enable all scripts at this time
    for _, child: Instance in mapModel:GetDescendants() do
        if child:IsA("Script") then child.Disabled = false end
        if child:IsA("LocalScript") then child.Disabled = false end
    end


    workspace:SetAttribute("MapScriptsInited", true)
end
local function _readyToRun()
    workspace:SetAttribute("MapPreInited", true)

    local soundId = setupSound()
    local timeout = 3

    task.wait(1)
    repeat
        task.wait(1)
        timeout -= 1
    until timeout < 0 or mapModel.MapMusic.IsLoaded == true

    mapModel:SetAttribute("IsLoaded", true)

    task.wait(1.5)
    mapModel.MapMusic:Play()
    mapModel:SetAttribute("IsStarted", true)

    HarukaLib.Clock(0.1, function()
        HarukaLib:AddAttr(mapModel, "CurrentTime", 0.1)
    end)

    local mainSettings = setting.Main :: Configuration
    local mapName = mainSettings:GetAttribute("Name") or "?"
    local difficulty = mainSettings:GetAttribute("Difficulty") or 0
    local creator = mainSettings:GetAttribute("Creator") or Players:FindFirstChildOfClass("Player").Name
    local mapDuration = mainSettings:GetAttribute("MaxTime") or 120

    local MapLib = require(RepS.Shared.Library.MapLib)

    workspace.Sounds.SFXs.MapStart:Play()

    Events.CreateHint.FireAll({
        Hint = `{mapName} [{MapDataBook.DifficultyNames[difficulty]}] by {creator}`,
        Color = MapDataBook.DifficultyColors[difficulty],
    })

    Promise.delay(5):andThen(function()
        if soundId == "" or soundId == nil then return end

        local productInfo = MarketplaceService:GetProductInfo(tonumber(soundId))
        if productInfo then
            Events.CreateHint.FireAll({
                Hint = `Music: {productInfo.Name}`,
                Color = Color3.fromRGB(125, 15, 79)
            })
        end
    end)
    Promise.delay(mapDuration):andThen(function()
        Events.CreateHint.FireAll({ Hint = "Time runs out!",  Color = "yellow" })

        MapLib.RoundEnding:Fire()
        Events.MapRoundEnding.FireAll({})
    end)
end
local function setupMain()
    repeat task.wait() until workspace:GetAttribute("ServerInited")

    setupMapLib()
    setupMap()
    setupLighting()
    setupMaterials()
    setupVariants()
    setupButtons()
    setupButtonFuncs()
    setupWaters()
    setupSkills()

    _readyToRun()

    setupScripts()
end
setupMain()
