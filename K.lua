local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

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

local colorVisible = Color3.fromRGB(0, 255, 150)
local colorHidden = Color3.fromRGB(255, 40, 40)

local screenCenter = Vector2.new(0, 0)
local espGuisContainer = {}
local draggingSlider = false
local draggingSpeedSlider = false

local function updateCenter()
    local viewportSize = Camera.ViewportSize
    local guiInset = GuiService:GetGuiInset()
    local calculatedX = viewportSize.X / 2
    local calculatedY = (viewportSize.Y + guiInset.Y) / 2
    screenCenter = Vector2.new(calculatedX, calculatedY)
    FOVCircle.Position = UDim2.new(0, calculatedX, 0, calculatedY)
end

Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    local viewportSize = Camera.ViewportSize
    local guiInset = GuiService:GetGuiInset()
    local calculatedX = viewportSize.X / 2
    local calculatedY = (viewportSize.Y + guiInset.Y) / 2
    screenCenter = Vector2.new(calculatedX, calculatedY)
    FOVCircle.Position = UDim2.new(0, calculatedX, 0, calculatedY)
end)

updateCenter()

task.spawn(function()
    while task.wait(0.5) do
        local viewportSize = Camera.ViewportSize
        local guiInset = GuiService:GetGuiInset()
        local calculatedX = viewportSize.X / 2
        local calculatedY = (viewportSize.Y + guiInset.Y) / 2
        screenCenter = Vector2.new(calculatedX, calculatedY)
        FOVCircle.Position = UDim2.new(0, calculatedX, 0, calculatedY)
    end
end)

MenuButton.MouseButton1Click:Connect(function()
    if MainMenu.Visible == true then
        MainMenu.Visible = false
    else
        MainMenu.Visible = true
    end
end)

CloseButton.MouseButton1Click:Connect(function()
    MainMenu.Visible = false
end)

SliderBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingSlider = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingSlider = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingSlider == true and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local rX = input.Position.X - SliderBar.AbsolutePosition.X
        local percentage = math.clamp(rX / SliderBar.AbsoluteSize.X, 0, 1)
        SliderBtn.Position = UDim2.new(percentage, 0, 0.5, 0)
        local newRadius = 30 + (percentage * 220)
        fovRadius = newRadius
        FOVCircle.Size = UDim2.new(0, newRadius * 2, 0, newRadius * 2)
        local roundedRadius = math.round(newRadius)
        SliderLabel.Text = "Радиус FOV: " .. tostring(roundedRadius) .. " px"
    end
end)

SpeedBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingSpeedSlider = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingSpeedSlider = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingSpeedSlider == true and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local rX = input.Position.X - SpeedBar.AbsolutePosition.X
        local percentage = math.clamp(rX / SpeedBar.AbsoluteSize.X, 0, 1)
        SpeedBtn.Position = UDim2.new(percentage, 0, 0.5, 0)
        local calculatedMultiplier = 1 + (percentage * 4)
        speedMultiplier = calculatedMultiplier
        SpeedLabel.Text = "Множитель Скорости: x" .. string.format("%.1f", calculatedMultiplier)
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

local function setDrawingVisibility(playerName, state)
    if espGuisContainer[playerName] then
        local data = espGuisContainer[playerName]
        data.Billboard.Enabled = state
    end
end

local function cleanAllVisuals()
    for name, _ in pairs(espGuisContainer) do
        if espGuisContainer[name] then
            espGuisContainer[name].Billboard.Enabled = false
        end
    end
end

local function hardRemovePlayerDrawing(playerName)
    if espGuisContainer[playerName] then
        local data = espGuisContainer[playerName]
        if data.Billboard then
            data.Billboard:Destroy()
        end
        espGuisContainer[playerName] = nil
    end
end

ESPToggle.MouseButton1Click:Connect(function()
    if espEnabled == true then
        espEnabled = false
        ESPToggle.BackgroundColor3 = Color3.fromRGB(160, 30, 30)
        ESPToggle.Text = "ESP: ВЫКЛ"
        cleanAllVisuals()
    else
        espEnabled = true
        ESPToggle.BackgroundColor3 = Color3.fromRGB(0, 100, 60)
        ESPToggle.Text = "ESP: ВКЛ"
    end
end)

BHopToggle.MouseButton1Click:Connect(function()
    if bHopEnabled == true then
        bHopEnabled = false
        BHopToggle.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
        BHopToggle.Text = "BUNNYHOP: ВЫКЛ"
    else
        bHopEnabled = true
        BHopToggle.BackgroundColor3 = Color3.fromRGB(0, 100, 60)
        BHopToggle.Text = "BUNNYHOP: ВКЛ"
    end
end)

ThirdPersonToggle.MouseButton1Click:Connect(function()
    if thirdPersonEnabled == true then
        thirdPersonEnabled = false
        ThirdPersonToggle.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
        ThirdPersonToggle.Text = "3 ЛИЦО: ВЫКЛ"
        Camera.CameraType = Enum.CameraType.Custom
    else
        thirdPersonEnabled = true
        ThirdPersonToggle.BackgroundColor3 = Color3.fromRGB(0, 100, 60)
        ThirdPersonToggle.Text = "3 ЛИЦО: ВКЛ"
    end
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

local function isEnemy(targetPlayer)
    if targetPlayer == LocalPlayer then
        return false
    end
    if targetPlayer.Team and LocalPlayer.Team then
        if targetPlayer.Team ~= LocalPlayer.Team then
            return true
        else
            return false
        end
    end
    local localTeamAttr = LocalPlayer:GetAttribute("Team")
    local targetTeamAttr = targetPlayer:GetAttribute("Team")
    if localTeamAttr and targetTeamAttr then
        if localTeamAttr ~= targetTeamAttr then
            return true
        else
            return false
        end
    end
    local localSideAttr = LocalPlayer:GetAttribute("Side")
    local targetSideAttr = targetPlayer:GetAttribute("Side")
    if localSideAttr and targetSideAttr then
        if localSideAttr ~= targetSideAttr then
            return true
        else
            return false
        end
    end
    local teamValueObj = targetPlayer:FindFirstChild("Team")
    local localTeamValueObj = LocalPlayer:FindFirstChild("Team")
    if teamValueObj and localTeamValueObj then
        if teamValueObj.Value ~= localTeamValueObj.Value then
            return true
        else
            return false
        end
    end
    if targetPlayer.TeamColor ~= LocalPlayer.TeamColor and targetPlayer.TeamColor ~= Color3.fromRGB(255, 255, 255) then
        return true
    end
    return false
end

local function scanCharacterModel(player)
    local nameToSearch = player.Name
    local workspaceDescendants = Workspace:GetDescendants()
    for i = 1, #workspaceDescendants do
        local object = workspaceDescendants[i]
        if object:IsA("Model") and object.Name == nameToSearch then
            local hum = object:FindFirstChildOfClass("Humanoid")
            local hrp = object:FindFirstChild("HumanoidRootPart")
            if hum and hrp then
                return object
            end
        end
    end
    return nil
end

local function isValidTarget(character)
    if not character then
        return false
    end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        return false
    end
    if humanoid.Health <= 0 then
        return false
    end
    if humanoid:GetState() == Enum.HumanoidStateType.Dead then
        return false
    end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then
        return false
    end
    local head = character:FindFirstChild("Head")
    if head then
        if head.Transparency == 1 then
            return false
        end
    else
        return false
    end
    return true
end

local function isVisible(targetPart, charModel)
    local localChar = LocalPlayer.Character
    if not localChar then
        return false
    end
    local originPart = localChar:FindFirstChild("Head")
    if not originPart then
        originPart = localChar:FindFirstChild("HumanoidRootPart")
    end
    if not originPart then
        return false
    end
    local originPosition = originPart.Position
    local targetPosition = targetPart.Position
    local directionVector = targetPosition - originPosition
    local raycastParameters = RaycastParams.new()
    raycastParameters.FilterType = Enum.RaycastFilterType.Exclude
    local exclusionList = {localChar, charModel, Camera}
    raycastParameters.FilterDescendantsInstances = exclusionList
    raycastParameters.IgnoreWater = true
    local raycastResult = workspace:Raycast(originPosition, directionVector, raycastParameters)
    if raycastResult == nil then
        return true
    else
        return false
    end
end

local function getTouchOrMousePosition()
    local activePositions = UserInputService:GetMouseLocation()
    local positionVector2 = Vector2.new(activePositions.X, activePositions.Y)
    return positionVector2
end

local function getClosestEnemyToTouch(inputCenter)
    local closestPlayer = nil
    local shortestDistance = math.huge
    local currentTargetPartName = aimTarget
    if aimMode == "Сайлент Аим" then
        currentTargetPartName = "Head"
    end
    local playerList = Players:GetPlayers()
    for i = 1, #playerList do
        local player = playerList[i]
        local enemyCheck = isEnemy(player)
        if enemyCheck == true then
            local char = scanCharacterModel(player)
            if char then
                local targetValidation = isValidTarget(char)
                if targetValidation == true then
                    local targetPart = char:FindFirstChild(currentTargetPartName)
                    if targetPart then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                        if onScreen == true then
                            local mousePos = Vector2.new(screenPos.X, screenPos.Y)
                            local distance = (mousePos - inputCenter).Magnitude
                            if distance <= fovRadius and distance < shortestDistance then
                                local wallCheck = isVisible(targetPart, char)
                                if wallCheck == true then
                                    shortestDistance = distance
                                    closestPlayer = player
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return closestPlayer
end

local function createPlayerNativeEsp(player, charModel)
    if not espGuisContainer[player.Name] then
        local data = {}
        local bGui = Instance.new("BillboardGui")
        bGui.Name = "BS_Esp_Billboard"
        bGui.Size = UDim2.new(0, 150, 0, 100)
        bGui.AlwaysOnTop = true
        bGui.ResetOnSpawn = false
        
        local boxFrame = Instance.new("Frame")
        boxFrame.Name = "BoxFrame"
        boxFrame.Size = UDim2.new(0.6, 0, 0.8, 0)
        boxFrame.Position = UDim2.new(0.2, 0, 0.1, 0)
        boxFrame.BackgroundTransparency = 1
        boxFrame.Parent = bGui
        
        local stroke = Instance.new("UIStroke")
        stroke.Name = "BoxStroke"
        stroke.Thickness = 2
        stroke.Color = colorHidden
        stroke.Parent = boxFrame
        
        local hpBg = Instance.new("Frame")
        hpBg.Name = "HpBg"
        hpBg.Size = UDim2.new(0, 4, 1, 0)
        hpBg.Position = UDim2.new(1, 4, 0, 0)
        hpBg.BackgroundColor3 = Color3.fromRGB(60, 10, 10)
        hpBg.BorderSizePixel = 0
        hpBg.Parent = boxFrame
        
        local hpFill = Instance.new("Frame")
        hpFill.Name = "HpFill"
        hpFill.Size = UDim2.new(1, 0, 1, 0)
        hpFill.Position = UDim2.new(0, 0, 0, 0)
        hpFill.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
        hpFill.BorderSizePixel = 0
        hpFill.Parent = hpBg
        
        local textLabel = Instance.new("TextLabel")
        textLabel.Name = "InfoLabel"
        textLabel.Size = UDim2.new(1, 0, 0, 15)
        textLabel.Position = UDim2.new(0, 0, 0, -18)
        textLabel.BackgroundTransparency = 1
        textLabel.Font = Enum.Font.SourceSansBold
        textLabel.TextSize = 13
        textLabel.TextColor3 = colorHidden
        textLabel.TextStrokeTransparency = 0
        textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        textLabel.Parent = boxFrame
        
        local rootPart = charModel:FindFirstChild("HumanoidRootPart")
        if rootPart then
            bGui.Parent = rootPart
        end
        
        data.Billboard = bGui
        data.Box = boxFrame
        data.Stroke = stroke
        data.HpBg = hpBg
        data.HpFill = hpFill
        data.Text = textLabel
        
        espGuisContainer[player.Name] = data
    end
    return espGuisContainer[player.Name]
end

local function removeNativeEsp(playerName)
    if espGuisContainer[playerName] then
        local data = espGuisContainer[playerName]
        if data.Billboard then
            data.Billboard:Destroy()
        end
        espGuisContainer[playerName] = nil
    end
end

local function updateNativeEspLogic(player, charModel, enemyVisible)
    local root = charModel:FindFirstChild("HumanoidRootPart")
    local head = charModel:FindFirstChild("Head")
    local humanoid = charModel:FindFirstChildOfClass("Humanoid")
    if not root or not head or not humanoid then
        return
    end
    
    local data = createPlayerNativeEsp(player, charModel)
    if data.Billboard.Parent ~= root then
        data.Billboard.Parent = root
    end
    
    if espEnabled == true then
        data.Billboard.Enabled = true
        
        local myChar = LocalPlayer.Character
        local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
        local distance = 0
        if myHrp then
            distance = (root.Position - myHrp.Position).Magnitude
        end
        local roundedDist = math.floor(distance)
        data.Text.Text = player.Name .. " [" .. tostring(roundedDist) .. "м]"
        
        local currentBoxColor = colorHidden
        if enemyVisible == true then
            currentBoxColor = colorVisible
        end
        data.Stroke.Color = currentBoxColor
        data.Text.TextColor3 = currentBoxColor
        
        local healthRatio = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
        data.HpFill.Size = UDim2.new(1, 0, healthRatio, 0)
        data.HpFill.Position = UDim2.new(0, 0, 1 - healthRatio, 0)
        data.HpFill.BackgroundColor3 = Color3.fromRGB(255 * (1 - healthRatio), 255 * healthRatio, 0)
    else
        data.Billboard.Enabled = false
    end
end

local initialPlayers = Players:GetPlayers()
for i = 1, #initialPlayers do
    local p = initialPlayers[i]
    local check = isEnemy(p)
    if check == true then
        local char = scanCharacterModel(p)
        if char then
            createPlayerNativeEsp(p, char)
        end
    end
end

Players.PlayerAdded:Connect(function(player)
    task.spawn(function()
        task.wait(0.5)
        local check = isEnemy(player)
        if check == true then
            local char = scanCharacterModel(player)
            if char then
                createPlayerNativeEsp(player.Name, char)
            end
        end
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    hardRemovePlayerDrawing(player.Name)
end)

RunService.RenderStepped:Connect(function()
    local currentTouchPos = getTouchOrMousePosition()
    local targetPlayer = getClosestEnemyToTouch(currentTouchPos)
    local folder = getCharactersFolder()
    local myChar = LocalPlayer.Character
    
    if thirdPersonEnabled == true and myChar then
        local myHrp = myChar:FindFirstChild("HumanoidRootPart")
        if myHrp then
            Camera.CameraType = Enum.CameraType.Scriptable
            local targetCamCFrame = myHrp.CFrame * CFrame.new(0, 3.5, 12)
            Camera.CFrame = CFrame.new(targetCamCFrame.Position, myHrp.Position + Vector3.new(0, 1.5, 0))
        end
    else
        if Camera.CameraType == Enum.CameraType.Scriptable and aimMode == "Выкл" then
            Camera.CameraType = Enum.CameraType.Custom
            LocalPlayer.CameraMaxZoomDistance = 0.5
            LocalPlayer.CameraMinZoomDistance = 0.5
        end
    end
    
    if myChar then
        local myHumanoid = myChar:FindFirstChildOfClass("Humanoid")
        if myHumanoid then
            local targetSpeed = 16 * speedMultiplier
            myHumanoid.WalkSpeed = targetSpeed
        end
    end
    
    if aimMode ~= "Выкл" and targetPlayer then
        FOVStroke.Color = Color3.fromRGB(0, 255, 150)
        FOVCircle.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
        
        local currentTargetPartName = "Head"
        if aimMode == "Обычный Аим" then
            currentTargetPartName = aimTarget
        end
        
        local char = scanCharacterModel(targetPlayer)
        if char then
            local validCheck = isValidTarget(char)
            if validCheck == true then
                local targetPart = char:FindFirstChild(currentTargetPartName)
                if targetPart then
                    if aimMode == "Обычный Аим" then
                        local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
                        Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, 0.15)
                    elseif aimMode == "Сайлент Аим" then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                        if onScreen == true then
                            local isPressed = UserInputService:IsMouseButtonPressed(Enum.MouseButton1)
                            local activeTouches = UserInputService:GetMouseLocation()
                            if isPressed == true or #activeTouches > 0 then
                                local originalCameraCFrame = Camera.CFrame
                                Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
                                task.wait()
                                Camera.CFrame = originalCameraCFrame
                            end
                        end
                    end
                end
            end
        end
    else
        FOVStroke.Color = Color3.fromRGB(255, 0, 0)
        FOVCircle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    end
    
    if bHopEnabled == true and myChar then
        local humanoid = myChar:FindFirstChildOfClass("Humanoid")
        if humanoid then
            if humanoid.Health > 0 then
                local spacePressed = UserInputService:IsKeyDown(Enum.KeyCode.Space)
                local touchActive = UserInputService:GetMouseLocation()
                if spacePressed == true or touchActive then
                    if humanoid.FloorMaterial ~= Enum.Material.Air then
                        humanoid.Jump = true
                    end
                end
            end
        end
    end
    
    local allPlayers = Players:GetPlayers()
    for i = 1, #allPlayers do
        local player = allPlayers[i]
        if player ~= LocalPlayer then
            local char = scanCharacterModel(player)
            if char then
                if espEnabled == true then
                    local enemyCheck = isEnemy(player)
                    if enemyCheck == true then
                        local targetValidation = isValidTarget(char)
                        if targetValidation == true then
                            local root = char:FindFirstChild("HumanoidRootPart")
                            if root then
                                local enemyVisible = isVisible(root, char)
                                updateNativeEspLogic(player, char, enemyVisible)
                            else
                                if espGuisContainer[player.Name] then
                                    espGuisContainer[player.Name].Billboard.Enabled = false
                                end
                            end
                        else
                            if espGuisContainer[player.Name] then
                                espGuisContainer[player.Name].Billboard.Enabled = false
                            end
                        end
                    else
                        if espGuisContainer[player.Name] then
                            espGuisContainer[player.Name].Billboard.Enabled = false
                        end
                    end
                else
                    if espGuisContainer[player.Name] then
                        espGuisContainer[player.Name].Billboard.Enabled = false
                    end
                end
            else
                if espGuisContainer[player.Name] then
                    espGuisContainer[player.Name].Billboard.Enabled = false
                end
            end
        end
    end
end)
