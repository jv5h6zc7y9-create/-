local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FixedMobileMatrixEngine"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 999999
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

-- Перенесено наверх слева, чтобы не мешать геймплею
local MenuButton = Instance.new("TextButton")
MenuButton.Name = "MenuButton"
MenuButton.Size = UDim2.new(0, 50, 0, 50)
MenuButton.Position = UDim2.new(0, 15, 0, 80)
MenuButton.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MenuButton.Text = "⚙️"
MenuButton.TextSize = 24
MenuButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MenuButton.ZIndex = 10
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
MainMenu.Size = UDim2.new(0, 320, 0, 580)
MainMenu.Position = UDim2.new(0.5, -160, 0.5, -290)
MainMenu.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainMenu.Visible = false
MainMenu.ZIndex = 100
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
TitleLabel.Text = "Matrix Engine (Fixed)"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 16
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.Parent = MainMenu

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0.15, 0)
TitleCorner.Parent = TitleLabel

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -38, 0, 7)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
CloseButton.Text = "❌"
CloseButton.TextSize = 12
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.ZIndex = 101
CloseButton.Parent = MainMenu

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0.3, 0)
CloseCorner.Parent = CloseButton

local ModeButton = Instance.new("TextButton")
ModeButton.Name = "ModeButton"
ModeButton.Size = UDim2.new(0, 280, 0, 40)
ModeButton.Position = UDim2.new(0.5, -140, 0, 55)
ModeButton.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
ModeButton.Text = "Режим: Выкл"
ModeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ModeButton.TextSize = 15
ModeButton.Font = Enum.Font.SourceSansBold
ModeButton.ZIndex = 101
ModeButton.Parent = MainMenu

local ModeCorner = Instance.new("UICorner")
ModeCorner.CornerRadius = UDim.new(0.2, 0)
ModeCorner.Parent = ModeButton

local TargetButton = Instance.new("TextButton")
TargetButton.Name = "TargetButton"
TargetButton.Size = UDim2.new(0, 280, 0, 40)
TargetButton.Position = UDim2.new(0.5, -140, 0, 105)
TargetButton.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
TargetButton.Text = "Цель: Head"
TargetButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TargetButton.TextSize = 15
TargetButton.Font = Enum.Font.SourceSansBold
TargetButton.ZIndex = 101
TargetButton.Parent = MainMenu

local TargetCorner = Instance.new("UICorner")
TargetCorner.CornerRadius = UDim.new(0.2, 0)
TargetCorner.Parent = TargetButton

local SliderLabel = Instance.new("TextLabel")
SliderLabel.Name = "SliderLabel"
SliderLabel.Size = UDim2.new(0, 280, 0, 20)
SliderLabel.Position = UDim2.new(0.5, -140, 0, 155)
SliderLabel.BackgroundTransparency = 1
SliderLabel.Text = "Радиус FOV: 100 px"
SliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SliderLabel.TextSize = 14
SliderLabel.Font = Enum.Font.SourceSansBold
SliderLabel.ZIndex = 101
SliderLabel.Parent = MainMenu

local SliderBar = Instance.new("Frame")
SliderBar.Name = "SliderBar"
SliderBar.Size = UDim2.new(0, 280, 0, 10)
SliderBar.Position = UDim2.new(0.5, -140, 0, 180)
SliderBar.BackgroundColor3 = Color3.fromRGB(70, 70, 85)
SliderBar.BorderSizePixel = 0
SliderBar.ZIndex = 101
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
SliderBtn.ZIndex = 102
SliderBtn.Parent = SliderBar

local SliderBtnCorner = Instance.new("UICorner")
SliderBtnCorner.CornerRadius = UDim.new(1, 0)
SliderBtnCorner.Parent = SliderBtn

local ESPToggle = Instance.new("TextButton")
ESPToggle.Name = "ESPToggle"
ESPToggle.Size = UDim2.new(0, 280, 0, 40)
ESPToggle.Position = UDim2.new(0.5, -140, 0, 210)
ESPToggle.BackgroundColor3 = Color3.fromRGB(0, 140, 0)
ESPToggle.Text = "ESP (ВХ): ВКЛЮЧЕНО"
ESPToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
ESPToggle.TextSize = 15
ESPToggle.Font = Enum.Font.SourceSansBold
ESPToggle.ZIndex = 101
ESPToggle.Parent = MainMenu

local ESPToggleCorner = Instance.new("UICorner")
ESPToggleCorner.CornerRadius = UDim.new(0.2, 0)
ESPToggleCorner.Parent = ESPToggle

local BHopToggle = Instance.new("TextButton")
BHopToggle.Name = "BHopToggle"
BHopToggle.Size = UDim2.new(0, 280, 0, 40)
BHopToggle.Position = UDim2.new(0.5, -140, 0, 260)
BHopToggle.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
BHopToggle.Text = "BUNNYHOP: ВЫКЛ"
BHopToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
BHopToggle.TextSize = 15
BHopToggle.Font = Enum.Font.SourceSansBold
BHopToggle.ZIndex = 101
BHopToggle.Parent = MainMenu

local BHopToggleCorner = Instance.new("UICorner")
BHopToggleCorner.CornerRadius = UDim.new(0.2, 0)
BHopToggleCorner.Parent = BHopToggle

local ThirdPersonToggle = Instance.new("TextButton")
ThirdPersonToggle.Name = "ThirdPersonToggle"
ThirdPersonToggle.Size = UDim2.new(0, 280, 0, 40)
ThirdPersonToggle.Position = UDim2.new(0.5, -140, 0, 310)
ThirdPersonToggle.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
ThirdPersonToggle.Text = "ТРЕТЬЕ ЛИЦО: ВЫКЛ"
ThirdPersonToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
ThirdPersonToggle.TextSize = 15
ThirdPersonToggle.Font = Enum.Font.SourceSansBold
ThirdPersonToggle.ZIndex = 101
ThirdPersonToggle.Parent = MainMenu

local ThirdPersonCorner = Instance.new("UICorner")
ThirdPersonCorner.CornerRadius = UDim.new(0.2, 0)
ThirdPersonCorner.Parent = ThirdPersonToggle

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Name = "SpeedLabel"
SpeedLabel.Size = UDim2.new(0, 280, 0, 20)
SpeedLabel.Position = UDim2.new(0.5, -140, 0, 360)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "Скорость: x1.0"
SpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedLabel.TextSize = 14
SpeedLabel.Font = Enum.Font.SourceSansBold
SpeedLabel.ZIndex = 101
SpeedLabel.Parent = MainMenu

local SpeedBar = Instance.new("Frame")
SpeedBar.Name = "SpeedBar"
SpeedBar.Size = UDim2.new(0, 280, 0, 10)
SpeedBar.Position = UDim2.new(0.5, -140, 0, 385)
SpeedBar.BackgroundColor3 = Color3.fromRGB(70, 70, 85)
SpeedBar.BorderSizePixel = 0
SpeedBar.ZIndex = 101
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
SpeedBtn.ZIndex = 102
SpeedBtn.Parent = SpeedBar

local SpeedBtnCorner = Instance.new("UICorner")
SpeedBtnCorner.CornerRadius = UDim.new(1, 0)
SpeedBtnCorner.Parent = SpeedBtn

local EnvironmentButton = Instance.new("TextButton")
EnvironmentButton.Name = "EnvironmentButton"
EnvironmentButton.Size = UDim2.new(0, 280, 0, 40)
EnvironmentButton.Position = UDim2.new(0.5, -140, 0, 415)
EnvironmentButton.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
EnvironmentButton.Text = "Небо: Стандарт"
EnvironmentButton.TextColor3 = Color3.fromRGB(255, 255, 255)
EnvironmentButton.TextSize = 15
EnvironmentButton.Font = Enum.Font.SourceSansBold
EnvironmentButton.ZIndex = 101
EnvironmentButton.Parent = MainMenu

local EnvironmentCorner = Instance.new("UICorner")
EnvironmentCorner.CornerRadius = UDim.new(0.2, 0)
EnvironmentCorner.Parent = EnvironmentButton

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

local ColorCorrection = Lighting:FindFirstChildOfClass("ColorCorrectionEffect")
if not ColorCorrection then
    ColorCorrection = Instance.new("ColorCorrectionEffect")
    ColorCorrection.Parent = Lighting
end

local function getCharactersFolder()
    local checkPlayers = Workspace:FindFirstChild("Players")
    if checkPlayers then return checkPlayers end
    local checkEntities = Workspace:FindFirstChild("Entities")
    if checkEntities then return checkEntities end
    return Workspace
end

local function UpdateViewportCenter()
    local insetTop, insetBottom = GuiService:GetGuiInset()
    ScreenCenter = Vector2.new(Camera.ViewportSize.X / 2, (Camera.ViewportSize.Y - (insetTop + insetBottom)) / 2)
    if FOVCircle then
        FOVCircle.Position = UDim2.new(0, ScreenCenter.X, 0, ScreenCenter.Y)
    end
end

Camera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateViewportCenter)
UpdateViewportCenter()

-- Клик по кнопке шестеренки открывает/закрывает меню
MenuButton.MouseButton1Click:Connect(function()
    MainMenu.Visible = not MainMenu.Visible
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

local draggingSpeedSlider = false
SpeedBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingSpeedSlider = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingSlider = false
        draggingSpeedSlider = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if (draggingSlider or draggingSpeedSlider) and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        if draggingSlider then
            local rX = input.Position.X - SliderBar.AbsolutePosition.X
            local percentage = math.clamp(rX / SliderBar.AbsoluteSize.X, 0, 1)
            SliderBtn.Position = UDim2.new(percentage, 0, 0.5, 0)
            updateFOV(30 + (percentage * 220))
        elseif draggingSpeedSlider then
            local rX = input.Position.X - SpeedBar.AbsolutePosition.X
            local percentage = math.clamp(rX / SpeedBar.AbsoluteSize.X, 0, 1)
            SpeedBtn.Position = UDim2.new(percentage, 0, 0.5, 0)
            speedMultiplier = 1 + (percentage * 4)
            SpeedLabel.Text = "Скорость: x" .. string.format("%.1f", speedMultiplier)
        end
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
        ESPToggle.Text = "ESP (ВХ): ВКЛЮЧЕНО"
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
        BHopToggle.Text = "BUNNYHOP: ВКЛ"
    else
        BHopToggle.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
        BHopToggle.Text = "BUNNYHOP: ВЫКЛ"
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
        EnvironmentButton.Text = "Небо: Полночь"
    elseif currentEnvironmentState == 2 then
        currentEnvironmentState = 3
        Lighting.TimeOfDay = "18:20:00"
        Lighting.Brightness = 1.5
        Lighting.OutdoorAmbient = Color3.fromRGB(100, 50, 40)
        ColorCorrection.Saturation = -0.1
        ColorCorrection.Contrast = 0.4
        ColorCorrection.Brightness = -0.05
        EnvironmentButton.Text = "Небо: Закат"
    else
        currentEnvironmentState = 1
        Lighting.TimeOfDay = "14:00:00"
        Lighting.Brightness = 3
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        ColorCorrection.Saturation = 0
        ColorCorrection.Contrast = 0
        ColorCorrection.Brightness = 0
        EnvironmentButton.Text = "Небо: Стандарт"
    end
end)

local function IsEnemy(targetPlayer)
    if targetPlayer == LocalPlayer then return false end
    if targetPlayer.Team and LocalPlayer.Team and targetPlayer.Team ~= LocalPlayer.Team then return true end
    local localTeamAttr = LocalPlayer:GetAttribute("Team") or LocalPlayer:GetAttribute("Side")
    local targetTeamAttr = targetPlayer:GetAttribute("Team") or targetPlayer:GetAttribute("Side")
    if localTeamAttr and targetTeamAttr and localTeamAttr ~= targetTeamAttr then return true end
    if targetPlayer.TeamColor ~= LocalPlayer.TeamColor and targetPlayer.TeamColor ~= BrickColor.new("White") then return true end
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
    if not character then return false end
    local originPart = character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
    if not originPart then return false end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {character, targetPart.Parent, getCharactersFolder()}
    params.IgnoreWater = true
    local result = workspace:Raycast(originPart.Position, targetPart.Position - originPart.Position, params)
    return result == nil
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
                            local distance = (Vector2.new(screenPos.X, screenPos.Y) - ScreenCenter).Magnitude
                            if distance <= FOV_RADIUS and distance < shortestDistance and IsVisibleCheck(targetPart) then
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

RunService.RenderStepped:Connect(function()
    if not ScreenGui or not ScreenGui.Parent then
        ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
    
    if thirdPersonActive then
        LocalPlayer.CameraMaxZoomDistance = 12
        LocalPlayer.CameraMinZoomDistance = 12
    end
    
    local myChar = LocalPlayer.Character
    if myChar then
        local myHumanoid = myChar:FindFirstChildOfClass("Humanoid")
        if myHumanoid then
            myHumanoid.WalkSpeed = 16 * speedMultiplier
            if bHopEnabled and myHumanoid.Health > 0 then
                local isInteracting = UserInputService:IsMouseButtonPressed(Enum.MouseButton1) or #UserInputService:GetTouches() > 0
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) or isInteracting then
                    if myHumanoid.FloorMaterial ~= Enum.Material.Air then
                        myHumanoid.Jump = true
                    end
                end
            end
        end
    end
    
    local activeScreenPlayers = {}
    local folder = getCharactersFolder()
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
                        local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
                        local dist = myHrp and (root.Position - myHrp.Position).Magnitude or 0
                        ApplyVisuals({Char = char, Root = root, Hum = hum, Player = player}, not IsVisibleCheck(root), dist)
                    end
                end
            end
        end
    end
    
    local targetPlayer = getClosestVisibleEnemy()
    if aimMode ~= "Выкл" and targetPlayer then
        FOVStroke.Color = Color3.fromRGB(0, 255, 0)
        local currentTargetPartName = aimTarget
        if aimMode == "Сайлент Аим" then
            currentTargetPartName = "Head"
        end
        
        local char = folder:FindFirstChild(targetPlayer.Name)
        if char then
            local _, _, root = ValidatedTarget(char)
            local targetPart = char:FindFirstChild(currentTargetPartName)
            if targetPart then
                if aimMode == "Обычный Аим" then
                    if UserInputService:IsMouseButtonPressed(Enum.MouseButton1) or #UserInputService:GetTouches() > 0 then
                        local targetDir = (targetPart.Position - Camera.CFrame.Position).Unit
                        Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, Camera.CFrame.Position + targetDir), AIM_SMOOTHNESS)
                    end
                elseif aimMode == "Сайлент Аим" then
                    Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetPart.Position)
                end
            end
        end
    else
        FOVStroke.Color = Color3.fromRGB(255, 0, 0)
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
