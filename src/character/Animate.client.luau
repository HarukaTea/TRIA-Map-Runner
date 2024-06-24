--!nocheck

local KSP = game:GetService("KeyframeSequenceProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local HarukaLib = require(ReplicatedStorage.Modules.Packages.HarukaLib)

local Add, Empty = HarukaLib.Bin()

local char = script.Parent :: Model
local animations = ReplicatedStorage.Package.Keyframes :: Folder
local animator = char.Humanoid:WaitForChild("Animator") :: Animator

local function _createAnimation(keyframe: KeyframeSequence) : Animation
	local anim = Instance.new("Animation")
	anim.AnimationId = KSP:RegisterKeyframeSequence(keyframe)

	return anim
end

local ANIMS = {
	Idle = animator:LoadAnimation(_createAnimation(animations.Idle)),
	Freefall = animator:LoadAnimation(_createAnimation(animations.Falling)),
	Jumping = animator:LoadAnimation(_createAnimation(animations.Jump)),
	Running = animator:LoadAnimation(_createAnimation(animations.Walk)),
	Seated = animator:LoadAnimation(_createAnimation(animations.Sit)),
	Climbing = animator:LoadAnimation(_createAnimation(animations.Climbing)),
}
local oldAnim: AnimationTrack

--// Private

local function startAnim(anim: AnimationTrack, transitionTime: number)
	if oldAnim ~= anim then
		if oldAnim then oldAnim:Stop(transitionTime) end
		if anim then anim:Play(transitionTime) end

		oldAnim = anim
	end
end
local localStateFunctions = {
	[Enum.HumanoidStateType.Jumping] = function()
		startAnim(ANIMS.Jumping, 0.1)
	end,
	[Enum.HumanoidStateType.Freefall] = function()
		startAnim(ANIMS.Freefall, 0.1)
	end,
	[Enum.HumanoidStateType.Seated] = function()
		startAnim(ANIMS.Seated, 0.5)
	end,
}
local stateFunctions = {
	[Enum.HumanoidStateType.Jumping] = true,
	[Enum.HumanoidStateType.Freefall] = true,
	[Enum.HumanoidStateType.Swimming] = true,
	[Enum.HumanoidStateType.GettingUp] = true,
	[Enum.HumanoidStateType.Landed] = true,
	[Enum.HumanoidStateType.Dead] = true,
	[Enum.HumanoidStateType.Climbing] = true,
	[Enum.HumanoidStateType.Running] = true
}

--// Setup
local function setup()
	local humanoid = char.Humanoid :: Humanoid
	local activeState = humanoid:GetState()

	Add(humanoid.StateChanged:Connect(function(_, state)
		activeState = state

		local localFunc = localStateFunctions[activeState]
		if localFunc then localFunc() return end

		local func = stateFunctions[activeState]
		if not func then startAnim() end
	end))
	Add(humanoid.Running:Connect(function()
		if humanoid.MoveDirection.Magnitude > 0 then
			startAnim(ANIMS.Running, 0.1)
		else
			startAnim(ANIMS.Idle, 0.1)
		end
	end))
	Add(humanoid.Climbing:Connect(function(vel)
		if vel ~= 0 then
			startAnim(ANIMS.Climbing, 0.1)
			ANIMS.Climbing:AdjustSpeed(1)
		else
			ANIMS.Climbing:AdjustSpeed(0)
		end
	end))

	local func = localStateFunctions[activeState]
	if func then func() else startAnim(ANIMS.Idle, 0.1) end
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
