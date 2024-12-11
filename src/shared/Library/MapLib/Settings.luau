--!nocheck

local Settings = {}

--[[
    This function can be used to get the value of a setting.
]]
function Settings:GetSetting(option: string) : nil
    --// TODO: Implement Settings when TRIA 1.0 is released

    --- all I know currently is FoV
    if option == "Field Of View" then
        return 70
    end

    return nil
end

return Settings
