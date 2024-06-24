--!nocheck

local Janitor = require(script.Janitor)

local Cleanup = {}
Cleanup.__index = Cleanup

Cleanup._Janitors = {}

Cleanup.Janitor = {} --// my own bin methods to fit in TRIA apis
Cleanup.Janitor.new = function(name: string?)
    local janitor = Janitor.new(name)

    Cleanup._Janitors[name] = Janitor

    return janitor
end

--[[
    This method returns a Janitor class with the given name
]]
function Cleanup:GetJanitor(janitorName: string | number)
    if not janitorName then return end

    return Cleanup._Janitors[janitorName]
end

--[[
    This method returns all the active Janitor classes.
]]
function Cleanup:GetJanitors()
    return Cleanup._Janitors
end

return table.freeze(setmetatable({}, Cleanup))
