local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Settings = {
    AimEnabled = true,
    TargetPart = "Head",
    FovRadius = 150,
    FovColor = Color3.fromRGB(255, 255, 255),
    EspVisible = Color3.fromRGB(0, 255, 0),
    EspHidden = Color3.fromRGB(255, 0, 0)
}

-- Безопасное создание FOV круга
local FovCircle = Drawing.new("Circle")
FovCircle.Thickness = 1
FovCircle.NumSides = 32
FovCircle.Filled = false
FovCircle.Transparency = 0.7
FovCircle.Color = Settings.FovColor
FovCircle.Radius = Settings.FovRadius
FovCircle.Visible = true

-- Функция очистки при выгрузке скрипта
local function Cleanup()
    if FovCircle then
        FovCircle:Remove()
    end
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChild("EspHighlight") then
            p.Character.EspHighlight:Destroy()
        end
    end
end

-- Обновление позиции FOV
local function UpdateFovPosition()
    local screenSize = Camera.ViewportSize
    FovCircle.Position = Vector2.new(screenSize.X / 2, screenSize.Y / 2)
end

-- Проверка видимости с защитой от nil
local function IsVisible(targetPart, character)
    local localChar = LocalPlayer.Character
    if not localChar or not localChar:FindFirstChild("HumanoidRootPart") then return false end
    
    local origin = Camera.CFrame.Position
    local direction = targetPart.Position - origin
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {localChar, character}
    raycastParams.IgnoreWater = true
    
    local result = workspace:Raycast(origin, direction, raycastParams)
    return result == nil
end

-- Поиск цели (с проверкой видимости)
local function GetClosestPlayerInFov()
    local target, minDistance = nil, Settings.FovRadius
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild(Settings.TargetPart) then
            local part = p.Character[Settings.TargetPart]
            local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
            
            if onScreen and IsVisible(part, p.Character) then
                local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                if dist < minDistance then 
                    minDistance = dist
                    target = part 
                end
            end
        end
    end
    return target
end

-- Оптимизированный ESP (обновление реже, чем каждый кадр)
local lastUpdate = 0
local function ManageEsp()
    if tick() - lastUpdate < 0.1 then return end -- Обновляем раз в 100 мс вместо 60 раз в секунду
    lastUpdate = tick()

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local char = p.Character
            local head = char:FindFirstChild("Head")
            
            local highlight = char:FindFirstChild("EspHighlight")
            if not highlight then
                highlight = Instance.new("Highlight")
                highlight.Name = "EspHighlight"
                highlight.FillTransparency = 0.5
                highlight.OutlineTransparency = 0.2
                highlight.Parent = char
            end
            
            if head and IsVisible(head, char) then
                highlight.FillColor = Settings.EspVisible
                highlight.OutlineColor = Settings.EspVisible
            else
                highlight.FillColor = Settings.EspHidden
                highlight.OutlineColor = Settings.EspHidden
            end
        end
    end
end

-- Основной цикл
RunService.Heartbeat:Connect(function()
    UpdateFovPosition()
    ManageEsp()
    
    if Settings.AimEnabled then
        getgenv().SilentTarget = GetClosestPlayerInFov()
    end
end)
