
local CollectionService = game:GetService("CollectionService")
local CAS = game:GetService("ContextActionService")
local Lighting = game:GetService("Lighting")
local RepS = game:GetService("ReplicatedStorage")

local Fusion = require(RepS.HarukaShared.Shared.Fusion)
local FusionComponents = require(RepS.HarukaShared.UIAtlas.FusionComponents)
local HarukaLib = require(RepS.HarukaShared.Shared.HarukaLib)

local MedalMarker = require(script.Parent.Components.MedalMarker)

local Observer, peek = Fusion.Observer, Fusion.peek

local MapLib = game.GetMapLib:Invoke()()
local map = MapLib.map :: Model

local sFind, match = string.find, string.match
local clear, tFind = table.clear, table.find
local wait = task.wait
local instanceNew = Instance.new
local v3New = Vector3.new




export type Self = {
    plr: Player,
    char: Model,
    scope: Fusion.Scope<any>,

    PanelOpen: Fusion.Value<boolean>,
    Inputs: {
        Speed: Fusion.Value<number>,
        ForceSpeed: Fusion.Value<boolean>,

        Jump: Fusion.Value<number>,
        ForceJump: Fusion.Value<boolean>,

        Noclip: Fusion.Value<number>,
        Waters: Fusion.Value<boolean>,
        Lights: Fusion.Value<boolean>,
        Shadows: Fusion.Value<boolean>,
        Shaders: Fusion.Value<boolean>,
        DisableKillbrick: Fusion.Value<boolean>,
        ShowMedals: Fusion.Value<boolean>,

        Buttons: Fusion.Value<number>,
        SkipBtns: Fusion.Value<boolean>,
        InfAir: Fusion.Value<boolean>,
    },

    CheckPointsContainer: Folder,
    CheckPoints: Fusion.Value<Folder>,
    TuneCheckPoints: Fusion.Value<{ BasePart }>,

    CharRespawned: BindableEvent,
}




return function (self: Self)
    local scope = self.scope :: Fusion.Scope<any>

    local function Value<T>(val: T) : Fusion.Value<T>
		return Fusion.Value(self.scope, val)
	end

    self.PanelOpen = Value(false)

    self.Inputs = {
        Speed = Value(20),
        ForceSpeed = Value(false),

        Jump = Value(50),
        ForceJump = Value(false),

        Noclip = Value(70),
        Waters = Value(true),
        Lights = Value(false),
        Shadows = Value(true),
        Shaders = Value(true),
        DisableKillbrick = Value(true),
        ShowMedals = Value(false),

        Buttons = Value(1),
        SkipBtns = Value(false),
        InfAir = Value(false),
    }

    local checkPointsContainer = instanceNew("Folder")
    checkPointsContainer.Name = "HARUKA_CheckPoints"
    checkPointsContainer.Parent = script:FindFirstAncestorOfClass("ScreenGui")

    self.CheckPointsContainer = checkPointsContainer
    self.CheckPoints = FusionComponents.useChildren(scope, checkPointsContainer)
    self.TuneCheckPoints = Value({})

    self.CharRespawned = Instance.new("BindableEvent")
    table.insert(scope, self.CharRespawned)


    --// Tune detector
    table.insert(scope, HarukaLib.Clock(1.5, function()
        local thatMapLib = game.GetMapLib:Invoke()()
        if thatMapLib == nil then self.TuneCheckPoints:set({}) return end
        local thatMap = thatMapLib.map :: Model
        if thatMap == nil then self.TuneCheckPoints:set({}) return end

        local thatTuneFolder = thatMap:FindFirstChild("Tune", true)
        if thatTuneFolder then
            if thatTuneFolder:FindFirstChild("Checkpoint") then
                local folder = thatTuneFolder.Checkpoint

                self.TuneCheckPoints:set(folder:GetChildren())
                local function _getChildren()
                    wait()
                    self.TuneCheckPoints:set(folder:GetChildren())
                end
                table.insert(scope, folder.ChildAdded:Connect(_getChildren))
                table.insert(scope, folder.ChildRemoved:Connect(_getChildren))
            else
                self.TuneCheckPoints:set({})
            end
        else
            self.TuneCheckPoints:set({})
        end
    end))


    --// Actions

    local function _setPanelOpen(_, inputState: Enum.UserInputState)
        if inputState ~= Enum.UserInputState.Begin then return end

        self.PanelOpen:set(not Fusion.peek(self.PanelOpen))
    end
    CAS:BindAction("HarukaPanelSetOpen", _setPanelOpen, false, Enum.KeyCode.C)

    local function _addCheckPoint(_, inputState: Enum.UserInputState)
        if inputState ~= Enum.UserInputState.Begin then return end

        local checkPoint = Instance.new("CFrameValue")
        checkPoint.Value = self.plr.Character.PrimaryPart.CFrame
        checkPoint.Name = "_Checkpoint"
        checkPoint.Parent = self.CheckPointsContainer

        MapLib:Alert("[Fallen Panel] Checkpoint Added!", "green", 3)
    end
    CAS:BindAction("HarukaPanelAddCheckpoint", _addCheckPoint, false, Enum.KeyCode.X)

    --// Connections

    local inputs = self.Inputs

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
    local disableKillbrickObserver = Observer(scope, inputs.DisableKillbrick)
    local medalsObserver = Observer(scope, inputs.ShowMedals)

    --// Speed
    local function _changeSpeed()
        self.plr.Character.Humanoid.WalkSpeed = peek(inputs.Speed)
    end
    speedObserver:onChange(_changeSpeed)


    --// Force speed detector
    local forceSpeedConnection: RBXScriptConnection = nil
    local function _clearSpeedConns()
        if forceSpeedConnection then
            forceSpeedConnection:Disconnect()
            forceSpeedConnection = nil
        end
    end
    local function _enableForceSpeed()
        _clearSpeedConns()

        forceSpeedConnection = self.plr.Character.Humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
            local humanoid = self.plr.Character.Humanoid :: Humanoid

            if humanoid.WalkSpeed < peek(inputs.Speed) then
                humanoid.WalkSpeed = peek(inputs.Speed)
            end
        end)
    end
    forceSpeedObserver:onChange(function()
        local isForce = peek(inputs.ForceSpeed) :: boolean

        if isForce then
            _enableForceSpeed()
        else
            _clearSpeedConns()
        end
    end)


    --// Jump detector
    local function _changeJump()
        self.plr.Character.Humanoid.JumpPower = peek(inputs.Jump)
    end
    jumpObserver:onChange(_changeJump)


    --// Force jump detector
    local forceJumpConnection: RBXScriptConnection = nil
    local function _clearJumpConns()
        if forceJumpConnection then
            forceJumpConnection:Disconnect()
            forceJumpConnection = nil
        end
    end
    local function _enableForceJump()
        _clearJumpConns()

        forceJumpConnection = self.plr.Character.Humanoid:GetPropertyChangedSignal("JumpPower"):Connect(function()
            local humanoid = self.plr.Character.Humanoid :: Humanoid

            if humanoid.JumpPower < peek(inputs.Jump) then
                humanoid.JumpPower = peek(inputs.Jump)
            end
        end)
    end
    forceJumpObserver:onChange(function()
        local isForce = peek(inputs.ForceJump) :: boolean

        if isForce then
            _enableForceJump()
        else
            _clearJumpConns()
        end
    end)


    --// Noclip detector
    local function _changeNoclip()
        game:GetService("ReplicatedStorage"):SetAttribute("_HARUKA_GlobalNoclipSpeed", peek(inputs.Noclip))
    end
    noclipObserver:onChange(_changeNoclip)


    --// Water detector
    local waterConnection: RBXScriptConnection = nil
    local waterDetected = {}
    local function _detectWater(water: BasePart)
        if sFind(water.Name, "_Liquid") or sFind(water.Name, "_Gas") then
            waterDetected[water] = water.Parent
            water.Parent = game:GetService("ReplicatedStorage")
        end
    end
    local function _clearWaterConns()
        if waterConnection then
            waterConnection:Disconnect()
            waterConnection = nil
        end
    end
    watersObserver:onChange(function()
        if peek(inputs.Waters) == false then
            _clearWaterConns()

            for _, water in workspace:GetDescendants() do
                _detectWater(water)
            end

            waterConnection = workspace.DescendantAdded:Connect(function(added: Instance)
                wait()
                _detectWater(added)
            end)

        else
            _clearWaterConns()

            for water, parent in waterDetected do
                water.Parent = if parent then parent else nil
            end

            clear(waterDetected)
        end
    end)

    --// Self-light detector
    local function _enableLights(char: Model)
        if char.PrimaryPart:FindFirstChild("SelfLight") then char.PrimaryPart.SelfLight:Destroy() end

        local light = instanceNew("PointLight")
        light.Range = 32
        light.Name = "SelfLight"
        light.Parent = char.PrimaryPart
    end
    lightsObserver:onChange(function()
        local char = self.plr.Character :: Model

        if peek(inputs.Lights) then
            _enableLights(char)
        else
            if char.PrimaryPart:FindFirstChild("SelfLight") then char.PrimaryPart.SelfLight:Destroy() end
        end
    end)

    --// Shadows detector
    local shadowsConnection: RBXScriptConnection = nil
    local shadowsConnection2: RBXScriptConnection = nil
    local function _clearShadowsConns()
        if shadowsConnection then
            shadowsConnection:Disconnect()
            shadowsConnection = nil
        end
        if shadowsConnection2 then
            shadowsConnection2:Disconnect()
            shadowsConnection2 = nil
        end
    end
    shadowsObserver:onChange(function()
        local state = peek(inputs.Shadows) :: boolean

        Lighting.GlobalShadows = state

        if not state then
            _clearShadowsConns()

            Lighting.FogEnd = 1599 * 40 ^ 2
            Lighting.FogStart = 1599 * 40 ^ 2

            shadowsConnection = Lighting:GetPropertyChangedSignal("FogStart"):Connect(function()
                wait()
                Lighting.FogStart = 1599 * 40 ^ 2
            end)
            shadowsConnection2 = Lighting:GetPropertyChangedSignal("FogEnd"):Connect(function()
                wait()
                Lighting.FogEnd = 1599 * 40 ^ 2
            end)
        else
            _clearShadowsConns()

            MapLib:Alert("[Fallen Panel] Changes will be applied in next round.", "green", 3)
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
                    if shader.Enabled then  __isShader() end
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
    local function _clearShaderConns()
        if shaderConnection then
            shaderConnection:Disconnect()
            shaderConnection = nil
        end
    end
    shadersObserver:onChange(function()
        if peek(inputs.Shaders) then
            _clearShaderConns()

            for _, shader in shaders do
                if shader and shader.Parent then shader.Enabled = true end
            end
            for _, shaderConn in shaderConnections do
                if shaderConn then shaderConn:Disconnect() end
            end
            clear(shaders)
            clear(shaderConnections)
        else
            _clearShaderConns()

            for _, shader in Lighting:GetDescendants() do
                _detectShader(shader)
            end
            shaderConnection = Lighting.DescendantAdded:Connect(function(added)
                wait()
                _detectShader(added)
            end)
        end
    end)

    --// disable killbrick detector
    local disableKillbrickConnection: RBXScriptConnection = nil
    local killbricksDetected = {}
    local function _detectKillbrick(part: Instance)
        if part:GetAttribute("_action") == "Kill" then
            part:SetAttribute("_action", nil)

            table.insert(killbricksDetected, part)
        end
    end
    local function _clearKillbrickConns()
        if disableKillbrickConnection then
            disableKillbrickConnection:Disconnect()
            disableKillbrickConnection = nil
        end
    end
    disableKillbrickObserver:onChange(function()
        if not peek(inputs.DisableKillbrick) then
            _clearKillbrickConns()

            for _, part: Instance in workspace:GetDescendants() do
                _detectKillbrick(part)
            end

            disableKillbrickConnection = workspace.DescendantAdded:Connect(function(added: Instance)
                wait()
                _detectKillbrick(added)
            end)
        else
            _clearKillbrickConns()

            for _, part: Instance in killbricksDetected do
                if not part then continue end
                if not part.Parent then continue end

                part:SetAttribute("_action", "Kill")
            end

            clear(killbricksDetected)
        end
    end)


    --// medal detector
    local showMedalConnection: RBXScriptConnection = nil
    local function _clearMedalConns()
        if showMedalConnection then
            showMedalConnection:Disconnect()
            showMedalConnection = nil
        end
    end
    local function _detectMedal(medal: Instance)
        if (medal:IsA("BasePart") or medal:IsA("UnionOperation")) and medal.Name == "Medal" then
            local medalMarker = MedalMarker(scope, {
                Adornee = medal
            }, self)

            medalMarker:AddTag("HARUKA_MedalMarker")
        end
    end
    medalsObserver:onChange(function()
        if peek(inputs.ShowMedals) then
            _clearMedalConns()

            for _, medal: Instance in workspace:GetDescendants() do
                _detectMedal(medal)
            end

            showMedalConnection = workspace.DescendantAdded:Connect(function(added: Instance)
                _detectMedal(added)
            end)

        else
            _clearMedalConns()

            for _, marker: BillboardGui in CollectionService:GetTagged("HARUKA_MedalMarker") do
                marker:Destroy()
            end
        end
    end)


    --// Button detector
    local btnConnection: RBXScriptConnection = nil
    local function _clearBtnConns()
        if btnConnection then
            btnConnection:Disconnect()
            btnConnection = nil
        end
    end
    function self:_detectButton(btn: Model)
        if not btn:IsA("Model") then return end

        local maxBtns = peek(inputs.Buttons) :: string

        if maxBtns == "" then maxBtns = 1 end
        if sFind(btn.Name, "_Button") and btn:IsA("Model") then
            local index = match(btn.Name, "%d+")
            if tonumber(index) > tonumber(maxBtns) then return end

            for _, child in btn:GetDescendants() do
                if child:IsA("BasePart") or child:IsA("UnionOperation") or child:IsA("CornerWedgePart") then
                    child.Transparency = 1
                    child.CanCollide = false
                end
            end

            btn.Hitbox.Size = v3New(1, 1, 1) * 15.99
            btn.Hitbox.CFrame = CFrame.identity
            btn.Hitbox.CFrame = self.plr.Character.PrimaryPart.CFrame
        end
    end
    skipBtnsObserver:onChange(function()
        if peek(inputs.SkipBtns) then
            _clearBtnConns()

            for _, btn: Instance in workspace:GetDescendants() do
                self:_detectButton(btn)
            end

            btnConnection = workspace.DescendantAdded:Connect(function(added: Instance)
                wait(1)
                self:_detectButton(added)
            end)
        else
            _clearBtnConns()
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
    local function _clearInfAirConns()
        if infAirConnection then
            infAirConnection:Disconnect()
            infAirConnection = nil
        end
    end
    infAirObserver:onChange(function()
        if peek(inputs.InfAir) then
            _clearInfAirConns()

            for _, water in workspace:GetDescendants() do
                _detectWaterState(water)
            end

            infAirConnection = workspace.DescendantAdded:Connect(function(added: Instance)
                wait()
                _detectWaterState(added)
            end)

        else
            _clearInfAirConns()

            for water, attr in changedWaters do
                if water and water.Parent then water:SetAttribute("Type", attr) end
            end

            clear(changedWaters)
        end
    end)



    ---// a new character just added
    table.insert(scope, self.plr.CharacterAdded:Connect(function(char: Model)
        repeat wait() until char.PrimaryPart
        repeat wait() until char:WaitForChild("Humanoid", 999)

        wait()
        self.CharRespawned:Fire(char)
    end))
    table.insert(scope, self.CharRespawned.Event:Connect(function(char)
        _changeSpeed()
        _changeJump()

        if peek(inputs.ForceJump) then _enableForceJump() end
        if peek(inputs.ForceSpeed) then _enableForceSpeed() end
        if peek(inputs.Lights) then _enableLights(char) end
    end))
end