-- Подключение основных системных служб Roblox
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService") -- Используется для точного центрирования на iPad Pro

-- Определение локального игрока и камеры
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

-- ==========================================
-- 1. ГЛОБАЛЬНЫЕ НАСТРОЙКИ И СОСТОЯНИЯ
-- ==========================================
local currentRadius = 100               -- Текущий радиус FOV круга в пикселях
local aimMode = "Обычный"               -- Текущий режим: "Обычный", "Сайлент", "Выкл"
local selectedKnife = "Стандартный"     -- Выбранный нож в локальном меню кастомизации
local colorVisible = Color3.fromRGB(0, 255, 0)   -- Цвет для противников на виду (Зеленый)
local colorHidden = Color3.fromRGB(255, 0, 0)    -- Цвет для противников за укрытием (Красный)

-- Таблица доступных скинов ножей для циклического переключения в меню
local knivesList = {
    "Стандартный",
    "M9 Bayonet",
    "Нож-Бабочка (Butterfly)",
    "Керамбит (Karambit)",
    "Охотничий нож (Huntsman)",
    "Тычковые ножи (Shadow Daggers)"
}
local currentKnifeIndex = 1

-- ==========================================
-- 2. СОЗДАНИЕ ГЛАВНОГО ИНТЕРФЕЙСА (GUI)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "iPadProPerfectEspHud"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true -- Игнорируем стандартный отступ для ручного точного просчета центра
ScreenGui.Parent = PlayerGui

-- Верхняя информационная панель со статистикой игроков в матче
local StatsPanel = Instance.new("Frame")
StatsPanel.Name = "StatsPanel"
StatsPanel.Size = UDim2.new(0, 360, 0, 45)
StatsPanel.Position = UDim2.new(0.5, -180, 0, 20) -- Размещаем по центру вверху экрана
StatsPanel.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
StatsPanel.BackgroundTransparency = 0.3
StatsPanel.BorderSizePixel = 0
StatsPanel.Parent = ScreenGui

local StatsCorner = Instance.new("UICorner")
StatsCorner.CornerRadius = UDim.new(0, 8)
StatsCorner.Parent = StatsPanel

local StatsText = Instance.new("TextLabel")
StatsText.Name = "StatsText"
StatsText.Size = UDim2.new(1, 0, 1, 0)
StatsText.BackgroundTransparency = 1
StatsText.Text = "Врагов видно: 0  |  За стеной: 0  |  Всего: 0"
StatsText.TextColor3 = Color3.fromRGB(255, 255, 255)
StatsText.TextSize = 14
StatsText.Font = Enum.Font.SourceSansBold
StatsText.Parent = StatsPanel

-- Круг FOV (Прицел идеально по центру экрана для iPad 11 Pro)
local FovCircle = Instance.new("Frame")
FovCircle.Name = "FovCircle"
FovCircle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
FovCircle.BackgroundTransparency = 0.88
FovCircle.BorderSizePixel = 0
FovCircle.Parent = ScreenGui

local CircleCorner = Instance.new("UICorner")
CircleCorner.CornerRadius = UDim.new(1, 0) -- Делает квадратный Frame идеальным кругом
CircleCorner.Parent = FovCircle

-- Функция динамического пересчета центра экрана с компенсацией статус-бара iOS
local function updateCirclePosition()
    local viewportSize = Camera.ViewportSize
    local insetTop, insetBottom = GuiService:GetGuiInset()
    
    -- Математический просчет физического центра экрана планшета
    local centerX = viewportSize.X / 2
    local centerY = (viewportSize.Y + insetTop) / 2
    
    FovCircle.Size = UDim2.new(0, currentRadius * 2, 0, currentRadius * 2)
    FovCircle.Position = UDim2.new(0, centerX - currentRadius, 0, centerY - currentRadius)
end

-- Инициализация позиции круга и привязка к изменению разрешения экрана
updateCirclePosition()
Camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateCirclePosition)

-- ==========================================
-- 3. ПЕРЕТАСКИВАЕМАЯ КНОПКА МЕНЮ (ДЛЯ IPAD)
-- ==========================================
local MenuButton = Instance.new("TextButton")
MenuButton.Name = "ToggleMenuButton"
MenuButton.Size = UDim2.new(0, 55, 0, 55)
MenuButton.Position = UDim2.new(0, 25, 0, 160) -- Начальная позиция слева на экране
MenuButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MenuButton.Text = "⚙️"
MenuButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MenuButton.TextSize = 24
MenuButton.Parent = ScreenGui

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0.3, 0)
ButtonCorner.Parent = MenuButton

-- Реализация плавного Drag-and-Drop пальцем на сенсорном экране
local dragging = false
local dragInput = nil
local dragStart = nil
local startPos = nil

local function updateDrag(input)
    local delta = input.Position - dragStart
    MenuButton.Position = UDim2.new(
        startPos.X.Scale, 
        startPos.X.Offset + delta.X, 
        startPos.Y.Scale, 
        startPos.Y.Offset + delta.Y
    )
end

MenuButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MenuButton.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

MenuButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        updateDrag(input)
    end
end)

-- ==========================================
-- 4. ГЛАВНОЕ ОКНО НАСТРОЕК (МЕНЮ)
-- ==========================================
local MainMenu = Instance.new("Frame")
MainMenu.Name = "MainMenu"
MainMenu.Size = UDim2.new(0, 300, 0, 280)
MainMenu.Position = UDim2.new(0.5, -150, 0.5, -140) -- По центру экрана
MainMenu.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainMenu.Visible = false -- Изначально скрыто
MainMenu.Parent = ScreenGui

local MenuCorner = Instance.new("UICorner")
MenuCorner.CornerRadius = UDim.new(0, 12)
MenuCorner.Parent = MainMenu

local MenuTitle = Instance.new("TextLabel")
MenuTitle.Name = "MenuTitle"
MenuTitle.Size = UDim2.new(1, 0, 0, 40)
MenuTitle.BackgroundTransparency = 1
MenuTitle.Text = "Панель Разработчика HUD"
MenuTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
MenuTitle.TextSize = 16
MenuTitle.Font = Enum.Font.SourceSansBold
MenuTitle.Parent = MainMenu

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.BackgroundTransparency = 1
CloseButton.Text = "❌"
CloseButton.TextColor3 = Color3.fromRGB(255, 90, 90)
CloseButton.TextSize = 16
CloseButton.Parent = MainMenu

-- Открытие и закрытие меню по нажатиям кнопок
CloseButton.MouseButton1Click:Connect(function()
    MainMenu.Visible = false
end)

MenuButton.MouseButton1Click:Connect(function()
    MainMenu.Visible = not MainMenu.Visible
end)

-- Вкладка 1: Кнопка циклического переключения режимов работы прицеливания
local ModeButton = Instance.new("TextButton")
ModeButton.Name = "ModeButton"
ModeButton.Size = UDim2.new(0.9, 0, 0, 40)
ModeButton.Position = UDim2.new(0.05, 0, 0, 50)
ModeButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ModeButton.Text = "Режим: Обычный Аим (Голова/Тело)"
ModeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ModeButton.TextSize = 13
ModeButton.Font = Enum.Font.SourceSansBold
ModeButton.Parent = MainMenu
Instance.new("UICorner", ModeButton).CornerRadius = UDim.new(0, 6)

ModeButton.MouseButton1Click:Connect(function()
    if aimMode == "Обычный" then
        aimMode = "Сайлент"
        ModeButton.Text = "Режим: Сайлент Аим (Только Голова)"
        ModeButton.BackgroundColor3 = Color3.fromRGB(130, 40, 40) -- Красный оттенок для Сайлента
    elseif aimMode == "Сайлент" then
        aimMode = "Выкл"
        ModeButton.Text = "Режим Аима: ОТКЛЮЧЕН"
        ModeButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    else
        aimMode = "Обычный"
        ModeButton.Text = "Режим: Обычный Аим (Голова/Тело)"
        ModeButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    end
end)

-- Вкладка 2: Настройка ползунка изменения радиуса круга
local SliderLabel = Instance.new("TextLabel")
SliderLabel.Name = "SliderLabel"
SliderLabel.Size = UDim2.new(1, 0, 0, 20)
SliderLabel.Position = UDim2.new(0, 0, 0, 105)
SliderLabel.BackgroundTransparency = 1
SliderLabel.Text = "Радиус FOV круга: " .. currentRadius .. "px"
SliderLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
SliderLabel.TextSize = 13
SliderLabel.Parent = MainMenu

local SliderBar = Instance.new("Frame")
SliderBar.Name = "SliderBar"
SliderBar.Size = UDim2.new(0.8, 0, 0, 6)
SliderBar.Position = UDim2.new(0.1, 0, 0, 135)
SliderBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SliderBar.BorderSizePixel = 0
SliderBar.Parent = MainMenu
Instance.new("UICorner", SliderBar).CornerRadius = UDim.new(1, 0)

local SliderBtn = Instance.new("TextButton")
SliderBtn.Name = "SliderBtn"
SliderBtn.Size = UDim2.new(0, 18, 0, 18)
SliderBtn.Position = UDim2.new(0.4, 0, -1, 0)
SliderBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
SliderBtn.Text = ""
SliderBtn.Parent = SliderBar
Instance.new("UICorner", SliderBtn).CornerRadius = UDim.new(1, 0)

local sliderDragging = false

SliderBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        sliderDragging = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        sliderDragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if sliderDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local barAbsPos = SliderBar.AbsolutePosition.X
        local barAbsSize = SliderBar.AbsoluteSize.X
        local touchX = input.Position.X
        
        local relativeX = math.clamp((touchX - barAbsPos) / barAbsSize, 0, 1)
        SliderBtn.Position = UDim2.new(relativeX, -9, -1, 0)
        
        -- Масштабирование радиуса от 30 до 250 пикселей
        currentRadius = math.floor(30 + (relativeX * 220))
        SliderLabel.Text = "Радиус FOV круга: " .. currentRadius .. "px"
        updateCirclePosition()
    end
end)

-- Вкладка 3: Локальный скинченджер ножей
local KnifeButton = Instance.new("TextButton")
KnifeButton.Name = "KnifeButton"
KnifeButton.Size = UDim2.new(0.9, 0, 0, 40)
KnifeButton.Position = UDim2.new(0.05, 0, 0, 165)
KnifeButton.BackgroundColor3 = Color3.fromRGB(30, 60, 90)
KnifeButton.Text = "Модель ножа: Стандартный"
KnifeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
KnifeButton.TextSize = 13
KnifeButton.Font = Enum.Font.SourceSansBold
KnifeButton.Parent = MainMenu
Instance.new("UICorner", KnifeButton).CornerRadius = UDim.new(0, 6)

KnifeButton.MouseButton1Click:Connect(function()
    currentKnifeIndex = currentKnifeIndex + 1
    if currentKnifeIndex > #knivesList then
        currentKnifeIndex = 1
    end
    selectedKnife = knivesList[currentKnifeIndex]
    KnifeButton.Text = "Модель ножа: " .. selectedKnife
end)

-- Информационная подпись внизу меню
local FooterLabel = Instance.new("TextLabel")
FooterLabel.Name = "FooterLabel"
FooterLabel.Size = UDim2.new(0.9, 0, 0, 40)
FooterLabel.Position = UDim2.new(0.05, 0, 0, 220)
FooterLabel.BackgroundTransparency = 1
FooterLabel.Text = "Скрипт автоматически фильтрует союзников. Модификация скинов применяется локально на уровне рендеринга HUD интерфейса."
FooterLabel.TextColor3 = Color3.fromRGB(140, 140, 140)
FooterLabel.TextSize = 11
FooterLabel.TextWrapped = true
FooterLabel.Font = Enum.Font.SourceSansItalic
FooterLabel.Parent = MainMenu

-- ==========================================
-- 5. МАТЕМАТИЧЕСКИЕ ФУНКЦИИ И ПРОВЕРКИ СТЕН
-- ==========================================
local function getTargetPart(character, targetMode)
    -- Режим Сайлент наводится СТРОГО на голову. Обычный режим может наводиться на торс
    if targetMode == "Сайлент" then
        return character:FindFirstChild("Head")
    else
        return character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
    end
end

local function checkWallVisibility(targetCharacter, targetPart)
    if not targetPart or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("Head") then
        return false
    end
    
    local rayOrigin = Camera.CFrame.Position
    local rayDirection = (targetPart.Position - rayOrigin)
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    -- Исключаем из трассировки луча себя и саму проверяемую цель, ищем только стены
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, targetCharacter}
    
    local result = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
    -- Если луч чистый и ни обо что не ударился — противник находится в прямой видимости
    return result == nil
end

-- ==========================================
-- 6. ОБНОВЛЕНИЕ ESP, МЕТОК ДИСТАНЦИИ И HP БАРА
-- ==========================================
local function updatePlayerEsp(player, character, isVisible)
    local head = character:FindFirstChild("Head")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not head or not humanoid then return end
    
    -- Поиск или создание BillboardGui над головой персонажа
    local billboardGui = head:FindFirstChild("BlockStrikeEspGui")
    if not billboardGui then
        billboardGui = Instance.new("BillboardGui")
        billboardGui.Name = "BlockStrikeEspGui"
        billboardGui.Size = UDim2.new(0, 140, 0, 45)
        billboardGui.StudsOffset = Vector3.new(0, 3, 0)
        billboardGui.AlwaysOnTop = true -- Позволяет тексту отображаться поверх игровых стен
        
        -- Текстовая метка имени игрока и дистанции в метрах
        local infoLabel = Instance.new("TextLabel")
        infoLabel.Name = "InfoLabel"
        infoLabel.Size = UDim2.new(1, 0, 0, 20)
        infoLabel.BackgroundTransparency = 1
        infoLabel.Font = Enum.Font.SourceSansBold
        infoLabel.TextSize = 13
        infoLabel.Parent = billboardGui
        
        -- Задняя подложка (фон) для индикатора здоровья
        local hpBackground = Instance.new("Frame")
        hpBackground.Name = "HpBackground"
        hpBackground.Size = UDim2.new(0.8, 0, 0, 4)
        hpBackground.Position = UDim2.new(0.1, 0, 0, 22)
        hpBackground.BackgroundColor3 = Color3.fromRGB(60, 10, 10)
        hpBackground.BorderSizePixel = 0
        hpBackground.Parent = billboardGui
        
        -- Активная зеленая полоска здоровья (HealthBar)
        local hpBar = Instance.new("Frame")
        hpBar.Name = "HpBar"
        hpBar.Size = UDim2.new(1, 0, 1, 0)
        hpBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        hpBar.BorderSizePixel = 0
        hpBar.Parent = hpBackground
        
        billboardGui.Parent = head
    end
    
    -- Расчет расстояния от локального игрока до цели
    local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local targetHrp = character:FindFirstChild("HumanoidRootPart")
    local distanceStuds = 0
    if myHrp and targetHrp then
        distanceStuds = (targetHrp.Position - myHrp.Position).Magnitude
    end
    
    -- Форматирование и вывод текста
    billboardGui.InfoLabel.Text = string.format("%s [%dм]", player.Name, math.floor(distanceStuds))
    billboardGui.InfoLabel.TextColor3 = isVisible and colorVisible or colorHidden
    
    -- Обновление масштаба шкалы HP бар (от 0 до 1)
    local healthRatio = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
    billboardGui.HpBackground.HpBar.Size = UDim2.new(healthRatio, 0, 1, 0)
    -- Плавный переход цвета HP бара (зеленый -> желтый -> красный) в зависимости от здоровья
    billboardGui.HpBackground.HpBar.BackgroundColor3 = Color3.fromRGB(255 * (1 - healthRatio), 255 * healthRatio, 0)
    
    -- Создание 3D Бокса (Highlight подсветка контура игрока)
    local highlight = character:FindFirstChild("EspPlayerHighlight")
    if not highlight then
        highlight = Instance.new("Highlight")
        highlight.Name = "EspPlayerHighlight"
        highlight.FillTransparency = 1 -- Оставляем внутренность прозрачной, подсвечиваем только силуэт
        highlight.OutlineTransparency = 0
        highlight.Parent = character
    end
    highlight.OutlineColor = isVisible and colorVisible or colorHidden
end

-- Функция очистки графических элементов (если противник перешел в вашу команду)
local function removePlayerEsp(character)
    if character:FindFirstChild("EspPlayerHighlight") then
        character.EspPlayerHighlight:Destroy()
    end
    local head = character:FindFirstChild("Head")
    if head and head:FindFirstChild("BlockStrikeEspGui") then
        head.BlockStrikeEspGui:Destroy()
    end
end

-- ==========================================
-- 7. ГЛАВНЫЙ СИНХРОННЫЙ ЦИКЛ ОБНОВЛЕНИЯ HUD
-- ==========================================
RunService.RenderStepped:Connect(function()
    local currentViewportSize = Camera.ViewportSize
    local systemInsetTop, _ = GuiService:GetGuiInset()
    
    -- Точные координаты центра экрана для проверки попадания в FOV
    local absoluteCenter = Vector2.new(currentViewportSize.X / 2, (currentViewportSize.Y + systemInsetTop) / 2)
    
    local visibleEnemiesCount = 0
    local hiddenEnemiesCount = 0
    local totalEnemiesInGame = 0
    local anyTargetInsideFovCircle = false
    
    -- Перебор всех присутствующих на сервере игроков
    for _, targetPlayer in ipairs(Players:GetPlayers()) do
        if targetPlayer ~= LocalPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local targetCharacter = targetPlayer.Character
            
            -- ПРОВЕРКА КОМАНДЫ: Наводится и подсвечивать только врагов
            if targetPlayer.Team == LocalPlayer.Team and LocalPlayer.Team ~= nil then
                -- Если игрок оказался тиммейтом, убираем с него оверлеи
                removePlayerEsp(targetCharacter)
            else
                -- Если игрок — ПРОТИВНИК
                totalEnemiesInGame = totalEnemiesInGame + 1
                
                -- Получаем целевую кость (в зависимости от обычного или сайлент режима)
                local targetAimPart = getTargetPart(targetCharacter, aimMode)
                
                -- Проверяем видимость за преградами
                local isTargetVisible = checkWallVisibility(targetCharacter, targetAimPart)
                
                if isTargetVisible then
                    visibleEnemiesCount = visibleEnemiesCount + 1
                else
                    hiddenEnemiesCount = hiddenEnemiesCount + 1
                end
                
                -- Перерисовываем ESP, текст метров и полоску HP врага
                updatePlayerEsp(targetPlayer, targetCharacter, isTargetVisible)
                
                -- Логика триггера FOV: Проверяем, находится ли точка цели внутри круглого интерфейса
                if targetAimPart and aimMode ~= "Выкл" then
                    local screenPosition, isOnScreen = Camera:WorldToViewportPoint(targetAimPart.Position)
                    if isOnScreen then
                        local screenPos2D = Vector2.new(screenPosition.X, screenPosition.Y)
                        local deltaDistanceFromCenter = (screenPos2D - absoluteCenter).Magnitude
                        -- Цель фиксируется только если враг внутри круга и не скрыт за препятствием
                        if deltaDistanceFromCenter <= currentRadius and isTargetVisible then
                            anyTargetInsideFovCircle = true
                        end
                    end
                end
            end
        end
    end
    
    -- Обновление счетчиков в верхнем баре
    StatsText.Text = string.format(
        "Врагов видно: %d | Скрыто за стеной: %d | Всего противников: %d",
        visibleEnemiesCount,
        hiddenEnemiesCount,
        totalEnemiesInGame
    )
    
    -- Динамическое изменение цвета центрального круга в зависимости от фиксации цели
    if anyTargetInsideFovCircle then
        FovCircle.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- Зеленый (Цель в зоне поражения)
    else
        FovCircle.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- Красный (Режим сканирования)
    end
end)
