--!nocheck

local Players = game:GetService("Players")

local plr = Players.LocalPlayer

local wait = task.wait

local function disableFreecam()
    repeat wait() until plr.PlayerGui:WaitForChild("Freecam", 999)

    wait()
    plr.PlayerGui.Freecam:Destroy()
end
--disableFreecam()
