--!nocheck

local Lighting = game:GetService("Lighting")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local SoundService = game:GetService("SoundService")
local StarterPlayer = game:GetService("StarterPlayer")

local Events = require(ServerScriptService.Modules.Data.ServerEvents)
local MapDataBook = require(ReplicatedStorage.Modules.Data.MapDataBook)
local Promise = require(ReplicatedStorage.Modules.Packages.Promise)
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
    mapModel:PivotTo(CFrame.identity * mapModel:GetPivot().Rotation)

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
        pcall(function() Lighting[attr] = val end)
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
                warn("Using old map libs!")

                buttonStates = {
                    Default = {
                        Active = buttonColorSettings:GetAttribute("EnabledColor") :: Color3,
                        InActive = buttonColorSettings:GetAttribute("DisabledColor") :: Color3,
                        Activated = buttonColorSettings:GetAttribute("PressedColor") :: Color3,
                    },
                    Group = {
                        Active = buttonColorSettings:GetAttribute("EnabledGroupColor") :: Color3,
                        InActive = buttonColorSettings:GetAttribute("DisabledColor") :: Color3,
                        Activated = buttonColorSettings:GetAttribute("PressedColor") :: Color3,
                    },
                    PathChild = {
                        Active = buttonColorSettings:GetAttribute("EnabledColor") :: Color3,
                        InActive = buttonColorSettings:GetAttribute("DisabledColor") :: Color3,
                        Activated = buttonColorSettings:GetAttribute("PressedColor") :: Color3,
                    }
                }
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

            local marker = ReplicatedStorage.Package.Unloads.ButtonMarker:Clone() :: BillboardGui
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

                    if button:GetAttribute("Hit") then return end
                    if button:GetAttribute("Index") ~= tostring(btnIndex) then
                        Events.CreateHint.FireAll({
                            Hint = "Press previous buttons first!",
                            Color = "white"
                        })
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

                    Events.CreateHint.FireAll({
                        Hint = "Button #"..button:GetAttribute("Index").." Pressed by "..plr.DisplayName,
                        Color = "white"
                    })

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
local function setupWaters()
    local liquidSettings = setting.Liquids :: Configuration

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
end
local function setupSkills()
    local skillSettings = setting:FindFirstChild("Skills") :: Configuration

    if not skillSettings then return end

    mapModel:SetAttribute("AllowAirDive", skillSettings:GetAttribute("AllowAirDive"))
    mapModel:SetAttribute("AllowSlide", skillSettings:GetAttribute("AllowSliding"))
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

    if mapScript then
        mapScript.Disabled = false
    end
    if mapLocalScript then
        mapLocalScript.Disabled = false
        mapLocalScript.Parent = plr.Character
    end

    mapModel:SetAttribute("ScriptsLoaded", true)
end
local function setupMain()
    setupMapLib()
    setupMap()
    setupLighting()
    setupVariants()
    setupButtons()
    setupButtonFuncs()
    setupWaters()
    setupSkills()

    --- starting
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

    local mainSettings = setting.Main :: Configuration
    local mapName = mainSettings:GetAttribute("Name") or "?"
    local difficulty = mainSettings:GetAttribute("Difficulty") or "Unrated"
    local creator = mainSettings:GetAttribute("Creator") or "?"

    workspace.Sounds.SFXs.MapStart:Play()

    Events.CreateHint.FireAll({
        Hint = `{mapName} [{MapDataBook.DifficultyNames[difficulty]}] by {creator}`,
        Color = MapDataBook.DifficultyColors[difficulty],
    })
    plr.Character:SetAttribute("MaxOxygen", mainSettings:GetAttribute("DefaultOxygen") or 100)
    plr.Character:SetAttribute("CurrentOxygen", plr.Character:GetAttribute("MaxOxygen"))

    Promise.delay(5):andThen(function()
        if soundId == "" or soundId == nil then return end

        local productInfo = MarketplaceService:GetProductInfo(soundId)
        if productInfo then
            Events.CreateHint.FireAll({
                Hint = `Music: {productInfo.Name}`,
                Color = Color3.fromRGB(125, 15, 79)
            })
        end
    end):catch(function(err)
        warn(err)
    end)

    setupScripts()
end
setupMain()
