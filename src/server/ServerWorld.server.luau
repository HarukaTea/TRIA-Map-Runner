--!nocheck


local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local StarterPlayer = game:GetService("StarterPlayer")
local SSS = game:GetService("ServerScriptService")


local nowClock = os.clock()


do
    if RunService:IsClient() then
        warn("Invalid runtime environment")

        workspace:SetAttribute("Haruka_ServerLocked", true)


        for _, plr: Player in Players:GetPlayers() do
            plr:Kick("This server is invalid/locked. Rejoin can fix it.")
        end
        return
    end
end

--// Init server settings
do
	Players.CharacterAutoLoads = false
	StarterPlayer.CharacterUseJumpPower = true
    StarterPlayer.EnableMouseLockOption = true
    StarterGui.ScreenOrientation = Enum.ScreenOrientation.LandscapeSensor
    StarterPlayer.CameraMaxZoomDistance = 159

    Lighting.GlobalShadows = true
end


--// Init server modules
do
    require(SSS.HarukaServer.Services.ServerWorldLib):Init()
end



print(`[ServerPreloadLib] HarukaServer Inited, Spent {string.format("%.2f", os.clock() - nowClock)} seconds`)
workspace:SetAttribute("Haruka_ServerInited", true)
