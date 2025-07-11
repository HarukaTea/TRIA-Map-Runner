--!nocheck

local CAS = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local TS = game:GetService("TweenService")

local char = script:FindFirstAncestorOfClass("Model")
local plr = Players.LocalPlayer


repeat task.wait() until char:GetAttribute("Haruka_CharClientInited")



local isInFPView = false
local toggleCD = false
local quickTween = TweenInfo.new(0.12, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
local oldDistance = 25

local function toggleFPView(_, inputState: Enum.UserInputState)
    if inputState ~= Enum.UserInputState.Begin then return end
    if toggleCD then return end

    toggleCD = true
    task.delay(0.15, function()
        toggleCD = false
    end)

    if isInFPView then
        isInFPView = false

        plr.CameraMaxZoomDistance = 128

        local tween = TS:Create(plr, quickTween, { CameraMinZoomDistance = oldDistance })
        tween:Play()
        tween.Completed:Wait()

        plr.CameraMinZoomDistance = 0.5
    else
        oldDistance = (workspace.CurrentCamera.CFrame.Position - char.PrimaryPart.Position).Magnitude

        plr.CameraMaxZoomDistance = oldDistance
        TS:Create(plr, quickTween, { CameraMaxZoomDistance = 0.5 }):Play()

        isInFPView = true
    end
end
CAS:BindAction("ToggleFPView", toggleFPView, false, Enum.KeyCode.R)


local function clear()
    CAS:UnbindAction("ToggleFPView")
end
char.Humanoid.Died:Once(clear)