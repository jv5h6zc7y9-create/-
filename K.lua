-- BloxStrike Advanced Mobile Framework for Delta Executor
-- Fully self-contained implementation with zero placeholder blocks.

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Feature State Flags
local Config = {
    ESPEnabled = false,
    SilentAimEnabled = false,
    SkinChangerEnabled = false,
    FOVValue = 100,
}

-- Cleanup Registry
local ActiveHighlights = {}
local Connections = {}

-- Create Custom GUI Elements
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BloxStrikeMobileMenu"
ScreenGui.ResetOnSpawn = false
pcall(function()
    ScreenGui.Parent = CoreGui
end)
if ScreenGui.Parent == nil then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 280, 0, 360)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(45, 45, 55)
MainStroke.Thickness = 1.5
MainStroke.Parent = MainFrame

local MainGradient = Instance.new("UIGradient")
MainGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 32)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 12, 16))
})
MainGradient.Rotation = 45
MainGradient.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 0, 45)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "BLOXSTRIKE // MOBILE"
TitleLabel.TextColor3 = Color3.fromRGB(240, 240, 250)
TitleLabel.TextSize = 14
TitleLabel.Parent = MainFrame

local function CreateMenuButton(name, positionY, defaultText)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(0.85, 0, 0, 42)
    btn.Position = UDim2.new(0.075, 0, 0, positionY)
    btn.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
    btn.Font = Enum.Font.GothamMedium
    btn.Text = defaultText
    btn.TextColor3 = Color3.fromRGB(200, 200, 210)
    btn.TextSize = 12
    btn.Parent = MainFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(50, 50, 65)
    stroke.Thickness = 1
    stroke.Parent = btn

    return btn
end

local EspButton = CreateMenuButton("ESPButton", 55, "ESP: OFF")
local AimButton = CreateMenuButton("AimButton", 108, "Silent Aim: OFF")
local SkinButton = CreateMenuButton("SkinButton", 161, "Skin Changer: OFF")

-- FOV Controls Container
local FovContainer = Instance.new("Frame")
FovContainer.Size = UDim2.new(0.85, 0, 0, 42)
FovContainer.Position = UDim2.new(0.075, 0, 0, 214)
FovContainer.BackgroundTransparency = 1
FovContainer.Parent = MainFrame

local FovLabel = Instance.new("TextLabel")
FovLabel.Size = UDim2.new(0.5, 0, 1, 0)
FovLabel.BackgroundTransparency = 1
FovLabel.Font = Enum.Font.GothamMedium
FovLabel.Text = "FOV: 100"
FovLabel.TextColor3 = Color3.fromRGB(200, 200, 210)
FovLabel.TextSize = 12
FovLabel.Parent = FovContainer

local MinusBtn = Instance.new("TextButton")
MinusBtn.Size = UDim2.new(0, 38, 0, 38)
MinusBtn.Position = UDim2.new(0.55, 0, 0.05, 0)
MinusBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
MinusBtn.Text = "-"
MinusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinusBtn.TextSize = 16
MinusBtn.Parent = FovContainer
Instance.new("UICorner", MinusBtn).CornerRadius = UDim.new(0, 8)

local PlusBtn = Instance.new("TextButton")
PlusBtn.Size = UDim2.new(0, 38, 0, 38)
PlusBtn.Position = UDim2.new(0.78, 0, 0.05, 0)
PlusBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
PlusBtn.Text = "+"
PlusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
PlusBtn.TextSize = 16
PlusBtn.Parent = FovContainer
Instance.new("UICorner", PlusBtn).CornerRadius = UDim.new(0, 8)

local CloseBtn = CreateMenuButton("CloseButton", 280, "Unload Menu")
CloseBtn.BackgroundColor3 = Color3.fromRGB(60, 20, 25)

-- Drawing Native Circle Configuration
local FovCircle = Drawing.new("Circle")
FovCircle.Visible = true
FovCircle.Filled = false
FovCircle.Color = Color3.fromRGB(255, 255, 255)
FovCircle.Transparency = 0.7
FovCircle.Thickness = 1
FovCircle.Radius = Config.FOVValue
FovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

-- Team-Agnostic Highlight ESP Routine
local function UpdateESP()
    if not Config.ESPEnabled then
        for _, h in pairs(ActiveHighlights) do
            if h then h:Destroy() end
        end
        ActiveHighlights = {}
        return
    end

    local currentModels = {}
    for _, descendant in ipairs(Workspace:GetDescendants()) do
        if descendant:IsA("Model") and descendant:FindFirstChildOfClass("Humanoid") then
            local hum = descendant:FindFirstChildOfClass("Humanoid")
            local root = descendant:FindFirstChild("HumanLoop") or descendant.PrimaryPart or descendant:FindFirstChild("HumanoidRootPart")
            
            if hum and hum.Health > 0 and descendant ~= LocalPlayer.Character then
                currentModels[descendant] = true
                local highlight = ActiveHighlights[descendant]
                if not highlight then
                    highlight = Instance.new("Highlight")
                    highlight.Adornee = descendant
                    highlight.FillColor = Color3.fromRGB(255, 40, 40)
                    highlight.FillTransparency = 0.4
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.OutlineTransparency = 0
                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    highlight.Parent = ScreenGui
                    ActiveHighlights[descendant] = highlight
                end
            end
        end
    end

    for model, hObj in pairs(ActiveHighlights) do
        if not currentModels[model] or not model.Parent then
            if hObj then hObj:Destroy() end
            ActiveHighlights[model] = nil
        end
    end
end

-- Silent Aim Target Utility
local function GetClosestTargetInFOV()
    local bestTarget = nil
    local shortestDistance = Config.FOVValue
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local char = player.Character
            local hum = char:FindFirstChildOfClass("Humanoid")
            local head = char:FindFirstChild("Head")
            
            if hum and hum.Health > 0 and head then
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local screenVector = Vector2.new(screenPos.X, screenPos.Y)
                    local distance = (screenVector - screenCenter).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        bestTarget = head
                    end
                end
            end
        end
    end
    return bestTarget
end

-- Metamethod Hooking for Silent Aim
local oldIndex
oldIndex = hookmetamethod(game, "__index", function(self, key)
    if Config.SilentAimEnabled and not checkcaller() then
        if (key == "Hit" or key == "Target") then
            local targetHead = GetClosestTargetInFOV()
            if targetHead then
                local predictedPos = targetHead.Position + (targetHead.AssemblyLinearVelocity * 0.05)
                if key == "Hit" then
                    return CFrame.new(predictedPos)
                else
                    return targetHead
                end
            end
        end
    end
    return oldIndex(self, key)
end)

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    if Config.SilentAimEnabled and not checkcaller() then
        if method == "FindPartOnRay" or method == "Raycast" then
            local args = {...}
            local targetHead = GetClosestTargetInFOV()
            if targetHead and args[1] then
                local origin = args[1].Origin or args[2]
                if typeof(origin) == "Vector3" then
                    local predictedPos = targetHead.Position + (targetHead.AssemblyLinearVelocity * 0.05)
                    local newDir = (predictedPos - origin).Unit * 1000
                    if method == "FindPartOnRay" then
                        args[1] = Ray.new(origin, newDir)
                    elseif method == "Raycast" then
                        args[2] = newDir
                    end
                    return oldNamecall(self, unpack(args))
                end
            end
        end
    end
    return oldNamecall(self, ...)
end)

-- Local Skin Changer Background Framework
Connections.SkinLoop = task.spawn(function()
    while task.wait(0.5) do
        if Config.SkinChangerEnabled and LocalPlayer.Character then
            for _, item in ipairs(LocalPlayer.Character:GetChildren()) do
                if item:IsA("Tool") then
                    for _, part in ipairs(item:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.Color = Color3.fromRGB(120, 80, 200)
                        end
                    end
                end
            end
        end
    end
end)

-- RenderStepped Visual Updates & FOV Tracking
Connections.Render = RunService.RenderStepped:Connect(function()
    FovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FovCircle.Radius = Config.FOVValue
    FovCircle.Visible = Config.SilentAimEnabled
    if Config.ESPEnabled then
        UpdateESP()
    end
end)

-- Button Event Handlers
EspButton.MouseButton1Click:Connect(function()
    Config.ESPEnabled = not Config.ESPEnabled
    EspButton.Text = Config.ESPEnabled and "ESP: ON" or "ESP: OFF"
    EspButton.TextColor3 = Config.ESPEnabled and Color3.fromRGB(80, 255, 80) or Color3.fromRGB(200, 200, 210)
    if not Config.ESPEnabled then UpdateESP() end
end)

AimButton.MouseButton1Click:Connect(function()
    Config.SilentAimEnabled = not Config.SilentAimEnabled
    AimButton.Text = Config.SilentAimEnabled and "Silent Aim: ON" or "Silent Aim: OFF"
    AimButton.TextColor3 = Config.SilentAimEnabled and Color3.fromRGB(80, 255, 80) or Color3.fromRGB(200, 200, 210)
end)

SkinButton.MouseButton1Click:Connect(function()
    Config.SkinChangerEnabled = not Config.SkinChangerEnabled
    SkinButton.Text = Config.SkinChangerEnabled and "Skin Changer: ON" or "Skin Changer: OFF"
    SkinButton.TextColor3 = Config.SkinChangerEnabled and Color3.fromRGB(80, 255, 80) or Color3.fromRGB(200, 200, 210)
end)

PlusBtn.MouseButton1Click:Connect(function()
    Config.FOVValue = math.min(Config.FOVValue + 10, 400)
    FovLabel.Text = "FOV: " .. tostring(Config.FOVValue)
end)

MinusBtn.MouseButton1Click:Connect(function()
    Config.FOVValue = math.max(Config.FOVValue - 10, 20)
    FovLabel.Text = "FOV: " .. tostring(Config.FOVValue)
end)

CloseBtn.MouseButton1Click:Connect(function()
    Config.ESPEnabled = false
    Config.SilentAimEnabled = false
    Config.SkinChangerEnabled = false
    UpdateESP()
    if Connections.Render then Connections.Render:Disconnect() end
    FovCircle:Remove()
    ScreenGui:Destroy()
end)

-- Реализация плавного перетаскивания (Drag) интерфейса для сенсорных экранов
local Dragging = false
local DragInput = nil
local DragStart = nil
local StartPosition = nil

local function UpdateDrag(input)
    local delta = input.Position - DragStart
    MainFrame.Position = UDim2.new(
        StartPosition.X.Scale, 
        StartPosition.X.Offset + delta.X, 
        StartPosition.Y.Scale, 
        StartPosition.Y.Offset + delta.Y
    )
end

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        Dragging = true
        DragStart = input.Position
        StartPosition = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                Dragging = false
            end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        DragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == DragInput and Dragging then
        UpdateDrag(input)
    end
end)

-- Инициализация и авто-очистка при удалении персонажа
LocalPlayer.CharacterRemoving:Connect(function()
    if Config.ESPEnabled then
        for model, highlight in pairs(ActiveHighlights) do
            if highlight then highlight:Destroy() end
        end
        ActiveHighlights = {}
    end
end)

-- Финальный вывод в лог Delta Executor о завершении загрузки
print("[BloxStrike Mobile Framework]: Loaded successfully.")
