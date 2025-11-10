
repeat task.wait() until workspace:GetAttribute("Haruka_PlayerClientInited")


local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local KSP = game:GetService("KeyframeSequenceProvider")
local SoundService = game:GetService("SoundService")


local Events = require(ReplicatedStorage.HarukaShared.Library.Events)
local Bindables = require(ReplicatedStorage.HarukaShared.Library.Bindables)
local HarukaLib = require(ReplicatedStorage.HarukaShared.Shared.HarukaLib)

local char = script:FindFirstAncestorOfClass("Model")
local plr = Players.LocalPlayer

local Add, Empty = HarukaLib.Bin()

local wait = task.wait

repeat wait() until char:HasTag("PlayerCharEntity")


local CharLib = {}


Add(Players.PlayerRemoving:Connect(function(player: Player)
	if player == plr then
		CharLib:__Destroy()
        CharLib:Destroy()
	end
end))
Add(script.Destroying:Connect(function()
    CharLib:__Destroy()
    CharLib:Destroy()
end))



function CharLib:Init()
    for funcId: string, func: (self) -> nil in CharLib do
        if string.find(funcId, "_Listen") and typeof(func) == "function" then
            func(self)
        end
    end


    Add(char.Humanoid.HealthChanged:Connect(function(health: number)
        if health <= 0 then
            pcall(self.__Destroy, self)
            pcall(self.Destroy, self)
            pcall(self._TriggerRagdoll, self)

            char.Humanoid.Health = -1
        end
    end))
    Add(char.PrimaryPart:GetPropertyChangedSignal("Parent"):Connect(function()
        local newParent = char
        if newParent then
            if newParent.PrimaryPart == nil and newParent:FindFirstChild("Humanoid") then
                newParent.Humanoid.Health = -1
                return
            end
            if newParent.PrimaryPart == nil and not newParent:FindFirstChild("Humanoid") then
                pcall(self.__Destroy, self)
                pcall(self.Destroy, self)
                return
            end
        else
            pcall(self.__Destroy, self)
            pcall(self.Destroy, self)
        end
    end))


    self:_InitUI()
end


function CharLib:Destroy()
    Empty()
end


--// Private functions



function CharLib:_InitUI()
    self.UIAdd, self.UIEmpty = HarukaLib.Bin()

    for _, module: ModuleScript in ReplicatedStorage.HarukaShared.UIAtlas.UI:GetChildren() do
		if string.find(module.Name, ".spec") then warn(module.Name) continue end
        if string.find(module.Name, "_local") then continue end
        if string.find(module.Name, "_preload") then continue end


        local success, err = pcall(function()
            local clear = require(module)(plr)
            if clear == nil then
                warn("Failed to load UI clear module: "..module.Name)
                return
            end

            self.UIAdd(clear)
        end)
        if not success then
            warn(err)
        end
	end
end

function CharLib:__Destroy()
    self.UIEmpty()

    SoundService.Sounds.SFXs.Died:Play()

    Events.RequestToForceReset.Fire()
end




function CharLib:_ListenAnimateTracker()
    local humanoid = char.Humanoid :: Humanoid
    local animator = humanoid:WaitForChild("Animator") :: Animator
    local animationsChar = ReplicatedStorage.Packages.Anims.CharAnims :: Folder
    local keyframes = ReplicatedStorage.Packages.Keyframes :: Folder


    local function _createTempAnimation(keyframe: KeyframeSequence) : Animation
        local anim = Instance.new("Animation")
        anim.AnimationId = KSP:RegisterKeyframeSequence(keyframe)

        return anim
    end
    self.Animator = animator


    self.CharAnims = {
        Idle = animator:LoadAnimation(animationsChar.Idle),
        Fall = animator:LoadAnimation(_createTempAnimation(keyframes.Fall)),
        Jump = animator:LoadAnimation(_createTempAnimation(keyframes.Jump)),
        Run = animator:LoadAnimation(_createTempAnimation(keyframes.Walk)),
        Sit = animator:LoadAnimation(animationsChar.Sit),
        Climb = animator:LoadAnimation(animationsChar.Climb),

        dance1 = animator:LoadAnimation(animationsChar.dance1),
        dance2 = animator:LoadAnimation(animationsChar.dance2),
        dance3 = animator:LoadAnimation(animationsChar.dance3),
        cheer = animator:LoadAnimation(animationsChar.cheer),
        point = animator:LoadAnimation(animationsChar.point),
        wave = animator:LoadAnimation(animationsChar.wave),
        laugh = animator:LoadAnimation(animationsChar.laugh),
    }
    Add(self.CharAnims)
    for animId: string, anim: AnimationTrack in self.CharAnims do
        if string.find(animId, "dance") then
            anim.Looped = true
        end
    end
    self.CharAnims.cheer.Looped = false
    self.CharAnims.point.Looped = false
    self.CharAnims.wave.Looped = false
    self.CharAnims.laugh.Looped = false



    self.OldAnim = nil :: AnimationTrack?

    local function _playAnim(anim: AnimationTrack, transitionTime: number)
        if self.OldAnim ~= anim then
            if self.OldAnim then self.OldAnim:Stop(transitionTime) end
            if anim then anim:Play(transitionTime) end

            self.OldAnim = anim
	    end
    end
	local charAnims = self.CharAnims
	Add(humanoid.Running:Connect(function()
		if humanoid.MoveDirection.Magnitude > 0 then
            _playAnim(charAnims.Run, 0.15)
		else
            _playAnim(charAnims.Idle, 0.15)
		end
	end))
	Add(humanoid.Climbing:Connect(function(vel)
		if vel ~= 0 then
			_playAnim(charAnims.Climb, 0.1)
		else
			charAnims.Climb:AdjustSpeed(0)
		end
	end))
	Add(humanoid.Jumping:Connect(function()
        _playAnim(charAnims.Jump, 0.25)
	end))
	Add(humanoid.FreeFalling:Connect(function()
        _playAnim(charAnims.Fall, 0.2)
	end))
	Add(humanoid.Seated:Connect(function()
		_playAnim(charAnims.Sit, 0.1)
	end))


	_playAnim(charAnims.Idle, 0.1)



    Add(Bindables.PlayerChatted:Connect(function(msg: string, sender: Player)
        if sender ~= plr then return end

        local emote = ""
        if msg == "/e dance" then
            emote = "dance"..math.random(1, 3)

        elseif (string.sub(msg, 1, 3) == "/e ") then
            emote = string.sub(msg, 4)

        elseif (string.sub(msg, 1, 7) == "/emote ") then
            emote = string.sub(msg, 8)
        end

        local whiteList = { "dance1", "dance2", "dance3", "cheer", "point", "wave", "laugh" }

        if (self.CharAnims.Idle.IsPlaying and table.find(whiteList, emote)) then
            _playAnim(self.CharAnims[emote], 0.1)
        end
    end))
end



function CharLib:_TriggerRagdoll()
    char.Torso:ApplyImpulse(char.Torso.CFrame.LookVector * -100)
end



CharLib:Init()



char:SetAttribute("Haruka_CharClientInited", true)