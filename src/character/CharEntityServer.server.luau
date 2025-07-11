--!nocheck

repeat task.wait() until workspace:GetAttribute("Haruka_MapPreloadRun")


local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local ServerBindables = require(SSS.HarukaServer.Library.ServerBindables)
local TEMPLATE = require(SSS.HarukaServer.Library.CharTemplate)
local HarukaLib = require(ReplicatedStorage.HarukaShared.Shared.HarukaLib)


local char = script:FindFirstAncestorOfClass("Model")
local spawnLocation = workspace.Map.Special.Spawn :: BasePart
local plr = Players:GetPlayerFromCharacter(char)


local CharLib = {}
local Add, Empty = HarukaLib.Bin()


local isDead = false


Add(Players.PlayerRemoving:Connect(function(player: Player)
	if player == plr then
		CharLib:Destroy()
	end
end))
Add(script.Destroying:Connect(function()
    CharLib:Destroy()
end))


function CharLib:Init()
	self:_RagdollInit()

    for funcId: string, func: (self) -> nil in CharLib do
        if string.find(funcId, "_Listen") and typeof(func) == "function" then
            task.spawn(func, self)
        end
    end
end



function CharLib:Destroy()
    if isDead then return end

    isDead = true
    Empty()

    ServerBindables.RToSpawnChar:Fire(plr)
end


--// Private functions


function CharLib:_ListenCharDestroyTracker()
	Add(char.Humanoid.HealthChanged:Connect(function(health: number)
		if health <= 0 then
			self:Destroy()
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
                self:Destroy()
                return
            end
        else
            self:Destroy()
        end
	end))
end



function CharLib:_RagdollInit()
	local humanoid = char.Humanoid :: Humanoid

	humanoid.BreakJointsOnDeath = false
	humanoid.RequiresNeck = false
end


function CharLib:_TriggerRagdoll()
	local humanoid = char.Humanoid :: Humanoid

	local attachmentCFrames = {
		["Neck"] = {CFrame.new(0, 1, 0, 0, -1, 0, 1, 0, -0, 0, 0, 1), CFrame.new(0, -0.5, 0, 0, -1, 0, 1, 0, -0, 0, 0, 1)},
		["Left Shoulder"] = {CFrame.new(-1.3, 0.75, 0, -1, 0, 0, 0, -1, 0, 0, 0, 1), CFrame.new(0.2, 0.75, 0, -1, 0, 0, 0, -1, 0, 0, 0, 1)},
		["Right Shoulder"] = {CFrame.new(1.3, 0.75, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1), CFrame.new(-0.2, 0.75, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)},
		["Left Hip"] = {CFrame.new(-0.5, -1, 0, 0, 1, -0, -1, 0, 0, 0, 0, 1), CFrame.new(0, 1, 0, 0, 1, -0, -1, 0, 0, 0, 0, 1)},
		["Right Hip"] = {CFrame.new(0.5, -1, 0, 0, 1, -0, -1, 0, 0, 0, 0, 1), CFrame.new(0, 1, 0, 0, 1, -0, -1, 0, 0, 0, 0, 1)},
	}

	local function _createColliderPart(part: BasePart)
		if not part then return end

		local rp = Instance.new("Part")
		rp.Name = "ColliderPart"
		rp.Size = part.Size / 1.7
		rp.Massless = true
		rp.CFrame = part.CFrame
		rp.Transparency = 1

		local wc = Instance.new("WeldConstraint")
		wc.Part0 = rp
		wc.Part1 = part

		wc.Parent = rp
		rp.Parent = part
	end
	for _, motor: Motor6D in char:GetDescendants() do
		if motor:IsA("Motor6D") then
			if not attachmentCFrames[motor.Name] then return end

			motor.Enabled = false

			local a0, a1 = Instance.new("Attachment"), Instance.new("Attachment")
			a0.CFrame = attachmentCFrames[motor.Name][1]
			a1.CFrame = attachmentCFrames[motor.Name][2]

			a0.Name = "RagdollAttachment"
			a1.Name = "RagdollAttachment"

			_createColliderPart(motor.Part1)

			local b = Instance.new("BallSocketConstraint")
			b.Attachment0 = a0
			b.Attachment1 = a1
			b.Name = "RagdollConstraint"

			b.Radius = 0.15
			b.LimitsEnabled = true
			b.TwistLimitsEnabled = false
			b.MaxFrictionTorque = 0
			b.Restitution = 0
			b.UpperAngle = 90
			b.TwistLowerAngle = -45
			b.TwistUpperAngle = 45

			if motor.Name == "Neck" then
				b.TwistLimitsEnabled = true
				b.UpperAngle = 45
				b.TwistLowerAngle = -70
				b.TwistUpperAngle = 70
			end

			a0.Parent = motor.Part0
			a1.Parent = motor.Part1
			b.Parent = motor.Parent
		end
	end

	humanoid.AutoRotate = false
end


function CharLib:_DoTRIACharInit()
    char.PrimaryPart = char.Humanoid.RootPart

    char.Humanoid.UseJumpPower = true
    char.Humanoid.WalkSpeed = 20
    char.Humanoid.JumpPower = 50

    char:PivotTo(spawnLocation.CFrame * CFrame.new(0, 3, 0))
    char.PrimaryPart.Anchored = true

    for attr: string, val: any in TEMPLATE do
        char:SetAttribute(attr, val)
    end


    repeat task.wait() until workspace.Map:GetAttribute("IsStarted")

    char.PrimaryPart.Anchored = false

    char:SetAttribute("AllowAirDive", workspace.Map:GetAttribute("AllowAirDive"))
    char:SetAttribute("AllowSlide", workspace.Map:GetAttribute("AllowSlide"))
    char:SetAttribute("_CharDataLoaded", true)
end


CharLib:Init()


char:SetAttribute("Haruka_CharServerInited", true)
