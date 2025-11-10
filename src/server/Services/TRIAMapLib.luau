
local Lighting = game:GetService("Lighting")
local MarketplaceService = game:GetService("MarketplaceService")
local MaterialService = game:GetService("MaterialService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local SoundService = game:GetService("SoundService")


local Events = require(ServerScriptService.HarukaServer.Library.ServerEvents)
local HarukaLib = require(ReplicatedStorage.HarukaShared.Shared.HarukaLib)
local Promise = require(ReplicatedStorage.HarukaShared.Shared.Promise)
local ServerBindables = require(ServerScriptService.HarukaServer.Library.ServerBindables)


local MapDataBook = require(ReplicatedStorage.HarukaShared.Library.MapDataBook)

local TRIAMapLib = {}



function TRIAMapLib:Init()
    self.MapModel = nil
    self.MapSettings = nil


    TRIAMapLib:_DoInitMapLibRemoteFunc()
    TRIAMapLib:_DoInitMapModel()
    TRIAMapLib:_DoInitLightingFromMapSettings()
    TRIAMapLib:_DoInitMapMaterialsFromMapSettings()
    TRIAMapLib:_DoInitVariantsFromMapModel()
    TRIAMapLib:_DoInitButtonsFromMapModel()
    TRIAMapLib:_DoInitMapMedals()
    TRIAMapLib:_DoInitButtonFuncsFromButtons()
    TRIAMapLib:_DoInitMapWatersFromMapModel()
    TRIAMapLib:_DoInitSkillSettings()
    TRIAMapLib:_DoInitMapSounds()
    TRIAMapLib:_DoInitMapUIs()

    TRIAMapLib:_DoPreloadRun()
    TRIAMapLib:_DoRunScripts()

    workspace:SetAttribute("Haruka_MapInited", true)
end



function TRIAMapLib:_DoInitMapLibRemoteFunc()
    local function _returnMapLib()
        return function ()
            return require(ReplicatedStorage.HarukaShared.Library.MapLib)
        end
    end

    local mapLibRF = Instance.new("BindableFunction")
    mapLibRF.Name = "GetMapLib"
    mapLibRF.Parent = game
    mapLibRF.OnInvoke = _returnMapLib

    --// Map libs old
    local bindables = Instance.new("Folder")
    bindables.Name = "Bindables"
    bindables.Parent = ServerStorage

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


    workspace:SetAttribute("Haruka_MapLibInited", true)
end



function TRIAMapLib:_DoInitMapModel()
    local mapModel = Instance.new("Model")
    mapModel.Name = "Map"

    for _, child: Instance in workspace:GetChildren() do
        if child:IsA("Camera") then continue end
        if child:IsA("Terrain") then continue end
        if Players:GetPlayerFromCharacter(child) then continue end

        child.Parent = mapModel
    end
    mapModel:PivotTo(CFrame.identity * mapModel:GetPivot().Rotation)
    mapModel:SetAttribute("CurrentTime", 0)

    --- disable all scripts before loading the map
    for _, child: Instance in mapModel:GetDescendants() do
        if child:FindFirstAncestorOfClass("ScreenGui") then continue end
        if child:IsA("Script") then child.Disabled = true end
        if child:IsA("LocalScript") then child.Disabled = true end
    end

    mapModel.Parent = workspace

    self.MapModel = mapModel
    self.MapSettings = mapModel:FindFirstChild("Settings")

    if not self.MapSettings then
        error("Map model does not contain a Settings folder!")
    end


    workspace:SetAttribute("Haruka_MapModelInited", true)
end



function TRIAMapLib:_DoInitLightingFromMapSettings()
    local lightingSettings = self.MapSettings.Lighting :: Configuration


    Lighting:ClearAllChildren()
    ReplicatedStorage.Packages.Unloads.WaterBlur:Clone().Parent = Lighting
    ReplicatedStorage.Packages.Unloads.WaterColor:Clone().Parent = Lighting


    for _, child: Instance in lightingSettings:GetChildren() do
        child.Parent = Lighting
    end
    for attr: string, val: any in lightingSettings:GetAttributes() do
        pcall(function() Lighting[attr] = val end)
    end


    workspace:SetAttribute("Haruka_MapLightingInited", true)
end



function TRIAMapLib:_DoInitMapMaterialsFromMapSettings()
    Promise.try(function()
        local materialSettings = self.MapSettings:FindFirstChild("Materials") :: Configuration

        if materialSettings then
            if not materialSettings:GetAttribute("Use2022Materials") then
                for _, child: Instance in self.MapModel:GetDescendants() do
                    if HarukaLib:IsBasePartType(child) then
                        if MaterialService:FindFirstChild(child.Material.Name.."_Pre2022") then
                            child.MaterialVariant = child.Material.Name.."_Pre2022"
                        end
                    end
                end
            end
        end


        workspace:SetAttribute("Haruka_MapMaterialInited", true)
    end)
end



function TRIAMapLib:_DoInitVariantsFromMapModel()
    local variantFolder = self.MapModel.Special:FindFirstChild("Variant") :: Folder
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


    workspace:SetAttribute("Haruka_MapVariantsInited", true)
end



function TRIAMapLib:_DoInitButtonsFromMapModel()
    local buttons = self.MapModel.Special:FindFirstChild("Button") :: Folder
    if not buttons then return end


    local events = Instance.new("Folder")
    events.Name = "ButtonEvents"
    events.Parent = self.MapModel


    local buttonColorSettings = self.MapModel.Settings.Button :: Folder
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
            require(ServerScriptService.HarukaServer.Library.ButtonStatesShared)[realrealIndex] = buttonStates


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

            local marker = ReplicatedStorage.Packages.Unloads.ButtonMarker:Clone() :: BillboardGui
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
                        ServerBindables.BtnTouched:Fire("PathChild", realrealIndex)
                    end


                    ServerBindables.BtnTouched:Fire("Normal", realrealIndex, button)


                    local toucher = Players:GetPlayerFromCharacter(hit.Parent)
                    Events.CreateHint.FireAll({
                        Hint = "Button #"..button:GetAttribute("Index").." Pressed by "..toucher.DisplayName,
                        Color = "white"
                    })
                    event:Fire(toucher)
                    ServerBindables.BtnPressed:Fire(realrealIndex)

                    btnIndex += 1
                end
            end)
        end
    end


    workspace:SetAttribute("Haruka_MapButtonsInited", true)
end


function TRIAMapLib:_DoInitMapMedals()
    local medal = self.MapModel.Special:FindFirstChild("Medal") :: Model | BasePart
    if not medal then return end

    if medal:IsA("Model") then
        for _, ins: Instance in medal:GetDescendants() do
            if ins.Name == "Medal" and ins:IsA("BasePart") then
                ins:AddTag("MedalEntity")
            end
        end
    elseif medal:IsA("BasePart") then
        medal:AddTag("MedalEntity")
    end


    workspace:SetAttribute("Haruka_MapMedalsInited", true)
end


function TRIAMapLib:_DoInitButtonFuncsFromButtons()
    for _, child: Instance in self.MapModel:GetDescendants() do
        if child:IsA("ObjectValue") then
            if string.find(child.Name, "_Destroy") then
                ServerStorage.HarukaRes.Unloads.ButtonEvents.Fade:Clone().Parent = child

            elseif string.find(child.Name, "_Fall") then
                ServerStorage.HarukaRes.Unloads.ButtonEvents.Fall:Clone().Parent = child

            elseif string.find(child.Name, "_Show") then
                ServerStorage.HarukaRes.Unloads.ButtonEvents.Show:Clone().Parent = child

            elseif string.find(child.Name, "_Hide") then
                ServerStorage.HarukaRes.Unloads.ButtonEvents.Hide:Clone().Parent = child

            elseif string.find(child.Name, "_Explode") then
                ServerStorage.HarukaRes.Unloads.ButtonEvents.Explode:Clone().Parent = child
            end

        elseif child:IsA("Sound") and string.find(child.Name, "_Sound") then
            ServerStorage.HarukaRes.Unloads.ButtonEvents.Sound:Clone().Parent = child
        end
    end


    workspace:SetAttribute("Haruka_MapButtonFuncsInited", true)
end



function TRIAMapLib:_DoInitMapWatersFromMapModel()
    local liquidSettings = self.MapSettings:FindFirstChild("Liquids") or self.MapSettings:FindFirstChild("Fluid") :: Configuration
    local WaterLib = require(ReplicatedStorage.HarukaShared.Library.WaterLib)


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


    workspace:SetAttribute("Haruka_MapWatersInited", true)
end


function TRIAMapLib:_DoInitSkillSettings()
    local skillSettings = self.MapSettings:FindFirstChild("Skills") :: Configuration
    if not skillSettings then
        skillSettings = self.MapSettings:FindFirstChild("Skill") :: Configuration
    end
    if not skillSettings then return end


    self.MapModel:SetAttribute("AllowAirDive", skillSettings:GetAttribute("AllowAirDive"))
    self.MapModel:SetAttribute("AllowSlide", skillSettings:GetAttribute("AllowSliding"))


    workspace:SetAttribute("Haruka_MapSkillsInited", true)
end



function TRIAMapLib:_DoInitMapSounds()
    local soundSettings = self.MapSettings:FindFirstChild("Music") :: Configuration | Sound
    if not soundSettings then soundSettings = self.MapSettings.Main :: Configuration end

    local soundId = ""

    if soundSettings:IsA("Configuration") then
        local sound = Instance.new("Sound")
        sound.Name = "MapMusic"
        sound.SoundId = "rbxassetid://"..soundSettings:GetAttribute("Music") or ""
        sound.Volume = soundSettings:GetAttribute("Volume") or soundSettings:GetAttribute("MusicVolume") or 0
        sound.Looped = true
        sound.SoundGroup = SoundService.Underwater
        sound.Parent = self.MapModel

        soundId = tostring(soundSettings:GetAttribute("Music"))

    elseif soundSettings:IsA("Sound") then
        soundSettings.Name = "MapMusic"
        soundSettings.Parent = self.MapModel

        soundId = string.match(tostring(soundSettings.SoundId), "%d+")
    end


    workspace:SetAttribute("Haruka_MapSoundsInited", true)


    self.MapSoundId = soundId
end


function TRIAMapLib:_DoInitMapUIs()
    local uiSettings = self.MapSettings:FindFirstChild("UI") :: Configuration
    if not uiSettings then return end


    for _, player: Player in Players:GetPlayers() do
        for _, gui: ScreenGui in uiSettings:GetChildren() do
            local cloned = gui:Clone()
            cloned:AddTag("MapUIEntity")
            cloned.Parent = player.PlayerGui
        end
    end


    workspace:SetAttribute("Haruka_MapUIsInited", true)
end



function TRIAMapLib:_DoPreloadRun()
    workspace:SetAttribute("Haruka_MapPreloadRun", true)

    local soundId = self.MapSoundId
    local mapModel = self.MapModel
    local setting = self.MapSettings
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

    local MapLib = require(ReplicatedStorage.HarukaShared.Library.MapLib)

    SoundService.Sounds.SFXs.MapStart:Play()

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
    end):catch(function() end)
    Promise.delay(mapDuration):andThen(function()
        mapModel:SetAttribute("IsFinished", true)

        Events.CreateHint.FireAll({ Hint = "Time runs out!",  Color = "yellow" })

        MapLib.RoundEnding:Fire()
        Events.MapRoundEnding.FireAll()
    end)


    workspace:SetAttribute("Haruka_MapPreloadInited", true)
end


function TRIAMapLib:_DoRunScripts()
    local mapModel = self.MapModel


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


    workspace:SetAttribute("Haruka_MapScriptsInited", true)
end



return TRIAMapLib