--===================================================================================--
-- STW-2026-Q2-0438 // PROJECT NORTHGATE // ADMINISTRATIVE CONTROL SUITE           --
-- TARGET: VIOLENCE DISTRICT (РАЙОН НАСИЛИЯ)                                         --
-- COMPATIBILITY: DELTA EXECUTOR (MOBILE / PC)                                      --
--===================================================================================--

-- [Инициализация Сервисов]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- [Глобальное состояние конфигурации]
local Config = {
    Combat = {
        AutoParry = false,
        ParryDistance = 15,
        AutoRage = false,
        KillAura = false,
        AuraRadius = 12,
        AntiStun = false
    },
    Skills = {
        PerfectSkillCheck = false
    },
    Visuals = {
        FovCircle = false,
        FovRadius = 100,
        EspBoxes = false,
        EspTracers = false,
        EspThickness = 1.5,
        EspTransparency = 1.0,
        AspectRatio = 1.0,
        FullBright = false
    },
    World = {
        InfStamina = false,
        WalkSpeed = 16,
        JumpPower = 50
    }
}

-- [Кэш исходных настроек мира для корректной выгрузки]
local WorldCache = {
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
    GlobalShadows = Lighting.GlobalShadows,
    AspectRatio = Camera.AspectRatio
}

-- [Хранилище Drawing объектов и соединений]
local SignalConnections = {}
local EspObjects = {}
local AimCircle = nil

-- [Поиск сетевых удаленных событий / RemoteEvents]
-- Примечание: Адаптировано под стандартную структуру репликации боевых ремотов
local CombatRemote = game:GetService("ReplicatedStorage"):FindFirstChild("CombatRemote") or 
                       game:GetService("ReplicatedStorage"):FindFirstChild("Hit") or
                       game:GetService("ReplicatedStorage"):FindFirstChild("Punch")

local ParryRemote = game:GetService("ReplicatedStorage"):FindFirstChild("ParryRemote") or 
                      game:GetService("ReplicatedStorage"):FindFirstChild("Block") or
                      game:GetService("ReplicatedStorage"):FindFirstChild("Parry")

local RageRemote = game:GetService("ReplicatedStorage"):FindFirstChild("RageRemote") or 
                     game:GetService("ReplicatedStorage"):FindFirstChild("ActivateRage")

--===================================================================================--
-- [МАТЕМАТИЧЕСКИ ИДЕАЛЬНЫЙ ЦЕНТР ДЛЯ FOV КРУГА]
--===================================================================================--
if typeof(Drawing) ~= "nil" then
    AimCircle = Drawing.new("Circle")
    AimCircle.Color = Color3.fromRGB(255, 0, 0)
    AimCircle.Thickness = 1.5
    AimCircle.NumSides = 64
    AimCircle.Filled = false
    AimCircle.Visible = false
end

local function UpdateFovCenter()
    if AimCircle then
        local inset = GuiService:GetGuiInset()
        AimCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, (Camera.ViewportSize.Y - inset.Y) / 2)
        AimCircle.Radius = Config.Visuals.FovRadius
        AimCircle.Visible = Config.Visuals.FovCircle
    end
end

--===================================================================================--
-- [РЕАЛИЗАЦИЯ ESP СИСТЕМЫ (BOXES & TRACERS)]
--===================================================================================--
local function CreateEsp(player)
    if player == LocalPlayer then return end
    
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = Color3.fromRGB(255, 0, 0)
    box.Filled = false
    
    local tracer = Drawing.new("Line")
    tracer.Visible = false
    tracer.Color = Color3.fromRGB(255, 255, 255)
    
    local nameTag = Drawing.new("Text")
    nameTag.Visible = false
    nameTag.Color = Color3.fromRGB(255, 255, 255)
    nameTag.Size = 14
    nameTag.Center = true
    
    local healthBar = Drawing.new("Line")
    healthBar.Visible = false
    healthBar.Color = Color3.fromRGB(0, 255, 0)
    
    EspObjects[player] = {
        Box = box,
        Tracer = tracer,
        NameTag = nameTag,
        HealthBar = healthBar
    }
end

local function RemoveEsp(player)
    if EspObjects[player] then
        for _, obj in pairs(EspObjects[player]) do
            obj:Remove()
        end
        EspObjects[player] = nil
    end
end

local function UpdateEsp()
    for player, obj in pairs(EspObjects) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local hrp = player.Character.HumanoidRootPart
            local humanoid = player.Character.Humanoid
            local vector, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            
            if onScreen then
                -- Расчет динамического 2D Бокса на основе проекции частей тела
                local top = Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 3, 0))
                local bottom = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3.5, 0))
                local boxHeight = math.abs(top.Y - bottom.Y)
                local boxWidth = boxHeight / 1.5
                
                -- Обновление Box
                obj.Box.Size = Vector2.new(boxWidth, boxHeight)
                obj.Box.Position = Vector2.new(vector.X - boxWidth / 2, vector.Y - boxHeight / 2)
                obj.Box.Thickness = Config.Visuals.EspThickness
                obj.Box.Transparency = Config.Visuals.EspTransparency
                obj.Box.Visible = Config.Visuals.EspBoxes
                
                -- Обновление Tracer (линия от нижней центральной точки экрана)
                local inset = GuiService:GetGuiInset()
                obj.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y - inset.Y)
                obj.Tracer.To = Vector2.new(vector.X, vector.Y + (boxHeight / 2))
                obj.Tracer.Thickness = Config.Visuals.EspThickness
                obj.Tracer.Transparency = Config.Visuals.EspTransparency
                obj.Tracer.Visible = Config.Visuals.EspTracers
                
                -- Обновление NameTag
                obj.NameTag.Text = player.Name .. " [" .. math.floor((hrp.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude) .. "m]"
                obj.NameTag.Position = Vector2.new(vector.X, (vector.Y - boxHeight / 2) - 15)
                obj.NameTag.Visible = Config.Visuals.EspBoxes
                
                -- Обновление HealthBar (динамическая полоска слева от бокса)
                local healthPercentage = humanoid.Health / humanoid.MaxHealth
                obj.HealthBar.From = Vector2.new(vector.X - boxWidth / 2 - 4, vector.Y + boxHeight / 2)
                obj.HealthBar.To = Vector2.new(vector.X - boxWidth / 2 - 4, (vector.Y + boxHeight / 2) - (boxHeight * healthPercentage))
                obj.HealthBar.Thickness = 2
                obj.HealthBar.Color = Color3.fromRGB(255 * (1 - healthPercentage), 255 * healthPercentage, 0)
                obj.HealthBar.Visible = Config.Visuals.EspBoxes
            else
                obj.Box.Visible = false
                obj.Tracer.Visible = false
                obj.NameTag.Visible = false
                obj.HealthBar.Visible = false
            end
        else
            obj.Box.Visible = false
            obj.Tracer.Visible = false
            obj.NameTag.Visible = false
            obj.HealthBar.Visible = false
        end
    end
end

--===================================================================================--
-- [ЦЕНТРАЛЬНЫЙ ИСПОЛНИТЕЛЬНЫЙ ЦИКЛ (COMBAT & CORE ENGINE)]
--===================================================================================--

-- 1. СВЕРХТОЧНЫЙ AUTO PARRY
local function ProcessAutoParry()
    if not Config.Combat.AutoParry or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local localHrp = LocalPlayer.Character.HumanoidRootPart
    for _, enemy in pairs(Players:GetPlayers()) do
        if enemy ~= LocalPlayer and enemy.Character and enemy.Character:FindFirstChild("HumanoidRootPart") and enemy.Character:FindFirstChild("Humanoid") then
            local enemyHrp = enemy.Character.HumanoidRootPart
            local distance = (enemyHrp.Position - localHrp.Position).Magnitude
            
            if distance <= Config.Combat.ParryDistance then
                local animator = enemy.Character.Humanoid:FindFirstChildOfClass("Animator")
                if animator then
                    for _, track in pairs(animator:GetPlayingAnimationTracks()) do
                        -- Фильтрация по ключевым словам боевых анимаций "Района Насилия"
                        local animName = string.lower(track.Animation.Name or "")
                        if string.find(animName, "attack") or string.find(animName, "swing") or string.find(animName, "punch") or string.find(animName, "slash") then
                            -- Проверка активной фазы хитбокса анимации
                            if track.TimePosition >= 0.05 and track.TimePosition <= 0.35 then
                                if ParryRemote then
                                    ParryRemote:FireServer()
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

-- 2. AUTO RAGE AWARENESS
local function ProcessAutoRage()
    if not Config.Combat.AutoRage then return end
    
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if playerGui then
        -- Динамическое обнаружение интерфейса шкалы ульты/ярости
        local mainGui = playerGui:FindFirstChild("MainGui") or playerGui:FindFirstChild("HUD")
        if mainGui then
            local rageBar = mainGui:FindFirstChild("RageBar", true) or mainGui:FindFirstChild("StaminaBar", true)
            if rageBar and (rageBar:IsA("Frame") or rageBar:IsA("ImageLabel")) then
                -- Проверка по размеру или тексту внутри процентов
                local thresholdReached = false
                local percentageText = rageBar:FindFirstChild("Percentage", true) or rageBar:FindFirstChild("TextLabel", true)
                
                if percentageText and percentageText:IsA("TextLabel") then
                    local val = tonumber(string.match(percentageText.Text, "%d+"))
                    if val and val >= 100 then thresholdReached = true end
                elseif rageBar.Size.X.Scale >= 1 then
                    thresholdReached = true
                end
                
                if thresholdReached and RageRemote then
                    RageRemote:FireServer()
                end
            end
        end
    end
end

-- 3. KILL AURA
local function ProcessKillAura()
    if not Config.Combat.KillAura or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local localHrp = LocalPlayer.Character.HumanoidRootPart
    for _, enemy in pairs(Players:GetPlayers()) do
        if enemy ~= LocalPlayer and enemy.Character and enemy.Character:FindFirstChild("HumanoidRootPart") and enemy.Character:FindFirstChild("Humanoid") and enemy.Character.Humanoid.Health > 0 then
            local enemyHrp = enemy.Character.HumanoidRootPart
            local distance = (enemyHrp.Position - localHrp.Position).Magnitude
            
            if distance <= Config.Combat.AuraRadius then
                if CombatRemote then
                    -- Симуляция мгновенного сетевого удара по хитбоксу оппонента
                    CombatRemote:FireServer(enemy.Character)
                end
            end
        end
    end
end

-- 4. ANTI-STUN & ANTI-RAGDOLL
local function ProcessAntiStun()
    if not Config.Combat.AntiStun or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("Humanoid") then return end
    
    local humanoid = LocalPlayer.Character.Humanoid
    if humanoid.PlatformStanding or humanoid:GetState() == Enum.HumanoidStateType.Ragdoll or humanoid:GetState() == Enum.HumanoidStateType.FallingDown then
        humanoid.PlatformStanding = false
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
end

-- 5. PERFECT SKILL CHECK AUTO-WIN
local function HookSkillChecks()
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    
    local connection = playerGui.ChildAdded:Connect(function(child)
        if not Config.Skills.PerfectSkillCheck then return end
        
        -- Поиск UI-компонента мини-игры
        if string.find(string.lower(child.Name), "check") or string.find(string.lower(child.Name), "minigame") then
            task.spawn(function()
                local needle = child:FindFirstChild("Needle", true) or child:FindFirstChild("Arrow", true)
                local targetZone = child:FindFirstChild("PerfectZone", true) or child:FindFirstChild("Target", true)
                local remote = child:FindFirstChild("RemoteEvent", true) or child:FindFirstChild("Submit", true) or game:GetService("ReplicatedStorage"):FindFirstChild("SkillCheckRemote")
                
                if needle and targetZone then
                    -- Непрерывный перехват совпадения геометрических фаз/вращения UI
                    while child.Parent == playerGui and Config.Skills.PerfectSkillCheck do
                        RunService.Heartbeat:Wait()
                        local currentRotation = needle.Rotation % 360
                        local targetRotation = targetZone.Rotation % 360
                        local tolerance = 5 -- Допуск в градусах для идеального попадания
                        
                        if math.abs(currentRotation - targetRotation) <= tolerance then
                            if remote and remote:IsA("RemoteEvent") then
                                remote:FireServer(true)
                            else
                                -- Виртуальное нажатие, если ремот скрыт
                                local button = child:FindFirstChild("ClickButton", true) or child:FindFirstChild("Action", true)
                                if button and button:IsA("TextButton") then
                                    -- Вызов внутренних функций клика GUI
                                    for _, conn in pairs(getconnections(button.MouseButton1Click)) do
                                        conn:Fire()
                                    end
                                end
                            end
                            break
                        end
                    end
                end
            end)
        end
    end)
    table.insert(SignalConnections, connection)
end

-- 9. FULLBRIGHT SYSTEM
local function ProcessFullBright()
    if Config.Visuals.FullBright then
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        Lighting.ClockTime = 14
        Lighting.FogEnd = 999999
        Lighting.GlobalShadows = false
    end
end

--===================================================================================--
-- [10. МЕТАТАБЛИЧНЫЙ ХУК ЗАЩИТЫ ВЫВОДА (BYPASS)]
--===================================================================================--
local function InitiateMetaHook()
    local rawMeta = getrawmetatable(game)
    setreadonly(rawMeta, false)
    local oldIndex = rawMeta.__index
    
    rawMeta.__index = newcclosure(function(self, key)
        if not checkcaller() and Config.World.InfStamina then
            if self:IsA("Humanoid") then
                if key == "WalkSpeed" then return 16 end
                if key == "JumpPower" then return 50 end
            end
        end
        return oldIndex(self, key)
    end)
    setreadonly(rawMeta, true)
    
    -- Блокировка расхода выносливости локальными скриптами игры
    local oldNameCall
    oldNameCall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        if not checkcaller() and Config.World.InfStamina and method == "FireServer" then
            if string.find(string.lower(self.Name), "stamina") or string.find(string.lower(self.Name), "sprint") then
                -- Подмена аргумента расхода стамины на 0 или отмена отправки пакета
                return nil
            end
        end
        return oldNameCall(self, ...)
    end))
end

--===================================================================================--
-- [РЕГИСТРАЦИЯ СЕРВИСНЫХ ЦИКЛОВ RUNSERVICE]
--===================================================================================--
table.insert(SignalConnections, RunService.Heartbeat:Connect(function()
    ProcessAutoParry()
    ProcessAutoRage()
    ProcessKillAura()
end))

table.insert(SignalConnections, RunService.Stepped:Connect(function()
    ProcessAntiStun()
    ProcessFullBright()
    if Config.World.InfStamina and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = Config.World.WalkSpeed
        LocalPlayer.Character.Humanoid.JumpPower = Config.World.JumpPower
    end
end))

table.insert(SignalConnections, RunService.RenderStepped:Connect(function()
    UpdateFovCenter()
    UpdateEsp()
    if Config.Visuals.AspectRatio ~= 1.0 then
        Camera.AspectRatio = Config.Visuals.AspectRatio
    end
end))

-- Синхронизация списка игроков для ESP
for _, p in pairs(Players:GetPlayers()) do CreateEsp(p) end
table.insert(SignalConnections, Players.PlayerAdded:Connect(CreateEsp))
table.insert(SignalConnections, Players.PlayerRemoving:Connect(RemoveEsp))

task.spawn(HookSkillChecks)
task.spawn(InitiateMetaHook)

--===================================================================================--
-- [КОНСТРУКТОР МОНОЛИТНОГО ИНТЕРФЕЙСА (UI ENGINE)]
--===================================================================================--
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ViolenceDistrict_AdminPanel"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Обеспечение работы UI на девайсах с вырезами экрана (Delta Mobile)
pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 550, 0, 350)
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local LeftPanel = Instance.new("Frame")
LeftPanel.Name = "LeftPanel"
LeftPanel.Size = UDim2.new(0, 150, 1, 0)
LeftPanel.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
LeftPanel.BorderSizePixel = 0
LeftPanel.Parent = MainFrame

local LeftCorner = Instance.new("UICorner")
LeftCorner.CornerRadius = UDim.new(0, 8)
LeftCorner.Parent = LeftPanel

local Container = Instance.new("Frame")
Container.Name = "Container"
Container.Size = UDim2.new(1, -160, 1, -10)
Container.Position = UDim2.new(0, 155, 0, 5)
Container.BackgroundTransparency = 1
Container.Parent = MainFrame

local Tabs = {}
local TabButtons = {}

local function CreateTab(name, icon)
    local TabFrame = Instance.new("ScrollingFrame")
    TabFrame.Name = name .. "Tab"
    TabFrame.Size = UDim2.new(1, 0, 1, 0)
    TabFrame.BackgroundTransparency = 1
    TabFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabFrame.ScrollBarThickness = 4
    TabFrame.Visible = false
    TabFrame.Parent = Container
    
    local UIList = Instance.new("UIListLayout")
    UIList.Padding = UDim.new(0, 6)
    UIList.SortOrder = Enum.SortOrder.LayoutOrder
    UIList.Parent = TabFrame
    
    Tabs[name] = TabFrame
    
    local Button = Instance.new("TextButton")
    Button.Name = name .. "Btn"
    Button.Size = UDim2.new(1, -10, 0, 40)
    Button.Position = UDim2.new(0, 5, 0, #TabButtons * 45 + 5)
    Button.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Button.TextColor3 = Color3.fromRGB(200, 200, 200)
    Button.Font = Enum.Font.SourceSansBold
    Button.TextSize = 14
    Button.Text = icon .. " " .. name
    Button.Parent = LeftPanel
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 4)
    BtnCorner.Parent = Button
    
    Button.MouseButton1Click:Connect(function()
        for tName, tFrame in pairs(Tabs) do
            tFrame.Visible = (tName == name)
        end
        for _, btn in pairs(TabButtons) do
            btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        end
        Button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    end)
    
    table.insert(TabButtons, Button)
    return TabFrame
end

-- Создание структуры вкладок в соответствии с интерфейсом
local CombatTab = CreateTab("Бой", "⚔️")
local SkillsTab = CreateTab("Скиллы", "⚡")
local VisualsTab = CreateTab("Визуалы", "👁️")
local WorldTab = CreateTab("Мир", "🏪")

--===================================================================================--
-- [КОМПОНЕНТЫ ИНТЕРФЕЙСА И СВЯЗЫВАНИЕ ФУНКЦИЙ]
--===================================================================================--

local function AddToggle(parent, text, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 35)
    Frame.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    Frame.BorderSizePixel = 0
    Frame.Parent = parent
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 16
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Text = text
    Label.Parent = Frame
    
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 50, 0, 25)
    Btn.Position = UDim2.new(1, -60, 0, 5)
    Btn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    Btn.Text = ""
    Btn.Parent = Frame
    
    local state = false
    Btn.MouseButton1Click:Connect(function()
        state = not state
        Btn.BackgroundColor3 = state and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
        callback(state)
    end)
    
    Instance.new("UICorner").CornerRadius = UDim.new(0, 4) Frame.Parent = parent
    Instance.new("UICorner").CornerRadius = UDim.new(0, 4) Btn.Parent = Btn
end

local function AddSlider(parent, text, min, max, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 45)
    Frame.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    Frame.Parent = parent
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.5, 0, 0, 20)
    Label.Position = UDim2.new(0, 10, 0, 2)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Text = text
    Label.Parent = Frame
    
    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0.4, 0, 0, 20)
    ValueLabel.Position = UDim2.new(0.6, -10, 0, 2)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    ValueLabel.Font = Enum.Font.SourceSans
    ValueLabel.TextSize = 14
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.Text = tostring(default)
    ValueLabel.Parent = Frame
    
    local SliderTrack = Instance.new("Frame")
    SliderTrack.Size = UDim2.new(1, -20, 0, 6)
    SliderTrack.Position = UDim2.new(0, 10, 0, 28)
    SliderTrack.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    SliderTrack.Parent = Frame
    
    local SliderThumb = Instance.new("Frame")
    SliderThumb.Size = UDim2.new(0, 12, 0, 12)
    SliderThumb.Position = UDim2.new((default - min) / (max - min), -6, 0, -3)
    SliderThumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SliderThumb.Parent = SliderTrack
    
    local dragging = false
    local function update(input)
        local pos = math.clamp((input.Position.X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X, 0, 1)
        SliderThumb.Position = UDim2.new(pos, -6, 0, -3)
        local value = math.floor(min + (max - min) * pos)
        ValueLabel.Text = tostring(value)
        callback(value)
    end
    
    SliderThumb.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    Instance.new("UICorner").CornerRadius = UDim.new(0, 4) Frame.Parent = parent
end

--===================================================================================--
-- ИНТЕГРАЦИЯ ФУНКЦИОНАЛА В ИНТЕРФЕЙС
--===================================================================================--

-- Вкладка: Бой
AddToggle(CombatTab, "Сверхточный Auto Parry", function(v) Config.Combat.AutoParry = v end)
AddSlider(CombatTab, "Дистанция Парирования", 5, 25, 15, function(v) Config.Combat.ParryDistance = v end)
AddToggle(CombatTab, "Auto Rage Awareness", function(v) Config.Combat.AutoRage = v end)
AddToggle(CombatTab, "Kill Aura", function(v) Config.Combat.KillAura = v end)
AddSlider(CombatTab, "Радиус Ауры", 5, 20, 12, function(v) Config.Combat.AuraRadius = v end)
AddToggle(CombatTab, "Anti-Stun & Anti-Ragdoll", function(v) Config.Combat.AntiStun = v end)

-- Вкладка: Скиллы
AddToggle(SkillsTab, "Perfect Skill Check Auto-Win", function(v) Config.Skills.PerfectSkillCheck = v end)

-- Вкладка: Визуалы
AddToggle(VisualsTab, "Отрисовка FOV Круга", function(v) Config.Visuals.FovCircle = v end)
AddSlider(VisualsTab, "Радиус FOV Круга", 10, 300, 100, function(v) Config.Visuals.FovRadius = v end)
AddToggle(VisualsTab, "ESP Боксы", function(v) Config.Visuals.EspBoxes = v end)
AddToggle(VisualsTab, "ESP Трассеры", function(v) Config.Visuals.EspTracers = v end)
AddSlider(VisualsTab, "Толщина Линий ESP", 1, 5, 1, function(v) Config.Visuals.EspThickness = v end)
AddSlider(VisualsTab, "Растяг Экрана (Aspect Ratio * 10)", 5, 25, 10, function(v) Config.Visuals.AspectRatio = v / 10 end)
AddToggle(VisualsTab, "FullBright (Удаление темноты)", function(v) 
    Config.Visuals.FullBright = v 
    if not v then
        Lighting.Ambient = WorldCache.Ambient
        Lighting.OutdoorAmbient = WorldCache.OutdoorAmbient
        Lighting.ClockTime = WorldCache.ClockTime
        Lighting.FogEnd = WorldCache.FogEnd
        Lighting.GlobalShadows = WorldCache.GlobalShadows
    end
end)

-- Вкладка: Мир
AddToggle(WorldTab, "Infinite Stamina + Bypass", function(v) Config.World.InfStamina = v end)
AddSlider(WorldTab, "Кастомный Скорость (WalkSpeed)", 16, 100, 16, function(v) Config.World.WalkSpeed = v end)
AddSlider(WorldTab, "Кастомный Прыжок (JumpPower)", 50, 150, 50, function(v) Config.World.JumpPower = v end)

--===================================================================================--
-- 11. ВЫГРУЗКА ПАНЕЛИ (UNLOAD)
--===================================================================================--
local UnloadButton = Instance.new("TextButton")
UnloadButton.Size = UDim2.new(1, -10, 0, 35)
UnloadButton.BackgroundColor3 = Color3.fromRGB(100, 20, 20)
UnloadButton.TextColor3 = Color3.fromRGB(255, 255, 255)
UnloadButton.Font = Enum.Font.SourceSansBold
UnloadButton.TextSize = 14
UnloadButton.Text = "🚨 ВЫГРУЗИТЬ ХАК (UNLOAD)"
UnloadButton.Parent = WorldTab

Instance.new("UICorner").CornerRadius = UDim.new(0, 4) UnloadButton.Parent = UnloadButton

UnloadButton.MouseButton1Click:Connect(function()
    -- Отключение всех тумблеров скрипта
    for cat, keys in pairs(Config) do
        for k, _ in pairs(keys) do
            Config[cat][k] = false
        end
    end
    
    -- Отключение сигналов и соединений RunService
    for _, conn in pairs(SignalConnections) do
        if conn.Connected then conn:Disconnect() end
    end
    table.clear(SignalConnections)
    
    -- Очистка памяти отрисовки (Drawing)
    for player, _ in pairs(EspObjects) do
        RemoveEsp(player)
    end
    if AimCircle then 
        AimCircle:Remove() 
    end
    
    -- Восстановление исходных параметров окружения из кэша
    Lighting.Ambient = WorldCache.Ambient
    Lighting.OutdoorAmbient = WorldCache.OutdoorAmbient
    Lighting.ClockTime = WorldCache.ClockTime
    Lighting.FogEnd = WorldCache.FogEnd
    Lighting.GlobalShadows = WorldCache.GlobalShadows
    Camera.AspectRatio = WorldCache.AspectRatio
    
    -- Полное уничтожение UI интерфейса хака
    ScreenGui:Destroy()
end)

-- Инициализация стартовой вкладки меню
if TabButtons[1] then
    for tName, tFrame in pairs(Tabs) do tFrame.Visible = (tName == "Бой") end
    TabButtons[1].BackgroundColor3 = Color3.fromRGB(40, 40, 40)
end
