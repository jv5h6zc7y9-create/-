--!strict
--[[
    Block Strike Ultimate Monolith Engine (Perfected ESP & AimToHead)
    Монолитный скрипт: Точные TikTok-боксы со сменой цвета, динамический индикатор видимости (красный/зеленый),
    регулировка высоты прицела/круга через ползунок в меню, жесткий аим строго в голову,
    и полное удаление отдачи/разброса внутри модуля оружия.
]]--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local DrawingSupported = (Drawing ~= nil and type(Drawing.new) == "function")

-- Глобальные настройки
_G.AimAssistEnabled = false
_G.NoSpreadEnabled = false
_G.SkinChangerEnabled = false
_G.BulletTracersEnabled = false 
_G.FullBrightEnabled = false
_G.AimSmoothness = 0.18
_G.AimFOV = 140
_G.TargetPart = "Head" -- Строго в голову
_G.SelectedSkinColor = Color3.fromRGB(255, 100, 0)
_G.TracerColor = Color3.fromRGB(0, 255, 255)
_G.ESPTheme = "Green" -- "Green", "Blue", "Yellow"
_G.FOVYOffset = 0 -- Смещение круга FOV по вертикали через ползунок

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BlockStrikeUltimateMonolithFinal"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local FOVCircle = Instance.new("Frame")
FOVCircle.Name = "FOVCircle"
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
FOVCircle.BackgroundTransparency = 0.92
FOVCircle.BorderSizePixel = 0
FOVCircle.Visible = true
FOVCircle.Parent = ScreenGui

local FOVStroke = Instance.new("UIStroke")
FOVStroke.Thickness = 1.5
FOVStroke.Color = Color3.fromRGB(255, 0, 0)
FOVStroke.Parent = FOVCircle

local FOVCorner = Instance.new("UICorner")
FOVCorner.CornerRadius = UDim.new(1, 0)
FOVCorner.Parent = FOVCircle

local MenuButton = Instance.new("TextButton")
MenuButton.Name = "MenuButton"
MenuButton.Size = UDim2.new(0, 60, 0, 60)
MenuButton.Position = UDim2.new(0, 20, 0, 20)
MenuButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MenuButton.Text = "⚙️"
MenuButton.TextSize = 28
MenuButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MenuButton.Parent = ScreenGui

local MenuButtonCorner = Instance.new("UICorner")
MenuButtonCorner.CornerRadius = UDim.new(0.3, 0)
MenuButtonCorner.Parent = MenuButton

local MenuButtonStroke = Instance.new("UIStroke")
MenuButtonStroke.Thickness = 2
MenuButtonStroke.Color = Color3.fromRGB(0, 255, 150)
MenuButtonStroke.Parent = MenuButton

local MainMenu = Instance.new("Frame")
MainMenu.Name = "MainMenu"
MainMenu.Size = UDim2.new(0, 380, 0, 720)
MainMenu.Position = UDim2.new(0.5, -190, 0.5, -360)
MainMenu.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
MainMenu.Visible = false
MainMenu.Parent = ScreenGui

local MainMenuCorner = Instance.new("UICorner")
MainMenuCorner.CornerRadius = UDim.new(0.05, 0)
MainMenuCorner.Parent = MainMenu

local MainMenuStroke = Instance.new("UIStroke")
MainMenuStroke.Thickness = 2
MainMenuStroke.Color = Color3.fromRGB(0, 255, 150)
MainMenuStroke.Parent = MainMenu

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(1, 0, 0, 50)
TitleLabel.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
TitleLabel.Text = "⚡ BLOCK STRIKE ULTIMATE (HEADSHOT EDITION) ⚡"
TitleLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
TitleLabel.TextSize = 12
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.Parent = MainMenu

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0.2, 0)
TitleCorner.Parent = TitleLabel

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 34, 0, 34)
CloseButton.Position = UDim2.new(1, -42, 0, 8)
CloseButton.BackgroundColor3 = Color3.fromRGB(220, 40, 40)
CloseButton.Text = "❌"
CloseButton.TextSize = 14
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Parent = MainMenu

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0.3, 0)
CloseCorner.Parent = CloseButton

local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -20, 1, -70)
ContentFrame.Position = UDim2.new(0, 10, 0, 60)
ContentFrame.BackgroundTransparency = 1
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 850)
ContentFrame.ScrollBarThickness = 4
ContentFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 150)
ContentFrame.Parent = MainMenu

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 12)
UIListLayout.Parent = ContentFrame

local function createButton(name, text, defaultColor)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(1, 0, 0, 45)
    btn.BackgroundColor3 = defaultColor or Color3.fromRGB(25, 25, 30)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 15
    btn.Font = Enum.Font.SourceSansBold
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.2, 0)
    corner.Parent = btn
    
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.Color = Color3.fromRGB(40, 40, 45)
    stroke.Parent = btn
    
    btn.Parent = ContentFrame
    return btn
end

local AimButton = createButton("AimButton", "Aim Assist (Строго в голову): ВЫКЛ")
local NoSpreadButton = createButton("NoSpreadButton", "Удаление Отдачи/Разброса (Delta): ВЫКЛ")
local TracersButton = createButton("TracersButton", "Трассеры Пуль: ВЫКЛ")
local SkinButton = createButton("SkinButton", "Скинченджер (Оружие + Нож): ВЫКЛ")
local ESPToggle = createButton("ESPToggle", "TikTok ESP (Как на скриншоте): ВКЛ", Color3.fromRGB(0, 100, 60))
local ThemeButton = createButton("ThemeButton", "Цвет ВХ (Зеленый / Синий / Желтый): Зеленый")
local FullBrightButton = createButton("FullBrightButton", "Ночное Виденье: ВЫКЛ")

-- Слайдер радиуса FOV
local SliderContainer = Instance.new("Frame")
SliderContainer.Name = "SliderContainer"
SliderContainer.Size = UDim2.new(1, 0, 0, 55)
SliderContainer.BackgroundTransparency = 1
SliderContainer.Parent = ContentFrame

local SliderLabel = Instance.new("TextLabel")
SliderLabel.Name = "SliderLabel"
SliderLabel.Size = UDim2.new(1, 0, 0, 20)
SliderLabel.BackgroundTransparency = 1
SliderLabel.Text = "Радиус FOV: 140 px"
SliderLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
SliderLabel.TextSize = 14
SliderLabel.Font = Enum.Font.SourceSansBold
SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
SliderLabel.Parent = SliderContainer

local SliderBar = Instance.new("Frame")
SliderBar.Name = "SliderBar"
SliderBar.Size = UDim2.new(1, 0, 0, 8)
SliderBar.Position = UDim2.new(0, 0, 0, 30)
SliderBar.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
SliderBar.BorderSizePixel = 0
SliderBar.Parent = SliderContainer

local SliderBarCorner = Instance.new("UICorner")
SliderBarCorner.CornerRadius = UDim.new(1, 0)
SliderBarCorner.Parent = SliderBar

local SliderBtn = Instance.new("TextButton")
SliderBtn.Name = "SliderBtn"
SliderBtn.Size = UDim2.new(0, 20, 0, 20)
SliderBtn.AnchorPoint = Vector2.new(0.5, 0.5)
SliderBtn.Position = UDim2.new(0.45, 0, 0.5, 0)
SliderBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
SliderBtn.Text = ""
SliderBtn.Parent = SliderBar

local SliderBtnCorner = Instance.new("UICorner")
SliderBtnCorner.CornerRadius = UDim.new(1, 0)
SliderBtnCorner.Parent = SliderBtn

-- Слайдер высоты круга (по вертикали)
local YSliderContainer = Instance.new("Frame")
YSliderContainer.Name = "YSliderContainer"
YSliderContainer.Size = UDim2.new(1, 0, 0, 55)
YSliderContainer.BackgroundTransparency = 1
YSliderContainer.Parent = ContentFrame

local YSliderLabel = Instance.new("TextLabel")
YSliderLabel.Name = "YSliderLabel"
YSliderLabel.Size = UDim2.new(1, 0, 0, 20)
YSliderLabel.BackgroundTransparency = 1
YSliderLabel.Text = "Высота круга (Y): 0 px"
YSliderLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
YSliderLabel.TextSize = 14
YSliderLabel.Font = Enum.Font.SourceSansBold
YSliderLabel.TextXAlignment = Enum.TextXAlignment.Left
YSliderLabel.Parent = YSliderContainer

local YSliderBar = Instance.new("Frame")
YSliderBar.Name = "YSliderBar"
YSliderBar.Size = UDim2.new(1, 0, 0, 8)
YSliderBar.Position = UDim2.new(0, 0, 0, 30)
YSliderBar.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
YSliderBar.BorderSizePixel = 0
YSliderBar.Parent = YSliderContainer

local YSliderBarCorner = Instance.new("UICorner")
YSliderBarCorner.CornerRadius = UDim.new(1, 0)
YSliderBarCorner.Parent = YSliderBar

local YSliderBtn = Instance.new("TextButton")
YSliderBtn.Name = "YSliderBtn"
YSliderBtn.Size = UDim2.new(0, 20, 0, 20)
YSliderBtn.AnchorPoint = Vector2.new(0.5, 0.5)
YSliderBtn.Position = UDim2.new(0.5, 0, 0.5, 0)
YSliderBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
YSliderBtn.Text = ""
YSliderBtn.Parent = YSliderBar

local YSliderBtnCorner = Instance.new("UICorner")
YSliderBtnCorner.CornerRadius = UDim.new(1, 0)
YSliderBtnCorner.Parent = YSliderBtn

local espEnabled = true
local draggingSlider = false
local draggingYSlider = false
local screenCenter = Vector2.new(0, 0)
local cacheDrawingObjects = {}

local function updateCenter()
    local viewportSize = Camera.ViewportSize
    local guiInset = GuiService:GetGuiInset()
    screenCenter = Vector2.new(viewportSize.X / 2, ((viewportSize.Y + guiInset.Y) / 2) + _G.FOVYOffset)
    FOVCircle.Position = UDim2.new(0, screenCenter.X, 0, screenCenter.Y)
end

Camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateCenter)
updateCenter()

MenuButton.MouseButton1Click:Connect(function() MainMenu.Visible = not MainMenu.Visible end)
CloseButton.MouseButton1Click:Connect(function() MainMenu.Visible = false end)

local function updateFOV(radius)
    _G.AimFOV = radius
    FOVCircle.Size = UDim2.new(0, radius * 2, 0, radius * 2)
    SliderLabel.Text = "Радиус FOV: " .. tostring(math.round(radius)) .. " px"
end
updateFOV(_G.AimFOV)

-- Управление слайдерами через мышь/тач
SliderBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingSlider = true
    end
end)

YSliderBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingYSlider = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingSlider = false
        draggingYSlider = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingSlider and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.MouseMovement) then
        local rX = input.Position.X - SliderBar.AbsolutePosition.X
        local percentage = math.clamp(rX / SliderBar.AbsoluteSize.X, 0, 1)
        SliderBtn.Position = UDim2.new(percentage, 0, 0.5, 0)
        updateFOV(30 + (percentage * 270))
    elseif draggingYSlider and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.MouseMovement) then
        local rX = input.Position.X - YSliderBar.AbsolutePosition.X
        local percentage = math.clamp(rX / YSliderBar.AbsoluteSize.X, 0, 1)
        YSliderBtn.Position = UDim2.new(percentage, 0, 0.5, 0)
        _G.FOVYOffset = (percentage - 0.5) * 400 -- смещение от -200 до +200 пикселей вверх/вниз
        YSliderLabel.Text = "Высота круга (Y): " .. tostring(math.round(_G.FOVYOffset)) .. " px"
        updateCenter()
    end
end)

-- Переключение кнопок
AimButton.MouseButton1Click:Connect(function()
    _G.AimAssistEnabled = not _G.AimAssistEnabled
    AimButton.BackgroundColor3 = _G.AimAssistEnabled and Color3.fromRGB(0, 100, 60) or Color3.fromRGB(25, 25, 30)
    AimButton.Text = _G.AimAssistEnabled and "Aim Assist (Строго в голову): ВКЛ" or "Aim Assist (Строго в голову): ВЫКЛ"
end)

NoSpreadButton.MouseButton1Click:Connect(function()
    _G.NoSpreadEnabled = not _G.NoSpreadEnabled
    NoSpreadButton.BackgroundColor3 = _G.NoSpreadEnabled and Color3.fromRGB(0, 100, 60) or Color3.fromRGB(25, 25, 30)
    NoSpreadButton.Text = _G.NoSpreadEnabled and "Удаление Отдачи/Разброса (Delta): ВКЛ" or "Удаление Отдачи/Разброса (Delta): ВЫКЛ"
end)

TracersButton.MouseButton1Click:Connect(function()
    _G.BulletTracersEnabled = not _G.BulletTracersEnabled
    TracersButton.BackgroundColor3 = _G.BulletTracersEnabled and Color3.fromRGB(0, 100, 60) or Color3.fromRGB(25, 25, 30)
    TracersButton.Text = _G.BulletTracersEnabled and "Трассеры Пуль: ВКЛ" or "Трассеры Пуль: ВЫКЛ"
end)

SkinButton.MouseButton1Click:Connect(function()
    _G.SkinChangerEnabled = not _G.SkinChangerEnabled
    SkinButton.BackgroundColor3 = _G.SkinChangerEnabled and Color3.fromRGB(0, 100, 60) or Color3.fromRGB(25, 25, 30)
    SkinButton.Text = _G.SkinChangerEnabled and "Скинченджер (Оружие + Нож): ВКЛ" or "Скинченджер (Оружие + Нож): ВЫКЛ"
end)

FullBrightButton.MouseButton1Click:Connect(function()
    _G.FullBrightEnabled = not _G.FullBrightEnabled
    FullBrightButton.BackgroundColor3 = _G.FullBrightEnabled and Color3.fromRGB(0, 100, 60) or Color3.fromRGB(25, 25, 30)
    FullBrightButton.Text = _G.FullBrightEnabled and "Ночное Виденье: ВКЛ" or "Ночное Виденье: ВЫКЛ"
end)

ThemeButton.MouseButton1Click:Connect(function()
    if _G.ESPTheme == "Green" then
        _G.ESPTheme = "Blue"
        ThemeButton.Text = "Цвет ВХ: Синий киберпанк"
    elseif _G.ESPTheme == "Blue" then
        _G.ESPTheme = "Yellow"
        ThemeButton.Text = "Цвет ВХ: Жёлтый янтарь"
    else
        _G.ESPTheme = "Green"
        ThemeButton.Text = "Цвет ВХ: Классический зеленый"
    end
end)

local function removeEsp(playerName)
    local data = cacheDrawingObjects[playerName]
    if data then
        pcall(function()
            if data.Box then data.Box.Visible = false end
            if data.HpBackground then data.HpBackground.Visible = false end
            if data.HpFill then data.HpFill.Visible = false end
            if data.Text then data.Text.Visible = false end
            if data.WeaponText then data.WeaponText.Visible = false end
        end)
    end
end

ESPToggle.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    if espEnabled then
        ESPToggle.BackgroundColor3 = Color3.fromRGB(0, 100, 60)
        ESPToggle.Text = "TikTok ESP (Как на скриншоте): ВКЛ"
    else
        ESPToggle.BackgroundColor3 = Color3.fromRGB(160, 30, 30)
        ESPToggle.Text = "TikTok ESP (Как на скриншоте): ВЫКЛ"
        for playerName, _ in pairs(cacheDrawingObjects) do
            removeEsp(playerName)
        end
    end
end)

local function isEnemy(targetPlayer)
    if not targetPlayer or targetPlayer == LocalPlayer then return false end
    if targetPlayer.Team and LocalPlayer.Team then
        return targetPlayer.Team ~= LocalPlayer.Team
    end
    return true
end

local function getCharacter(player)
    if player == LocalPlayer then return player.Character end
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Head") then 
        return char 
    end
    for _, child in ipairs(Workspace:GetChildren()) do
        if child:IsA("Model") and child.Name == player.Name then
            if child:FindFirstChild("HumanoidRootPart") and child:FindFirstChild("Head") then
                return child
            end
        end
    end
    return nil
end

-- Проверка видимости через рейкаст (преграды)
local function IsVisibleFast(targetPart)
    local character = LocalPlayer.Character
    if not character then return false end
    local head = character:FindFirstChild("Head")
    if not head then return false end
    
    local _, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
    if not onScreen then return false end
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {character, targetPart.Parent}
    raycastParams.IgnoreWater = true
    
    local origin = Camera.CFrame.Position
    local direction = targetPart.Position - origin
    local raycastResult = workspace:Raycast(origin, direction, raycastParams)
    
    if raycastResult == nil or raycastResult.Instance:IsDescendantOf(targetPart.Parent) then
        return true -- Виден (нет преград)
    end
    return false -- За препятствием
end

local cachedTarget = nil
local lastTargetUpdate = 0
local TARGET_UPDATE_INTERVAL = 0.05

-- Аим строго в голову (TargetPart всегда "Head")
local function GetHeadTarget()
    if tick() - lastTargetUpdate > TARGET_UPDATE_INTERVAL then
        cachedTarget = nil
        local closestTarget = nil
        local shortestDistance = _G.AimFOV

        for _, player in ipairs(Players:GetPlayers()) do
            if not isEnemy(player) then continue end
            local char = getCharacter(player)
            if char and char:FindFirstChild("Head") and char:FindFirstChildOfClass("Humanoid") then
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid.Health > 0 then
                    local headPart = char.Head
                    local screenPos, onScreen = Camera:WorldToViewportPoint(headPart.Position)
                    
                    if onScreen then
                        local distance = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                        if distance < shortestDistance then
                            if IsVisibleFast(headPart) then
                                shortestDistance = distance
                                closestTarget = headPart
                            end
                        end
                    end
                end
            end
        end
        cachedTarget = closestTarget
        lastTargetUpdate = tick()
    end
    return cachedTarget
end

local function createPlayerDrawingObjects(playerName)
    if not DrawingSupported then return nil end
    if not cacheDrawingObjects[playerName] then
        local data = {}
        pcall(function()
            data.Box = Drawing.new("Square")
            data.Box.Thickness = 1.5
            data.Box.Filled = false
            data.Box.Visible = false
            
            data.HpBackground = Drawing.new("Square")
            data.HpBackground.Thickness = 1
            data.HpBackground.Filled = true
            data.HpBackground.Color = Color3.fromRGB(60, 10, 10)
            data.HpBackground.Visible = false
            
            data.HpFill = Drawing.new("Square")
            data.HpFill.Thickness = 1
            data.HpFill.Filled = true
            data.HpFill.Visible = false
            
            data.Text = Drawing.new("Text")
            data.Text.Size = 13
            data.Text.Center = true
            data.Text.Outline = true
            data.Text.Visible = false

            data.WeaponText = Drawing.new("Text")
            data.WeaponText.Size = 12
            data.WeaponText.Center = true
            data.WeaponText.Outline = true
            data.WeaponText.Color = Color3.fromRGB(200, 200, 200)
            data.WeaponText.Visible = false
        end)
        cacheDrawingObjects[playerName] = data
    end
    return cacheDrawingObjects[playerName]
end

-- Обработка стрельбы и трассеров
local tracerPool = {}
local MAX_TRACERS = 5
local isShooting = false

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isShooting = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isShooting = false
    end
end)

local function CreateBulletTracerOptimized(originPos, targetPos)
    if #tracerPool >= MAX_TRACERS then
        local old = table.remove(tracerPool, 1)
        pcall(function()
            if old.PartA then old.PartA:Destroy() end
            if old.PartB then old.PartB:Destroy() end
        end)
    end
    pcall(function()
        local partA = Instance.new("Part")
        partA.Size = Vector3.new(0.1, 0.1, 0.1)
        partA.Position = originPos
        partA.Transparency = 1
        partA.Anchored = true
        partA.CanCollide = false
        partA.Parent = Workspace

        local partB = Instance.new("Part")
        partB.Size = Vector3.new(0.1, 0.1, 0.1)
        partB.Position = targetPos
        partB.Transparency = 1
        partB.Anchored = true
        partB.CanCollide = false
        partB.Parent = Workspace

        local attachmentA = Instance.new("Attachment", partA)
        local attachmentB = Instance.new("Attachment", partB)

        local beam = Instance.new("Beam")
        beam.Attachment0 = attachmentA
        beam.Attachment1 = attachmentB
        beam.Color = ColorSequence.new(_G.TracerColor)
        beam.Width0 = 0.12
        beam.Width1 = 0.12
        beam.Texture = "rbxassetid://6079958617" 
        beam.TextureMode = Enum.TextureMode.Wrap
        beam.TextureSpeed = 5
        beam.LightEmission = 1
        beam.LightInfluence = 0
        beam.Parent = partA

        table.insert(tracerPool, {PartA = partA, PartB = partB})

        task.delay(0.08, function()
            pcall(function()
                partA:Destroy()
                partB:Destroy()
            end)
            for i, v in ipairs(tracerPool) do
                if v.PartA == partA then
                    table.remove(tracerPool, i)
                    break
                end
            end
        end)
    end)
end

-- Главный цикл отрисовки и логики
RunService.RenderStepped:Connect(function()
    -- Aim Assist в голову с проверкой FOV круга (зеленый если внутри, красный если пусто)
    if _G.AimAssistEnabled then
        local targetHead = GetHeadTarget()
        if targetHead then
            FOVStroke.Color = Color3.fromRGB(0, 255, 150)
            FOVCircle.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
            local targetCFrame = CFrame.new(Camera.CFrame.Position, targetHead.Position)
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, _G.AimSmoothness)
        else
            FOVStroke.Color = Color3.fromRGB(255, 0, 0)
            FOVCircle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        end
    end

    -- Fullbright
    if _G.FullBrightEnabled then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    end

    -- Удаление отдачи и разброса на карте Delta (внутри структуры оружия / ModuleScript / Attributes)
    if _G.NoSpreadEnabled and LocalPlayer.Character then
        pcall(function()
            for _, tool in ipairs(LocalPlayer.Character:GetChildren()) do
                if tool:IsA("Tool") then
                    tool:SetAttribute("Spread", 0)
                    tool:SetAttribute("Recoil", 0)
                    tool:SetAttribute("RecoilForce", 0)
                    tool:SetAttribute("SpreadIncrement", 0)
                    tool:SetAttribute("Inaccuracy", 0)
                    tool:SetAttribute("Kickback", 0)
                    tool:SetAttribute("Sway", 0)
                    
                    -- Попытка залезть в ModuleScript конфигурации оружия если таковой присутствует внутри Tool
                    for _, descendant in ipairs(tool:GetDescendants()) do
                        if descendant:IsA("ModuleScript") then
                            pcall(function()
                                local config = require(descendant)
                                if type(config) == "table" then
                                    if config.Recoil then config.Recoil = 0 end
                                    if config.RecoilForce then config.RecoilForce = 0 end
                                    if config.Spread then config.Spread = 0 end
                                    if config.SpreadIncrement then config.SpreadIncrement = 0 end
                                    if config.Inaccuracy then config.Inaccuracy = 0 end
                                    if config.Sway then config.Sway = 0 end
                                end
                            end)
                        end
                    end
                end
            end
        end)
    end
end)

-- Скинченджер
local lastSkinApplied = {}
RunService.RenderStepped:Connect(function()
    if not _G.SkinChangerEnabled or not LocalPlayer.Character then
        lastSkinApplied = {}
        return
    end
    pcall(function()
        for _, item in ipairs(LocalPlayer.Character:GetChildren()) do
            if item:IsA("Tool") then
                if not lastSkinApplied[item] then
                    for _, part in ipairs(item:GetDescendants()) do
                        if part:IsA("BasePart") or part:IsA("MeshPart") then
                            part.Color = _G.SelectedSkinColor
                            part.Material = Enum.Material.Neon
                            if part:IsA("MeshPart") then
                                part.TextureID = ""
                            end
                        end
                    end
                    lastSkinApplied[item] = true
                end
            end
        end
    end)
end)

-- Отрисовка ESP (TikTok стиль: зеленый если виден, красный если за препятствием)
local lastEspUpdate = 0
local ESP_THROTTLE = 0.03
RunService.RenderStepped:Connect(function()
    if not espEnabled then return end
    if tick() - lastEspUpdate < ESP_THROTTLE then return end
    lastEspUpdate = tick()

    local baseThemeColor = Color3.fromRGB(0, 255, 150)
    if _G.ESPTheme == "Blue" then
        baseThemeColor = Color3.fromRGB(0, 180, 255)
    elseif _G.ESPTheme == "Yellow" then
        baseThemeColor = Color3.fromRGB(255, 220, 0)
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end

        local data = DrawingSupported and createPlayerDrawingObjects(player.Name) or nil
        if not isEnemy(player) then
            removeEsp(player.Name)
            continue
        end

        local char = getCharacter(player)
        if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Head") and data and data.Box then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local root = char.HumanoidRootPart
                local head = char.Head
                local rPos, onScreen = Camera:WorldToViewportPoint(root.Position)
                
                if onScreen then
                    local topPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                    local bottomPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 2.5, 0))
                    local height = math.abs(topPos.Y - bottomPos.Y)
                    local width = height * 0.55
                    
                    -- Проверка: за преградой или нет (Красный если за стеной, Цвет темы если виден)
                    local isVisible = IsVisibleFast(head)
                    local dynamicColor = isVisible and baseThemeColor or Color3.fromRGB(255, 40, 40)
                    
                    data.Box.Size = Vector2.new(width, height)
                    data.Box.Position = Vector2.new(rPos.X - width / 2, topPos.Y)
                    data.Box.Color = dynamicColor
                    data.Box.Visible = true
                    
                    local healthRatio = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
                    data.HpBackground.Size = Vector2.new(3, height)
                    data.HpBackground.Position = Vector2.new(rPos.X - width / 2 - 6, topPos.Y)
                    data.HpBackground.Visible = true
                    
                    local fillHeight = height * healthRatio
                    data.HpFill.Size = Vector2.new(3, fillHeight)
                    data.HpFill.Position = Vector2.new(rPos.X - width / 2 - 6, topPos.Y + (height - fillHeight))
                    data.HpFill.Color = Color3.fromRGB(255 * (1 - healthRatio), 255 * healthRatio, 0)
                    data.HpFill.Visible = true
                    
                    local distance = math.floor((root.Position - Camera.CFrame.Position).Magnitude)
                    data.Text.Text = player.Name .. "\n[" .. distance .. "m]"
                    data.Text.Position = Vector2.new(rPos.X, topPos.Y - 32)
                    data.Text.Color = dynamicColor
                    data.Text.Visible = true

                    local activeWeapon = "Hands"
                    local tool = char:FindFirstChildOfClass("Tool")
                    if tool then
                        activeWeapon = tool.Name
                    end
                    data.WeaponText.Text = activeWeapon
                    data.WeaponText.Position = Vector2.new(rPos.X, topPos.Y + height + 4)
                    data.WeaponText.Color = dynamicColor
                    data.WeaponText.Visible = true
                else
                    removeEsp(player.Name)
                end
            else
                removeEsp(player.Name)
            end
        else
            removeEsp(player.Name)
        end
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if cacheDrawingObjects[player.Name] then
        pcall(function()
            cacheDrawingObjects[player.Name].Box:Remove()
            cacheDrawingObjects[player.Name].HpBackground:Remove()
            cacheDrawingObjects[player.Name].HpFill:Remove()
            cacheDrawingObjects[player.Name].Text:Remove()
            cacheDrawingObjects[player.Name].WeaponText:Remove()
        end)
        cacheDrawingObjects[player.Name] = nil
    end
end)
