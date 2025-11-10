
-- Copyright (C) 2025 Tria
-- This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
-- If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.


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