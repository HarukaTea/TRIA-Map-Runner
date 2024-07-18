--!nocheck

local KSP = game:GetService("KeyframeSequenceProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local HarukaLib = require(ReplicatedStorage.Modules.Packages.HarukaLib)

local Add, Empty = HarukaLib.Bin()

local animations = ReplicatedStorage.Package.Animations :: Folder
local char = script.Parent :: Model
local keyframes = ReplicatedStorage.Package.Keyframes :: Folder
local animator = char.Humanoid:WaitForChild("Animator") :: Animator

-- create temp animation for studio to use
local function _createTempAnimation(keyframe: KeyframeSequence) : Animation
	local anim = Instance.new("Animation")
	anim.AnimationId = KSP:RegisterKeyframeSequence(keyframe)

	return anim
end

local ANIMS = {
	Idle = animator:LoadAnimation(animations.Idle),
	Freefall = animator:LoadAnimation(_createTempAnimation(keyframes.Fall)),
	Jumping = animator:LoadAnimation(_createTempAnimation(keyframes.Jump)),
	Running = animator:LoadAnimation(_createTempAnimation(keyframes.Walk)),
	Seated = animator:LoadAnimation(animations.Sit),
	Climbing = animator:LoadAnimation(animations.Climb),
}
local oldAnim: AnimationTrack


local function startAnim(anim: AnimationTrack, transitionTime: number)
	if oldAnim ~= anim then
		if oldAnim then oldAnim:Stop(transitionTime) end
		if anim then anim:Play(transitionTime) end

		oldAnim = anim
	end
end

local jumpAnimTime = 0
local isFreefalling = false

--// Setup
local function setup()
	local humanoid = char.Humanoid :: Humanoid

	Add(humanoid.Running:Connect(function()
		if humanoid.MoveDirection.Magnitude > 0 then
			startAnim(ANIMS.Running, 0.1)
			ANIMS.Running:AdjustSpeed(20 / 26)
		else
			startAnim(ANIMS.Idle, 0.1)
		end

		isFreefalling = false
	end))
	Add(humanoid.Climbing:Connect(function(vel)
		if vel ~= 0 then
			startAnim(ANIMS.Climbing, 0.1)
			ANIMS.Climbing:AdjustSpeed(vel / 12)
		else
			ANIMS.Climbing:AdjustSpeed(0)
		end

		isFreefalling = false
	end))
	Add(humanoid.Jumping:Connect(function()
		jumpAnimTime = 0.3

		startAnim(ANIMS.Jumping, 0.1)
		isFreefalling = false
	end))
	Add(humanoid.FreeFalling:Connect(function()
		if jumpAnimTime <= 0 then
			startAnim(ANIMS.Freefall, 0.1)
		end

		isFreefalling = true
	end))
	Add(humanoid.Seated:Connect(function()
		startAnim(ANIMS.Seated, 0.1)

		isFreefalling = false
	end))

	Add(RunService.RenderStepped:Connect(function(dt)
		if jumpAnimTime > 0 then jumpAnimTime -= dt end
		if isFreefalling and jumpAnimTime <= 0 then startAnim(ANIMS.Freefall, 0.1) end
	end))

	startAnim(ANIMS.Idle, 0.1)
	isFreefalling = false

	char.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
end
setup()

--// Clear
local function onDead()
	--// 256 limit still happens, idk
	for _, anim: AnimationTrack in ANIMS do
		anim:Stop(0)
		anim:Destroy()
	end
	local animTracks = animator:GetPlayingAnimationTracks()
	for _, track: AnimationTrack in animTracks do
		track:Stop(0)
		track:Destroy()
	end

	Empty()
end
char.Humanoid.Died:Once(onDead)
