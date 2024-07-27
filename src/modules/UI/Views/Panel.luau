--!nocheck

local CAS = game:GetService("ContextActionService")
local Lighting = game:GetService("Lighting")
local TestS = game:GetService("TestService")
local RepS = game:GetService("ReplicatedStorage")

local Components = require(RepS.Modules.UI.Vanilla)
local Fusion = require(RepS.Modules.Packages.Fusion)
local HarukaLib = require(RepS.Modules.Packages.HarukaLib)

local ButtonOption = require(RepS.Modules.UI.Components.ButtonOption)
local TypeOption = require(RepS.Modules.UI.Components.TypeOption)
local ToggleOption = require(RepS.Modules.UI.Components.ToggleOption)

local MapLib = game.GetMapLib:Invoke()()

local Children, OnChange, Value, Observer, Computed, peek =
    Fusion.Children, Fusion.OnChange, Fusion.Value, Fusion.Observer, Fusion.Computed, Fusion.peek

local fromScale, fromOffset = UDim2.fromScale, UDim2.fromOffset
local udNew = UDim.new
local sFind, match = string.find, string.match
local clear, tFind = table.clear, table.find
local wait = task.wait
local instanceNew = Instance.new
local v3New = Vector3.new

local function Panel(self: table) : Frame
    local scope = self.scope :: table

    self.list = Value(scope, nil)
    self.panelOpen = Value(scope, false)
    self.absSize, self.absContentSize = Value(scope, 0), Value(scope, 0)

    self.inputs = {
        Speed = Value(scope, "20"),
        ForceSpeed = Value(scope, false),

        Jump = Value(scope, "50"),
        ForceJump = Value(scope, false),

        Noclip = Value(scope, "60"),
        Waters = Value(scope, true),
        Lights = Value(scope, false),
        Shadows = Value(scope, true),
        Shaders = Value(scope, true),

        Buttons = Value(scope, "1"),
        SkipBtns = Value(scope, false),
        InfAir = Value(scope, false),
    }
    self.checkPoints = Value(scope, {})

    --// Connections
    local inputs = self.inputs

    local speedObserver = Observer(scope, inputs.Speed)
    local forceSpeedObserver = Observer(scope, inputs.ForceSpeed)

    local jumpObserver = Observer(scope, inputs.Jump)
    local forceJumpObserver = Observer(scope, inputs.ForceJump)

    local noclipObserver = Observer(scope, inputs.Noclip)
    local watersObserver = Observer(scope, inputs.Waters)
    local lightsObserver = Observer(scope, inputs.Lights)
    local shadowsObserver = Observer(scope, inputs.Shadows)
    local shadersObserver = Observer(scope, inputs.Shaders)
    local skipBtnsObserver = Observer(scope, inputs.SkipBtns)
    local infAirObserver = Observer(scope, inputs.InfAir)

    --// Speed
    local function _calSpeed(speed: string) : number
        if speed == "" then return 20 end
        if not tonumber(speed) then return 20 end

        return tonumber(speed)
    end
    speedObserver:onChange(function()
        self.char.Humanoid.WalkSpeed = _calSpeed(peek(inputs.Speed))
    end)

    --// Force speed detector
    local forceSpeedConnection: RBXScriptConnection = nil
    forceSpeedObserver:onChange(function()
        local isForce = peek(inputs.ForceSpeed) :: boolean

        if isForce then
            if forceSpeedConnection then forceSpeedConnection:Disconnect() end

            forceSpeedConnection = self.char.Humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
                local humanoid = self.char.Humanoid :: Humanoid

                if humanoid.WalkSpeed < _calSpeed(peek(inputs.Speed)) then
                    humanoid.WalkSpeed = _calSpeed(peek(inputs.Speed))
                end
            end)
        else
            if forceSpeedConnection then forceSpeedConnection:Disconnect() end
        end
    end)

    --// Jump detector
    local function _calJump(jump: string)
        if jump == "" then return 50 end
        if not tonumber(jump) then return 50 end

        return tonumber(jump)
    end
    jumpObserver:onChange(function()
        self.char.Humanoid.JumpPower = _calJump(peek(inputs.Jump))
    end)

    --// Force jump detector
    local forceJumpConnection: RBXScriptConnection = nil
    forceJumpObserver:onChange(function()
        local isForce = peek(inputs.ForceJump) :: boolean

        if isForce then
            if forceJumpConnection then forceJumpConnection:Disconnect() end

            forceJumpConnection = self.char.Humanoid:GetPropertyChangedSignal("JumpPower"):Connect(function()
                local humanoid = self.char.Humanoid :: Humanoid

                if humanoid.JumpPower < _calJump(peek(inputs.Jump)) then
                    humanoid.JumpPower = _calJump(peek(inputs.Jump))
                end
            end)
        else
            if forceJumpConnection then forceJumpConnection:Disconnect() end
        end
    end)

    --// Noclip detector
    local function _calNoclipSpeed(speed: string)
        if speed == "" then return 60 end
        if not tonumber(speed) then return 60 end

        return tonumber(speed)
    end
    noclipObserver:onChange(function()
        self.plr.Backpack.Noclip:SetAttribute("Speed", _calNoclipSpeed(peek(inputs.Noclip)))
    end)

    --// Water detector
    local waterConnection: RBXScriptConnection = nil
    local waterDetected = {}
    local function _detectWater(water: BasePart)
        if sFind(water.Name, "_Liquid") or sFind(water.Name, "_Gas") then
            waterDetected[water] = water.Parent
            water.Parent = TestS
        end
    end
    watersObserver:onChange(function()
        if peek(inputs.Waters) == false then
            if waterConnection then waterConnection:Disconnect() end

            for _, water in workspace:GetDescendants() do
                _detectWater(water)
            end

            waterConnection = workspace.DescendantAdded:Connect(function(added: Instance)
                wait()
                _detectWater(added)
            end)

        else
            if waterConnection then waterConnection:Disconnect() end

            for water, parent in waterDetected do
                water.Parent = if parent then parent else nil
            end

            clear(waterDetected)
        end
    end)

    --// Self-light detector
    lightsObserver:onChange(function()
        local char = self.char :: Model

        if peek(inputs.Lights) then
            if char.PrimaryPart:FindFirstChild("SelfLight") then char.PrimaryPart.SelfLight:Destroy() end

            local light = instanceNew("PointLight")
            light.Range = 25
            light.Name = "SelfLight"
            light.Parent = char.PrimaryPart

        else
            if char.PrimaryPart:FindFirstChild("SelfLight") then char.PrimaryPart.SelfLight:Destroy() end
        end
    end)

    --// Shadows detector
    local oriStart, oriEnd = Value(scope, Lighting.FogStart), Value(scope, Lighting.FogEnd)
    HarukaLib:Hydrate(Lighting, {
        ["Prop-FogStart"] = function(newStart)
            if newStart ~= 1599 * 40 ^ 2 then oriStart:set(newStart) end
        end,
        ["Prop-FogEnd"] = function(newEnd)
            if newEnd ~= 1599 * 40 ^ 2 then oriEnd:set(newEnd) end
        end
    })
    shadowsObserver:onChange(function()
        local state = peek(inputs.Shadows) :: boolean

        Lighting.GlobalShadows = state

        if not state then
            Lighting.FogEnd = 1599 * 40 ^ 2
            Lighting.FogStart = 1599 * 40 ^ 2
        else
            Lighting.FogEnd = peek(oriEnd)
            Lighting.FogStart = peek(oriStart)
        end
    end)

    --// Shaders detector
    local shaderConnection: RBXScriptConnection = nil
    local shaders = {}
    local shaderConnections = {}
    local function _detectShader(shader: Instance)
        local function __isShader()
            if shader.Enabled then
                if shaderConnections[shader] then
                    shaderConnections[shader]:Disconnect()
                    shaderConnections[shader] = nil
                end

                shader.Enabled = false
                shaders[#shaders + 1] = shader
            else
                shaderConnections[shader] = shader:GetPropertyChangedSignal("Enabled"):Connect(function()
                    if shader.Enabled then
                        __isShader()
                    end
                end)
            end
        end

        if shader:IsA("ColorCorrectionEffect")
            or shader:IsA("BloomEffect")
            or shader:IsA("SunRaysEffect")
            or shader:IsA("BlurEffect")
            or shader:IsA("DepthOfFieldEffect") then

                __isShader()
        end
    end
    shadersObserver:onChange(function()
        if peek(inputs.Shaders) then
            if shaderConnection then shaderConnection:Disconnect() end

            for _, shader in shaders do
                if shader and shader.Parent then shader.Enabled = true end
            end
            for _, shaderConn in shaderConnections do
                if shaderConn then shaderConnection:Disconnect() end
            end
            clear(shaders)
            clear(shaderConnections)
        else
            if shaderConnection then shaderConnection:Disconnect() end

            for _, shader in Lighting:GetDescendants() do
                _detectShader(shader)
            end
            shaderConnection = Lighting.DescendantAdded:Connect(function(added)
                wait()
                _detectShader(added)
            end)
        end
    end)

    --// Button detector
    local btnConnection: RBXScriptConnection = nil
    function self:_detectButton(btn: Model)
        if not btn:IsA("Model") then return end

        local maxBtns = peek(inputs.Buttons) :: string

        if maxBtns == "" then maxBtns = 1 end
        if sFind(btn.Name, "_Button") and btn:IsA("Model") then
            local index = match(btn.Name, "%d+")
            if tonumber(index) > tonumber(maxBtns) then return end

            for _, child in btn:GetDescendants() do
                if child:IsA("BasePart") or child:IsA("UnionOperation") then
                    child.Transparency = 1
                    child.CanCollide = false
                end
            end

            btn.Hitbox.Size = v3New(1, 1, 1) * 15.99
            btn.Hitbox.CFrame = self.char.PrimaryPart.CFrame
        end
    end
    skipBtnsObserver:onChange(function()
        if peek(inputs.SkipBtns) then
            for _, btn in workspace:GetDescendants() do
                self:_detectButton(btn)
            end

            btnConnection = workspace.DescendantAdded:Connect(function(added: Instance)
                wait(1)
                self:_detectButton(added)
            end)

        else
            if btnConnection then btnConnection:Disconnect() end
        end
    end)

    --// Inf air detector
    local infAirConnection: RBXScriptConnection = nil
    local whiteList = { "acid", "lava" }
    local changedWaters = {}
    local function _detectWaterState(water: BasePart)
        if water:GetAttribute("Type") and tFind(whiteList, water:GetAttribute("Type")) then
            changedWaters[water] = water:GetAttribute("Type")

            water:SetAttribute("Type", "water")
        end
    end
    infAirObserver:onChange(function()
        if peek(inputs.InfAir) then
            for _, water in workspace:GetDescendants() do
                _detectWaterState(water)
            end

            infAirConnection = workspace.DescendantAdded:Connect(function(added: Instance)
                wait()
                _detectWaterState(added)
            end)

        else
            if infAirConnection then infAirConnection:Disconnect() end

            for water, attr in changedWaters do
                if water and water.Parent then water:SetAttribute("Type", attr) end
            end
            clear(changedWaters)
        end
    end)

    --// Checkpoints
    local function _addCheckPoint(_, inputState: Enum.UserInputState)
        if inputState ~= Enum.UserInputState.Begin then return end

        local cTable = Fusion.peek(self.checkPoints)

        cTable[#cTable + 1] = self.char.PrimaryPart.CFrame
        self.checkPoints:set(cTable)

        MapLib:Alert("Checkpoint added!", "white", 3)
    end
    CAS:BindAction("HarukaPanelAddCheckpoint", _addCheckPoint, false, Enum.KeyCode.X)

    self.list = Fusion.Value(scope, Components.Frame(scope, {
        Name = "PanelBG",
        Position = fromScale(0.915, -2.8),
        BackgroundTransparency = 0.2,
        Size = fromScale(0.15, 5),

        Visible = Computed(scope, function(use)
            return use(self.panelOpen)
        end),

        [Children] = {
            Fusion.New(scope, "UICorner")({ CornerRadius = udNew(0.02, 0) }),
            Components.ScrollingFrame(scope, {
                Name = "Panel",
                ClipsDescendants = true,
                Size = fromScale(0.9, 0.9),
                ScrollingDirection = Enum.ScrollingDirection.Y,

                ScrollingEnabled = Computed(scope, function(use)
                    return if use(self.absContentSize) > use(self.absSize) then true else false
                end),
                CanvasSize = Computed(scope, function(use)
                    if use(self.absContentSize) > use(self.absSize) then
                        return fromOffset(0, use(self.absContentSize))
                    else
                        return fromOffset(0, 0)
                    end
                end),

                [OnChange("AbsoluteSize")] = function(size)
                    self.absSize:set(size.Y)
                end,

                [Children] = {
                    Fusion.New(scope, "UIListLayout")({
                        Padding = udNew(0, 8),
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        HorizontalAlignment = Enum.HorizontalAlignment.Center,

                        [OnChange("AbsoluteContentSize")] = function(size)
                            self.absContentSize:set(size.Y)
                        end
                    }),

                    TypeOption("Speed", self),
                    ToggleOption("ForceSpeed", self),

                    TypeOption("Jump", self),
                    ToggleOption("ForceJump", self),

                    TypeOption("Noclip", self),

                    ToggleOption("Waters", self),
                    ToggleOption("Lights", self),
                    ToggleOption("Shadows", self),
                    ToggleOption("Shaders", self),

                    TypeOption("Buttons", self),
                    ToggleOption("SkipBtns", self),
                    ButtonOption("ActivateAllBtns", self),

                    ToggleOption("InfAir", self),

                    ButtonOption("AddCheck", self),
                    ButtonOption("ClearCheck", self),

                    Fusion.ForValues(scope, self.checkPoints, function(_, localScope: table, checkPoint: CFrame)
                        return ButtonOption("Checkpoint", self, checkPoint, localScope)
                    end)
                }
            })
        }
    }))

    return self.list
end

return Panel
