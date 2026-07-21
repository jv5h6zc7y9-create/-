--[[
    ================================================================================
    👑 SYLENT ENGINE v2.1 — INVISIBLE PHYSICS ENGINE + FULL UI
    🎯 FOCUS: NO VISUAL EFFECTS — PURE PHYSICS MANIPULATION + INTERFACE
    🔒 TARGET: ROBLOX RUNTIME 3.1+ (DELTA EXECUTOR)
    🚀 STATUS: ACTIVE | FULLY OPTIMIZED | COMPLETE MENU
    ================================================================================
]]

if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- ============================================================================
-- [1. ЯДРО: СИСТЕМНЫЕ СЕРВИСЫ, КОНФИГ И ГЛОБАЛЬНОЕ СОСТОЯНИЕ]
-- ============================================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local Debris = game:GetService("Debris")
local TeleportService = game:GetService("TeleportService")
local TextChatService = game:GetService("TextChatService")
local StarterGui = game:GetService("StarterGui")
local Stats = game:GetService("Stats")
local GuiService = game:GetService("GuiService")

local lp = Players.LocalPlayer
if not lp.Character then 
    lp.CharacterAdded:Wait() 
end
local camera = workspace.CurrentCamera

if _G.SylentEngine and _G.SylentEngine.Loaded then
    warn("[SYLENT Engine]: Скрипт уже запущен! Повторная инициализация заблокирована.")
    return
end

-- ============================================================================
-- [1.1. РАСШИРЕННАЯ КОНФИГУРАЦИЯ]
-- ============================================================================
local Config = {
    -- SILENT AIM
    SilentAimEnabled = false,
    SilentAimRange = 200,
    SilentAimPrediction = 0.5,
    SilentAimTargetPart = "HumanoidRootPart",
    
    -- MEGA THROW
    MegaThrowEnabled = false,
    ThrowForce = 2000000,
    ThrowRange = 30,
    
    -- CROWN VORTEX
    CrownVortexEnabled = false,
    VortexRadius = 8,
    VortexHeight = 25,
    VortexSpeed = 0.08,
    VortexGrabDelay = 0.05,
    
    -- ANTI-GRAB
    AntiGrabEnabled = true,
    VelocityThreshold = 50,
    
    -- CAMERA
    ForceThirdPerson = false,
    ThirdPersonZoom = 15,
    
    -- ДВИЖЕНИЕ
    WalkSpeedEnabled = false,
    WalkSpeedValue = 16,
    JumpPowerEnabled = false,
    JumpPowerValue = 50,
    InfiniteJump = false,
    Noclip = false,
    Fly = false,
    FlySpeed = 50,
    AntiFling = false,
    
    -- ТРОЛЛИНГ
    FlingAura = false,
    ClickFling = false,
    FlingAll = false,
    OrbitPlayer = false,
    TargetPlayer = "",
    OrbitSpeed = 5,
    OrbitDistance = 5,
    MassWeld = false,
    LobbyFreeze = false,
    ChatSpam = false,
    ChatSpamMessage = "SYLENT Engine v2.1 Running!",
    
    -- ЯДРО
    BypassMetatable = true,
}

-- ============================================================================
-- [1.2. ГЛОБАЛЬНОЕ СОСТОЯНИЕ]
-- ============================================================================
_G.SylentEngine = {
    Loaded = true,
    Flags = {
        SilentAim = Config.SilentAimEnabled,
        SilentAimRange = Config.SilentAimRange,
        SilentAimPrediction = Config.SilentAimPrediction,
        SilentAimTargetPart = Config.SilentAimTargetPart,
        MegaThrow = Config.MegaThrowEnabled,
        ThrowForce = Config.ThrowForce,
        ThrowRange = Config.ThrowRange,
        CrownVortex = Config.CrownVortexEnabled,
        VortexRadius = Config.VortexRadius,
        VortexHeight = Config.VortexHeight,
        VortexSpeed = Config.VortexSpeed,
        VortexGrabDelay = Config.VortexGrabDelay,
        AntiGrab = Config.AntiGrabEnabled,
        VelocityThreshold = Config.VelocityThreshold,
        ForceThirdPerson = Config.ForceThirdPerson,
        ThirdPersonZoom = Config.ThirdPersonZoom,
        WalkSpeedEnabled = Config.WalkSpeedEnabled,
        WalkSpeedValue = Config.WalkSpeedValue,
        JumpPowerEnabled = Config.JumpPowerEnabled,
        JumpPowerValue = Config.JumpPowerValue,
        InfiniteJump = Config.InfiniteJump,
        Noclip = Config.Noclip,
        Fly = Config.Fly,
        FlySpeed = Config.FlySpeed,
        AntiFling = Config.AntiFling,
        FlingAura = Config.FlingAura,
        ClickFling = Config.ClickFling,
        FlingAll = Config.FlingAll,
        OrbitPlayer = Config.OrbitPlayer,
        TargetPlayer = Config.TargetPlayer,
        OrbitSpeed = Config.OrbitSpeed,
        OrbitDistance = Config.OrbitDistance,
        MassWeld = Config.MassWeld,
        LobbyFreeze = Config.LobbyFreeze,
        ChatSpam = Config.ChatSpam,
        ChatSpamMessage = Config.ChatSpamMessage,
        BypassMetatable = Config.BypassMetatable,
    },
    Cache = {
        Connections = {},
        OriginalLighting = {
            Ambient = Lighting.Ambient,
            OutdoorAmbient = Lighting.OutdoorAmbient,
            Brightness = Lighting.Brightness,
            ClockTime = Lighting.ClockTime,
            FogEnd = Lighting.FogEnd,
            GlobalShadows = Lighting.GlobalShadows
        },
        OriginalMaterials = {},
        OriginalSizes = {},
        OriginalCameraMode = lp.CameraMode,
        OriginalZoomDistance = lp.CameraMaxZoomDistance,
        HuntingList = {},
        FlyUp = false,
        FlyDown = false,
        VortexPlayers = {},
        SavedPosition = nil,
        SilentAimTarget = nil,
        LastTargetPosition = nil,
        LastTargetVelocity = Vector3.new(0, 0, 0),
        VortexAngle = 0,
        VortexGrabbedPlayers = {},
        IsVortexActive = false,
        GrabCooldown = false,
        LastGrabTime = 0,
        PlayerListCache = {},
        CacheUpdateTime = 0,
        AntiGrabCooldown = false,
        ThrowCooldown = false,
        LastThrowTime = 0,
        CameraRestoreData = {
            Mode = lp.CameraMode,
            Zoom = lp.CameraMaxZoomDistance,
        },
        PhysicsOverride = false,
        VelocityLog = {},
        VelocityLogIndex = 1,
        MaxVelocityLog = 10,
        FlyBodyVelocity = nil,
        OrbitAngle = 0,
    }
}

local Engine = _G.SylentEngine

-- ============================================================================
-- [1.3. БЕЗОПАСНЫЕ ФУНКЦИИ ПОДКЛЮЧЕНИЯ И УТИЛИТЫ]
-- ============================================================================
local function SafeConnect(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(Engine.Cache.Connections, connection)
    return connection
end

local function FindPlayerByName(name)
    if not name or name == "" then return nil end
    name = name:lower()
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Name:lower():sub(1, #name) == name or p.DisplayName:lower():sub(1, #name) == name then
            return p
        end
    end
    return nil
end

local function IsValidCharacter(char)
    if not char then return false end
    if not char:FindFirstChild("HumanoidRootPart") then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return false end
    if hum.Health <= 0 then return false end
    return true
end

local function GetCharacterRoot(char)
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end

local function GetHumanoid(char)
    if not char then return nil end
    return char:FindFirstChildOfClass("Humanoid")
end

local function ResetCharacterPhysics(char)
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            pcall(function()
                part.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                part.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            end)
        end
    end
    local hum = GetHumanoid(char)
    if hum then
        pcall(function()
            hum.PlatformStand = false
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end)
    end
end

-- ============================================================================
-- [2. UI: ПОЛНОЦЕННОЕ МЕНЮ С ВКЛАДКАМИ]
-- ============================================================================

local SylentUI = {}
SylentUI.__index = SylentUI

local UI_THEME = {
    Bg          = Color3.fromRGB(10, 11, 16),
    BgStrong    = Color3.fromRGB(18, 20, 28),
    Border      = Color3.fromRGB(0, 255, 240),
    Accent      = Color3.fromRGB(0, 255, 240),
    Text        = Color3.fromRGB(255, 255, 255),
    TextDim     = Color3.fromRGB(130, 135, 150),
    ToggleOff   = Color3.fromRGB(40, 43, 56)
}

local UI_EASE = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function tweenUI(obj, info, props)
    local t = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

function SylentUI.new(config)
    local self = setmetatable({}, SylentUI)
    self.Title = config.Title or "SYLENT ENGINE"
    self.Version = config.Version or "v2.1"
    self.ActiveTab = nil
    self.Tabs = {}
    self:BuildCoreFrame()
    return self
end

function SylentUI:BuildCoreFrame()
    local screen = Instance.new("ScreenGui")
    screen.Name = "Sylent_UI_" .. HttpService:GenerateGUID(false):sub(1,6)
    screen.ResetOnSpawn = false
    screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() screen.Parent = CoreGui end)
    if not screen.Parent then screen.Parent = lp:WaitForChild("PlayerGui") end
    self.Screen = screen
    Engine.Cache.SylentUI = self

    local launcher = Instance.new("TextButton")
    launcher.Size = UDim2.new(0, 55, 0, 55)
    launcher.Position = UDim2.new(0.02, 0, 0.2, 0)
    launcher.BackgroundColor3 = UI_THEME.BgStrong
    launcher.Text = "⚡"
    launcher.TextColor3 = UI_THEME.Border
    launcher.Font = Enum.Font.FredokaOne
    launcher.TextSize = 25
    launcher.Parent = screen

    local lCor = Instance.new("UICorner")
    lCor.CornerRadius = UDim.new(1, 0)
    lCor.Parent = launcher

    local lStroke = Instance.new("UIStroke")
    lStroke.Color = UI_THEME.Border
    lStroke.Thickness = 2
    lStroke.Parent = launcher

    self.Launcher = launcher

    local dragStart, startPos, dragging = nil, nil, false
    launcher.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = launcher.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    launcher.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            launcher.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 640, 0, 420)
    frame.Position = UDim2.new(0.5, -320, 0.5, -210)
    frame.BackgroundColor3 = UI_THEME.Bg
    frame.ClipsDescendants = true
    frame.Visible = false
    frame.Parent = screen
    self.Frame = frame

    local fCor = Instance.new("UICorner")
    fCor.CornerRadius = UDim.new(0, 12)
    fCor.Parent = frame

    local fStroke = Instance.new("UIStroke")
    fStroke.Color = UI_THEME.Border
    fStroke.Thickness = 2
    fStroke.Parent = frame

    local sidebar = Instance.new("Frame")
    sidebar.Size = UDim2.new(0, 180, 1, 0)
    sidebar.BackgroundColor3 = UI_THEME.BgStrong
    sidebar.Parent = frame

    local sCor = Instance.new("UICorner")
    sCor.CornerRadius = UDim.new(0, 12)
    sCor.Parent = sidebar

    local sStroke = Instance.new("UIStroke")
    sStroke.Color = UI_THEME.Border
    sStroke.Thickness = 1
    sStroke.Parent = sidebar

    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 75)
    header.BackgroundTransparency = 1
    header.Parent = sidebar

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0, 32)
    title.Position = UDim2.new(0, 15, 0, 15)
    title.Text = self.Title
    title.TextColor3 = UI_THEME.Text
    title.Font = Enum.Font.FredokaOne
    title.TextSize = 22
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.BackgroundTransparency = 1
    title.Parent = header

    local version = Instance.new("TextLabel")
    version.Size = UDim2.new(1, -20, 0, 18)
    version.Position = UDim2.new(0, 15, 0, 42)
    version.Text = self.Version
    version.TextColor3 = UI_THEME.Border
    version.Font = Enum.Font.SourceSansBold
    version.TextSize = 13
    version.TextXAlignment = Enum.TextXAlignment.Left
    version.BackgroundTransparency = 1
    version.Parent = header

    local tabScroll = Instance.new("ScrollingFrame")
    tabScroll.Size = UDim2.new(1, 0, 1, -85)
    tabScroll.Position = UDim2.new(0, 0, 0, 80)
    tabScroll.BackgroundTransparency = 1
    tabScroll.ScrollBarThickness = 0
    tabScroll.Parent = sidebar

    local tsLayout = Instance.new("UIListLayout")
    tsLayout.Padding = UDim.new(0, 5)
    tsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tsLayout.Parent = tabScroll

    self.TabList = tabScroll

    local pageContainer = Instance.new("Frame")
    pageContainer.Size = UDim2.new(1, -200, 1, -20)
    pageContainer.Position = UDim2.new(0, 190, 0, 10)
    pageContainer.BackgroundTransparency = 1
    pageContainer.Parent = frame
    self.PageContainer = pageContainer

    local menuState = false
    launcher.MouseButton1Click:Connect(function()
        menuState = not menuState
        if menuState then
            frame.Size = UDim2.new(0, 0, 0, 0)
            frame.Position = launcher.Position
            frame.Visible = true
            tweenUI(frame, UI_EASE, {
                Size = UDim2.new(0, 640, 0, 420),
                Position = UDim2.new(0.5, -320, 0.5, -210)
            })
            tweenUI(launcher, UI_EASE, {Rotation = 90, TextColor3 = UI_THEME.Border})
            lStroke.Color = UI_THEME.Border
        else
            tweenUI(frame, UI_EASE, {
                Size = UDim2.new(0, 0, 0, 0),
                Position = launcher.Position
            })
            tweenUI(launcher, UI_EASE, {Rotation = 0, TextColor3 = UI_THEME.Border})
            lStroke.Color = UI_THEME.Border
            task.wait(0.25)
            if not menuState then frame.Visible = false end
        end
    end)
end

function SylentUI:CreateTab(name)
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = UI_THEME.Border
    page.Visible = false
    page.Parent = self.PageContainer

    local pLayout = Instance.new("UIListLayout")
    pLayout.Padding = UDim.new(0, 8)
    pLayout.Parent = page

    pLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0, 0, 0, pLayout.AbsoluteContentSize.Y + 15)
    end)

    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(0.92, 0, 0, 36)
    tabBtn.BackgroundColor3 = UI_THEME.Bg
    tabBtn.BackgroundTransparency = 1
    tabBtn.Text = ""
    tabBtn.AutoButtonColor = false
    tabBtn.Parent = self.TabList

    local tbCor = Instance.new("UICorner")
    tbCor.CornerRadius = UDim.new(0, 6)
    tbCor.Parent = tabBtn

    local tbLabel = Instance.new("TextLabel")
    tbLabel.Size = UDim2.new(1, -15, 1, 0)
    tbLabel.Position = UDim2.new(0, 15, 0, 0)
    tbLabel.Text = name
    tbLabel.TextColor3 = UI_THEME.TextDim
    tbLabel.Font = Enum.Font.SourceSansBold
    tbLabel.TextSize = 15
    tbLabel.TextXAlignment = Enum.TextXAlignment.Left
    tbLabel.BackgroundTransparency = 1
    tbLabel.Parent = tabBtn

    local tabData = {Page = page, Button = tabBtn, Label = tbLabel}

    tabBtn.MouseButton1Click:Connect(function()
        self:SelectTab(tabData)
    end)

    if not self.ActiveTab then
        self:SelectTab(tabData)
    end

    local ElementAPI = {}
    ElementAPI.Page = page

    function ElementAPI:AddSection(titleText)
        local secText = Instance.new("TextLabel")
        secText.Size = UDim2.new(0.96, 0, 0, 24)
        secText.Text = "• " .. titleText:upper() .. " •"
        secText.TextColor3 = UI_THEME.Border
        secText.Font = Enum.Font.SourceSansBold
        secText.TextSize = 12
        secText.TextXAlignment = Enum.TextXAlignment.Left
        secText.BackgroundTransparency = 1
        secText.Parent = page
    end

    function ElementAPI:AddToggle(cfg)
        local card = Instance.new("Frame")
        card.Size = UDim2.new(0.96, 0, 0, 50)
        card.BackgroundColor3 = UI_THEME.BgStrong
        card.Parent = page

        local cCor = Instance.new("UICorner")
        cCor.CornerRadius = UDim.new(0, 8)
        cCor.Parent = card

        local cStroke = Instance.new("UIStroke")
        cStroke.Color = Color3.fromRGB(35, 38, 52)
        cStroke.Thickness = 1
        cStroke.Parent = card

        local titleL = Instance.new("TextLabel")
        titleL.Size = UDim2.new(0.7, 0, 0, 24)
        titleL.Position = UDim2.new(0, 12, 0, 4)
        titleL.Text = cfg.Name
        titleL.TextColor3 = UI_THEME.Text
        titleL.Font = Enum.Font.SourceSansBold
        titleL.TextSize = 15
        titleL.TextXAlignment = Enum.TextXAlignment.Left
        titleL.BackgroundTransparency = 1
        titleL.Parent = card

        local descL = Instance.new("TextLabel")
        descL.Size = UDim2.new(0.7, 0, 0, 18)
        descL.Position = UDim2.new(0, 12, 0, 24)
        descL.Text = cfg.Description or ""
        descL.TextColor3 = UI_THEME.TextDim
        descL.Font = Enum.Font.SourceSans
        descL.TextSize = 12
        descL.TextXAlignment = Enum.TextXAlignment.Left
        descL.BackgroundTransparency = 1
        descL.Parent = card

        local swBtn = Instance.new("TextButton")
        swBtn.Size = UDim2.new(0, 44, 0, 22)
        swBtn.Position = UDim2.new(0.96, -44, 0.5, -11)
        swBtn.BackgroundColor3 = UI_THEME.ToggleOff
        swBtn.Text = ""
        swBtn.Parent = card

        local sCor = Instance.new("UICorner")
        sCor.CornerRadius = UDim.new(1, 0)
        sCor.Parent = swBtn

        local node = Instance.new("Frame")
        node.Size = UDim2.new(0, 16, 0, 16)
        node.Position = UDim2.new(0, 3, 0.5, -8)
        node.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        node.Parent = swBtn

        local nCor = Instance.new("UICorner")
        nCor.CornerRadius = UDim.new(1, 0)
        nCor.Parent = node

        local activeState = cfg.Default or false
        local function updateToggle(st)
            activeState = st
            if activeState then
                tweenUI(swBtn, TweenInfo.new(0.2), {BackgroundColor3 = UI_THEME.Border})
                tweenUI(node, TweenInfo.new(0.2), {Position = UDim2.new(1, -19, 0.5, -8)})
            else
                tweenUI(swBtn, TweenInfo.new(0.2), {BackgroundColor3 = UI_THEME.ToggleOff})
                tweenUI(node, TweenInfo.new(0.2), {Position = UDim2.new(0, 3, 0.5, -8)})
            end
            pcall(cfg.Callback, activeState)
        end

        updateToggle(activeState)
        swBtn.MouseButton1Click:Connect(function()
            updateToggle(not activeState)
        end)
    end

    function ElementAPI:AddSlider(cfg)
        local card = Instance.new("Frame")
        card.Size = UDim2.new(0.96, 0, 0, 58)
        card.BackgroundColor3 = UI_THEME.BgStrong
        card.Parent = page

        local cCor = Instance.new("UICorner")
        cCor.CornerRadius = UDim.new(0, 8)
        cCor.Parent = card

        local cStroke = Instance.new("UIStroke")
        cStroke.Color = Color3.fromRGB(35, 38, 52)
        cStroke.Thickness = 1
        cStroke.Parent = card

        local titleL = Instance.new("TextLabel")
        titleL.Size = UDim2.new(0.7, 0, 0, 22)
        titleL.Position = UDim2.new(0, 12, 0, 6)
        titleL.Text = cfg.Name
        titleL.TextColor3 = UI_THEME.Text
        titleL.Font = Enum.Font.SourceSansBold
        titleL.TextSize = 15
        titleL.TextXAlignment = Enum.TextXAlignment.Left
        titleL.BackgroundTransparency = 1
        titleL.Parent = card

        local valL = Instance.new("TextLabel")
        valL.Size = UDim2.new(0.25, 0, 0, 22)
        valL.Position = UDim2.new(0.7, 0, 0, 6)
        valL.Text = tostring(cfg.Default)
        valL.TextColor3 = UI_THEME.Border
        valL.Font = Enum.Font.FredokaOne
        valL.TextSize = 14
        valL.TextXAlignment = Enum.TextXAlignment.Right
        valL.BackgroundTransparency = 1
        valL.Parent = card

        local track = Instance.new("TextButton")
        track.Size = UDim2.new(0.92, 0, 0, 6)
        track.Position = UDim2.new(0.04, 0, 0.72, 0)
        track.BackgroundColor3 = UI_THEME.ToggleOff
        track.Text = ""
        track.Parent = card

        local tCor = Instance.new("UICorner")
        tCor.CornerRadius = UDim.new(1, 0)
        tCor.Parent = track

        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((cfg.Default - cfg.Min)/(cfg.Max - cfg.Min), 0, 1, 0)
        fill.BackgroundColor3 = UI_THEME.Border
        fill.Parent = track

        local fCor = Instance.new("UICorner")
        fCor.CornerRadius = UDim.new(1, 0)
        fCor.Parent = fill

        local isSliding = false
        local function processSlide(input)
            local pct = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            local currentVal = math.floor(cfg.Min + (cfg.Max - cfg.Min) * pct)
            fill.Size = UDim2.new(pct, 0, 1, 0)
            valL.Text = tostring(currentVal)
            pcall(cfg.Callback, currentVal)
        end

        track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isSliding = true
                processSlide(input)
            end
        end)
        SafeConnect(UserInputService.InputChanged, function(input)
            if isSliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                processSlide(input)
            end
        end)
        track.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isSliding = false
            end
        end)
    end

    function ElementAPI:AddTextBox(cfg)
        local card = Instance.new("Frame")
        card.Size = UDim2.new(0.96, 0, 0, 50)
        card.BackgroundColor3 = UI_THEME.BgStrong
        card.Parent = page

        local cCor = Instance.new("UICorner")
        cCor.CornerRadius = UDim.new(0, 8)
        cCor.Parent = card

        local cStroke = Instance.new("UIStroke")
        cStroke.Color = Color3.fromRGB(35, 38, 52)
        cStroke.Thickness = 1
        cStroke.Parent = card

        local titleL = Instance.new("TextLabel")
        titleL.Size = UDim2.new(0.4, 0, 1, 0)
        titleL.Position = UDim2.new(0, 12, 0, 0)
        titleL.Text = cfg.Name
        titleL.TextColor3 = UI_THEME.Text
        titleL.Font = Enum.Font.SourceSansBold
        titleL.TextSize = 15
        titleL.TextXAlignment = Enum.TextXAlignment.Left
        titleL.BackgroundTransparency = 1
        titleL.Parent = card

        local tBox = Instance.new("TextBox")
        tBox.Size = UDim2.new(0.54, 0, 0.68, 0)
        tBox.Position = UDim2.new(0.42, 0, 0.16, 0)
        tBox.BackgroundColor3 = UI_THEME.Bg
        tBox.Text = cfg.Default or ""
        tBox.TextColor3 = UI_THEME.Text
        tBox.PlaceholderText = cfg.Placeholder or "Ввод данных..."
        tBox.PlaceholderColor3 = UI_THEME.TextDim
        tBox.Font = Enum.Font.SourceSansSemibold
        tBox.TextSize = 14
        tBox.ClipsDescendants = true
        tBox.Parent = card

        local tbCor = Instance.new("UICorner")
        tbCor.CornerRadius = UDim.new(0, 6)
        tbCor.Parent = tBox

        local tbStroke = Instance.new("UIStroke")
        tbStroke.Color = Color3.fromRGB(55, 58, 76)
        tbStroke.Thickness = 1
        tbStroke.Parent = tBox

        tBox.FocusLost:Connect(function()
            pcall(cfg.Callback, tBox.Text)
        end)
    end

    function ElementAPI:AddButton(cfg)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.96, 0, 0, 40)
        btn.BackgroundColor3 = UI_THEME.Border
        btn.Text = cfg.Name
        btn.TextColor3 = UI_THEME.Bg
        btn.Font = Enum.Font.SourceSansBold
        btn.TextSize = 15
        btn.AutoButtonColor = true
        btn.Parent = page

        local bCor = Instance.new("UICorner")
        bCor.CornerRadius = UDim.new(0, 8)
        bCor.Parent = btn

        btn.MouseButton1Click:Connect(function()
            pcall(cfg.Callback)
        end)
    end

    return ElementAPI
end

function SylentUI:SelectTab(tabData)
    if self.ActiveTab then
        self.ActiveTab.Page.Visible = false
        tweenUI(self.ActiveTab.Button, UI_EASE, {BackgroundTransparency = 1})
        tweenUI(self.ActiveTab.Label, UI_EASE, {TextColor3 = UI_THEME.TextDim})
    end
    self.ActiveTab = tabData
    tabData.Page.Visible = true
    tweenUI(tabData.Button, UI_EASE, {BackgroundTransparency = 0.88})
    tweenUI(tabData.Label, UI_EASE, {TextColor3 = UI_THEME.Border})
end

local Menu = SylentUI.new({ Title = "SYLENT ENGINE", Version = "v2.1 • FULL UI" })
Engine.Cache.Menu = Menu

-- ============================================================================
-- [2.1. НАПОЛНЕНИЕ ВКЛАДОК]
-- ============================================================================

-- Вкладка: ДВИЖЕНИЕ
local movementTab = Menu:CreateTab("Движение")
movementTab:AddSection("Физические Характеристики")

movementTab:AddToggle({
    Name = "Кастомный WalkSpeed",
    Description = "Блокирует скорость бега на нужном уровне",
    Default = Engine.Flags.WalkSpeedEnabled,
    Callback = function(st)
        Engine.Flags.WalkSpeedEnabled = st
    end
})

movementTab:AddSlider({
    Name = "Скорость перемещения",
    Min = 16,
    Max = 300,
    Default = Engine.Flags.WalkSpeedValue,
    Callback = function(val)
        Engine.Flags.WalkSpeedValue = val
    end
})

movementTab:AddToggle({
    Name = "Кастомный JumpPower",
    Description = "Регулирует высоту ваших прыжков",
    Default = Engine.Flags.JumpPowerEnabled,
    Callback = function(st)
        Engine.Flags.JumpPowerEnabled = st
    end
})

movementTab:AddSlider({
    Name = "Сила прыжка",
    Min = 50,
    Max = 500,
    Default = Engine.Flags.JumpPowerValue,
    Callback = function(val)
        Engine.Flags.JumpPowerValue = val
    end
})

movementTab:AddSection("Супер-Способности")

movementTab:AddToggle({
    Name = "Бесконечный Прыжок",
    Description = "Прыгайте по невидимым уступам в воздухе",
    Default = Engine.Flags.InfiniteJump,
    Callback = function(st)
        Engine.Flags.InfiniteJump = st
    end
})

movementTab:AddToggle({
    Name = "Режим полета (Fly)",
    Description = "Перемещение в стиле наблюдателя",
    Default = Engine.Flags.Fly,
    Callback = function(st)
        Engine.Flags.Fly = st
    end
})

movementTab:AddSlider({
    Name = "Скорость полета",
    Min = 10,
    Max = 350,
    Default = Engine.Flags.FlySpeed,
    Callback = function(val)
        Engine.Flags.FlySpeed = val
    end
})

movementTab:AddToggle({
    Name = "Noclip (Проход сквозь стены)",
    Description = "Отключает коллизию всех частей вашего тела",
    Default = Engine.Flags.Noclip,
    Callback = function(st)
        Engine.Flags.Noclip = st
    end
})

movementTab:AddToggle({
    Name = "Anti-Fling (Защита от отбрасывания)",
    Description = "Защищает от внешних сил и вращений",
    Default = Engine.Flags.AntiFling,
    Callback = function(st)
        Engine.Flags.AntiFling = st
    end
})

-- Вкладка: FTAP БОЙ
local combatTab = Menu:CreateTab("FTAP Бой")
combatTab:AddSection("Системы наведения")

combatTab:AddToggle({
    Name = "Silent Aim (Невидимый)",
    Description = "Подставляет координаты цели в RemoteEvent без поворота камеры",
    Default = Engine.Flags.SilentAim,
    Callback = function(st)
        Engine.Flags.SilentAim = st
    end
})

combatTab:AddSlider({
    Name = "Радиус захвата (студы)",
    Min = 50,
    Max = 1000,
    Default = Engine.Flags.SilentAimRange,
    Callback = function(val)
        Engine.Flags.SilentAimRange = val
    end
})

combatTab:AddSlider({
    Name = "Упреждение (Prediction)",
    Min = 1,
    Max = 10,
    Default = 5,
    Callback = function(val)
        Engine.Flags.SilentAimPrediction = val / 10
    end
})

combatTab:AddSection("Выбор части скелета")

local partNames = {"Head", "Torso", "HumanoidRootPart"}
local partFrame = Instance.new("Frame")
partFrame.Size = UDim2.new(0.96, 0, 0, 40)
partFrame.BackgroundTransparency = 1
partFrame.Parent = combatTab.Page

local partLayout = Instance.new("UIListLayout")
partLayout.FillDirection = Enum.FillDirection.Horizontal
partLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
partLayout.Padding = UDim.new(0, 6)
partLayout.Parent = partFrame

local partBtns = {}
for _, partName in ipairs(partNames) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 85, 0, 30)
    btn.Text = partName
    btn.BackgroundColor3 = UI_THEME.BgStrong
    btn.TextColor3 = UI_THEME.TextDim
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 12
    btn.AutoButtonColor = false
    btn.Parent = partFrame
    local bCor = Instance.new("UICorner")
    bCor.CornerRadius = UDim.new(0, 6)
    bCor.Parent = btn
    if partName == Engine.Flags.SilentAimTargetPart then
        btn.BackgroundColor3 = UI_THEME.Border
        btn.TextColor3 = UI_THEME.Bg
    end
    btn.MouseButton1Click:Connect(function()
        Engine.Flags.SilentAimTargetPart = partName
        for _, b in ipairs(partBtns) do
            b.BackgroundColor3 = UI_THEME.BgStrong
            b.TextColor3 = UI_THEME.TextDim
        end
        btn.BackgroundColor3 = UI_THEME.Border
        btn.TextColor3 = UI_THEME.Bg
    end)
    table.insert(partBtns, btn)
end

combatTab:AddSection("Механика броска")

combatTab:AddToggle({
    Name = "Mega Throw (Мега-бросок)",
    Description = "Выбрасывает цель с огромной силой (ПКМ)",
    Default = Engine.Flags.MegaThrow,
    Callback = function(st)
        Engine.Flags.MegaThrow = st
    end
})

combatTab:AddSlider({
    Name = "Сила броска",
    Min = 100000,
    Max = 2000000,
    Default = Engine.Flags.ThrowForce,
    Callback = function(val)
        Engine.Flags.ThrowForce = val
    end
})

combatTab:AddSlider({
    Name = "Радиус броска",
    Min = 5,
    Max = 60,
    Default = Engine.Flags.ThrowRange,
    Callback = function(val)
        Engine.Flags.ThrowRange = val
    end
})

combatTab:AddSection("Защита")

combatTab:AddToggle({
    Name = "Anti-Grab (Защита от захвата)",
    Description = "Уничтожает чужие физические связи на вашем скелете",
    Default = Engine.Flags.AntiGrab,
    Callback = function(st)
        Engine.Flags.AntiGrab = st
    end
})

combatTab:AddSlider({
    Name = "Порог возврата скорости",
    Min = 10,
    Max = 200,
    Default = Engine.Flags.VelocityThreshold,
    Callback = function(val)
        Engine.Flags.VelocityThreshold = val
    end
})

-- Вкладка: ТРОЛЛИНГ
local trollTab = Menu:CreateTab("Троллинг")
trollTab:AddSection("Черная Дыра (Crown Vortex)")

trollTab:AddToggle({
    Name = "Crown Vortex (Корона)",
    Description = "Захватывает всех игроков в корону над вами",
    Default = Engine.Flags.CrownVortex,
    Callback = function(st)
        Engine.Flags.CrownVortex = st
        if not st then
            for _, player in ipairs(Engine.Cache.VortexPlayers) do
                if player and player.Character then
                    local root = GetCharacterRoot(player.Character)
                    if root then
                        pcall(function()
                            root.AssemblyLinearVelocity = camera.CFrame.LookVector * 2000000
                        end)
                    end
                end
            end
            Engine.Cache.VortexPlayers = {}
        end
    end
})

trollTab:AddSlider({
    Name = "Радиус короны",
    Min = 3,
    Max = 20,
    Default = Engine.Flags.VortexRadius,
    Callback = function(val)
        Engine.Flags.VortexRadius = val
    end
})

trollTab:AddSlider({
    Name = "Высота короны",
    Min = 10,
    Max = 60,
    Default = Engine.Flags.VortexHeight,
    Callback = function(val)
        Engine.Flags.VortexHeight = val
    end
})

trollTab:AddSlider({
    Name = "Скорость вращения",
    Min = 1,
    Max = 30,
    Default = 8,
    Callback = function(val)
        Engine.Flags.VortexSpeed = val / 100
    end
})

trollTab:AddSection("Ауры и массовые эффекты")

trollTab:AddToggle({
    Name = "Fling Aura (Аура разрушения)",
    Description = "Флингует всех в радиусе 18 студусов",
    Default = Engine.Flags.FlingAura,
    Callback = function(st)
        Engine.Flags.FlingAura = st
    end
})

trollTab:AddToggle({
    Name = "Click Fling (Ctrl + ЛКМ)",
    Description = "Флинг по клику с зажатым Ctrl",
    Default = Engine.Flags.ClickFling,
    Callback = function(st)
        Engine.Flags.ClickFling = st
    end
})

trollTab:AddButton({
    Name = "Fling All (Флинг всех)",
    Callback = function()
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= lp then
                task.spawn(function() ExecuteFling(player) end)
            end
        end
    end
})

trollTab:AddSection("Орбита и хаос")

trollTab:AddTextBox({
    Name = "Имя жертвы (Orbit)",
    Placeholder = "Введите ник...",
    Default = Engine.Flags.TargetPlayer,
    Callback = function(text)
        Engine.Flags.TargetPlayer = text
    end
})

trollTab:AddToggle({
    Name = "Orbit Player (Орбита)",
    Description = "Кружение вокруг указанной цели",
    Default = Engine.Flags.OrbitPlayer,
    Callback = function(st)
        Engine.Flags.OrbitPlayer = st
    end
})

trollTab:AddSlider({
    Name = "Дистанция орбиты",
    Min = 3,
    Max = 50,
    Default = Engine.Flags.OrbitDistance,
    Callback = function(val)
        Engine.Flags.OrbitDistance = val
    end
})

trollTab:AddSlider({
    Name = "Скорость орбиты",
    Min = 1,
    Max = 40,
    Default = Engine.Flags.OrbitSpeed,
    Callback = function(val)
        Engine.Flags.OrbitSpeed = val
    end
})

trollTab:AddButton({
    Name = "Mass Weld (Сварка физики)",
    Callback = function()
        RunMassWeld()
    end
})

trollTab:AddToggle({
    Name = "Lobby Freeze (Заморозка)",
    Description = "Лагает физику сервера спамом позиций",
    Default = Engine.Flags.LobbyFreeze,
    Callback = function(st)
        Engine.Flags.LobbyFreeze = st
    end
})

-- Вкладка: КАМЕРА
local cameraTab = Menu:CreateTab("Камера")
cameraTab:AddSection("Управление камерой")

cameraTab:AddToggle({
    Name = "Принудительное 3-е лицо",
    Description = "Фиксирует камеру в режиме 3-го лица",
    Default = Engine.Flags.ForceThirdPerson,
    Callback = function(st)
        Engine.Flags.ForceThirdPerson = st
        if not st then
            pcall(function()
                if Engine.Cache.OriginalCameraMode then
                    lp.CameraMode = Engine.Cache.OriginalCameraMode
                    lp.CameraMaxZoomDistance = Engine.Cache.OriginalZoomDistance
                end
            end)
        end
    end
})

cameraTab:AddSlider({
    Name = "Дистанция зума (3-е лицо)",
    Min = 5,
    Max = 50,
    Default = Engine.Flags.ThirdPersonZoom,
    Callback = function(val)
        Engine.Flags.ThirdPersonZoom = val
    end
})

cameraTab:AddSection("Система")

cameraTab:AddToggle({
    Name = "Bypass Metatable",
    Description = "Маскирует WalkSpeed/JumpPower от сервера",
    Default = Engine.Flags.BypassMetatable,
    Callback = function(st)
        Engine.Flags.BypassMetatable = st
    end
})

cameraTab:AddButton({
    Name = "Выгрузить скрипт",
    Callback = function()
        CompleteDestruction()
    end
})

-- ============================================================================
-- [3. ВСЕ ОСТАЛЬНЫЕ ФУНКЦИИ (ПОЛНОСТЬЮ ИЗ ПРЕДЫДУЩЕЙ ВЕРСИИ, БЕЗ СОКРАЩЕНИЙ)]
-- ============================================================================

-- [3.1. МОДУЛЬ: SILENT AIM]
local skeletonBones = {
    "Head", "Torso", "HumanoidRootPart", "UpperTorso", "LowerTorso",
    "LeftArm", "RightArm", "LeftLeg", "RightLeg",
    "LeftHand", "RightHand", "LeftFoot", "RightFoot",
    "LeftLowerArm", "RightLowerArm", "LeftUpperArm", "RightUpperArm",
    "LeftLowerLeg", "RightLowerLeg", "LeftUpperLeg", "RightUpperLeg"
}

local function GetSkeletonPart(player, partName)
    if not player or not player.Character then return nil end
    local targetPart = player.Character:FindFirstChild(partName)
    if targetPart and targetPart:IsA("BasePart") then
        return targetPart
    end
    for _, boneName in ipairs(skeletonBones) do
        local part = player.Character:FindFirstChild(boneName)
        if part and part:IsA("BasePart") then
            return part
        end
    end
    return nil
end

local function GetClosestSkeletonInRange()
    local closestPlayer = nil
    local closestPart = nil
    local shortestDistance = Engine.Flags.SilentAimRange or 200
    local targetPartName = Engine.Flags.SilentAimTargetPart or "HumanoidRootPart"
    local predictionStrength = Engine.Flags.SilentAimPrediction or 0.5
    
    local myRoot = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil, nil end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == lp then continue end
        if not IsValidCharacter(player.Character) then continue end
        
        if #Engine.Cache.HuntingList > 0 then
            local found = false
            for _, name in ipairs(Engine.Cache.HuntingList) do
                if player.Name:lower():find(name:lower()) then
                    found = true
                    break
                end
            end
            if not found then continue end
        end
        
        local targetPart = GetSkeletonPart(player, targetPartName)
        if targetPart then
            local velocity = targetPart.AssemblyLinearVelocity
            local predictionTime = predictionStrength / 5
            local predictedPosition = targetPart.Position + (velocity * predictionTime)
            
            local distance = (myRoot.Position - predictedPosition).Magnitude
            if distance < shortestDistance then
                shortestDistance = distance
                closestPlayer = player
                closestPart = targetPart
                Engine.Cache.LastTargetPosition = predictedPosition
                Engine.Cache.LastTargetVelocity = velocity
            end
        end
    end
    
    return closestPlayer, closestPart
end

local function FindGrabRemote()
    local remotes = {}
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            if obj.Name:lower():find("grab") or obj.Name:lower():find("throw") or obj.Name:lower():find("interact") or obj.Name:lower():find("action") then
                table.insert(remotes, obj)
            end
        end
    end
    return remotes
end

local grabRemotes = FindGrabRemote()

local function InterceptGrabCall(remote, method, args)
    if not Engine.Flags.SilentAim then return args end
    
    local target, targetPart = GetClosestSkeletonInRange()
    if target and targetPart then
        for i, arg in ipairs(args) do
            if type(arg) == "userdata" and arg:IsA("BasePart") then
                args[i] = targetPart
            elseif type(arg) == "CFrame" then
                args[i] = targetPart.CFrame
            elseif type(arg) == "Vector3" then
                args[i] = targetPart.Position
            end
        end
    end
    
    return args
end

local oldNamecall = nil
pcall(function()
    local mt = getrawmetatable(game)
    oldNamecall = mt.__namecall
    if oldNamecall then
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            
            if Engine.Flags.SilentAim then
                if self:IsA("RemoteEvent") and method == "FireServer" then
                    args = InterceptGrabCall(self, method, args)
                elseif self:IsA("RemoteFunction") and method == "InvokeServer" then
                    args = InterceptGrabCall(self, method, args)
                end
            end
            
            return oldNamecall(self, unpack(args))
        end)
    end
end)

local oldIndex = nil
pcall(function()
    local mt = getrawmetatable(game)
    oldIndex = mt.__index
    if oldIndex then
        mt.__index = newcclosure(function(self, key)
            if Engine.Flags.SilentAim and self == lp:GetMouse() then
                if key == "Hit" then
                    local target, targetPart = GetClosestSkeletonInRange()
                    if target and targetPart then
                        return targetPart.CFrame
                    end
                elseif key == "Target" then
                    local target, targetPart = GetClosestSkeletonInRange()
                    if target and targetPart then
                        return targetPart
                    end
                end
            end
            return oldIndex(self, key)
        end)
    end
end)

-- [3.2. МОДУЛЬ: MEGA-THROW]
SafeConnect(UserInputService.InputBegan, function(input, processed)
    if not Engine.Flags.MegaThrow or processed then return end
    
    if input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.Touch then
        local currentTime = tick()
        if Engine.Cache.ThrowCooldown and currentTime - Engine.Cache.LastThrowTime < 0.2 then
            return
        end
        
        local target, targetPart = GetClosestSkeletonInRange()
        if target and targetPart then
            local myRoot = GetCharacterRoot(lp.Character)
            if myRoot then
                local distance = (myRoot.Position - targetPart.Position).Magnitude
                if distance < Engine.Flags.ThrowRange then
                    pcall(function()
                        targetPart.AssemblyLinearVelocity = camera.CFrame.LookVector * Engine.Flags.ThrowForce
                        for _, boneName in ipairs(skeletonBones) do
                            local bone = target.Character:FindFirstChild(boneName)
                            if bone and bone:IsA("BasePart") and bone ~= targetPart then
                                bone.AssemblyLinearVelocity = camera.CFrame.LookVector * Engine.Flags.ThrowForce * 0.5
                            end
                        end
                        for _, part in ipairs(target.Character:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = false
                            end
                        end
                        Engine.Cache.LastThrowTime = currentTime
                        Engine.Cache.ThrowCooldown = true
                        task.delay(0.2, function()
                            Engine.Cache.ThrowCooldown = false
                        end)
                    end)
                end
            end
        end
    end
end)

-- [3.3. МОДУЛЬ: CROWN VORTEX]
local function GrabPlayerSkeleton(target)
    if not target or target == lp then return end
    if not IsValidCharacter(target.Character) then return end
    
    local targetRoot = GetCharacterRoot(target.Character)
    if not targetRoot then return end
    
    local currentTime = tick()
    if Engine.Cache.GrabCooldown and currentTime - Engine.Cache.LastGrabTime < Engine.Flags.VortexGrabDelay then
        return
    end
    
    for _, remote in ipairs(grabRemotes) do
        pcall(function()
            if remote:IsA("RemoteEvent") then
                remote:FireServer(targetRoot)
            elseif remote:IsA("RemoteFunction") then
                remote:InvokeServer(targetRoot)
            end
        end)
    end
    
    local char = lp.Character
    local tool = char and char:FindFirstChildOfClass("Tool")
    if tool and tool:FindFirstChild("Handle") then
        pcall(function()
            local handle = tool.Handle
            firetouchinterest(handle, targetRoot, 0)
            firetouchinterest(handle, targetRoot, 1)
        end)
    end
    
    Engine.Cache.LastGrabTime = currentTime
    Engine.Cache.GrabCooldown = true
    task.delay(Engine.Flags.VortexGrabDelay, function()
        Engine.Cache.GrabCooldown = false
    end)
end

SafeConnect(RunService.Heartbeat, function()
    if not Engine.Flags.CrownVortex then
        for _, player in ipairs(Engine.Cache.VortexPlayers) do
            if player and player.Character then
                local root = GetCharacterRoot(player.Character)
                if root then
                    pcall(function()
                        root.AssemblyLinearVelocity = camera.CFrame.LookVector * 2000000
                    end)
                end
            end
        end
        Engine.Cache.VortexPlayers = {}
        Engine.Cache.VortexGrabbedPlayers = {}
        Engine.Cache.VortexAngle = 0
        Engine.Cache.IsVortexActive = false
        return
    end
    
    local char = lp.Character
    local root = GetCharacterRoot(char)
    if not root then return end
    
    Engine.Cache.VortexAngle = Engine.Cache.VortexAngle + Engine.Flags.VortexSpeed
    Engine.Cache.IsVortexActive = true
    
    local newList = {}
    for _, player in ipairs(Engine.Cache.VortexPlayers) do
        if player and IsValidCharacter(player.Character) then
            table.insert(newList, player)
        end
    end
    Engine.Cache.VortexPlayers = newList
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == lp then continue end
        if not IsValidCharacter(player.Character) then continue end
        
        local found = false
        for _, p in ipairs(Engine.Cache.VortexPlayers) do
            if p == player then found = true break end
        end
        
        if not found then
            GrabPlayerSkeleton(player)
            table.insert(Engine.Cache.VortexPlayers, player)
            task.wait(Engine.Flags.VortexGrabDelay)
        end
    end
    
    local count = #Engine.Cache.VortexPlayers
    if count == 0 then return end
    
    local height = Engine.Flags.VortexHeight or 25
    local radius = Engine.Flags.VortexRadius or 8
    local angle = Engine.Cache.VortexAngle
    
    for i, player in ipairs(Engine.Cache.VortexPlayers) do
        if player and player.Character then
            local targetRoot = GetCharacterRoot(player.Character)
            if targetRoot then
                local playerAngle = angle + (i / count) * math.pi * 2
                local targetPos = root.Position + Vector3.new(
                    math.cos(playerAngle) * radius,
                    height,
                    math.sin(playerAngle) * radius
                )
                
                pcall(function()
                    targetRoot.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                    targetRoot.CFrame = CFrame.new(targetPos, root.Position)
                    local torso = player.Character:FindFirstChild("Torso")
                    if torso then
                        torso.CFrame = CFrame.new(torso.Position, root.Position)
                    end
                    local head = player.Character:FindFirstChild("Head")
                    if head then
                        head.CFrame = CFrame.new(head.Position, root.Position)
                    end
                end)
            end
        end
    end
end)

SafeConnect(Players.PlayerAdded, function(player)
    player.CharacterAdded:Connect(function(char)
        if Engine.Flags.CrownVortex then
            local found = false
            for _, p in ipairs(Engine.Cache.VortexPlayers) do
                if p == player then found = true break end
            end
            if not found then
                table.insert(Engine.Cache.VortexPlayers, player)
            end
        end
    end)
end)

-- [3.4. МОДУЛЬ: ANTI-GRAB]
local function SetupAntiGrab(char)
    if not char then return end
    
    local function OnChildAdded(child)
        if not Engine.Flags.AntiGrab then return end
        
        local isEnemyGrab = false
        
        if child:IsA("Weld") or child:IsA("WeldConstraint") or 
           child:IsA("RopeConstraint") or child:IsA("NoCollisionConstraint") or 
           child:IsA("ManualWeld") or child:IsA("JointInstance") or
           child:IsA("Motor6D") or child:IsA("Snap") then
            
            local part0 = child.Part0
            local part1 = child.Part1
            
            if part0 and part1 then
                local model0 = part0:FindFirstAncestorOfClass("Model")
                local model1 = part1:FindFirstAncestorOfClass("Model")
                
                if model0 and model1 then
                    local isPlayer0 = Players:GetPlayerFromCharacter(model0)
                    local isPlayer1 = Players:GetPlayerFromCharacter(model1)
                    
                    if isPlayer0 and isPlayer0 ~= lp and model1 == char then
                        isEnemyGrab = true
                    elseif isPlayer1 and isPlayer1 ~= lp and model0 == char then
                        isEnemyGrab = true
                    end
                end
            end
        end
        
        if isEnemyGrab then
            local root = GetCharacterRoot(char)
            if root then
                Engine.Cache.SavedPosition = root.CFrame
            end
            
            pcall(function()
                child:Destroy()
                ResetCharacterPhysics(char)
            end)
        end
    end
    
    local connection = char.ChildAdded:Connect(OnChildAdded)
    table.insert(Engine.Cache.Connections, connection)
end

SafeConnect(RunService.Heartbeat, function()
    if not Engine.Flags.AntiGrab then return end
    
    local char = lp.Character
    local root = GetCharacterRoot(char)
    if not root then return end
    
    local velocity = root.AssemblyLinearVelocity
    local velocityMag = velocity.Magnitude
    
    Engine.Cache.VelocityLog[Engine.Cache.VelocityLogIndex] = velocityMag
    Engine.Cache.VelocityLogIndex = (Engine.Cache.VelocityLogIndex % Engine.Cache.MaxVelocityLog) + 1
    
    if velocityMag > Engine.Flags.VelocityThreshold and Engine.Cache.SavedPosition then
        pcall(function()
            root.CFrame = Engine.Cache.SavedPosition
            root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            ResetCharacterPhysics(char)
        end)
    end
end)

if lp.Character then
    SetupAntiGrab(lp.Character)
end

SafeConnect(lp.CharacterAdded, function(char)
    task.wait(0.2)
    SetupAntiGrab(char)
end)

-- [3.5. МОДУЛЬ: КАМЕРА]
SafeConnect(RunService.RenderStepped, function()
    if Engine.Flags.ForceThirdPerson then
        pcall(function()
            lp.CameraMode = Enum.CameraMode.Classic
            lp.CameraMaxZoomDistance = Engine.Flags.ThirdPersonZoom
            lp.CameraMinZoomDistance = 1
            Engine.Cache.CameraRestoreData.Mode = Enum.CameraMode.Classic
            Engine.Cache.CameraRestoreData.Zoom = Engine.Flags.ThirdPersonZoom
        end)
    else
        pcall(function()
            if Engine.Cache.OriginalCameraMode then
                lp.CameraMode = Engine.Cache.OriginalCameraMode
                lp.CameraMaxZoomDistance = Engine.Cache.OriginalZoomDistance
            end
        end)
    end
end)

-- [3.6. МОДУЛЬ: МЕТАТАБЛИЦА]
local rawMT = getrawmetatable(game)
local oldIndexMT = rawMT.__index
local oldNewIndexMT = rawMT.__newindex
setreadonly(rawMT, false)

rawMT.__index = newcclosure(function(self, index)
    if Engine.Flags.BypassMetatable and not checkcaller() then
        if self:IsA("Humanoid") then
            if index == "WalkSpeed" then return 16 end
            if index == "JumpPower" then return 50 end
        end
    end
    return oldIndexMT(self, index)
end)

rawMT.__newindex = newcclosure(function(self, index, val)
    if Engine.Flags.BypassMetatable and not checkcaller() then
        if self:IsA("Humanoid") then
            if index == "WalkSpeed" and val == 0 then return end
            if index == "JumpPower" and val == 0 then return end
        end
    end
    oldNewIndexMT(self, index, val)
end)

setreadonly(rawMT, true)

-- [3.7. МОДУЛЬ: ДВИЖЕНИЕ]
SafeConnect(RunService.Heartbeat, function()
    local char = lp.Character
    if not char then return end
    local hum = GetHumanoid(char)
    if not hum then return end
    
    if Engine.Flags.WalkSpeedEnabled then
        pcall(function()
            hum.WalkSpeed = Engine.Flags.WalkSpeedValue
        end)
    end
    
    if Engine.Flags.JumpPowerEnabled then
        pcall(function()
            hum.JumpPower = Engine.Flags.JumpPowerValue
        end)
    end
end)

SafeConnect(RunService.Stepped, function()
    local char = lp.Character
    if not char then return end
    
    if Engine.Flags.Noclip then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                pcall(function()
                    part.CanCollide = false
                end)
            end
        end
    end
end)

SafeConnect(RunService.Heartbeat, function()
    local char = lp.Character
    if not char then return end
    
    if Engine.Flags.AntiFling then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                pcall(function()
                    part.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                    if not Engine.Flags.Fly then
                        local velocity = part.AssemblyLinearVelocity
                        if velocity.Magnitude > 80 then
                            part.AssemblyLinearVelocity = Vector3.new(
                                math.clamp(velocity.X, -25, 25),
                                math.clamp(velocity.Y, -40, 40),
                                math.clamp(velocity.Z, -25, 25)
                            )
                        end
                    end
                end)
            end
        end
    end
end)

local flyBodyVelocity = nil

SafeConnect(RunService.RenderStepped, function()
    local char = lp.Character
    local root = GetCharacterRoot(char)
    local hum = GetHumanoid(char)
    
    if not root or not hum then return end
    
    if Engine.Flags.Fly then
        pcall(function()
            hum.PlatformStand = true
            
            if not flyBodyVelocity or flyBodyVelocity.Parent ~= root then
                flyBodyVelocity = Instance.new("BodyVelocity")
                flyBodyVelocity.MaxForce = Vector3.new(1e6, 1e6, 1e6)
                flyBodyVelocity.Parent = root
            end
            
            local moveDir = hum.MoveDirection
            local camCFrame = camera.CFrame
            local flySpeed = Engine.Flags.FlySpeed or 50
            local flyVel = Vector3.new(0, 0, 0)
            
            if moveDir.Magnitude > 0 then
                local forwardVector = camCFrame.LookVector
                local rightVector = camCFrame.RightVector
                flyVel = (forwardVector * (moveDir.Z * -flySpeed)) + (rightVector * (moveDir.X * flySpeed))
            end
            
            if Engine.Cache.FlyUp or UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                flyVel = flyVel + Vector3.new(0, flySpeed, 0)
            end
            if Engine.Cache.FlyDown or UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                flyVel = flyVel - Vector3.new(0, flySpeed, 0)
            end
            
            flyBodyVelocity.Velocity = flyVel
        end)
    elseif flyBodyVelocity then
        pcall(function()
            flyBodyVelocity:Destroy()
            flyBodyVelocity = nil
            if hum then
                hum.PlatformStand = false
            end
            if root then
                root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            end
        end)
    end
end)

SafeConnect(UserInputService.JumpRequest, function()
    if Engine.Flags.InfiniteJump then
        local char = lp.Character
        local hum = GetHumanoid(char)
        if hum then
            pcall(function()
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end)
        end
    end
end)

SafeConnect(RunService.RenderStepped, function()
    if Engine.Flags.AspectRatioStretch and Engine.Flags.AspectRatioStretch ~= 1.0 then
        pcall(function()
            camera.FieldOfView = math.clamp(70 * Engine.Flags.AspectRatioStretch, 35, 140)
        end)
    end
end)

-- [3.8. МОДУЛЬ: ТРОЛЛИНГ]
local function ExecuteFling(target)
    if not target or target == lp then return end
    if not IsValidCharacter(target.Character) then return end
    
    local char = lp.Character
    local root = GetCharacterRoot(char)
    local tchar = target.Character
    local troot = GetCharacterRoot(tchar)
    
    if not root or not troot then return end
    
    local oldCFrame = root.CFrame
    local flingActive = true
    
    local tempNoclip = RunService.Stepped:Connect(function()
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    pcall(function() part.CanCollide = false end)
                end
            end
        end
    end)
    
    local flingLoop = RunService.Heartbeat:Connect(function()
        if not tchar or not troot or not troot.Parent or not flingActive then return end
        pcall(function()
            root.AssemblyLinearVelocity = Vector3.new(0, 3000000, 0)
            root.AssemblyAngularVelocity = Vector3.new(3000000, 3000000, 3000000)
            root.CFrame = troot.CFrame * CFrame.new(math.random(-2, 2)/10, 0, math.random(-2, 2)/10)
        end)
    end)
    
    task.delay(1.5, function()
        flingActive = false
        pcall(function()
            tempNoclip:Disconnect()
            flingLoop:Disconnect()
        end)
        task.wait(0.02)
        if root then
            pcall(function()
                root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                root.CFrame = oldCFrame
            end)
        end
    end)
end

SafeConnect(RunService.Heartbeat, function()
    if not Engine.Flags.FlingAura then return end
    
    local char = lp.Character
    local root = GetCharacterRoot(char)
    if not root then return end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == lp then continue end
        if not IsValidCharacter(player.Character) then continue end
        
        local targetRoot = GetCharacterRoot(player.Character)
        if targetRoot then
            local dist = (root.Position - targetRoot.Position).Magnitude
            if dist <= 18 then
                ExecuteFling(player)
            end
        end
    end
end)

SafeConnect(UserInputService.InputBegan, function(input, processed)
    if processed or not Engine.Flags.ClickFling then return end
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
    
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        local mousePos = UserInputService:GetMouseLocation()
        local ray = camera:ViewportPointToRay(mousePos.X, mousePos.Y)
        local raycastParams = RaycastParams.new()
        raycastParams.FilterType = Enum.RaycastFilterType.Exclude
        raycastParams.FilterDescendantsInstances = {lp.Character}
        
        local result = workspace:Raycast(ray.Origin, ray.Direction * 1500, raycastParams)
        if result and result.Instance then
            local model = result.Instance:FindFirstAncestorOfClass("Model")
            if model then
                local clickedPlayer = Players:GetPlayerFromCharacter(model)
                if clickedPlayer and clickedPlayer ~= lp then
                    ExecuteFling(clickedPlayer)
                end
            end
        end
    end
end)

local orbitAngle = 0
SafeConnect(RunService.Heartbeat, function()
    if not Engine.Flags.OrbitPlayer or Engine.Flags.TargetPlayer == "" then return end
    
    local target = FindPlayerByName(Engine.Flags.TargetPlayer)
    if not target then return end
    
    local char = lp.Character
    local root = GetCharacterRoot(char)
    local tchar = target.Character
    local troot = GetCharacterRoot(tchar)
    
    if not root or not troot then return end
    
    orbitAngle = orbitAngle + (Engine.Flags.OrbitSpeed / 50)
    local offset = Vector3.new(
        math.cos(orbitAngle) * Engine.Flags.OrbitDistance,
        0,
        math.sin(orbitAngle) * Engine.Flags.OrbitDistance
    )
    pcall(function()
        root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        root.CFrame = CFrame.new(troot.Position + offset, troot.Position)
    end)
end)

local function RunMassWeld()
    local char = lp.Character
    if not char then return end
    
    for _, part in ipairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") and not part.Anchored and not part:IsDescendantOf(char) then
            pcall(function()
                local weld = Instance.new("WeldConstraint")
                weld.Part0 = part
                weld.Part1 = GetCharacterRoot(char) or char:FindFirstChildOfClass("Part")
                weld.Parent = part
                part.CanCollide = false
            end)
        end
    end
end

SafeConnect(RunService.Heartbeat, function()
    if not Engine.Flags.LobbyFreeze then return end
    
    local char = lp.Character
    local root = GetCharacterRoot(char)
    if not root then return end
    
    for i = 1, 40 do
        pcall(function()
            root.CFrame = root.CFrame * CFrame.new(0, 999999, 0)
            root.CFrame = root.CFrame * CFrame.new(0, -999999, 0)
        end)
    end
end)

task.spawn(function()
    while task.wait(3) do
        if Engine.Flags.ChatSpam and Engine.Loaded then
            pcall(function()
                if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
                    local channel = TextChatService.TextChannels.RBXGeneral
                    channel:SendAsync(Engine.Flags.ChatSpamMessage)
                else
                    ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(Engine.Flags.ChatSpamMessage, "All")
                end
            end)
        end
    end
end)

-- [3.9. МОДУЛЬ: ВЫГРУЗКА]
local function CompleteDestruction()
    Engine.Loaded = false
    
    for _, conn in ipairs(Engine.Cache.Connections) do
        if conn and conn.Connected then
            pcall(function() conn:Disconnect() end)
        end
    end
    table.clear(Engine.Cache.Connections)
    
    pcall(function()
        Lighting.Ambient = Engine.Cache.OriginalLighting.Ambient
        Lighting.OutdoorAmbient = Engine.Cache.OriginalLighting.OutdoorAmbient
        Lighting.Brightness = Engine.Cache.OriginalLighting.Brightness
        Lighting.ClockTime = Engine.Cache.OriginalLighting.ClockTime
        Lighting.FogEnd = Engine.Cache.OriginalLighting.FogEnd
        Lighting.GlobalShadows = Engine.Cache.OriginalLighting.GlobalShadows
    end)
    
    for part, origSize in pairs(Engine.Cache.OriginalSizes) do
        if part and part.Parent then
            pcall(function()
                part.Size = origSize
                part.CanCollide = true
                part.Massless = false
            end)
        end
    end
    table.clear(Engine.Cache.OriginalSizes)
    
    pcall(function()
        if Engine.Cache.OriginalCameraMode then
            lp.CameraMode = Engine.Cache.OriginalCameraMode
            lp.CameraMaxZoomDistance = Engine.Cache.OriginalZoomDistance
        end
    end)
    
    pcall(function()
        local char = lp.Character
        if char then
            ResetCharacterPhysics(char)
            local hum = GetHumanoid(char)
            if hum then
                hum.WalkSpeed = 16
                hum.JumpPower = 50
            end
        end
    end)
    
    if Engine.Cache.FlyBodyVelocity then
        pcall(function() Engine.Cache.FlyBodyVelocity:Destroy() end)
        Engine.Cache.FlyBodyVelocity = nil
    end
    
    if Engine.Cache.SylentUI and Engine.Cache.SylentUI.Screen then
        pcall(function() Engine.Cache.SylentUI.Screen:Destroy() end)
    end
    
    table.clear(Engine.Cache.HuntingList)
    table.clear(Engine.Cache.VortexPlayers)
    table.clear(Engine.Cache.VortexGrabbedPlayers)
    table.clear(Engine.Cache.VelocityLog)
    Engine.Cache.SavedPosition = nil
    Engine.Cache.SilentAimTarget = nil
    
    _G.SylentEngine = nil
    print("[SYLENT Engine]: Скрипт выгружен. Все соединения очищены. Память освобождена.")
end

-- ============================================================================
-- [4. ФИНАЛЬНАЯ ИНИЦИАЛИЗАЦИЯ]
-- ============================================================================
Engine.Cache.OriginalCameraMode = lp.CameraMode
Engine.Cache.OriginalZoomDistance = lp.CameraMaxZoomDistance

SafeConnect(lp.CharacterAdded, function(char)
    local hum = char:WaitForChild("Humanoid", 15)
    if hum then
        task.wait(0.5)
        SetupAntiGrab(char)
    end
end)

print("[SYLENT Engine v2.1]: Невидимый физический движок с UI загружен.")
print("  ✅ Silent Aim — " .. (Engine.Flags.SilentAim and "активен" or "ожидает включения"))
print("  ✅ Mega Throw — " .. (Engine.Flags.MegaThrow and "активен" or "ожидает включения"))
print("  ✅ Crown Vortex — " .. (Engine.Flags.CrownVortex and "активен" or "ожидает включения"))
print("  ✅ Anti-Grab — " .. (Engine.Flags.AntiGrab and "активен" or "отключен"))
print("  ✅ UI — активен (кнопка ⚡ в левом верхнем углу)")
print("Для выгрузки используйте кнопку в меню или CompleteDestruction()")
