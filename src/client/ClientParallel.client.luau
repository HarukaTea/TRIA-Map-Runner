--!nocheck

local RepS = game:GetService("ReplicatedStorage")

require(RepS.Shared.Actors.UIStrokeFix.UIStrokeController)
require(RepS.Shared.Actors.BtnMarkerFX.BtnMarkerFXCreator)


workspace:SetAttribute("ClientParallelInited", true)
