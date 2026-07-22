local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

-- ==========================================
-- 1. НАСТРОЙКИ ПО УМОЛЧАНИЮ
-- ==========================================
local currentRadius = 100        -- Радиус FOV круга
local aimPartName = "Head"       -- Куда целиться по умолчанию ("Head" или "HumanoidRootPart")
local colorVisible = Color3.fromRGB(0, 255, 0)   -- На виду (Зеленый)
local colorHidden = Color3.fromRGB(255, 0, 0)    -- За стеной (Красный)

-- ==========================================
-- 2. СОЗДАНИЕ ГЛАВНОГО ИНТЕРФЕЙСА (GUI)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CounterBloxEspHud"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- Верхняя панель статистики (счетчик врагов)
local StatsPanel = Instance.new("Frame")
StatsPanel.Size = UDim2.new(0, 340, 0, 40)
StatsPanel.Position = UDim2.new(0.5, -170, 0, 15)
StatsPanel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
StatsPanel.BackgroundTransparency = 0.3
StatsPanel.Parent = ScreenGui

local StatsCorner = Instance.new("UICorner")
StatsCorner.CornerRadius = UDim.new(0, 8)
StatsCorner.Parent = StatsPanel

local StatsText = Instance.new("TextLabel")
StatsText.Size = UDim2.new(1, 0, 1, 0)
StatsText.BackgroundTransparency = 1
StatsText.Text = "Врагов видно: 0  |  Скрыто: 0  |  Всего: 0"
StatsText.TextColor3 = Color3.fromRGB(255, 255, 255)
StatsText.TextSize = 15
StatsText.Font = Enum.Font.SourceSansBold
StatsText.Parent = StatsPanel

-- Круг FOV по центру экрана
local FovCircle = Instance.new("Frame")
FovCircle.Name = "FovCircle"
FovCircle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
FovCircle.BackgroundTransparency = 0.85
FovCircle.BorderSizePixel = 0
FovCircle.Parent = ScreenGui

local CircleCorner = Instance.new("UICorner")
CircleCorner.CornerRadius = UDim.new(1, 0)
CircleCorner.Parent = FovCircle

local function updateCircle()
    local center = Camera.ViewportSize / 2
    FovCircle.Size = UDim2.new(0, currentRadius * 2, 0, currentRadius * 2)
    FovCircle.Position = UDim2.new(0, center.X - currentRadius, 0, center.Y - currentRadius)
end

updateCircle()
Camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateCircle)

-- ==========================================
-- 3. ПЕРЕТАСКИВАЕМАЯ КНОПКА МЕНЮ ДЛЯ IPAD
-- ==========================================
local MenuButton = Instance.new("TextButton")
MenuButton.Size = UDim2.new(0, 55, 0, 55)
MenuButton.Position = UDim2.new(0, 20, 0, 150) 
MenuButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MenuButton.Text = "⚙️"
MenuButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MenuButton.TextSize = 24
MenuButton.Parent = ScreenGui

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0.3, 0)
ButtonCorner.Parent = MenuButton

local dragging, dragInput, dragStart, startPos

MenuButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MenuButton.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
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
        local delta = input.Position - dragStart
        MenuButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- ==========================================
-- 4. ОКНО НАСТРОЕК (МЕНЮ)
-- ==========================================
local MainMenu = Instance.new("Frame")
MainMenu.Size = UDim2.new(0, 280, 0, 220)
MainMenu.Position = UDim2.new(0.5, -140, 0.5, -110)
MainMenu.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainMenu.Visible = false
MainMenu.Parent = ScreenGui

local MenuCorner = Instance.new("UICorner")
MenuCorner.CornerRadius = UDim.new(0, 12)
MenuCorner.Parent = MainMenu

local MenuTitle = Instance.new("TextLabel")
MenuTitle.Size = UDim2.new(1, 0, 0, 40)
MenuTitle.BackgroundTransparency = 1
MenuTitle.Text = "Настройки Скрипта"
MenuTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
MenuTitle.TextSize = 16
MenuTitle.Font = Enum.Font.SourceSansBold
MenuTitle.Parent = MainMenu

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.BackgroundTransparency = 1
CloseButton.Text = "❌"
CloseButton.TextColor3 = Color3.fromRGB(255, 90, 90)
CloseButton.TextSize = 16
CloseButton.Parent = MainMenu

CloseButton.MouseButton1Click:Connect(function() MainMenu.Visible = false end)
MenuButton.MouseButton1Click:Connect(function() MainMenu.Visible = not MainMenu.Visible end)

-- Ползунок радиуса FOV круга
local SliderLabel = Instance.new("TextLabel")
SliderLabel.Size = UDim2.new(1, 0, 0, 25)
SliderLabel.Position = UDim2.new(0, 0, 0, 45)
SliderLabel.BackgroundTransparency = 1
SliderLabel.Text = "Радиус FOV: " .. currentRadius
SliderLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
SliderLabel.TextSize = 14
SliderLabel.Parent = MainMenu

local SliderBar = Instance.new("Frame")
SliderBar.Size = UDim2.new(0.8, 0, 0, 8)
SliderBar.Position = UDim2.new(0.1, 0, 0, 75)
SliderBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SliderBar.Parent = MainMenu

local SliderBtn = Instance.new("TextButton")
SliderBtn.Size = UDim2.new(0, 18, 0, 18)
SliderBtn.Position = UDim2.new(0.4, 0, -0.5, 0)
SliderBtn.BackgroundColor3 = Color3.fromRGB(0, 160, 255)
SliderBtn.Text = ""
SliderBtn.Parent = SliderBar
Instance.new("UICorner", SliderBtn).CornerRadius = UDim.new(1, 0)

local sliderDragging = false

SliderBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliderDragging = true end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliderDragging = false end
end)

UserInputService.InputChanged:Connect(function(input)
    if sliderDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local relativeX = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
        SliderBtn.Position = UDim2.new(relativeX, -9, -0.5, 0)
        currentRadius = math.floor(30 + (relativeX * 220))
        SliderLabel.Text = "Радиус FOV: " .. currentRadius
        updateCircle()
    end
end)

-- Кнопка выбора точки прицеливания (Голова / Тело)
local TargetPartBtn = Instance.new("TextButton")
TargetPartBtn.Size = UDim2.new(0.8, 0, 0, 35)
TargetPartBtn.Position = UDim2.new(0.1, 0, 0, 110)
TargetPartBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
TargetPartBtn.Text = "Цель: Голова"
TargetPartBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TargetPartBtn.TextSize = 14
TargetPartBtn.Parent = MainMenu
Instance.new("UICorner", TargetPartBtn).CornerRadius = UDim.new(0, 6)

TargetPartBtn.MouseButton1Click:Connect(function()
    if aimPartName == "Head" then
        aimPartName = "HumanoidRootPart"
        TargetPartBtn.Text = "Цель: Тело (Торс)"
    else
        aimPartName = "Head"
        TargetPartBtn.Text = "Цель: Голова"
    end
end)

-- Info Label в меню
local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size = UDim2.new(1, 0, 0, 30)
InfoLabel.Position = UDim2.new(0, 0, 0, 160)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Text = "Игнорирует союзников по команде"
InfoLabel.TextColor3 = Color3.fromRGB(120, 255, 120)
InfoLabel.TextSize = 12
InfoLabel.Font = Enum.Font.SourceSansItalic
InfoLabel.Parent = MainMenu

-- ==========================================
-- 5. ФУНКЦИИ ПРОВЕРКИ ВИДИМОСТИ И КОМАНД
-- ==========================================
local function checkVisibility(targetChar)
    local targetPart = targetChar:FindFirstChild(aimPartName)
    if not targetPart or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("Head") then 
        return false 
    end
    
    local origin = Camera.CFrame.Position
    local direction = (targetPart.Position - origin)
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, targetChar}
    
    local result = workspace:Raycast(origin, direction, raycastParams)
    return result == nil
end

-- ==========================================
-- 6. СОЗДАНИЕ И ОБНОВЛЕНИЕ ESP И HP БАРА
-- ==========================================
local function updateEsp(player, character, isVisible)
    local head = character:FindFirstChild("Head")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not head or not humanoid then return end
    
    local bGui = head:FindFirstChild("EspEnemyGui")
    if not bGui then
        bGui = Instance.new("BillboardGui")
        bGui.Name = "EspEnemyGui"
        bGui.Size = UDim2.new(0, 130, 0, 45)
        bGui.StudsOffset = Vector3.new(0, 3, 0)
        bGui.AlwaysOnTop = true
        
        -- Текст имени и дистанции
        local label = Instance.new("TextLabel")
        label.Name = "InfoLabel"
        label.Size = UDim2.new(1, 0, 0, 20)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.SourceSansBold
        label.TextSize = 14
        label.Parent = bGui
        
        -- Задний фон HP бара
        local hpBackground = Instance.new("Frame")
        hpBackground.Name = "HpBg"
        hpBackground.Size = UDim2.new(0.8, 0, 0, 5)
        hpBackground.Position = UDim2.new(0.1, 0, 0, 22)
        hpBackground.BackgroundColor3 = Color3.fromRGB(50, 0, 0)
        hpBackground.BorderSizePixel = 0
        hpBackground.Parent = bGui
        
        -- Зеленая полоска HP
        local hpBar = Instance.new("Frame")
        hpBar.Name = "HpBar"
        hpBar.Size = UDim2.new(1, 0, 1, 0)
        hpBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        hpBar.BorderSizePixel = 0
        hpBar.Parent = hpBackground
        bGui.Parent = head
    end
    
    -- Рассчет метров
    local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local targetHrp = character:FindFirstChild("HumanoidRootPart")
    local distance = (myHrp and targetHrp) and (targetHrp.Position - myHrp.Position).Magnitude or 0
    
    bGui.InfoLabel.Text = string.format("%s [%dм]", player.Name, math.floor(distance))
    bGui.InfoLabel.TextColor3 = isVisible and colorVisible or colorHidden
    
    -- Обновление полоски здоровья (HP бар)
    local hpPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
    bGui.HpBg.HpBar.Size = UDim2.new(hpPercent, 0, 1, 0)
    -- Меняет цвет полоски с зеленого на красный при падении здоровья
    bGui.HpBg.HpBar.BackgroundColor3 = Color3.fromRGB(255 * (1 - hpPercent), 255 * hpPercent, 0)
    
    -- Силуэт (Box/Highlight) врага
    local highlight = character:FindFirstChild("EspHighlight")
    if not highlight then
        highlight = Instance.new("Highlight")
        highlight.Name = "EspHighlight"
        highlight.FillTransparency = 1
        highlight.OutlineTransparency = 0
        highlight.Parent = character
    end
    highlight.OutlineColor = isVisible and colorVisible or colorHidden
end

-- Удаление ESP элементов, если игрок стал тиммейтом или вышел
local function clearEsp(character)
    if character:FindFirstChild("EspHighlight") then character.EspHighlight:Destroy() end
    local head = character:FindFirstChild("Head")
    if head and head:FindFirstChild("EspEnemyGui") then head.EspEnemyGui:Destroy() end
end

-- ==========================================
-- 7. ОСНОВНОЙ ЦИКЛ ОБНОВЛЕНИЯ (RENDERSTEPPED)
-- ==========================================
RunService.RenderStepped:Connect(function()
    local visibleCount = 0
    local hiddenCount = 0
    local totalEnemies = 0
    local screenCenter = Camera.ViewportSize / 2
    local aimTargetInFov = false

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local character = player.Character
            
            -- ПРОВЕРКА КОМАНДЫ (Игнорируем тиммейтов)
            if player.Team == LocalPlayer.Team and LocalPlayer.Team ~= nil then
                -- Если это тиммейт, убираем с него ВХ/подсветку
                clearEsp(character)
            else
                -- Если это ПРОТИВНИК
                totalEnemies = totalEnemies + 1
                local isVisible = checkVisibility(character)
                
                if isVisible then
                    visibleCount = visibleCount + 1
                else
                    hiddenCount = hiddenCount + 1
                end
                
                -- Обновляем ВХ, скелет-бокс и HP бар
                updateEsp(player, character, isVisible)
                
                -- ЛОГИКА АИМА: попал ли противник в центральный круг FOV
                local targetPart = character:FindFirstChild(aimPartName)
                if targetPart then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                    if onScreen then
                        local distanceFromCenter = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                        -- Срабатывает только если противник внутри FOV-круга и находится на виду (не за стеной)
                        if distanceFromCenter <= currentRadius and isVisible then
                            aimTargetInFov = true
                        end
                    end
                end
            end
        end
    end
    
    -- Обновление счетчиков на панели статистики
    StatsText.Text = string.format("Врагов видно: %d | Скрыто: %d | Всего: %d", visibleCount, hiddenCount, totalEnemies)
    
    -- Подсветка индикатора FOV круга
    if aimTargetInFov then
        FovCircle.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- Зеленый (цель захвачена)
    else
        FovCircle.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- Красный (ожидание)
    end
end)
