--!nocheck

local CAS = game:GetService("ContextActionService")
local Debris = game:GetService("Debris")
local KSP = game:GetService("KeyframeSequenceProvider")
local RepS = game:GetService("ReplicatedStorage")
local RS = game:GetService("RunService")
local TS = game:GetService("TweenService")

local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local Add, Empty = HarukaLib.Bin()

local char = script:FindFirstAncestorOfClass("Model")
local keyframes = RepS.Packages.Keyframes :: Folder
local animator = char.Humanoid:WaitForChild("Animator") :: Animator


repeat task.wait() until char:GetAttribute("Haruka_CharClientInited")



-- create temp animation for studio to use
local function _createTempAnimation(keyframe: KeyframeSequence) : Animation
	local anim = Instance.new("Animation")
	anim.AnimationId = KSP:RegisterKeyframeSequence(keyframe)

	return anim
end

local ANIMS = {
	SwimUp = animator:LoadAnimation(_createTempAnimation(keyframes.SwimUp)),
	SwimDown = animator:LoadAnimation(_createTempAnimation(keyframes.SwimDown)),
	SwimIdle = animator:LoadAnimation(_createTempAnimation(keyframes.SwimIdle)),
	Swimming = animator:LoadAnimation(_createTempAnimation(keyframes.Swimming)),
	SwimUpDiagonal = animator:LoadAnimation(_createTempAnimation(keyframes.SwimUpDiagonal)),
	SwimDownDiagonal = animator:LoadAnimation(_createTempAnimation(keyframes.SwimDownDiagonal))
}
Add(ANIMS)

--- swimming
local animState = nil
local isSwimming = false
local swimVel: BodyVelocity = nil

local swimUp = false
local swimDown = false

local function playSwimAnim(newAnim: string)
    local oldAnim = animState

    if newAnim ~= oldAnim then
        local old = ANIMS[oldAnim]
        local new = ANIMS[newAnim]

        if old then old:Stop() end
        if new then new:Play() end

        animState = newAnim
    end
end
local function swimIn()
	if not isSwimming then
        isSwimming = true
        char:SetAttribute("IsSwimming", true)

		char.Humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
        char.Humanoid.HipHeight = -3

        local rootVel = char.PrimaryPart.Velocity

        local diveVel = Instance.new("BodyVelocity")
        diveVel.Name = "DiveVelocity"
        diveVel.MaxForce = Vector3.new(0, 8000, 0)
        diveVel.Velocity = Vector3.new(rootVel.X, rootVel.Y, rootVel.Z)
        diveVel.Parent = char.Head

        if not swimVel then
            swimVel = Instance.new("BodyVelocity")
            swimVel.Name = "SwimVelocity"
            swimVel.P = 8000
            swimVel.Velocity = Vector3.new()
            swimVel.MaxForce = Vector3.new(rootVel.X, 8000, rootVel.Z)
            swimVel.Parent = char.PrimaryPart
        end


        HarukaLib:CreateTween(diveVel, TweenInfo.new(0.2), {
            Velocity = Vector3.new(rootVel.X, 0, rootVel.Z)
        }):Play()

        Debris:AddItem(diveVel, 0.2)

        playSwimAnim("SwimIdle")
	end
end
local function swimOut()
	if isSwimming then
		isSwimming = false
        swimUp = false
        swimDown = false

        char:SetAttribute("IsSwimming", false)

        if swimVel then
            swimVel:Destroy()
            swimVel = nil
        end

        local rootVel = char.PrimaryPart.Velocity

        char.Humanoid.HipHeight = 0
        char.PrimaryPart.Velocity = Vector3.new(
            rootVel.X, char.Humanoid.JumpPower * 1.2, rootVel.Z
        )

        playSwimAnim(nil)
	end
end

Add(char.Head.Touched:Connect(function(water: BasePart)
    if water:IsA("BasePart") and string.find(water.Name, "_Liquid") then
        swimIn()
    end
end))
Add(char.Head.TouchEnded:Connect(function(water: BasePart)
    if water:IsA("BasePart") and string.find(water.Name, "_Liquid") then
        swimOut()
    end
end))
Add(char.Humanoid.Changed:Connect(function()
    if char.Humanoid.Jump and isSwimming then
        swimUp = true
        swimDown = false

    elseif not char.Humanoid.Jump and isSwimming then
        swimUp = false

    elseif char.Humanoid.Jump and not isSwimming then
        swimUp = false

    elseif not char.Humanoid.Jump and not isSwimming then
        swimUp = false
    end
end))
Add(RS.Heartbeat:Connect(function()
    if isSwimming then
        local swimVelocity = 0

        if swimUp then
            swimVelocity = char.Humanoid.WalkSpeed

        elseif swimDown then
            swimVelocity = -char.Humanoid.WalkSpeed

        elseif not swimUp or not swimDown then
            swimVelocity = 0
        end

        local swimmingVel = char.PrimaryPart:WaitForChild("SwimVelocity") :: BodyVelocity
        local moveDirection = if char.Humanoid.MoveDirection.Magnitude > 0.1 then true else false
        local direction = swimmingVel.Velocity

        if direction.Magnitude > 0.2 then
            if moveDirection then
                if swimVelocity > 0.1 then
                    playSwimAnim("SwimUpDiagonal")

                elseif swimVelocity < -0.1 then
                    playSwimAnim("SwimDownDiagonal")

                else
                    playSwimAnim("Swimming")
                end
            else
                if swimVelocity < 0 then
                    playSwimAnim("SwimDown")
                else
                    playSwimAnim("SwimUp")
                end
            end
        else
            playSwimAnim("SwimIdle")
        end

        swimmingVel.Velocity = Vector3.new(
            char.Humanoid.MoveDirection.X * char.Humanoid.WalkSpeed,
            swimVelocity,
            char.Humanoid.MoveDirection.Z * char.Humanoid.WalkSpeed
        )
    end
end))

local function swimAction(action: string, inputState: Enum.UserInputState)
    if action == "SwimUp" then
        if inputState == Enum.UserInputState.Begin then
            swimUp = true

        elseif inputState == Enum.UserInputState.End then
            swimUp = false
        end

    elseif action == "SwimDown" then
        if inputState == Enum.UserInputState.Begin then
            swimDown = true

        elseif inputState == Enum.UserInputState.End then
            swimDown = false
        end
    end

    return if (isSwimming and inputState == Enum.UserInputState.Begin) then
        Enum.ContextActionResult.Sink else Enum.ContextActionResult.Pass
end
CAS:BindActionAtPriority("SwimDown", swimAction, true, 3000, Enum.KeyCode.LeftShift)


--// Clear
char.Humanoid.Died:Once(function()
    if isSwimming then
        isSwimming = false
        swimUp = false
        swimDown = false
    end

    CAS:UnbindAction("SwimDown")

    Empty()
end)