-- СОЗДАНИЕ ИНТЕРФЕЙСА (Сенсорное меню для iPad с новыми функциями)
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local AimButton = Instance.new("TextButton")
local EspButton = Instance.new("TextButton")
local HoleButton = Instance.new("TextButton")
local AntiGrabButton = Instance.new("TextButton")
local FovPlusButton = Instance.new("TextButton")
local FovMinusButton = Instance.new("TextButton")

ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

MainFrame.Name = "iPadDeltaMenuFinalVersion"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Position = UDim2.new(0.05, 0, 0.25, 0)
MainFrame.Size = UDim2.new(0, 260, 0, 395) -- Увеличена высота под кнопку Анти-Хвата
MainFrame.Active = true
MainFrame.Draggable = true 

Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Title.Text = "IPAD FT&P ULTIMATE v6"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.SourceSansBold

local function styleButton(btn, text, posY, sizeX, posX)
    btn.Parent = MainFrame
    btn.Size = UDim2.new(sizeX or 0.9, 0, 0, 45)
    btn.Position = UDim2.new(posX or 0.05, 0, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 15
    btn.Font = Enum.Font.SourceSansBold
end

styleButton(AimButton, "1. Сверх-Хват + Аим [ВЫКЛ]", 65)
styleButton(EspButton, "2. Границы Бокса [ВЫКЛ]", 120)
styleButton(HoleButton, "3. Физическая Дыра [ВЫКЛ]", 175)
styleButton(AntiGrabButton, "4. Анти-Хват [ВЫКЛ]", 230)
-- Кнопки изменения размера центрального круга (FOV)
styleButton(FovPlusButton, "FOV +", 290, 0.42, 0.05)
styleButton(FovMinusButton, "FOV -", 290, 0.42, 0.53)

-- СЕРВИСЫ ROBLOX
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- НАСТРОЙКИ ФУНКЦИЙ
local States = { SilentAim = false, ShowEsp = false, BlackHole = false, AntiGrab = false }
local Config = { SilentAimFov = 200, ThrowForce = 999999, HoleSpeed = 140, HoleRadius = 300 }
local EspObjects = {}

-- СОЗДАНИЕ КРУГА СТРОГО ПОСЕРЕДИНЕ ЭКРАНА IPAD
local FovCircle = Drawing.new("Circle")
FovCircle.Visible = false
FovCircle.Thickness = 2.5
FovCircle.Color = Color3.fromRGB(255, 50, 50)
FovCircle.Radius = Config.SilentAimFov
FovCircle.Filled = false
FovCircle.NumSides = 64

-- Обновление позиции круга строго в центре экрана каждый кадр
RunService.RenderStepped:Connect(function()
    if States.SilentAim then
        -- Рассчитываем точные координаты центра экрана iPad
        local centerScreen = Camera.ViewportSize / 2
        FovCircle.Position = Vector2.new(centerScreen.X, centerScreen.Y)
        FovCircle.Radius = Config.SilentAimFov
        FovCircle.Visible = true
    else
        FovCircle.Visible = false
    end
end)

-- ДИНАМИЧЕСКИЙ ПОИСК ЦЕЛИ СТРОГО ВНУТРИ ЦЕНТРАЛЬНОГО КРУГА ЭКРАНА
local function GetClosestPlayerInCenterCircle()
    local closestPlayer = nil
    local shortestDistance = Config.SilentAimFov -- Ограничение по радиусу круга
    local centerScreen = Camera.ViewportSize / 2

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            local human = player.Character:FindFirstChild("Humanoid")
            
            if root and human and human.Health > 0 then
                local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
                
                if onScreen then
                    -- Считаем расстояние от ЦЕНТРА экрана до игрока
                    local distance = (Vector2.new(centerScreen.X, centerScreen.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                    
                    -- Захват срабатывает, только если игрок находится внутри границ круга
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

-- ФУНКЦИЯ ОБНОВЛЕНИЯ 3D БОКСОВ (ГРАНИЦ) ДЛЯ ИГРОКОВ ВНУТРИ ЦЕНТРАЛЬНОГО КРУГА
local function UpdateEsp()
    local currentTarget = GetClosestPlayerInCenterCircle()

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            
            if root and States.ShowEsp then
                if not EspObjects[player] then
                    local box = Instance.new("BoxHandleAdornment")
                    box.Name = "FTP_BOX_CENTER_SYSTEM"
                    box.Size = player.Character:GetExtentsSize() + Vector3.new(0.4, 0.4, 0.4)
                    box.Color3 = Color3.fromRGB(255, 0, 0)
                    box.Transparency = 0.6
                    box.AlwaysOnTop = true
                    box.ZIndex = 10
                    box.Adornee = player.Character
                    box.Parent = player.Character
                    EspObjects[player] = box
                else
                    EspObjects[player].Size = player.Character:GetExtentsSize() + Vector3.new(0.4, 0.4, 0.4)
                    
                    -- Если игрок попал строго в центральный круг на экране, его бокс становится зеленым
                    if currentTarget == player then
                        EspObjects[player].Color3 = Color3.fromRGB(0, 255, 0)
                        EspObjects[player].Transparency = 0.4
                    else
                        EspObjects[player].Color3 = Color3.fromRGB(255, 0, 0)
                        EspObjects[player].Transparency = 0.7
                    end
                end
            else
                if EspObjects[player] then
                    EspObjects[player]:Destroy()
                    EspObjects[player] = nil
                end
            end
        end
    end
end

-- Удаление индикаторов боксов при выходе игрока
Players.PlayerRemoving:Connect(function(player)
    if EspObjects[player] then
        EspObjects[player]:Destroy()
        EspObjects[player] = nil
    end
end)

-- ОБРАБОТКА ОРИГИНАЛЬНОЙ КНОПКИ БРОСКА ДЛЯ СУПЕР-ЗАПУСКА ИЗ ЦЕНТРА ЭКРАНА
UserInputService.InputBegan:Connect(function(input, processed)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton2 then
        if States.SilentAim then
            local target = GetClosestPlayerInCenterCircle()
            
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                local targetHrp = target.Character.HumanoidRootPart
                
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

-- ХУКИ СВЕРХ-ХВАТА ДЛЯ ДИСТАНЦИОННОГО ЗАХВАТА ИГРОКОВ В ЦЕНТРАЛЬНОМ КРУГЕ
local oldIndex
oldIndex = hookmetamethod(game, "__index", function(self, key)
    if States.SilentAim and not checkcaller() then
        if key == "Hit" or key == "Target" then
            local dynamicTarget = GetClosestPlayerInCenterCircle()
            
            if dynamicTarget and dynamicTarget.Character and dynamicTarget.Character:FindFirstChild("HumanoidRootPart") then
                if key == "Hit" then
                    return dynamicTarget.Character.HumanoidRootPart.CFrame
                elseif key == "Target" then
                    -- Игра считывает хват точно по центру круга прицела
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
        local dynamicTarget = GetClosestPlayerInCenterCircle()
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

-- ФИЗИЧЕСКИЙ ЦИКЛ ЧЕРНОЙ ДЫРЫ И ФУНКЦИИ АНТИ-ХВАТА (ANTI-GRAB)
RunService.Heartbeat:Connect(function()
    UpdateEsp() -- Отрисовка боксов
    
    local myChar = LocalPlayer.Character
    local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHrp then return end

    -- ЛОГИКА АНТИ-ХВАТА (Запускается каждый кадр физики, если включен)
    if States.AntiGrab then
        for _, obj in pairs(myChar:GetDescendants()) do
            -- Очищает все виды веревок, физических захватов, лучей, которые сервер пытается прикрепить к вам
            if obj:IsA("Weld") or obj:IsA("WeldConstraint") or obj:IsA("RopeConstraint") or obj:IsA("NoCollisionConstraint") or obj:IsA("BodyPosition") or obj:IsA("BodyVelocity") or obj:IsA("RocketPropulsion") then
                -- Если это не элементы вашей внутренней одежды или анимации — мгновенно удаляем захват врага
                if obj.Name ~= "Neck" and obj.Name ~= "RootJoint" and not obj.Parent:IsA("Accessory") then
                    obj:Destroy()
                end
            end
        end
        
        -- Принудительное обнуление сторонней скорости (если вас пытаются запустить)
        if myHrp.AssemblyLinearVelocity.Magnitude > 100 then
            myHrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        end
    end
    
    -- ЛОГИКА ЗАСАСЫВАНИЯ ЧЕРНОЙ ДЫРЫ
    if States.BlackHole then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local tHrp = player.Character:FindFirstChild("HumanoidRootPart")
                local tHum = player.Character:FindFirstChild("Humanoid")
                
                if tHrp and tHum and tHum.Health > 0 then
                    local distance = (myHrp.Position - tHrp.Position).Magnitude
                    
                    if distance < Config.HoleRadius then
                        for _, part in pairs(player.Character:GetChildren()) do
                            if part:IsA("BasePart") then
                                part.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
                            end
                        end
                        
                        local direction = (myHrp.Position - tHrp.Position).Unit
                        tHrp.AssemblyLinearVelocity = direction * Config.HoleSpeed
                    end
                end
            end
        end
    end
end)

-- НАСТРОЙКА КНОПОК ИНТЕРФЕЙСА ДЛЯ IPAD
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
    HoleButton.Text = "3. Физическая Дыра " .. (States.BlackHole and "[ВКЛ]" or "[ВЫКЛ]")
    HoleButton.BackgroundColor3 = States.BlackHole and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 50)
end)

AntiGrabButton.MouseButton1Click:Connect(function()
    States.AntiGrab = not States.AntiGrab
    AntiGrabButton.Text = "4. Анти-Хват " .. (States.AntiGrab and "[ВКЛ]" or "[ВЫКЛ]")
    AntiGrabButton.BackgroundColor3 = States.AntiGrab and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 50)
end)

-- РЕГУЛИРОВКА РАДИУСА ЦЕНТРАЛЬНОГО КРУГА
FovPlusButton.MouseButton1Click:Connect(function()
    Config.SilentAimFov = Config.SilentAimFov + 25
    if Config.SilentAimFov > 700 then Config.SilentAimFov = 700 end
end)

FovMinusButton.MouseButton1Click:Connect(function()
    Config.SilentAimFov = Config.SilentAimFov - 25
    if Config.SilentAimFov < 50 then Config.SilentAimFov = 50 end
end)

print("[Delta Ultimate Central Circle & Anti-Grab Loaded Successfully]")
