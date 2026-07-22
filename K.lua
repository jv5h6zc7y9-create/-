local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

-- ==========================================
-- 1. СОЗДАНИЕ ГЛАВНОГО ИНТЕРФЕЙСА (GUI)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AdvancedEspHud"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- ==========================================
-- 2. ВЕРХНЯЯ ПАНЕЛЬ СТАТИСТИКИ (СЧЕТЧИК)
-- ==========================================
local StatsPanel = Instance.new("Frame")
StatsPanel.Name = "StatsPanel"
StatsPanel.Size = UDim2.new(0, 320, 0, 40)
StatsPanel.Position = UDim2.new(0.5, -160, 0, 10)
StatsPanel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
StatsPanel.BackgroundTransparency = 0.3
StatsPanel.Parent = ScreenGui

local StatsCorner = Instance.new("UICorner")
StatsCorner.CornerRadius = UDim.new(0, 8)
StatsCorner.Parent = StatsPanel

local StatsText = Instance.new("TextLabel")
StatsText.Size = UDim2.new(1, 0, 1, 0)
StatsText.BackgroundTransparency = 1
StatsText.Text = "На виду: 0  |  За укрытием: 0  |  Всего: 0"
StatsText.TextColor3 = Color3.fromRGB(255, 255, 255)
StatsText.TextSize = 16
StatsText.Font = Enum.Font.SourceSansBold
StatsText.Parent = StatsPanel

-- ==========================================
-- 3. КРУГ ПРИЦЕЛА (FOV)
-- ==========================================
local FovCircle = Instance.new("Frame")
FovCircle.Name = "FovCircle"
FovCircle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
FovCircle.BackgroundTransparency = 0.83
FovCircle.BorderSizePixel = 0
FovCircle.Parent = ScreenGui

local CircleCorner = Instance.new("UICorner")
CircleCorner.CornerRadius = UDim.new(1, 0)
CircleCorner.Parent = FovCircle

local currentRadius = 100 -- Начальный радиус

local function updateCircle()
    local center = Camera.ViewportSize / 2
    FovCircle.Size = UDim2.new(0, currentRadius * 2, 0, currentRadius * 2)
    FovCircle.Position = UDim2.new(0, center.X - currentRadius, 0, center.Y - currentRadius)
end

updateCircle()
Camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateCircle)

-- ==========================================
-- 4. ПЕРЕТАСКИВАЕМАЯ КНОПКА МЕНЮ (ДЛЯ IPAD)
-- ==========================================
local MenuButton = Instance.new("TextButton")
MenuButton.Name = "ToggleMenuButton"
MenuButton.Size = UDim2.new(0, 55, 0, 55)
MenuButton.Position = UDim2.new(0, 20, 0, 120) 
MenuButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MenuButton.Text = "⚙️"
MenuButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MenuButton.TextSize = 22
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
-- 5. ОКНО НАСТРОЕК (МЕНЮ)
-- ==========================================
local MainMenu = Instance.new("Frame")
MainMenu.Name = "MainMenu"
MainMenu.Size = UDim2.new(0, 260, 0, 160)
MainMenu.Position = UDim2.new(0.5, -130, 0.5, -80)
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

-- Ползунок размера круга
local SliderLabel = Instance.new("TextLabel")
SliderLabel.Size = UDim2.new(1, 0, 0, 25)
SliderLabel.Position = UDim2.new(0, 0, 0, 50)
SliderLabel.BackgroundTransparency = 1
SliderLabel.Text = "Радиус FOV: " .. currentRadius
SliderLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
SliderLabel.TextSize = 14
SliderLabel.Parent = MainMenu

local SliderBar = Instance.new("Frame")
SliderBar.Size = UDim2.new(0.8, 0, 0, 8)
SliderBar.Position = UDim2.new(0.1, 0, 0, 90)
SliderBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SliderBar.Parent = MainMenu

local SliderBarCorner = Instance.new("UICorner")
SliderBarCorner.CornerRadius = UDim.new(1, 0)
SliderBarCorner.Parent = SliderBar

local SliderBtn = Instance.new("TextButton")
SliderBtn.Size = UDim2.new(0, 18, 0, 18)
SliderBtn.Position = UDim2.new(0.4, 0, -0.5, 0)
SliderBtn.BackgroundColor3 = Color3.fromRGB(0, 160, 255)
SliderBtn.Text = ""
SliderBtn.Parent = SliderBar

local SliderBtnCorner = Instance.new("UICorner")
SliderBtnCorner.CornerRadius = UDim.new(1, 0)
SliderBtnCorner.Parent = SliderBtn

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
        local mouseX = input.Position.X
        local relativeX = math.clamp((mouseX - barAbsPos) / barAbsSize, 0, 1)
        SliderBtn.Position = UDim2.new(relativeX, -9, -0.5, 0)
        
        currentRadius = math.floor(30 + (relativeX * 220))
        SliderLabel.Text = "Радиус FOV: " .. currentRadius
        updateCircle()
    end
end)

-- ==========================================
-- 6. СИСТЕМА ВХ (ESP, СKЕЛЕТ, ВИДИМОСТЬ)
-- ==========================================
local colorVisible = Color3.fromRGB(0, 255, 0)   -- Зеленый (на виду)
local colorHidden = Color3.fromRGB(255, 0, 0)    -- Красный (за стеной)

-- Функция проверки прямой видимости игрока
local function checkVisibility(targetChar)
    local head = targetChar:FindFirstChild("Head")
    if not head or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("Head") then 
        return false 
    end
    
    local origin = Camera.CFrame.Position
    local direction = (head.Position - origin)
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    -- Игнорируем себя и персонажа цели, чтобы проверить только стены между вами
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, targetChar}
    
    local result = workspace:Raycast(origin, direction, raycastParams)
    return result == nil -- Если луч ни обо что не ударился, значит цель видно напрямую
end

-- Обновление ESP меток над головой (дистанция)
local function updateBillboard(player, character, distance, isVisible)
    local head = character:FindFirstChild("Head")
    if not head then return end
    
    local bGui = head:FindFirstChild("EspDistanceGui")
    if not bGui then
        bGui = Instance.new("BillboardGui")
        bGui.Name = "EspDistanceGui"
        bGui.Size = UDim2.new(0, 100, 0, 30)
        bGui.StudsOffset = Vector3.new(0, 2.5, 0)
        bGui.AlwaysOnTop = true -- Показывает текст сквозь стены
        
        local label = Instance.new("TextLabel")
        label.Name = "DistanceLabel"
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.SourceSansBold
        label.TextSize = 14
        label.Parent = bGui
        bGui.Parent = head
    end
    
    local meters = math.floor(distance)
    bGui.DistanceLabel.Text = string.format("%s [%dм]", player.Name, meters)
    bGui.DistanceLabel.TextColor3 = isVisible and colorVisible or colorHidden
end

-- Основной цикл обновления физики ESP
RunService.RenderStepped:Connect(function()
    local visibleCount = 0
    local hiddenCount = 0
    local totalPlayers = 0
    
    local screenCenter = Camera.ViewportSize / 2
    local aimTargetInFov = false

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local character = player.Character
            local hrp = character.HumanoidRootPart
            totalPlayers = totalPlayers + 1
            
            -- 1. Рассчитываем дистанцию в метрах (студах)
            local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local distance = myHrp and (hrp.Position - myHrp.Position).Magnitude or 0
            
            -- 2. Проверяем видимость (на виду или за стеной)
            local isVisible = checkVisibility(character)
            local targetColor = isVisible and colorVisible or colorHidden
            
            if isVisible then
                visibleCount = visibleCount + 1
            else
                hiddenCount = hiddenCount + 1
            end
            
            -- 3. Управляем подсветкой (Box/Skeleton Outline) через Highlight
            local highlight = character:FindFirstChild("EspHighlight")
            if not highlight then
                highlight = Instance.new("Highlight")
                highlight.Name = "EspHighlight"
                highlight.FillTransparency = 1 -- Оставляем только контур
                highlight.OutlineTransparency = 0
                highlight.Parent = character
            end
            highlight.OutlineColor = targetColor
            
            -- 4. Обновляем текстовый маркер дистанции
            updateBillboard(player, character, distance, isVisible)
            
            -- 5. Логика Аима: Проверяем, попал ли игрок в центральный круг на экране
            local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            if onScreen then
                local distanceFromCenter = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                if distanceFromCenter <= currentRadius and isVisible then
                    aimTargetInFov = true
                end
            end
        end
    end
    
    -- Обновляем счетчики на верхней панели
    StatsText.Text = string.format("На виду: %d | За укрытием: %d | Всего: %d", visibleCount, hiddenCount, totalPlayers)
    
    -- Меняем цвет круга прицела, если живая и видимая цель внутри FOV
    if aimTargetInFov then
        FovCircle.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- Зеленый при наведении
    else
        FovCircle.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- Красный в режиме ожидания
    end
end)
