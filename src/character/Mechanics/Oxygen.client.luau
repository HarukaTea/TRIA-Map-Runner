
local RepS = game:GetService("ReplicatedStorage")

local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local Add, Empty = HarukaLib.Bin()

local char = script:FindFirstAncestorOfClass("Model")


repeat task.wait() until char:GetAttribute("Haruka_CharClientInited")

local isSwimming = false
local currentWater: BasePart = nil
local currentWaters: { BasePart } = {}


local DRAIN_RATE = {
    water = 1 / 6.5,
    acid = 1 / 30,
    lava = 0.01,
}

local splashCD = 0
local defaultOxygen = workspace.Map.Settings.Main:GetAttribute("DefaultOxygen")
local timePerLoss = 1 / 10
local oxygenDepletion = 1

if defaultOxygen == nil then
    --- V1.0 Map kit
    defaultOxygen = workspace.Map.Settings.Fluid:GetAttribute("DefaultOxygen") or 100
end

char:SetAttribute("SelfOxygen", defaultOxygen)
char:SetAttribute("TankOxygen", 0)
char:SetAttribute("MaxOxygen", defaultOxygen)

Add(char.Head.Touched:Connect(function(hit: BasePart)
    if hit:IsA("BasePart") and (string.find(hit.Name, "_Liquid") or string.find(hit.Name, "_Gas")) then
        if isSwimming then
            if hit ~= currentWater then
                local priority = hit:GetAttribute("Priority") or 0
                local currentPriority = currentWater:GetAttribute("Priority") or 0

                local isGas = string.find(hit.Name, "_Gas")
                --// same priority, gas gets ignored
                if isGas then
                    if priority > currentPriority then
                        currentWater = hit
                        table.insert(currentWaters, hit)
                    else
                        table.insert(currentWaters, hit)
                    end
                --// same priority, highest drain amount get chosen
                else
                    local waterType = hit:GetAttribute("Type") or "water" :: string
                    local currentWaterType = currentWater:GetAttribute("Type") or "water" :: string

                    local drainRate = DRAIN_RATE[waterType] or 1
                    local currentDrainRate = DRAIN_RATE[currentWaterType] or 1

                    if waterType == "custom" then
                        drainRate = 1 / (hit:GetAttribute("OxygenDepletion") or 1)
                    end
                    if currentWaterType == "custom" then
                        currentDrainRate = 1 / (currentWater:GetAttribute("OxygenDepletion") or 1)
                    end

                    if priority > currentPriority then
                        currentWater = hit
                        table.insert(currentWaters, hit)

                    elseif priority == currentPriority then
                        if drainRate <= currentDrainRate then
                            currentWater = hit
                            table.insert(currentWaters, hit)
                        else
                            table.insert(currentWaters, hit)
                        end
                    else
                        table.insert(currentWaters, hit)
                    end
                end
            end
        else
            isSwimming = true
            currentWater = hit
            table.insert(currentWaters, hit)
        end
    end
end))
Add(char.Head.TouchEnded:Connect(function(hit: BasePart)
    if hit:IsA("BasePart") and (string.find(hit.Name, "_Liquid") or string.find(hit.Name, "_Gas")) then
        if table.find(currentWaters, hit) then
            table.remove(currentWaters, table.find(currentWaters, hit))
        end
        if #currentWaters <= 0 then
            isSwimming = false
            currentWater = nil
        else
            currentWater = currentWaters[1]
        end
    end
end))
Add(char.Humanoid.Touched:Connect(function(hit: BasePart)
    if hit:IsA("BasePart")
        and hit.Name == "Hitbox"
        and hit.Parent
        and hit.Parent.Name == "AirTank" then

        local oxygenGiven = hit.Parent:GetAttribute("Oxygen") or 300
        oxygenGiven = math.clamp(oxygenGiven, 0, math.huge - 1)

        if oxygenGiven < 0 then
            HarukaLib:AddAttr(char, "SelfOxygen", oxygenGiven)
            HarukaLib:AddAttr(char, "MaxOxygen", oxygenGiven)
        else
            HarukaLib:AddAttr(char, "TankOxygen", oxygenGiven)
        end

        hit.Parent:Destroy()
    end
end))

--- air controls
local function decreaseAir()
    splashCD = 1

    local targetOxygen = if char:GetAttribute("TankOxygen") > 0 then "TankOxygen" else "SelfOxygen"

    HarukaLib:AddAttr(char, targetOxygen, -oxygenDepletion)
end
local function increaseAir()
    splashCD = math.max(0, splashCD - timePerLoss)

    if splashCD <= 0 then
        timePerLoss = 1 / 12.5

        if char:GetAttribute("SelfOxygen") < char:GetAttribute("MaxOxygen") then
            HarukaLib:AddAttr(char, "SelfOxygen", 1)
        end
        if char:GetAttribute("SelfOxygen") > char:GetAttribute("MaxOxygen") then
            char:SetAttribute("SelfOxygen", char:GetAttribute("MaxOxygen"))
        end
    end
end

Add(task.spawn(function()
    while task.wait(timePerLoss) do
        if char.Humanoid.Health > 0 then
            if isSwimming then
                if currentWater then
                    local state = currentWater:GetAttribute("Type") :: string

                    if state == "water" then
                        timePerLoss = DRAIN_RATE.water

                    elseif state == "acid" then
                        timePerLoss = DRAIN_RATE.acid

                    elseif state == "lava" then
                        timePerLoss = DRAIN_RATE.lava
                        char.Humanoid.Health = 0

                    elseif state == "custom" then
                        timePerLoss = 1 / (currentWater:GetAttribute("OxygenDepletion") or 1)
                    end
                end

                decreaseAir()

            elseif not isSwimming then
                if char:GetAttribute("SelfOxygen") >= char:GetAttribute("MaxOxygen") then
                    continue
                else
                    if char:GetAttribute("TankOxygen") > 0 then
                        continue
                    end
                    increaseAir()
                end
            end

            if char:GetAttribute("SelfOxygen") + char:GetAttribute("TankOxygen") <= 0 then
                char.Humanoid.Health = 0
            end
        else
            break
        end
    end
end))

--// Clear
char.Humanoid.Died:Once(Empty)