-- Roblox LocalScript для Block Strike (Delta Executor / iPad Pro 11)
-- Вся логика в одном сплошном файле без сокращений и пропусков
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- НАСТРОЙКИ СЛИТНОГО МОДУЛЯ
local Settings = {
    AimbotEnabled = true,
    SilentAimEnabled = true,
    FovRadius = 120,
    FovColorEmpty = Color3.fromRGB(255, 0, 0),
    FovColorLock = Color3.fromRGB(0, 255, 0),
    EspEnabled = true,
    TeamCheck = true,
    StretchMode = "16:9" -- "16:9", "4:3", "5:4"
}

-- ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ ЭКРАНА И ЦЕНТРА
local ScreenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
local GuiInset = GuiService:GetGuiInset()

local function UpdateScreenMetrics()
    local size = Camera.ViewportSize
    GuiInset = GuiService:GetGuiInset()
    ScreenCenter = Vector2.new(size.X / 2, (size.Y - GuiInset.Y) / 2)
end

Camera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateScreenMetrics)
UpdateScreenMetrics()

-- ПОЛУЧЕНИЕ ВСЕХ ПЕРСОНАЖЕЙ (BLOCK STRIKE АДАПТАЦИЯ)
local function GetEntitiesFolder()
    local folder = workspace:FindFirstChild("Players") or workspace:FindFirstChild("Entities")
    if not folder then
        folder = workspace
    end
    return folder
end

-- КОРРЕКТНОЕ ОПРЕДЕЛЕНИЕ КОМАНДЫ (АТРИБУТЫ + СТАНДАРТ)
local function GetPlayerTeam(player)
    if not player then return nil end
    local customTeam = player:GetAttribute("Team")
    if customTeam then return tostring(customTeam) end
    if player.Team then return player.Team.Name end
    if player:FindFirstChild("Team") then return player.Team.Value end
    return nil
end

local function IsEnemy(targetPlayer)
    if not Settings.TeamCheck then return true end
    if targetPlayer == LocalPlayer then return false end
    
    local lpTeam = GetPlayerTeam(LocalPlayer)
    local targetTeam = GetPlayerTeam(targetPlayer)
    
    if lpTeam and targetTeam then
        return lpTeam ~= targetTeam
    end
    
    if LocalPlayer.TeamColor and targetPlayer.TeamColor then
        return LocalPlayer.TeamColor ~= targetPlayer.TeamColor
    end
    
    return true
end

-- ВАЛИДАЦИЯ ЦЕЛИ (ТРОЙНАЯ ПРОВЕРКА И АНТИ-КРАШ)
local function IsValidTarget(model)
    if not model then return false end
    local humanoid = model:FindFirstChildOfClass("Humanoid")
    local head = model:FindFirstChild("Head")
    local root = model:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not head or not root then return false end
    if humanoid.Health <= 0 then return false end
    if head.Transparency >= 0.9 then return false end
    if humanoid:GetState() == Enum.HumanoidStateType.Dead then return false end
    
    -- Поиск игрока по модели
    local targetPlayer = Players:GetPlayerFromCharacter(model)
    if not targetPlayer then
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character == model or p.Name == model.Name then
                targetPlayer = p
                break
            end
        end
    end
    
    if targetPlayer and not IsEnemy(targetPlayer) then
        return false
    end
    
    return true
end

-- ПРОВЕРКА ВИДИМОСТИ (RAYCAST)
local function IsVisible(targetPart, character)
    local origin = Camera.CFrame.Position
    local direction = targetPart.Position - origin
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {LocalPlayer.Character, Camera, character}
    params.IgnoreWater = true
    
    local result = workspace:Raycast(origin, direction, params)
    return result == nil
end

-- СОЗДАНИЕ PREMIUM UI (СКРИН СТРУКТУРА)
local CoreGui = game:GetService("CoreGui")
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PremiumDeltaMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui

-- FOV КРУГ (ДЛЯ IPAD)
local FovGui = Instance.new("ScreenGui")
FovGui.Name = "FovDisplay"
FovGui.ResetOnSpawn = false
FovGui.Parent = CoreGui

local FovFrame = Instance.new("Frame")
FovFrame.AnchorPoint = Vector2.new(0.5, 0.5)
FovFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
FovFrame.Size = UDim2.new(0, Settings.FovRadius * 2, 0, Settings.FovRadius * 2)
FovFrame.BackgroundTransparency = 1
FovFrame.Parent = FovGui

local FovCorner = Instance.new("UICorner")
FovCorner.CornerRadius = UDim.new(1, 0)
FovCorner.Parent = FovFrame

local FovStroke = Instance.new("UIStroke")
FovStroke.Color = Settings.FovColorEmpty
FovStroke.Thickness = 2
FovStroke.Parent = FovFrame

-- КНОПКА-ШЕСТЕРЕНКА (СПАВН СТРОГО В ЦЕНТРЕ ПО ИНСТРУКЦИИ)
local GearButton = Instance.new("TextButton")
GearButton.Name = "GearButton"
GearButton.Size = UDim2.new(0, 50, 0, 50)
GearButton.AnchorPoint = Vector2.new(0.5, 0.5)
GearButton.Position = UDim2.new(0.5, 0, 0.5, 0) -- Строго в центре прицела при первом запуске
GearButton.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
GearButton.Text = "⚙️"
GearButton.TextSize = 25
GearButton.TextColor3 = Color3.fromRGB(255, 255, 255)
GearButton.Parent = ScreenGui

local GearCorner = Instance.new("UICorner")
GearCorner.CornerRadius = UDim.new(0.5, 0)
GearCorner.Parent = GearButton

local GearStroke = Instance.new("UIStroke")
GearStroke.Color = Color3.fromRGB(0, 150, 255)
GearStroke.Thickness = 1.5
GearStroke.Parent = GearButton

-- ФУНКЦИЯ ДРАГГИНГА ДЛЯ IPAD (ТАЧ ПОДДЕРЖКА)
local function MakeDraggable(frame)
    local dragging = false
    local dragInput, dragStart, startPos

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

MakeDraggable(GearButton)

-- ГЛАВНОЕ МЕНЮ (ТЕМНОЕ ПРЕМИУМ)
local MainMenu = Instance.new("Frame")
MainMenu.Name = "MainMenu"
MainMenu.Size = UDim2.new(0, 350, 0, 250)
MainMenu.AnchorPoint = Vector2.new(0.5, 0.5)
MainMenu.Position = UDim2.new(0.5, 0, 0.5, 0)
MainMenu.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainMenu.Visible = false
MainMenu.Parent = ScreenGui

local MenuCorner = Instance.new("UICorner")
MenuCorner.CornerRadius = UDim.new(0, 12)
MenuCorner.Parent = MainMenu

local MenuStroke = Instance.new("UIStroke")
MenuStroke.Color = Color3.fromRGB(40, 40, 50)
MenuStroke.Thickness = 2
MenuStroke.Parent = MainMenu

MakeDraggable(MainMenu)

-- ЗАГЛОВОК МЕНЮ
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 0, 40)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "DELTA PREMIUM — BLOCK STRIKE"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.SourceSansBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainMenu

-- КРЕСТИК ЗАКРЫТИЯ ❌
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.BackgroundTransparency = 1
CloseButton.Text = "❌"
CloseButton.TextSize = 18
CloseButton.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseButton.Parent = MainMenu

CloseButton.MouseButton1Click:Connect(function()
    MainMenu.Visible = false
    GearButton.Visible = true
end)

GearButton.MouseButton1Click:Connect(function()
    MainMenu.Visible = true
    GearButton.Visible = false
end)

-- КОНТЕЙНЕР ДЛЯ ЭЛЕМЕНТОВ
local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 10)
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder

local Container = Instance.new("Frame")
Container.Size = UDim2.new(1, -30, 1, -60)
Container.Position = UDim2.new(0, 15, 0, 50)
Container.BackgroundTransparency = 1
Container.Parent = MainMenu
ListLayout.Parent = Container

-- ФУНКЦИЯ СОЗДАНИЯ ПЕРЕКЛЮЧАТЕЛЕЙ (TOGGLES)
local function CreateToggle(name, default, callback)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, 0, 0, 35)
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.Parent = Container
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextSize = 16
    label.Font = Enum.Font.SourceSans
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggleFrame
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.25, 0, 0.8, 0)
    button.Position = UDim2.new(0.75, 0, 0.1, 0)
    button.BackgroundColor3 = default and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(50, 50, 60)
    button.Text = default and "ON" or "OFF"
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.SourceSansBold
    button.TextSize = 14
    button.Parent = toggleFrame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = button
    
    local state = default

    button.MouseButton1Click:Connect(function()
        state = not state
        button.BackgroundColor3 = state and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(50, 50, 60)
        button.Text = state and "ON" or "OFF"
        callback(state)
    end)
end

-- ФУНКЦИЯ ДЛЯ КНОПКИ РАСТЯГА СТРЕТЧА
local function CreateStretchButton()
    local stretchFrame = Instance.new("Frame")
    stretchFrame.Size = UDim2.new(1, 0, 0, 35)
    stretchFrame.BackgroundTransparency = 1
    stretchFrame.Parent = Container
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "Растяг Экрана:"
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextSize = 16
    label.Font = Enum.Font.SourceSans
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = stretchFrame
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.45, 0, 0.8, 0)
    btn.Position = UDim2.new(0.55, 0, 0.1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(70, 30, 120)
    btn.Text = "Режим: 16:9"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14
    btn.Parent = stretchFrame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    
    local modes = {"16:9", "4:3", "5:4"}
    local currentIdx = 1
    
    btn.MouseButton1Click:Connect(function()
        currentIdx = currentIdx + 1
        if currentIdx > #modes then currentIdx = 1 end
        Settings.StretchMode = modes[currentIdx]
        btn.Text = "Режим: " .. Settings.StretchMode
        
        -- Управление пропорциями
        if Settings.StretchMode == "16:9" then
            Camera.TargetAspectRatio = 1.777777
        elseif Settings.StretchMode == "4:3" then
            Camera.TargetAspectRatio = 1.333333
        elseif Settings.StretchMode == "5:4" then
            Camera.TargetAspectRatio = 1.25
        end
    end)
end

-- Инициализация элементов меню
CreateToggle("Сайлент Аимбот", Settings.SilentAimEnabled, function(val) Settings.SilentAimEnabled = val end)
CreateToggle("Проверка Команды", Settings.TeamCheck, function(val) Settings.TeamCheck = val end)
CreateToggle("Отображение ESP", Settings.EspEnabled, function(val) Settings.EspEnabled = val end)
CreateStretchButton()

-- КОРНЕВОЙ ОРГАНИЗАТОР ЭФФЕКТОВ ESP (БЕЗ ДУБЛИРОВАНИЯ И С ЗАЩИТОЙ ОТ ЛАГОВ)
local ActiveEsp = {}

-- Нативный Трейсер через Beam
local function CreateNativeTracer(character, rootPart)
    local attachment0 = Instance.new("Attachment")
    attachment0.Name = "EspTracerAttachmentCam"
    attachment0.Parent = workspace.Terrain -- Привязка к миру во избежание лагов
    
    local attachment1 = Instance.new("Attachment")
    attachment1.Name = "EspTracerAttachmentEnemy"
    attachment1.Parent = rootPart
    
    local beam = Instance.new("Beam")
    beam.Attachment0 = attachment0
    beam.Attachment1 = attachment1
    beam.Width0 = 0.05
    beam.Width1 = 0.05
    beam.FaceCamera = true
    beam.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
    beam.Transparency = NumberSequence.new(0.2)
    beam.Parent = rootPart
    
    return attachment0, beam
end

local function ApplyEspEffects(model)
    if not model or ActiveEsp[model] then return end
    
    local root = model:WaitForChild("HumanoidRootPart", 5)
    local head = model:WaitForChild("Head", 5)
    local humanoid = model:WaitForChild("Humanoid", 5)
    if not root or not head or not humanoid then return end
    
    -- 1. Highlight (Нативное сквозное просвечивание)
    local hl = Instance.new("Highlight")
    hl.Name = "EspHighlight"
    hl.FillTransparency = 0.4
    hl.OutlineTransparency = 0.1
    hl.Parent = model
    
    -- 2. BillboardGui для 2D-бокса и интерфейса
    local bGui = Instance.new("BillboardGui")
    bGui.Name = "EspBillboard"
    bGui.Size = UDim2.new(4.5, 0, 5.5, 0)
    bGui.AlwaysOnTop = true
    bGui.Adornee = root
    bGui.Parent = root
    
    -- Обводка/Рамка бокса
    local boxFrame = Instance.new("Frame")
    boxFrame.Size = UDim2.new(1, 0, 1, 0)
    boxFrame.BackgroundTransparency = 1
    boxFrame.Parent = bGui
    
    local boxStroke = Instance.new("UIStroke")
    boxStroke.Thickness = 1.5
    boxStroke.Color = Color3.fromRGB(255, 0, 0)
    boxStroke.Parent = boxFrame
    
    -- Вертикальный HP-бар СТРОГО СПРАВА
    local hpTrack = Instance.new("Frame")
    hpTrack.Size = UDim2.new(0.06, 0, 1, 0)
    hpTrack.Position = UDim2.new(1, 5, 0, 0) -- Строго справа от бокса
    hpTrack.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
    hpTrack.BorderSizePixel = 0
    hpTrack.Parent = bGui
    
    local hpBar = Instance.new("Frame")
    hpBar.Size = UDim2.new(1, 0, 1, 0)
    hpBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    hpBar.BorderSizePixel = 0
    hpBar.Parent = hpTrack
    
    -- Имя и Дистанция НАД головой
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(2, 0, 0, 20)
    textLabel.Position = UDim2.new(-0.5, 0, 0, -25)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextSize = 13
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.TextStrokeTransparency = 0
    textLabel.Parent = bGui
    
    -- Трейсер через Beam
    local tracerAtt0, tracerBeam = CreateNativeTracer(model, root)
    
    ActiveEsp[model] = {
        Highlight = hl,
        Billboard = bGui,
        BoxStroke = boxStroke,
        HpBar = hpBar,
        TextLabel = textLabel,
        TracerAttachment0 = tracerAtt0,
        TracerBeam = tracerBeam
    }
end

local function RemoveEspEffects(model)
    local cache = ActiveEsp[model]
    if cache then
        if cache.Highlight then cache.Highlight:Destroy() end
        if cache.Billboard then cache.Billboard:Destroy() end
        if cache.TracerAttachment0 then cache.TracerAttachment0:Destroy() end
        if cache.TracerBeam then cache.TracerBeam:Destroy() end
        ActiveEsp[model] = nil
    end
end

-- ОБНОВЛЕНИЕ ESP И ПОИСК БЛИЖАЙШЕЙ ЦЕЛИ В FOV ЗА ОДИН КАДР
local function ProcessFrame()
    local entitiesFolder = GetEntitiesFolder()
    local children = entitiesFolder:GetChildren()
    local closestTarget = nil
    local minDistanceToCenter = Settings.FovRadius
    
    -- Динамическая позиция нижнего центра для лучей трейсеров
    local tracerOriginWorld = Camera:ViewportPointToRay(ScreenCenter.X, Camera.ViewportSize.Y - 10).Origin
    
    for _, child in ipairs(children) do
        if child:IsA("Model") and child ~= LocalPlayer.Character then
            if IsValidTarget(child) then
                -- Активация ESP, если объект валиден
                if Settings.EspEnabled then
                    if not ActiveEsp[child] then
                        ApplyEspEffects(child)
                    end
                    
                    local data = ActiveEsp[child]
                    if data then
                        data.Billboard.Enabled = true
                        data.Highlight.Enabled = true
                        
                        local head = child:FindFirstChild("Head")
                        local root = child:FindFirstChild("HumanoidRootPart")
                        local humanoid = child:FindFirstChildOfClass("Humanoid")
                        
                        if head and root and humanoid then
                            -- Проверка видимости для смены цвета нативного Highlight
                            local visible = IsVisible(head, child)
                            
                            if visible then
                                data.Highlight.FillColor = Color3.fromRGB(0, 255, 0)
                                data.Highlight.OutlineColor = Color3.fromRGB(0, 255, 0)
                                data.BoxStroke.Color = Color3.fromRGB(0, 255, 0)
                            else
                                data.Highlight.FillColor = Color3.fromRGB(255, 0, 0)
                                data.Highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
                                data.BoxStroke.Color = Color3.fromRGB(255, 0, 0)
                            end
                            
                            -- Обновление ХП бара (плавный градиент)
                            local hpPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
                            data.HpBar.Size = UDim2.new(1, 0, hpPercent, 0)
                            data.HpBar.Position = UDim2.new(0, 0, 1 - hpPercent, 0)
                            data.HpBar.BackgroundColor3 = Color3.fromHSV(hpPercent * 0.33, 1, 1)
                            
                            -- Расчет дистанции и имени
                            local distance = math.floor((Camera.CFrame.Position - root.Position).Magnitude)
                            local nameClean = child.Name
                            local pFromChar = Players:GetPlayerFromCharacter(child)
                            if pFromChar then nameClean = pFromChar.DisplayName end
                            data.TextLabel.Text = string.format("%s [%d м]", nameClean, distance)
                            
                            -- Нативный сверхбыстрый Трейсер (Beam позиционирование)
                            if data.TracerAttachment0 then
                                data.TracerAttachment0.Position = tracerOriginWorld
                                data.TracerBeam.Color = ColorSequence.new(visible and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0))
                            end
                            
                            -- ПРОВЕРКА FOV ДЛЯ АИМБОТА
                            local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                            if onScreen then
                                local screenPos2D = Vector2.new(screenPos.X, screenPos.Y)
                                local distToCenter = (screenPos2D - ScreenCenter).Magnitude
                                if distToCenter < minDistanceToCenter then
                                    minDistanceToCenter = distToCenter
                                    closestTarget = head
                                end
                            end
                        end
                    end
                else
                    -- Отключение рендеринга ESP элементов при выключении флага
                    if ActiveEsp[child] then
                        ActiveEsp[child].Billboard.Enabled = false
                        ActiveEsp[child].Highlight.Enabled = false
                        if ActiveEsp[child].TracerBeam then
                            ActiveEsp[child].TracerBeam.Color = ColorSequence.new(Color3.new(0,0,0), Color3.new(0,0,0))
                        end
                    end
                end
            else
                -- Если цель больше не валидна (умерла/сменила команду)
                RemoveEspEffects(child)
            end
        end
    end
    
    -- Очистка несуществующих объектов
    for model, _ in pairs(ActiveEsp) do
        if not model or not model.Parent or not entitiesFolder:FindFirstChild(model.Name) then
            RemoveEspEffects(model)
        end
    end
    
    -- СИСТЕМА УЛЬТРА САЙЛЕНТ АИМБОТА (НЕПРЕРЫВНЫЙ МИКРО-ДОВОРOT КАМЕРЫ ДЛЯ IPAD)
    if Settings.SilentAimEnabled and closestTarget then
        FovStroke.Color = Settings.FovColorLock
        
        -- Проверяем зажатие тача экрана или выполнение выстрелов (автоподдержка)
        local isPressing = UserInputService:IsMouseButtonPressed(Enum.MouseButton1) or #UserInputService:GetTouches() > 0
        if isPressing then
            local targetCFrame = CFrame.new(Camera.CFrame.Position, closestTarget.Position)
            -- Плавная интерполяция (микро-доворот) без тряски интерфейса и вылетов
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, 0.25)
        end
    else
        FovStroke.Color = Settings.FovColorEmpty
    end
end

-- ПОТОК ИСПОЛНЕНИЯ (СТАРТ СРАЗУ И БЕЗ ЗАДЕРЖЕК)
RunService.RenderStepped:Connect(ProcessFrame)

-- ОТСЛЕЖИВАНИЕ ДИНАМИЧЕСКОГО ИЗМЕНЕНИЯ МИРА И ЭНТИТИ
local targetFolder = GetEntitiesFolder()

targetFolder.ChildAdded:Connect(function(child)
    if child:IsA("Model") then
        task.wait(0.1)
        if IsValidTarget(child) and Settings.EspEnabled then
            ApplyEspEffects(child)
        end
    end
end)

targetFolder.ChildRemoved:Connect(function(child)
    RemoveEspEffects(child)
end)
