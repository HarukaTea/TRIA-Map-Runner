--!nocheck

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RepS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local SoundService = game:GetService("SoundService")
local StarterPlayer = game:GetService("StarterPlayer")


local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)
local Events = require(SSS.HarukaServer.Library.ServerEvents)
local Promise = require(RepS.HarukaShared.Shared.Promise)
local ServerBindables = require(SSS.HarukaServer.Library.ServerBindables)


local GlobalTRIALib = {}

local wait = task.wait


--// Constructor

function GlobalTRIALib:Init()
    for funcId: string, func: (self) -> nil in GlobalTRIALib do
        if string.find(funcId, "_Listen") and typeof(func) == "function" then
            Promise.try(func, self)
        end
    end
end


--// Private Methods


function GlobalTRIALib:_ListenDefaultEventsTracker()
    Events.RequestToForceReset.SetCallback(function(plr: Player)
        local char = plr.Character

        if not plr.Character then return end

        if char:FindFirstChild("Humanoid") then
            char.Humanoid.Health = -1
        end
    end)
end


function GlobalTRIALib:_ListenCharSpawnTracker()
    ServerBindables.RToSpawnChar:Connect(function(plr: Player)
        if not plr then return end
        if not plr:IsDescendantOf(Players) then return end

        if plr.Character then
            wait(Players.RespawnTime)
            if plr.Character then
                plr.Character:Destroy()
                plr.Character = nil
            end
        end


        if not plr then return end
        if not plr:IsDescendantOf(Players) then return end

        local r6Char: Model

        Promise.new(function(resolve)
            local humanoidDesc = Players:GetHumanoidDescriptionFromUserId(plr.UserId)
            r6Char = Players:CreateHumanoidModelFromDescription(humanoidDesc, Enum.HumanoidRigType.R6)
            r6Char.Name = plr.Name

            resolve("Completed")

        end):timeout(5):catch(function()

            r6Char = RepS.Packages.Unloads.DummyH:Clone() :: Model
        end):await()

        --- keep retrying
        if r6Char.Name == "DummyH" then
            Promise.retryWithDelay(function()
                return Promise.new(function(resolve)
                    local humanoidDesc = Players:GetHumanoidDescriptionFromUserId(plr.UserId)

                    resolve(humanoidDesc)

                end):timeout(5):catch(function()

                end)

            end, 3, 6):andThen(function(humanoidDesc: HumanoidDescription)
                r6Char.Humanoid:ApplyDescription(humanoidDesc)

            end):catch(function()

            end)
        end

        r6Char.Archivable = true
        r6Char.Name = plr.Name
        r6Char:PivotTo(CFrame.new(Vector3.yAxis * 159))
        r6Char.Humanoid.DisplayName = plr.DisplayName
        r6Char.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
        r6Char.Humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
        r6Char.Animate:Destroy()
        r6Char.PrimaryPart = r6Char.Humanoid.RootPart

        r6Char:SetAttribute("HarukaUniqueId", HttpService:GenerateGUID(false))

        local alignMoverAtt = Instance.new("Attachment")
        alignMoverAtt.Name = "AlignMoverAttachment"
        alignMoverAtt.Parent = r6Char.PrimaryPart

        HarukaLib:SetCollisionGroup(r6Char, "PlayerBodyPart")

        plr.Character = r6Char


        local enumState = {
            Enum.HumanoidStateType.Swimming,
        }
        for _, state: Enum.HumanoidStateType in enumState do
            r6Char.Humanoid:SetStateEnabled(state, false)
        end


        --// clear collision box
        for _, part: BasePart in r6Char:GetChildren() do
            if not HarukaLib:IsBasePartType(part) then continue end
            if part == r6Char.PrimaryPart then continue end

            part.EnableFluidForces = false
            part.CanCollide = false
            part.Material = Enum.Material.SmoothPlastic
        end


        r6Char:SetAttribute("SpawnClock", DateTime.now().UnixTimestamp)
        r6Char.Parent = workspace.EntitiesPlayerChar


        for _, thatScript: Instance in StarterPlayer.StarterCharacterScripts:GetChildren() do
            thatScript:Clone().Parent = r6Char
        end
    end)
end


function GlobalTRIALib:_ListenTRIAMapLibRequestsTracker()
    repeat task.wait() until workspace:GetAttribute("Haruka_MapInited")


    local MapLib = game.GetMapLib:Invoke()()

    Events.ChangeLighting.SetCallback(function(_, data)
        local properties, postEffects = data.Properties, data.PostEffects

        MapLib:GetFeature("Lighting"):SetLighting(properties, postEffects)
    end)


    Events.ChangeMusic.SetCallback(function(_, data)
        local musicId, volume, startTick = data.MusicId, data.Volume, data.StartTick

        MapLib:ChangeMusic(musicId, volume, startTick)
    end)
end



function GlobalTRIALib:_ListenButtonTouchedTracker()
    repeat task.wait() until workspace:GetAttribute("Haruka_MapInited")


    local buttons = workspace.Map.Special:FindFirstChild("Button") :: Folder
    if not buttons then return end


    ServerBindables.BtnTouched:Connect(function(btnType: string, index: number, button: Model)
        if btnType == "PathChild" then
            local buttonStates = require(SSS.HarukaServer.Library.ButtonStatesShared)[index]
            if buttonStates == nil then return end


            for _, child: Model in buttons:GetChildren() do
                if child:IsA("Model") and string.find(child.Name, "_Button") then
                    if child:GetAttribute("Index") == tostring(index) then
                        local nextMarker = child:FindFirstChild("ButtonMarker") :: BillboardGui

                        child.Light.Color = buttonStates.PathChild.Activated
                        child:SetAttribute("Hit", true)

                        nextMarker.Enabled = false
                    end
                end
            end

        elseif btnType == "Normal" then
            local buttonStates = require(SSS.HarukaServer.Library.ButtonStatesShared)[index]
            if buttonStates == nil then return end


            button:SetAttribute("Hit", true)
            SoundService.Sounds.SFXs.BtnPressed:Play()

            button.ButtonMarker.Enabled = false

            if button:GetAttribute("Group") then
                button.Light.Color = buttonStates.Group.Activated
            elseif button:GetAttribute("PathChild") then
                button.Light.Color = buttonStates.PathChild.Activated
            else
                button.Light.Color = buttonStates.Default.Activated
            end



            for _, child: Model in buttons:GetChildren() do
                if child:IsA("Model") and string.find(child.Name, "_Button") then
                    if child:GetAttribute("Index") == tostring(index + 1) then
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


return GlobalTRIALib

