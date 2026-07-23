--[[
    Gravel.cc Legacy - Aimbot Module (Standalone for Block Strike)
    Вырезан и очищен от зависимостей. 
    Управление включается/выключается через _G.AimbotSettings.Enabled
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- НАСТРОЙКИ AIMBOT (Меняй эти значения под себя)
_G.AimbotSettings = {
    Enabled = false,           -- Вкл/Выкл (можешь менять через консоль или свой GUI)
    FOV_Size = 120,            -- Радиус круга захвата в пикселях
    Aim_Strength = 0.5,        -- Плавность (0 - без наводки, 1 - мгновенный снимок)
    Target_Part = "Head",      -- "Head", "HumanoidRootPart" или "Torso"
    Team_Mode = "Enemies",     -- "Enemies", "Teams" или "All"
    Wall_Check = false,        -- Проверка на видимость через стены
    Use_360_Aimbot = false,    -- Целится на 360 градусов (игнорирует FOV)
    Get_Target_Mode = "Closest" -- "Closest" или "Lowest Health"
}

-- Вспомогательные функции
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
    return Char:FindFirstChild(_G.AimbotSettings.Target_Part) or Char:FindFirstChild("Head")
end

local function wallCheck(TargetPos, OriginPos)
    if not _G.AimbotSettings.Wall_Check then return true end
    
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

-- Основной цикл Aim Assist
RunService.RenderStepped:Connect(function()
    local Settings = _G.AimbotSettings
    if not Settings.Enabled or not Camera then return end
    
    -- Убедимся, что персонаж жив
    local MyChar = LocalPlayer.Character
    if not MyChar or not isAlive(LocalPlayer) then return end
    
    local ViewportSize = Camera.ViewportSize
    local ScreenCenter = Vector2.new(ViewportSize.X / 2, ViewportSize.Y / 2)
    local CameraPos = Camera.CFrame.Position
    local FOV_Radius = Settings.FOV_Size
    
    local BestTarget = nil
    local BestValue = math.huge
    
    for _, Player in ipairs(Players:GetPlayers()) do
        if Player == LocalPlayer then continue end
        if not isAlive(Player) then continue end
        
        -- Проверка команды
        if Settings.Team_Mode == "Enemies" and isTeammate(Player) then continue end
        if Settings.Team_Mode == "Teams" and not isTeammate(Player) then continue end
        
        local TargetPart = getTargetPart(Player)
        if not TargetPart then continue end
        
        local ScreenPos, OnScreen = Camera:WorldToViewportPoint(TargetPart.Position)
        local ScreenVec = Vector2.new(ScreenPos.X, ScreenPos.Y)
        local DistanceFromCenter = (ScreenVec - ScreenCenter).Magnitude
        
        -- Проверка FOV (кроме 360 режима)
        if not Settings.Use_360_Aimbot then
            if not OnScreen or DistanceFromCenter > FOV_Radius then continue end
        end
        
        -- Wall Check
        if not wallCheck(TargetPart.Position, CameraPos) then continue end
        
        -- Выбор цели
        local Humanoid = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
        local CurrentValue = math.huge
        
        if Settings.Get_Target_Mode == "Lowest Health" then
            CurrentValue = Humanoid and Humanoid.Health or math.huge
        else -- Closest (Distance)
            CurrentValue = (CameraPos - TargetPart.Position).Magnitude
        end
        
        if CurrentValue < BestValue then
            BestValue = CurrentValue
            BestTarget = TargetPart
        end
    end
    
    -- Применение наводки
    if BestTarget then
        local CurrentCF = Camera.CFrame
        local TargetCF = CFrame.lookAt(CurrentCF.Position, BestTarget.Position)
        local Strength = math.clamp(Settings.Aim_Strength, 0, 1)
        
        if Strength >= 1 then
            Camera.CFrame = TargetCF -- Мгновенный захват (жёсткий аим)
        else
            Camera.CFrame = CurrentCF:Lerp(TargetCF, Strength) -- Плавная наводка
        end
    end
end)

print("Aim Assist Module Loaded. Use _G.AimbotSettings.Enabled = true to activate.")
