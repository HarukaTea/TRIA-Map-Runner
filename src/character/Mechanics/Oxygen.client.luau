--!nocheck

local RepS = game:GetService("ReplicatedStorage")

local HarukaLib = require(RepS.Modules.Packages.HarukaLib)

local Add, Empty = HarukaLib.Bin()

local char = script.Parent.Parent :: Model

repeat task.wait() until workspace:WaitForChild("Map", 999)

local isSwimming = false
local currentWater: BasePart = nil

local splashCD = 0
local maxOxygen = workspace.Map.Settings.Main:GetAttribute("DefaultOxygen")
local timePerLoss = 0.085
local oxygenDepletion = 1

local defaultOxygen = maxOxygen

Add(char.Head.Touched:Connect(function(hit: BasePart)
    if hit:IsA("BasePart") and (string.find(hit.Name, "_Liquid") or string.find(hit.Name, "_Gas")) then
        isSwimming = true

        currentWater = hit
    end
end))
Add(char.Head.TouchEnded:Connect(function(hit: BasePart)
    if hit:IsA("BasePart") and (string.find(hit.Name, "_Liquid") or string.find(hit.Name, "_Gas")) then
        isSwimming = false

        currentWater = nil
    end
end))
Add(char.Humanoid.Touched:Connect(function(hit: BasePart)
    if hit:IsA("BasePart")
        and hit.Name == "Hitbox"
        and hit.Parent
        and hit.Parent.Name == "AirTank" then

        local oxygenGiven = hit.Parent:GetAttribute("Oxygen") :: number

        HarukaLib:AddAttr(char, "MaxOxygen", oxygenGiven)

        maxOxygen = char:GetAttribute("MaxOxygen")
        char:SetAttribute("CurrentOxygen", maxOxygen)

        hit.Parent:Destroy()
    end
end))

--- air controls
local function decreaseAir()
    splashCD = 2

    HarukaLib:AddAttr(char, "CurrentOxygen", -oxygenDepletion)
    if char:GetAttribute("CurrentOxygen") >= maxOxygen then char:SetAttribute("CurrentOxygen", maxOxygen) end

    if char:GetAttribute("CurrentOxygen") < defaultOxygen and maxOxygen ~= defaultOxygen then
        maxOxygen = defaultOxygen

        char:SetAttribute("MaxOxygen", maxOxygen)
    end
end
local function increaseAir()
    splashCD = math.max(0, splashCD - 0.25)

    if splashCD <= 0 then
        timePerLoss = 0.065

        HarukaLib:AddAttr(char, "CurrentOxygen", 1)
        if char:GetAttribute("CurrentOxygen") >= maxOxygen then char:SetAttribute("CurrentOxygen", maxOxygen) end
    end
end

Add(task.spawn(function()
    while task.wait(timePerLoss) do
        if char.Humanoid.Health > 0 then
            if isSwimming then
                if currentWater then
                    local state = currentWater:GetAttribute("Type") :: string

                    if state == "water" then
                        oxygenDepletion = 1
                        timePerLoss = 0.085

                    elseif state == "acid" then
                        oxygenDepletion = 1
                        timePerLoss = 0.04

                    elseif state == "lava" then
                        char:SetAttribute("CurrentOxygen", 0)

                    elseif state == "custom" then
                        --// FIXME: this may be inaccurate, need to check again in TRIA 1.0
                        oxygenDepletion = (currentWater:GetAttribute("OxygenDepletion") or 1) / (1 / 0.085)
                        timePerLoss = 0.085
                    end
                end

                decreaseAir()

            elseif not isSwimming then
                if char:GetAttribute("MaxOxygen") > (maxOxygen or 100) then
                    continue

                elseif maxOxygen <= maxOxygen then
                    increaseAir()
                end
            end

            if char:GetAttribute("CurrentOxygen") <= 0 then
                char.Humanoid.Health = 0
            end
        else
            break
        end
    end
end))

--// Clear
char.Humanoid.Died:Once(Empty)
