-- Полный оптимизированный скрипт для Delta iOS (Roblox)
-- Использование ScreenGui гарантирует отображение круга FOV на мобильных эксплойтах

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Настройки
local Settings = {
    AimEnabled = true,
    TargetPart = "Head",
    FovRadius = 150,     -- Размер круга (диаметр будет умножаться на 2)
    FovColor = Color3.fromRGB(255, 255, 255),
    EspVisible = Color3.fromRGB(0, 255, 0),    -- Зеленый (виден)
    EspHidden = Color3.fromRGB(255, 0, 0)     -- Красный (за стеной)
}

-- Очистка старого интерфейса при перезапуске скрипта
if CoreGui:FindFirstChild("DeltaFovContainer") then
    CoreGui.DeltaFovContainer:Destroy()
end

-- Создание UI-контейнера для круга FOV (совместимо с мобильными эксплойтами)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaFovContainer"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local FovFrame = Instance.new("Frame")
FovFrame.Name = "FovCircle"
FovFrame.AnchorPoint = Vector2.new(0.5, 0.5)
FovFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
FovFrame.Size = UDim2.new(0, Settings.FovRadius * 2, 0, Settings.FovRadius * 2)
FovFrame.BackgroundTransparency = 1
FovFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(1, 0)
UICorner.Parent = FovFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Settings.FovColor
UIStroke.Thickness = 1.5
UIStroke.Transparency = 0.3
UIStroke.Parent = FovFrame

-- Обновление размера и позиции FOV
local function UpdateFovPosition()
    FovFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    FovFrame.Size = UDim2.new(0, Settings.FovRadius * 2, 0, Settings.FovRadius * 2)
end

-- Проверка видимости игрока (Рэйкаст) с защитой от nil
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

-- Функция поиска цели для Сайлент Аима (внутри FOV и с проверкой видимости)
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

-- Управление ESP (ВХ) подсветкой с оптимизацией по времени
local lastUpdate = 0
local function ManageEsp()
    if tick() - lastUpdate < 0.1 then return end -- Снижает нагрузку на мобильный процессор
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

-- Основной цикл работы скрипта
RunService.Heartbeat:Connect(function()
    UpdateFovPosition()
    ManageEsp()
    
    if Settings.AimEnabled then
        getgenv().SilentTarget = GetClosestPlayerInFov()
    end
end)
