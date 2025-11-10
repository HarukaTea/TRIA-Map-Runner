
local CAS = game:GetService("ContextActionService")
local KSP = game:GetService("KeyframeSequenceProvider")
local RepS = game:GetService("ReplicatedStorage")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local Add, Empty = HarukaLib.Bin()

local char = script:FindFirstAncestorOfClass("Model")
local humanoid = char.Humanoid :: Humanoid
local animator = humanoid.Animator :: Animator


repeat task.wait() until char:GetAttribute("Haruka_CharClientInited")



local animation = Instance.new("Animation")
animation.AnimationId = KSP:RegisterKeyframeSequence(RepS.Packages.Keyframes.Slide)

local slideAnim = animator:LoadAnimation(animation)
local canSlide = true

local function _cancelSlide()
    humanoid:MoveTo(char.PrimaryPart.Position)
    humanoid.HipHeight = 0

    canSlide = true
    slideAnim:Stop()
end
local function _slide()
    if char:GetAttribute("AllowAirDive") then
        if humanoid:GetState() == Enum.HumanoidStateType.Freefall then
            local currentVel = char.PrimaryPart.Velocity

            char.PrimaryPart.Velocity = Vector3.new(
                currentVel.X,
                (-char.Humanoid.JumpPower) * 1.5,
                currentVel.Z
            )
        end
    end
    while RS.Heartbeat:Wait() do
        if (humanoid:GetState() == Enum.HumanoidStateType.Running)
            or (humanoid:GetState() == Enum.HumanoidStateType.RunningNoPhysics) then
            break
        end
    end

    humanoid.HipHeight = -1.5
    slideAnim:Play()

    local currentVel = char.PrimaryPart.Velocity
    char.PrimaryPart.Velocity = Vector3.new(
        currentVel.X,
        -35,
        currentVel.Z
    )

    local lastTick = tick()
    local move = if humanoid.MoveDirection.Magnitude > 0 then humanoid.MoveDirection * 20
        else char.PrimaryPart.CFrame.LookVector * 20

    local slideAdd, slideEmpty = HarukaLib.Bin()
    Add(slideEmpty)

    while canSlide == false do
        RS.RenderStepped:Wait()

        humanoid:MoveTo(char.PrimaryPart.Position + move)

        slideAdd(UIS.JumpRequest:Once(function()
            canSlide = true
        end))
        slideAdd(humanoid.Climbing:Once(function()
            canSlide = true
        end))

        if tick() - lastTick >= 1 then canSlide = true end
    end
    slideEmpty()

    canSlide = true
    _cancelSlide()
end

local function slideHandler(_, inputState: Enum.UserInputState)
    if not char:GetAttribute("AllowSlide") then return end
    if char:GetAttribute("IsSwimming") then return end

    if canSlide == true and inputState == Enum.UserInputState.Begin then
        canSlide = false
        _slide()

    elseif inputState == Enum.UserInputState.End then
        canSlide = true
        _cancelSlide()
    end
end
CAS:BindAction("Slide", slideHandler, false, Enum.KeyCode.E)

--// Clear
char.Humanoid.Died:Once(function()
    CAS:UnbindAction("Slide")

    Empty()
end)