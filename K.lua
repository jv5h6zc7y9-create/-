-- ====================================================================
-- BLOXSTRIKE ULTIMATE FPS EXPLOIT V1 (MIRAGE EDITION)
-- FULLY OPTIMIZED FOR DELTA EXECUTOR (iOS / iPAD)
-- ====================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ГЛОБАЛЬНАЯ ТАБЛИЦА НАСТРОЕК
local Settings = {
    SilentAim = false,
    ShowFov = false,
    EspBoxes = false,
    NoRecoil = false,
    SilentAimFov = 180,
    AimPart = "Head" -- Цель: Голова
}

-- Очистка старых версий скрипта
if CoreGui:FindFirstChild("BloxStrikeDeltaMenu") then
    CoreGui:FindFirstChild("BloxStrikeDeltaMenu"):Destroy()
end

-- ====================================================================
-- СОЗДАНИЕ ИНТЕРФЕЙСА GUI (Оптимизировано под iPad)
-- ====================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BloxStrikeDeltaMenu"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
MainFrame.Position = UDim2.new(0.05, 0, 0.25, 0)
MainFrame.Size = UDim2.new(0, 260, 0, 395)
MainFrame.Active = true
MainFrame.Draggable = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 2
MainStroke.Color = Color3.fromRGB(50, 50, 60)
MainStroke.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
Title.Text = "BLOXSTRIKE DELTA V1"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.SourceSansBold

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = Title

local function styleButton(btn, text, posY, sizeX, posX)
    btn.Parent = MainFrame
    btn.Size = UDim2.new(sizeX or 0.9, 0, 0, 45)
    btn.Position = UDim2.new(posX or 0.05, 0, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(220, 220, 220)
    btn.TextSize = 14
    btn.Font = Enum.Font.SourceSansBold
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = btn
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Thickness = 1
    Stroke.Color = Color3.fromRGB(60, 60, 75)
    Stroke.Parent = btn
end

local AimBtn = Instance.new("TextButton")
local EspBtn = Instance.new("TextButton")
local RecoilBtn = Instance.new("TextButton")
local FovBtn = Instance.new("TextButton")
local FovPlus = Instance.new("TextButton")
local FovMinus = Instance.new("TextButton")

styleButton(AimBtn, "1. Silent Aim [ВЫКЛ]", 60)
styleButton(FovBtn, "2. Показать Круг FOV [ВЫКЛ]", 115)
styleButton(EspBtn, "3. Валхак (ESP Boxes) [ВЫКЛ]", 170)
styleButton(RecoilBtn, "4. Анти-Отдача (Лазер) [ВЫКЛ]", 225)

styleButton(FovPlus, "FOV +", 285, 0.42, 0.05)
styleButton(FovMinus, "FOV -", 285, 0.42, 0.53)

local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size = UDim2.new(0.9, 0, 0, 25)
InfoLabel.Position = UDim2.new(0.05, 0, 0, 350)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Text = "FOV Радиус: " .. tostring(Settings.SilentAimFov)
InfoLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
InfoLabel.TextSize = 13
InfoLabel.Font = Enum.Font.SourceSansItalic
InfoLabel.Parent = MainFrame

-- ====================================================================
-- ВИЗУАЛИЗАЦИЯ КРУГА FOV НА СЕРЕДИНЕ ЭКРАНА IPAD
-- ====================================================================
local FovCircle = Drawing.new("Circle")
FovCircle.Visible = false
FovCircle.Thickness = 2
FovCircle.Color = Color3.fromRGB(255, 80, 80)
FovCircle.Radius = Settings.SilentAimFov
FovCircle.Filled = false
FovCircle.NumSides = 64

RunService.RenderStepped:Connect(function()
    if Settings.ShowFov then
        local centerScreen = Camera.ViewportSize / 2
        FovCircle.Position = Vector2.new(centerScreen.X, centerScreen.Y)
        FovCircle.Radius = Settings.SilentAimFov
        FovCircle.Visible = true
    else
        FovCircle.Visible = false
    end
end)

-- ====================================================================
-- ФУНКЦИЯ ПОИСКА БЛИЖАЙШЕГО ВРАГА (ФИЛЬТРАЦИЯ ПО КОМАНДАМ)
-- ====================================================================
local function GetClosestEnemyInFov()
    local closestTarget = nil
    local shortestDistance = Settings.SilentAimFov
    local centerScreen = Camera.ViewportSize / 2

    for _, player in pairs(Players:GetPlayers()) do
        -- Проверка: не я сам, у игрока есть персонаж и он живой
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local head = player.Character:FindFirstChild("Head")
            local human = player.Character:FindFirstChild("Humanoid")
            
            -- Проверка на команду (Team Check), чтобы не аимить в своих
            if head and human and human.Health > 0 and player.Team ~= LocalPlayer.Team then
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                
                if onScreen then
                    local distance = (Vector2.new(centerScreen.X, centerScreen.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                    if distance < shortestDistance then
                        closestTarget = player.Character
                        shortestDistance = distance
                    end
                end
            end
        end
    end
    return closestTarget
end

-- ====================================================================
-- ХУК МЕТАМЕТОДОВ ДЛЯ SILENT AIM (ПОДМЕНА НАПРАВЛЕНИЯ ПУЛЬ)
-- ====================================================================
local oldIndex
oldIndex = hookmetamethod(game, "__index", function(self, key)
    if Settings.SilentAim and not checkcaller() then
        if key == "Hit" or key == "Target" then
            local enemyChar = GetClosestEnemyInFov()
            if enemyChar and enemyChar:FindFirstChild(Settings.AimPart) then
                local targetPart = enemyChar[Settings.AimPart]
                if key == "Hit" then
                    return targetPart.CFrame
                elseif key == "Target" then
                    return targetPart
                end
            end
        end
    end
    return oldIndex(self, key)
end)

-- ====================================================================
-- ЦИКЛ СТРЕЛЬБЫ ЛАЗЕРОМ (АНТИ-ОТДАТА) И ОБНОВЛЕНИЯ ESP СТЕН
-- ====================================================================
local EspTable = {}

RunService.Heartbeat:Connect(function()
    -- 1. ЛОГИКА АНТИ-ОТДАТЫ (No Recoil & No Spread)
    if Settings.NoRecoil then
        -- Скрипт находит локальные модули оружия в камере или персонаже и обнуляет переменные отдачи
        pcall(function()
            local currentWeapon = Camera:FindFirstChildOfClass("Model") or LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if currentWeapon and currentWeapon:FindFirstChild("Configuration") then
                for _, val in pairs(currentWeapon.Configuration:GetChildren()) do
                    if val.Name:find("Recoil") or val.Name:find("Spread") or val.Name:find("Inaccuracy") then
                        val.Value = 0
                    end
                end
            end
        end)
    end

    -- 2. ЛОГИКА ВАЛХАКА (ESP BOXES)
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local root = player.Character.HumanoidRootPart
            local hum = player.Character:FindFirstChild("Humanoid")
            
            if root and hum and hum.Health > 0 and Settings.EspBoxes and player.Team ~= LocalPlayer.Team then
                if not EspTable[player] then
                    local box = Instance.new("BoxHandleAdornment")
                    box.Name = "BloxStrike_ESP_System"
                    box.Size = player.Character:GetExtentsSize() + Vector3.new(0.2, 0.2, 0.2)
                    box.Color3 = Color3.fromRGB(255, 0, 0) -- Красный для врагов
                    box.Transparency = 0.6
                    box.AlwaysOnTop = true -- Видно сквозь стены Mirage
                    box.ZIndex = 5
                    box.Adornee = player.Character
                    box.Parent = player.Character
                    EspTable[player] = box
                else
                    EspTable[player].Size = player.Character:GetExtentsSize() + Vector3.new(0.2, 0.2, 0.2)
                end
            else
                if EspTable[player] then
                    EspTable[player]:Destroy()
                    EspTable[player] = nil
                end
            end
        end
    end
end)

-- Очистка кэша ESP при выходе игрока
Players.PlayerRemoving:Connect(function(player)
    if EspTable[player] then
        EspTable[player]:Destroy()
        EspTable[player] = nil
    end
end)

-- ====================================================================
-- ЛОГИКА КНОПОК ИНТЕРФЕЙСА ПЛАНШЕТА
-- ====================================================================
local function toggleVisual(btn, state, text)
    if state then
        btn.Text = text .. " [ВКЛ]"
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 130, 70)}):Play()
    else
        btn.Text = text .. " [ВЫКЛ]"
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 48)}):Play()
    end
end

AimBtn.MouseButton1Click:Connect(function()
    Settings.SilentAim = not Settings.SilentAim
    toggleVisual(AimBtn, Settings.SilentAim, "1. Silent Aim")
end)

FovBtn.MouseButton1Click:Connect(function()
    Settings.ShowFov = not Settings.ShowFov
    toggleVisual(FovBtn, Settings.ShowFov, "2. Показать Круг FOV")
end)

EspBtn.MouseButton1Click:Connect(function()
    Settings.EspBoxes = not Settings.EspBoxes
    toggleVisual(EspBtn, Settings.EspBoxes, "3. Валхак (ESP Boxes)")
end)

RecoilBtn.MouseButton1Click:Connect(function()
    Settings.NoRecoil = not Settings.NoRecoil
    toggleVisual(RecoilBtn, Settings.NoRecoil, "4. Анти-Отдача (Лазер)")
end)

FovPlus.MouseButton1Click:Connect(function()
    if Settings.SilentAimFov < 500 then
        Settings.SilentAimFov = Settings.SilentAimFov + 20
        InfoLabel.Text = "FOV Радиус: " .. tostring(Settings.SilentAimFov)
    end
end)

FovMinus.MouseButton1Click:Connect(function()
    if Settings.SilentAimFov > 40 then
        Settings.SilentAimFov = Settings.SilentAimFov - 20
        InfoLabel.Text = "FOV Радиус: " .. tostring(Settings.SilentAimFov)
    end
end)

print("[Delta iOS]: Скрипт для BloxStrike успешно активирован!")
