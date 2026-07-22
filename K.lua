-- ====================================================================
-- BLOXSTRIKE REWRITTEN ENGINE FIX (MIRAGE UPDATE)
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

-- ТАБЛИЦА НАСТРОЕК
local Settings = {
    SilentAim = false,
    ShowFov = false,
    EspBoxes = false,
    SilentAimFov = 200
}

-- Очистка старых интерфейсов
if CoreGui:FindFirstChild("BloxStrikeAbsoluteFix") then
    CoreGui:FindFirstChild("BloxStrikeAbsoluteFix"):Destroy()
end

-- ====================================================================
-- ПРОФЕССИОНАЛЬНОЕ GUI МЕНЮ ДЛЯ IPAD
-- ====================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BloxStrikeAbsoluteFix"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
MainFrame.Position = UDim2.new(0.05, 0, 0.25, 0)
MainFrame.Size = UDim2.new(0, 260, 0, 340)
MainFrame.Active = true
MainFrame.Draggable = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 2
MainStroke.Color = Color3.fromRGB(45, 45, 55)
MainStroke.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
Title.Text = "BLOXSTRIKE ABSOLUTE FIX"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 15
Title.Font = Enum.Font.SourceSansBold

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = Title

local function styleButton(btn, text, posY, sizeX, posX)
    btn.Parent = MainFrame
    btn.Size = UDim2.new(sizeX or 0.9, 0, 0, 45)
    btn.Position = UDim2.new(posX or 0.05, 0, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(240, 240, 240)
    btn.TextSize = 14
    btn.Font = Enum.Font.SourceSansBold
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = btn
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Thickness = 1
    Stroke.Color = Color3.fromRGB(55, 55, 70)
    Stroke.Parent = btn
end

local AimBtn = Instance.new("TextButton")
local FovBtn = Instance.new("TextButton")
local EspBtn = Instance.new("TextButton")
local FovPlus = Instance.new("TextButton")
local FovMinus = Instance.new("TextButton")

styleButton(AimBtn, "1. Исправленный Аим [ВЫКЛ]", 60)
styleButton(FovBtn, "2. Границы FOV (Круг) [ВЫКЛ]", 115)
styleButton(EspBtn, "3. Настоящий Валхак (ESP) [ВЫКЛ]", 170)

styleButton(FovPlus, "FOV +", 230, 0.42, 0.05)
styleButton(FovMinus, "FOV -", 230, 0.42, 0.53)

local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size = UDim2.new(0.9, 0, 0, 25)
InfoLabel.Position = UDim2.new(0.05, 0, 0, 295)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Text = "FOV Радиус: " .. tostring(Settings.SilentAimFov)
InfoLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
InfoLabel.TextSize = 13
InfoLabel.Font = Enum.Font.SourceSansItalic
InfoLabel.Parent = MainFrame

-- ====================================================================
-- ПОДСВЕТКА КРУГА FOV
-- ====================================================================
local FovCircle = Drawing.new("Circle")
FovCircle.Visible = false
FovCircle.Thickness = 2
FovCircle.Color = Color3.fromRGB(0, 180, 255)
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
-- ГЛУБОКОЕ СКАНИРОВАНИЕ ИГРОКОВ (ОБХОД СКРЫТИЯ МОДЕЛЕЙ В BLOXSTRIKE)
-- ====================================================================
local function GetRealEnemyPart()
    local closestTarget = nil
    local shortestDistance = Settings.SilentAimFov
    local centerScreen = Camera.ViewportSize / 2

    -- Сканируем не только игроков, но и кастомные папки workspace, куда игра прячет хитбоксы
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") then
            local rootPart = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Head") or obj:FindFirstChildOfClass("BasePart")
            local human = obj:FindFirstChild("Humanoid")
            
            -- Проверяем, что это не наш персонаж и модель живая
            if rootPart and human and human.Health > 0 and not obj:IsDescendantOf(LocalPlayer.Character) then
                -- Привязка к игроку Roblox для проверки на команду (Team Check)
                local targetPlayer = Players:GetPlayerFromCharacter(obj)
                if not targetPlayer or targetPlayer.Team ~= LocalPlayer.Team then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                    
                    if onScreen then
                        local distance = (Vector2.new(centerScreen.X, centerScreen.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                        if distance < shortestDistance then
                            closestTarget = rootPart
                            shortestDistance = distance
                        end
                    end
                end
            end
        end
    end
    return closestTarget
end

-- ====================================================================
-- ИСПРАВЛЕННЫЙ СВЕРХСКОРОСТНОЙ АИМ ЧЕРЕЗ ИЗМЕНЕНИЕ ПАКЕТОВ КАМЕРЫ
-- ====================================================================
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if Settings.SilentAim and not checkcaller() then
        if method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList" or method == "Raycast" then
            local realTargetPart = GetRealEnemyPart()
            if realTargetPart then
                if method == "Raycast" then
                    args = (realTargetPart.Position - args).Unit * 1000
                else
                    args = Ray.new(args.Origin, (realTargetPart.Position - args.Origin).Unit * 1000)
                end
            end
        end
    end
    return oldNamecall(self, unpack(args))
end)

local oldIndex
oldIndex = hookmetamethod(game, "__index", function(self, key)
    if Settings.SilentAim and not checkcaller() and (key == "Hit" or key == "Target") then
        local realTargetPart = GetRealEnemyPart()
        if realTargetPart then
            if key == "Hit" then
                return realTargetPart.CFrame
            elseif key == "Target" then
                return realTargetPart
            end
        end
    end
    return oldIndex(self, key)
end)

-- ====================================================================
-- АБСОЛЮТНОЕ 2D ЭКРАННОЕ ESP (РАБОТАЕТ СКВОЗЬ СТЕНЫ НА ЛЮБЫХ КАРТАХ)
-- ====================================================================
local ActiveEspBoxes = {}

RunService.RenderStepped:Connect(function()
    -- Очищаем старые рамки каждый кадр, чтобы они не зависали на экране iPad
    for _, box in pairs(ActiveEspBoxes) do
        box.Visible = false
    end

    if not Settings.EspBoxes then return end

    local boxIndex = 1
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and not obj:IsDescendantOf(LocalPlayer.Character) then
            local root = obj:FindFirstChild("HumanoidRootPart")
            local human = obj:FindFirstChild("Humanoid")
            
            if root and human and human.Health > 0 then
                local playerInstance = Players:GetPlayerFromCharacter(obj)
                if not playerInstance or playerInstance.Team ~= LocalPlayer.Team then
                    
                    local rootPos, onScreen = Camera:WorldToViewportPoint(root.Position)
                    
                    if onScreen then
                        -- Рассчитываем размер 2D рамки на экране на основе дистанции до врага
                        local scale = 1000 / rootPos.Z
                        local width, height = 2.2 * scale, 3.5 * scale
                        
                        -- Создаем или берем уже существующую рамку из пула памяти
                        local box = ActiveEspBoxes[boxIndex]
                        if not box then
                            box = Drawing.new("Square")
                            box.Thickness = 2
                            box.Color = Color3.fromRGB(255, 0, 50) -- Красный цвет ВХ
                            box.Filled = false
                            ActiveEspBoxes[boxIndex] = box
                        end
                        
                        box.Size = Vector2.new(width, height)
                        box.Position = Vector2.new(rootPos.X - width / 2, rootPos.Y - height / 2)
                        box.Visible = true
                        
                        boxIndex = boxIndex + 1
                    end
                end
            end
        end
    end
end)

-- ====================================================================
-- НАСТРОЙКА КНОПОК
-- ====================================================================
local function toggleVisual(btn, state, text)
    if state then
        btn.Text = text .. " [ВКЛ]"
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 130, 70)}):Play()
    else
        btn.Text = text .. " [ВЫКЛ]"
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 45)}):Play()
    end
end

AimBtn.MouseButton1Click:Connect(function()
    Settings.SilentAim = not Settings.SilentAim
    toggleVisual(AimBtn, Settings.SilentAim, "1. Исправленный Аим")
end)

FovBtn.MouseButton1Click:Connect(function()
    Settings.ShowFov = not Settings.ShowFov
    toggleVisual(FovBtn, Settings.ShowFov, "2. Границы FOV (Круг)")
end)

EspBtn.MouseButton1Click:Connect(function()
    Settings.EspBoxes = not Settings.EspBoxes
    toggleVisual(EspBtn, Settings.EspBoxes, "3. Настоящий Валхак (ESP)")
end)

FovPlus.MouseButton1Click:Connect(function()
    if Settings.SilentAimFov < 500 then
        Settings.SilentAimFov = Settings.SilentAimFov + 25
        InfoLabel.Text = "FOV Радиус: " .. tostring(Settings.SilentAimFov)
    end
end)

FovMinus.MouseButton1Click:Connect(function()
    if Settings.SilentAimFov > 50 then
        Settings.SilentAimFov = Settings.SilentAimFov - 25
        InfoLabel.Text = "FOV Радиус: " .. tostring(Settings.SilentAimFov)
    end
end)

print("[Delta iOS Fix]: Скрипт успешно перезапущен с обходом защиты!")
