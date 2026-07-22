--[=[
    ФРЕЙМВОРК: Низкоуровневая Архитектура Моделирования Физики и Интерполяции Сетевого Владения
    ПЛАТФОРМА: Мобильная Архитектура iPad (Сенсорная Оптимизация под Окружение Delta)
    СТАТУС: Продуктивная Сборка (Production-Ready), Полный Открытый Код Без Сокращений
--]=]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = Workspace.CurrentCamera

-- Инициализация Удаленных Сетевых Интерфейсов (Унифицированные Протоколы Жизненного Цикла Объектов)
local EquipmentRemote = ReplicatedStorage:FindFirstChild("EquipmentLifecycleRemote") or Instance.new("RemoteEvent", ReplicatedStorage)
EquipmentRemote.Name = "EquipmentLifecycleRemote"

local InteractionRemote = ReplicatedStorage:FindFirstChild("NetworkInteractionRemote") or Instance.new("RemoteEvent", ReplicatedStorage)
InteractionRemote.Name = "NetworkInteractionRemote"

-- Глобальная Таблица Состояний Модулей Физики
local PhysicsConfig = {
    ModuleStates = {
        [1] = false, [2] = false, [3] = false, [4] = false, [5] = false,
        [6] = false, [7] = false, [8] = false, [9] = false, [10] = false
    },
    HeldAssemblies = {},
    TargetPredictionData = nil,
    JoystickActive = false,
    JoystickVector = Vector3.new(0, 0, 0)
}

-- Глобальный Кэш Ссылок Переменных Трекинга (Буфер Очистки Ресурсов)
local ReferenceFlushingBuffer = {
    CurrentTargetInstance = nil,
    ActiveRaycastResult = nil,
    TemporaryCalculationMatrix = nil
}

-- Создание Адаптивного Графического Интерфейса (Раздел А)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LowLevelPhysicsSolverHUD"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("CanvasGroup")
MainFrame.Name = "MainEnginePanel"
MainFrame.Size = UDim2.new(0, 0, 0, 0)
MainFrame.Position = UDim2.new(0.05, 0, 0.15, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
MainFrame.BorderSizePixel = 0
MainFrame.GroupTransparency = 1
MainFrame.Parent = ScreenGui

local MainUICorner = Instance.new("UICorner")
MainUICorner.CornerRadius = UDim.new(0, 10)
MainUICorner.Parent = MainFrame

local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 45)
TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopBarCorner = Instance.new("UICorner")
TopBarCorner.CornerRadius = UDim.new(0, 10)
TopBarCorner.Parent = TopBar

local TopBarFix = Instance.new("Frame")
TopBarFix.Name = "TopBarFix"
TopBarFix.Size = UDim2.new(1, 0, 0, 10)
TopBarFix.Position = UDim2.new(0, 0, 1, -10)
TopBarFix.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
TopBarFix.BorderSizePixel = 0
TopBarFix.Parent = TopBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -100, 1, 0)
TitleLabel.Position = UDim2.new(0, 14, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "АРХИТЕКТУРА РЕШАТЕЛЯ ФИЗИКИ [DELTA]"
TitleLabel.TextColor3 = Color3.fromRGB(230, 230, 240)
TitleLabel.TextSize = 14
TitleLabel.Font = Enum.Font.Code
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TopBar

local MinButton = Instance.new("TextButton")
MinButton.Size = UDim2.new(0, 35, 0, 35)
MinButton.Position = UDim2.new(1, -80, 0, 5)
MinButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
MinButton.Text = "-"
MinButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinButton.TextSize = 18
MinButton.Font = Enum.Font.Code
MinButton.Parent = TopBar

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 6)
MinCorner.Parent = MinButton

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 35, 0, 35)
CloseButton.Position = UDim2.new(1, -40, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(45, 25, 25)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 150, 150)
CloseButton.TextSize = 14
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = TopBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseButton

local ScrollContainer = Instance.new("ScrollingFrame")
ScrollContainer.Name = "ScrollRegion"
ScrollContainer.Size = UDim2.new(1, -12, 1, -55)
ScrollContainer.Position = UDim2.new(0, 6, 0, 50)
ScrollContainer.BackgroundTransparency = 1
ScrollContainer.BorderSizePixel = 0
ScrollContainer.CanvasSize = UDim2.new(0, 0, 0, 860)
ScrollContainer.ScrollBarThickness = 4
ScrollContainer.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 80)
ScrollContainer.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.Parent = ScrollContainer

-- Алгоритм Ручного Вычисления Координат Касания (Исключение Утечек Памяти iOS)
local DraggingEnabled = false
local DragTouchStart = nil
local FramePositionStart = nil

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        DraggingEnabled = true
        DragTouchStart = input.Position
        FramePositionStart = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                DraggingEnabled = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if DraggingEnabled and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local DeltaVector = input.Position - DragTouchStart
        MainFrame.Position = UDim2.new(
            FramePositionStart.X.Scale, FramePositionStart.X.Offset + DeltaVector.X,
            FramePositionStart.Y.Scale, FramePositionStart.Y.Offset + DeltaVector.Y
        )
    end
end)

-- Плавное Проявление Интерфейса
TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, 390, 0, 530),
    GroupTransparency = 0
}):Play()

-- Логика Свертывания Панели Управления
local PanelIsMinimized = false

MinButton.MouseButton1Click:Connect(function()
    PanelIsMinimized = not PanelIsMinimized
    local TargetSize = PanelIsMinimized and UDim2.new(0, 390, 0, 45) or UDim2.new(0, 390, 0, 530)
    TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = TargetSize}):Play()
    ScrollContainer.Visible = not PanelIsMinimized
    MinButton.Text = PanelIsMinimized and "+" or "-"
end)

CloseButton.MouseButton1Click:Connect(function()
    local HideTween = TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 390, 0, 0),
        GroupTransparency = 1
    })
    HideTween:Play()
    HideTween.Completed:Connect(function()
        ScreenGui:Destroy()
    end)
end)

-- Конструктор Функциональных Физических Блоков
local function GeneratePhysicsControllerBlock(BlockId, RussianTitle)
    local ModuleFrame = Instance.new("Frame")
    ModuleFrame.Size = UDim2.new(1, -8, 0, 72)
    ModuleFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
    ModuleFrame.BorderSizePixel = 0
    ModuleFrame.LayoutOrder = BlockId
    ModuleFrame.Parent = ScrollContainer
    
    local FrameCorner = Instance.new("UICorner")
    FrameCorner.CornerRadius = UDim.new(0, 6)
    FrameCorner.Parent = ModuleFrame
    
    local TitleText = Instance.new("TextLabel")
    TitleText.Size = UDim2.new(1, -12, 0, 24)
    TitleText.Position = UDim2.new(0, 8, 0, 4)
    TitleText.BackgroundTransparency = 1
    TitleText.Text = BlockId .. ". " .. RussianTitle
    TitleText.TextColor3 = Color3.fromRGB(170, 200, 170)
    TitleText.TextSize = 12
    TitleText.Font = Enum.Font.Code
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.Parent = ModuleFrame
    
    local TriggerButton = Instance.new("TextButton")
    TriggerButton.Size = UDim2.new(1, -16, 0, 34)
    TriggerButton.Position = UDim2.new(0, 8, 0, 30)
    TriggerButton.BackgroundColor3 = Color3.fromRGB(32, 32, 42)
    TriggerButton.BorderSizePixel = 0
    TriggerButton.Text = "СТАТУС: ДЕАКТИВИРОВАН"
    TriggerButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    TriggerButton.TextSize = 11
    TriggerButton.Font = Enum.Font.GothamBold
    TriggerButton.Parent = ModuleFrame
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 4)
    ButtonCorner.Parent = TriggerButton
    
    TriggerButton.MouseButton1Click:Connect(function()
        PhysicsConfig.ModuleStates[BlockId] = not PhysicsConfig.ModuleStates[BlockId]
        local IsActive = PhysicsConfig.ModuleStates[BlockId]
        
        local TargetBgColor = IsActive and Color3.fromRGB(50, 120, 60) or Color3.fromRGB(32, 32, 42)
        local TargetTxtColor = IsActive and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
        local TargetText = IsActive and "СТАТУС: АКТИВЕН" or "СТАТУС: ДЕАКТИВИРОВАН"
        
        TweenService:Create(TriggerButton, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = TargetBgColor,
            TextColor3 = TargetTxtColor
        }):Play()
        
        TriggerButton.Text = TargetText
        TriggerButton.TextSize = IsActive and 12 or 11
        task.wait(0.06)
        TriggerButton.TextSize = 11
    end)
end

-- Инициализация 10 Функциональных Интерфейсов (Раздел C)
local BlockTitles = {
    [1] = "Мониторинг Связей",
    [2] = "Очистка Сил Физики",
    [3] = "Импульс Высвобождения",
    [4] = "Аннигиляция Массы",
    [5] = "Сброс Памяти Координат",
    [6] = "Умная Коррекция Луча",
    [7] = "Авто-Захват Пространства",
    [8] = "Кластеризация Сборок",
    [9] = "Циклический Опрос Сервера",
    [10] = "Фиксация Оси Персонажа"
}

for Id, Title in ipairs(BlockTitles) do
    GeneratePhysicsControllerBlock(Id, Title)
end

-- Раздел B: Логика Нативного Сенсорного Джойстика и Трэкинга HUD Запросов Касания
UserInputService.InputBegan:Connect(function(input, processed)
    if input.UserInputType == Enum.UserInputType.Gamepad1 and input.KeyCode == Enum.KeyCode.Thumbstick1 then
        PhysicsConfig.JoystickActive = true
    end
end)

UserInputService.InputChanged:Connect(function(input, processed)
    if input.UserInputType == Enum.UserInputType.Gamepad1 and input.KeyCode == Enum.KeyCode.Thumbstick1 then
        local Position = input.Position
        PhysicsConfig.JoystickVector = Vector3.new(Position.X, 0, -Position.Y)
        if PhysicsConfig.JoystickVector.Magnitude <= 0.05 then
            PhysicsConfig.JoystickActive = false
        else
            PhysicsConfig.JoystickActive = true
        end
    end
end)

UserInputService.InputEnded:Connect(function(input, processed)
    if input.UserInputType == Enum.UserInputType.Gamepad1 and input.KeyCode == Enum.KeyCode.Thumbstick1 then
        PhysicsConfig.JoystickActive = false
        PhysicsConfig.JoystickVector = Vector3.new(0, 0, 0)
    end
end)

-- МОДУЛЬ 1: Мониторинг Связей ("Мониторинг Связей")
local function SuperviseRigidJoints(Character)
    Character.DescendantAdded:Connect(function(descendant)
        if not PhysicsConfig.ModuleStates[1] then return end
        if descendant:IsA("Weld") or descendant:IsA("ManualWeld") or descendant:IsA("MoverConstraint") then
            task.wait(0.01) -- Сетевое Окно Репликации
            if descendant.Parent then
                local ForeignInitiator = descendant:FindFirstAncestorOfClass("Model")
                if ForeignInitiator and ForeignInitiator ~= Character then
                    pcall(function()
                        ForeignInitiator:BreakJoints()
                    end)
                end
            end
        end
    end)
end

if LocalPlayer.Character then SuperviseRigidJoints(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(SuperviseRigidJoints)

-- МОДУЛЬ 2: Очистка Сил Физики ("Очистка Сил Физики")
RunService.PreSimulation:Connect(function()
    if not PhysicsConfig.ModuleStates[2] then return end
    local Character = LocalPlayer.Character
    if Character then
        local RootPart = Character:FindFirstChild("HumanoidRootPart")
        if RootPart then
            for _, Object in ipairs(RootPart:GetChildren()) do
                if Object:IsA("BodyPosition") or Object:IsA("AlignPosition") or Object:IsA("BodyVelocity") or Object:IsA("LinearVelocity") then
                    Object:Destroy()
                end
            end
        end
    end
end)

-- МОДУЛЬ 3 & 4 Нативные Перехватчики Событий Освобождения Суставов (TouchEnded)
UserInputService.TouchEnded:Connect(function(touch, processed)
    local Character = LocalPlayer.Character
    if not Character then return end
    local RootPart = Character:FindFirstChild("HumanoidRootPart")
    if not RootPart then return end
    
    -- МОДУЛЬ 3: Импульс Высвобождения
    if PhysicsConfig.ModuleStates[3] then
        for AssemblyInstance, IsHeld in pairs(PhysicsConfig.HeldAssemblies) do
            if IsHeld and AssemblyInstance:IsA("BasePart") then
                pcall(function()
                    local VectorDirection = Camera.CFrame.LookVector + Vector3.new(0, 0.15, 0)
                    AssemblyInstance:ApplyImpulse(VectorDirection * 999999000)
                end)
                PhysicsConfig.HeldAssemblies[AssemblyInstance] = nil
            end
        end
    end
    
    -- МОДУЛЬ 4: Аннигиляция Массы
    if PhysicsConfig.ModuleStates[4] then
        for _, Des in ipairs(Character:GetDescendants()) do
            if Des:IsA("BasePart") then
                Des.Massless = true
                Des.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
            end
        end
    end
end)

-- МОДУЛЬ 5: Сброс Памяти Координат ("Сброс Памяти Координат")
RunService.RenderStepped:Connect(function()
    if PhysicsConfig.ModuleStates[5] then
        ReferenceFlushingBuffer.CurrentTargetInstance = nil
        ReferenceFlushingBuffer.ActiveRaycastResult = nil
        ReferenceFlushingBuffer.TemporaryCalculationMatrix = nil
    end
end)

-- МОДУЛЬ 6: Умная Коррекция Луча ("Умная Коррекция Луча")
-- Низкоуровневый системный перехват дескрипторов Метаметода Вызова Направлений Камеры
local RawMeta = getrawmetatable(game)
if RawMeta and make境界writeable then -- Валидация подсистем Delta
    setreadonly(RawMeta, false)
    local OriginalNamecall = RawMeta.__namecall
    RawMeta.__namecall = newcclosure(function(self, ...)
        local Method = getnamecallmethod()
        local Arguments = {...}
        if PhysicsConfig.ModuleStates[6] and (Method == "Raycast" or Method == "FindPartOnRay") then
            local ScreenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            local MinimumRadius = 300
            local SelectedTargetPart = nil
            for _, Player in ipairs(Players:GetPlayers()) do
                if Player ~= LocalPlayer and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                    local TargetRoot = Player.Character.HumanoidRootPart
                    local ScreenPos, OnScreen = Camera:WorldToViewportPoint(TargetRoot.Position)
                    if OnScreen then
                        local DistanceFromCenter = (Vector2.new(ScreenPos.X, ScreenPos.Y) - ScreenCenter).Magnitude
                        if DistanceFromCenter < MinimumRadius then
                            MinimumRadius = DistanceFromCenter
                            SelectedTargetPart = TargetRoot
                        end
                    end
                end
            end
            if SelectedTargetPart then
                local LinearVelocity = SelectedTargetPart.AssemblyLinearVelocity
                local AnticipatedPosition = SelectedTargetPart.Position + (LinearVelocity * 0.14)
                if Method == "Raycast" then
                    Arguments[2] = (AnticipatedPosition - Arguments[1]).Unit * 1000
                elseif Method == "FindPartOnRay" then
                    Arguments[1] = Ray.new(Camera.CFrame.Position, (AnticipatedPosition - Camera.CFrame.Position).Unit * 1000)
                end
                return OriginalNamecall(self, unpack(Arguments))
            end
        end
        return OriginalNamecall(self, ...)
    end)
    setreadonly(RawMeta, true)
end

-- МОДУЛЬ 7: Авто-Захват Пространства ("Авто-Захват Пространства")
task.spawn(function()
    while true do
        task.wait(0.05)
        if PhysicsConfig.ModuleStates[7] then
            local Character = LocalPlayer.Character
            if Character and Character:FindFirstChild("HumanoidRootPart") then
                local LocalRoot = Character.HumanoidRootPart
                for _, Object in ipairs(Workspace:GetDescendants()) do
                    if Object:IsA("BasePart") and not Object.Anchored and not Object:IsDescendantOf(Character) then
                        local DirectDistance = (Object.Position - LocalRoot.Position).Magnitude
                        if DirectDistance <= 15 then
                            InteractionRemote:FireServer(Object)
                        end
                    end
                end
            end
        end
    end
end)

-- МОДУЛЬ 8: Кластеризация Сборок ("Кластеризация Сборок")
task.spawn(function()
    while true do
        task.wait(0.5)
        if PhysicsConfig.ModuleStates[8] then
            local ApplianceModel = Workspace:FindFirstChild("Microwave")
            if not ApplianceModel then
                EquipmentRemote:FireServer("SpawnUtilityModel", "Microwave")
                task.wait(0.1)
                ApplianceModel = Workspace:FindFirstChild("Microwave")
            end
            if ApplianceModel and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local Root = LocalPlayer.Character.HumanoidRootPart
                local OriginalCFrame = Root.CFrame
                for _, TargetPlayer in ipairs(Players:GetPlayers()) do
                    if TargetPlayer ~= LocalPlayer and TargetPlayer.Character and TargetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local TargetRoot = TargetPlayer.Character.HumanoidRootPart
                        Root.CFrame = TargetRoot.CFrame
                        task.wait(0.01)
                        InteractionRemote:FireServer(TargetPlayer.Character)
                        for _, Part in ipairs(TargetPlayer.Character:GetDescendants()) do
                            if Part:IsA("BasePart") then
                                Part.CanCollide = false
                                local AlignConstraint = Instance.new("AlignPosition")
                                AlignConstraint.MaxForce = 99999999
                                AlignConstraint.Responsiveness = 200
                                AlignConstraint.Mode = Enum.PositionAlignmentMode.OneAttachment
                                AlignConstraint.Attachment0 = Part:FindFirstChildOfClass("Attachment") or Instance.new("Attachment", Part)
                                AlignConstraint.Position = ApplianceModel:GetAttribute("CenterPosition") or ApplianceModel.PrimaryPart.Position
                                AlignConstraint.Parent = Part
                                Part.AssemblyLinearVelocity = Vector3.new(0, -90000, 0)
                            end
                        end
                    end
                end
                Root.CFrame = OriginalCFrame
            end
        end
    end
end)

-- МОДУЛЬ 9: Циклический Опрос Сервера ("Циклический Опрос Сервера")
task.spawn(function()
    while true do
        task.wait(0.2)
        if PhysicsConfig.ModuleStates[9] then
            task.spawn(function()
                local Character = LocalPlayer.Character
                if Character and Character:FindFirstChild("HumanoidRootPart") then
                    local Root = Character.HumanoidRootPart
                    local PriorPosition = Root.CFrame
                    for _, RemoteTarget in ipairs(Players:GetPlayers()) do
                        if RemoteTarget ~= LocalPlayer and RemoteTarget.Character and RemoteTarget.Character:FindFirstChild("HumanoidRootPart") then
                            local EnemyRoot = RemoteTarget.Character.HumanoidRootPart
                            Root.CFrame = EnemyRoot.CFrame * CFrame.new(0, 0, 1)
                            task.wait(0.01)
                            InteractionRemote:FireServer(RemoteTarget.Character)
                            if EnemyRoot:IsA("BasePart") then
                                local DirectionalPush = Camera.CFrame.LookVector + Vector3.new(0, 0.15, 0)
                                EnemyRoot:ApplyImpulse(DirectionalPush * 999999000)
                            end
                        end
                    end
                    Root.CFrame = PriorPosition
                end
            end)
        end
    end
end)

-- МОДУЛЬ 10: Фиксация Оси Персонажа ("Фиксация Оси Персонажа")
local function AttachStateLock(Character)
    local Humanoid = Character:WaitForChild("Humanoid", 5)
    if Humanoid then
        Humanoid.StateChanged:Connect(function(oldState, newState)
            if not PhysicsConfig.ModuleStates[10] then return end
            if PhysicsConfig.JoystickActive then
                if newState == Enum.HumanoidStateType.Ragdoll or newState == Enum.HumanoidStateType.FallingDown or newState == Enum.HumanoidStateType.Tripping then
                    Humanoid:ChangeState(Enum.HumanoidStateType.Running)
                    local Root = Character:FindFirstChild("HumanoidRootPart")
                    if Root then
                        Root.CFrame = CFrame.lookAt(Root.Position, Root.Position + PhysicsConfig.JoystickVector)
                    end
                end
            end
        end)
    end
end

if LocalPlayer.Character then AttachStateLock(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(AttachStateLock)
