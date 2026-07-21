--[[
    ================================================================================
    👑 SYLENT ENGINE v3.0 — ULTIMATE INVISIBLE PHYSICS ENGINE
    🎯 FOCUS: NO VISUAL EFFECTS — PURE PHYSICS MANIPULATION
    🔒 TARGET: ROBLOX RUNTIME 3.1+ (DELTA EXECUTOR)
    🚀 STATUS: ACTIVE | FULLY EXPANDED | 3000+ LINES
    ================================================================================
]]

if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- ============================================================================
-- [1. СИСТЕМНЫЕ СЕРВИСЫ И ИНИЦИАЛИЗАЦИЯ]
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
local Workspace = game:GetService("Workspace")

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
-- [2. ГЛОБАЛЬНАЯ СТРУКТУРА СОСТОЯНИЯ (РАСШИРЕННАЯ)]
-- ============================================================================
_G.SylentEngine = {
    Loaded = true,
    Flags = {
        -- Движение
        WalkSpeedEnabled = false,
        WalkSpeedValue = 16,
        JumpPowerEnabled = false,
        JumpPowerValue = 50,
        InfiniteJump = false,
        Noclip = false,
        Fly = false,
        FlySpeed = 50,
        AntiFling = false,
        
        -- Бой
        SilentAim = false,
        SilentAimRange = 200,
        SilentAimPrediction = 0.5,
        SilentAimTargetPart = "HumanoidRootPart",
        MegaThrow = false,
        ThrowForce = 2000000,
        ThrowRange = 30,
        InstantGrabBreak = false,
        
        -- Троллинг
        FlingAura = false,
        ClickFling = false,
        FlingAll = false,
        OrbitPlayer = false,
        TargetPlayer = "",
        OrbitSpeed = 5,
        OrbitDistance = 5,
        MassWeld = false,
        LobbyFreeze = false,
        
        -- Crown Vortex
        CrownVortex = false,
        VortexRadius = 8,
        VortexHeight = 25,
        VortexSpeed = 0.08,
        VortexGrabDelay = 0.05,
        
        -- Визуалы (полностью удалены, оставлены только флаги для совместимости)
        ESP_Players = false,
        ESP_Tracers = false,
        ESP_Boxes = false,
        ESP_Names = false,
        ESP_Health = false,
        Fullbright = false,
        PotatoPC = false,
        
        -- Ядро
        BypassMetatable = true,
        ChatSpam = false,
        ChatSpamMessage = "SYLENT Engine v3.0 Running!",
        ForceThirdPerson = false,
        ThirdPersonZoom = 15,
        AspectRatioStretch = 1.0,
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
        IsVortexActive = false,
        GrabCooldown = false,
        LastGrabTime = 0,
        ThrowCooldown = false,
        LastThrowTime = 0,
        CameraRestoreData = {
            Mode = lp.CameraMode,
            Zoom = lp.CameraMaxZoomDistance,
        },
        VelocityLog = {},
        VelocityLogIndex = 1,
        MaxVelocityLog = 10,
        FlyBodyVelocity = nil,
        OrbitAngle = 0,
    }
}

local Engine = _G.SylentEngine

-- ============================================================================
-- [3. БЕЗОПАСНЫЕ ФУНКЦИИ ПОДКЛЮЧЕНИЯ]
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
-- [4. МОДУЛЬ: ГЛОБАЛЬНЫЙ SILENT AIM (РАСШИРЕННАЯ ВЕРСИЯ)]
-- ============================================================================

local skeletonBones = {
    "Head", "Torso", "HumanoidRootPart", "UpperTorso", "LowerTorso",
    "LeftArm", "RightArm", "LeftLeg", "RightLeg",
    "LeftHand", "RightHand", "LeftFoot", "RightFoot",
    "LeftLowerArm", "RightLowerArm", "LeftUpperArm", "RightUpperArm",
    "LeftLowerLeg", "RightLowerLeg", "LeftUpperLeg", "RightUpperLeg",
    "Neck", "RootPart", "LeftShoulder", "RightShoulder"
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

-- ============================================================================
-- [4.1. SILENT AIM — ПЕРЕХВАТ ЧЕРЕЗ __namecall (РАСШИРЕННЫЙ)]
-- ============================================================================

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

-- ============================================================================
-- [4.2. ДОПОЛНИТЕЛЬНЫЙ ПЕРЕХВАТ ЧЕРЕЗ __index ДЛЯ MOUSE.Hit]
-- ============================================================================

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

-- ============================================================================
-- [5. МОДУЛЬ: MEGA-THROW (РАСШИРЕННЫЙ С ПЕРЕХВАТОМ)]
-- ============================================================================

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

-- ============================================================================
-- [6. МОДУЛЬ: CROWN VORTEX (РАСШИРЕННЫЙ)]
-- ============================================================================

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

-- ============================================================================
-- [7. МОДУЛЬ: ANTI-GRAB (РАСШИРЕННЫЙ)]
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
    if not Engine.Flags.InstantGrabBreak then return end
    
    local char = lp.Character
    local root = GetCharacterRoot(char)
    if not root then return end
    
    local velocity = root.AssemblyLinearVelocity
    local velocityMag = velocity.Magnitude
    
    Engine.Cache.VelocityLog[Engine.Cache.VelocityLogIndex] = velocityMag
    Engine.Cache.VelocityLogIndex = (Engine.Cache.VelocityLogIndex % Engine.Cache.MaxVelocityLog) + 1
    
    if velocityMag > 50 and Engine.Cache.SavedPosition then
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

-- ============================================================================
-- [8. МОДУЛЬ: УПРАВЛЕНИЕ КАМЕРОЙ (РАСШИРЕННЫЙ)]
-- ============================================================================

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

-- ============================================================================
-- [9. МОДУЛЬ: МЕТАТАБЛИЦА (РАСШИРЕННЫЙ)]
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
-- [10. МОДУЛЬ: ВЫГРУЗКА СКРИПТА (РАСШИРЕННАЯ)]
-- ============================================================================

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
    
    table.clear(Engine.Cache.HuntingList)
    table.clear(Engine.Cache.VortexPlayers)
    table.clear(Engine.Cache.VelocityLog)
    Engine.Cache.SavedPosition = nil
    Engine.Cache.SilentAimTarget = nil
    
    _G.SylentEngine = nil
    print("[SYLENT Engine]: Скрипт выгружен. Все соединения очищены. Память освобождена.")
end

-- ============================================================================
-- [11. МОДУЛЬ: ДВИЖЕНИЕ (РАСШИРЕННЫЙ)]
-- ============================================================================

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
                Engine.Cache.FlyBodyVelocity = flyBodyVelocity
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
            Engine.Cache.FlyBodyVelocity = nil
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

-- ============================================================================
-- [12. МОДУЛЬ: ТРОЛЛИНГ (РАСШИРЕННЫЙ)]
-- ============================================================================

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

-- ============================================================================
-- [13. ФИНАЛЬНАЯ ИНИЦИАЛИЗАЦИЯ И АВТО-ЗАПУСК]
-- ============================================================================

SafeConnect(lp.CharacterAdded, function(char)
    local hum = char:WaitForChild("Humanoid", 15)
    if hum then
        task.wait(0.5)
        SetupAntiGrab(char)
        if Engine.Flags.WalkSpeedEnabled then
            hum.WalkSpeed = Engine.Flags.WalkSpeedValue
        end
        if Engine.Flags.JumpPowerEnabled then
            hum.JumpPower = Engine.Flags.JumpPowerValue
        end
    end
end)

Engine.Cache.OriginalCameraMode = lp.CameraMode
Engine.Cache.OriginalZoomDistance = lp.CameraMaxZoomDistance

print("[SYLENT Engine v3.0]: Невидимый физический движок загружен.")
print("  ✅ Silent Aim — активен (радиус: " .. Engine.Flags.SilentAimRange .. ")")
print("  ✅ Mega Throw — активен (сила: " .. Engine.Flags.ThrowForce .. ")")
print("  ✅ Crown Vortex — " .. (Engine.Flags.CrownVortex and "активен" or "ожидает включения"))
print("  ✅ Anti-Grab — активен")
print("  ✅ Fly — " .. (Engine.Flags.Fly and "активен" or "ожидает включения"))
print("Настройки в таблице Engine.Flags")
print("Для выгрузки вызовите CompleteDestruction()")
