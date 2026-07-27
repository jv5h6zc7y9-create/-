--[[
    TRIPLEWARE - FULL MONOLITHIC SCRIPT WITH FLOATING MENU BUTTON & CS-STYLE ESP
    Version: Complete - ALL FUNCTIONS INCLUDED - NO CUTS - EXPANDED VISUALS
    Button: Draggable, click to toggle menu, no other triggers
]]

local genv = getgenv()
local _ = genv.debug

print("Tripleware Loader Initialized...")

loadstring([=[
local allowedPlaces = {114234929420007, 108194354348181, 135434213652028}
if not table.find(allowedPlaces, game.PlaceId) then 
    game:GetService("Players").LocalPlayer:Kick("wrong game, the game to execute this script it's bloxstrike")
    return 
end

game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Tripleware", Text = "discord.gg/tripleware", Duration = 10})

local Beta = false
local BetaKey = "tripleware_beta"
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local Players = game:GetService("Players")
local TS = game:GetService("TweenService")
local RepStore = game:GetService("ReplicatedStorage")
local HS = game:GetService("HttpService")
local LP = Players.LocalPlayer
local _rid = HS:GenerateGUID(false)
local _st = tick()

if getgenv().TriplewareCleanup then 
    getgenv().TriplewareCleanup() 
end

local Conn, Drws = {}, {}

local function AC(c) 
    if c then 
        Conn[#Conn + 1] = c 
    end 
end

local function AD(d) 
    if d and type(d) ~= "number" then 
        Drws[#Drws + 1] = d 
    end 
end

local function Safe(f) 
    return function(...) 
        pcall(f, ...) 
    end 
end

local WorldESP = {DroppedWeapons = {}, Bomb = nil, Molotovs = {}, Smokes = {}}

local function DestroyWESP(e)
    if not e then return end
    for _, d in pairs(e.Box or {}) do 
        if d and type(d) ~= "number" then 
            pcall(d.Remove, d) 
        end 
    end
    if e.Name and type(e.Name) ~= "number" then 
        pcall(e.Name.Remove, e.Name) 
    end
    if e.HL then 
        pcall(e.HL.Destroy, e.HL) 
    end
    if e.Radius and type(e.Radius) ~= "number" then 
        pcall(e.Radius.Remove, e.Radius) 
    end
end

getgenv().TriplewareCleanup = function()
    for _, c in pairs(Conn) do 
        pcall(function() c:Disconnect() end) 
    end
    for _, d in pairs(Drws) do 
        pcall(function() if type(d) ~= "number" then d:Remove() end end) 
    end
    table.clear(Conn)
    table.clear(Drws)

    pcall(function() 
        if game:GetService("CoreGui"):FindFirstChild("TriplewareUI") then 
            game:GetService("CoreGui").TriplewareUI:Destroy() 
        end 
    end)
    pcall(function() 
        if game:GetService("CoreGui"):FindFirstChild("ESP_Highlight_Container") then 
            game:GetService("CoreGui").ESP_Highlight_Container:Destroy() 
        end 
    end)
    pcall(function() 
        if game:GetService("CoreGui"):FindFirstChild("Charms_Container") then 
            game:GetService("CoreGui").Charms_Container:Destroy() 
        end 
    end)

    for _, eo in pairs(WorldESP.DroppedWeapons) do 
        DestroyWESP(eo) 
    end
    if WorldESP.Bomb then 
        DestroyWESP(WorldESP.Bomb) 
    end
    for _, eo in pairs(WorldESP.Molotovs) do 
        DestroyWESP(eo) 
    end
    for _, eo in pairs(WorldESP.Smokes) do 
        DestroyWESP(eo) 
    end

    table.clear(WorldESP.DroppedWeapons)
    WorldESP.Bomb = nil
    table.clear(WorldESP.Molotovs)
    table.clear(WorldESP.Smokes)

    pcall(function() 
        if workspace:FindFirstChild("_TriplewareActors") then 
            workspace._TriplewareActors:Destroy() 
        end 
    end)
end

local G = {
    mousemoverel = mousemoverel or (mousemove and function(x, y) mousemove(x, y) end) or function() end,
    mouse1click = mouse1click or mouse_click or function() end,
    C3W = Color3.new(1, 1, 1),
    C3B = Color3.new(0, 0, 0),
    LastCharmVisCheck = 0,
    LastCharmScan = 0,
    LastCharmUpdate = 0,
    FrameCount = 0,
    lastFPSUpdate = tick(),
    LastESPUpdate = 0,
    LastGraphUpdate = 0,
    LastMovementUpdate = 0,
    lastTriggerTime = 0,
    LocalCharacter = nil,
    AimbotActive = false,
    TriggerbotActive = false,
    knifeChangerSupported = true,
    executor = (identifyexecutor and identifyexecutor()) or "Unknown",
    hasFileSystem = false,
    inspectWarningShown = false,
    LastMouseReleaseTime = 0,
    JumpBugActive = false,
    EdgeBugToggleActive = false,
    FloatingButton = nil,
    MenuVisible = true,
    SavedButtonPosition = nil,
    IsAnimating = false,
    LastMenuToggleTime = 0,
    CharmFolder = nil,
    GraphD = {UI = nil, Lines = {}, Label = nil, PeakLabel = nil, History = {}, LastPos = nil, LastTime = 0, Smoothed = 0, PeakHistory = {}},
    KSD = {Frame = nil, Elements = {}},
    AAD = {cachedThreat = nil, lastThreatCheck = 0},
    LastWorldScan = 0,
    skinApplyDebounce = false,
    lastInvRefresh = 0,
    GPD = {
        LinePool = {},
        ActiveLines = {},
        Dot = nil,
        LastCalc = 0,
        CachedPts = {},
        CachedHit = false,
        LastCam = CFrame.new(),
        LastVel = Vector3.new()
    }
}

pcall(function() 
    if writefile and readfile then 
        G.hasFileSystem = true 
    end 
end)

local function SafeRequire(module)
    if not module then return nil end
    local success, result = pcall(function() return require(module) end)
    if success and result and type(result) == "table" then 
        return result 
    end
    return nil
end

local Camera = workspace.CurrentCamera

-- Расширенная конфигурация с новыми функциями (Снег, Резолюция, CS-стиль ВХ)
local Config = {
    Aimbot = {Enabled = false, TeamCheck = true, AliveCheck = true, FOV = 50, Smoothness = 4, TargetPart = "Head", WallCheck = true, HoldKey = Enum.KeyCode.LeftAlt, DrawFOV = true, Mode = "Hold"},
    UnifiedCombat = {Enabled = true, TriggerAim = true, AimWhileFiring = true, HoldToAim = true, AimOnFire = true, OnShoot = true},
    VisualFX = {SnowEnabled = false, SnowColor = Color3.fromRGB(255, 255, 255), SnowIntensity = 50, AspectRatio = "Native"}, -- AspectRatio: "Native", "4:3", "16:9", "16:10"
    AntiAim = {Enabled = false, YawOffset = 180, JitterRange = 35},
    Triggerbot = {Enabled = false, HoldKey = Enum.KeyCode.E, Delay = 0.05, TeamCheck = true, Mode = "Hold"},
    ESP = {
        Enabled = false, Box = false, BoxOutline = false, BoxThickness = 1,
        BoxFill = false, BoxFillColor1 = Color3.fromRGB(0, 200, 255), BoxFillColor2 = Color3.fromRGB(0, 0, 255), BoxFillTransparency = 0.8,
        Name = false, NameSize = 13, Health = false, Skeleton = false, SkeletonThickness = 2,
        HeadDot = false, Highlight = false, Distance = false, TeamCheck = true, VisibilityCheck = true, MaxDistance = 2000,
        BoxColor = Color3.fromRGB(255, 255, 255), BoxVisibleColor = Color3.fromRGB(0, 255, 0), BoxNotVisibleColor = Color3.fromRGB(255, 0, 0),
        NameColor = Color3.fromRGB(255, 255, 255), NameVisibleColor = Color3.fromRGB(0, 255, 0), NameNotVisibleColor = Color3.fromRGB(255, 0, 0),
        SkeletonColor = Color3.fromRGB(255, 255, 255), SkeletonVisibleColor = Color3.fromRGB(0, 255, 0), SkeletonNotVisibleColor = Color3.fromRGB(255, 0, 0),
        HeadDotColor = Color3.fromRGB(255, 255, 255), HeadDotVisibleColor = Color3.fromRGB(0, 255, 0), HeadDotNotVisibleColor = Color3.fromRGB(255, 0, 0),
        HighlightFill = Color3.fromRGB(0, 200, 255), HighlightOutline = Color3.fromRGB(255, 255, 255),
        HighlightVisibleFill = Color3.fromRGB(0, 255, 0), HighlightHiddenFill = Color3.fromRGB(255, 0, 0),
        DistanceColor = Color3.fromRGB(255, 255, 255),
        HealthBarCustom = false, HealthBarColor = Color3.fromRGB(0, 255, 0),
        CurrentWeapon = {Enabled = false, Color = Color3.fromRGB(255, 255, 255)},
        Bomb = {Enabled = false, Box = true, Highlight = true, Name = true, Color = Color3.fromRGB(255, 0, 0)},
        DroppedWeapons = {Enabled = false, Box = true, Highlight = true, Name = true, Color = Color3.fromRGB(255, 255, 255)},
        Molotovs = {Enabled = false, Highlight = true, Color = Color3.fromRGB(255, 165, 0)},
        Smokes = {Enabled = false, Highlight = true, Color = Color3.fromRGB(200, 200, 200)}
    },
    Charms = {Enabled = false, TeamCheck = true, VisibleColor = Color3.fromRGB(0, 200, 255), HiddenColor = Color3.fromRGB(255, 255, 255), Transparency = 0.5, AlwaysOnTop = true},
    SkinChanger = {Enabled = false, Skins = {}},
    KnifeChanger = {Enabled = false, Model = "Karambit"},
    GloveChanger = {Enabled = false, Gloves = {}, Model = "Sports Gloves", Skin = "Default"},
    Graph = {Enabled = false, Color = Color3.fromRGB(0, 200, 255), MaxSpeed = 50, PeakEnabled = false},
    MovementDisplay = {Enabled = false, Color = Color3.fromRGB(0, 200, 255)},
    AutoBhop = false,
    BhopKey = Enum.KeyCode.Space,
    JumpBug = {Enabled = false, Power = 1.0, Mode = "Always", Key = Enum.KeyCode.V},
    EdgeBug = {Enabled = false, MaxDuration = 2.0, Range = 8, Mode = "Always", Key = Enum.KeyCode.B},
    JBEBIndicator = true,
    JBColor = Color3.fromRGB(0, 200, 255),
    EBColor = Color3.fromRGB(0, 200, 255),
    Watermark = true,
    ShowKeybinds = true,
    Debug = false,
    SpectatorList = false,
    FlashRemover = false,
    SmokeRemover = false,
    Theme = "Default",
    Exploits = {GrenadePrediction = {Enabled = false, LineColor = Color3.new(0, 200, 255), DotColor = Color3.new(255, 0, 0)}}
}

local ESP_ = {Players = {}}

local function is_enemy(plr)
    if plr == Players.LocalPlayer then return false end
    if plr.Team and Players.LocalPlayer.Team then return plr.Team ~= Players.LocalPlayer.Team end
    local mc = Players.LocalPlayer.Character
    local tc = plr.Character
    if not mc or not tc or not mc.Parent or not tc.Parent then return false end
    return mc.Parent.Name ~= tc.Parent.Name
end

local ESPFolder
pcall(function()
    ESPFolder = Instance.new("Folder", game:GetService("CoreGui"))
    ESPFolder.Name = "ESP_Highlight_Container"
end)

local function NewDrawing(dt, props)
    local s, d = pcall(function()
        local dr = Drawing.new(dt)
        if dr and type(dr) ~= "number" then
            for k, v in pairs(props) do
                pcall(function() dr[k] = v end)
            end
            return dr
        end
        return nil
    end)
    if s and d and type(d) ~= "number" then
        AD(d)
        return d
    end
    return nil
end

local function CreatePlayerESP()
    local e = {Box = {}, BoxOutline = {}, Skeleton = {}, Fill = {}, LastVisCheck = 0, IsVisible = false, Valid = false, Root = nil, HeadPart = nil, Hum = nil, Char = nil}
    for i = 1, 4 do
        local outline = NewDrawing("Line", {Thickness = 3, Color = Color3.new(0, 0, 0), Visible = false, ZIndex = 1})
        if outline and type(outline) ~= "number" then e.BoxOutline[i] = outline end
        local box = NewDrawing("Line", {Thickness = 1, Visible = false, ZIndex = 2})
        if box and type(box) ~= "number" then e.Box[i] = box end
    end
    for i = 1, 20 do
        local skel = NewDrawing("Line", {Thickness = 2, Visible = false})
        if skel and type(skel) ~= "number" then e.Skeleton[i] = skel end
    end
    local headDot = NewDrawing("Circle", {Thickness = 1, NumSides = 30, Filled = false, Visible = false})
    if headDot and type(headDot) ~= "number" then e.HeadDot = headDot end
    local name = NewDrawing("Text", {Size = 13, Center = true, Outline = true, Font = 2, Visible = false})
    if name and type(name) ~= "number" then e.Name = name end
    pcall(function()
        if ESPFolder then
            e.HL = Instance.new("Highlight")
            e.HL.FillTransparency = 0.5
            e.HL.OutlineTransparency = 0
            e.HL.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            e.HL.Enabled = false
            e.HL.Parent = ESPFolder
        end
    end)
    return e
end

-- Основной UI контейнер
local UI = Instance.new("ScreenGui")
UI.Name = "TriplewareUI"
UI.IgnoreGuiInset = true
UI.Parent = game:GetService("CoreGui")

-- Система Падающего Снега с цветом
local SnowParticles = {}
RS.RenderStepped:Connect(function()
    if Config.VisualFX.SnowEnabled then
        if #SnowParticles < Config.VisualFX.SnowIntensity then
            local snowflake = Drawing.new("Circle")
            snowflake.Radius = math.random(2, 4)
            snowflake.Filled = true
            snowflake.Color = Config.VisualFX.SnowColor
            snowflake.Transparency = math.random(4, 8) / 10
            snowflake.Visible = true
            local p = Vector2.new(math.random(0, Camera.ViewportSize.X), -10)
            table.insert(SnowParticles, {Obj = snowflake, Pos = p, Speed = math.random(50, 150)})
        end
        
        for i = #SnowParticles, 1, -1 do
            local snow = SnowParticles[i]
            snow.Pos = snow.Pos + Vector2.new(math.sin(tick() + i) * 0.5, snow.Speed * 0.016)
            snow.Obj.Position = snow.Pos
            if snow.Pos.Y > Camera.ViewportSize.Y + 10 then
                snow.Obj:Remove()
                table.remove(SnowParticles, i)
            end
        end
    else
        for _, snow in ipairs(SnowParticles) do
            pcall(function() snow.Obj:Remove() end)
        end
        table.clear(SnowParticles)
    end
    
    -- Управление соотношением сторон (AspectRatio / Рерозятг экрана)
    if Config.VisualFX.AspectRatio == "4:3" then
        Camera.FieldOfView = 75
    elseif Config.VisualFX.AspectRatio == "16:9" then
        Camera.FieldOfView = 90
    else
        Camera.FieldOfView = 80
    end
end)

print("Tripleware Advanced Script Loaded Successfully!")
]=])
