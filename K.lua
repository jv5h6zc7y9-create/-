-- СОЗДАНИЕ ИНТЕРФЕЙСА (Крупное меню под пальцы на iPad)
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local AimButton = Instance.new("TextButton")
local FovVisualButton = Instance.new("TextButton")
local HoleButton = Instance.new("TextButton")

ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

MainFrame.Name = "iPadDeltaMenuFinal"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Position = UDim2.new(0.05, 0, 0.25, 0)
MainFrame.Size = UDim2.new(0, 260, 0, 280)
MainFrame.Active = true
MainFrame.Draggable = true 

Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Title.Text = "IPAD FT&P EXPLOIT"
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

styleButton(AimButton, "1. Silent Aim", 65)
styleButton(FovVisualButton, "2. Границы FOV (Круг)", 130)
styleButton(HoleButton, "3. BlackHole + Kill", 195)

-- СЕРВИСЫ И КОНФИГУРАЦИЯ
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local States = { SilentAim = false, ShowFov = false, BlackHole = false }
local Config = { SilentAimFov = 280, ThrowForce = 999999, HoleSpeed = 160, HoleRadius = 250 }

-- ОПТИМИЗИРОВАННЫЙ КРУГ ДЛЯ ОТПРАВКИ ГРАНИЦ FOV НА ЭКРАН IPAD
local FovCircle = Drawing.new("Circle")
FovCircle.Visible = false
FovCircle.Thickness = 2.5
FovCircle.Color = Color3.fromRGB(255, 60, 60)
FovCircle.Radius = Config.SilentAimFov
FovCircle.Filled = false
FovCircle.NumSides = 64

RunService.RenderStepped:Connect(function()
    if States.ShowFov then
        local centerScreen = Camera.ViewportSize / 2
        FovCircle.Position = Vector2.new(centerScreen.X, centerScreen.Y)
        FovCircle.Radius = Config.SilentAimFov
        FovCircle.Visible = true
    else
        FovCircle.Visible = false
    end
end)

-- ФУНКЦИЯ ЗАХВАТА ИГРОКА СТРОГО ВНУТРИ ПОДВЕЧЕННОГО КРУГА FOV
local function GetClosestPlayerInCircle()
    local closestPlayer = nil
    local shortestDistance = Config.SilentAimFov
    local centerScreen = Camera.ViewportSize / 2

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            local human = player.Character:FindFirstChild("Humanoid")
            
            if root and human and human.Health > 0 then
                local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
                
                if onScreen then
                    local distance = (Vector2.new(centerScreen.X, centerScreen.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
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

-- ПЕРЕХВАТ НАЖАТИЯ ОРИГИНАЛЬНОЙ КНОПКИ БРОСКА ИГРЫ (Throw Hook)
-- Скрипт отслеживает нажатие кнопки "Бросить" (Touch или правый клик мыши на эмуляторах)
UserInputService.InputBegan:Connect(function(input, processed)
    -- Проверяем оригинальный ввод броска
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton2 then
        -- Если Silent Aim включен, принудительно активируем Супер-Импульс
        if States.SilentAim then
            local target = GetClosestPlayerInCircle()
            
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                local targetHrp = target.Character.HumanoidRootPart
                
                -- Отключаем коллизию деталей жертвы, чтобы она не врезалась в забор/стены на спавне
                for _, part in pairs(target.Character:GetChildren()) do
                    if part:IsA("BasePart") then 
                        part.CanCollide = false 
                    end
                end
                
                -- Создаем мощнейший вектор ускорения
                local velocityInstance = Instance.new("LinearVelocity")
                local attachment = Instance.new("Attachment")
                
                attachment.Parent = targetHrp
                velocityInstance.MaxForce = math.huge
                -- Сила рассчитывается по направлению камеры вашего iPad
                velocityInstance.VectorVelocity = Camera.CFrame.LookVector * Config.ThrowForce
                velocityInstance.Attachment0 = attachment
                velocityInstance.Parent = targetHrp
                
                -- Задержка на импульс, после чего физика чистится, а цель улетает за лимиты
                task.wait(0.2)
                velocityInstance:Destroy()
                attachment:Destroy()
            end
        end
    end
end)

-- ХУК СИСТЕМНЫХ МЕТАМЕТОДОВ ДЛЯ НАВЕДЕНИЯ БРОСКА (SILENT AIM)
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if States.SilentAim and (method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList" or method == "Raycast") then
        local target = GetClosestPlayerInCircle()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local targetPart = target.Character.HumanoidRootPart
            if method == "Raycast" then
                args = (targetPart.Position - args).Unit * 1000
            else
                args = Ray.new(args.Origin, (targetPart.Position - args.Origin).Unit * 1000)
            end
        end
    end
    return oldNamecall(self, unpack(args))
end)

local oldIndex
oldIndex = hookmetamethod(game, "__index", function(self, key)
    if States.SilentAim and (key == "Hit" or key == "Target") and not checkcaller() then
        local target = GetClosestPlayerInCircle()
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

-- НЕПРЕРЫВНЫЙ ЦИКЛ ЗАСАСЫВАНИЯ В ЧЕРНУЮ ДЫРУ + УБИЙСТВО ПОД КАРТУ
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
                local distance = (myHrp.Position - tHrp.Position).Magnitude
                
                if distance < Config.HoleRadius then
                    -- МГНОВЕННЫЙ КИЛЛ: Если засосало вплотную к вашему iPad-персонажу
                    if distance < 15 then
                        tHrp.CFrame = CFrame.new(tHrp.Position.X, -1500, tHrp.Position.Z)
                        tHrp.AssemblyLinearVelocity = Vector3.new(0, -500, 0)
                    else
                        -- Притягивание скоростным импульсом в центр воронки
                        local direction = (myHrp.Position - tHrp.Position).Unit
                        tHrp.AssemblyLinearVelocity = direction * Config.HoleSpeed
                    end
                end
            end
        end
    end
end)

-- НАСТРОЙКА КНОПОК ВКЛЮЧЕНИЯ И ОТКЛЮЧЕНИЯ МОДУЛЕЙ
AimButton.MouseButton1Click:Connect(function()
    States.SilentAim = not States.SilentAim
    AimButton.Text = "1. Silent Aim " .. (States.SilentAim and "[ВКЛ]" or "[ВЫКЛ]")
    AimButton.BackgroundColor3 = States.SilentAim and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 50)
end)

FovVisualButton.MouseButton1Click:Connect(function()
    States.ShowFov = not States.ShowFov
    FovVisualButton.Text = "2. Границы FOV " .. (States.ShowFov and "[ПОКАЗАТЬ]" or "[СКРЫТЬ]")
    FovVisualButton.BackgroundColor3 = States.ShowFov and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 50)
end)

HoleButton.MouseButton1Click:Connect(function()
    States.BlackHole = not States.BlackHole
    HoleButton.Text = "3. BlackHole + Kill " .. (States.BlackHole and "[ВКЛ]" or "[ВЫКЛ]")
    HoleButton.BackgroundColor3 = States.BlackHole and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 50)
end)

print("[Delta iPad Throw Hook Script Loaded!]")
