-- ====================================================================
-- ПОЛНЫЙ МОБИЛЬНЫЙ СКРИПТ ДЛЯ FLING THINGS AND PEOPLE (DELTA IPAD)
-- СТРОГО БЕЗ СОКРАЩЕНИЙ И УРЕЗАНИЙ КОДА
-- ====================================================================

-- Проверка базовых библиотек рисования в инжекторе Delta
if not Drawing then
    error("Критическая ошибка: Ваша версия инжектора Delta не поддерживает библиотеку рисования Drawing!")
end

-- Инициализация всех необходимых сервисов Roblox
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Полная глобальная таблица настроек всех функций софта
local ScriptSettings = {
    AimEnabled = false,        -- Включение/выключение Аим Ассиста
    FOVDrawn = true,           -- Отображение бирюзового круга на экране
    FOVRadius = 150,           -- Текущий радиус круга (размер)
    AntiGrabEnabled = false,   -- Полный иммунитет от чужих лучей
    SuperFlingEnabled = false, -- Увеличение силы броска предметов и людей
    FlingPowerValue = 50,      -- Множитель силы далекого супер-броска
    ReachEnabled = false,      -- Увеличение дистанции захвата луча
    NoCooldownEnabled = false  -- Полное отключение задержки на использование луча
}

-- ====================================================================
-- ФУНКЦИЯ №1: СОЗДАНИЕ И НАСТРОЙКА КРУГА FOV СТРОГО ПО ЦЕНТРУ IPAD
-- ====================================================================
local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(0, 255, 255) -- Бирюзовый цвет круга
FOVCircle.Thickness = 2.5                     -- Толщина линии круга
FOVCircle.NumSides = 64                       -- Сглаженность круга
FOVCircle.Filled = false                      -- Круг прозрачный внутри
FOVCircle.Visible = false                     -- По умолчанию скрыт

-- Постоянное обновление положения круга строго по центру экрана планшета
RunService.RenderStepped:Connect(function()
    if ScriptSettings.FOVDrawn and ScriptSettings.AimEnabled then
        local screenSize = Camera.ViewportSize
        FOVCircle.Position = Vector2.new(screenSize.X / 2, screenSize.Y / 2)
        FOVCircle.Radius = ScriptSettings.FOVRadius
        FOVCircle.Visible = true
    else
        FOVCircle.Visible = false
    end
end)

-- ====================================================================
-- ФУНКЦИЯ №2: ПОИСК БЛИЖАЙШЕГО ИГРОКА И ЛОГИКА МОБИЛЬНОГО АИМ АССИСТА
-- ====================================================================
local function getClosestPlayerInFOVCircle()
    local closestPlayer = nil
    local shortestDistance = math.huge
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            -- Проверяем, жив ли игрок на данный момент
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                -- Переводим 3D координаты игрока в 2D координаты экрана iPad
                local pos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
                if onScreen then
                    -- Считаем расстояние от центра экрана до персонажа
                    local distance = (Vector2.new(pos.X, pos.Y) - screenCenter).Magnitude
                    -- Если игрок внутри круга и он ближе остальных, выбираем его целью
                    if distance <= ScriptSettings.FOVRadius and distance < shortestDistance then
                        closestPlayer = player
                        shortestDistance = distance
                    end
                end
            end
        end
    end
    return closestPlayer
end

-- Отслеживание зажатия пальца на экране iPad для активации доводки прицела
local isTouchHolding = false

UserInputService.TouchStarted:Connect(function(touch, gameProcessedEvent)
    -- Если нажатие произошло не по элементам интерфейса/кнопкам самого чита
    if not gameProcessedEvent and ScriptSettings.AimEnabled then
        isTouchHolding = true
    end
end)

UserInputService.TouchEnded:Connect(function()
    isTouchHolding = false
end)

-- Цикл плавной доводки камеры на цель при удержании пальца на экране
RunService.RenderStepped:Connect(function()
    if isTouchHolding and ScriptSettings.AimEnabled then
        local targetPlayer = getClosestPlayerInFOVCircle()
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local targetPosition = targetPlayer.Character.HumanoidRootPart.Position
            -- Плавное смещение камеры iPad в сторону цели (Lerp)
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, targetPosition), 0.15)
        end
    end
end)

-- ====================================================================
-- ФУНКЦИЯ №3: ПАССИВНЫЙ АНТИ-ЗАХВАТ (ПОЛНЫЙ ИММУНИТЕТ ОТ ЧУЖИХ ЛУЧЕЙ)
-- ====================================================================
RunService.Heartbeat:Connect(function()
    if ScriptSettings.AntiGrabEnabled and LocalPlayer.Character then
        -- Прочесываем все объекты внутри персонажа на наличие чужих захватов
        for _, object in pairs(LocalPlayer.Character:GetDescendants()) do
            if object:IsA("AlignPosition") or object:IsA("RopeConstraint") or object:IsA("BodyPosition") or object:IsA("BodyVelocity") or object:IsA("WeldConstraint") then
                -- Если этот физический объект прикреплен не нашими скриптами, мгновенно уничтожаем его
                if not object:IsDescendantOf(LocalPlayer.Character) then
                    object:Destroy()
                end
            end
        end
    end
end)

-- ====================================================================
-- ФУНКЦИЯ №4: СУПЕР СУПЕР-БРОСОК (ДАЛЕКИЙ ПОЛЕТ ПРЕДМЕТОВ И ЛЮДЕЙ)
-- ====================================================================
workspace.DescendantAdded:Connect(function(newObject)
    if ScriptSettings.SuperFlingEnabled then
        -- Отслеживаем появление физических сил, которые игра создает при манипуляции объектами
        if newObject:IsA("BodyVelocity") or newObject:IsA("AlignPosition") or newObject:IsA("BodyForce") then
            task.wait(0.02) -- Минимальная задержка для точного перехвата
            if newObject.Parent and (newObject.Parent:IsA("Part") or newObject.Parent:IsA("MeshPart")) then
                -- Принудительно умножаем скорость детали по направлению взгляда камеры игрока
                newObject.Parent.AssemblyLinearVelocity = Camera.CFrame.LookVector * (ScriptSettings.FlingPowerValue * 15)
            end
        end
    end
end)

-- ====================================================================
-- ФУНКЦИИ №5 И №6: ДИСТАНЦИЯ ЗАХВАТА (REACH) И ОТМЕНА КУЛДАУНА (NO COOLDOWN)
-- ====================================================================
-- Постоянный поиск локальных скриптов игры для модификации внутренних переменных луча
RunService.Heartbeat:Connect(function()
    if LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") then
        -- Перебор всех инструментов и скриптов в персонаже игрока
        if LocalPlayer.Character then
            for _, item in pairs(LocalPlayer.Character:GetChildren()) do
                -- Модификация дальности луча захвата (Reach)
                if ScriptSettings.ReachEnabled and item:IsA("Tool") and item:FindFirstChild("MaxDistance") then
                    item.MaxDistance.Value = 999999 -- Увеличиваем дистанцию до бесконечности
                end
                -- Модификация перезарядки луча (No Cooldown)
                if ScriptSettings.NoCooldownEnabled and item:IsA("Tool") and item:FindFirstChild("Cooldown") then
                    item.Cooldown.Value = 0 -- Обнуляем кулдаун для спама кнопкой
                end
            end
        end
        -- Дополнительный поиск в рюкзаке (Backpack) на случай, если луч убран
        for _, item in pairs(LocalPlayer.Backpack:GetChildren()) do
            if ScriptSettings.ReachEnabled and item:IsA("Tool") and item:FindFirstChild("MaxDistance") then
                item.MaxDistance.Value = 999999
            end
            if ScriptSettings.NoCooldownEnabled and item:IsA("Tool") and item:FindFirstChild("Cooldown") then
                item.Cooldown.Value = 0
            end
        end
    end
end)

-- ====================================================================
-- СОЗДАНИЕ КРАСИВОГО ТЕМНОГО МОБИЛЬНОГО ИНТЕРФЕЙСА (GUI) ДЛЯ IPAD
-- ====================================================================
local CustomScreenGui = Instance.new("ScreenGui")
local CentralFrame = Instance.new("Frame")
local FrameTitle = Instance.new("TextLabel")
local Scroller = Instance.new("ScrollingFrame")
local ListLayout = Instance.new("UIListLayout")
local UICornerMain = Instance.new("UICorner")

CustomScreenGui.Parent = game:GetService("CoreGui")
CustomScreenGui.ResetOnSpawn = false
CustomScreenGui.Name = "DeltaFlingHubUncut"

-- Главное окно меню чита
CentralFrame.Name = "MainWindow"
CentralFrame.Parent = CustomScreenGui
CentralFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25) -- Очень темный цвет фона
CentralFrame.Position = UDim2.new(0.35, 0, 0.25, 0)
CentralFrame.Size = UDim2.new(0, 340, 0, 420)
CentralFrame.Active = true
CentralFrame.Draggable = true -- Позволяет свободно перетаскивать пальцем меню по экрану iPad

UICornerMain.Parent = CentralFrame
UICornerMain.CornerRadius = UDim.new(0, 12)

-- Заголовок меню
FrameTitle.Parent = CentralFrame
FrameTitle.Size = UDim2.new(1, 0, 0, 45)
FrameTitle.BackgroundColor3 = Color3.fromRGB(30, 30, 38)

FrameTitle.Text = "FT&P Full Mobile Hub (Delta)"
FrameTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
FrameTitle.TextSize = 16
FrameTitle.Font = Enum.Font.SourceSansBold

local UICornerTitle = Instance.new("UICorner")
UICornerTitle.Parent = FrameTitle
UICornerTitle.CornerRadius = UDim.new(0, 12)

-- Область прокрутки для кнопок софта
Scroller.Parent = CentralFrame
Scroller.Position = UDim2.new(0, 0, 0, 50)
Scroller.Size = UDim2.new(1, 0, 1, -50)
Scroller.BackgroundTransparency = 1
Scroller.CanvasSize = UDim2.new(0, 0, 0, 550) -- Размер зоны прокрутки пальцем
Scroller.ScrollBarThickness = 4

ListLayout.Parent = Scroller
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Padding = UDim.new(0, 8)
ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Универсальная функция для создания полноценных кнопок-переключателей
local function AddMenuToggle(labelText, settingKey)
    local button = Instance.new("TextButton")
    local corner = Instance.new("UICorner")
    button.Parent = Scroller
    button.Size = UDim2.new(0.92, 0, 0, 48)
    button.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
    button.Text = labelText .. ": [ВЫКЛЮЧЕНО]"
    button.TextColor3 = Color3.fromRGB(210, 210, 210)
    button.TextSize = 15
    button.Font = Enum.Font.SourceSans
    corner.Parent = button
    corner.CornerRadius = UDim.new(0, 8)
    button.MouseButton1Click:Connect(function()
        ScriptSettings[settingKey] = not ScriptSettings[settingKey]
        if ScriptSettings[settingKey] then
            button.Text = labelText .. ": [ВКЛЮЧЕНО]"
            button.BackgroundColor3 = Color3.fromRGB(0, 140, 90) -- Зеленый при включении
            button.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            button.Text = labelText .. ": [ВЫКЛЮЧЕНО]"
            button.BackgroundColor3 = Color3.fromRGB(40, 40, 48) -- Возврат к темному
            button.TextColor3 = Color3.fromRGB(210, 210, 210)
        end
    end)
end

-- ====================================================================
-- ДОБАВЛЕНИЕ ВСЕХ ДО ЕДИНОЙ ФУНКЦИЙ В МЕНЮ ИНТЕРФЕЙСА
-- ====================================================================
AddMenuToggle("1. Аим Ассист (Удерживать экран)", "AimEnabled")
AddMenuToggle("2. Показывать круг Аима", "FOVDrawn")
AddMenuToggle("3. Анти-Захват (Иммунитет лучей)", "AntiGrabEnabled")
AddMenuToggle("4. Супер Далекий Бросок", "SuperFlingEnabled")
AddMenuToggle("5. Огромная Дистанция (Reach)", "ReachEnabled")
AddMenuToggle("6. Спам лучем (No Cooldown)", "NoCooldownEnabled")

-- Кнопка №7: Настройка размера FOV круга под пальцы на iPad
local SizeButton = Instance.new("TextButton")
local SizeCorner = Instance.new("UICorner")
SizeButton.Parent = Scroller
SizeButton.Size = UDim2.new(0.92, 0, 0, 48)
SizeButton.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
SizeButton.Text = "7. Изменить Размер Круга: " .. tostring(ScriptSettings.FOVRadius)
SizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SizeButton.TextSize = 15
SizeButton.Font = Enum.Font.SourceSans
SizeCorner.Parent = SizeButton
SizeCorner.CornerRadius = UDim.new(0, 8)
SizeButton.MouseButton1Click:Connect(function()
    -- Цикличное переключение радиуса круга для удобства кастомизации на планшете
    if ScriptSettings.FOVRadius == 90 then
        ScriptSettings.FOVRadius = 150
    elseif ScriptSettings.FOVRadius == 150 then
        ScriptSettings.FOVRadius = 220
    elseif ScriptSettings.FOVRadius == 220 then
        ScriptSettings.FOVRadius = 300
    elseif ScriptSettings.FOVRadius == 300 then
        ScriptSettings.FOVRadius = 400
    else
        ScriptSettings.FOVRadius = 90
    end
    SizeButton.Text = "7. Изменить Размер Круга: " .. tostring(ScriptSettings.FOVRadius)
end)

-- Кнопка №8: Изменение силы супер-броска (Fling Power)
local PowerButton = Instance.new("TextButton")
local PowerCorner = Instance.new("UICorner")
PowerButton.Parent = Scroller
PowerButton.Size = UDim2.new(0.92, 0, 0, 48)
PowerButton.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
PowerButton.Text = "8. Сила Далекого Броска: x" .. tostring(ScriptSettings.FlingPowerValue)
PowerButton.TextColor3 = Color3.fromRGB(255, 255, 255)
PowerButton.TextSize = 15
PowerButton.Font = Enum.Font.SourceSans
PowerCorner.Parent = PowerButton
PowerCorner.CornerRadius = UDim.new(0, 8)
PowerButton.MouseButton1Click:Connect(function()
    -- Цикличное увеличение силы импульса броска
    if ScriptSettings.FlingPowerValue == 25 then
        ScriptSettings.FlingPowerValue = 50
    elseif ScriptSettings.FlingPowerValue == 50 then
        ScriptSettings.FlingPowerValue = 100
    elseif ScriptSettings.FlingPowerValue == 100 then
        ScriptSettings.FlingPowerValue = 200
    else
        ScriptSettings.FlingPowerValue = 25
    end
    PowerButton.Text = "8. Сила Далекого Броска: x" .. tostring(ScriptSettings.FlingPowerValue)
end)
