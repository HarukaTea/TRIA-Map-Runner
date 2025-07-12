local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")


repeat task.wait() until workspace:GetAttribute("Haruka_ServerInited")
repeat task.wait() until Players:FindFirstChildOfClass("Player")

require(ServerScriptService.HarukaServer.Services.TRIAMapLib):Init()