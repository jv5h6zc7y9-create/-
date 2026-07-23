--[[
    Block Strike Ultimate - MOBILE EDITION (iPad/iPhone)
    AIM + SILENT + WH + FOV CIRCLE + TOUCH MENU
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ==================== НАСТРОЙКИ ====================
local Settings = {
    SilentAim = false,
    AimAssist = false,
    WallCheck = true,
    
    FOV = 120,
    Smoothness = 0.4,
    TargetPart = "Head",
    TeamMode = "Enemies",
    HitChance = 100,
    
    FOV_Active = Color3.fromRGB(255, 255, 0),
    FOV_Idle = Color3.fromRGB(255, 50, 50)
}

-- ==================== СОЗДАНИЕ UI (КНОПКИ НА ЭКРАНЕ) ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MobileMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

-- Стиль кнопки
local function createButton(Name, Text, Position, Color)
    local Btn = Instance.new("TextButton")
    Btn.Name = Name
    Btn.Size = UDim2.new(0, 55, 0, 55)
    Btn.Position = Position
    Btn.BackgroundColor3 = Color or Color3.fromRGB(30, 30, 30)
    Btn.Text = Text
    Btn.TextSize = 24
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.BorderSizePixel = 0
    Btn.Parent = ScreenGui
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 12)
    Corner.Parent = Btn
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Thickness = 2
    Stroke.Color = Color3.fromRGB(255, 255, 255)
    Stroke.Transparency = 0.5
    Stroke.Parent = Btn
    
    return Btn
end

-- Кнопки в левом верхнем углу (как джойстик)
local SilentBtn = createButton("Silent", "🎯", UDim2.new(0, 15, 0, 100), Color3.fromRGB(40, 40, 40))
local AimBtn = createButton("Aim", "👁", UDim2.new(0, 15, 0, 165), Color3.fromRGB(40, 40, 40))
local WHBtn = createButton("WH", "🧱", UDim2.new(0, 15, 0, 230), Color3.fromRGB(40, 40, 40))
local PartBtn = createButton("Part", "💀", UDim2.new(0, 15, 0, 295), Color3.fromRGB(40, 40, 40))

-- FOV слайдер (горизонтальная полоска снизу)
local FOV_Slider = Instance.new("Frame")
FOV_Slider.Name = "FOV_Slider"
FOV_Slider.Size = UDim2.new(0, 200, 0, 8)
FOV_Slider.Position = UDim2.new(0.5, -100, 1, -80)
FOV_Slider.AnchorPoint = Vector2.new(0.5, 0)
FOV_Slider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
FOV_Slider.BorderSizePixel = 0
FOV_Slider.Parent = ScreenGui

local FOV_Corner = Instance.new("UICorner")
FOV_Corner.CornerRadius = UDim.new(0, 4)
FOV_Corner.Parent = FOV_Slider

local FOV_Knob = Instance.new("TextButton")
FOV_Knob.Name = "Knob"
FOV_Knob.Size = UDim2.new(0, 24, 0, 24)
FOV_Knob.AnchorPoint = Vector2.new(0.5, 0.5)
FOV_Knob.Position = UDim2.new(Settings.FOV / 300, 0, 0.5, 0)
FOV_Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
FOV_Knob.Text = ""
FOV_Knob.BorderSizePixel = 0
FOV_Knob.Parent = FOV_Slider

local FOV_KnobCorner = Instance.new("UICorner")
FOV_KnobCorner.CornerRadius = UDim.new(0, 12)
FOV_KnobCorner.Parent = FOV_Knob

local FOV_Label = Instance.new("TextLabel")
FOV_Label.Name = "FOV_Label"
FOV_Label.Size = UDim2.new(1, 0, 0, 20)
FOV_Label.Position = UDim2.new(0, 0, 0, -25)
FOV_Label.BackgroundTransparency = 1
FOV_Label.Text = "FOV: " .. Settings.FOV
FOV_Label.TextColor3 = Color3.fromRGB(255, 255, 255)
FOV_Label.TextSize = 14
FOV_Label.Font = Enum.Font.GothamBold
FOV_Label.Parent = FOV_Slider

-- ==================== FOV КРУГ ====================
local FOV_Circle = Instance.new("Frame")
FOV_Circle.Name = "FOV_Circle"
FOV_Circle.AnchorPoint = Vector2.new(0.5, 0.5)
FOV_Circle.Size = UDim2.new(0, Settings.FOV * 2, 0, Settings.FOV * 2)
FOV_Circle.Position = UDim2.new(0.5, 0, 0.5, 0)
FOV_Circle.BackgroundTransparency = 0.92
FOV_Circle.BackgroundColor3 = Settings.FOV_Idle
FOV_Circle.BorderSizePixel = 0
FOV_Circle.Visible = false
FOV_Circle.Parent = ScreenGui

local FOV_CircleCorner = Instance.new("UICorner")
FOV_CircleCorner.CornerRadius = UDim.new(1, 0)
FOV_CircleCorner.Parent = FOV_Circle

local FOV_CircleStroke = Instance.new("UIStroke")
FOV_CircleStroke.Thickness = 2
FOV_CircleStroke.Color = Settings.FOV_Idle
FOV_CircleStroke.Parent = FOV_Circle

-- ==================== ЛОГИКА СЛАЙДЕРА ====================
local dragging = false

FOV_Knob.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.Touch then
        local mousePos = UserInputService:GetMouseLocation()
        local barPos = FOV_Slider.AbsolutePosition.X
        local barWidth = FOV_Slider.AbsoluteSize.X
        local percent = math.clamp((mousePos.X - barPos) / barWidth, 0, 1)
        
        Settings.FOV = math.floor(30 + percent * 270) -- 30-300
        FOV_Knob.Position = UDim2.new(percent, 0, 0.5, 0)
        FOV_Label.Text = "FOV: " .. Settings.FOV
        FOV_Circle.Size = UDim2.new(0, Settings.FOV * 2, 0, Settings.FOV * 2)
    end
end)

-- ==================== ОБРАБОТЧИКИ КНОПОК ====================
local function updateButtonColor(btn, state)
    if state then
        btn.BackgroundColor3 = Color3.fromRGB(0, 180, 80) -- Зеленый
    else
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40) -- Серый
    end
end

SilentBtn.MouseButton1Click:Connect(function()
    Settings.SilentAim = not Settings.SilentAim
    updateButtonColor(SilentBtn, Settings.SilentAim)
end)

AimBtn.MouseButton1Click:Connect(function()
    Settings.AimAssist = not Settings.AimAssist
    updateButtonColor(AimBtn, Settings.AimAssist)
end)

WHBtn.MouseButton1Click:Connect(function()
    Settings.WallCheck = not Settings.WallCheck
    updateButtonColor(WHBtn, Settings.WallCheck)
end)

PartBtn.MouseButton1Click:Connect(function()
    local parts = {"Head", "HumanoidRootPart", "Torso"}
    local current = table.find(parts, Settings.TargetPart) or 1
    Settings.TargetPart = parts[current % #parts + 1]
    
    -- Меняем иконку
    if Settings.TargetPart == "Head" then
        PartBtn.Text = "💀"
    elseif Settings.TargetPart == "HumanoidRootPart" then
        PartBtn.Text = "🦴"
    else
        PartBtn.Text = "🩻"
    end
end)

-- ==================== ФУНКЦИИ ====================
local function isTeammate(Player)
    if LocalPlayer.Team and Player.Team then
        return LocalPlayer.Team == Player.Team
    end
    return false
end

local function isAlive(Player)
    local Char = Player.Character
    if not Char then return false end
    local Hum = Char:FindFirstChildOfClass("Humanoid")
    return Hum and Hum.Health > 0
end

local function getTargetPart(Player)
    local Char = Player.Character
    if not Char then return nil end
    return Char:FindFirstChild(Settings.TargetPart) or Char:FindFirstChild("Head")
end

local function wallCheck(TargetPos, OriginPos)
    if not Settings.WallCheck then return true end
    
    local Direction = (TargetPos - OriginPos)
    local Ray = Ray.new(OriginPos, Direction.Unit * Direction.Magnitude)
    local IgnoreList = {LocalPlayer.Character}
    
    for _, Pl in ipairs(Players:GetPlayers()) do
        if Pl.Character then
            table.insert(IgnoreList, Pl.Character)
        end
    end
    
    local Hit = Workspace:FindPartOnRayWithIgnoreList(Ray, IgnoreList)
    return Hit == nil
end

local function findBestTarget()
    if not Camera or not LocalPlayer.Character then return nil, nil end
    
    local CameraPos = Camera.CFrame.Position
    local ViewportSize = Camera.ViewportSize
    local Center = Vector2.new(ViewportSize.X / 2, ViewportSize.Y / 2)
    
    local BestTarget = nil
    local BestPart = nil
    local BestDistance = math.huge
    
    for _, Pl in ipairs(Players:GetPlayers()) do
        if Pl == LocalPlayer then continue end
        if not isAlive(Pl) then continue end
        
        if Settings.TeamMode == "Enemies" and isTeammate(Pl) then continue end
        if Settings.TeamMode == "Teams" and not isTeammate(Pl) then continue end
        
        local Part = getTargetPart(Pl)
        if not Part then continue end
        
        local ScreenPos, OnScreen = Camera:WorldToViewportPoint(Part.Position)
        if not OnScreen then continue end
        
        local ScreenVec = Vector2.new(ScreenPos.X, ScreenPos.Y)
        local DistFromCenter = (ScreenVec - Center).Magnitude
        
        if DistFromCenter > Settings.FOV then continue end
        if not wallCheck(Part.Position, CameraPos) then continue end
        
        local WorldDist = (CameraPos - Part.Position).Magnitude
        if WorldDist < BestDistance then
            BestDistance = WorldDist
            BestTarget = Pl
            BestPart = Part
        end
    end
    
    return BestTarget, BestPart
end

-- ==================== SILENT AIM ====================
local OldNamecall
OldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local Method = getnamecallmethod()
    local Args = {...}
    
    if Settings.SilentAim and Method == "FindPartOnRayWithIgnoreList" then
        if math.random(1, 100) <= Settings.HitChance then
            local Target, TargetPart = findBestTarget()
            
            if Target and TargetPart then
                local OriginalRay = Args[1]
                local Origin = OriginalRay.Origin
                local NewDirection = (TargetPart.Position - Origin).Unit * OriginalRay.Direction.Magnitude
                Args[1] = Ray.new(Origin, NewDirection)
                
                return OldNamecall(self, table.unpack(Args))
            end
        end
    end
    
    return OldNamecall(self, ...)
end)

-- ==================== AIM ASSIST + ОТРИСОВКА ====================
RunService.RenderStepped:Connect(function()
    -- Позиция FOV круга (с учетом выреза камеры на iPad)
    if Camera then
        local Insets = game:GetService("GuiService"):GetGuiInset()
        FOV_Circle.Position = UDim2.new(0.5, 0, 0.5, Insets.Y / 2)
    end
    
    FOV_Circle.Visible = Settings.SilentAim or Settings.AimAssist
    if not FOV_Circle.Visible then return end
    
    local Target, TargetPart = findBestTarget()
    
    -- Цвет круга
    if Target then
        FOV_CircleStroke.Color = Settings.FOV_Active
        FOV_Circle.BackgroundColor3 = Settings.FOV_Active
    else
        FOV_CircleStroke.Color = Settings.FOV_Idle
        FOV_Circle.BackgroundColor3 = Settings.FOV_Idle
    end
    
    -- Плавный Aim Assist
    if Settings.AimAssist and Target and TargetPart and LocalPlayer.Character then
        local Hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if Hum and Hum.Health > 0 then
            local TargetCF = CFrame.lookAt(Camera.CFrame.Position, TargetPart.Position)
            Camera.CFrame = Camera.CFrame:Lerp(TargetCF, Settings.Smoothness)
        end
    end
end)

print("✅ MOBILE VERSION LOADED - Tap buttons to control!")
