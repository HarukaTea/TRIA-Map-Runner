--!nocheck

local CollectionService = game:GetService("CollectionService")
local RepS = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local FusionComponents = {}


local wait = task.wait


FusionComponents.useTagged = function(scope: Fusion.Scope, tag: string) : Fusion.Value
    local val = Fusion.Value(scope, CollectionService:GetTagged(tag))

    local function _getChildren()
        wait()
        val:set(CollectionService:GetTagged(tag))
    end
    table.insert(scope, CollectionService:GetInstanceAddedSignal(tag):Connect(_getChildren))
    table.insert(scope, CollectionService:GetInstanceRemovedSignal(tag):Connect(_getChildren))

    return val
end


FusionComponents.useMouse = function(scope: Fusion.Scope) : Fusion.Value
    local val = Fusion.Value(scope, UserInputService:GetMouseLocation())

    table.insert(scope, UserInputService.InputBegan:Connect(function(inputObj)
        local mouseMoved = if inputObj.UserInputType == Enum.UserInputType.MouseMovement then true else false
        local touched = if inputObj.UserInputType == Enum.UserInputType.Touch then true else false

        if mouseMoved or touched then
            val:set(UserInputService:GetMouseLocation())
        end
    end))

    return val
end


FusionComponents.useViewportSize = function(scope: Fusion.Scope) : Fusion.Value
    local val = Fusion.Value(scope, workspace.CurrentCamera.ViewportSize)

    table.insert(scope, workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        val:set(workspace.CurrentCamera.ViewportSize)
    end))

    return val
end


FusionComponents.useFolder = function(scope: Fusion.Scope, folder: Folder) : Fusion.Value
    local val = Fusion.Value(scope, folder:GetChildren())

    local function _getChildren()
        wait()
        val:set(folder:GetChildren())
    end
    table.insert(scope, folder.ChildAdded:Connect(_getChildren))
    table.insert(scope, folder.ChildRemoved:Connect(_getChildren))

    return val
end


FusionComponents.useValue = function(scope: Fusion.Scope, valueInstance: Instance) : Fusion.Value
    local val = Fusion.Value(scope, valueInstance.Value)

    table.insert(scope, valueInstance:GetPropertyChangedSignal("Value"):Connect(function()
        val:set(valueInstance.Value)
    end))

    return val
end


FusionComponents.useXboxControllerHotInput = function(scope: Fusion.Scope) : Fusion.Value<"Keyboard" | "Controller" | "MobileDevice">
    local lastInput = Fusion.Value(scope, "MobileDevice")
    local device = HarukaLib:GetDevice()

    local function _setLastInput(input: Enum.UserInputType)
        if input == Enum.UserInputType.Keyboard then
            lastInput:set("Keyboard")

        elseif input == Enum.UserInputType.Gamepad1 then
            lastInput:set("Controller")

        elseif input == Enum.UserInputType.Gamepad2 then
            lastInput:set("Controller")

        elseif input == Enum.UserInputType.Gamepad3 then
            lastInput:set("Controller")

        elseif input == Enum.UserInputType.Gamepad4 then
            lastInput:set("Controller")
        end
    end
    _setLastInput(UserInputService:GetLastInputType())


    if Fusion.peek(lastInput) == "MobileDevice" then
        if device == "Console" then
            lastInput:set("Controller")
        elseif device == "PC" then
            lastInput:set("Keyboard")
        end
    end

    table.insert(scope, UserInputService.LastInputTypeChanged:Connect(_setLastInput))

    return lastInput
end




return FusionComponents
