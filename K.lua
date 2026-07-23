local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Инициализация или поиск существующего ScreenGui
local ScreenGui = LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("PremiumMobileMatrixEngine")
if not ScreenGui then
    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "PremiumMobileMatrixEngine"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- 1. ДРАГ-КНОПКА ОТКРЫТИЯ (ПО ЦЕНТРУ ЭКРАНА ПРИ ЗАПУСКЕ)
local MenuButton = Instance.new("TextButton")
MenuButton.Name = "MenuButton"
MenuButton.Size = UDim2.new(0, 60, 0, 60)
MenuButton.AnchorPoint = Vector2.new(0.5, 0.5)
MenuButton.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
MenuButton.Text = "⚙️"
MenuButton.TextSize = 28
MenuButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MenuButton.ZIndex = 100
MenuButton.Parent = ScreenGui

local MenuButtonCorner = Instance.new("UICorner")
MenuButtonCorner.CornerRadius = UDim.new(0.3, 0)
MenuButtonCorner.Parent = MenuButton

local MenuButtonStroke = Instance.new("UIStroke")
MenuButtonStroke.Thickness = 2
MenuButtonStroke.Color = Color3.fromRGB(80, 80, 100)
MenuButtonStroke.Parent = MenuButton

local function SetButtonToCenter()
    local insetTop, insetBottom = GuiService:GetGuiInset()
    local centerX = Camera.ViewportSize.X / 2
    local centerY = (Camera.ViewportSize.Y - (insetTop + insetBottom)) / 2
    MenuButton.Position = UDim2.new(0, centerX, 0, centerY)
end
SetButtonToCenter()

-- 2. ДИЗАЙН ГЛАВНОГО МЕНЮ (MainMenu)
local MainMenu = Instance.new("Frame")
MainMenu.Name = "MainMenu"
MainMenu.Size = UDim2.new(0, 350, 0, 640)
MainMenu.AnchorPoint = Vector2.new(0.5, 0.5)
MainMenu.Position = UDim2.new(0.5, 0, 0.5, 0)
MainMenu.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainMenu.Visible = false
MainMenu.ZIndex = 50
MainMenu.Parent = ScreenGui

local MainMenuCorner = Instance.new("UICorner")
MainMenuCorner.CornerRadius = UDim.new(0.04, 0)
MainMenuCorner.Parent = MainMenu

local MainMenuStroke = Instance.new("UIStroke")
MainMenuStroke.Thickness = 2
MainMenuStroke.Color = Color3.fromRGB(45, 45, 55)
MainMenuStroke.Parent = MainMenu

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(1, 0, 0, 45)
TitleLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
TitleLabel.Text = "iPad Pro 11 Premium Multi-Cheat"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 16
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.ZIndex = 51
TitleLabel.Parent = MainMenu

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0.1, 0)
TitleCorner.Parent = TitleLabel

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 32, 0, 32)
CloseButton.AnchorPoint = Vector2.new(1, 0)
CloseButton.Position = UDim2.new(1, -7, 0, 7)
CloseButton.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
CloseButton.Text = "❌"
CloseButton.TextSize = 14
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.ZIndex = 52
CloseButton.Parent = MainMenu

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDictNew and UDim.new(0.3, 0) or UDim.new(0.3, 0)
CloseCorner.Parent = CloseButton

-- Контейнер прокрутки для элементов меню
local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(1, 0, 1, -95)
ScrollingFrame.Position = UDim2.new(0, 0, 0, 45)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.BorderSizePixel = 0
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 620)
ScrollingFrame.ScrollBarThickness = 4
ScrollingFrame.ZIndex = 51
ScrollingFrame.Parent = MainMenu

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.Parent = ScrollingFrame

-- Функция-помощник для создания стандартных кнопок меню
local function CreateMenuButton(name, text, order)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(0, 310, 0, 45)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 15
    btn.Font = Enum.Font.SourceSansBold
    btn.LayoutOrder = order
    btn.ZIndex = 52
    btn.Parent = ScrollingFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.15, 0)
    corner.Parent = btn

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.Color = Color3.fromRGB(75, 75, 90)
    stroke.Parent = btn

    return btn
end

-- 3. ФУНКЦИОНАЛЬНЫЕ КНОПКИ И ПЕРЕКЛЮЧАТЕЛИ
local ModeButton = CreateMenuButton("ModeButton", "Режим: Сайлент Аим", 1)
ModeButton.BackgroundColor3 = Color3.fromRGB(0, 0, 150)

local TargetButton = CreateMenuButton("TargetButton", "Цель: Head", 2)
local ESPToggle = CreateMenuButton("ESPToggle", "ESP (ВХ): ВКЛЮЧЕНО", 3)
ESPToggle.BackgroundColor3 = Color3.fromRGB(0, 120, 0)

local BHopToggle = CreateMenuButton("BHopToggle", "BUNNYHOP: ВКЛЮЧЕН", 4)
BHopToggle.BackgroundColor3 = Color3.fromRGB(0, 120, 0)

local ThirdPersonToggle = CreateMenuButton("ThirdPersonToggle", "ТРЕТЬЕ ЛИЦО: ВЫКЛ", 5)
local EnvironmentButton = CreateMenuButton("EnvironmentButton", "Небо и Гамма: Стандарт", 6)
local StretchButton = CreateMenuButton("StretchButton", "Растяг: 16:9 (Стандарт)", 7)

-- 4. ПОЛЗУНКИ С ТОЧКАМИ (SLIDERS)
local function CreateSlider(name, titleText, initialText, order)
    local container = Instance.new("Frame")
    container.Name = name .. "Container"
    container.Size = UDim2.new(0, 310, 0, 50)
    container.BackgroundTransparency = 1
    container.LayoutOrder = order
    container.ZIndex = 52
    container.Parent = ScrollingFrame

    local label = Instance.new("TextLabel")
    label.Name = name .. "Label"
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = initialText
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 14
    label.Font = Enum.Font.SourceSansBold
    label.ZIndex = 53
    label.Parent = container

    local bar = Instance.new("Frame")
    bar.Name = name .. "Bar"
    bar.Size = UDim2.new(1, 0, 0, 8)
    bar.Position = UDim2.new(0, 0, 0, 30)
    bar.BackgroundColor3 = Color3.fromRGB(70, 70, 85)
    bar.BorderSizePixel = 0
    bar.ZIndex = 53
    bar.Parent = container

    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(1, 0)
    barCorner.Parent = bar

    local btn = Instance.new("TextButton")
    btn.Name = name .. "Btn"
    btn.Size = UDim2.new(0, 22, 0, 22)
    btn.AnchorPoint = Vector2.new(0.5, 0.5)
    btn.Position = UDim2.new(0.35, 0, 0.5, 0)
    btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = ""
    btn.ZIndex = 54
    btn.Parent = bar

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(1, 0)
    btnCorner.Parent = btn

    return container, label, bar, btn
end

local sliderContainer, SliderLabel, SliderBar, SliderBtn = CreateSlider("FOV", "Радиус FOV", "Радиус FOV: 100 px", 8)
local speedContainer, SpeedLabel, SpeedBar, SpeedBtn = CreateSlider("Speed", "Скорость бега", "Скорость бега: x1.0", 9)

-- 5. НИЖНИЙ КОПИРАЙТ КРЕДИТ
local CreditLabel = Instance.new("TextLabel")
CreditLabel.Name = "CreditLabel"
CreditLabel.Size = UDim2.new(1, 0, 0, 35)
CreditLabel.BackgroundTransparency = 1
CreditLabel.Text = "Block Strike Ultra Anti-Crash Mobile Engine"
CreditLabel.TextColor3 = Color3.fromRGB(130, 130, 150)
CreditLabel.TextSize = 11
CreditLabel.Font = Enum.Font.SourceSansItalic
CreditLabel.LayoutOrder = 10
CreditLabel.ZIndex = 52
CreditLabel.Parent = ScrollingFrame


-- ЛОГИКА DRAG AND DROP (ПЕРЕТАСКИВАНИЕ КНОПКИ ПАЛЬЦЕМ)
local Dragging, DragStart, StartPos = false, nil, nil

MenuButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        Dragging = true
        DragStart = input.Position
        StartPos = MenuButton.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                Dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if Dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.MouseMovement) then
        local delta = input.Position - DragStart
        MenuButton.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + delta.X, StartPos.Y.Scale, StartPos.Y.Offset + delta.Y)
    end
end)

MenuButton.MouseButton1Click:Connect(function()
    if not Dragging then
        MainMenu.Visible = not MainMenu.Visible
    end
end)

CloseButton.MouseButton1Click:Connect(function()
    MainMenu.Visible = false
end)


-- СВЯЗЬ ИНТЕРАФЕЙСА С ПЕРЕМЕННЫМИ _G

-- 1. Кнопка режима аима
local aimModesList = {"Выкл", "Обычный Аим", "Сайлент Аим"}
local currentModeIndex = 3 -- по умолчанию "Сайлент Аим" в коде ядра
ModeButton.MouseButton1Click:Connect(function()
    currentModeIndex = currentModeIndex + 1
    if currentModeIndex > #aimModesList then
        currentModeIndex = 1
    end
    
    local modeName = aimModesList[currentModeIndex]
    _G.AimMode = modeName
    
    if modeName == "Выкл" then
        ModeButton.Text = "Режим: Выкл"
        ModeButton.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        _G.AimbotEnabled = false
        _G.SilentAimActive = false
    elseif modeName == "Обычный Аим" then
        ModeButton.Text = "Режим: Обычный Аим"
        ModeButton.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
        _G.AimbotEnabled = true
        _G.SilentAimActive = false
    elseif modeName == "Сайлент Аим" then
        ModeButton.Text = "Режим: Сайлент Аим"
        ModeButton.BackgroundColor3 = Color3.fromRGB(0, 0, 150)
        _G.AimbotEnabled = false
        _G.SilentAimActive = true
    end
end)

-- 2. Кнопка цели
TargetButton.MouseButton1Click:Connect(function()
    if _G.AimTarget == "Head" then
        _G.AimTarget = "HumanoidRootPart"
        TargetButton.Text = "Цель: HumanoidRootPart"
    else
        _G.AimTarget = "Head"
        TargetButton.Text = "Цель: Head"
    end
end)

-- 3. Кнопка ESP
ESPToggle.MouseButton1Click:Connect(function()
    _G.EspEnabled = not _G.EspEnabled
    if _G.EspEnabled then
        ESPToggle.Text = "ESP (ВХ): ВКЛЮЧЕНО"
        ESPToggle.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
    else
        ESPToggle.Text = "ESP (ВХ): ВЫКЛЮЧЕНО"
        ESPToggle.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    end
end)

-- 4. Кнопка BunnyHop
BHopToggle.MouseButton1Click:Connect(function()
    _G.BHopEnabled = not _G.BHopEnabled
    if _G.BHopEnabled then
        BHopToggle.Text = "BUNNYHOP: ВКЛЮЧЕН"
        BHopToggle.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
    else
        BHopToggle.Text = "BUNNYHOP: ВЫКЛЮЧЕН"
        BHopToggle.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    end
end)

-- 5. Кнопка Третьего лица
ThirdPersonToggle.MouseButton1Click:Connect(function()
    _G.ThirdPersonActive = not _G.ThirdPersonActive
    if _G.ThirdPersonActive then
        ThirdPersonToggle.Text = "ТРЕТЬЕ ЛИЦО: ВКЛ"
        ThirdPersonToggle.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
    else
        ThirdPersonToggle.Text = "ТРЕТЬЕ ЛИЦО: ВЫКЛ"
        ThirdPersonToggle.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        LocalPlayer.CameraMaxZoomDistance = 0.5
        LocalPlayer.CameraMinZoomDistance = 0.5
    end
end)

-- 6. Кнопка Окружения (Небо и Гамма)
local envState = 1
local ColorCorrection = Lighting:FindFirstChildOfClass("ColorCorrectionEffect")
if not ColorCorrection then
    ColorCorrection = Instance.new("ColorCorrectionEffect")
    ColorCorrection.Parent = Lighting
end

EnvironmentButton.MouseButton1Click:Connect(function()
    envState = envState + 1
    if envState > 3 then envState = 1 end
    
    if envState == 1 then
        Lighting.TimeOfDay = "14:00:00"
        Lighting.Brightness = 3
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        ColorCorrection.Saturation = 0
        ColorCorrection.Contrast = 0
        ColorCorrection.Brightness = 0
        EnvironmentButton.Text = "Небо и Гамма: Стандарт"
    elseif envState == 2 then
        Lighting.TimeOfDay = "00:00:00"
        Lighting.Brightness = 0
        Lighting.OutdoorAmbient = Color3.fromRGB(15, 15, 35)
        ColorCorrection.Saturation = 0.6
        ColorCorrection.Contrast = 0.3
        ColorCorrection.Brightness = 0.05
        EnvironmentButton.Text = "Небо и Гамма: Полночь"
    elseif envState == 3 then
        Lighting.TimeOfDay = "18:20:00"
        Lighting.Brightness = 1.5
        Lighting.OutdoorAmbient = Color3.fromRGB(100, 50, 40)
        ColorCorrection.Saturation = -0.1
        ColorCorrection.Contrast = 0.4
        ColorCorrection.Brightness = -0.05
        EnvironmentButton.Text = "Небо и Гамма: Закат"
    end
end)

-- 7. Кнопка Растяга экрана
local aspectRatioTexts = {"Растяг: 16:9 (Стандарт)", "Растяг: 4:3 (Растянуто)", "Растяг: 5:4 (Ультра-растянуто)"}
StretchButton.MouseButton1Click:Connect(function()
    _G.CurrentRatioIndex = _G.CurrentRatioIndex + 1
    if _G.CurrentRatioIndex > 3 then
        _G.CurrentRatioIndex = 1
    end
    StretchButton.Text = aspectRatioTexts[_G.CurrentRatioIndex]
end)


-- ЛОГИКА ПОЛЗУНКОВ (FOV и Скорость)
local draggingFOV = false
SliderBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingFOV = true
    end
end)

local draggingSpeed = false
SpeedBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingSpeed = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingFOV = false
        draggingSpeed = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.MouseMovement then
        if draggingFOV then
            local rX = input.Position.X - SliderBar.AbsolutePosition.X
            local pct = math.clamp(rX / SliderBar.AbsoluteSize.X, 0, 1)
            SliderBtn.Position = UDim2.new(pct, 0, 0.5, 0)
            
            -- Изменяем FOV от 30 до 250
            local calculatedFOV = math.floor(30 + (pct * 220))
            _G.FOV_RADIUS = calculatedFOV
            SliderLabel.Text = "Радиус FOV: " .. tostring(calculatedFOV) .. " px"
        end
        
        if draggingSpeed then
            local rX = input.Position.X - SpeedBar.AbsolutePosition.X
            local pct = math.clamp(rX / SpeedBar.AbsoluteSize.X, 0, 1)
            SpeedBtn.Position = UDim2.new(pct, 0, 0.5, 0)
            
            -- Изменяем скорость от 1.0 до 5.0
            local calculatedSpeed = 1.0 + (pct * 4.0)
            _G.SpeedMultiplier = tonumber(string.format("%.1f", calculatedSpeed))
            SpeedLabel.Text = "Скорость бега: x" .. string.format("%.1f", _G.SpeedMultiplier)
        end
    end
end)
