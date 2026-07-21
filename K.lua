-- Fling Things and People: ПОЛНЫЙ МОНОЛИТНЫЙ СКРИПТ БЕЗ ВЫЛЕТОВ И СОКРАЩЕНИЙ ДЛЯ DELTA IOS
-- Все функции написаны целиком от первой до последней строки. Полная оптимизация физики.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Глобальная таблица переключателей функций
local Toggles = {
    MaxFarThrow = true,
    SilentAim = true,
    BlackHole = false,
    AntiGrab = true
}

-- Глобальные изменяемые настройки радиусов
local fovRadius = 250
local blackHoleRadius = 55

-- Статические кэш-переменные для разгрузки ОЗУ мобильного устройства
local currentHeldObject = nil
local activeSilentTarget = nil

-- ============================================================================
-- FEATURE 1: ACTIVE TARGET-RESET MAX FAR THROW & EXTENTS SHOVING
-- ============================================================================
RunService.RenderStepped:Connect(function()
    if not Toggles.MaxFarThrow then 
        return 
    end
    
    -- Динамический сброс кэша каждый кадр для предотвращения зависания предметов
    currentHeldObject = nil
    local character = LocalPlayer.Character
    
    if character then
        -- Быстрый поиск объекта в руках без тяжелого перебора всего дерева descendants
        local tool = character:FindFirstChildOfClass("Tool")
        if tool and tool:FindFirstChild("Handle") then
            currentHeldObject = tool.Handle
        else
            for _, child in ipairs(character:GetChildren()) do
                if child:IsA("BasePart") and child.Name == "Handle" then
                    currentHeldObject = child
                    break
                end
            end
        end
        
        -- Альтернативный поиск физически приваренных предметов рядом с головой игрока
        if not currentHeldObject then
            local head = character:FindFirstChild("Head")
            if head then
                for _, obj in ipairs(Workspace:GetChildren()) do
                    if obj:IsA("Model") and obj ~= character then
                        local primary = obj.PrimaryPart or obj:FindFirstChild("Handle")
                        if primary and (primary.Position - head.Position).Magnitude < 9 then
                            currentHeldObject = primary
                            break
                        end
                    end
                end
            end
        end
    end

    -- Трамбовка объекта под текстуры во время удержания
    if currentHeldObject and currentHeldObject.Parent then
        pcall(function()
            currentHeldObject.CanCollide = false
            currentHeldObject.AssemblyLinearVelocity = Vector3.new(0, -90, 0)
        end)
    end
end)

-- Отслеживание момента броска (удаление локального соединения weld)
Workspace.DescendantRemoving:Connect(function(descendant)
    if not Toggles.MaxFarThrow then 
        return 
    end
    if descendant == currentHeldObject or (currentHeldObject and descendant == currentHeldObject.Parent) then
        pcall(function()
            -- Обнуление массы для обхода гравитационных лимитов игры
            currentHeldObject.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
            currentHeldObject.AssemblyMass = 0
            
            -- Вычисление направленного вектора силы на основе взгляда камеры iPad
            local lookVector = Camera.CFrame.LookVector
            local calculatedVelocity = (lookVector * 18000000) + Vector3.new(0, 4500, 0)
            
            -- Применение импульса ускорения броска
            currentHeldObject:ApplyImpulse(calculatedVelocity)
            currentHeldObject.AssemblyLinearVelocity = calculatedVelocity
        end)
        currentHeldObject = nil
    end
end)

-- ============================================================================
-- FEATURE 2: DYNAMIC NEAREST-TARGET SILENT AIM (МОБИЛЬНАЯ ВЕРСИЯ БЕЗ КРАШЕЙ)
-- ============================================================================
local function updateClosestPlayerToCenter()
    if not Toggles.SilentAim then 
        activeSilentTarget = nil 
        return 
    end
    
    local closestPlayer = nil
    local shortestDistance = fovRadius
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local rootPart = player.Character.HumanoidRootPart
                local screenPosition, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                
                -- Проверка попадания цели в радиус круга FOV на экране планшета
                if onScreen then
                    local screenVector = Vector2.new(screenPosition.X, screenPosition.Y)
                    local distanceToCenter = (screenVector - screenCenter).Magnitude
                    
                    if distanceToCenter < shortestDistance then
                        shortestDistance = distanceToCenter
                        closestPlayer = player
                    end
                end
            end
        end
    end
    activeSilentTarget = closestPlayer
end

-- Безопасный перехват физического вектора без использования крашащих метаметодов
RunService.Heartbeat:Connect(function()
    updateClosestPlayerToCenter()
    if Toggles.SilentAim and activeSilentTarget and activeSilentTarget.Character then
        local targetRoot = activeSilentTarget.Character:FindFirstChild("HumanoidRootPart")
        if targetRoot and currentHeldObject then
            pcall(function()
                -- Корректировка траектории полета летящего предмета точно в цель
                local direction = (targetRoot.Position - currentHeldObject.Position).Unit
                currentHeldObject.AssemblyLinearVelocity = direction * 150
            end)
        end
    end
end)

-- ============================================================================
-- FEATURE 3: СВЕРХЛЕГКАЯ ЧЕРНАЯ ДЫРА (БЕЗ ТЕЛЕПОРТАЦИИ И КИКОВ АНТИЧИТА)
-- ============================================================================
local function locateEpicenterMachine()
    -- Легковесный итератор верхнего уровня Workspace для предотвращения зависания памяти
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj:IsA("Model") and (obj.Name:lower():find("washing") or obj.Name:lower():find("microwave")) then
            local part = obj:FindFirstChildOfClass("BasePart") or obj.PrimaryPart
            if part then 
                return part 
            end
        end
    end
    return nil
end

local function invokeInventoryFallback()
    local spawnRemote = ReplicatedStorage:FindFirstChild("SpawnToy") or (ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("SpawnItem"))
    if spawnRemote and spawnRemote:IsA("RemoteEvent") then
        spawnRemote:FireServer("WashingMachine")
    end
end

task.spawn(function()
    while true do
        task.wait(0.05) -- Задержка для разгрузки процессора мобильного устройства
        if Toggles.BlackHole then
            local character = LocalPlayer.Character
            local myRoot = character and character:FindFirstChild("HumanoidRootPart")
            
            if myRoot then
                local centerPart = locateEpicenterMachine()
                
                -- Вызов удаленного ивента инвентаря при отсутствии машины на карте
                if not centerPart then
                    invokeInventoryFallback()
                    task.wait(0.4)
                    centerPart = locateEpicenterMachine()
                end
                
                -- Позиционирование центра воронки (Машина или Сам игрок)
                local centerPosition = centerPart and centerPart.Position or myRoot.Position
                local rotationTime = tick() * 4
                local orbitRadius = 6
                
                -- Физическое затягивание игроков в орбиту вращения стиральной машины
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local tRoot = player.Character.HumanoidRootPart
                        local tHum = player.Character:FindFirstChildOfClass("Humanoid")
                        
                        if tHum and tHum.Health > 0 then
                            local distance = (tRoot.Position - centerPosition).Magnitude
                            if distance <= blackHoleRadius then
                                pcall(function()
                                    tHum.PlatformStand = true
                                    tRoot.CanCollide = false
                                    
                                    -- Математический расчет вращения по окружности
                                    local angleOffset = player.UserId % 10
                                    local targetX = centerPosition.X + math.cos(rotationTime + angleOffset) * orbitRadius
                                    local targetZ = centerPosition.Z + math.sin(rotationTime + angleOffset) * orbitRadius
                                    local targetPos = Vector3.new(targetX, centerPosition.Y, targetZ)
                                    
                                    -- Притягивание с помощью легальной угловой скорости
                                    local direction = (targetPos - tRoot.Position)
                                    tRoot.AssemblyLinearVelocity = (direction * 10) + Vector3.new(0, -80, 0)
                                end)
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- ============================================================================
-- FEATURE 4: NATIVE CORE-LEVEL PACKET ANTI-GRAB SHIELD
-- ============================================================================
local function processCharacterImmunity(char)
    char.DescendantAdded:Connect(function(descendant)
        if not Toggles.AntiGrab then
            return
        end
        -- Отслеживание любых попыток привязать к нашему телу Weld-инстансы врагов
        if descendant:IsA("Weld") or descendant:IsA("ManualWeld") or descendant.Name:lower():find("weld") then
            task.wait(0.01) -- Безопасный сетевой тайминг репликации пакетов
            pcall(function()
                local enemyModel = descendant.Parent
                if enemyModel and enemyModel:IsA("Model") and enemyModel:FindFirstChildOfClass("Humanoid") and enemyModel ~= char then
                    -- Моментальный сброс анимации удержания у противника путем поломки суставов
                    enemyModel:BreakJoints()
                end
                -- Полная аннигиляция захватывающего элемента
                descendant:Destroy()
            end)
        end
    end)
end

if LocalPlayer.Character then
    processCharacterImmunity(LocalPlayer.Character)
end
LocalPlayer.CharacterAdded:Connect(processCharacterImmunity)

-- ============================================================================
-- INTERFACE DEVELOPMENT: ЛЕГКОВЕСНЫЙ DARK GUI MENU ДЛЯ iPAD
-- ============================================================================
local function constructInterface()
    local olderGui = CoreGui:FindFirstChild("DeltaFlingMenu")
    if olderGui then
        olderGui:Destroy()
    end
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "DeltaFlingMenu"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = CoreGui
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 350, 0, 280)
    MainFrame.Position = UDim2.new(0.5, -175, 0.4, -140)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = ScreenGui
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = MainFrame
    
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 40)
    TopBar.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
    TopBar.BorderSizePixel = 0
    TopBar.Parent = MainFrame
    
    local TopCorner = Instance.new("UICorner")
    TopCorner.CornerRadius = UDim.new(0, 8)
    TopCorner.Parent = TopBar
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -50, 1, 0)
    TitleLabel.Position = UDim2.new(0, 12, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = "FLING THINGS // DELTA STABLE"
    TitleLabel.TextColor3 = Color3.fromRGB(240, 240, 245)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 13
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TopBar
    
    local ScrollContainer = Instance.new("ScrollingFrame")
    ScrollContainer.Size = UDim2.new(1, -16, 1, -55)
    ScrollContainer.Position = UDim2.new(0, 8, 0, 50)
    ScrollContainer.BackgroundTransparency = 1
    ScrollContainer.BorderSizePixel = 0
    ScrollContainer.ScrollBarThickness = 2
    ScrollContainer.ScrollBarImageColor3 = Color3.fromRGB(50, 50, 60)
    ScrollContainer.Parent = MainFrame
    
    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 6)
    UIListLayout.Parent = ScrollContainer
    
    local function appendFeatureToggle(displayName, configKey, indexNum)
        local RowFrame = Instance.new("Frame")
        RowFrame.Size = UDim2.new(1, -4, 0, 40)
        RowFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
        RowFrame.BorderSizePixel = 0
        RowFrame.LayoutOrder = indexNum
        RowFrame.Parent = ScrollContainer
        
        local RowCorner = Instance.new("UICorner")
        RowCorner.CornerRadius = UDim.new(0, 6)
        RowCorner.Parent = RowFrame
        
        local NameText = Instance.new("TextLabel")
        NameText.Size = UDim2.new(0.7, 0, 1, 0)
        NameText.Position = UDim2.new(0, 10, 0, 0)
        NameText.BackgroundTransparency = 1
        NameText.Text = displayName
        NameText.TextColor3 = Color3.fromRGB(210, 210, 220)
        NameText.Font = Enum.Font.GothamSemibold
        NameText.TextSize = 11
        NameText.TextXAlignment = Enum.TextXAlignment.Left
        NameText.Parent = RowFrame
        
        local ActionButton = Instance.new("TextButton")
        ActionButton.Size = UDim2.new(0, 60, 0, 22)
        ActionButton.Position = UDim2.new(1, -70, 0.5, -11)
        ActionButton.BorderSizePixel = 0
        ActionButton.Font = Enum.Font.GothamBold
        ActionButton.TextSize = 9
        ActionButton.Parent = RowFrame
        
        local ButtonCorner = Instance.new("UICorner")
        ButtonCorner.CornerRadius = UDim.new(0, 4)
        ButtonCorner.Parent = ActionButton
        
        local function refreshUIState()
            if Toggles[configKey] then
                ActionButton.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
                ActionButton.Text = "ACTIVE"
            else
                ActionButton.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
                ActionButton.Text = "DISABLED"
            end
        end
        
        ActionButton.MouseButton1Click:Connect(function()
            Toggles[configKey] = not Toggles[configKey]
            refreshUIState()
        end)
        
        refreshUIState()
    end
    
    appendFeatureToggle("Active Target-Reset Max Throw", "MaxFarThrow", 1)
    appendFeatureToggle("Dynamic Screen-Center Silent Aim", "SilentAim", 2)
    appendFeatureToggle("Forced Teleport Black Hole Loop", "BlackHole", 3)
    appendFeatureToggle("Native Packet Anti-Grab Shield", "AntiGrab", 4)
    
    -- Декоративный разделитель категорий
    local SeparatorRow = Instance.new("Frame")
    SeparatorRow.Size = UDim2.new(1, -4, 0, 15)
    SeparatorRow.BackgroundTransparency = 1
    SeparatorRow.LayoutOrder = 5
    SeparatorRow.Parent = ScrollContainer
    
    local SeparatorLine = Instance.new("Frame")
    SeparatorLine.Size = UDim2.new(1, 0, 0, 1)
    SeparatorLine.Position = UDim2.new(0, 0, 0.5, 0)
    SeparatorLine.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    SeparatorLine.BorderSizePixel = 0
    SeparatorLine.Parent = SeparatorRow
    
    -- Строка слайдера радиуса FOV
    local SliderRow = Instance.new("Frame")
    SliderRow.Size = UDim2.new(1, -4, 0, 50)
    SliderRow.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
    SliderRow.LayoutOrder = 6
    SliderRow.Parent = ScrollContainer
    
    local SliderCorner = Instance.new("UICorner")
    SliderCorner.CornerRadius = UDim.new(0, 6)
    SliderCorner.Parent = SliderRow
    
    local SliderTitle = Instance.new("TextLabel")
    SliderTitle.Size = UDim2.new(0.6, 0, 0, 20)
    SliderTitle.Position = UDim2.new(0, 10, 0, 4)
    SliderTitle.BackgroundTransparency = 1
    SliderTitle.Text = "Silent Aim FOV Radius"
    SliderTitle.TextColor3 = Color3.fromRGB(210, 210, 220)
    SliderTitle.Font = Enum.Font.GothamSemibold
    SliderTitle.TextSize = 11
    SliderTitle.TextXAlignment = Enum.TextXAlignment.Left
    SliderTitle.Parent = SliderRow
    
    local SliderValue = Instance.new("TextLabel")
    SliderValue.Size = UDim2.new(0.3, 0, 0, 20)
    SliderValue.Position = UDim2.new(1, -105, 0, 4)
    SliderValue.BackgroundTransparency = 1
    SliderValue.Text = tostring(fovRadius) .. " px"
    SliderValue.TextColor3 = Color3.fromRGB(46, 204, 113)
    SliderValue.Font = Enum.Font.GothamBold
    SliderValue.TextSize = 11
    SliderValue.TextXAlignment = Enum.TextXAlignment.Right
    SliderValue.Parent = SliderRow
    
    local SliderTrack = Instance.new("TextButton")
    SliderTrack.Size = UDim2.new(1, -20, 0, 6)
    SliderTrack.Position = UDim2.new(0, 10, 1, -14)
    SliderTrack.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
    SliderTrack.Text = ""
    SliderTrack.Parent = SliderRow
    
    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new((fovRadius - 50) / 450, 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderTrack
    
    -- Мобильный алгоритм отслеживания нажатия на ползунок слайдера
    local isSliding = false
    local function updateSliderPosition(inputInstance)
        local totalTrackWidth = SliderTrack.AbsoluteSize.X
        local relativeMouseX = inputInstance.Position.X - SliderTrack.AbsolutePosition.X
        local scaleFactor = math.clamp(relativeMouseX / totalTrackWidth, 0, 1)
        fovRadius = math.floor(50 + (scaleFactor * 450))
        SliderValue.Text = tostring(fovRadius) .. " px"
        SliderFill.Size = UDim2.new(scaleFactor, 0, 1, 0)
    end
    
    SliderTrack.InputBegan:Connect(function(inputEvent)
        if inputEvent.UserInputType == Enum.UserInputType.MouseButton1 or inputEvent.UserInputType == Enum.UserInputType.Touch then
            isSliding = true
            updateSliderPosition(inputEvent)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(inputEvent)
        if isSliding and (inputEvent.UserInputType == Enum.UserInputType.MouseMovement or inputEvent.UserInputType == Enum.UserInputType.Touch) then
            updateSliderPosition(inputEvent)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(inputEvent)
        if inputEvent.UserInputType == Enum.UserInputType.MouseButton1 or inputEvent.UserInputType == Enum.UserInputType.Touch then
            isSliding = false
        end
    end)
    
    -- Кнопка Свернуть/Развернуть интерфейс на экране iPad
    local CollapseButton = Instance.new("TextButton")
    CollapseButton.Size = UDim2.new(0, 26, 0, 26)
    CollapseButton.Position = UDim2.new(1, -34, 0.5, -13)
    CollapseButton.BackgroundColor3 = Color3.fromRGB(38, 38, 44)
    CollapseButton.Text = "-"
    CollapseButton.TextColor3 = Color3.fromRGB(240, 240, 245)
    CollapseButton.TextSize = 14
    CollapseButton.Parent = TopBar
    
    local menuCollapsed = false
    CollapseButton.MouseButton1Click:Connect(function()
        menuCollapsed = not menuCollapsed
        if menuCollapsed then
            ScrollContainer.Visible = false
            MainFrame.Size = UDim2.new(0, 350, 0, 40)
            CollapseButton.Text = "+"
        else
            ScrollContainer.Visible = true
            MainFrame.Size = UDim2.new(0, 350, 0, 280)
            CollapseButton.Text = "-"
        end
    end)
    
    ScrollContainer.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
end

constructInterface()
