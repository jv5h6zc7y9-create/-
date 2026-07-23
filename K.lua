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
MenuButton.Size = UDim2.new(0, 55, 0, 55)
MenuButton.AnchorPoint = Vector2.new(0.5, 0.5)
MenuButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MenuButton.Text = "⚙️"
MenuButton.TextSize = 26
MenuButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MenuButton.Parent = ScreenGui

local MenuButtonCorner = Instance.new("UICorner")
MenuButtonCorner.CornerRadius = UDim.new(0.3, 0)
MenuButtonCorner.Parent = MenuButton

local MenuButtonStroke = Instance.new("UIStroke")
MenuButtonStroke.Thickness = 2
MenuButtonStroke.Color = Color3.fromRGB(100, 100, 100)
MenuButtonStroke.Parent = MenuButton

local MainMenu = Instance.new("Frame")
MainMenu.Name = "MainMenu"
MainMenu.Size = UDim2.new(0, 340, 0, 680)
MainMenu.Position = UDim2.new(0.5, -170, 0.5, -340)
MainMenu.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainMenu.Visible = false
MainMenu.Parent = ScreenGui

local MainMenuCorner = Instance.new("UICorner")
MainMenuCorner.CornerRadius = UDim.new(0.04, 0)
MainMenuCorner.Parent = MainMenu

local MainMenuStroke = Instance.new("UIStroke")
MainMenuStroke.Thickness = 2
MainMenuStroke.Color = Color3.fromRGB(60, 60, 60)
MainMenuStroke.Parent = MainMenu

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(1, 0, 0, 45)
TitleLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TitleLabel.Text = "iPad Pro 11 Ultimate Menu"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 18
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.Parent = MainMenu

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0.15, 0)
TitleCorner.Parent = TitleLabel

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 32, 0, 32)
CloseButton.Position = UDim2.new(1, -38, 0, 6)
CloseButton.BackgroundColor3 = Color3.fromRGB(160, 0, 0)
CloseButton.Text = "❌"
CloseButton.TextSize = 14
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Parent = MainMenu

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0.3, 0)
CloseCorner.Parent = CloseButton

local ModeButton = Instance.new("TextButton")
ModeButton.Name = "ModeButton"
ModeButton.Size = UDim2.new(0, 300, 0, 45)
ModeButton.Position = UDim2.new(0.5, -150, 0, 65)
ModeButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ModeButton.Text = "Режим: Выкл"
ModeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ModeButton.TextSize = 16
ModeButton.Font = Enum.Font.SourceSansBold
ModeButton.Parent = MainMenu

local ModeCorner = Instance.new("UICorner")
ModeCorner.CornerRadius = UDim.new(0.2, 0)
ModeCorner.Parent = ModeButton

local ModeStroke = Instance.new("UIStroke")
ModeStroke.Thickness = 1
ModeStroke.Color = Color3.fromRGB(80, 80, 80)
ModeStroke.Parent = ModeButton

local TargetButton = Instance.new("TextButton")
TargetButton.Name = "TargetButton"
TargetButton.Size = UDim2.new(0, 300, 0, 45)
TargetButton.Position = UDim2.new(0.5, -150, 0, 125)
TargetButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
TargetButton.Text = "Цель: Head"
TargetButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TargetButton.TextSize = 16
TargetButton.Font = Enum.Font.SourceSansBold
TargetButton.Parent = MainMenu

local TargetCorner = Instance.new("UICorner")
TargetCorner.CornerRadius = UDim.new(0.2, 0)
TargetCorner.Parent = TargetButton

local TargetStroke = Instance.new("UIStroke")
TargetStroke.Thickness = 1
TargetStroke.Color = Color3.fromRGB(80, 80, 80)
TargetStroke.Parent = TargetButton

local SliderLabel = Instance.new("TextLabel")
SliderLabel.Name = "SliderLabel"
SliderLabel.Size = UDim2.new(0, 300, 0, 25)
SliderLabel.Position = UDim2.new(0.5, -150, 0, 190)
SliderLabel.BackgroundTransparency = 1
SliderLabel.Text = "Радиус FOV: 100 px"
SliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SliderLabel.TextSize = 16
SliderLabel.Font = Enum.Font.SourceSansBold
SliderLabel.Parent = MainMenu

local SliderBar = Instance.new("Frame")
SliderBar.Name = "SliderBar"
SliderBar.Size = UDim2.new(0, 300, 0, 12)
SliderBar.Position = UDim2.new(0.5, -150, 0, 225)
SliderBar.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
SliderBar.BorderSizePixel = 0
SliderBar.Parent = MainMenu

local SliderBarCorner = Instance.new("UICorner")
SliderBarCorner.CornerRadius = UDim.new(1, 0)
SliderBarCorner.Parent = SliderBar

local SliderBtn = Instance.new("TextButton")
SliderBtn.Name = "SliderBtn"
SliderBtn.Size = UDim2.new(0, 22, 0, 22)
SliderBtn.AnchorPoint = Vector2.new(0.5, 0.5)
SliderBtn.Position = UDim2.new(0.318, 0, 0.5, 0)
SliderBtn.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
SliderBtn.Text = ""
SliderBtn.Parent = SliderBar

local SliderBtnCorner = Instance.new("UICorner")
SliderBtnCorner.CornerRadius = UDim.new(1, 0)
SliderBtnCorner.Parent = SliderBtn

local SliderBtnStroke = Instance.new("UIStroke")
SliderBtnStroke.Thickness = 1
SliderBtnStroke.Color = Color3.fromRGB(0, 0, 0)
SliderBtnStroke.Parent = SliderBtn

local ESPToggle = Instance.new("TextButton")
ESPToggle.Name = "ESPToggle"
ESPToggle.Size = UDim2.new(0, 300, 0, 45)
ESPToggle.Position = UDim2.new(0.5, -150, 0, 265)
ESPToggle.BackgroundColor3 = Color3.fromRGB(0, 130, 0)
ESPToggle.Text = "ESP: ВКЛ"
ESPToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
ESPToggle.TextSize = 16
ESPToggle.Font = Enum.Font.SourceSansBold
ESPToggle.Parent = MainMenu

local ESPToggleCorner = Instance.new("UICorner")
ESPToggleCorner.CornerRadius = UDim.new(0.2, 0)
ESPToggleCorner.Parent = ESPToggle

local ESPToggleStroke = Instance.new("UIStroke")
ESPToggleStroke.Thickness = 1
ESPToggleStroke.Color = Color3.fromRGB(80, 80, 80)
ESPToggleStroke.Parent = ESPToggle

local BHopToggle = Instance.new("TextButton")
BHopToggle.Name = "BHopToggle"
BHopToggle.Size = UDim2.new(0, 300, 0, 45)
BHopToggle.Position = UDim2.new(0.5, -150, 0, 325)
BHopToggle.BackgroundColor3 = Color3.fromRGB(160, 0, 0)
BHopToggle.Text = "BUNNYHOP: ВЫКЛ"
BHopToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
BHopToggle.TextSize = 16
BHopToggle.Font = Enum.Font.SourceSansBold
BHopToggle.Parent = MainMenu

local BHopToggleCorner = Instance.new("UICorner")
BHopToggleCorner.CornerRadius = UDim.new(0.2, 0)
BHopToggleCorner.Parent = BHopToggle

local BHopToggleStroke = Instance.new("UIStroke")
BHopToggleStroke.Thickness = 1
BHopToggleStroke.Color = Color3.fromRGB(80, 80, 80)
BHopToggleStroke.Parent = BHopToggle

local ThirdPersonToggle = Instance.new("TextButton")
ThirdPersonToggle.Name = "ThirdPersonToggle"
ThirdPersonToggle.Size = UDim2.new(0, 300, 0, 45)
ThirdPersonToggle.Position = UDim2.new(0.5, -150, 0, 385)
ThirdPersonToggle.BackgroundColor3 = Color3.fromRGB(160, 0, 0)
ThirdPersonToggle.Text = "3 ЛИЦО: ВЫКЛ"
ThirdPersonToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
ThirdPersonToggle.TextSize = 16
ThirdPersonToggle.Font = Enum.Font.SourceSansBold
ThirdPersonToggle.Parent = MainMenu

local ThirdPersonCorner = Instance.new("UICorner")
ThirdPersonCorner.CornerRadius = UDim.new(0.2, 0)
ThirdPersonCorner.Parent = ThirdPersonToggle

local ThirdPersonStroke = Instance.new("UIStroke")
ThirdPersonStroke.Thickness = 1
ThirdPersonStroke.Color = Color3.fromRGB(80, 80, 80)
ThirdPersonStroke.Parent = ThirdPersonToggle

local SkyButton = Instance.new("TextButton")
SkyButton.Name = "SkyButton"
SkyButton.Size = UDim2.new(0, 300, 0, 45)
SkyButton.Position = UDim2.new(0.5, -150, 0, 445)
SkyButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SkyButton.Text = "Небо: Обычное"
SkyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SkyButton.TextSize = 16
SkyButton.Font = Enum.Font.SourceSansBold
SkyButton.Parent = MainMenu

local SkyCorner = Instance.new("UICorner")
SkyCorner.CornerRadius = UDim.new(0.2, 0)
SkyCorner.Parent = SkyButton

local SkyStroke = Instance.new("UIStroke")
SkyStroke.Thickness = 1
SkyStroke.Color = Color3.fromRGB(80, 80, 80)
SkyStroke.Parent = SkyButton

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Name = "SpeedLabel"
SpeedLabel.Size = UDim2.new(0, 300, 0, 25)
SpeedLabel.Position = UDim2.new(0.5, -150, 0, 505)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "Множитель Скорости: x1"
SpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedLabel.TextSize = 16
SpeedLabel.Font = Enum.Font.SourceSansBold
SpeedLabel.Parent = MainMenu

local SpeedBar = Instance.new("Frame")
SpeedBar.Name = "SpeedBar"
SpeedBar.Size = UDim2.new(0, 300, 0, 12)
SpeedBar.Position = UDim2.new(0.5, -150, 0, 540)
SpeedBar.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
SpeedBar.BorderSizePixel = 0
SpeedBar.Parent = MainMenu

local SpeedBarCorner = Instance.new("UICorner")
SpeedBarCorner.CornerRadius = UDim.new(1, 0)
SpeedBarCorner.Parent = SpeedBar

local SpeedBtn = Instance.new("TextButton")
SpeedBtn.Name = "SpeedBtn"
SpeedBtn.Size = UDim2.new(0, 22, 0, 22)
SpeedBtn.AnchorPoint = Vector2.new(0.5, 0.5)
SpeedBtn.Position = UDim2.new(0, 0, 0.5, 0)
SpeedBtn.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
SpeedBtn.Text = ""
SpeedBtn.Parent = SpeedBar

local SpeedBtnCorner = Instance.new("UICorner")
SpeedBtnCorner.CornerRadius = UDim.new(1, 0)
SpeedBtnCorner.Parent = SpeedBtn

local SpeedBtnStroke = Instance.new("UIStroke")
SpeedBtnStroke.Thickness = 1
SpeedBtnStroke.Color = Color3.fromRGB(0, 0, 0)
SpeedBtnStroke.Parent = SpeedBtn

local ColorButton = Instance.new("TextButton")
ColorButton.Name = "ColorButton"
ColorButton.Size = UDim2.new(0, 300, 0, 45)
ColorButton.Position = UDim2.new(0.5, -150, 0, 580)
ColorButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ColorButton.Text = "Гамма: Стандарт"
ColorButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ColorButton.TextSize = 16
ColorButton.Font = Enum.Font.SourceSansBold
ColorButton.Parent = MainMenu

local ColorCorner = Instance.new("UICorner")
ColorCorner.CornerRadius = UDim.new(0.2, 0)
ColorCorner.Parent = ColorButton

local ColorStroke = Instance.new("UIStroke")
ColorStroke.Thickness = 1
ColorStroke.Color = Color3.fromRGB(80, 80, 80)
ColorStroke.Parent = ColorButton

local DrawingContainer = Instance.new("Folder")
DrawingContainer.Name = "DrawingContainer"
DrawingContainer.Parent = ScreenGui

local fovRadius = 100
local aimMode = "Выкл"
local aimTarget = "Head"
local espEnabled = true
local bHopEnabled = false
local thirdPersonEnabled = false
local currentSkyMode = "Обычное"
local currentGammaMode = "Стандарт"
local speedMultiplier = 1

local colorVisible = Color3.fromRGB(0, 255, 0)
local colorHidden = Color3.fromRGB(255, 0, 0)

local screenCenter = Vector2.new(0, 0)
local menuButtonPosition = nil

local ColorCorrection = Lighting:FindFirstChildOfClass("ColorCorrectionEffect")
if not ColorCorrection then
    ColorCorrection = Instance.new("ColorCorrectionEffect")
    ColorCorrection.Parent = Lighting
end

local function updateCenter()
    local viewportSize = Camera.ViewportSize
    local guiInset = GuiService:GetGuiInset()
    screenCenter = Vector2.new(viewportSize.X / 2, (viewportSize.Y + guiInset.Y) / 2)
    FOVCircle.Position = UDim2.new(0, screenCenter.X, 0, screenCenter.Y)
    if not menuButtonPosition then
        MenuButton.Position = UDim2.new(0, screenCenter.X, 0, screenCenter.Y)
    end
end

Camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateCenter)
updateCenter()

task.spawn(function()
    while task.wait(0.5) do
        updateCenter()
    end
end)

local draggingButton = false
local dragInputButton = nil
local dragStartButton = nil
local startPosButton = nil

MenuButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingButton = true
        dragStartButton = input.Position
        startPosButton = MenuButton.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                draggingButton = false
            end
        end)
    end
end)

MenuButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInputButton = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInputButton and draggingButton then
        local delta = input.Position - dragStartButton
        local newPos = UDim2.new(startPosButton.X.Scale, startPosButton.X.Offset + delta.X, startPosButton.Y.Scale, startPosButton.Y.Offset + delta.Y)
        MenuButton.Position = newPos
        menuButtonPosition = newPos
    end
end)

MenuButton.MouseButton1Click:Connect(function()
    if not draggingButton then
        MainMenu.Visible = not MainMenu.Visible
    end
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

local draggingSlider = false

local function moveSlider(input)
    local rX = input.Position.X - SliderBar.AbsolutePosition.X
    local percentage = math.clamp(rX / SliderBar.AbsoluteSize.X, 0, 1)
    SliderBtn.Position = UDim2.new(percentage, 0, 0.5, 0)
    local newRadius = 30 + (percentage * 220)
    updateFOV(newRadius)
end

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
    if draggingSlider and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        moveSlider(input)
    end
end)

local draggingSpeedSlider = false

local function moveSpeedSlider(input)
    local rX = input.Position.X - SpeedBar.AbsolutePosition.X
    local percentage = math.clamp(rX / SpeedBar.AbsoluteSize.X, 0, 1)
    SpeedBtn.Position = UDim2.new(percentage, 0, 0.5, 0)
    speedMultiplier = 1 + (percentage * 4)
    SpeedLabel.Text = "Множитель Скорости: x" .. string.format("%.1f", speedMultiplier)
end

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
    if draggingSpeedSlider and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        moveSpeedSlider(input)
    end
end)

ModeButton.MouseButton1Click:Connect(function()
    if aimMode == "Выкл" then
        aimMode = "Обычный Аим"
        ModeButton.BackgroundColor3 = Color3.fromRGB(0, 130, 0)
    elseif aimMode == "Обычный Аим" then
        aimMode = "Сайлент Аим"
        ModeButton.BackgroundColor3 = Color3.fromRGB(0, 0, 140)
    else
        aimMode = "Выкл"
        ModeButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
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
    DrawingContainer:ClearAllChildren()
    for _, player in ipairs(Players:GetPlayers()) do
        local plFolder = Workspace:FindFirstChild("Players") or Workspace:FindFirstChild("Entities") or Workspace
        local char = plFolder:FindFirstChild(player.Name)
        if char then
            local head = char:FindFirstChild("Head")
            if head then
                local billboardGui = head:FindFirstChild("AdvancedEspBillboard")
                if billboardGui then billboardGui:Destroy() end
            end
            local highlight = char:FindFirstChild("EspPlayerHighlight")
            if highlight then highlight:Destroy() end
        end
    end
end

ESPToggle.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    if espEnabled then
        ESPToggle.BackgroundColor3 = Color3.fromRGB(0, 130, 0)
        ESPToggle.Text = "ESP: ВКЛ"
    else
        ESPToggle.BackgroundColor3 = Color3.fromRGB(160, 0, 0)
        ESPToggle.Text = "ESP: ВЫКЛ"
        cleanAllVisuals()
    end
end)

BHopToggle.MouseButton1Click:Connect(function()
    bHopEnabled = not bHopEnabled
    if bHopEnabled then
        BHopToggle.BackgroundColor3 = Color3.fromRGB(0, 130, 0)
        BHopToggle.Text = "BUNNYHOP: ВКЛ"
    else
        BHopToggle.BackgroundColor3 = Color3.fromRGB(160, 0, 0)
        BHopToggle.Text = "BUNNYHOP: ВЫКЛ"
    end
end)

ThirdPersonToggle.MouseButton1Click:Connect(function()
    thirdPersonEnabled = not thirdPersonEnabled
    if thirdPersonEnabled then
        ThirdPersonToggle.BackgroundColor3 = Color3.fromRGB(0, 130, 0)
        ThirdPersonToggle.Text = "3 ЛИЦО: ВКЛ"
    else
        ThirdPersonToggle.BackgroundColor3 = Color3.fromRGB(160, 0, 0)
        ThirdPersonToggle.Text = "3 ЛИЦО: ВЫКЛ"
        LocalPlayer.CameraMaxZoomDistance = 0.5
        LocalPlayer.CameraMinZoomDistance = 0.5
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

local function getCharactersFolder()
    return Workspace:FindFirstChild("Players") or Workspace:FindFirstChild("Entities") or Workspace
end

local function isEnemy(targetPlayer)
    if targetPlayer == LocalPlayer then return false end
    if targetPlayer.Team and LocalPlayer.Team and targetPlayer.Team ~= LocalPlayer.Team then
        return true
    end
    local localTeamAttr = LocalPlayer:GetAttribute("Team")
    local targetTeamAttr = targetPlayer:GetAttribute("Team")
    if localTeamAttr and targetTeamAttr and localTeamAttr ~= targetTeamAttr then
        return true
    end
    if targetPlayer.TeamColor ~= LocalPlayer.TeamColor and targetPlayer.TeamColor ~= string.format("White") then
        return true
    end
    return false
end

local function isValidTarget(character)
    if not character then return false end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 or humanoid:GetState() == Enum.HumanoidStateType.Dead then
        return false
    end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then
        return false
    end
    local head = character:FindFirstChild("Head")
    if head and head.Transparency == 1 then
        return false
    end
    return true
end

local function isVisible(targetPart)
    local character = LocalPlayer.Character
    if not character then return false end
    local originPart = character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
    if not originPart then return false end
    local origin = originPart.Position
    local direction = targetPart.Position - origin
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {character, targetPart.Parent, getCharactersFolder()}
    params.IgnoreWater = true
    local result = workspace:Raycast(origin, direction, params)
    return result == nil
end

local function getClosestVisibleEnemy()
    local closestPlayer = nil
    local shortestDistance = math.huge
    local currentTargetPartName = aimTarget
    if aimMode == "Сайлент Аим" then
        currentTargetPartName = "Head"
    end
    local folder = getCharactersFolder()
    for _, player in ipairs(Players:GetPlayers()) do
        if isEnemy(player) then
            local char = folder:FindFirstChild(player.Name)
            if char and isValidTarget(char) then
                local targetPart = char:FindFirstChild(currentTargetPartName)
                if targetPart then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                    if onScreen then
                        local mousePos = Vector2.new(screenPos.X, screenPos.Y)
                        local distance = (mousePos - screenCenter).Magnitude
                        if distance <= fovRadius and distance < shortestDistance then
                            if isVisible(targetPart) then
                                shortestDistance = distance
                                closestPlayer = player
                            end
                        end
                    end
                end
            end
        end
    end
    return closestPlayer
end

local function createScreenLine(name)
    local line = DrawingContainer:FindFirstChild(name)
    if not line then
        line = Instance.new("Frame")
        line.Name = name
        line.BorderSizePixel = 0
        line.AnchorPoint = Vector2.new(0.5, 0)
        line.Parent = DrawingContainer
    end
    return line
end

local function updatePlayerEsp(player, character, enemyVisible)
    local head = character:FindFirstChild("Head")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")
    if not head or not humanoid or not root then return end
    
    local billboardGui = head:FindFirstChild("AdvancedEspBillboard")
    if not billboardGui then
        billboardGui = Instance.new("BillboardGui")
        billboardGui.Name = "AdvancedEspBillboard"
        billboardGui.Size = UDim2.new(0, 130, 0, 150)
        billboardGui.AlwaysOnTop = true
        billboardGui.ExtentsOffset = Vector3.new(0, -1.5, 0)
        
        local boxFrame = Instance.new("Frame")
        boxFrame.Name = "BoxFrame"
        boxFrame.Size = UDim2.new(1, 0, 1, 0)
        boxFrame.BackgroundTransparency = 1
        boxFrame.Parent = billboardGui
        
        local stroke = Instance.new("UIStroke")
        stroke.Name = "BoxStroke"
        stroke.Thickness = 2
        stroke.Color = Color3.fromRGB(255, 0, 0)
        stroke.Parent = boxFrame
        
        local hpBackground = Instance.new("Frame")
        hpBackground.Name = "HpBackground"
        hpBackground.Size = UDim2.new(0, 6, 1, 0)
        hpBackground.Position = UDim2.new(1, 6, 0, 0)
        hpBackground.BackgroundColor3 = Color3.fromRGB(60, 10, 10)
        hpBackground.BorderSizePixel = 0
        hpBackground.Parent = boxFrame
        
        local hpBar = Instance.new("Frame")
        hpBar.Name = "HpBar"
        hpBar.Size = UDim2.new(1, 0, 1, 0)
        hpBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        hpBar.BorderSizePixel = 0
        hpBar.Parent = hpBackground
        
        local infoLabel = Instance.new("TextLabel")
        infoLabel.Name = "InfoLabel"
        infoLabel.Size = UDim2.new(1, 0, 0, 20)
        infoLabel.Position = UDim2.new(0, 0, 0, -25)
        infoLabel.BackgroundTransparency = 1
        infoLabel.Font = Enum.Font.SourceSansBold
        infoLabel.TextSize = 14
        infoLabel.Parent = billboardGui
        
        billboardGui.Parent = head
    end
    
    local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local distanceMeters = 0
    if myHrp and root then
        distanceMeters = (root.Position - myHrp.Position).Magnitude
    end
    
    billboardGui.InfoLabel.Text = string.format("%s [%dм]", player.Name, math.floor(distanceMeters))
    billboardGui.InfoLabel.TextColor3 = enemyVisible and colorVisible or colorHidden
    
    local boxFrame = billboardGui:FindFirstChild("BoxFrame")
    if boxFrame then
        local stroke = boxFrame:FindFirstChild("BoxStroke")
        if stroke then
            stroke.Color = enemyVisible and colorVisible or colorHidden
        end
        
        local healthRatio = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
        local hpBg = boxFrame:FindFirstChild("HpBackground")
        local hpBar = hpBg and hpBg:FindFirstChild("HpBar")
        if hpBg and hpBar then
            hpBar.Size = UDim2.new(1, 0, healthRatio, 0)
            hpBar.Position = UDim2.new(0, 0, 1 - healthRatio, 0)
            hpBar.BackgroundColor3 = Color3.fromRGB(255 * (1 - healthRatio), 255 * healthRatio, 0)
        end
    end
    
    local rPos, onScreen = Camera:WorldToViewportPoint(root.Position)
    local line = createScreenLine(player.Name .. "_Tracer")
    
    if onScreen then
        local startX = Camera.ViewportSize.X / 2
        local startY = Camera.ViewportSize.Y
        local endX = rPos.X
        local endY = rPos.Y
        local distanceX = endX - startX
        local distanceY = endY - startY
        local lineLength = math.sqrt(distanceX * distanceX + distanceY * distanceY)
        local angle = math.atan2(distanceY, distanceX)
        
        line.Visible = true
        line.Size = UDim2.new(0, 2, 0, lineLength)
        line.Position = UDim2.new(0, startX, 0, startY)
        line.Rotation = math.deg(angle) - 90
        line.BackgroundColor3 = enemyVisible and colorVisible or colorHidden
    else
        line.Visible = false
    end
    
    local highlight = character:FindFirstChild("EspPlayerHighlight")
    if not highlight then
        highlight = Instance.new("Highlight")
        highlight.Name = "EspPlayerHighlight"
        highlight.FillTransparency = 0.85
        highlight.OutlineTransparency = 0
        highlight.Parent = character
    end
    highlight.OutlineColor = enemyVisible and colorVisible or colorHidden
    highlight.FillColor = enemyVisible and colorVisible or colorHidden
end

local function removePlayerEsp(player)
    local folder = getCharactersFolder()
    local char = folder:FindFirstChild(player.Name)
    if char then
        local head = char:FindFirstChild("Head")
        if head then
            local billboardGui = head:FindFirstChild("AdvancedEspBillboard")
            if billboardGui then billboardGui:Destroy() end
        end
        local highlight = char:FindFirstChild("EspPlayerHighlight")
        if highlight then highlight:Destroy() end
    end
    local line = DrawingContainer:FindFirstChild(player.Name .. "_Tracer")
    if line then line:Destroy() end
end

RunService.RenderStepped:Connect(function()
    local targetPlayer = getClosestVisibleEnemy()
    local folder = getCharactersFolder()
    
    if thirdPersonEnabled then
        LocalPlayer.CameraMaxZoomDistance = 12
        LocalPlayer.CameraMinZoomDistance = 12
    end
    
    local myChar = LocalPlayer.Character
    if myChar then
        local myHumanoid = myChar:FindFirstChildOfClass("Humanoid")
        if myHumanoid then
            myHumanoid.WalkSpeed = 16 * speedMultiplier
        end
    end
    
    if aimMode ~= "Выкл" and targetPlayer then
        FOVStroke.Color = Color3.fromRGB(0, 255, 0)
        FOVCircle.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        
        local currentTargetPartName = aimTarget
        if aimMode == "Сайлент Аим" then
            currentTargetPartName = "Head"
        end
        
        local char = folder:FindFirstChild(targetPlayer.Name)
        if char and isValidTarget(char) then
            local targetPart = char:FindFirstChild(currentTargetPartName)
            if targetPart then
                if aimMode == "Обычный Аим" then
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
                elseif aimMode == "Сайлент Аим" then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                    if onScreen and (UserInputService:IsMouseButtonPressed(Enum.MouseButton1) or #UserInputService:GetMouseLocation() > 0) then
                        Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, targetPart.Position), 1)
                    end
                end
            end
        end
    else
        FOVStroke.Color = Color3.fromRGB(255, 0, 0)
        FOVCircle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    end
    
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
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = folder:FindFirstChild(player.Name)
            if char then
                if espEnabled and isEnemy(player) then
                    if isValidTarget(char) then
                        local root = char:FindFirstChild("HumanoidRootPart")
                        if root then
                            local enemyVisible = isVisible(root)
                            updatePlayerEsp(player, char, enemyVisible)
                        else
                            removePlayerEsp(player)
                        end
                    else
                        removePlayerEsp(player)
                    end
                else
                    removePlayerEsp(player)
                end
            else
                removePlayerEsp(player)
            end
        end
    end
end)

Players.PlayerRemoving:Connect(function(player)
    removePlayerEsp(player)
end)
