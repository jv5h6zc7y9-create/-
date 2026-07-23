--[[
    Block Strike Ultimate Engine - Fixed & Optimized Version
    Исправлены проблемы с поиском персонажей, поддержкой Drawing, логикой команд и прицеливанием.
]]--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Проверка поддержки Drawing API
local DrawingSupported = (Drawing ~= nil and type(Drawing.new) == "function")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BlockStrikePremiumEngine"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local FOVCircle = Instance.new("Frame")
FOVCircle.Name = "FOVCircle"
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
FOVCircle.BackgroundTransparency = 0.9
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
MainMenu.Size = UDim2.new(0, 360, 0, 640)
MainMenu.Position = UDim2.new(0.5, -180, 0.5, -320)
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
TitleLabel.Text = "⚡ BLOCK STRIKE ULTIMATE ⚡"
TitleLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
TitleLabel.TextSize = 18
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
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 720)
ContentFrame.ScrollBarThickness = 4
ContentFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 150)
ContentFrame.Parent = MainMenu

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 12)
UIListLayout.Parent = ContentFrame

local ModeButton = Instance.new("TextButton")
ModeButton.Name = "ModeButton"
ModeButton.Size = UDim2.new(1, 0, 0, 45)
ModeButton.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
ModeButton.Text = "Режим: Выкл"
ModeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ModeButton.TextSize = 16
ModeButton.Font = Enum.Font.SourceSansBold
local ModeCorner = Instance.new("UICorner")
ModeCorner.CornerRadius = UDim.new(0.2, 0)
ModeCorner.Parent = ModeButton
local ModeStroke = Instance.new("UIStroke")
ModeStroke.Thickness = 1
ModeStroke.Color = Color3.fromRGB(40, 40, 45)
ModeStroke.Parent = ModeButton
ModeButton.Parent = ContentFrame

local TargetButton = Instance.new("TextButton")
TargetButton.Name = "TargetButton"
TargetButton.Size = UDim2.new(1, 0, 0, 45)
TargetButton.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
TargetButton.Text = "Цель: Head"
TargetButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TargetButton.TextSize = 16
TargetButton.Font = Enum.Font.SourceSansBold
local TargetCorner = Instance.new("UICorner")
TargetCorner.CornerRadius = UDim.new(0.2, 0)
TargetCorner.Parent = TargetButton
local TargetStroke = Instance.new("UIStroke")
TargetStroke.Thickness = 1
TargetStroke.Color = Color3.fromRGB(40, 40, 45)
TargetStroke.Parent = TargetButton
TargetButton.Parent = ContentFrame

local SliderContainer = Instance.new("Frame")
SliderContainer.Name = "SliderContainer"
SliderContainer.Size = UDim2.new(1, 0, 0, 55)
SliderContainer.BackgroundTransparency = 1
SliderContainer.Parent = ContentFrame

local SliderLabel = Instance.new("TextLabel")
SliderLabel.Name = "SliderLabel"
SliderLabel.Size = UDim2.new(1, 0, 0, 20)
SliderLabel.BackgroundTransparency = 1
SliderLabel.Text = "Радиус FOV: 100 px"
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
SliderBtn.Position = UDim2.new(0.318, 0, 0.5, 0)
SliderBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
SliderBtn.Text = ""
SliderBtn.Parent = SliderBar

local SliderBtnCorner = Instance.new("UICorner")
SliderBtnCorner.CornerRadius = UDim.new(1, 0)
SliderBtnCorner.Parent = SliderBtn

local ESPToggle = Instance.new("TextButton")
ESPToggle.Name = "ESPToggle"
ESPToggle.Size = UDim2.new(1, 0, 0, 45)
ESPToggle.BackgroundColor3 = Color3.fromRGB(0, 100, 60)
ESPToggle.Text = "ESP: ВКЛ"
ESPToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
ESPToggle.TextSize = 16
ESPToggle.Font = Enum.Font.SourceSansBold
local ESPCorner = Instance.new("UICorner")
ESPCorner.CornerRadius = UDim.new(0.2, 0)
ESPCorner.Parent = ESPToggle
local ESPStroke = Instance.new("UIStroke")
ESPStroke.Thickness = 1
ESPStroke.Color = Color3.fromRGB(40, 40, 45)
ESPStroke.Parent = ESPToggle
ESPToggle.Parent = ContentFrame

local BHopToggle = Instance.new("TextButton")
BHopToggle.Name = "BHopToggle"
BHopToggle.Size = UDim2.new(1, 0, 0, 45)
BHopToggle.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
BHopToggle.Text = "BUNNYHOP: ВЫКЛ"
BHopToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
BHopToggle.TextSize = 16
BHopToggle.Font = Enum.Font.SourceSansBold
local BHopCorner = Instance.new("UICorner")
BHopCorner.CornerRadius = UDim.new(0.2, 0)
BHopCorner.Parent = BHopToggle
local BHopStroke = Instance.new("UIStroke")
BHopStroke.Thickness = 1
BHopStroke.Color = Color3.fromRGB(40, 40, 45)
BHopStroke.Parent = BHopToggle
BHopToggle.Parent = ContentFrame

local ThirdPersonToggle = Instance.new("TextButton")
ThirdPersonToggle.Name = "ThirdPersonToggle"
ThirdPersonToggle.Size = UDim2.new(1, 0, 0, 45)
ThirdPersonToggle.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
ThirdPersonToggle.Text = "3 ЛИЦО: ВЫКЛ"
ThirdPersonToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
ThirdPersonToggle.TextSize = 16
ThirdPersonToggle.Font = Enum.Font.SourceSansBold
local ThirdPersonCorner = Instance.new("UICorner")
ThirdPersonCorner.CornerRadius = UDim.new(0.2, 0)
ThirdPersonCorner.Parent = ThirdPersonToggle
local ThirdPersonStroke = Instance.new("UIStroke")
ThirdPersonStroke.Thickness = 1
ThirdPersonStroke.Color = Color3.fromRGB(40, 40, 45)
ThirdPersonStroke.Parent = ThirdPersonToggle
ThirdPersonToggle.Parent = ContentFrame

local SkyButton = Instance.new("TextButton")
SkyButton.Name = "SkyButton"
SkyButton.Size = UDim2.new(1, 0, 0, 45)
SkyButton.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
SkyButton.Text = "Небо: Обычное"
SkyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SkyButton.TextSize = 16
SkyButton.Font = Enum.Font.SourceSansBold
local SkyCorner = Instance.new("UICorner")
SkyCorner.CornerRadius = UDim.new(0.2, 0)
SkyCorner.Parent = SkyButton
local SkyStroke = Instance.new("UIStroke")
SkyStroke.Thickness = 1
SkyStroke.Color = Color3.fromRGB(40, 40, 45)
SkyStroke.Parent = SkyButton
SkyButton.Parent = ContentFrame

local SpeedContainer = Instance.new("Frame")
SpeedContainer.Name = "SpeedContainer"
SpeedContainer.Size = UDim2.new(1, 0, 0, 55)
SpeedContainer.BackgroundTransparency = 1
SpeedContainer.Parent = ContentFrame

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Name = "SpeedLabel"
SpeedLabel.Size = UDim2.new(1, 0, 0, 20)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "Множитель Скорости: x1"
SpeedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
SpeedLabel.TextSize = 14
SpeedLabel.Font = Enum.Font.SourceSansBold
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
SpeedLabel.Parent = SpeedContainer

local SpeedBar = Instance.new("Frame")
SpeedBar.Name = "SpeedBar"
SpeedBar.Size = UDim2.new(1, 0, 0, 8)
SpeedBar.Position = UDim2.new(0, 0, 0, 30)
SpeedBar.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
SpeedBar.BorderSizePixel = 0
SpeedBar.Parent = SpeedContainer

local SpeedBarCorner = Instance.new("UICorner")
SpeedBarCorner.CornerRadius = UDim.new(1, 0)
SpeedBarCorner.Parent = SpeedBar

local SpeedBtn = Instance.new("TextButton")
SpeedBtn.Name = "SpeedBtn"
SpeedBtn.Size = UDim2.new(0, 20, 0, 20)
SpeedBtn.AnchorPoint = Vector2.new(0.5, 0.5)
SpeedBtn.Position = UDim2.new(0, 0, 0.5, 0)
SpeedBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
SpeedBtn.Text = ""
SpeedBtn.Parent = SpeedBar

local SpeedBtnCorner = Instance.new("UICorner")
SpeedBtnCorner.CornerRadius = UDim.new(1, 0)
SpeedBtnCorner.Parent = SpeedBtn

local ColorButton = Instance.new("TextButton")
ColorButton.Name = "ColorButton"
ColorButton.Size = UDim2.new(1, 0, 0, 45)
ColorButton.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
ColorButton.Text = "Гамма: Стандарт"
ColorButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ColorButton.TextSize = 16
ColorButton.Font = Enum.Font.SourceSansBold
local ColorCorner = Instance.new("UICorner")
ColorCorner.CornerRadius = UDim.new(0.2, 0)
ColorCorner.Parent = ColorButton
local ColorStroke = Instance.new("UIStroke")
ColorStroke.Thickness = 1
ColorStroke.Color = Color3.fromRGB(40, 40, 45)
ColorStroke.Parent = ColorButton
ColorButton.Parent = ContentFrame

local fovRadius = 100
local aimMode = "Выкл"
local aimTarget = "Head"
local espEnabled = true
local bHopEnabled = false
local thirdPersonEnabled = false
local currentSkyMode = "Обычное"
local currentGammaMode = "Стандарт"
local speedMultiplier = 1
local draggingSlider = false
local draggingSpeedSlider = false

local colorVisible = Color3.fromRGB(0, 255, 150)
local colorHidden = Color3.fromRGB(255, 40, 40)

local screenCenter = Vector2.new(0, 0)
local cacheDrawingObjects = {}

local ColorCorrection = Lighting:FindFirstChildOfClass("ColorCorrectionEffect")
if not ColorCorrection then
    ColorCorrection = Instance.new("ColorCorrectionEffect")
    ColorCorrection.Parent = Lighting
end

local function updateCenter()
    local viewportSize = Camera.ViewportSize
    local guiInset = GuiService:GetGuiInset()
    local calculatedX = viewportSize.X / 2
    local calculatedY = (viewportSize.Y + guiInset.Y) / 2
    screenCenter = Vector2.new(calculatedX, calculatedY)
    FOVCircle.Position = UDim2.new(0, calculatedX, 0, calculatedY)
end

Camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateCenter)
updateCenter()

MenuButton.MouseButton1Click:Connect(function()
    MainMenu.Visible = not MainMenu.Visible
end)

CloseButton.MouseButton1Click:Connect(function()
    MainMenu.Visible = false
end)

local function updateFOV(radius)
    fovRadius = radius
    FOVCircle.Size = UDim2.new(0, radius * 2, 0, radius * 2)
    SliderLabel.Text = "Радиус FOV: " .. tostring(math.round(radius)) .. " px"
end

updateFOV(fovRadius)

SliderBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingSlider = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingSlider = false
        draggingSpeedSlider = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingSlider and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local rX = input.Position.X - SliderBar.AbsolutePosition.X
        local percentage = math.clamp(rX / SliderBar.AbsoluteSize.X, 0, 1)
        SliderBtn.Position = UDim2.new(percentage, 0, 0.5, 0)
        updateFOV(30 + (percentage * 220))
    elseif draggingSpeedSlider and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local rX = input.Position.X - SpeedBar.AbsolutePosition.X
        local percentage = math.clamp(rX / SpeedBar.AbsoluteSize.X, 0, 1)
        SpeedBtn.Position = UDim2.new(percentage, 0, 0.5, 0)
        speedMultiplier = 1 + (percentage * 4)
        SpeedLabel.Text = "Множитель Скорости: x" .. string.format("%.1f", speedMultiplier)
    end
end)

SpeedBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingSpeedSlider = true
    end
end)

ModeButton.MouseButton1Click:Connect(function()
    if aimMode == "Выкл" then
        aimMode = "Обычный Аим"
        ModeButton.BackgroundColor3 = Color3.fromRGB(0, 100, 60)
    elseif aimMode == "Обычный Аим" then
        aimMode = "Сайлент Аим"
        ModeButton.BackgroundColor3 = Color3.fromRGB(0, 60, 140)
    else
        aimMode = "Выкл"
        ModeButton.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    end
    ModeButton.Text = "Режим: " .. aimMode
end)

TargetButton.MouseButton1Click:Connect(function()
    if aimTarget == "Head" then
        aimTarget = "HumanoidRootPart"
    else
        aimTarget = "Head"
    end
    TargetButton.Text = "Цель: " .. aimTarget
end)

local function cleanAllVisuals()
    for _, data in pairs(cacheDrawingObjects) do
        if data.Box then data.Box.Visible = false end
        if data.HpBackground then data.HpBackground.Visible = false end
        if data.HpFill then data.HpFill.Visible = false end
        if data.Text then data.Text.Visible = false end
    end
end

ESPToggle.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    if espEnabled then
        ESPToggle.BackgroundColor3 = Color3.fromRGB(0, 100, 60)
        ESPToggle.Text = "ESP: ВКЛ"
    else
        ESPToggle.BackgroundColor3 = Color3.fromRGB(160, 30, 30)
        ESPToggle.Text = "ESP: ВЫКЛ"
        cleanAllVisuals()
    end
end)

BHopToggle.MouseButton1Click:Connect(function()
    bHopEnabled = not bHopEnabled
    BHopToggle.BackgroundColor3 = bHopEnabled and Color3.fromRGB(0, 100, 60) or Color3.fromRGB(25, 25, 30)
    BHopToggle.Text = bHopEnabled and "BUNNYHOP: ВКЛ" or "BUNNYHOP: ВЫКЛ"
end)

ThirdPersonToggle.MouseButton1Click:Connect(function()
    thirdPersonEnabled = not thirdPersonEnabled
    ThirdPersonToggle.BackgroundColor3 = thirdPersonEnabled and Color3.fromRGB(0, 100, 60) or Color3.fromRGB(25, 25, 30)
    ThirdPersonToggle.Text = thirdPersonEnabled and "3 ЛИЦО: ВКЛ" or "3 ЛИЦО: ВЫКЛ"
end)

SkyButton.MouseButton1Click:Connect(function()
    if currentSkyMode == "Обычное" then
        currentSkyMode = "Полночь"
        Lighting.TimeOfDay = "00:00:00"
        Lighting.Brightness = 0
        Lighting.OutdoorAmbient = Color3.fromRGB(20, 20, 40)
    elseif currentSkyMode == "Полночь" then
        currentSkyMode = "Закат"
        Lighting.TimeOfDay = "18:00:00"
        Lighting.Brightness = 2
        Lighting.OutdoorAmbient = Color3.fromRGB(120, 60, 40)
    else
        currentSkyMode = "Обычное"
        Lighting.TimeOfDay = "14:00:00"
        Lighting.Brightness = 3
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    end
    SkyButton.Text = "Небо: " .. currentSkyMode
end)

ColorButton.MouseButton1Click:Connect(function()
    if currentGammaMode == "Стандарт" then
        currentGammaMode = "Яркая"
        ColorCorrection.Saturation = 0.5
        ColorCorrection.Contrast = 0.2
        ColorCorrection.Brightness = 0.05
    elseif currentGammaMode == "Яркая" then
        currentGammaMode = "Кинематограф"
        ColorCorrection.Saturation = -0.2
        ColorCorrection.Contrast = 0.4
        ColorCorrection.Brightness = -0.05
    else
        currentGammaMode = "Стандарт"
        ColorCorrection.Saturation = 0
        ColorCorrection.Contrast = 0
        ColorCorrection.Brightness = 0
    end
    ColorButton.Text = "Гамма: " .. currentGammaMode
end)

-- Улучшенный универсальный поиск персонажей игры
local function getCharacter(player)
    if player == LocalPlayer then return player.Character end
    
    -- Проверка стандартных мест хранения
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        return char
    end
    
    -- Поиск в игровых контейнерах Workspace (для кастомных мобильных портов)
    for _, containerName in ipairs({"Players", "Entities", "Characters", "Clients", "ClientsModels"}) do
        local container = Workspace:FindFirstChild(containerName)
        if container then
            local found = container:FindFirstChild(player.Name) or container:FindFirstChild(tostring(player.UserId))
            if found then return found end
        end
    end
    
    return nil
end

local function isEnemy(targetPlayer)
    if targetPlayer == LocalPlayer then return false end
    
    -- Универсальная проверка через стандартные Teams
    if targetPlayer.Team and LocalPlayer.Team then
        return targetPlayer.Team ~= LocalPlayer.Team
    end
    
    -- Проверка атрибутов команд
    local localTeamAttr = LocalPlayer:GetAttribute("Team") or LocalPlayer:GetAttribute("TeamId")
    local targetTeamAttr = targetPlayer:GetAttribute("Team") or targetPlayer:GetAttribute("TeamId")
    if localTeamAttr and targetTeamAttr then
        return localTeamAttr ~= targetTeamAttr
    end
    
    -- Проверка TeamColor
    if targetPlayer.TeamColor ~= LocalPlayer.TeamColor and targetPlayer.TeamColor ~= BrickColor.new("White") then
        return true
    end
    
    return true -- По умолчанию считаем врагом в FFA режимах
end

local function isValidTarget(character)
    if not character then return false end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return false end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    local head = character:FindFirstChild("Head")
    if not rootPart or not head then return false end
    return true
end

local function isVisible(targetPart)
    local character = LocalPlayer.Character
    if not character then return false end
    local originPart = character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
    if not originPart then return false end
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {character, targetPart.Parent}
    raycastParams.IgnoreWater = true
    
    local result = workspace:Raycast(originPart.Position, targetPart.Position - originPart.Position, raycastParams)
    return result == nil
end

local function getClosestEnemy()
    local closestPlayer = nil
    local shortestDistance = fovRadius
    local targetPartName = (aimMode == "Сайлент Аим") and "Head" or aimTarget
    
    for _, player in ipairs(Players:GetPlayers()) do
        if isEnemy(player) then
            local char = getCharacter(player)
            if isValidTarget(char) then
                local targetPart = char:FindFirstChild(targetPartName)
                if targetPart then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                    if onScreen then
                        local distance = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                        if distance <= shortestDistance then
                            shortestDistance = distance
                            closestPlayer = player
                        end
                    end
                end
            end
        end
    end
    return closestPlayer
end

local function createPlayerDrawingObjects(playerName)
    if not DrawingSupported then return nil end
    if not cacheDrawingObjects[playerName] then
        local data = {}
        pcall(function()
            data.Box = Drawing.new("Square")
            data.Box.Thickness = 2
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
            data.Text.Size = 14
            data.Text.Center = true
            data.Text.Outline = true
            data.Text.Visible = false
        end)
        cacheDrawingObjects[playerName] = data
    end
    return cacheDrawingObjects[playerName]
end

RunService.RenderStepped:Connect(function()
    -- Обновление настроек персонажа локального игрока
    local myChar = LocalPlayer.Character
    if myChar then
        local humanoid = myChar:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = 16 * speedMultiplier
        end
    end

    -- Управление камерой 3-го лица
    LocalPlayer.CameraMaxZoomDistance = thirdPersonEnabled and 12 or 0.5
    LocalPlayer.CameraMinZoomDistance = thirdPersonEnabled and 12 or 0.5

    -- Обработка Аимбота (включая эмуляцию Сайлент Аима через коррекцию камеры на лету)
    if aimMode ~= "Выкл" then
        local targetPlayer = getClosestEnemy()
        if targetPlayer then
            FOVStroke.Color = Color3.fromRGB(0, 255, 150)
            FOVCircle.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
            
            local char = getCharacter(targetPlayer)
            if char then
                local targetPartName = (aimMode == "Сайлент Аим") and "Head" or aimTarget
                local targetPart = char:FindFirstChild(targetPartName)
                if targetPart then
                    local lerpSpeed = (aimMode == "Сайлент Аим") and 1.0 or 0.2
                    Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, targetPart.Position), lerpSpeed)
                end
            end
        else
            FOVStroke.Color = Color3.fromRGB(255, 0, 0)
            FOVCircle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        end
    end

    -- Bunnyhop логика
    if bHopEnabled and myChar then
        local humanoid = myChar:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.Health > 0 then
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) or UserInputService:GetMouseLocation() then
                if humanoid.FloorMaterial ~= Enum.Material.Air then
                    humanoid.Jump = true
                end
            end
        end
    end

    -- Отрисовка ESP (ВХ)
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local data = DrawingSupported and createPlayerDrawingObjects(player.Name) or nil
            local char = getCharacter(player)
            
            if espEnabled and isEnemy(player) and isValidTarget(char) and data and data.Box then
                local root = char.HumanoidRootPart
                local rPos, onScreen = Camera:WorldToViewportPoint(root.Position)
                
                if onScreen then
                    local topPos = Camera:WorldToViewportPoint(root.Position + Vector3.new(0, 3, 0))
                    local bottomPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
                    local height = math.abs(topPos.Y - bottomPos.Y)
                    local width = height * 0.55
                    local isVis = isVisible(root)
                    local boxColor = isVis and colorVisible or colorHidden
                    
                    data.Box.Size = Vector2.new(width, height)
                    data.Box.Position = Vector2.new(rPos.X - width / 2, topPos.Y)
                    data.Box.Color = boxColor
                    data.Box.Visible = true
                    
                    local humanoid = char:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        local healthRatio = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
                        data.HpBackground.Size = Vector2.new(4, height)
                        data.HpBackground.Position = Vector2.new(rPos.X - width / 2 - 10, topPos.Y)
                        data.HpBackground.Visible = true
                        
                        local fillHeight = height * healthRatio
                        data.HpFill.Size = Vector2.new(4, fillHeight)
                        data.HpFill.Position = Vector2.new(rPos.X - width / 2 - 10, topPos.Y + (height - fillHeight))
                        data.HpFill.Color = Color3.fromRGB(255 * (1 - healthRatio), 255 * healthRatio, 0)
                        data.HpFill.Visible = true
                    end
                    
                    local distance = math.floor((root.Position - Camera.CFrame.Position).Magnitude)
                    data.Text.Text = player.Name .. " [" .. distance .. "м]"
                    data.Text.Position = Vector2.new(rPos.X, topPos.Y - 18)
                    data.Text.Color = boxColor
                    data.Text.Visible = true
                else
                    data.Box.Visible = false
                    data.HpBackground.Visible = false
                    data.HpFill.Visible = false
                    data.Text.Visible = false
                end
            elseif data and data.Box then
                data.Box.Visible = false
                data.HpBackground.Visible = false
                data.HpFill.Visible = false
                data.Text.Visible = false
            end
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
        end)
        cacheDrawingObjects[player.Name] = nil
    end
end)
