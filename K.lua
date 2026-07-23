local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PremiumMobileMatrixEngine"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local FOVCircle = Instance.new("Frame")
FOVCircle.Name = "FOVCircle"
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
FOVCircle.BackgroundTransparency = 0.95
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
MenuButton.AnchorPoint = Vector2.new(0.5, 0.5)
MenuButton.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MenuButton.Text = "⚙️"
MenuButton.TextSize = 28
MenuButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MenuButton.Parent = ScreenGui

local MenuButtonCorner = Instance.new("UICorner")
MenuButtonCorner.CornerRadius = UDim.new(0.3, 0)
MenuButtonCorner.Parent = MenuButton

local MenuButtonStroke = Instance.new("UIStroke")
MenuButtonStroke.Thickness = 2
MenuButtonStroke.Color = Color3.fromRGB(0, 150, 255)
MenuButtonStroke.Parent = MenuButton

local MainMenu = Instance.new("Frame")
MainMenu.Name = "MainMenu"
MainMenu.Size = UDim2.new(0, 350, 0, 640)
MainMenu.Position = UDim2.new(0.5, -175, 0.5, -320)
MainMenu.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainMenu.Visible = false
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
TitleLabel.Size = UDim2.new(1, 0, 0, 50)
TitleLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
TitleLabel.Text = "iPad Pro 11 Premium Multi-Cheat"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 18
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.Parent = MainMenu

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0.15, 0)
TitleCorner.Parent = TitleLabel

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 34, 0, 34)
CloseButton.Position = UDim2.new(1, -42, 0, 8)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
CloseButton.Text = "❌"
CloseButton.TextSize = 14
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Parent = MainMenu

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0.3, 0)
CloseCorner.Parent = CloseButton

local ModeButton = Instance.new("TextButton")
ModeButton.Name = "ModeButton"
ModeButton.Size = UDim2.new(0, 310, 0, 45)
ModeButton.Position = UDim2.new(0.5, -155, 0, 70)
ModeButton.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
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
ModeStroke.Color = Color3.fromRGB(75, 75, 90)
ModeStroke.Parent = ModeButton

local TargetButton = Instance.new("TextButton")
TargetButton.Name = "TargetButton"
TargetButton.Size = UDim2.new(0, 310, 0, 45)
TargetButton.Position = UDim2.new(0.5, -155, 0, 130)
TargetButton.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
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
TargetStroke.Color = Color3.fromRGB(75, 75, 90)
TargetStroke.Parent = TargetButton

local SliderLabel = Instance.new("TextLabel")
SliderLabel.Name = "SliderLabel"
SliderLabel.Size = UDim2.new(0, 310, 0, 25)
SliderLabel.Position = UDim2.new(0.5, -155, 0, 195)
SliderLabel.BackgroundTransparency = 1
SliderLabel.Text = "Радиус FOV: 100 px"
SliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SliderLabel.TextSize = 16
SliderLabel.Font = Enum.Font.SourceSansBold
SliderLabel.Parent = MainMenu

local SliderBar = Instance.new("Frame")
SliderBar.Name = "SliderBar"
SliderBar.Size = UDim2.new(0, 310, 0, 12)
SliderBar.Position = UDim2.new(0.5, -155, 0, 230)
SliderBar.BackgroundColor3 = Color3.fromRGB(70, 70, 85)
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
SliderBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
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
ESPToggle.Size = UDim2.new(0, 310, 0, 45)
ESPToggle.Position = UDim2.new(0.5, -155, 0, 270)
ESPToggle.BackgroundColor3 = Color3.fromRGB(0, 140, 0)
ESPToggle.Text = "ESP (ВХ): ВКЛУЧЕНО"
ESPToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
ESPToggle.TextSize = 16
ESPToggle.Font = Enum.Font.SourceSansBold
ESPToggle.Parent = MainMenu

local ESPToggleCorner = Instance.new("UICorner")
ESPToggleCorner.CornerRadius = UDim.new(0.2, 0)
ESPToggleCorner.Parent = ESPToggle

local ESPToggleStroke = Instance.new("UIStroke")
ESPToggleStroke.Thickness = 1
ESPToggleStroke.Color = Color3.fromRGB(75, 75, 90)
ESPToggleStroke.Parent = ESPToggle

local BHopToggle = Instance.new("TextButton")
BHopToggle.Name = "BHopToggle"
BHopToggle.Size = UDim2.new(0, 310, 0, 45)
BHopToggle.Position = UDim2.new(0.5, -155, 0, 330)
BHopToggle.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
BHopToggle.Text = "BUNNYHOP: ВЫКЛЮЧЕН"
BHopToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
BHopToggle.TextSize = 16
BHopToggle.Font = Enum.Font.SourceSansBold
BHopToggle.Parent = MainMenu

local BHopToggleCorner = Instance.new("UICorner")
BHopToggleCorner.CornerRadius = UDim.new(0.2, 0)
BHopToggleCorner.Parent = BHopToggle

local BHopToggleStroke = Instance.new("UIStroke")
BHopToggleStroke.Thickness = 1
BHopToggleStroke.Color = Color3.fromRGB(75, 75, 90)
BHopToggleStroke.Parent = BHopToggle

local ThirdPersonToggle = Instance.new("TextButton")
ThirdPersonToggle.Name = "ThirdPersonToggle"
ThirdPersonToggle.Size = UDim2.new(0, 310, 0, 45)
ThirdPersonToggle.Position = UDim2.new(0.5, -155, 0, 390)
ThirdPersonToggle.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
ThirdPersonToggle.Text = "ТРЕТЬЕ ЛИЦО: ВЫКЛ"
ThirdPersonToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
ThirdPersonToggle.TextSize = 16
ThirdPersonToggle.Font = Enum.Font.SourceSansBold
ThirdPersonToggle.Parent = MainMenu

local ThirdPersonCorner = Instance.new("UICorner")
ThirdPersonCorner.CornerRadius = UDim.new(0.2, 0)
ThirdPersonCorner.Parent = ThirdPersonToggle

local ThirdPersonStroke = Instance.new("UIStroke")
ThirdPersonStroke.Thickness = 1
ThirdPersonStroke.Color = Color3.fromRGB(75, 75, 90)
ThirdPersonStroke.Parent = ThirdPersonToggle

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Name = "SpeedLabel"
SpeedLabel.Size = UDim2.new(0, 310, 0, 25)
SpeedLabel.Position = UDim2.new(0.5, -155, 0, 450)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "Скорость бега: x1.0"
SpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedLabel.TextSize = 16
SpeedLabel.Font = Enum.Font.SourceSansBold
SpeedLabel.Parent = MainMenu

local SpeedBar = Instance.new("Frame")
SpeedBar.Name = "SpeedBar"
SpeedBar.Size = UDim2.new(0, 310, 0, 12)
SpeedBar.Position = UDim2.new(0.5, -155, 0, 485)
SpeedBar.BackgroundColor3 = Color3.fromRGB(70, 70, 85)
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
SpeedBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SpeedBtn.Text = ""
SpeedBtn.Parent = SpeedBar

local SpeedBtnCorner = Instance.new("UICorner")
SpeedBtnCorner.CornerRadius = UDim.new(1, 0)
SpeedBtnCorner.Parent = SpeedBtn

local SpeedBtnStroke = Instance.new("UIStroke")
SpeedBtnStroke.Thickness = 1
SpeedBtnStroke.Color = Color3.fromRGB(0, 0, 0)
SpeedBtnStroke.Parent = SpeedBtn

local EnvironmentButton = Instance.new("TextButton")
EnvironmentButton.Name = "EnvironmentButton"
EnvironmentButton.Size = UDim2.new(0, 310, 0, 45)
EnvironmentButton.Position = UDim2.new(0.5, -155, 0, 520)
EnvironmentButton.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
EnvironmentButton.Text = "Небо и Гамма: Стандарт"
EnvironmentButton.TextColor3 = Color3.fromRGB(255, 255, 255)
EnvironmentButton.TextSize = 16
EnvironmentButton.Font = Enum.Font.SourceSansBold
EnvironmentButton.Parent = MainMenu

local EnvironmentCorner = Instance.new("UICorner")
EnvironmentCorner.CornerRadius = UDim.new(0.2, 0)
EnvironmentCorner.Parent = EnvironmentButton

local EnvironmentStroke = Instance.new("UIStroke")
EnvironmentStroke.Thickness = 1
EnvironmentStroke.Color = Color3.fromRGB(75, 75, 90)
EnvironmentStroke.Parent = EnvironmentButton

local CreditLabel = Instance.new("TextLabel")
CreditLabel.Name = "CreditLabel"
CreditLabel.Size = UDim2.new(1, 0, 0, 30)
CreditLabel.Position = UDim2.new(0, 0, 1, -35)
CreditLabel.BackgroundTransparency = 1
CreditLabel.Text = "Block Strike Ultra Anti-Crash Mobile Engine"
CreditLabel.TextColor3 = Color3.fromRGB(140, 140, 150)
CreditLabel.TextSize = 13
CreditLabel.Font = Enum.Font.SourceSansItalic
CreditLabel.Parent = MainMenu

local LocalTracerAttachment = Instance.new("Attachment")
LocalTracerAttachment.Name = "LocalPlayerTracerAttachment"
LocalTracerAttachment.Position = Vector3.new(0, -2.5, -1)
LocalTracerAttachment.Parent = Camera

local fovRadius = 100
local aimMode = "Выкл"
local aimTarget = "Head"
local espEnabled = true
local bHopEnabled = false
local thirdPersonActive = false
local currentEnvironmentState = 1
local speedMultiplier = 1

local colorVisible = Color3.fromRGB(0, 255, 0)
local colorHidden = Color3.fromRGB(255, 0, 0)

local screenCenter = Vector2.new(0, 0)
local menuButtonPosition = nil
local isUserTouchingToFire = false

local ColorCorrection = Lighting:FindFirstChildOfClass("ColorCorrectionEffect")
if not ColorCorrection then
    ColorCorrection = Instance.new("ColorCorrectionEffect")
    ColorCorrection.Parent = Lighting
end

local function getCharactersFolder()
    return Workspace:FindFirstChild("Players") or Workspace:FindFirstChild("Entities") or Workspace
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
    SpeedLabel.Text = "Скорость бега: x" .. string.format("%.1f", speedMultiplier)
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
        ModeButton.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
    elseif aimMode == "Обычный Аим" then
        aimMode = "Сайлент Аим"
        ModeButton.BackgroundColor3 = Color3.fromRGB(0, 0, 150)
    else
        aimMode = "Выкл"
        ModeButton.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
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
    local folder = getCharactersFolder()
    for _, player in ipairs(Players:GetPlayers()) do
        local char = folder:FindFirstChild(player.Name)
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local bGui = hrp:FindFirstChild("MatrixBillboardEsp")
                if bGui then bGui:Destroy() end
                local attachment = hrp:FindFirstChild("EnemyTracerAttachment")
                if attachment then attachment:Destroy() end
            end
            local head = char:FindFirstChild("Head")
            if head then
                local tGui = head:FindFirstChild("NameDistanceEspGui")
                if tGui then tGui:Destroy() end
            end
            local highlight = char:FindFirstChild("MatrixEspHighlight")
            if highlight then highlight:Destroy() end
            local beam = Camera:FindFirstChild(player.Name .. "_BeamTracer")
            if beam then beam:Destroy() end
        end
    end
end

ESPToggle.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    if espEnabled then
        ESPToggle.BackgroundColor3 = Color3.fromRGB(0, 140, 0)
        ESPToggle.Text = "ESP (ВХ): ВКЛУЧЕНО"
    else
        ESPToggle.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
        ESPToggle.Text = "ESP (ВХ): ВЫКЛЮЧЕНО"
        cleanAllVisuals()
    end
end)

BHopToggle.MouseButton1Click:Connect(function()
    bHopEnabled = not bHopEnabled
    if bHopEnabled then
        BHopToggle.BackgroundColor3 = Color3.fromRGB(0, 140, 0)
        BHopToggle.Text = "BUNNYHOP: ВКЛУЧЕН"
    else
        BHopToggle.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
        BHopToggle.Text = "BUNNYHOP: ВЫКЛЮЧЕН"
    end
end)

ThirdPersonToggle.MouseButton1Click:Connect(function()
    thirdPersonActive = not thirdPersonActive
    if thirdPersonActive then
        ThirdPersonToggle.BackgroundColor3 = Color3.fromRGB(0, 140, 0)
        ThirdPersonToggle.Text = "ТРЕТЬЕ ЛИЦО: ВКЛ"
    else
        ThirdPersonToggle.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
        ThirdPersonToggle.Text = "ТРЕТЬЕ ЛИЦО: ВЫКЛ"
        LocalPlayer.CameraMaxZoomDistance = 0.5
        LocalPlayer.CameraMinZoomDistance = 0.5
    end
end)

EnvironmentButton.MouseButton1Click:Connect(function()
    if currentEnvironmentState == 1 then
        currentEnvironmentState = 2
        Lighting.TimeOfDay = "00:00:00"
        Lighting.Brightness = 0
        Lighting.OutdoorAmbient = Color3.fromRGB(15, 15, 35)
        ColorCorrection.Saturation = 0.6
        ColorCorrection.Contrast = 0.3
        ColorCorrection.Brightness = 0.05
        EnvironmentButton.Text = "Небо и Гамма: Полночь + Насыщенная"
    elseif currentEnvironmentState == 2 then
        currentEnvironmentState = 3
        Lighting.TimeOfDay = "18:20:00"
        Lighting.Brightness = 1.5
        Lighting.OutdoorAmbient = Color3.fromRGB(100, 50, 40)
        ColorCorrection.Saturation = -0.1
        ColorCorrection.Contrast = 0.4
        ColorCorrection.Brightness = -0.05
        EnvironmentButton.Text = "Небо и Гамма: Закат + Кино"
    else
        currentEnvironmentState = 1
        Lighting.TimeOfDay = "14:00:00"
        Lighting.Brightness = 3
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        ColorCorrection.Saturation = 0
        ColorCorrection.Contrast = 0
        ColorCorrection.Brightness = 0
        EnvironmentButton.Text = "Небо и Гамма: Стандарт"
    end
end)

UserInputService.TouchStarted:Connect(function(touch, processed)
    if not processed then
        isUserTouchingToFire = true
    end
end)

UserInputService.TouchEnded:Connect(function(touch, processed)
    isUserTouchingToFire = false
end)

local function isEnemy(targetPlayer)
    if targetPlayer == LocalPlayer then return false end
    if targetPlayer.Team and LocalPlayer.Team and targetPlayer.Team ~= LocalPlayer.Team then
        return true
    end
    local localTeamAttr = LocalPlayer:GetAttribute("Team") or LocalPlayer:GetAttribute("Side")
    local targetTeamAttr = targetPlayer:GetAttribute("Team") or targetPlayer:GetAttribute("Side")
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
    if head and head.Transparency >= 0.9 then
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

local function updatePlayerEsp(player, character, enemyVisible)
    local head = character:FindFirstChild("Head")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not head or not humanoid or not hrp then return end
    
    local nameGui = head:FindFirstChild("NameDistanceEspGui")
    if not nameGui then
        nameGui = Instance.new("BillboardGui")
        nameGui.Name = "NameDistanceEspGui"
        nameGui.Size = UDim2.new(0, 150, 0, 25)
        nameGui.StudsOffset = Vector3.new(0, 2.5, 0)
        nameGui.AlwaysOnTop = true
        
        local label = Instance.new("TextLabel")
        local stroke = Instance.new("UIStroke")
        label.Name = "Label"
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.SourceSansBold
        label.TextSize = 13
        stroke.Thickness = 1
        stroke.Color = Color3.fromRGB(0, 0, 0)
        stroke.Parent = label
        label.Parent = nameGui
        nameGui.Parent = head
    end
    
    local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local distanceMeters = 0
    if myHrp and hrp then
        distanceMeters = (hrp.Position - myHrp.Position).Magnitude
    end
    
    nameGui.Label.Text = string.format("%s [%dм]", player.Name, math.floor(distanceMeters))
    nameGui.Label.TextColor3 = enemyVisible and colorVisible or colorHidden
    
    local billboardGui = hrp:FindFirstChild("MatrixBillboardEsp")
    if not billboardGui then
        billboardGui = Instance.new("BillboardGui")
        billboardGui.Name = "MatrixBillboardEsp"
        billboardGui.Size = UDim2.new(0, 50, 0, 80)
        billboardGui.AlwaysOnTop = true
        
        local boxFrame = Instance.new("Frame")
        boxFrame.Name = "BoxFrame"
        boxFrame.Size = UDim2.new(1, 0, 1, 0)
        boxFrame.BackgroundTransparency = 1
        
        local boxStroke = Instance.new("UIStroke")
        boxStroke.Name = "BoxStroke"
        boxStroke.Thickness = 2
        boxStroke.Parent = boxFrame
        
        boxFrame.Parent = billboardGui
        
        local hpBg = Instance.new("Frame")
        hpBg.Name = "RightHpBg"
        hpBg.BackgroundColor3 = Color3.fromRGB(45, 10, 10)
        hpBg.BorderSizePixel = 0
        hpBg.Parent = boxFrame
        
        local hpBar = Instance.new("Frame")
        hpBar.Name = "RightHpFill"
        hpBar.BorderSizePixel = 0
        hpBar.Parent = hpBg
        
        billboardGui.Parent = hrp
    end
    
    local boxFrame = billboardGui:FindFirstChild("BoxFrame")
    if boxFrame then
        local boxStroke = boxFrame:FindFirstChild("BoxStroke")
        if boxStroke then
            boxStroke.Color = enemyVisible and colorVisible or colorHidden
        end
        
        local healthRatio = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
        local hpBg = boxFrame:FindFirstChild("RightHpBg")
        local hpFill = hpBg and hpBg:FindFirstChild("RightHpFill")
        if hpBg and hpFill then
            hpBg.Size = UDim2.new(0, 5, 1, 0)
            hpBg.Position = UDim2.new(1, 6, 0, 0)
            hpFill.Size = UDim2.new(1, 0, healthRatio, 0)
            hpFill.Position = UDim2.new(0, 0, 1 - healthRatio, 0)
            hpFill.BackgroundColor3 = Color3.fromHSV(healthRatio * 0.33, 1, 1)
        end
    end
    
    local enemyAttachment = hrp:FindFirstChild("EnemyTracerAttachment")
    if not enemyAttachment then
        enemyAttachment = Instance.new("Attachment")
        enemyAttachment.Name = "EnemyTracerAttachment"
        enemyAttachment.Parent = hrp
    end
    
    local beam = Camera:FindFirstChild(player.Name .. "_BeamTracer")
    if not beam then
        beam = Instance.new("Beam")
        beam.Name = player.Name .. "_BeamTracer"
        beam.Width0 = 0.05
        beam.Width1 = 0.05
        beam.FaceCamera = true
        beam.LightInfluence = 0
        beam.Attachment0 = LocalTracerAttachment
        beam.Attachment1 = enemyAttachment
        beam.Parent = Camera
    end
    
    beam.Color = ColorSequence.new(enemyVisible and colorVisible or colorHidden)
    
    local highlight = character:FindFirstChild("MatrixEspHighlight")
    if not highlight then
        highlight = Instance.new("Highlight")
        highlight.Name = "MatrixEspHighlight"
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
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
            local tGui = head:FindFirstChild("NameDistanceEspGui")
            if tGui then tGui:Destroy() end
        end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local bGui = hrp:FindFirstChild("MatrixBillboardEsp")
            if bGui then bGui:Destroy() end
            local attachment = hrp:FindFirstChild("EnemyTracerAttachment")
            if attachment then attachment:Destroy() end
        end
        local highlight = char:FindFirstChild("MatrixEspHighlight")
        if highlight then highlight:Destroy() end
    end
    local beam = Camera:FindFirstChild(player.Name .. "_BeamTracer")
    if beam then beam:Destroy() end
end

RunService.RenderStepped:Connect(function()
    local targetPlayer = getClosestVisibleEnemy()
    local folder = getCharactersFolder()
    
    if thirdPersonActive then
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
        FOVCircle.BackgroundColor3 = Color3.fromRGB(0, 255, 0, 0.95)
        
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
                    if isUserTouchingToFire or UserInputService:IsMouseButtonPressed(Enum.MouseButton1) then
                        local originalCameraCFrame = Camera.CFrame
                        Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
                        task.defer(function()
                            Camera.CFrame = originalCameraCFrame
                        end)
                    end
                end
            end
        end
    else
        FOVStroke.Color = Color3.fromRGB(255, 0, 0)
        FOVCircle.BackgroundColor3 = Color3.fromRGB(255, 0, 0, 0.95)
    end
    
    if bHopEnabled and myChar then
        local humanoid = myChar:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.Health > 0 then
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) or isUserTouchingToFire then
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
