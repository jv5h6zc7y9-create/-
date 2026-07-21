-- Создание GUI интерфейса (Крупные элементы для сенсора iPad)
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local AimButton = Instance.new("TextButton")
local ThrowButton = Instance.new("TextButton")
local HoleButton = Instance.new("TextButton")

ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

MainFrame.Name = "iPadDeltaMenuComplete"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Position = UDim2.new(0.05, 0, 0.25, 0)
MainFrame.Size = UDim2.new(0, 250, 0, 280)
MainFrame.Active = true
MainFrame.Draggable = true 

Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Title.Text = "IPAD FULL EXPLOIT"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.Font = Enum.Font.SourceSansBold

local function styleButton(btn, text, posY)
    btn.Parent = MainFrame
    btn.Size = UDim2.new(0.9, 0, 0, 50)
    btn.Position = UDim2.new(0.05, 0, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    btn.Text = text .. " [ВЫКЛ]"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 16
    btn.Font = Enum.Font.SourceSansBold
end

styleButton(AimButton, "1. Silent Aim", 65)
styleButton(ThrowButton, "2. Super Throw", 130)
styleButton(HoleButton, "3. BlackHole + Kill", 195)

-- ОСНОВНЫЕ СЕРВИСЫ ROBLOX
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- СОСТОЯНИЯ И НАСТРОЙКИ
local States = { SilentAim = false, SuperThrow = false, BlackHole = false }
local Config = { SilentAimFov = 350, ThrowForce = 999999, HoleSpeed = 160, HoleRadius = 250 }

-- 1. ПОЛНАЯ ФУНКЦИЯ НАХОЖДЕНИЯ БЛИЖАЙШЕГО ИГРОКА ДЛЯ АИМА (FOV СКАНИРОВАНИЕ)
local function GetClosestPlayerToTouch()
    local closestPlayer = nil
    local shortestDistance = Config.SilentAimFov
    local touchPos = UserInputService:GetMouseLocation()

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            local human = player.Character:FindFirstChild("Humanoid")
            
            if root and human and human.Health > 0 then
                -- Переводим 3D координаты игрока в 2D пиксели экрана iPad
                local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
                
                if onScreen then
                    -- Считаем расстояние от центра тапа до игрока
                    local distance = (Vector2.new(touchPos.X, touchPos.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
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

-- 2. ПОЛНЫЙ ХУК МЕТАМЕТОДОВ ДЛЯ SILENT AIM (ПОДМЕНА НАПРАВЛЕНИЯ ИГРЫ)
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    -- Если Аим включен и игра пытается пустить луч/бросок из камеры или мыши
    if States.SilentAim and (method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList" or method == "Raycast") then
        local target = GetClosestPlayerToTouch()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            -- Перезаписываем направление луча строго в голову или торс цели
            local targetPart = target.Character.HumanoidRootPart
            if method == "Raycast" then
                args[2] = (targetPart.Position - args[1]).Unit * 1000
            else
                args[1] = Ray.new(args[1].Origin, (targetPart.Position - args[1].Origin).Unit * 1000)
            end
        end
    end
    return oldNamecall(self, unpack(args))
end)

local oldIndex
oldIndex = hookmetamethod(game, "__index", function(self, key)
    -- Подмена координат виртуального курсора для бросков в Delta
    if States.SilentAim and (key == "Hit" or key == "Target") and not checkcaller() then
        local target = GetClosestPlayerToTouch()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            if key == "Hit" then
                return target.Character.HumanoidRootPart.CFrame
            elseif key == "Target" then
                return target.Character.HumanoidRootPart
            end
        end
    end
    return oldIndex(self, key)
end)

-- 3. ПОЛНАЯ ФУНКЦИЯ СУПЕР-БРОСКА ЗА КАРТУ (ДЛЯ СЕНСОРА IPAD)
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    -- Срабатывает, когда вы касаетесь экрана пальцем
    if input.UserInputType == Enum.UserInputType.Touch and States.SuperThrow then
        local target = GetClosestPlayerToTouch()
        
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local targetHrp = target.Character.HumanoidRootPart
            
            -- Отключение коллизии (чтобы цель гарантированно улетела сквозь стены)
            for _, part in pairs(target.Character:GetChildren()) do
                if part:IsA("BasePart") then 
                    part.CanCollide = false 
                end
            end
            
            -- Создание мощного вектора скорости
            local velocityInstance = Instance.new("LinearVelocity")
            local attachment = Instance.new("Attachment")
            
            attachment.Parent = targetHrp
            velocityInstance.MaxForce = math.huge
            -- Запуск происходит по направлению взгляда камеры iPad
            velocityInstance.VectorVelocity = Camera.CFrame.LookVector * Config.ThrowForce
            velocityInstance.Attachment0 = attachment
            velocityInstance.Parent = targetHrp
            
            -- Удаление вектора через 0.2 сек, когда цель уже набрала скорость света
            task.wait(0.2)
            velocityInstance:Destroy()
            attachment:Destroy()
        end
    end
end)

-- 4. ПОЛНАЯ ФУНКЦИЯ ЧЕРНОЙ ДЫРЫ И АВТО-УБИЙСТВА (VOID KILL)
RunService.Heartbeat:Connect(function()
    if not States.BlackHole then return end
    
    local myChar = LocalPlayer.Character
    local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHrp then return end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local tHrp = player.Character:FindFirstChild("HumanoidRootPart")
            local tHum = player.Character:FindFirstChild("Humanoid")
            
            if tHrp and tHum and tHum.Health > 0 then
                -- Вычисляем дистанцию между вами и жертвой
                local distance = (myHrp.Position - tHrp.Position).Magnitude
                
                if distance < Config.HoleRadius then
                    -- Если затянуло вплотную (радиус 15 единиц) -> МГНОВЕННЫЙ КИЛЛ
                    if distance < 15 then
                        -- Телепортация под карту в зону смерти Roblox (Void)
                        tHrp.CFrame = CFrame.new(tHrp.Position.X, -1500, tHrp.Position.Z)
                        tHrp.AssemblyLinearVelocity = Vector3.new(0, -500, 0)
                    else
                        -- Если далеко -> СТЯГИВАНИЕ в эпицентр
                        local direction = (myHrp.Position - tHrp.Position).Unit
                        tHrp.AssemblyLinearVelocity = direction * Config.HoleSpeed
                    end
                end
            end
        end
    end
end)

-- ПОДКЛЮЧЕНИЕ КНОПОК ИНТЕРФЕЙСА
AimButton.MouseButton1Click:Connect(function()
    States.SilentAim = not States.SilentAim
    AimButton.Text = "1. Silent Aim " .. (States.SilentAim and "[ВКЛ]" or "[ВЫКЛ]")
    AimButton.BackgroundColor3 = States.SilentAim and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(55, 55, 55)
end)

ThrowButton.MouseButton1Click:Connect(function()
    States.SuperThrow = not States.SuperThrow
    ThrowButton.Text = "2. Super Throw " .. (States.SuperThrow and "[ВКЛ]" or "[ВЫКЛ]")
    ThrowButton.BackgroundColor3 = States.SuperThrow and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(55, 55, 55)
end)

HoleButton.MouseButton1Click:Connect(function()
    States.BlackHole = not States.BlackHole
    HoleButton.Text = "3. BlackHole + Kill " .. (States.BlackHole and "[ВКЛ]" or "[ВЫКЛ]")
    HoleButton.BackgroundColor3 = States.BlackHole and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(55, 55, 55)
end)

print("[Delta iPad Uncut Script Loaded!]")
