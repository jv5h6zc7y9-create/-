--[[
    ================================================================================
    👑 SYLENT ENGINE v1.0 — ULTIMATE MONOLITHIC TESTING SUITE
    🎨 UI: NEO-GLOW CYBERPUNK INTERFACE (NATIVE INSTANCE-BASED)
    🔒 TARGET: ROBLOX RUNTIME 3.1+ (DELTA EXECUTOR)
    🚀 STATUS: ACTIVE | FULLY OPTIMIZED FOR MOBILE ARCHITECTURES
    ================================================================================
]]

if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- ============================================================================
-- [1. ЯДРО: СИСТЕМНЫЕ СЕРВИСЫ И ГЛОБАЛЬНОЕ СОСТОЯНИЕ]
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

_G.SylentEngine = {
    Loaded = true,
    Flags = {
        -- === БЛОК 1: ДВИЖЕНИЕ ===
        WalkSpeedEnabled = false,
        WalkSpeedValue = 16,
        JumpPowerEnabled = false,
        JumpPowerValue = 50,
        InfiniteJump = false,
        Noclip = false,
        Fly = false,
        FlySpeed = 50,
        AntiFling = false,
        
        -- === БЛОК 2: БОЙ ===
        SilentAim = false,
        SilentAimFOV = 120,
        SilentAimPrediction = 0.5,
        SilentAimTargetPart = "HumanoidRootPart",
        ShowFOV = false,
        MegaThrow = false,
        ThrowForce = 2000000,
        InstantGrabBreak = false,
        CounterAttack = false,
        CounterMode = "В небо",
        CounterAngle = 70,
        VehicleKillAll = false,
        UnlockToyShop = false,
        ForceThirdPerson = false,
        CustomFOV = 70,
        
        -- === БЛОК 3: ТРОЛЛИНГ ===
        FlingAura = false,
        ClickFling = false,
        FlingAll = false,
        KillAura = false,
        BringAll = false,
        PropsFling = false,
        OrbitPlayer = false,
        TargetPlayer = "",
        OrbitSpeed = 5,
        OrbitDistance = 5,
        MassWeld = false,
        LobbyFreeze = false,
        
        -- === БЛОК 4: ВИЗУАЛЫ ===
        ESP_Players = false,
        ESP_Tracers = false,
        ESP_Boxes = false,
        ESP_Names = false,
        ESP_Health = false,
        Fullbright = false,
        PotatoPC = false,
        ESP_BoxThickness = 2,
        ESP_BoxTransparency = 0.8,
        ESP_TracerThickness = 1.5,
        ESP_TracerTransparency = 0.9,
        
        -- === БЛОК 5: РАСШИРЕННЫЕ МОДУЛИ ===
        HitboxExpansion = false,
        HitboxScale = 5,
        ProximityGrab = false,
        ProximityRadius = 4,
        AspectRatioStretch = 1.0,
        CrownVortex = false,
        VortexRadius = 8,
        VortexHeight = 25,
        TextureAudit = false,
        
        -- === БЛОК 6: ЯДРО ===
        BypassMetatable = true,
        ChatSpam = false,
        ChatSpamMessage = "SYLENT Engine v1.0 Ultimate Testing Suite Running!"
    },
    Cache = {
        OriginalLighting = {
            Ambient = Lighting.Ambient,
            OutdoorAmbient = Lighting.OutdoorAmbient,
            Brightness = Lighting.Brightness,
            ClockTime = Lighting.ClockTime,
            FogEnd = Lighting.FogEnd,
            GlobalShadows = Lighting.GlobalShadows
        },
        Connections = {},
        EspBoxes = {},
        EspTracers = {},
        EspNames = {},
        EspHealth = {},
        EspHighlights = {},
        OriginalMaterials = {},
        OriginalSizes = {},
        OriginalCameraMode = lp.CameraMode,
        OriginalZoomDistance = lp.CameraMaxZoomDistance,
        OriginalAspectRatio = 1.0,
        HuntingList = {},
        FlyUp = false,
        FlyDown = false,
        IsGrabbing = false,
        CurrentGrabbedTarget = nil,
        SilentAimTarget = nil,
        AssistAimTarget = nil,
        LastTargetPosition = nil,
        LastTargetVelocity = Vector3.new(0, 0, 0),
        VortexPlayers = {},
        SavedPosition = nil,
        TextureAuditProcessed = {}
    }
}

local Engine = _G.SylentEngine

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

-- ============================================================================
-- [2. МОДУЛЬ: FOV И SILENT AIM (ПРЕДИКТИВНАЯ КОРРЕКТИРОВКА ВЕКТОРОВ)]
-- ============================================================================

local FOVGui = Instance.new("ScreenGui")
FOVGui.Name = "Sylent_FOV_Core"
FOVGui.ResetOnSpawn = false
pcall(function() FOVGui.Parent = CoreGui end)
if not FOVGui.Parent then FOVGui.Parent = lp:WaitForChild("PlayerGui") end

local FOVCircle = Instance.new("Frame")
FOVCircle.Name = "FOVFrame"
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.BackgroundTransparency = 1
FOVCircle.Size = UDim2.new(0, Engine.Flags.SilentAimFOV * 2, 0, Engine.Flags.SilentAimFOV * 2)
FOVCircle.Visible = false
FOVCircle.Parent = FOVGui

local FOVCorner = Instance.new("UICorner")
FOVCorner.CornerRadius = UDim.new(1, 0)
FOVCorner.Parent = FOVCircle

local FOVStroke = Instance.new("UIStroke")
FOVStroke.Color = Color3.fromRGB(0, 255, 240)
FOVStroke.Thickness = 1.5
FOVStroke.Parent = FOVCircle

SafeConnect(RunService.RenderStepped, function()
    if Engine.Flags.SilentAim and Engine.Flags.ShowFOV then
        local viewportSize = camera.ViewportSize
        local inset = GuiService:GetGuiInset()
        local exactCenterX = viewportSize.X / 2
        local exactCenterY = (viewportSize.Y - inset.Y) / 2
        
        FOVCircle.Visible = true
        FOVCircle.Position = UDim2.new(0, exactCenterX, 0, exactCenterY)
        FOVCircle.Size = UDim2.new(0, Engine.Flags.SilentAimFOV * 2, 0, Engine.Flags.SilentAimFOV * 2)
    else
        FOVCircle.Visible = false
    end
end)

local fovCircleDrawing = Drawing.new("Circle")
fovCircleDrawing.Thickness = 1.5
fovCircleDrawing.Filled = false
fovCircleDrawing.Color = Color3.fromRGB(0, 255, 240)
fovCircleDrawing.Transparency = 0.7
fovCircleDrawing.Visible = false

SafeConnect(RunService.RenderStepped, function()
    if Engine.Flags.SilentAim and Engine.Flags.ShowFOV then
        local viewportSize = camera.ViewportSize
        local inset = GuiService:GetGuiInset()
        local exactCenterX = viewportSize.X / 2
        local exactCenterY = (viewportSize.Y - inset.Y) / 2
        
        fovCircleDrawing.Position = Vector2.new(exactCenterX, exactCenterY)
        fovCircleDrawing.Radius = Engine.Flags.SilentAimFOV
        fovCircleDrawing.Visible = true
    else
        fovCircleDrawing.Visible = false
    end
end)

local targetBones = {
    "Head", "Torso", "HumanoidRootPart", "UpperTorso", "LowerTorso",
    "LeftArm", "RightArm", "LeftLeg", "RightLeg",
    "LeftHand", "RightHand", "LeftFoot", "RightFoot"
}

local function GetClosestPlayerWithPrediction()
    local closestPlayer = nil
    local closestPart = nil
    local shortestDistance = Engine.Flags.SilentAimFOV or 120
    local viewportSize = camera.ViewportSize
    local inset = GuiService:GetGuiInset()
    local center = Vector2.new(viewportSize.X / 2, (viewportSize.Y - inset.Y) / 2)
    local targetPartName = Engine.Flags.SilentAimTargetPart or "HumanoidRootPart"
    local predictionStrength = Engine.Flags.SilentAimPrediction or 0.5
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == lp then continue end
        if not player.Character then continue end
        
        local hum = player.Character:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        
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
        
        local targetPart = player.Character:FindFirstChild(targetPartName)
        if targetPart and targetPart:IsA("BasePart") then
            local velocity = targetPart.AssemblyLinearVelocity
            local predictionTime = predictionStrength / 5
            local predictedPosition = targetPart.Position + (velocity * predictionTime)
            
            if targetPartName == "HumanoidRootPart" or targetPartName == "Torso" then
                predictedPosition = predictedPosition + Vector3.new(0, -0.5, 0)
            end
            
            local screenPos, onScreen = camera:WorldToViewportPoint(predictedPosition)
            if onScreen then
                local distance = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    closestPlayer = player
                    closestPart = targetPart
                    Engine.Cache.LastTargetPosition = predictedPosition
                    Engine.Cache.LastTargetVelocity = velocity
                end
            end
        else
            for _, boneName in ipairs(targetBones) do
                local part = player.Character:FindFirstChild(boneName)
                if part and part:IsA("BasePart") then
                    local velocity = part.AssemblyLinearVelocity
                    local predictionTime = predictionStrength / 5
                    local predictedPosition = part.Position + (velocity * predictionTime)
                    
                    if boneName == "HumanoidRootPart" or boneName == "Torso" then
                        predictedPosition = predictedPosition + Vector3.new(0, -0.5, 0)
                    end
                    
                    local screenPos, onScreen = camera:WorldToViewportPoint(predictedPosition)
                    if onScreen then
                        local distance = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                        if distance < shortestDistance then
                            shortestDistance = distance
                            closestPlayer = player
                            closestPart = part
                            Engine.Cache.LastTargetPosition = predictedPosition
                            Engine.Cache.LastTargetVelocity = velocity
                        end
                    end
                end
            end
        end
    end
    
    return closestPlayer, closestPart
end

local function InterceptRemoteCall(remote, method, args)
    if not Engine.Flags.SilentAim then return args end
    
    local target, targetPart = GetClosestPlayerWithPrediction()
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
                    args = InterceptRemoteCall(self, method, args)
                elseif self:IsA("RemoteFunction") and method == "InvokeServer" then
                    args = InterceptRemoteCall(self, method, args)
                end
            end
            
            return oldNamecall(self, unpack(args))
        end)
    end
end)

-- ============================================================================
-- [3. МОДУЛЬ: АНТИ-ГРАБ С ВОЗВРАТОМ ПОЗИЦИИ]
-- ============================================================================

local function SetupAntiGrab(char)
    if not char then return end
    
    local function OnChildAdded(child)
        if not Engine.Flags.InstantGrabBreak then return end
        
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
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                Engine.Cache.SavedPosition = root.CFrame
            end
            
            pcall(function()
                child:Destroy()
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.PlatformStand = false
                    hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                end
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                        part.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                    end
                end
            end)
        end
    end
    
    local connection = char.ChildAdded:Connect(OnChildAdded)
    table.insert(Engine.Cache.Connections, connection)
end

SafeConnect(RunService.Heartbeat, function()
    if not Engine.Flags.InstantGrabBreak then return end
    
    local char = lp.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    local velocity = root.AssemblyLinearVelocity
    if velocity.Magnitude > 50 and Engine.Cache.SavedPosition then
        root.CFrame = Engine.Cache.SavedPosition
        root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.PlatformStand = false
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end
end)

if lp.Character then
    SetupAntiGrab(lp.Character)
end

SafeConnect(lp.CharacterAdded, function(char)
    task.wait(0.2)
    SetupAntiGrab(char)
end)

-- ============================================================================
-- [4. МОДУЛЬ: CROWN VORTEX (СТРЕСС-ТЕСТ СЕТЕВОГО ВЛАДЕНИЯ)]
-- ============================================================================

local vortexAngle = 0
local vortexGrabbedPlayers = {}

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

local function GrabPlayer(target)
    if not target or target == lp then return end
    if not target.Character then return end
    
    local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return end
    
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
end

SafeConnect(RunService.Heartbeat, function()
    if not Engine.Flags.CrownVortex then
        for _, player in ipairs(Engine.Cache.VortexPlayers) do
            if player and player.Character then
                local root = player.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    root.AssemblyLinearVelocity = camera.CFrame.LookVector * 2000000
                end
            end
        end
        Engine.Cache.VortexPlayers = {}
        vortexGrabbedPlayers = {}
        vortexAngle = 0
        return
    end
    
    local char = lp.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    vortexAngle = vortexAngle + 0.08
    
    local newList = {}
    for _, player in ipairs(Engine.Cache.VortexPlayers) do
        if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(newList, player)
        end
    end
    Engine.Cache.VortexPlayers = newList
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player == lp then continue end
        if not player.Character then continue end
        
        local found = false
        for _, p in ipairs(Engine.Cache.VortexPlayers) do
            if p == player then found = true break end
        end
        
        if not found then
            GrabPlayer(player)
            table.insert(Engine.Cache.VortexPlayers, player)
            task.wait(0.05)
        end
    end
    
    local count = #Engine.Cache.VortexPlayers
    local height = Engine.Flags.VortexHeight or 25
    local radius = Engine.Flags.VortexRadius or 8
    
    for i, player in ipairs(Engine.Cache.VortexPlayers) do
        if player and player.Character then
            local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
            if targetRoot then
                local angle = vortexAngle + (i / count) * math.pi * 2
                local targetPos = root.Position + Vector3.new(
                    math.cos(angle) * radius,
                    height,
                    math.sin(angle) * radius
                )
                
                targetRoot.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                targetRoot.CFrame = CFrame.new(targetPos, root.Position)
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

-- ============================================================================
-- [5. МОДУЛЬ: ТЕКСТУРНЫЙ АУДИТ (ОПТИМИЗАЦИЯ РЕНДЕРИНГА)]
-- ============================================================================

local function ExecuteTextureAudit(char)
    if not char then return end
    if Engine.Cache.TextureAuditProcessed[char] then return end
    Engine.Cache.TextureAuditProcessed[char] = true
    
    for _, child in ipairs(char:GetDescendants()) do
        if child:IsA("Accessory") or child:IsA("Shirt") or child:IsA("Pants") or child:IsA("Clothing") then
            pcall(function() child:Destroy() end)
        end
        
        if child:IsA("BasePart") then
            child.Material = Enum.Material.SmoothPlastic
            child.Color = Color3.fromRGB(255, 240, 220)
            if child:FindFirstChildOfClass("Texture") then
                pcall(function() child:FindFirstChildOfClass("Texture"):Destroy() end)
            end
            if child:FindFirstChildOfClass("Decal") then
                pcall(function() child:FindFirstChildOfClass("Decal"):Destroy() end)
            end
        end
        
        if child:IsA("Accessory") then
            pcall(function() child:Destroy() end)
        end
    end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        for _, clothing in ipairs(hum:GetChildren()) do
            if clothing:IsA("Clothing") then
                pcall(function() clothing:Destroy() end)
            end
        end
    end
end

SafeConnect(RunService.Heartbeat, function()
    if Engine.Flags.TextureAudit then
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character then
                task.spawn(function() ExecuteTextureAudit(player.Character) end)
            end
        end
    else
        table.clear(Engine.Cache.TextureAuditProcessed)
    end
end)

-- ============================================================================
-- [6. МОДУЛЬ: ESP (ОТЛАДОЧНАЯ ВИЗУАЛИЗАЦИЯ ГЕОМЕТРИИ)]
-- ============================================================================

local ESPGui = Instance.new("ScreenGui")
ESPGui.Name = "Sylent_ESP_Core"
ESPGui.ResetOnSpawn = false
pcall(function() ESPGui.Parent = CoreGui end)
if not ESPGui.Parent then ESPGui.Parent = lp:WaitForChild("PlayerGui") end

local function CreateESP(player)
    if player == lp then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "Sylent_ESP_Highlight_" .. player.Name
    highlight.FillColor = Color3.fromRGB(0, 255, 240)
    highlight.OutlineColor = Color3.fromRGB(255, 0, 128)
    highlight.FillTransparency = 0.5
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Adornee = player.Character
    highlight.Enabled = false
    highlight.Parent = ESPGui
    Engine.Cache.EspHighlights[player] = highlight
    
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = Color3.fromRGB(0, 255, 240)
    box.Thickness = Engine.Flags.ESP_BoxThickness or 2
    box.Filled = false
    box.Transparency = Engine.Flags.ESP_BoxTransparency or 0.8
    
    local tracer = Drawing.new("Line")
    tracer.Visible = false
    tracer.Color = Color3.fromRGB(255, 0, 128)
    tracer.Thickness = Engine.Flags.ESP_TracerThickness or 1.5
    tracer.Transparency = Engine.Flags.ESP_TracerTransparency or 0.9
    
    local name = Drawing.new("Text")
    name.Visible = false
    name.Color = Color3.fromRGB(255, 255, 255)
    name.Size = 14
    name.Center = true
    name.Outline = true
    name.OutlineColor = Color3.fromRGB(0, 0, 0)
    
    local healthBar = Drawing.new("Line")
    healthBar.Visible = false
    healthBar.Color = Color3.fromRGB(0, 255, 130)
    healthBar.Thickness = 2.5
    
    Engine.Cache.EspBoxes[player.UserId] = box
    Engine.Cache.EspTracers[player.UserId] = tracer
    Engine.Cache.EspNames[player.UserId] = name
    Engine.Cache.EspHealth[player.UserId] = healthBar
    
    local connection
    connection = RunService.RenderStepped:Connect(function()
        if not Engine.Loaded then
            box:Destroy()
            tracer:Destroy()
            name:Destroy()
            healthBar:Destroy()
            if highlight then highlight:Destroy() end
            connection:Disconnect()
            return
        end
        
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        
        if Engine.Flags.ESP_Players and char then
            highlight.Enabled = true
            highlight.Adornee = char
        else
            highlight.Enabled = false
        end
        
        if not char or not hum or hum.Health <= 0 then
            box.Visible = false
            tracer.Visible = false
            name.Visible = false
            healthBar.Visible = false
            return
        end
        
        local minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge
        local hasValidParts = false
        
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                local screenPos, onScreen = camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    hasValidParts = true
                    minX = math.min(minX, screenPos.X)
                    minY = math.min(minY, screenPos.Y)
                    maxX = math.max(maxX, screenPos.X)
                    maxY = math.max(maxY, screenPos.Y)
                end
            end
        end
        
        if not hasValidParts then
            box.Visible = false
            tracer.Visible = false
            name.Visible = false
            healthBar.Visible = false
            return
        end
        
        local centerX = (minX + maxX) / 2
        local centerY = (minY + maxY) / 2
        local width = maxX - minX
        local height = maxY - minY
        local viewportSize = camera.ViewportSize
        local inset = GuiService:GetGuiInset()
        local exactCenterX = viewportSize.X / 2
        local exactCenterY = (viewportSize.Y - inset.Y) / 2
        
        if Engine.Flags.ESP_Boxes then
            box.Size = Vector2.new(width + 4, height + 4)
            box.Position = Vector2.new(minX - 2, minY - 2)
            box.Visible = true
        else
            box.Visible = false
        end
        
        if Engine.Flags.ESP_Tracers then
            tracer.From = Vector2.new(exactCenterX, exactCenterY)
            tracer.To = Vector2.new(centerX, centerY)
            tracer.Visible = true
        else
            tracer.Visible = false
        end
        
        if Engine.Flags.ESP_Names then
            name.Text = player.DisplayName .. " (@" .. player.Name .. ")"
            name.Position = Vector2.new(centerX, minY - 16)
            name.Visible = true
        else
            name.Visible = false
        end
        
        if Engine.Flags.ESP_Health then
            local healthPercent = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
            local barHeight = height * healthPercent
            healthBar.From = Vector2.new(minX - 8, maxY)
            healthBar.To = Vector2.new(minX - 8, maxY - barHeight)
            healthBar.Color = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)
            healthBar.Visible = true
        else
            healthBar.Visible = false
        end
    end)
    table.insert(Engine.Cache.Connections, connection)
end

Players.PlayerAdded:Connect(CreateESP)
for _, p in ipairs(Players:GetPlayers()) do CreateESP(p) end

-- ============================================================================
-- [7. МОДУЛЬ: УПРАВЛЕНИЕ ФИЗИЧЕСКИМИ ПАРАМЕТРАМИ (FLY, SPEED, TELEPORT)]
-- ============================================================================

SafeConnect(RunService.Heartbeat, function()
    local char = lp.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        if Engine.Flags.WalkSpeedEnabled then
            hum.WalkSpeed = Engine.Flags.WalkSpeedValue
        end
        if Engine.Flags.JumpPowerEnabled then
            hum.JumpPower = Engine.Flags.JumpPowerValue
        end
    end
end)

SafeConnect(RunService.Stepped, function()
    local char = lp.Character
    if not char then return end
    if Engine.Flags.Noclip then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

SafeConnect(RunService.Heartbeat, function()
    local char = lp.Character
    if Engine.Flags.AntiFling and char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
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
            end
        end
    end
end)

local flyBodyVelocity = nil

SafeConnect(RunService.RenderStepped, function()
    local char = lp.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    
    if Engine.Flags.Fly and root and hum then
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
        
    elseif flyBodyVelocity then
        flyBodyVelocity:Destroy()
        flyBodyVelocity = nil
        if hum then
            hum.PlatformStand = false
        end
        if root then
            root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        end
    end
end)

SafeConnect(UserInputService.JumpRequest, function()
    if Engine.Flags.InfiniteJump then
        local char = lp.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

SafeConnect(RunService.RenderStepped, function()
    local stretch = Engine.Flags.AspectRatioStretch or 1.0
    if stretch ~= 1.0 then
        camera.FieldOfView = math.clamp(70 * stretch, 35, 140)
    end
end)

SafeConnect(RunService.RenderStepped, function()
    if Engine.Flags.ForceThirdPerson then
        lp.CameraMode = Enum.CameraMode.Classic
        lp.CameraMaxZoomDistance = 128
        lp.CameraMinZoomDistance = 10
    end
end)

-- ============================================================================
-- [8. МОДУЛЬ: ВРЕДИТЕЛЬСТВО И ТРОЛЛИНГ]
-- ============================================================================

local function ExecuteFling(target)
    if not target or target == lp then return end
    local char = lp.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local tchar = target.Character
    local troot = tchar and tchar:FindFirstChild("HumanoidRootPart")
    
    if root and troot then
        local oldCFrame = root.CFrame
        local flingActive = true
        
        local tempNoclip = RunService.Stepped:Connect(function()
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
        
        local flingLoop = RunService.Heartbeat:Connect(function()
            if not tchar or not troot or not troot.Parent or not flingActive then return end
            root.AssemblyLinearVelocity = Vector3.new(0, 3000000, 0)
            root.AssemblyAngularVelocity = Vector3.new(3000000, 3000000, 3000000)
            root.CFrame = troot.CFrame * CFrame.new(math.random(-2, 2)/10, 0, math.random(-2, 2)/10)
        end)
        
        task.delay(1.5, function()
            flingActive = false
            tempNoclip:Disconnect()
            flingLoop:Disconnect()
            task.wait(0.02)
            if root then
                root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                root.CFrame = oldCFrame
            end
        end)
    end
end

SafeConnect(RunService.Heartbeat, function()
    if Engine.Flags.FlingAura then
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= lp and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local targetRoot = player.Character.HumanoidRootPart
                    local dist = (root.Position - targetRoot.Position).Magnitude
                    if dist <= 18 then
                        ExecuteFling(player)
                    end
                end
            end
        end
    end
end)

SafeConnect(UserInputService.InputBegan, function(input, processed)
    if not processed and Engine.Flags.ClickFling and input.UserInputType == Enum.UserInputType.MouseButton1 then
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
    end
end)

local orbitAngle = 0
SafeConnect(RunService.Heartbeat, function()
    if Engine.Flags.OrbitPlayer and Engine.Flags.TargetPlayer ~= "" then
        local target = FindPlayerByName(Engine.Flags.TargetPlayer)
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local tchar = target and target.Character
        local troot = tchar and tchar:FindFirstChild("HumanoidRootPart")
        
        if root and troot then
            orbitAngle = orbitAngle + (Engine.Flags.OrbitSpeed / 50)
            local offset = Vector3.new(
                math.cos(orbitAngle) * Engine.Flags.OrbitDistance,
                0,
                math.sin(orbitAngle) * Engine.Flags.OrbitDistance
            )
            root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            root.CFrame = CFrame.new(troot.Position + offset, troot.Position)
        end
    end
end)

local function RunMassWeld()
    local char = lp.Character
    if not char then return end
    for _, part in ipairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") and not part.Anchored and not part:IsDescendantOf(char) then
            pcall(function()
                local weld = Instance.new("WeldConstraint")
                weld.Part0 = part
                weld.Part1 = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChildOfClass("Part")
                weld.Parent = part
                part.CanCollide = false
            end)
        end
    end
end

SafeConnect(RunService.Heartbeat, function()
    if Engine.Flags.LobbyFreeze then
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            for i = 1, 40 do
                root.CFrame = root.CFrame * CFrame.new(0, 999999, 0)
                root.CFrame = root.CFrame * CFrame.new(0, -999999, 0)
            end
        end
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

-- ============================================================================
-- [9. МОДУЛЬ: МЕТАТАБЛИЦА (BYPASS)]
-- ============================================================================

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

-- ============================================================================
-- [10. МОДУЛЬ: UI (NEO-GLOW CYBERPUNK INTERFACE)]
-- ============================================================================

local CyberUI = {}
CyberUI.__index = CyberUI

local CYBER_THEME = {
    MainBg       = Color3.fromRGB(10, 11, 16),
    PanelBg      = Color3.fromRGB(18, 20, 28),
    BorderCyan   = Color3.fromRGB(0, 255, 240),
    BorderPink   = Color3.fromRGB(255, 0, 128),
    MainText     = Color3.fromRGB(255, 255, 255),
    DimText      = Color3.fromRGB(130, 135, 150),
    AccentGlow   = Color3.fromRGB(0, 255, 200),
    ToggleOff    = Color3.fromRGB(40, 43, 56)
}

local UI_EASE = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function tweenUI(obj, info, props)
    local t = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

function CyberUI.new(config)
    local self = setmetatable({}, CyberUI)
    self.Title = config.Title or "SYLENT ENGINE"
    self.Version = config.Version or "v1.0"
    self.ActiveTab = nil
    self.Tabs = {}
    self:BuildCoreFrame()
    return self
end

function CyberUI:BuildCoreFrame()
    local screen = Instance.new("ScreenGui")
    screen.Name = "Sylent_CyberPro_" .. HttpService:GenerateGUID(false):sub(1,6)
    screen.ResetOnSpawn = false
    screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() screen.Parent = CoreGui end)
    if not screen.Parent then screen.Parent = lp:WaitForChild("PlayerGui") end
    self.Screen = screen

    local launcher = Instance.new("TextButton")
    launcher.Size = UDim2.new(0, 55, 0, 55)
    launcher.Position = UDim2.new(0.02, 0, 0.2, 0)
    launcher.BackgroundColor3 = CYBER_THEME.PanelBg
    launcher.Text = "⚡"
    launcher.TextColor3 = CYBER_THEME.BorderCyan
    launcher.Font = Enum.Font.FredokaOne
    launcher.TextSize = 25
    launcher.Parent = screen

    local lCor = Instance.new("UICorner")
    lCor.CornerRadius = UDim.new(1, 0)
    lCor.Parent = launcher

    local lStroke = Instance.new("UIStroke")
    lStroke.Color = CYBER_THEME.BorderCyan
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
    frame.BackgroundColor3 = CYBER_THEME.MainBg
    frame.ClipsDescendants = true
    frame.Visible = false
    frame.Parent = screen
    self.Frame = frame

    local fCor = Instance.new("UICorner")
    fCor.CornerRadius = UDim.new(0, 12)
    fCor.Parent = frame

    local fStroke = Instance.new("UIStroke")
    fStroke.Color = CYBER_THEME.BorderPink
    fStroke.Thickness = 2
    fStroke.Parent = frame

    local sidebar = Instance.new("Frame")
    sidebar.Size = UDim2.new(0, 180, 1, 0)
    sidebar.BackgroundColor3 = CYBER_THEME.PanelBg
    sidebar.Parent = frame

    local sCor = Instance.new("UICorner")
    sCor.CornerRadius = UDim.new(0, 12)
    sCor.Parent = sidebar

    local sStroke = Instance.new("UIStroke")
    sStroke.Color = CYBER_THEME.BorderCyan
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
    title.TextColor3 = CYBER_THEME.MainText
    title.Font = Enum.Font.FredokaOne
    title.TextSize = 22
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.BackgroundTransparency = 1
    title.Parent = header

    local version = Instance.new("TextLabel")
    version.Size = UDim2.new(1, -20, 0, 18)
    version.Position = UDim2.new(0, 15, 0, 42)
    version.Text = self.Version
    version.TextColor3 = CYBER_THEME.BorderCyan
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
            tweenUI(launcher, UI_EASE, {Rotation = 90, TextColor3 = CYBER_THEME.BorderPink})
            lStroke.Color = CYBER_THEME.BorderPink
        else
            tweenUI(frame, UI_EASE, {
                Size = UDim2.new(0, 0, 0, 0),
                Position = launcher.Position
            })
            tweenUI(launcher, UI_EASE, {Rotation = 0, TextColor3 = CYBER_THEME.BorderCyan})
            lStroke.Color = CYBER_THEME.BorderCyan
            task.wait(0.25)
            if not menuState then frame.Visible = false end
        end
    end)
end

function CyberUI:CreateTab(name)
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = CYBER_THEME.BorderCyan
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
    tabBtn.BackgroundColor3 = CYBER_THEME.MainBg
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
    tbLabel.TextColor3 = CYBER_THEME.DimText
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
        secText.TextColor3 = CYBER_THEME.BorderCyan
        secText.Font = Enum.Font.SourceSansBold
        secText.TextSize = 12
        secText.TextXAlignment = Enum.TextXAlignment.Left
        secText.BackgroundTransparency = 1
        secText.Parent = page
    end

    function ElementAPI:AddToggle(cfg)
        local card = Instance.new("Frame")
        card.Size = UDim2.new(0.96, 0, 0, 50)
        card.BackgroundColor3 = CYBER_THEME.PanelBg
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
        titleL.TextColor3 = CYBER_THEME.MainText
        titleL.Font = Enum.Font.SourceSansBold
        titleL.TextSize = 15
        titleL.TextXAlignment = Enum.TextXAlignment.Left
        titleL.BackgroundTransparency = 1
        titleL.Parent = card

        local descL = Instance.new("TextLabel")
        descL.Size = UDim2.new(0.7, 0, 0, 18)
        descL.Position = UDim2.new(0, 12, 0, 24)
        descL.Text = cfg.Description or ""
        descL.TextColor3 = CYBER_THEME.DimText
        descL.Font = Enum.Font.SourceSans
        descL.TextSize = 12
        descL.TextXAlignment = Enum.TextXAlignment.Left
        descL.BackgroundTransparency = 1
        descL.Parent = card

        local swBtn = Instance.new("TextButton")
        swBtn.Size = UDim2.new(0, 44, 0, 22)
        swBtn.Position = UDim2.new(0.96, -44, 0.5, -11)
        swBtn.BackgroundColor3 = CYBER_THEME.ToggleOff
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
                tweenUI(swBtn, TweenInfo.new(0.2), {BackgroundColor3 = CYBER_THEME.BorderCyan})
                tweenUI(node, TweenInfo.new(0.2), {Position = UDim2.new(1, -19, 0.5, -8)})
            else
                tweenUI(swBtn, TweenInfo.new(0.2), {BackgroundColor3 = CYBER_THEME.ToggleOff})
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
        card.BackgroundColor3 = CYBER_THEME.PanelBg
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
        titleL.TextColor3 = CYBER_THEME.MainText
        titleL.Font = Enum.Font.SourceSansBold
        titleL.TextSize = 15
        titleL.TextXAlignment = Enum.TextXAlignment.Left
        titleL.BackgroundTransparency = 1
        titleL.Parent = card

        local valL = Instance.new("TextLabel")
        valL.Size = UDim2.new(0.25, 0, 0, 22)
        valL.Position = UDim2.new(0.7, 0, 0, 6)
        valL.Text = tostring(cfg.Default)
        valL.TextColor3 = CYBER_THEME.BorderPink
        valL.Font = Enum.Font.FredokaOne
        valL.TextSize = 14
        valL.TextXAlignment = Enum.TextXAlignment.Right
        valL.BackgroundTransparency = 1
        valL.Parent = card

        local track = Instance.new("TextButton")
        track.Size = UDim2.new(0.92, 0, 0, 6)
        track.Position = UDim2.new(0.04, 0, 0.72, 0)
        track.BackgroundColor3 = CYBER_THEME.ToggleOff
        track.Text = ""
        track.Parent = card

        local tCor = Instance.new("UICorner")
        tCor.CornerRadius = UDim.new(1, 0)
        tCor.Parent = track

        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((cfg.Default - cfg.Min)/(cfg.Max - cfg.Min), 0, 1, 0)
        fill.BackgroundColor3 = CYBER_THEME.BorderPink
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
        card.BackgroundColor3 = CYBER_THEME.PanelBg
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
        titleL.TextColor3 = CYBER_THEME.MainText
        titleL.Font = Enum.Font.SourceSansBold
        titleL.TextSize = 15
        titleL.TextXAlignment = Enum.TextXAlignment.Left
        titleL.BackgroundTransparency = 1
        titleL.Parent = card

        local tBox = Instance.new("TextBox")
        tBox.Size = UDim2.new(0.54, 0, 0.68, 0)
        tBox.Position = UDim2.new(0.42, 0, 0.16, 0)
        tBox.BackgroundColor3 = CYBER_THEME.MainBg
        tBox.Text = cfg.Default or ""
        tBox.TextColor3 = CYBER_THEME.MainText
        tBox.PlaceholderText = cfg.Placeholder or "Ввод данных..."
        tBox.PlaceholderColor3 = CYBER_THEME.DimText
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
        btn.BackgroundColor3 = CYBER_THEME.BorderCyan
        btn.Text = cfg.Name
        btn.TextColor3 = CYBER_THEME.MainBg
        btn.Font = Enum.Font.SourceSansBold
        btn.TextSize = 15
        btn.AutoButtonColor = true
        btn.Parent = page

        local bCor = Instance.new("UICorner")
        bCor.CornerRadius = UDim.new(0, 8)
        bCor.Parent = btn

        local bGrad = Instance.new("UIGradient")
        bGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, CYBER_THEME.BorderCyan),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 150, 255))
        })
        bGrad.Parent = btn

        btn.MouseButton1Click:Connect(function()
            pcall(cfg.Callback)
        end)
    end

    return ElementAPI
end

function CyberUI:SelectTab(tabData)
    if self.ActiveTab then
        self.ActiveTab.Page.Visible = false
        tweenUI(self.ActiveTab.Button, UI_EASE, {BackgroundTransparency = 1})
        tweenUI(self.ActiveTab.Label, UI_EASE, {TextColor3 = CYBER_THEME.DimText})
    end
    self.ActiveTab = tabData
    tabData.Page.Visible = true
    tweenUI(tabData.Button, UI_EASE, {BackgroundTransparency = 0.88})
    tweenUI(tabData.Label, UI_EASE, {TextColor3 = CYBER_THEME.BorderCyan})
end

local SylentUI = CyberUI.new({ Title = "SYLENT ENGINE", Version = "v1.0 • ULTIMATE SUITE" })

-- ============================================================================
-- [11. ИНИЦИАЛИЗАЦИЯ ВКЛАДОК И КОМПЛЕКТАЦИЯ UI]
-- ============================================================================

-- Вкладка: ДВИЖЕНИЕ
local movementTab = SylentUI:CreateTab("Движение")
movementTab:AddSection("Контроль Физических Свойств")
movementTab:AddToggle({
    Name = "Активировать WalkSpeed",
    Description = "Блокирует скорость перемещения вашего персонажа",
    Default = Engine.Flags.WalkSpeedEnabled,
    Callback = function(st) Engine.Flags.WalkSpeedEnabled = st end
})
movementTab:AddSlider({
    Name = "Кастомная Скорость",
    Min = 16,
    Max = 300,
    Default = Engine.Flags.WalkSpeedValue,
    Callback = function(val) Engine.Flags.WalkSpeedValue = val end
})
movementTab:AddToggle({
    Name = "Активировать JumpPower",
    Description = "Позволяет изменять высоту прыжка без ограничений",
    Default = Engine.Flags.JumpPowerEnabled,
    Callback = function(st) Engine.Flags.JumpPowerEnabled = st end
})
movementTab:AddSlider({
    Name = "Сила Прыжка",
    Min = 50,
    Max = 400,
    Default = Engine.Flags.JumpPowerValue,
    Callback = function(val) Engine.Flags.JumpPowerValue = val end
})
movementTab:AddSection("Продвинутая Акробатика")
movementTab:AddToggle({
    Name = "Бесконечный Прыжок",
    Description = "Позволяет отталкиваться от воздуха неограниченно",
    Default = Engine.Flags.InfiniteJump,
    Callback = function(st) Engine.Flags.InfiniteJump = st end
})
movementTab:AddToggle({
    Name = "Режим Полета (Fly)",
    Description = "Плавное движение по направлению камеры",
    Default = Engine.Flags.Fly,
    Callback = function(st) Engine.Flags.Fly = st end
})
movementTab:AddSlider({
    Name = "Скорость Полета",
    Min = 20,
    Max = 300,
    Default = Engine.Flags.FlySpeed,
    Callback = function(val) Engine.Flags.FlySpeed = val end
})
movementTab:AddToggle({
    Name = "Проход Сквозь Стены (Noclip)",
    Description = "Отключает обработку коллизий для всех частей тела",
    Default = Engine.Flags.Noclip,
    Callback = function(st) Engine.Flags.Noclip = st end
})
movementTab:AddButton({
    Name = "Подъем (Ascend Fly)",
    Callback = function()
        Engine.Cache.FlyUp = true
        task.delay(0.2, function() Engine.Cache.FlyUp = false end)
    end
})
movementTab:AddButton({
    Name = "Спуск (Descend Fly)",
    Callback = function()
        Engine.Cache.FlyDown = true
        task.delay(0.2, function() Engine.Cache.FlyDown = false end)
    end
})
movementTab:AddToggle({
    Name = "Анти-Флинг Физики",
    Description = "Замораживает угловую скорость для защиты от отбрасывания",
    Default = Engine.Flags.AntiFling,
    Callback = function(st) Engine.Flags.AntiFling = st end
})
movementTab:AddSection("Растяг Экрана (Aspect Ratio)")
movementTab:AddSlider({
    Name = "Растяг Экрана",
    Min = 50,
    Max = 250,
    Default = 100,
    Callback = function(val)
        Engine.Flags.AspectRatioStretch = val / 100
    end
})

-- Вкладка: FTAP БОЙ
local ftapCombatTab = SylentUI:CreateTab("FTAP Бой")
ftapCombatTab:AddSection("🔴 СИСТЕМЫ НАВЕДЕНИЯ")
ftapCombatTab:AddToggle({
    Name = "Сайлент Аим (Remote Injection)",
    Description = "Инжектирует вектор цели в RemoteEvent/RemoteFunction вызовы",
    Default = Engine.Flags.SilentAim,
    Callback = function(st) Engine.Flags.SilentAim = st end
})
ftapCombatTab:AddSlider({
    Name = "Успеваемость Аима (Prediction)",
    Min = 1,
    Max = 10,
    Default = 5,
    Callback = function(val)
        Engine.Flags.SilentAimPrediction = val / 10
    end
})

local partSelectionFrame = Instance.new("Frame")
partSelectionFrame.Size = UDim2.new(0.96, 0, 0, 40)
partSelectionFrame.BackgroundTransparency = 1
partSelectionFrame.Parent = ftapCombatTab.Page

local partLayout = Instance.new("UIListLayout")
partLayout.FillDirection = Enum.FillDirection.Horizontal
partLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
partLayout.Padding = UDim.new(0, 6)
partLayout.Parent = partSelectionFrame

local partNames = {"Head", "Torso", "HumanoidRootPart"}
local partButtons = {}

for _, partName in ipairs(partNames) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 85, 0, 30)
    btn.Text = partName
    btn.BackgroundColor3 = CYBER_THEME.PanelBg
    btn.TextColor3 = CYBER_THEME.DimText
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 12
    btn.AutoButtonColor = false
    btn.Parent = partSelectionFrame
    
    local bCor = Instance.new("UICorner")
    bCor.CornerRadius = UDim.new(0, 6)
    bCor.Parent = btn
    
    local bStroke = Instance.new("UIStroke")
    bStroke.Color = CYBER_THEME.BorderCyan
    bStroke.Thickness = 1
    bStroke.Transparency = 0.7
    bStroke.Parent = btn
    
    if partName == Engine.Flags.SilentAimTargetPart then
        btn.BackgroundColor3 = CYBER_THEME.BorderCyan
        btn.TextColor3 = CYBER_THEME.MainBg
        bStroke.Transparency = 0
    end
    
    btn.MouseButton1Click:Connect(function()
        Engine.Flags.SilentAimTargetPart = partName
        for _, b in ipairs(partButtons) do
            b.BackgroundColor3 = CYBER_THEME.PanelBg
            b.TextColor3 = CYBER_THEME.DimText
            local stroke = b:FindFirstChildOfClass("UIStroke")
            if stroke then stroke.Transparency = 0.7 end
        end
        btn.BackgroundColor3 = CYBER_THEME.BorderCyan
        btn.TextColor3 = CYBER_THEME.MainBg
        local stroke = btn:FindFirstChildOfClass("UIStroke")
        if stroke then stroke.Transparency = 0 end
    end)
    
    table.insert(partButtons, btn)
end

ftapCombatTab:AddToggle({
    Name = "Отображать Круг FOV",
    Description = "Визуализация радиуса наведения",
    Default = Engine.Flags.ShowFOV,
    Callback = function(st) Engine.Flags.ShowFOV = st end
})
ftapCombatTab:AddSlider({
    Name = "Радиус FOV",
    Min = 30,
    Max = 500,
    Default = Engine.Flags.SilentAimFOV,
    Callback = function(val) Engine.Flags.SilentAimFOV = val end
})
ftapCombatTab:AddSection("🟢 HITBOX EXPANSION")
ftapCombatTab:AddToggle({
    Name = "Расширение Хитбоксов Врагов",
    Description = "Увеличивает размер всех частей тела врагов",
    Default = Engine.Flags.HitboxExpansion,
    Callback = function(st)
        Engine.Flags.HitboxExpansion = st
        if not st then
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
        end
    end
})
ftapCombatTab:AddSlider({
    Name = "Множитель Размера Хитбокса",
    Min = 2,
    Max = 20,
    Default = Engine.Flags.HitboxScale,
    Callback = function(val) Engine.Flags.HitboxScale = val end
})
ftapCombatTab:AddSection("🔵 PROXIMITY AUTO-GRAB")
ftapCombatTab:AddToggle({
    Name = "Авто-Захват Ближайшей Цели",
    Description = "Автоматически хватает игрока или предмет в радиусе",
    Default = Engine.Flags.ProximityGrab,
    Callback = function(st)
        Engine.Flags.ProximityGrab = st
        if not st then
            Engine.Cache.IsGrabbing = false
            Engine.Cache.CurrentGrabbedTarget = nil
        end
    end
})
ftapCombatTab:AddSlider({
    Name = "Радиус Авто-Захвата",
    Min = 2,
    Max = 10,
    Default = Engine.Flags.ProximityRadius,
    Callback = function(val) Engine.Flags.ProximityRadius = val end
})
ftapCombatTab:AddSection("Механика Манипуляции Телами")
ftapCombatTab:AddToggle({
    Name = "Мега-Далекий Бросок за карту",
    Description = "Прикладывает разрушительный вектор импульса к цели",
    Default = Engine.Flags.MegaThrow,
    Callback = function(st) Engine.Flags.MegaThrow = st end
})
ftapCombatTab:AddSlider({
    Name = "Сила Дальнего Броска",
    Min = 500000,
    Max = 2000000,
    Default = Engine.Flags.ThrowForce,
    Callback = function(val) Engine.Flags.ThrowForce = val end
})
ftapCombatTab:AddToggle({
    Name = "Анти-Взятие Себя (Grab Break)",
    Description = "Мгновенно уничтожает связи удержания чужих лучей",
    Default = Engine.Flags.InstantGrabBreak,
    Callback = function(st) Engine.Flags.InstantGrabBreak = st end
})
ftapCombatTab:AddSection("Контратака")
ftapCombatTab:AddToggle({
    Name = "Авто-Отброс при атаке противника",
    Description = "Уклоняется и жестко наказывает приблизившегося обидчика",
    Default = Engine.Flags.CounterAttack,
    Callback = function(st) Engine.Flags.CounterAttack = st end
})
ftapCombatTab:AddTextBox({
    Name = "Режим Наказания",
    Placeholder = "В небо / В подкарту",
    Default = Engine.Flags.CounterMode,
    Callback = function(txt) Engine.Flags.CounterMode = txt end
})
ftapCombatTab:AddSlider({
    Name = "Угол Запуска (Для режима Небо)",
    Min = 30,
    Max = 90,
    Default = Engine.Flags.CounterAngle,
    Callback = function(val) Engine.Flags.CounterAngle = val end
})

-- Вкладка: ТРОЛЛИНГ
local trollTab = SylentUI:CreateTab("Троллинг")
trollTab:AddSection("УРАГАН-КОРОНА (CROWN VORTEX)")
trollTab:AddToggle({
    Name = "Ураган-Корона",
    Description = "Захватывает всех игроков в корону над вами через игру",
    Default = Engine.Flags.CrownVortex,
    Callback = function(st)
        Engine.Flags.CrownVortex = st
        if not st then
            for _, player in ipairs(Engine.Cache.VortexPlayers) do
                if player and player.Character then
                    local root = player.Character:FindFirstChild("HumanoidRootPart")
                    if root then
                        root.AssemblyLinearVelocity = camera.CFrame.LookVector * 2000000
                    end
                end
            end
            Engine.Cache.VortexPlayers = {}
        end
    end
})
trollTab:AddSlider({
    Name = "Высота Короны",
    Min = 10,
    Max = 60,
    Default = 25,
    Callback = function(val) Engine.Flags.VortexHeight = val end
})
trollTab:AddSlider({
    Name = "Радиус Короны",
    Min = 3,
    Max = 20,
    Default = 8,
    Callback = function(val) Engine.Flags.VortexRadius = val end
})
trollTab:AddSection("Настраиваемый Список Охоты")
trollTab:AddTextBox({
    Name = "Добавить цель в Hunting List",
    Placeholder = "Имя игрока...",
    Default = "",
    Callback = function(text)
        if text ~= "" then
            local found = false
            for _, name in ipairs(Engine.Cache.HuntingList) do
                if name:lower() == text:lower() then
                    found = true
                    break
                end
            end
            if not found then
                table.insert(Engine.Cache.HuntingList, text)
                StarterGui:SetCore("SendNotification", {Title = "Система Охоты", Text = text .. " добавлен в список!", Duration = 2})
            end
        end
    end
})
trollTab:AddButton({
    Name = "Очистить Hunting List",
    Callback = function()
        table.clear(Engine.Cache.HuntingList)
        StarterGui:SetCore("SendNotification", {Title = "Система Охоты", Text = "Список целей полностью очищен!", Duration = 2})
    end
})
trollTab:AddSection("Прицельный Террор")
trollTab:AddTextBox({
    Name = "Юзернейм Жертвы",
    Placeholder = "Часть имени...",
    Default = Engine.Flags.TargetPlayer,
    Callback = function(text) Engine.Flags.TargetPlayer = text end
})
trollTab:AddButton({
    Name = "Уничтожить цель (Fling Target)",
    Callback = function()
        local t = FindPlayerByName(Engine.Flags.TargetPlayer)
        if t then ExecuteFling(t) else
            StarterGui:SetCore("SendNotification", {Title = "Внимание", Text = "Игрок не обнаружен!", Duration = 2.5})
        end
    end
})
trollTab:AddToggle({
    Name = "Режим Орбиты вокруг цели",
    Description = "Связывает позиционирование, запуская кружение",
    Default = Engine.Flags.OrbitPlayer,
    Callback = function(st) Engine.Flags.OrbitPlayer = st end
})
trollTab:AddSlider({
    Name = "Дистанция Орбиты",
    Min = 3,
    Max = 50,
    Default = Engine.Flags.OrbitDistance,
    Callback = function(val) Engine.Flags.OrbitDistance = val end
})
trollTab:AddSection("Массовые Разрушения")
trollTab:AddToggle({
    Name = "Машина: Kill All (В сиденье)",
    Description = "Использует коллизию транспорта для ликвидации сервера",
    Default = Engine.Flags.VehicleKillAll,
    Callback = function(st) Engine.Flags.VehicleKillAll = st end
})
trollTab:AddToggle({
    Name = "Аура Разрушения (Fling Aura)",
    Description = "Аннигилирует любого в радиусе 18 студов",
    Default = Engine.Flags.FlingAura,
    Callback = function(st) Engine.Flags.FlingAura = st end
})
trollTab:AddToggle({
    Name = "Click Fling (Зажать Ctrl + ЛКМ)",
    Description = "Атакует выбранную цель кликом мыши на карте",
    Default = Engine.Flags.ClickFling,
    Callback = function(st) Engine.Flags.ClickFling = st end
})
trollTab:AddButton({
    Name = "Ликвидировать Всех (Fling All)",
    Callback = function()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= lp then task.spawn(function() ExecuteFling(p) end) end
        end
    end
})
trollTab:AddButton({
    Name = "Связать Физику Сервера (Mass Weld)",
    Callback = function() RunMassWeld() end
})
trollTab:AddToggle({
    Name = "Заморозка Лобби (Lobby Freeze)",
    Description = "Штормит пакетами позиции для лага физического движка",
    Default = Engine.Flags.LobbyFreeze,
    Callback = function(st) Engine.Flags.LobbyFreeze = st end
})

-- Вкладка: ВИЗУАЛЫ
local visualsTab = SylentUI:CreateTab("Визуалы")
visualsTab:AddSection("Рендеринг ESP Линий")
visualsTab:AddToggle({
    Name = "Отображать ESP Боксы",
    Description = "Очерчивает рамки вокруг силуэтов оппонентов",
    Default = Engine.Flags.ESP_Boxes,
    Callback = function(st) Engine.Flags.ESP_Boxes = st end
})
visualsTab:AddToggle({
    Name = "Отображать Трассеры",
    Description = "Линии векторов от центра экрана к игрокам",
    Default = Engine.Flags.ESP_Tracers,
    Callback = function(st) Engine.Flags.ESP_Tracers = st end
})
visualsTab:AddToggle({
    Name = "Отображать Ники",
    Description = "Показывает Nickname и DisplayName над головами",
    Default = Engine.Flags.ESP_Names,
    Callback = function(st) Engine.Flags.ESP_Names = st end
})
visualsTab:AddToggle({
    Name = "Отображать ХП бары",
    Description = "Шкала запаса здоровья игроков",
    Default = Engine.Flags.ESP_Health,
    Callback = function(st) Engine.Flags.ESP_Health = st end
})
visualsTab:AddToggle({
    Name = "Подсветка игроков (Highlight)",
    Description = "Подсвечивает игроков сквозь стены",
    Default = Engine.Flags.ESP_Players,
    Callback = function(st) Engine.Flags.ESP_Players = st end
})
visualsTab:AddSection("Настройки ESP")
visualsTab:AddSlider({
    Name = "Толщина Бокса",
    Min = 1,
    Max = 5,
    Default = 2,
    Callback = function(val) Engine.Flags.ESP_BoxThickness = val end
})
visualsTab:AddSlider({
    Name = "Прозрачность Бокса",
    Min = 10,
    Max = 100,
    Default = 80,
    Callback = function(val) Engine.Flags.ESP_BoxTransparency = val / 100 end
})
visualsTab:AddSlider({
    Name = "Толщина Трассера",
    Min = 1,
    Max = 5,
    Default = 2,
    Callback = function(val) Engine.Flags.ESP_TracerThickness = val end
})
visualsTab:AddSlider({
    Name = "Прозрачность Трассера",
    Min = 10,
    Max = 100,
    Default = 90,
    Callback = function(val) Engine.Flags.ESP_TracerTransparency = val / 100 end
})
visualsTab:AddSection("Параметры Окружающего Мира")
visualsTab:AddToggle({
    Name = "Постоянный День (Fullbright)",
    Description = "Исключает темноту, максимизируя яркость освещения",
    Default = Engine.Flags.Fullbright,
    Callback = function(st)
        Engine.Flags.Fullbright = st
        if not st then
            Lighting.Ambient = Engine.Cache.OriginalLighting.Ambient
            Lighting.OutdoorAmbient = Engine.Cache.OriginalLighting.OutdoorAmbient
            Lighting.Brightness = Engine.Cache.OriginalLighting.Brightness
            Lighting.ClockTime = Engine.Cache.OriginalLighting.ClockTime
        end
    end
})
visualsTab:AddToggle({
    Name = "Режим Оптимизации (Potato PC)",
    Description = "Убирает тяжелые материалы/декали для повышения FPS",
    Default = Engine.Flags.PotatoPC,
    Callback = function(st)
        Engine.Flags.PotatoPC = st
        if st then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and not obj:IsDescendantOf(lp.Character) then
                    Engine.Cache.OriginalMaterials[obj] = {obj.Material, obj.Reflectance}
                    obj.Material = Enum.Material.SmoothPlastic
                    obj.Reflectance = 0
                elseif obj:IsA("Decal") or obj:IsA("Texture") then
                    obj.Transparency = 1
                end
            end
        else
            for obj, data in pairs(Engine.Cache.OriginalMaterials) do
                if obj and obj.Parent then
                    obj.Material = data[1]
                    obj.Reflectance = data[2]
                end
            end
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("Decal") or obj:IsA("Texture") then
                    obj.Transparency = 0
                end
            end
            table.clear(Engine.Cache.OriginalMaterials)
        end
    end
})
visualsTab:AddSection("Текстуры и Рендеринг")
visualsTab:AddToggle({
    Name = "Текстуры (Сброс материалов)",
    Description = "Удаляет одежду и сбрасывает материалы на SmoothPlastic",
    Default = Engine.Flags.TextureAudit,
    Callback = function(st) Engine.Flags.TextureAudit = st end
})

-- Вкладка: МИР И МАГАЗИН
local shopSystemTab = SylentUI:CreateTab("Мир & Магазин")
shopSystemTab:AddSection("Манипуляция Данными Игры")
shopSystemTab:AddToggle({
    Name = "Разблокировать весь Toy Shop",
    Description = "Подменяет статус предметов в ReplicatedStorage на купленные",
    Default = Engine.Flags.UnlockToyShop,
    Callback = function(st)
        Engine.Flags.UnlockToyShop = st
        if st then
            pcall(function()
                local shopStorage = ReplicatedStorage:FindFirstChild("ToyShopItems") or ReplicatedStorage:FindFirstChild("Items")
                if shopStorage then
                    for _, item in ipairs(shopStorage:GetChildren()) do
                        if item:IsA("BoolValue") and item.Name == "Locked" then
                            item.Value = false
                        elseif item:FindFirstChild("Locked") then
                            item.Locked.Value = false
                        end
                    end
                end
            end)
        end
    end
})
shopSystemTab:AddToggle({
    Name = "Принудительное 3-е Лицо",
    Description = "Фиксирует режим камеры и разблокирует зум",
    Default = Engine.Flags.ForceThirdPerson,
    Callback = function(st)
        Engine.Flags.ForceThirdPerson = st
        if not st then
            lp.CameraMode = Engine.Cache.OriginalCameraMode or Enum.CameraMode.Classic
            lp.CameraMaxZoomDistance = Engine.Cache.OriginalZoomDistance or 40
        end
    end
})
shopSystemTab:AddSlider({
    Name = "Изменить Угол Обзора (FOV)",
    Min = 70,
    Max = 140,
    Default = 70,
    Callback = function(val)
        Engine.Flags.CustomFOV = val
        if not Engine.Flags.AspectRatioStretch or Engine.Flags.AspectRatioStretch == 1.0 then
            camera.FieldOfView = val
        end
    end
})
shopSystemTab:AddSection("Авто-Спамер")
shopSystemTab:AddToggle({
    Name = "Рекламный Спамер в чат",
    Description = "Циклическая отправка сообщения в общий канал",
    Default = Engine.Flags.ChatSpam,
    Callback = function(st) Engine.Flags.ChatSpam = st end
})
shopSystemTab:AddTextBox({
    Name = "Текст сообщения",
    Placeholder = "Пишите строку здесь...",
    Default = Engine.Flags.ChatSpamMessage,
    Callback = function(text) Engine.Flags.ChatSpamMessage = text end
})

-- Вкладка: ПРОФИЛЬ
local profileTab = SylentUI:CreateTab("Профиль")
profileTab:AddSection("Информация о вашей учетной записи")
local profCard = Instance.new("Frame")
profCard.Size = UDim2.new(0.96, 0, 0, 270)
profCard.BackgroundColor3 = CYBER_THEME.PanelBg
profCard.Parent = profileTab.Page
local prCor = Instance.new("UICorner")
prCor.CornerRadius = UDim.new(0, 10)
prCor.Parent = profCard
local prStroke = Instance.new("UIStroke")
prStroke.Color = CYBER_THEME.BorderCyan
prStroke.Thickness = 1
prStroke.Parent = profCard
local pHeadImg = Instance.new("ImageLabel")
pHeadImg.Size = UDim2.new(0, 90, 0, 90)
pHeadImg.Position = UDim2.new(0.5, -45, 0, 15)
pHeadImg.BackgroundColor3 = CYBER_THEME.MainBg
pHeadImg.Image = "rbxasset://textures/ui/Guideline.png"
pHeadImg.Parent = profCard
local phCor = Instance.new("UICorner")
phCor.CornerRadius = UDim.new(1, 0)
phCor.Parent = pHeadImg
local phStroke = Instance.new("UIStroke")
phStroke.Color = CYBER_THEME.BorderPink
phStroke.Thickness = 2
phStroke.Parent = pHeadImg
local vpFrame = Instance.new("ViewportFrame")
vpFrame.Size = UDim2.new(0, 100, 0, 100)
vpFrame.Position = UDim2.new(0.05, 0, 0.5, -50)
vpFrame.BackgroundTransparency = 1
vpFrame.Parent = profCard
local vpCamera = Instance.new("Camera")
vpFrame.CurrentCamera = vpCamera
vpCamera.Parent = vpFrame
task.spawn(function()
    while task.wait(2) do
        if Engine.Loaded and lp.Character then
            vpFrame:ClearAllChildren()
            lp.Character.Archivable = true
            local clone = lp.Character:Clone()
            clone.Parent = vpFrame
            local hrp = clone:FindFirstChild("HumanoidRootPart")
            if hrp then
                vpCamera.CFrame = CFrame.new(hrp.Position + Vector3.new(0, 1, 6), hrp.Position + Vector3.new(0, 0.5, 0))
            end
        end
    end
end)
local pNameLabel = Instance.new("TextLabel")
pNameLabel.Size = UDim2.new(0.6, 0, 0, 24)
pNameLabel.Position = UDim2.new(0.35, 10, 0, 115)
pNameLabel.Text = lp.DisplayName .. " (@" .. lp.Name .. ")"
pNameLabel.TextColor3 = CYBER_THEME.MainText
pNameLabel.Font = Enum.Font.SourceSansBold
pNameLabel.TextSize = 16
pNameLabel.TextXAlignment = Enum.TextXAlignment.Left
pNameLabel.BackgroundTransparency = 1
pNameLabel.Parent = profCard
local pAgeLabel = Instance.new("TextLabel")
pAgeLabel.Size = UDim2.new(0.6, 0, 0, 20)
pAgeLabel.Position = UDim2.new(0.35, 10, 0, 140)
pAgeLabel.Text = "Возраст Аккаунта: " .. tostring(lp.AccountAge) .. " дней"
pAgeLabel.TextColor3 = CYBER_THEME.DimText
pAgeLabel.Font = Enum.Font.SourceSansSemibold
pAgeLabel.TextSize = 14
pAgeLabel.TextXAlignment = Enum.TextXAlignment.Left
pAgeLabel.BackgroundTransparency = 1
pAgeLabel.Parent = profCard
local pPerfLabel = Instance.new("TextLabel")
pPerfLabel.Size = UDim2.new(0.6, 0, 0, 22)
pPerfLabel.Position = UDim2.new(0.35, 10, 0, 165)
pPerfLabel.Text = "Пинг: Расчет... | FPS: Расчет..."
pPerfLabel.TextColor3 = CYBER_THEME.BorderCyan
pPerfLabel.Font = Enum.Font.SourceSansBold
pPerfLabel.TextSize = 13
pPerfLabel.TextXAlignment = Enum.TextXAlignment.Left
pPerfLabel.BackgroundTransparency = 1
pPerfLabel.Parent = profCard
task.spawn(function()
    local uId = lp.UserId
    local content, ready = Players:GetUserThumbnailAsync(uId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
    if ready then pHeadImg.Image = content end
end)
local framesCounter = 0
SafeConnect(RunService.Heartbeat, function(dt) framesCounter = math.floor(1/dt) end)
task.spawn(function()
    while task.wait(1) do
        if Engine.Loaded then
            pcall(function()
                local png = math.floor(Stats.Network.ServerToClientPing:GetValue() * 1000)
                pPerfLabel.Text = "Пинг: " .. tostring(png) .. " ms | FPS: " .. tostring(framesCounter)
            end)
        end
    end
end)

-- Вкладка: ЯДРО
local coreConfigTab = SylentUI:CreateTab("Ядро")
coreConfigTab:AddSection("Системная Модификация")
coreConfigTab:AddToggle({
    Name = "Bypass Metatable Protection",
    Description = "Предотвращает детекты модификации параметров сервером",
    Default = Engine.Flags.BypassMetatable,
    Callback = function(st) Engine.Flags.BypassMetatable = st end
})
coreConfigTab:AddSection("Полная Выгрузка Скрипта")

local function CompleteDestruction()
    Engine.Loaded = false
    
    for _, conn in ipairs(Engine.Cache.Connections) do
        if conn.Connected then conn:Disconnect() end
    end
    table.clear(Engine.Cache.Connections)
    
    Lighting.Ambient = Engine.Cache.OriginalLighting.Ambient
    Lighting.OutdoorAmbient = Engine.Cache.OriginalLighting.OutdoorAmbient
    Lighting.Brightness = Engine.Cache.OriginalLighting.Brightness
    Lighting.ClockTime = Engine.Cache.OriginalLighting.ClockTime
    
    if SylentUI.Screen then SylentUI.Screen:Destroy() end
    if FOVGui then FOVGui:Destroy() end
    if ESPGui then ESPGui:Destroy() end
    if fovCircleDrawing then fovCircleDrawing:Destroy() end
    
    for obj, data in pairs(Engine.Cache.OriginalMaterials) do
        if obj and obj.Parent then
            obj.Material = data[1]
            obj.Reflectance = data[2]
        end
    end
    
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
    
    for _, highlight in pairs(Engine.Cache.EspHighlights) do
        if highlight then highlight:Destroy() end
    end
    table.clear(Engine.Cache.EspHighlights)
    
    pcall(function()
        lp.CameraMode = Engine.Cache.OriginalCameraMode or Enum.CameraMode.Classic
        lp.CameraMaxZoomDistance = Engine.Cache.OriginalZoomDistance or 40
    end)
    
    pcall(function()
        local hum = lp.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.PlatformStand = false
            hum.WalkSpeed = 16
            hum.JumpPower = 50
        end
    end)
    
    table.clear(Engine.Cache.TextureAuditProcessed)
    _G.SylentEngine = nil
    print("[SYLENT Engine]: Скрипт выгружен. Все соединения очищены. Память освобождена.")
end

coreConfigTab:AddButton({
    Name = "Выгрузить Скрипт (Destroy)",
    Callback = function() CompleteDestruction() end
})

-- ============================================================================
-- [12. ФИНАЛЬНАЯ ИНИЦИАЛИЗАЦИЯ]
-- ============================================================================

SafeConnect(lp.CharacterAdded, function(char)
    local hum = char:WaitForChild("Humanoid", 15)
    if hum then
        task.wait(0.5)
        if Engine.Flags.WalkSpeedEnabled then hum.WalkSpeed = Engine.Flags.WalkSpeedValue end
        if Engine.Flags.JumpPowerEnabled then hum.JumpPower = Engine.Flags.JumpPowerValue end
    end
    SetupAntiGrab(char)
end)

SafeConnect(RunService.LightingChanged, function()
    if Engine.Flags.Fullbright then
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        Lighting.Brightness = 3
        Lighting.ClockTime = 14
    end
end)

print("[SYLENT Engine v1.0]: Полный комплекс загружен. Все 7 модулей активны. UI готов к работе.")
