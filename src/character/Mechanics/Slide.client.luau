--!nocheck

local ContextActionService = game:GetService("ContextActionService")
local KSP = game:GetService("KeyframeSequenceProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local char = script.Parent.Parent :: Model
local humanoid = char.Humanoid :: Humanoid
local animator = humanoid.Animator :: Animator

local animation = Instance.new("Animation")
animation.AnimationId = KSP:RegisterKeyframeSequence(ReplicatedStorage.Package.Keyframes.Slide)

local slideAnim = animator:LoadAnimation(animation)
local canSlide = true
local slideThread: thread = nil

local function __endPlatform()
    humanoid.PlatformStand = false

    for _, child: Instance in char.PrimaryPart:GetChildren() do
        if child.Name == "SlideVel" then child:Destroy() end
    end
end
UserInputService.JumpRequest:Connect(__endPlatform)

local function _cancelSlide(isForce: boolean?)
    if canSlide then return end
    if isForce then
        if slideThread then task.cancel(slideThread) end
    end

    canSlide = true

    slideAnim:Stop()

    __endPlatform()
end
local function _slide()
    if not canSlide then return end

    canSlide = false

    slideThread = task.spawn(function()
        humanoid.PlatformStand = true
        slideAnim:Play()

        local gyro = Instance.new("BodyGyro")
        gyro.Name = "SlideVel"
        gyro.P = 50
        gyro.MaxTorque = Vector3.new(1, 1, 1) * 10000
        gyro.CFrame = CFrame.new(char.PrimaryPart.CFrame.LookVector)
        gyro.Parent = char.PrimaryPart

        local vel = Instance.new("BodyVelocity")
        vel.Name = "SlideVel"
        vel.MaxForce = Vector3.new(18500, 1000, 18500)
        vel.Velocity = humanoid.MoveDirection * humanoid.WalkSpeed
        vel.Parent = char.PrimaryPart

        task.wait(0.7)
        _cancelSlide(false)
    end)
end

local function slideHandler(_, inputState: Enum.UserInputState)
    if inputState == Enum.UserInputState.Begin then
        _slide()
    elseif inputState == Enum.UserInputState.End then
        _cancelSlide(true)
    end
end
ContextActionService:BindAction("Slide", slideHandler, false, Enum.KeyCode.E)
