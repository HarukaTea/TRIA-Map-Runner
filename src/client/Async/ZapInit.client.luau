local ReplicatedStorage = game:GetService("ReplicatedStorage")


local Events = require(ReplicatedStorage.HarukaShared.Library.Events)


for eventId: string, event in Events do
    if event == nil then continue end
    if typeof(event) ~= "table" then continue end
    if event.On == nil then continue end

    Events[eventId].On(function() end)
end
