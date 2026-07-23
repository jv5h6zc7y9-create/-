local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AimbotSystemGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local TopBarPatch = Instance.new("Frame")
TopBarPatch.Name = "TopBarPatch"
TopBarPatch.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
TopBarPatch.BorderSizePixel = 0
TopBarPatch.Position = UDim2.new(0, 0, 0, 0)
TopBarPatch.Size = UDim2.new(1, 0, 0, 0)
TopBarPatch.Visible = false
TopBarPatch.ZIndex = 10
TopBarPatch.Parent = ScreenGui

local BottomBarPatch = Instance.new("Frame")
BottomBarPatch.Name = "BottomBarPatch"
BottomBarPatch.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
BottomBarPatch.BorderSizePixel = 0
BottomBarPatch.Position = UDim2.new(0, 0, 1, 0)
BottomBarPatch.AnchorPoint = Vector2.new(0, 1)
BottomBarPatch.Size = UDim2.new(1, 0, 0, 0)
BottomBarPatch.Visible = false
BottomBarPatch.ZIndex = 10
BottomBarPatch.Parent = ScreenGui

local FOVCircle = Instance.new("Frame")
FOVCircle.Name = "FOVCircle"
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
FOVCircle.BackgroundTransparency = 0.8
FOVCircle.BorderSizePixel = 0
FOVCircle.Visible = true
FOVCircle.Parent = ScreenGui

local FOVStroke = Instance.new("UIStroke")
FOVStroke.Thickness = 2
FOVStroke.Color = Color3.fromRGB(255, 0, 0)
FOVStroke.Parent = FOVCircle

local FOVCorner = Instance.new("UICorner")
FOVCorner.CornerRadius = UDim.new(1, 0)
FOVCorner.Parent = FOVCircle

local MenuButton = Instance.new("TextButton")
MenuButton.Name = "MenuButton"
MenuButton.Size = UDim2.new(0, 50, 0, 50)
MenuButton.AnchorPoint = Vector2.new(0.5, 0.5)
MenuButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MenuButton.Text = "⚙️"
MenuButton.TextSize = 25
MenuButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MenuButton.ZIndex = 100
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
MainMenu.Size = UDim2.new(0, 320, 0, 640)
MainMenu.Position = UDim2.new(0.5, -160, 0.5, -320)
MainMenu.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainMenu.Visible = false
MainMenu.ZIndex = 101
MainMenu.Parent = ScreenGui

local MainMenuCorner = Instance.new("UICorner")
MainMenuCorner.CornerRadius = UDim.new(0.05, 0)
MainMenuCorner.Parent = MainMenu

local MainMenuStroke = Instance.new("UIStroke")
MainMenuStroke.Thickness = 2
MainMenuStroke.Color = Color3.fromRGB(80, 80, 80)
MainMenuStroke.Parent = MainMenu

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(1, 0, 0, 40)
TitleLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TitleLabel.Text = "НАСТРОЙКИ"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 18
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.Parent = MainMenu

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0.2, 0)
TitleCorner.Parent = TitleLabel

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
CloseButton.Text = "❌"
CloseButton.TextSize = 14
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Parent = MainMenu

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0.3, 0)
CloseCorner.Parent = CloseButton

local ModeButton = Instance.new("TextButton")
ModeButton.Name = "ModeButton"
ModeButton.Size = UDim2.new(0, 280, 0, 45)
ModeButton.Position = UDim2.new(0.5, -140, 0, 50)
ModeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
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
ModeStroke.Color = Color3.fromRGB(100, 100, 100)
ModeStroke.Parent = ModeButton

local TargetButton = Instance.new("TextButton")
TargetButton.Name = "TargetButton"
TargetButton.Size = UDim2.new(0, 280, 0, 45)
TargetButton.Position = UDim2.new(0.5, -140, 0, 100)
TargetButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
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
TargetStroke.Color = Color3.fromRGB(100, 100, 100)
TargetStroke.Parent = TargetButton

local SliderLabel = Instance.new("TextLabel")
SliderLabel.Name = "SliderLabel"
SliderLabel.Size = UDim2.new(0, 280, 0, 20)
SliderLabel.Position = UDim2.new(0.5, -140, 0, 150)
SliderLabel.BackgroundTransparency = 1
SliderLabel.Text = "Радиус FOV: 100 px"
SliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SliderLabel.TextSize = 15
SliderLabel.Font = Enum.Font.SourceSansBold
SliderLabel.Parent = MainMenu

local SliderBar = Instance.new("Frame")
SliderBar.Name = "SliderBar"
SliderBar.Size = UDim2.new(0, 280, 0, 10)
SliderBar.Position = UDim2.new(0.5, -140, 0, 175)
SliderBar.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
SliderBar.BorderSizePixel = 0
SliderBar.Parent = MainMenu

local SliderBarCorner = Instance.new("UICorner")
SliderBarCorner.CornerRadius = UDim.new(1, 0)
SliderBarCorner.Parent = SliderBar

local SliderBtn = Instance.new("TextButton")
SliderBtn.Name = "SliderBtn"
SliderBtn.Size = UDim2.new(0, 20, 0, 20)
SliderBtn.AnchorPoint = Vector2.new(0.5, 0.5)
SliderBtn.Position = UDim2.new(0.318, 0, 0.5, 0)
SliderBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SliderBtn.Text = ""
SliderBtn.Parent = SliderBar

local SliderBtnCorner = Instance.new("UICorner")
SliderBtnCorner.CornerRadius = UDim.new(1, 0)
SliderBtnCorner.Parent = SliderBtn

local YSliderLabel = Instance.new("TextLabel")
YSliderLabel.Name = "YSliderLabel"
YSliderLabel.Size = UDim2.new(0, 280, 0, 20)
YSliderLabel.Position = UDim2.new(0.5, -140, 0, 195)
YSliderLabel.BackgroundTransparency = 1
YSliderLabel.Text = "Смещение круга Y: 0 px"
YSliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
YSliderLabel.TextSize = 15
YSliderLabel.Font = Enum.Font.SourceSansBold
YSliderLabel.Parent = MainMenu

local YSliderBar = Instance.new("Frame")
YSliderBar.Name = "YSliderBar"
YSliderBar.Size = UDim2.new(0, 280, 0, 10)
YSliderBar.Position = UDim2.new(0.5, -140, 0, 220)
YSliderBar.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
YSliderBar.BorderSizePixel = 0
YSliderBar.Parent = MainMenu

local YSliderBarCorner = Instance.new("UICorner")
YSliderBarCorner.CornerRadius = UDim.new(1, 0)
YSliderBarCorner.Parent = YSliderBar

local YSliderBtn = Instance.new("TextButton")
YSliderBtn.Name = "YSliderBtn"
YSliderBtn.Size = UDim2.new(0, 20, 0, 20)
YSliderBtn.AnchorPoint = Vector2.new(0.5, 0.5)
YSliderBtn.Position = UDim2.new(0.5, 0, 0.5, 0)
YSliderBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
YSliderBtn.Text = ""
YSliderBtn.Parent = YSliderBar

local YSliderBtnCorner = Instance.new("UICorner")
YSliderBtnCorner.CornerRadius = UDim.new(1, 0)
YSliderBtnCorner.Parent = YSliderBtn

local ESPToggle = Instance.new("TextButton")
ESPToggle.Name = "ESPToggle"
ESPToggle.Size = UDim2.new(0, 280, 0, 45)
ESPToggle.Position = UDim2.new(0.5, -140, 0, 240)
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
ESPToggleStroke.Color = Color3.fromRGB(100, 100, 100)
ESPToggleStroke.Parent = ESPToggle

local BHopToggle = Instance.new("TextButton")
BHopToggle.Name = "BHopToggle"
BHopToggle.Size = UDim2.new(0, 280, 0, 45)
BHopToggle.Position = UDim2.new(0.5, -140, 0, 295)
BHopToggle.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
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
BHopToggleStroke.Color = Color3.fromRGB(100, 100, 100)
BHopToggleStroke.Parent = BHopToggle

local ThirdPersonToggle = Instance.new("TextButton")
ThirdPersonToggle.Name = "ThirdPersonToggle"
ThirdPersonToggle.Size = UDim2.new(0, 280, 0, 45)
ThirdPersonToggle.Position = UDim2.new(0.5, -140, 0, 350)
ThirdPersonToggle.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
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
ThirdPersonStroke.Color = Color3.fromRGB(100, 100, 100)
ThirdPersonStroke.Parent = ThirdPersonToggle

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Name = "SpeedLabel"
SpeedLabel.Size = UDim2.new(0, 280, 0, 20)
SpeedLabel.Position = UDim2.new(0.5, -140, 0, 400)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "Скорость бега: x1.0"
SpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedLabel.TextSize = 16
SpeedLabel.Font = Enum.Font.SourceSansBold
SpeedLabel.Parent = MainMenu

local SpeedBar = Instance.new("Frame")
SpeedBar.Name = "SpeedBar"
SpeedBar.Size = UDim2.new(0, 280, 0, 10)
SpeedBar.Position = UDim2.new(0.5, -140, 0, 425)
SpeedBar.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
SpeedBar.BorderSizePixel = 0
SpeedBar.Parent = MainMenu

local SpeedBarCorner = Instance.new("UICorner")
SpeedBarCorner.CornerRadius = UDim.new(1, 0)
SpeedBarCorner.Parent = SpeedBar

local SpeedBtn = Instance.new("TextButton")
SpeedBtn.Name = "SpeedBtn"
SpeedBtn.Size = UDim2.new(0, 20, 0, 20)
SpeedBtn.AnchorPoint = Vector2.new(0.5, 0.5)
SpeedBtn.Position = UDim2.new(0, 0, 0.5, 0)
SpeedBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SpeedBtn.Text = ""
SpeedBtn.Parent = SpeedBar

local SpeedBtnCorner = Instance.new("UICorner")
SpeedBtnCorner.CornerRadius = UDim.new(1, 0)
SpeedBtnCorner.Parent = SpeedBtn

local EnvironmentButton = Instance.new("TextButton")
EnvironmentButton.Name = "EnvironmentButton"
EnvironmentButton.Size = UDim2.new(0, 280, 0, 45)
EnvironmentButton.Position = UDim2.new(0.5, -140, 0, 445)
EnvironmentButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
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
EnvironmentStroke.Color = Color3.fromRGB(100, 100, 100)
EnvironmentStroke.Parent = EnvironmentButton

local StretchButton = Instance.new("TextButton")
StretchButton.Name = "StretchButton"
StretchButton.Size = UDim2.new(0, 280, 0, 45)
StretchButton.Position = UDim2.new(0.5, -140, 0, 500)
StretchButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
StretchButton.Text = "Растяг: 16:9 (Стандарт)"
StretchButton.TextColor3 = Color3.fromRGB(255, 255, 255)
StretchButton.TextSize = 16
StretchButton.Font = Enum.Font.SourceSansBold
StretchButton.Parent = MainMenu

local StretchCorner = Instance.new("UICorner")
StretchCorner.CornerRadius = UDim.new(0.2, 0)
StretchCorner.Parent = StretchButton

local StretchStroke = Instance.new("UIStroke")
StretchStroke.Thickness = 1
StretchStroke.Color = Color3.fromRGB(100, 100, 100)
StretchStroke.Parent = StretchButton

local DrawingContainer = Instance.new("Folder")
DrawingContainer.Name = "DrawingContainer"
DrawingContainer.Parent = ScreenGui

local AttachmentOrigin = Instance.new("Attachment")
AttachmentOrigin.Name = "DeltaLocalOriginAttachment"
AttachmentOrigin.Position = Vector3.new(0, -2.5, -1)
AttachmentOrigin.Parent = Camera

local ScreenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
local FOV_RADIUS = 100
local AIM_SMOOTHNESS = 1

local MenuConfig = {
    AimbotEnabled = false,
    SilentAimActive = false
}

local aimMode = "Выкл"
local aimTarget = "Head"
local espEnabled = true
local bHopEnabled = false
local thirdPersonActive = false
local currentEnvironmentState = 1
local speedMultiplier = 1
local currentRatioIndex = 1
local aspectRatios = {0, 4/3, 5/4}
local aspectRatioTexts = {"16:9 (Стандарт)", "4:3 (Растянуто)", "5:4 (Ультра-растянуто)"}
local circleOffsetY = 0

local colorVisible = Color3.fromRGB(30, 255, 30)
local colorHidden = Color3.fromRGB(255, 30, 30)

local menuButtonPosition = nil

local function getCharactersFolder()
    local checkPlayers = Workspace:FindFirstChild("Players")
    if checkPlayers then
        return checkPlayers
    end
    local checkEntities = Workspace:FindFirstChild("Entities")
    if checkEntities then
        return checkEntities
    end
    return Workspace
end

local function EnforceAspectRatio(ratio)
    if ratio == 0 then
        TopBarPatch.Visible = false
        BottomBarPatch.Visible = false
        return
    end
    local width = Camera.ViewportSize.X
    local height = Camera.ViewportSize.Y
    local targetHeight = width / ratio
    if targetHeight < height then
        local delta = (height - targetHeight) / 2
        TopBarPatch.Size = UDim2.new(1, 0, 0, delta)
        TopBarPatch.Visible = true
        BottomBarPatch.Size = UDim2.new(1, 0, 0, delta)
        BottomBarPatch.Position = UDim2.new(0, 0, 1, 0)
        BottomBarPatch.Visible = true
    else
        TopBarPatch.Visible = false
        BottomBarPatch.Visible = false
    end
end

local function UpdateViewportCenter()
    local insetTop, insetBottom = GuiService:GetGuiInset()
    ScreenCenter = Vector2.new(Camera.ViewportSize.X / 2, (Camera.ViewportSize.Y - (insetTop + insetBottom)) / 2)
    if FOVCircle then
        FOVCircle.Position = UDim2.new(0, ScreenCenter.X, 0, ScreenCenter.Y + circleOffsetY)
    end
    if not menuButtonPosition then
        MenuButton.Position = UDim2.new(0, ScreenCenter.X, 0, ScreenCenter.Y)
    end
    EnforceAspectRatio(aspectRatios[currentRatioIndex])
end

Camera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateViewportCenter)
UpdateViewportCenter()

local Dragging, DragInput, DragStart, StartPos

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

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if Dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - DragStart
        local newPos = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + delta.X, StartPos.Y.Scale, StartPos.Y.Offset + delta.Y)
        MenuButton.Position = newPos
        menuButtonPosition = newPos
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

local function updateFOV(radius)
    FOV_RADIUS = radius
    FOVCircle.Size = UDim2.new(0, radius * 2, 0, radius * 2)
    SliderLabel.Text = "Радиус FOV: " .. tostring(math.round(radius)) .. " px"
end

updateFOV(FOV_RADIUS)

local draggingSlider = false

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
        local rX = input.Position.X - SliderBar.AbsolutePosition.X
        local percentage = math.clamp(rX / SliderBar.AbsoluteSize.X, 0, 1)
        SliderBtn.Position = UDim2.new(percentage, 0, 0.5, 0)
        local newRadius = 30 + (percentage * 220)
        updateFOV(newRadius)
    end
end)

local draggingYSlider = false

YSliderBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingYSlider = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingYSlider = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingYSlider and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local rX = input.Position.X - YSliderBar.AbsolutePosition.X
        local percentage = math.clamp(rX / YSliderBar.AbsoluteSize.X, 0, 1)
        YSliderBtn.Position = UDim2.new(percentage, 0, 0.5, 0)
        circleOffsetY = -150 + (percentage * 300)
        YSliderLabel.Text = "Смещение круга Y: " .. tostring(math.round(circleOffsetY)) .. " px"
        FOVCircle.Position = UDim2.new(0, ScreenCenter.X, 0, ScreenCenter.Y + circleOffsetY)
    end
end)

local draggingSpeedSlider = false

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
        local rX = input.Position.X - SpeedBar.AbsolutePosition.X
        local percentage = math.clamp(rX / SpeedBar.AbsoluteSize.X, 0, 1)
        SpeedBtn.Position = UDim2.new(percentage, 0, 0.5, 0)
        speedMultiplier = 1 + (percentage * 4)
        SpeedLabel.Text = "Скорость бега: x" .. string.format("%.1f", speedMultiplier)
    end
end)

ModeButton.MouseButton1Click:Connect(function()
    if aimMode == "Выкл" then
        aimMode = "Обычный Аим"
        MenuConfig.AimbotEnabled = true
        MenuConfig.SilentAimActive = false
        ModeButton.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
    elseif aimMode == "Обычный Аим" then
        aimMode = "Сайлент Аим"
        MenuConfig.AimbotEnabled = false
        MenuConfig.SilentAimActive = true
        ModeButton.BackgroundColor3 = Color3.fromRGB(0, 0, 150)
    else
        aimMode = "Выкл"
        MenuConfig.AimbotEnabled = false
        MenuConfig.SilentAimActive = false
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

local function removePlayerEsp(player)
    local folder = getCharactersFolder()
    local char = folder:FindFirstChild(player.Name)
    if char then
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            local bb = root:FindFirstChild("DeltaBillboard")
            if bb then bb:Destroy() end
            local tAtt = root:FindFirstChild("DeltaTracerAttachment")
            if tAtt then tAtt:Destroy() end
            local beam = root:FindFirstChild("DeltaTracerBeam")
            if beam then beam:Destroy() end
        end
        local hl = char:FindFirstChild("DeltaHighlight")
        if hl then hl:Destroy() end
    end
end

local function cleanAllVisuals()
    local currentPlayers = Players:GetPlayers()
    for index = 1, #currentPlayers do
        removePlayerEsp(currentPlayers[index])
    end
end

ESPToggle.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    if espEnabled then
        ESPToggle.BackgroundColor3 = Color3.fromRGB(0, 140, 0)
        ESPToggle.Text = "ESP (ВХ): ВКЛУЧЕНО"
    else
        ESPToggle.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
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
        BHopToggle.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
        BHopToggle.Text = "BUNNYHOP: ВЫКЛЮЧЕН"
    end
end)

ThirdPersonToggle.MouseButton1Click:Connect(function()
    thirdPersonActive = not thirdPersonActive
    if thirdPersonActive then
        ThirdPersonToggle.BackgroundColor3 = Color3.fromRGB(0, 140, 0)
        ThirdPersonToggle.Text = "ТРЕТЬЕ ЛИЦО: ВКЛ"
    else
        ThirdPersonToggle.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
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
        EnvironmentButton.Text = "Небо и Гамма: Полночь"
    elseif currentEnvironmentState == 2 then
        currentEnvironmentState = 3
        Lighting.TimeOfDay = "18:20:00"
        Lighting.Brightness = 1.5
        Lighting.OutdoorAmbient = Color3.fromRGB(100, 50, 40)
        ColorCorrection.Saturation = -0.1
        ColorCorrection.Contrast = 0.4
        ColorCorrection.Brightness = -0.05
        EnvironmentButton.Text = "Небо и Гамма: Закат"
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

StretchButton.MouseButton1Click:Connect(function()
    currentRatioIndex = currentRatioIndex + 1
    if currentRatioIndex > #aspectRatios then
        currentRatioIndex = 1
    end
    StretchButton.Text = "Растяг: " .. aspectRatioTexts[currentRatioIndex]
    EnforceAspectRatio(aspectRatios[currentRatioIndex])
end)

local function IsEnemy(targetPlayer)
    if targetPlayer == LocalPlayer then
        return false
    end
    if targetPlayer.Team and LocalPlayer.Team and targetPlayer.Team ~= LocalPlayer.Team then
        return true
    end
    local localTeamAttr = LocalPlayer:GetAttribute("Team") or LocalPlayer:GetAttribute("Side")
    local targetTeamAttr = targetPlayer:GetAttribute("Team") or targetPlayer:GetAttribute("Side")
    if localTeamAttr and targetTeamAttr and localTeamAttr ~= targetTeamAttr then
        return true
    end
    if targetPlayer.TeamColor ~= LocalPlayer.TeamColor and targetPlayer.TeamColor ~= BrickColor.new("White") then
        return true
    end
    return false
end

local function ValidatedTarget(character)
    local hum = character:FindFirstChildOfClass("Humanoid")
    local head = character:FindFirstChild("Head")
    local root = character:FindFirstChild("HumanoidRootPart")
    if hum and head and root and hum.Health > 0 and character.Name ~= "Dead" and head.Transparency ~= 1 then
        return hum, head, root
    end
    return nil
end

local function IsVisibleCheck(targetPart)
    local character = LocalPlayer.Character
    if not character then
        return false
    end
    local originPart = character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
    if not originPart then
        return false
    end
    local origin = originPart.Position
    local direction = targetPart.Position - origin
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {character, targetPart.Parent, getCharactersFolder()}
    params.IgnoreWater = true
    local result = workspace:Raycast(origin, direction, params)
    if result == nil then
        return true
    else
        return false
    end
end

local function ApplyVisuals(target, occluded, dist)
    local visibilityColor = occluded and Color3.fromRGB(255, 30, 30) or Color3.fromRGB(30, 255, 30)
    
    local hl = target.Char:FindFirstChild("DeltaHighlight") or Instance.new("Highlight")
    if not hl.Parent then
        hl.Name = "DeltaHighlight"
        hl.FillTransparency = 0.85
        hl.OutlineTransparency = 0
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = target.Char
    end
    hl.FillColor = visibilityColor
    hl.OutlineColor = visibilityColor
    
    local bb = target.Root:FindFirstChild("DeltaBillboard") or Instance.new("BillboardGui")
    if not bb.Parent then
        bb.Name = "DeltaBillboard"
        bb.AlwaysOnTop = true
        bb.Size = UDim2.new(0, 130, 0, 150)
        bb.Adornee = target.Root
        bb.Parent = target.Root
    end
    
    local box = bb:FindFirstChild("BoundingBox") or Instance.new("Frame")
    if not box.Parent then
        box.Name = "BoundingBox"
        box.Size = UDim2.new(0, 65, 0, 95)
        box.Position = UDim2.new(0.5, -32, 0.5, -47)
        box.BackgroundTransparency = 1
        box.Parent = bb
    end
    
    local stroke = box:FindFirstChild("UIStroke") or Instance.new("UIStroke")
    if not stroke.Parent then
        stroke.Thickness = 1.5
        stroke.Parent = box
    end
    stroke.Color = visibilityColor
    
    local track = box:FindFirstChild("HealthTrack") or Instance.new("Frame")
    if not track.Parent then
        track.Name = "HealthTrack"
        track.Size = UDim2.new(0, 4, 0, 95)
        track.Position = UDim2.new(1, 4, 0, 0)
        track.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        track.BorderSizePixel = 0
        track.Parent = box
    end
    
    local fill = track:FindFirstChild("HealthFill") or Instance.new("Frame")
    if not fill.Parent then
        fill.Name = "HealthFill"
        fill.AnchorPoint = Vector2.new(0, 1)
        fill.Position = UDim2.new(0, 0, 1, 0)
        fill.BorderSizePixel = 0
        fill.Parent = track
    end
    
    local hpPct = math.clamp(target.Hum.Health / target.Hum.MaxHealth, 0, 1)
    fill.Size = UDim2.new(1, 0, hpPct, 0)
    fill.BackgroundColor3 = Color3.fromRGB(255 * (1 - hpPct), hpPct * 255, 0)
    
    local lbl = box:FindFirstChild("InfoLabel") or Instance.new("TextLabel")
    if not lbl.Parent then
        lbl.Name = "InfoLabel"
        lbl.Size = UDim2.new(2, 0, 0, 18)
        lbl.Position = UDim2.new(-0.5, 0, 0, -22)
        lbl.BackgroundTransparency = 1
        lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
        lbl.TextStrokeTransparency = 0
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 10
        lbl.Parent = box
    end
    lbl.Text = string.format("%s [%dm]", target.Player and target.Player.Name or target.Char.Name, math.floor(dist))
    
    local tAtt = target.Root:FindFirstChild("DeltaTracerAttachment") or Instance.new("Attachment")
    if not tAtt.Parent then
        tAtt.Name = "DeltaTracerAttachment"
        tAtt.Parent = target.Root
    end
    
    local beam = target.Root:FindFirstChild("DeltaTracerBeam") or Instance.new("Beam")
    if not beam.Parent then
        beam.Name = "DeltaTracerBeam"
        beam.Attachment0 = AttachmentOrigin
        beam.Attachment1 = tAtt
        beam.Width0 = 0.04
        beam.Width1 = 0.04
        beam.FaceCamera = true
        beam.LightInfluence = 0
        beam.Parent = target.Root
    end
    beam.Color = ColorSequence.new(visibilityColor)
end

local function getClosestVisibleEnemy()
    local closestPlayer = nil
    local shortestDistance = math.huge
    local currentTargetPartName = aimTarget
    if aimMode == "Сайлент Аим" then
        currentTargetPartName = "Head"
    end
    
    local folder = getCharactersFolder()
    local playerList = Players:GetPlayers()
    
    for i = 1, #playerList do
        local player = playerList[i]
        if IsEnemy(player) then
            local char = folder:FindFirstChild(player.Name)
            if char then
                local hum, head, root = ValidatedTarget(char)
                if hum and head and root then
                    local targetPart = char:FindFirstChild(currentTargetPartName)
                    if targetPart then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                        if onScreen then
                            local mousePos = Vector2.new(screenPos.X, screenPos.Y)
                            local actualFovCenter = Vector2.new(ScreenCenter.X, ScreenCenter.Y + circleOffsetY)
                            local distance = (mousePos - actualFovCenter).Magnitude
                            if distance <= FOV_RADIUS and distance < shortestDistance then
                                if IsVisibleCheck(targetPart) then
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

RunService.RenderStepped:Connect(function()
    if not ScreenGui or not ScreenGui.Parent then
        ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Name = "AimbotSystemGui"
        ScreenGui.ResetOnSpawn = false
        ScreenGui.IgnoreGuiInset = true
        ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
    
    if not FOVCircle or not FOVCircle.Parent then
        FOVCircle = Instance.new("Frame")
        FOVCircle.Name = "FOVCircle"
        FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
        FOVCircle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        FOVCircle.BackgroundTransparency = 0.8
        FOVCircle.BorderSizePixel = 0
        FOVCircle.Visible = true
        FOVCircle.Parent = ScreenGui
        FOVStroke = Instance.new("UIStroke")
        FOVStroke.Thickness = 2
        FOVStroke.Color = Color3.fromRGB(255, 0, 0)
        FOVStroke.Parent = FOVCircle
        FOVCorner = Instance.new("UICorner")
        FOVCorner.CornerRadius = UDim.new(1, 0)
        FOVCorner.Parent = FOVCircle
    end
    
    if not MenuButton or not MenuButton.Parent then
        MenuButton = Instance.new("TextButton")
        MenuButton.Name = "MenuButton"
        MenuButton.Size = UDim2.new(0, 50, 0, 50)
        MenuButton.AnchorPoint = Vector2.new(0.5, 0.5)
        MenuButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        MenuButton.Text = "⚙️"
        MenuButton.TextSize = 25
        MenuButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        MenuButton.ZIndex = 100
        MenuButton.Parent = ScreenGui
    end
    
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
    
    if bHopEnabled and myChar then
        local humanoid = myChar:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.Health > 0 then
            local isInteracting = UserInputService:IsMouseButtonPressed(Enum.MouseButton1) or #UserInputService:GetTouches() > 0
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) or isInteracting then
                if humanoid.FloorMaterial ~= Enum.Material.Air then
                    humanoid.Jump = true
                end
            end
        end
    end
    
    local activeScreenPlayers = {}
    local allPlayers = Players:GetPlayers()
    
    for j = 1, #allPlayers do
        local player = allPlayers[j]
        if IsEnemy(player) then
            local char = folder:FindFirstChild(player.Name)
            if char then
                local hum, head, root = ValidatedTarget(char)
                if hum and head and root then
                    if espEnabled then
                        activeScreenPlayers[player.Name] = true
                        local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        local dist = 0
                        if myHrp and root then
                            dist = (root.Position - myHrp.Position).Magnitude
                        end
                        local occluded = not IsVisibleCheck(root)
                        local wrapper = {
                            Char = char,
                            Root = root,
                            Hum = hum,
                            Player = player
                        }
                        ApplyVisuals(wrapper, occluded, dist)
                    end
                end
            end
        end
    end
    
    if aimMode ~= "Выкл" and targetPlayer then
        FOVStroke.Color = Color3.fromRGB(30, 255, 30)
        FOVCircle.BackgroundColor3 = Color3.fromRGB(30, 255, 30)
        
        local currentTargetPartName = aimTarget
        if aimMode == "Сайлент Аим" then
            currentTargetPartName = "Head"
        end
        
        local char = folder:FindFirstChild(targetPlayer.Name)
        if char then
            local hum, head, root = ValidatedTarget(char)
            if hum and head and root then
                local targetPart = char:FindFirstChild(currentTargetPartName)
                if targetPart then
                    if aimMode == "Обычный Аим" then
                        local inputService = game:GetService("UserInputService")
                        local isInteracting = inputService:IsMouseButtonPressed(Enum.MouseButton1) or #inputService:GetTouches() > 0
                        if isInteracting then
                            local targetDir = (targetPart.Position - Camera.CFrame.Position).Unit
                            local targetRot = CFrame.lookAt(Camera.CFrame.Position, Camera.CFrame.Position + targetDir)
                            Camera.CFrame = Camera.CFrame:Lerp(targetRot, AIM_SMOOTHNESS)
                        end
                    elseif aimMode == "Сайлент Аим" then
                        local targetDir = (targetPart.Position - Camera.CFrame.Position).Unit
                        local targetRot = CFrame.lookAt(Camera.CFrame.Position, Camera.CFrame.Position + targetDir)
                        Camera.CFrame = targetRot
                    end
                end
            end
        end
    else
        FOVStroke.Color = Color3.fromRGB(255, 30, 30)
        FOVCircle.BackgroundColor3 = Color3.fromRGB(255, 30, 30)
    end
    
    for k = 1, #allPlayers do
        local player = allPlayers[k]
        if not activeScreenPlayers[player.Name] then
            removePlayerEsp(player)
        end
    end
end)

Players.PlayerRemoving:Connect(function(player)
    removePlayerEsp(player)
end)
