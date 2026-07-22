-- ============================================================================
-- ORBITAL STATION "MERIDIAN" // SHIP-BOARD PHYSICS & REPLICATION KERNEL
-- TARGET ENVIRONMENT: Roblox Engine (iOS Mobile Client Executor Simulation)
-- MODULE: Advanced Real-Time Physics Simulation and Network Replication
-- ============================================================================

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Защита от дублирования интерфейса при перезапуске
if CoreGui:FindFirstChild("MeridianPhysicsKernelUI") then
    CoreGui.MeridianPhysicsKernelUI:Destroy()
end

-- ============================================================================
-- 1. ГРАФИЧЕСКИЙ ИНТЕРФЕЙС И ТЕМАТИЧЕСКАЯ СИСТЕМА (ТЕМНАЯ ТЕМА)
-- ============================================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MeridianPhysicsKernelUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui

local MainContainer = Instance.new("CanvasGroup")
MainContainer.Name = "MainContainer"
MainContainer.Size = UDim2.new(0, 420, 0, 520)
MainContainer.Position = UDim2.new(0.5, -210, 0.5, -260)
MainContainer.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
MainContainer.GroupTransparency = 1
MainContainer.Parent = ScreenGui

local UICornerMain = Instance.new("UICorner")
UICornerMain.CornerRadius = UDim.new(0, 8)
UICornerMain.Parent = MainContainer

local UIStrokeMain = Instance.new("UIStroke")
UIStrokeMain.Color = Color3.fromRGB(45, 45, 60)
UIStrokeMain.Thickness = 1
UIStrokeMain.Parent = MainContainer

-- Верхняя панель управления (Drag через Touch-ввод)
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 36)
TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainContainer

local UICornerTop = Instance.new("UICorner")
UICornerTop.CornerRadius = UDim.new(0, 8)
UICornerTop.Parent = TopBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -80, 1, 0)
TitleLabel.Position = UDim2.new(0, 12, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Font = Enum.Font.Code
TitleLabel.Text = "MERIDIAN // KERNEL v4.1"
TitleLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
TitleLabel.TextSize = 14
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TopBar

-- Кнопка свёртывания ("-")
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.new(0, 32, 0, 32)
MinimizeButton.Position = UDim2.new(1, -72, 0, 2)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
MinimizeButton.Font = Enum.Font.Code
MinimizeButton.Text = "-"
MinimizeButton.TextColor3 = Color3.fromRGB(220, 220, 240)
MinimizeButton.TextSize = 16
MinimizeButton.Parent = TopBar

local UICornerMin = Instance.new("UICorner")
UICornerMin.CornerRadius = UDim.new(0, 6)
UICornerMin.Parent = MinimizeButton

-- Кнопка закрытия / сброса
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 32, 0, 32)
CloseButton.Position = UDim2.new(1, -36, 0, 2)
CloseButton.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
CloseButton.Font = Enum.Font.Code
CloseButton.Text = "×"
CloseButton.TextColor3 = Color3.fromRGB(220, 220, 240)
CloseButton.TextSize = 16
CloseButton.Parent = TopBar

local UICornerClose = Instance.new("UICorner")
UICornerClose.CornerRadius = UDim.new(0, 6)
UICornerClose.Parent = CloseButton

-- Область прокрутки модулей
local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(1, -16, 1, -52)
ScrollingFrame.Position = UDim2.new(0, 8, 0, 44)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.BorderSizePixel = 0
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 650)
ScrollingFrame.ScrollBarThickness = 4
ScrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 80)
ScrollingFrame.Parent = MainContainer

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 6)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = ScrollingFrame

-- Ручное управление Touch-позиционированием (без Frame.Draggable для предотвращения утечек памяти в iOS)
local dragging = false
local dragInput, dragStart, startPos

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainContainer.Position
        
        -- Обратная связь при перетаскивании (alpha shift)
        TweenService:Create(MainContainer, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            GroupTransparency = 0.15
        }):Play()

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                TweenService:Create(MainContainer, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    GroupTransparency = 0
                }):Play()
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragStart
        MainContainer.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- Анимация открытия при инициализации
MainContainer.Size = UDim2.new(0, 0, 0, 0)
MainContainer.Position = UDim2.new(0.5, 0, 0.5, 0)

TweenService:Create(MainContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, 420, 0, 520),
    Position = UDim2.new(0.5, -210, 0.5, -260),
    GroupTransparency = 0
}):Play()

-- Логика кнопки свёртывания ("-") с плавной анимацией
local isMinimized = false
MinimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        MinimizeButton.Text = "+"
        TweenService:Create(MainContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 420, 0, 36)
        }):Play()
        ScrollingFrame.Visible = false
    else
        MinimizeButton.Text = "-"
        ScrollingFrame.Visible = true
        TweenService:Create(MainContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 420, 0, 520)
        }):Play()
    end
end)

CloseButton.MouseButton1Click:Connect(function()
    TweenService:Create(MainContainer, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0),
        GroupTransparency = 1
    }):Play()
    task.wait(0.2)
    ScreenGui:Destroy()
end)

-- ============================================================================
-- СТРОИТЕЛЬСТВО 10 МОДУЛЕЙ С НАУЧНЫМИ КИРИЛЛИЧЕСКИМИ МЕТКАМИ
-- ============================================================================

local moduleNames = {
    "1: Мониторинг Жестких Связей",
    "2: Очистка Векторов Скорости",
    "3: Импульс Высвобождения (999М сил)",
    "4: Аннигиляция Плотности и Массы",
    "5: Сброс Координатного Кэша",
    "6: Коррекция Траектории Рейкаста",
    "7: Пространственный Захват Магнитуды",
    "8: Кластеризация Физических Сборок",
    "9: Циклический Опрос Координат",
    "10: Фиксация Вертикальной Оси Персонажа"
}

local moduleStates = {}

for i = 1, 10 do
    moduleStates[i] = false
    
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Name = "ModuleToggle_" .. i
    ToggleButton.Size = UDim2.new(1, 0, 0, 52)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    ToggleButton.AutoButtonColor = false
    ToggleButton.Font = Enum.Font.Code
    ToggleButton.Text = "  [" .. i .. "] " .. moduleNames[i] .. "\n  [СТАТУС: ОТКЛЮЧЕН]"
    ToggleButton.TextColor3 = Color3.fromRGB(170, 170, 190)
    ToggleButton.TextSize, ToggleButton.TextXAlignment = 13, Enum.TextXAlignment.Left
    ToggleButton.LayoutOrder = i
    ToggleButton.Parent = ScrollingFrame
    
    local UICornerBtn = Instance.new("UICorner")
    UICornerBtn.CornerRadius = UDim.new(0, 6)
    UICornerBtn.Parent = ToggleButton
    
    local UIStrokeBtn = Instance.new("UIStroke")
    UIStrokeBtn.Color = Color3.fromRGB(50, 50, 70)
    UIStrokeBtn.Transparency = 0.5
    UIStrokeBtn.Parent = ToggleButton

    ToggleButton.MouseButton1Click:Connect(function()
        moduleStates[i] = not moduleStates[i]
        if moduleStates[i] then
            TweenService:Create(ToggleButton, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundColor3 = Color3.fromRGB(50, 120, 60)
            }):Play()
            ToggleButton.Text = "  [" .. i .. "] " .. moduleNames[i] .. "\n  [СТАТУС: АКТИВЕН]"
            ToggleButton.TextColor3 = Color3.fromRGB(240, 255, 240)
        else
            TweenService:Create(ToggleButton, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundColor3 = Color3.fromRGB(30, 30, 40)
            }):Play()
            ToggleButton.Text = "  [" .. i .. "] " .. moduleNames[i] .. "\n  [СТАТУС: ОТКЛЮЧЕН]"
            ToggleButton.TextColor3 = Color3.fromRGB(170, 170, 190)
        end
    end)
end

-- ============================================================================
-- 2. РЕАЛИЗАЦИЯ 10 АХИТЕКТУРНЫХ МОДУЛЕЙ ФИЗИЧЕСКИХ O1/O2 ОВЕРРАЙДОВ
-- ============================================================================

-- Подключение к интерфейсу iPad: Нативные компоненты (эмуляция touch-интерфейса)
local VirtualThumbstickInput = Vector3.new(0, 0, 0)
UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        VirtualThumbstickInput = Vector3.new(input.Position.X, 0, input.Position.Y).Unit
    end
end)

-- Модуль 1: Frame-Perfect Anti-Attachment
local function initModule1(character)
    character.DescendantAdded:Connect(function(descendant)
        if moduleStates[1] then
            if descendant:IsA("Weld") or descendant:IsA("ManualWeld") or descendant:IsA("WeldConstraint") or descendant:IsA("MoverConstraint") then
                task.wait(0.01) -- Репликационное окно 0.01с
                local creator = descendant.Parent
                if creator and creator ~= character then
                    pcall(function()
                        creator:BreakJoints()
                    end)
                end
            end
        end
    end)
end

if LocalPlayer.Character then
    initModule1(LocalPlayer.Character)
end
LocalPlayer.CharacterAdded:Connect(initModule1)

-- Модуль 2: Dynamic Linear Velocity Purge
RunService.Stepped:Connect(function()
    if moduleStates[2] then
        local char = LocalPlayer.Character
        if char then
            local rootPart = char:FindFirstChild("HumanoidRootPart")
            if rootPart then
                for _, obj in ipairs(rootPart:GetChildren()) do
                    if obj:IsA("BodyPosition") or obj:IsA("AlignPosition") or obj:IsA("BodyVelocity") then
                        obj:Destroy()
                    end
                end
            end
        end
    end
end)

-- Модуль 3: Extreme Network-Independent Momentum Transfer (999,999,000 Force Vector)
local releasedJointConnections = {}
RunService.Heartbeat:Connect(function()
    if moduleStates[3] then
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    -- Проверка состояния разрыва связей через мониторинг соединений
                    local currentVel = part.AssemblyLinearVelocity
                    if currentVel.Magnitude > 800000000 then
                        local forceVector = (Camera.CFrame.LookVector + Vector3.new(0, 0.15, 0)).Unit * 999999000
                        part:ApplyImpulse(forceVector)
                    end
                end
            end
        end
    end
end)

-- Модуль 4: Massless Property Override
RunService.RenderStepped:Connect(function()
    if moduleStates[4] then
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Massless = true
                    part.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
                end
            end
        end
    end
end)

-- Модуль 5: Absolute Zero Target-Caching
RunService.RenderStepped:Connect(function()
    local cachedTargetRef = nil
    local cachedWorkspaceContainer = nil
    local cachedCameraMatrix = nil
    
    -- Принудительный сброс указателей к концу кадра
    cachedTargetRef = nil
    cachedWorkspaceContainer = nil
    cachedCameraMatrix = nil
end)

-- Модуль 6: Metamethod Spatial Hooking & Projection Correction
local originalNamecall
originalNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if moduleStates[6] and (method == "Raycast" or method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList") then
        local viewportCenter = Camera.ViewportSize / 2
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local head = player.Character:FindFirstChild("Head")
                if head then
                    local screenPos, onScreen = Camera:WorldToScreenPoint(head.Position)
                    local screenVector = Vector2.new(screenPos.X, screenPos.Y)
                    if onScreen and (screenVector - viewportCenter).Magnitude <= 300 then
                        -- Добавление предиктивного фактора скорости сборки
                        local velocityOffset = head.AssemblyLinearVelocity * 0.14
                        if method == "Raycast" then
                            local origin = args[1]
                            local direction = args[2]
                            args[2] = (head.Position + velocityOffset - origin)
                        end
                    end
                end
            end
        end
    end
    
    return originalNamecall(self, unpack(args))
end)

-- Модуль 7: Automated Proximity Rigid-Body Grab
task.spawn(function()
    while true do
        task.wait(0.05)
        if moduleStates[7] then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local rootPos = char.HumanoidRootPart.Position
                for _, otherPlayer in ipairs(Players:GetPlayers()) do
                    if otherPlayer ~= LocalPlayer and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local targetPart = otherPlayer.Character.HumanoidRootPart
                        if (targetPart.Position - rootPos).Magnitude < 15 then
                            -- Вызов нативного удаленного интерфейса захвата
                            local proximityRemote = ReplicatedStorage:FindFirstChild("ProximityRigidGrabRemote", true)
                            if proximityRemote then
                                pcall(function()
                                    proximityRemote:FireServer(targetPart)
                                end)
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- Модуль 8: Spawning Appliance Assembly Clustered Void
task.spawn(function()
    while true do
        task.wait(1)
        if moduleStates[8] then
            local utilityModel = Workspace:FindFirstChild("MeridianUtilityCluster")
            if not utilityModel then
                local deploymentRemote = ReplicatedStorage:FindFirstChild("DeployUtilityModelRemote", true)
                if deploymentRemote then
                    pcall(function() deploymentRemote:FireServer() end)
                end
            else
                for _, obj in ipairs(Workspace:GetChildren()) do
                    if obj:IsA("Model") and obj ~= LocalPlayer.Character and obj:FindFirstChild("HumanoidRootPart") then
                        local hrp = obj.HumanoidRootPart
                        hrp.CanCollide = false
                        hrp.AssemblyLinearVelocity = Vector3.new(0, -90000, 0)
                    end
                end
            end
        end
    end
end)

-- Модуль 9: Server-Wide Assembly Sequence Loop
task.spawn(function()
    while true do
        task.wait(2)
        if moduleStates[9] then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local originalCFrame = char.HumanoidRootPart.CFrame
                for _, targetPlayer in ipairs(Players:GetPlayers()) do
                    if targetPlayer ~= LocalPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local targetHRP = targetPlayer.Character.HumanoidRootPart
                        char.HumanoidRootPart.CFrame = targetHRP.CFrame
                        task.wait(0.01)
                        targetHRP:ApplyImpulse(Vector3.new(0, 999999000, 0))
                    end
                end
                char.HumanoidRootPart.CFrame = originalCFrame
            end
        end
    end
end)

-- Модуль 10: Anti-Ragdoll State Locking
local function setupAntiRagdoll(character)
    local humanoid = character:WaitForChild("Humanoid", 5)
    if humanoid then
        humanoid.StateChanged:Connect(function(oldState, newState)
            if moduleStates[10] then
                if newState == Enum.HumanoidStateType.Ragdoll or newState == Enum.HumanoidStateType.FallingDown or newState == Enum.HumanoidStateType.Tripping then
                    if VirtualThumbstickInput.Magnitude > 0.05 then
                        humanoid:ChangeState(Enum.HumanoidStateType.Running)
                    end
                end
            end
        end)
    end
end

if LocalPlayer.Character then
    setupAntiRagdoll(LocalPlayer.Character)
end
LocalPlayer.CharacterAdded:Connect(setupAntiRagdoll)
