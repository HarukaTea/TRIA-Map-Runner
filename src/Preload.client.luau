
local RF = game:GetService("ReplicatedFirst")
local SG = game:GetService("StarterGui")

RF:RemoveDefaultLoadingScreen()

SG:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
SG:SetCoreGuiEnabled(Enum.CoreGuiType.Health, true)
