--!strict
--[[
    Финальный монолитный скрипт для Roblox (Delta Executor / Мобильные устройства):
    1. Мобильный Silent Aim (Camera/Touch Redirect на голову) — решает проблему отсутствия мыши.
    2. Ползунки для настройки радиуса FOV и вертикального смещения (Y) прямо в меню.
    3. Многоуровневая фильтрация союзников (TikTok ESP + Team Check).
    4. Полноценный Скинченджер и No-Recoil / No-Spread без сокращений.
]]--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local DrawingSupported = (Drawing ~= nil and type(Drawing.new) == "function")

-- Глобальные настройки
_G.SilentAimEnabled = false
_G.NoSpreadEnabled = false
_G.SkinChangerEnabled = false
_G.FullBrightEnabled = false
_G.AimFOV = 140
_G.FOVYOffset = 0 -- Смещение круга по вертикали
_G.SelectedSkinColor = Color3.fromRGB(255, 100, 0)
_G.ESPTheme = "Green"

-- Создание графического интерфейса
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BlockStrikeMobileUltimate"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Индикатор FOV (Круг на экране)
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

-- Кнопка открытия меню
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

-- Главное меню
local MainMenu = Instance.new("Frame")
MainMenu.Name = "MainMenu"
MainMenu.Size = UDim2.new(0, 380, 0, 740)
MainMenu.Position = UDim2.new(0.5, -190, 0.5, -370)
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
TitleLabel.Size = UDim2.new(1, 0, 0, 50)
TitleLabel.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
TitleLabel.Text = "⚡ MOBILE SILENT AIM + SLIDERS ⚡"
TitleLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
TitleLabel.TextSize = 12
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.Parent = MainMenu

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0.2, 0)
TitleCorner.Parent = TitleLabel

local CloseButton = Instance.new("TextButton")
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
ContentFrame.Size = UDim2.new(1, -20, 1, -70)
ContentFrame.Position = UDim2.new(0, 10, 0, 60)
ContentFrame.BackgroundTransparency = 1
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 950)
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

-- Кнопки функционала
local SilentAimButton = createButton("SilentAimButton", "Mobile Silent Aim (В голову): ВЫКЛ")
local NoSpreadButton = createButton("NoSpreadButton", "Удаление Отдачи/Разброса: ВЫКЛ")
local SkinButton = createButton("SkinButton", "Скинченджер (Оружие + Нож): ВЫКЛ")
local ESPToggle = createButton("ESPToggle", "TikTok ESP (Без союзников): ВКЛ", Color3.fromRGB(0, 100, 60))
local ThemeButton = createButton("ThemeButton", "Цвет ВХ: Зеленый")
local FullBrightButton = createButton("FullBrightButton", "Ночное Виденье: ВЫКЛ")

-- =========================================================
-- ПОЛЗУНОК 1: РАДИУС FOV (Больше / Меньше)
-- =========================================================
local SliderContainer = Instance.new("Frame")
SliderContainer.Size = UDim2.new(1, 0, 0, 55)
SliderContainer.BackgroundTransparency = 1
SliderContainer.Parent = ContentFrame

local SliderLabel = Instance.new("TextLabel")
SliderLabel.Size = UDim2.new(1, 0, 0, 20)
SliderLabel.BackgroundTransparency = 1
SliderLabel.Text = "Радиус FOV: 140 px"
SliderLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
SliderLabel.TextSize = 14
SliderLabel.Font = Enum.Font.SourceSansBold
SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
SliderLabel.Parent = SliderContainer

local SliderBar = Instance.new("Frame")
SliderBar.Size = UDim2.new(1, 0, 0, 8)
SliderBar.Position = UDim2.new(0, 0, 0, 30)
SliderBar.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
SliderBar.BorderSizePixel = 0
SliderBar.Parent = SliderContainer

local SliderBarCorner = Instance.new("UICorner")
SliderBarCorner.CornerRadius = UDim.new(1, 0)
SliderBarCorner.Parent = SliderBar

local SliderBtn = Instance.new("TextButton")
SliderBtn.Size = UDim2.new(0, 20, 0, 20)
SliderBtn.AnchorPoint = Vector2.new(0.5, 0.5)
SliderBtn.Position = UDim2.new(0.45, 0, 0.5, 0)
SliderBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
SliderBtn.Text = ""
SliderBtn.Parent = SliderBar

local SliderBtnCorner = Instance.new("UICorner")
SliderBtnCorner.CornerRadius = UDim.new(1, 0)
SliderBtnCorner.Parent = SliderBtn

-- =========================================================
-- ПОЛЗУНОК 2: ВЫСОТА КРУГА FOV (Выше / Ниже по Y)
-- =========================================================
local YSliderContainer = Instance.new("Frame")
YSliderContainer.Size = UDim2.new(1, 0, 0, 55)
YSliderContainer.BackgroundTransparency = 1
YSliderContainer.Parent = ContentFrame

local YSliderLabel = Instance.new("TextLabel")
YSliderLabel.Size = UDim2.new(1, 0, 0, 20)
YSliderLabel.BackgroundTransparency = 1
YSliderLabel.Text = "Высота круга (Y): 0 px"
YSliderLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
YSliderLabel.TextSize = 14
YSliderLabel.Font = Enum.Font.SourceSansBold
YSliderLabel.TextXAlignment = Enum.TextXAlignment.Left
YSliderLabel.Parent = YSliderContainer

local YSliderBar = Instance.new("Frame")
YSliderBar.Size = UDim2.new(1, 0, 0, 8)
YSliderBar.Position = UDim2.new(0, 0, 0, 30)
YSliderBar.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
YSliderBar.BorderSizePixel = 0
YSliderBar.Parent = YSliderContainer

local YSliderBarCorner = Instance.new("UICorner")
YSliderBarCorner.CornerRadius = UDim.new(1, 0)
YSliderBarCorner.Parent = YSliderBar

local YSliderBtn = Instance.new("TextButton")
YSliderBtn.Size = UDim2.new(0, 20, 0, 20)
YSliderBtn.AnchorPoint = Vector2.new(0.5, 0.5)
YSliderBtn.Position = UDim2.new(0.5, 0, 0.5, 0)
YSliderBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
YSliderBtn.Text = ""
YSliderBtn.Parent = YSliderBar

local YSliderBtnCorner = Instance.new("UICorner")
YSliderBtnCorner.CornerRadius = UDim.new(1, 0)
YSliderBtnCorner.Parent = YSliderBtn

MenuButton.MouseButton1Click:Connect(function() MainMenu.Visible = not MainMenu.Visible end)
CloseButton.MouseButton1Click:Connect(function() MainMenu.Visible = false end)

local screenCenter = Vector2.new(0, 0)
local function updateCenter()
    local viewportSize = Camera.ViewportSize
    local guiInset = GuiService:GetGuiInset()
    screenCenter = Vector2.new(viewportSize.X / 2, ((viewportSize.Y + guiInset.Y) / 2) + _G.FOVYOffset)
    FOVCircle.Position = UDim2.new(0, screenCenter.X, 0, screenCenter.Y)
end
Camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateCenter)
updateCenter()

local function updateFOV(radius)
    _G.AimFOV = radius
    FOVCircle.Size = UDim2.new(0, radius * 2, 0, radius * 2)
    SliderLabel.Text = "Радиус FOV: " .. tostring(math.round(radius)) .. " px"
end
updateFOV(_G.AimFOV)

-- Логика ползунков для сенсорных экранов (iPad / Delta)
local draggingSlider = false
local draggingYSlider = false

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
        _G.FOVYOffset = (percentage - 0.5) * 400
        YSliderLabel.Text = "Высота круга (Y): " .. tostring(math.round(_G.FOVYOffset)) .. " px"
        updateCenter()
    end
end)

-- =========================================================
-- МНОГОУРОВНЕВАЯ ФУНКЦИЯ ПРОВЕРКИ СОЮЗНИКОВ (TEAM CHECK)
-- =========================================================
local function isEnemy(targetPlayer)
    if not targetPlayer or targetPlayer == LocalPlayer then return false end
    
    if targetPlayer.Team and LocalPlayer.Team then
        if targetPlayer.Team ~= LocalPlayer.Team then return true else return false end
    end
    
    local localTeamAttr = LocalPlayer:GetAttribute("Team")
    local targetTeamAttr = targetPlayer:GetAttribute("Team")
    if localTeamAttr ~= nil and targetTeamAttr ~= nil then
        if localTeamAttr ~= targetTeamAttr then return true else return false end
    end
    
    local localSideAttr = LocalPlayer:GetAttribute("Side")
    local targetSideAttr = targetPlayer:GetAttribute("Side")
    if localSideAttr ~= nil and targetSideAttr ~= nil then
        if localSideAttr ~= targetSideAttr then return true else return false end
    end
    
    local teamValueObj = targetPlayer:FindFirstChild("Team")
    local myTeamValueObj = LocalPlayer:FindFirstChild("Team")
    if teamValueObj and myTeamValueObj and teamValueObj:IsA("ValueBase") and myTeamValueObj:IsA("ValueBase") then
        if teamValueObj.Value ~= myTeamValueObj.Value then return true else return false end
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
        return true
    end
    return false
end

-- =========================================================
-- ПОИСК БЛИЖАЙШЕЙ ГОЛОВЫ ВРАГА (HEADSHOT TARGET)
-- =========================================================
local function GetBestHeadTarget()
    local bestHead = nil
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
                            bestHead = headPart
                        end
                    end
                end
            end
        end
    end
    return bestHead
end

-- =========================================================
-- НАДЕЖНЫЙ МОБИЛЬНЫЙ SILENT AIM (TOUCH/CAMERA REDIRECT)
-- =========================================================
RunService.RenderStepped:Connect(function()
    if _G.SilentAimEnabled then
        local targetHead = GetBestHeadTarget()
        if targetHead then
            FOVStroke.Color = Color3.fromRGB(0, 255, 150)
            FOVCircle.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
            
            -- Проверяем нажатие на экран (палец или клик мыши)
            if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or UserInputService.TouchEnabled then
                local predictedPos = targetHead.Position + (targetHead.AssemblyLinearVelocity * 0.165)
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, predictedPos)
            end
        else
            FOVStroke.Color = Color3.fromRGB(255, 0, 0)
            FOVCircle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        end
    end

    if _G.FullBrightEnabled then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    end

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
                end
            end
        end)
    end
end)

-- Кнопки интерфейса логика
SilentAimButton.MouseButton1Click:Connect(function()
    _G.SilentAimEnabled = not _G.SilentAimEnabled
    SilentAimButton.BackgroundColor3 = _G.SilentAimEnabled and Color3.fromRGB(0, 100, 60) or Color3.fromRGB(25, 25, 30)
    SilentAimButton.Text = _G.SilentAimEnabled and "Mobile Silent Aim (В голову): ВКЛ" or "Mobile Silent Aim (В голову): ВЫКЛ"
end)

NoSpreadButton.MouseButton1Click:Connect(function()
    _G.NoSpreadEnabled = not _G.NoSpreadEnabled
    NoSpreadButton.BackgroundColor3 = _G.NoSpreadEnabled and Color3.fromRGB(0, 100, 60) or Color3.fromRGB(25, 25, 30)
    NoSpreadButton.Text = _G.NoSpreadEnabled and "Удаление Отдачи/Разброса: ВКЛ" or "Удаление Отдачи/Разброса: ВЫКЛ"
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
        ThemeButton.Text = "Цвет ВХ: Зеленый"
    end
end)

local espEnabled = true
ESPToggle.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    ESPToggle.BackgroundColor3 = espEnabled and Color3.fromRGB(0, 100, 60) or Color3.fromRGB(160, 30, 30)
    ESPToggle.Text = espEnabled and "TikTok ESP (Без союзников): ВКЛ" or "TikTok ESP (Без союзников): ВЫКЛ"
end)

local cacheDrawingObjects = {}
local function removeNativeEsp(playerName)
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
                            if part:IsA("MeshPart") then part.TextureID = "" end
                        end
                    end
                    lastSkinApplied[item] = true
                end
            end
        end
    end)
end)

-- ESP с фильтрацией союзников
local lastEspUpdate = 0
RunService.RenderStepped:Connect(function()
    if not espEnabled then return end
    if tick() - lastEspUpdate < 0.03 then return end
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
        local enemyCheck = isEnemy(player)
        
        if enemyCheck == true then
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

                        local tool = char:FindFirstChildOfClass("Tool")
                        data.WeaponText.Text = tool and tool.Name or "Hands"
                        data.WeaponText.Position = Vector2.new(rPos.X, topPos.Y + height + 4)
                        data.WeaponText.Color = dynamicColor
                        data.WeaponText.Visible = true
                    else
                        removeNativeEsp(player.Name)
                    end
                else
                    removeNativeEsp(player.Name)
                end
            else
                removeNativeEsp(player.Name)
            end
        else
            removeNativeEsp(player.Name)
        end
    end
end)
