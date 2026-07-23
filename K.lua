--[[
    Senior Roblox Luau Developer Script
    Target: Delta Executor (iOS / iPad Pro 11)
    Game Structure: Block Strike (Workspace.Players / Workspace.Entities)
    Team Check: Player:GetAttribute("Team")
    Language: Russian (Strict)
]]
-- Проверка на повторный запуск для избежания конфликтов
if _G.BlockStrikeScriptLoaded then
    return
end
_G.BlockStrikeScriptLoaded = true

-- Сервисы Roblox
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Camera = Workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")

-- Переменные локального игрока
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Создание ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaBlockStrikeGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

-- Глобальные настройки скрипта (состояния по умолчанию)
local Settings = {
    AimMode = "Выкл", -- "Выкл", "Обычный Аим", "Сайлент Аим"
    AimTarget = "Head", -- "Head", "HumanoidRootPart"
    EspEnabled = true,
    BhopEnabled = false,
    ThirdPersonEnabled = false,
    SkyMode = "Обычное", -- "Обычное", "Черное", "Гамма"
    StretchMode = "16:9", -- "16:9", "4:3", "5:4"
    FovRadius = 100,
    WalkSpeedMultiplier = 1.0,
    DefaultWalkSpeed = 16
}

-- Глобальные переменные для работы логики
local ScreenCenter = Vector2.new(0, 0)
local CurrentTarget = nil

-- 1. ИДЕАЛЬНОЕ ЦЕНТРИРОВАНИЕ И ОБНОВЛЕНИЕ ЦЕНТРА
local function UpdateScreenCenter()
    local viewportSize = Camera.ViewportSize
    local inset = GuiService:GetGuiInset()
    -- Расчет физического центра с компенсацией вырезов iPad Pro 11
    ScreenCenter = Vector2.new(
        (viewportSize.X - inset.X) / 2,
        (viewportSize.Y - inset.Y) / 2
    )
end

UpdateScreenCenter()
Camera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateScreenCenter)

-- 2. СТАРЫЙ ДИЗАЙН КРУГА FOV С ЗАЛИВКОЙ ВНУТРИ
local FovFrame = Instance.new("Frame")
FovFrame.Name = "FovCircleFrame"
FovFrame.AnchorPoint = Vector2.new(0.5, 0.5)
FovFrame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
FovFrame.BackgroundTransparency = 0.8
FovFrame.BorderSizePixel = 0
FovFrame.ZIndex = 1
FovFrame.Parent = ScreenGui

local FovCorner = Instance.new("UICorner")
FovCorner.CornerRadius = UDim.new(1, 0)
FovCorner.Parent = FovFrame

local FovStroke = Instance.new("UIStroke")
FovStroke.Thickness = 2
FovStroke.Color = Color3.fromRGB(255, 0, 0)
FovStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
FovStroke.Parent = FovFrame

local function RefreshFovVisuals()
    FovFrame.Position = UDim2.new(0, ScreenCenter.X, 0, ScreenCenter.Y)
    FovFrame.Size = UDim2.new(0, Settings.FovRadius * 2, 0, Settings.FovRadius * 2)
    
    if CurrentTarget then
        FovFrame.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        FovStroke.Color = Color3.fromRGB(0, 255, 0)
    else
        FovFrame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        FovStroke.Color = Color3.fromRGB(255, 0, 0)
    end
end

-- 3. СТАРОЕ РАБОЧЕЕ МЕНЮ И КНОПКА ПО ЦЕНТРУ ЭКРАНА
-- Кнопка открытия (шестеренка ⚙️)
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "MenuToggleButton"
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Position = UDim2.new(0, ScreenCenter.X - 25, 0, ScreenCenter.Y - 25)
ToggleButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
ToggleButton.Text = "⚙️"
ToggleButton.TextSize = 24
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.ZIndex = 10
ToggleButton.Parent = ScreenGui

local ToggleButtonCorner = Instance.new("UICorner")
ToggleButtonCorner.CornerRadius = UDim.new(0, 10)
ToggleButtonCorner.Parent = ToggleButton

local ToggleButtonStroke = Instance.new("UIStroke")
ToggleButtonStroke.Thickness = 1
ToggleButtonStroke.Color = Color3.fromRGB(100, 100, 100)
ToggleButtonStroke.Parent = ToggleButton

-- Главное меню настроек (MainMenu)
local MainMenu = Instance.new("Frame")
MainMenu.Name = "MainMenu"
MainMenu.Size = UDim2.new(0, 320, 0, 580)
MainMenu.Position = UDim2.new(0, ScreenCenter.X - 160, 0, ScreenCenter.Y - 290)
MainMenu.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainMenu.Visible = false
MainMenu.ZIndex = 5
MainMenu.Parent = ScreenGui

local MainMenuCorner = Instance.new("UICorner")
MainMenuCorner.CornerRadius = UDim.new(0.05, 0)
MainMenuCorner.Parent = MainMenu

local MainMenuStroke = Instance.new("UIStroke")
MainMenuStroke.Thickness = 2
MainMenuStroke.Color = Color3.fromRGB(80, 80, 80)
MainMenuStroke.Parent = MainMenu

-- Шапка меню
local HeaderLabel = Instance.new("TextLabel")
HeaderLabel.Name = "HeaderLabel"
HeaderLabel.Size = UDim2.new(1, 0, 0, 45)
HeaderLabel.Position = UDim2.new(0, 0, 0, 0)
HeaderLabel.BackgroundTransparency = 1
HeaderLabel.Text = "НАСТРОЙКИ"
HeaderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
HeaderLabel.TextSize = 18
HeaderLabel.Font = Enum.Font.SourceSansBold
HeaderLabel.ZIndex = 6
HeaderLabel.Parent = MainMenu

-- Кнопка закрытия (❌)
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 35, 0, 35)
CloseButton.Position = UDim2.new(1, -40, 0, 5)
CloseButton.BackgroundTransparency = 1
CloseButton.Text = "❌"
CloseButton.TextSize = 16
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.ZIndex = 6
CloseButton.Parent = MainMenu

-- Скролл для размещения элементов управления
local ScrollContainer = Instance.new("ScrollingFrame")
ScrollContainer.Name = "ScrollContainer"
ScrollContainer.Size = UDim2.new(1, 0, 1, -55)
ScrollContainer.Position = UDim2.new(0, 0, 0, 55)
ScrollContainer.BackgroundTransparency = 1
ScrollContainer.CanvasSize = UDim2.new(0, 0, 0, 580)
ScrollContainer.ScrollBarThickness = 4
ScrollContainer.ZIndex = 6
ScrollContainer.Parent = MainMenu

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.Parent = ScrollContainer

-- Вспомогательная функция для создания кнопок управления
local function CreateMenuButton(name, text, layoutOrder)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(0, 280, 0, 45)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 15
    btn.Font = Enum.Font.SourceSans
    btn.LayoutOrder = layoutOrder
    btn.ZIndex = 7
    btn.Parent = ScrollContainer

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn

    local btnStroke = Instance.new("UIStroke")
    btnStroke.Thickness = 1
    btnStroke.Color = Color3.fromRGB(70, 70, 70)
    btnStroke.Parent = btn

    return btn
end

-- Вспомогательная функция для создания ползунков
local function CreateMenuSlider(name, textTemplate, minVal, maxVal, currentVal, layoutOrder, callback)
    local container = Instance.new("Frame")
    container.Name = name .. "Container"
    container.Size = UDim2.new(0, 280, 0, 55)
    container.BackgroundTransparency = 1
    container.LayoutOrder = layoutOrder
    container.ZIndex = 7
    container.Parent = ScrollContainer

    local label = Instance.new("TextLabel")
    label.Name = "SliderLabel"
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = string.gsub(textTemplate, "X", tostring(currentVal))
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextSize = 14
    label.Font = Enum.Font.SourceSans
    label.ZIndex = 7
    label.Parent = container

    local track = Instance.new("Frame")
    track.Name = "Track"
    track.Size = UDim2.new(1, 0, 0, 8)
    track.Position = UDim2.new(0, 0, 0, 30)
    track.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    track.ZIndex = 7
    track.Parent = container

    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = track

    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    local pct = (currentVal - minVal) / (maxVal - minVal)
    fill.Size = UDim2.new(pct, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    fill.ZIndex = 7
    fill.Parent = track

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill

    local knob = Instance.new("TextButton")
    knob.Name = "Knob"
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new(pct, -8, 0.5, -8)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.Text = ""
    knob.ZIndex = 8
    knob.Parent = track

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    local dragging = false

    local function UpdateSliderInput(input)
        local totalWidth = track.AbsoluteSize.X
        local relativeX = input.Position.X - track.AbsolutePosition.X
        local ratio = math.clamp(relativeX / totalWidth, 0, 1)
        
        local rawValue = minVal + (ratio * (maxVal - minVal))
        -- Округление в зависимости от типа данных
        if maxVal <= 10 then
            rawValue = math.round(rawValue * 10) / 10
        else
            rawValue = math.round(rawValue)
        end

        fill.Size = UDim2.new(ratio, 0, 1, 0)
        knob.Position = UDim2.new(ratio, -8, 0.5, -8)
        label.Text = string.gsub(textTemplate, "X", tostring(rawValue))
        
        callback(rawValue)
    end

    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            UpdateSliderInput(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- Создание кнопок и ползунков в меню
local ModeButton = CreateMenuButton("ModeButton", "Режим: Выкл", 1)
local TargetButton = CreateMenuButton("TargetButton", "Цель: Head", 2)
local ESPToggle = CreateMenuButton("ESPToggle", "ESP (ВХ): ВКЛ", 3)
local BHopToggle = CreateMenuButton("BHopToggle", "BUNNYHOP: ВЫКЛ", 4)
local ThirdPersonToggle = CreateMenuButton("ThirdPersonToggle", "ТРЕТЬЕ ЛИЦО: ВЫКЛ", 5)
local EnvironmentButton = CreateMenuButton("EnvironmentButton", "Небо: Обычное", 6)
local StretchButton = CreateMenuButton("StretchButton", "Растяг: 16:9", 7)

-- Ползунки
CreateMenuSlider("FovSlider", "Радиус FOV: X px", 30, 250, Settings.FovRadius, 8, function(value)
    Settings.FovRadius = value
end)

CreateMenuSlider("SpeedSlider", "Скорость бега: xX", 1.0, 5.0, Settings.WalkSpeedMultiplier, 9, function(value)
    Settings.WalkSpeedMultiplier = value
end)

-- Логика плавного перетаскивания (Touch / Drag) для кнопки и меню
local function EnableDrag(guiElement, snapToCenter)
    local dragToggle = nil
    local dragStart = nil
    local startPos = nil

    guiElement.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) and (guiElement == ToggleButton or UserInputService:GetFocusedTextBox() == nil) then
            dragToggle = true
            dragStart = input.Position
            startPos = guiElement.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragToggle = false
                end
            end)
        end
    end)

    guiElement.InputChanged:Connect(function(input)
        if dragToggle and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = input.Position - dragStart
            guiElement.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

EnableDrag(ToggleButton, false)
EnableDrag(MainMenu, false)

-- Обработчики нажатий кнопок интерфейса
ToggleButton.MouseButton1Click:Connect(function()
    MainMenu.Visible = not MainMenu.Visible
end)

CloseButton.MouseButton1Click:Connect(function()
    MainMenu.Visible = false
end)

ModeButton.MouseButton1Click:Connect(function()
    if Settings.AimMode == "Выкл" then
        Settings.AimMode = "Обычный Аим"
    elseif Settings.AimMode == "Обычный Аим" then
        Settings.AimMode = "Сайлент Аим"
    else
        Settings.AimMode = "Выкл"
    end
    ModeButton.Text = "Режим: " .. Settings.AimMode
end)

TargetButton.MouseButton1Click:Connect(function()
    if Settings.AimTarget == "Head" then
        Settings.AimTarget = "HumanoidRootPart"
    else
        Settings.AimTarget = "Head"
    end
    TargetButton.Text = "Цель: " .. Settings.AimTarget
end)

ESPToggle.MouseButton1Click:Connect(function()
    Settings.EspEnabled = not Settings.EspEnabled
    if Settings.EspEnabled then
        ESPToggle.Text = "ESP (ВХ): ВКЛ"
    else
        ESPToggle.Text = "ESP (ВХ): ВЫКЛ"
    end
end)

BHopToggle.MouseButton1Click:Connect(function()
    Settings.BhopEnabled = not Settings.BhopEnabled
    if Settings.BhopEnabled then
        BHopToggle.Text = "BUNNYHOP: ВКЛ"
    else
        BHopToggle.Text = "BUNNYHOP: ВЫКЛ"
    end
end)

ThirdPersonToggle.MouseButton1Click:Connect(function()
    Settings.ThirdPersonEnabled = not Settings.ThirdPersonEnabled
    if Settings.ThirdPersonEnabled then
        ThirdPersonToggle.Text = "ТРЕТЬЕ ЛИЦО: ВКЛ"
        LocalPlayer.CameraMode = Enum.CameraMode.Classic
    else
        ThirdPersonToggle.Text = "ТРЕТЬЕ ЛИЦО: ВЫКЛ"
        LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
    end
end)

EnvironmentButton.MouseButton1Click:Connect(function()
    if Settings.SkyMode == "Обычное" then
        Settings.SkyMode = "Черное"
        game:GetService("Lighting").Ambient = Color3.fromRGB(0, 0, 0)
        game:GetService("Lighting").OutdoorAmbient = Color3.fromRGB(0, 0, 0)
    elseif Settings.SkyMode == "Черное" then
        Settings.SkyMode = "Гамма"
        game:GetService("Lighting").Ambient = Color3.fromRGB(255, 255, 255)
        game:GetService("Lighting").OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    else
        Settings.SkyMode = "Обычное"
        game:GetService("Lighting").Ambient = Color3.fromRGB(128, 128, 128)
        game:GetService("Lighting").OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    end
    EnvironmentButton.Text = "Небо: " .. Settings.SkyMode
end)

StretchButton.MouseButton1Click:Connect(function()
    if Settings.StretchMode == "16:9" then
        Settings.StretchMode = "4:3"
        Camera.FieldOfView = 80
    elseif Settings.StretchMode == "4:3" then
        Settings.StretchMode = "5:4"
        Camera.FieldOfView = 70
    else
        Settings.StretchMode = "16:9"
        Camera.FieldOfView = 90
    end
    StretchButton.Text = "Растяг: " .. Settings.StretchMode
end)

-- 4. НОВАЯ СИСТЕМА АИМА И СТАБИЛЬНЫЙ САЙЛЕНТ АИМ (ANTI-CRASH)
-- Поиск контейнера игроков/сущностей Block Strike
local function GetEntitiesFolder()
    return Workspace:FindFirstChild("Players") or Workspace:FindFirstChild("Entities") or Workspace
end

-- Функция проверки команды на основе кастомного атрибута Block Strike
local function IsEnemy(playerEntity)
    -- Если это полноценный игрок Roblox
    if playerEntity:IsA("Player") then
        if playerEntity == LocalPlayer then return false end
        local myTeam = LocalPlayer:GetAttribute("Team")
        local enemyTeam = playerEntity:GetAttribute("Team")
        if myTeam and enemyTeam then
            return myTeam ~= enemyTeam
        end
        return true
    end
    
    -- Если сущность является моделькой персонажа в Workspace.Players или Workspace.Entities
    local modelPlayer = Players:GetPlayerFromCharacter(playerEntity)
    if modelPlayer then
        if modelPlayer == LocalPlayer then return false end
        local myTeam = LocalPlayer:GetAttribute("Team")
        local enemyTeam = modelPlayer:GetAttribute("Team")
        if myTeam and enemyTeam then
            return myTeam ~= enemyTeam
        end
    end
    
    -- Проверка атрибутов напрямую на модели
    local entityTeam = playerEntity:GetAttribute("Team")
    local myTeam = LocalPlayer:GetAttribute("Team")
    if myTeam and entityTeam then
        return myTeam ~= entityTeam
    end
    
    return true
end

-- Поиск ближайшей валидной цели в круге FOV
local function GetClosestTarget()
    local closestTarget = nil
    local maxDistance = Settings.FovRadius
    local folder = GetEntitiesFolder()
    local children = folder:GetChildren()
    
    -- Также проверяем стандартных игроков, если папка специфична
    if folder ~= Workspace then
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character and not table.find(children, p.Character) then
                table.insert(children, p.Character)
            end
        end
    end
    
    for _, object in ipairs(children) do
        local character = object
        if object:IsA("Player") then
            character = object.Character
        end
        
        if character and character:IsA("Model") and character ~= LocalPlayer.Character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            local targetPart = character:FindFirstChild(Settings.AimTarget)
            
            -- Фильтрация: игнорируем союзников и мертвых/наблюдателей
            if humanoid and humanoid.Health > 0 and targetPart and IsEnemy(object) then
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    local fovDist = (Vector2.new(screenPos.X, screenPos.Y) - ScreenCenter).Magnitude
                    if fovDist < maxDistance then
                        maxDistance = fovDist
                        closestTarget = targetPart
                    end
                end
            end
        end
    end
    
    return closestTarget
end

-- Переменная удержания экрана (для обычного аима на мобильных устройствах)
local IsScreenTouched = false

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        IsScreenTouched = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        IsScreenTouched = false
    end
end)

-- 5. НОВАЯ ОПТИМИЗИРОВАННАЯ СИСТЕМА ВХ (ESP)
local EspObjects = {}

local function CreateEsp(character, playerObject)
    if EspObjects[character] then return end
    
    local boxFrame = Instance.new("Frame")
    boxFrame.Name = "EspBox"
    boxFrame.BackgroundTransparency = 1
    boxFrame.BorderSizePixel = 0
    boxFrame.Size = UDim2.new(0, 0, 0, 0)
    boxFrame.Visible = false
    boxFrame.Parent = ScreenGui
    
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1.5
    stroke.Color = Color3.fromRGB(255, 0, 0)
    stroke.Parent = boxFrame
    
    EspObjects[character] = {
        Box = boxFrame,
        Stroke = stroke,
        PlayerObj = playerObject
    }
end

local function RemoveEsp(character)
    if EspObjects[character] then
        EspObjects[character].Box:Destroy()
        EspObjects[character] = nil
    end
end

-- Автоматическое отслеживание сущностей для ESP
local function MonitorEntities()
    local folder = GetEntitiesFolder()
    
    local function SetupCharacter(child)
        if child:IsA("Model") and child ~= LocalPlayer.Character then
            CreateEsp(child, child)
        elseif child:IsA("Player") and child ~= LocalPlayer then
            child.CharacterAdded:Connect(function(char)
                CreateEsp(char, child)
            end)
            if child.Character then
                CreateEsp(child.Character, child)
            end
        end
    end
    
    folder.ChildAdded:Connect(SetupCharacter)
    for _, child in ipairs(folder:GetChildren()) do
        SetupCharacter(child)
    end
    
    if folder ~= Workspace then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                p.CharacterAdded:Connect(function(char)
                    CreateEsp(char, p)
                end)
                if p.Character then
                    CreateEsp(p.Character, p)
                end
            end
        end
    end
end

-- Обновление ESP рамок в реальном времени
local function UpdateEspVisuals()
    for character, esp in pairs(EspObjects) do
        if not character.Parent or not Settings.EspEnabled or not IsEnemy(esp.PlayerObj) then
            esp.Box.Visible = false
        else
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            local rpart = character:FindFirstChild("HumanoidRootPart")
            if humanoid and humanoid.Health > 0 and rpart then
                local rpartPos, onScreen = Camera:WorldToViewportPoint(rpart.Position)
                if onScreen then
                    -- Расчет размеров коробки на основе дистанции
                    local topPos = Camera:WorldToViewportPoint(rpart.Position + Vector3.new(0, 3, 0))
                    local bottomPos = Camera:WorldToViewportPoint(rpart.Position + Vector3.new(0, -3.5, 0))
                    local boxHeight = math.abs(topPos.Y - bottomPos.Y)
                    local boxWidth = boxHeight * 0.6
                    
                    esp.Box.Size = UDim2.new(0, boxWidth, 0, boxHeight)
                    esp.Box.Position = UDim2.new(0, rpartPos.X - boxWidth / 2, 0, rpartPos.Y - boxHeight / 2)
                    
                    -- Изменение цвета если в аиме
                    if CurrentTarget and CurrentTarget.Parent == character then
                        esp.Stroke.Color = Color3.fromRGB(0, 255, 0)
                    else
                        esp.Stroke.Color = Color3.fromRGB(255, 0, 0)
                    end
                    esp.Box.Visible = true
                else
                    esp.Box.Visible = false
                end
            else
                esp.Box.Visible = false
            end
        end
    end
end

-- Очистка разрушенных объектов ESP из таблицы
RunService.Heartbeat:Connect(function()
    for character, _ in pairs(EspObjects) do
        if not character.Parent then
            RemoveEsp(character)
        end
    end
end)

-- ДОПОЛНИТЕЛЬНЫЕ ФУНКЦИИ (BunnyHop, Скорость, Третье лицо)
local function HandleExtraFeatures()
    -- BunnyHop
    if Settings.BhopEnabled and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.FloorMaterial ~= Enum.BoneType.None then
            humanoid.Jump = true
        end
    end
    
    -- Модификатор скорости бега
    if LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = Settings.DefaultWalkSpeed * Settings.WalkSpeedMultiplier
        end
    end
    
    -- Кастомное Третье Лицо
    if Settings.ThirdPersonEnabled then
        Camera.CameraSubject = LocalPlayer.Character or Camera.CameraSubject
        -- Смещение камеры назад для симуляции 3-го лица
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local rpart = LocalPlayer.Character.HumanoidRootPart
            Camera.CFrame = CFrame.new(rpart.Position - (Camera.CFrame.LookVector * 12), rpart.Position)
        end
    end
end

-- ГЛАВНЫЙ ИСПОЛНИТЕЛЬНЫЙ ЦИКЛ (RenderStepped)
RunService.RenderStepped:Connect(function()
    -- Обновляем текущую валидную цель
    CurrentTarget = GetClosestTarget()
    
    -- Визуализация FOV
    RefreshFovVisuals()
    
    -- Визуализация ESP
    UpdateEspVisuals()
    
    -- Дополнительный функционал
    HandleExtraFeatures()
    
    -- Обработка Аимботов
    if CurrentTarget then
        if Settings.AimMode == "Обычный Аим" and IsScreenTouched then
            -- Плавное наведение CFrame камеры на цель при зажатии экрана
            local targetRotation = CFrame.new(Camera.CFrame.Position, CurrentTarget.Position)
            Camera.CFrame = Camera.CFrame:Lerp(targetRotation, 0.15)
        elseif Settings.AimMode == "Сайлент Аим" then
            -- Стабильный Сайлент Аим: непрерывный микро-доворот взгляда каждый кадр (Anti-Crash)
            -- Безопасно корректирует вектор взгляда без перехвата метаметодов
            local currentLook = Camera.CFrame.LookVector
            local targetDirection = (CurrentTarget.Position - Camera.CFrame.Position).Unit
            
            -- Микро-наведение, перенаправляющее траекторию выстрела движка игры
            local dotProduct = currentLook:Dot(targetDirection)
            if dotProduct < 0.999 then
                local blendedDirection = currentLook:Lerp(targetDirection, 0.25).Unit
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + blendedDirection)
            end
        end
    end
end)

-- Инициализация ESP при старте
MonitorEntities()
