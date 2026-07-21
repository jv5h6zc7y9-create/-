-- СОЗДАНИЕ ИНТЕРФЕЙСА (Сенсорное меню для iPad)
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local AimButton = Instance.new("TextButton")
local EspButton = Instance.new("TextButton")
local HoleButton = Instance.new("TextButton")

ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

MainFrame.Name = "iPadDeltaMenuFinalAbsolute"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Position = UDim2.new(0.05, 0, 0.25, 0)
MainFrame.Size = UDim2.new(0, 260, 0, 280)
MainFrame.Active = true
MainFrame.Draggable = true 

Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Title.Text = "IPAD FT&P FIXED v5"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.SourceSansBold

local function styleButton(btn, text, posY)
    btn.Parent = MainFrame
    btn.Size = UDim2.new(0.9, 0, 0, 50)
    btn.Position = UDim2.new(0.05, 0, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.Text = text .. " [ВЫКЛ]"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 15
    btn.Font = Enum.Font.SourceSansBold
end

styleButton(AimButton, "1. Сверх-Хват + Аим", 65)
styleButton(EspButton, "2. Границы Бокса Аима", 130)
styleButton(HoleButton, "3. Черная Дыра (Сбор)", 195)

-- СЕРВИСЫ ROBLOX
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- НАСТРОЙКИ ФУНКЦИЙ
local States = { SilentAim = false, ShowEsp = false, BlackHole = false }
local Config = { MaxTargetDistance = 350, ThrowForce = 999999, HoleSpeed = 120, HoleRadius = 250 }
local EspObjects = {}

-- 1. ДИНАМИЧЕСКИЙ ПОИСК БЛИЖАЙШЕЙ ЦЕЛИ РЯДОМ С ТАЧЕМ СЕНСОРА БЕЗ ЗАЛИПАНИЙ
local function GetCurrentClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = Config.MaxTargetDistance
    local touchPos = UserInputService:GetMouseLocation()

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            local human = player.Character:FindFirstChild("Humanoid")
            
            if root and human and human.Health > 0 then
                local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
                
                if onScreen then
                    -- Вычисляем реальное расстояние от пальца до игрока на экране iPad
                    local distance = (Vector2.new(touchPos.X, touchPos.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                    
                    -- Проверяем, входит ли цель в рамки лимита FOV
                    if distance < shortestDistance then
                        closestPlayer = player
                        shortestDistance = distance
                    end
                end
            end
        end
    end
    return closestPlayer
end

-- 2. ФУНКЦИЯ КВАДРАТНЫХ ГРАНИЦ БОКСА (BOX ESP)
local function UpdateEsp()
    local currentTarget = GetCurrentClosestPlayer()

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            
            if root and States.ShowEsp then
                -- Если бокс еще не создан для игрока, создаем его 3D каркас
                if not EspObjects[player] then
                    local box = Instance.new("BoxHandleAdornment")
                    box.Name = "FTP_BOX_DYN"
                    box.Size = player.Character:GetExtentsSize() + Vector3.new(0.4, 0.4, 0.4)
                    box.Color3 = Color3.fromRGB(255, 0, 0) -- По умолчанию красный (просто игрок)
                    box.Transparency = 0.6
                    box.AlwaysOnTop = true
                    box.ZIndex = 10
                    box.Adornee = player.Character
                    box.Parent = player.Character
                    EspObjects[player] = box
                else
                    -- Обновляем размер бокса под движения игрока
                    EspObjects[player].Size = player.Character:GetExtentsSize() + Vector3.new(0.4, 0.4, 0.4)
                    
                    -- Если этот игрок стал ближайшим к вашему прицелу/пальцу (попал в границы Сайлент Аима)
                    if currentTarget == player then
                        EspObjects[player].Color3 = Color3.fromRGB(0, 255, 0) -- Зеленый бокс (Готов к захвату)
                        EspObjects[player].Transparency = 0.4
                    else
                        EspObjects[player].Color3 = Color3.fromRGB(255, 0, 0) -- Красный (вне зоны Аима)
                        EspObjects[player].Transparency = 0.7
                    end
                end
            else
                -- Если кнопка выключена, мгновенно стираем все боксы
                if EspObjects[player] then
                    EspObjects[player]:Destroy()
                    EspObjects[player] = nil
                end
            end
        end
    end
end

-- Очистка памяти при выходе игроков
Players.PlayerRemoving:Connect(function(player)
    if EspObjects[player] then
        EspObjects[player]:Destroy()
        EspObjects[player] = nil
    end
end)

-- 3. ПЕРЕХВАТ ОРИГИНАЛЬНОЙ КНОПКИ БРОСКА ДЛЯ СУПЕР-ЗАПУСКА ПО НАПРАВЛЕНИЮ КАМЕРЫ
UserInputService.InputBegan:Connect(function(input, processed)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton2 then
        if States.SilentAim then
            local target = GetCurrentClosestPlayer()
            
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                local targetHrp = target.Character.HumanoidRootPart
                
                -- Отключаем коллизию деталей, чтобы цель гарантированно улетела без застреваний
                for _, part in pairs(target.Character:GetChildren()) do
                    if part:IsA("BasePart") then 
                        part.CanCollide = false 
                    end
                end
                
                local velocityInstance = Instance.new("LinearVelocity")
                local attachment = Instance.new("Attachment")
                
                attachment.Parent = targetHrp
                velocityInstance.MaxForce = math.huge
                velocityInstance.VectorVelocity = Camera.CFrame.LookVector * Config.ThrowForce
                velocityInstance.Attachment0 = attachment
                velocityInstance.Parent = targetHrp
                
                task.wait(0.2)
                velocityInstance:Destroy()
                attachment:Destroy()
            end
        end
    end
end)

-- 4. ХУКИ НА ДИСТАНЦИОННЫЙ СВЕРХ-ХВАТ (ПОДМЕНА СВОЙСТВ ТАЧПАДА / МЫШИ)
local oldIndex
oldIndex = hookmetamethod(game, "__index", function(self, key)
    if States.SilentAim and not checkcaller() then
        if key == "Hit" or key == "Target" then
            local dynamicTarget = GetCurrentClosestPlayer()
            
            if dynamicTarget and dynamicTarget.Character and dynamicTarget.Character:FindFirstChild("HumanoidRootPart") then
                if key == "Hit" then
                    return dynamicTarget.Character.HumanoidRootPart.CFrame
                elseif key == "Target" then
                    -- Возвращаем цель Аима, чтобы игра позволила схватить игрока, даже если вы нажали рядом с ним
                    return dynamicTarget.Character.HumanoidRootPart
                end
            end
        end
    end
    return oldIndex(self, key)
end)

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if States.SilentAim and (method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList" or method == "Raycast") then
        local dynamicTarget = GetCurrentClosestPlayer()
        if dynamicTarget and dynamicTarget.Character and dynamicTarget.Character:FindFirstChild("HumanoidRootPart") then
            local targetPart = dynamicTarget.Character.HumanoidRootPart
            if method == "Raycast" then
                args = (targetPart.Position - args).Unit * 1000
            else
                args = Ray.new(args.Origin, (targetPart.Position - args.Origin).Unit * 1000)
            end
        end
    end
    return oldNamecall(self, unpack(args))
end)

-- 5. ИСПРАВЛЕННЫЙ ЦИКЛ ЧЕРНОЙ ДЫРЫ (БЕЗ ИСЧЕЗНОВЕНИЯ ИГРОКОВ)
RunService.Heartbeat:Connect(function()
    UpdateEsp() -- Постоянное сканирование игроков и обновление Боксов на экране iPad
    
    if not States.BlackHole then return end
    
    local myChar = LocalPlayer.Character
    local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHrp then return end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local tHrp = player.Character:FindFirstChild("HumanoidRootPart")
            local tHum = player.Character:FindFirstChild("Humanoid")
            
            if tHrp and tHum and tHum.Health > 0 then
                local distance = (myHrp.Position - tHrp.Position).Magnitude
                
                -- Игроки просто стягиваются к вам. Удаление (телепорт под карту) вырезано, чтобы убрать баг исчезновения
                if distance < Config.HoleRadius then
                    local direction = (myHrp.Position - tHrp.Position).Unit
                    tHrp.AssemblyLinearVelocity = direction * Config.HoleSpeed
                end
            end
        end
    end
end)

-- ПОДКЛЮЧЕНИЕ НАЖАТИЙ НА КНОПКИ МЕНЮ ДЛЯ IPAD
AimButton.MouseButton1Click:Connect(function()
    States.SilentAim = not States.SilentAim
    AimButton.Text = "1. Сверх-Хват + Аим " .. (States.SilentAim and "[ВКЛ]" or "[ВЫКЛ]")
    AimButton.BackgroundColor3 = States.SilentAim and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 50)
end)

EspButton.MouseButton1Click:Connect(function()
    States.ShowEsp = not States.ShowEsp
    EspButton.Text = "2. Границы Бокса " .. (States.ShowEsp and "[ПОКАЗАТЬ]" or "[СКРЫТЬ]")
    EspButton.BackgroundColor3 = States.ShowEsp and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 50)
end)

HoleButton.MouseButton1Click:Connect(function()
    States.BlackHole = not States.BlackHole
    HoleButton.Text = "3. Черная Дыра (Сбор) " .. (States.BlackHole and "[ВКЛ]" or "[ВЫКЛ]")
    HoleButton.BackgroundColor3 = States.BlackHole and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 50)
end)

print("[Delta iPad Script Configured. Anti-Vanishing Code Loaded.]")
