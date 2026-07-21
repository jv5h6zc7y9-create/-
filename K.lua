-- СОЗДАНИЕ ИНТЕРФЕЙСА (Крупное меню под пальцы на iPad)
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

MainFrame.Name = "iPadDeltaMenuFinalAbsoluteFixV8"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Position = UDim2.new(0.05, 0, 0.25, 0)
MainFrame.Size = UDim2.new(0, 260, 0, 395)
MainFrame.Active = true
MainFrame.Draggable = true 

Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Title.Text = "IPAD FT&P ULTIMATE V8"
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
styleButton(AntiGrabButton, "4. Anti-Grab [ВЫКЛ]", 230)

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
local Config = { SilentAimFov = 200, ThrowForce = 5000000, HoleSpeed = 140, HoleRadius = 300 }
local EspObjects = {}
local CurrentGrabbedObject = nil

-- СОЗДАНИЕ КРУГА СТРОГО ПОСЕРЕДИНЕ ЭКРАНА IPAD
local FovCircle = Drawing.new("Circle")
FovCircle.Visible = false
FovCircle.Thickness = 2.5
FovCircle.Color = Color3.fromRGB(255, 50, 50)
FovCircle.Radius = Config.SilentAimFov
FovCircle.Filled = false
FovCircle.NumSides = 64

-- МГНОВЕННЫЙ ПОИСК ЦЕЛИ БЕЗ ЗАДЕРЖЕК (ОПТИМИЗИРОВАНО ПОД СВЕРХСКОРОСТЬ)
local function GetClosestPlayerInCenterCircle()
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

-- ФУНКЦИЯ ОБНОВЛЕНИЯ 3D БОКСОВ (ESP КОРОБКИ)
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

Players.PlayerRemoving:Connect(function(player)
    if EspObjects[player] then
        EspObjects[player]:Destroy()
        EspObjects[player] = nil
    end
end)

-- ХУК МЕТАМЕТОДОВ ДЛЯ МГНОВЕННОГО ПОПАДАНИЯ АИМА (БЕЗ ЗАДЕРЖЕК)
local oldIndex
oldIndex = hookmetamethod(game, "__index", function(self, key)
    if States.SilentAim and not checkcaller() then
        if key == "Hit" or key == "Target" then
            local dynamicTarget = GetClosestPlayerInCenterCircle()
            if dynamicTarget and dynamicTarget.Character and dynamicTarget.Character:FindFirstChild("HumanoidRootPart") then
                if key == "Hit" then
                    return dynamicTarget.Character.HumanoidRootPart.CFrame
                elseif key == "Target" then
                    return dynamicTarget.Character.HumanoidRootPart
                end
            end
        end
    end
    return oldIndex(self, key)
end)

-- СВЕРХСКОРОСТНОЙ ЦИКЛ ОБНОВЛЕНИЯ ПОЗИЦИЙ, АНТИ-ГРАБА И ОТКЛЮЧЕНИЯ КОЛЛИЗИИ
RunService.RenderStepped:Connect(function()
    local myChar = LocalPlayer.Character
    local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
    
    -- Обновление круга FOV
    if States.SilentAim then
        local centerScreen = Camera.ViewportSize / 2
        FovCircle.Position = Vector2.new(centerScreen.X, centerScreen.Y)
        FovCircle.Radius = Config.SilentAimFov
        FovCircle.Visible = true
    else
        FovCircle.Visible = false
    end

    if myChar then
        -- 1. АБСОЛЮТНЫЙ АНТИ-ХВАТ (Очистка любых попыток поднять вас)
        if States.AntiGrab then
            for _, obj in pairs(myChar:GetDescendants()) do
                if obj:IsA("Weld") or obj:IsA("ManualWeld") or obj:IsA("RopeConstraint") or obj:IsA("BallSocketConstraint") or obj:IsA("SpringConstraint") then
                    -- Если связь создана не вашей локальной системой, уничтожаем её
                    if obj.Name ~= "LocalGrabWeld" then
                        obj:Destroy()
                    end
                end
            end
            if myHrp then
                for _, force in pairs(myHrp:GetChildren()) do
                    if force:IsA("BodyPosition") or force:IsA("BodyVelocity") or force:IsA("LinearVelocity") or force:IsA("VectorForce") then
                        force:Destroy()
                    end
                end
            end
        end

        -- 2. ПОИСК УДЕРЖИВАЕМОГО ОБЪЕКТА И ОТКЛЮЧЕНИЕ КОЛЛИЗИИ (ДЛЯ ЗАПИХИВАНИЯ ПОД ПОЛ)
        CurrentGrabbedObject = nil
        for _, child in pairs(myChar:GetDescendants()) do
            if (child:IsA("Weld") or child:IsA("Constraint")) and child.Part1 and not child.Part1:IsDescendantOf(myChar) then
                CurrentGrabbedObject = child.Part1.Parent
            elseif (child:IsA("Weld") or child:IsA("Constraint")) and child.Part0 and not child.Part0:IsDescendantOf(myChar) then
                CurrentGrabbedObject = child.Part0.Parent
            end
        end

        -- Если объект в руках — полностью отключаем ему коллизию, чтобы засунуть под текстуры
        if CurrentGrabbedObject and States.SilentAim then
            for _, part in pairs(CurrentGrabbedObject:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                    part.Velocity = Vector3.new(part.Velocity.X, -50, part.Velocity.Z) -- Помогает проталкивать вниз
                end
            end
        end
    end
end)

-- ПЕРЕХВАТ НАСТОЯЩЕЙ ИГРОВОЙ КНОПКИ БРОСКА ДЛЯ СУПЕР-ИМПУЛЬСА В НЕБО И КИЛЛА
UserInputService.InputBegan:Connect(function(input, processed)
    -- Перехватываем сенсорное нажатие на кнопку броска (или правый клик)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton2 then
        if States.SilentAim and CurrentGrabbedObject then
            local targetHrp = CurrentGrabbedObject:FindFirstChild("HumanoidRootPart") or CurrentGrabbedObject:FindFirstChildOfClass("BasePart")
            
            if targetHrp then
                -- Полностью стираем старые силы удержания, чтобы бросок не тормозил
                for _, force in pairs(targetHrp:GetChildren()) do
                    if force:IsA("BodyPosition") or force:IsA("BodyVelocity") or force:IsA("LinearVelocity") then
                        force:Destroy()
                    end
                end

                -- Рассчитываем траекторию: если в FOV есть игрок — летит в него, иначе — строго в небо по камере
                local aimTarget = GetClosestPlayerInCenterCircle()
                local throwDirection = Camera.CFrame.LookVector
                if aimTarget and aimTarget.Character and aimTarget.Character:FindFirstChild("HumanoidRootPart") then
                    throwDirection = (aimTarget.Character.HumanoidRootPart.Position - targetHrp.Position).Unit
                else
                    -- Если прицел чистый, даем мощный вектор вверх и вперед (в небо)
                    throwDirection = (Camera.CFrame.LookVector + Vector3.new(0, 2, 0)).Unit
                end
                
                -- Создаем колоссальную силу супер-броска
                local velocityInstance = Instance.new("LinearVelocity")
                local attachment = Instance.new("Attachment")
                attachment.Parent = targetHrp
                velocityInstance.MaxForce = math.huge
                velocityInstance.VectorVelocity = throwDirection * Config.ThrowForce
                velocityInstance.Attachment0 = attachment
                velocityInstance.Parent = targetHrp
                
                -- Быстро удаляем физический костыль, оставляя чистую бесконечную инерцию полета
                task.wait(0.15)
                velocityInstance:Destroy()
                attachment:Destroy()
            end
        end
    end
end)

-- НЕПРЕРЫВНЫЙ ФИЗИЧЕСКИЙ ЦИКЛ ДЛЯ ЧЕРНОЙ ДЫРЫ И ESP КОРОБОК
RunService.Heartbeat:Connect(function()
    local myChar = LocalPlayer.Character
    local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
    UpdateEsp()
    
    -- Логика Физической Черной Дыры
    if States.BlackHole and myHrp then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local tHrp = player.Character:FindFirstChild("HumanoidRootPart")
                local tHum = player.Character:FindFirstChild("Humanoid")
                
                if tHrp and tHum and tHum.Health > 0 then
                    local distance = (myHrp.Position - tHrp.Position).Magnitude
                    
                    if distance < Config.HoleRadius then
                        if distance < 18 then
                            -- КИЛЛ под карту в Бездну Void
                            tHrp.CFrame = CFrame.new(tHrp.Position.X, -1600, tHrp.Position.Z)
                            tHrp.AssemblyLinearVelocity = Vector3.new(0, -999, 0)
                        else
                            -- Всасывание в эпицентр дыры
                            local direction = (myHrp.Position - tHrp.Position).Unit
                            tHrp.AssemblyLinearVelocity = direction * Config.HoleSpeed
                        end
                    end
                end
            end
        end
    end
end)

-- НАСТРОЙКА КНОПОК ИНТЕРФЕЙСА ПЛАНШЕТА
AimButton.MouseButton1Click:Connect(function()
    States.SilentAim = not States.SilentAim
    AimButton.Text = "1. Сверх-Хват + Аим " .. (States.SilentAim and "[ВКЛ]" or "[ВЫКЛ]")
    AimButton.BackgroundColor3 = States.SilentAim and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 50)
end)

EspButton.MouseButton1Click:Connect(function()
    States.ShowEsp = not States.ShowEsp
    EspButton.Text = "2. Границы Бокса " .. (States.ShowEsp and "[ВКЛ]" or "[ВЫКЛ]")
    EspButton.BackgroundColor3 = States.ShowEsp and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 50)
end)

HoleButton.MouseButton1Click:Connect(function()
    States.BlackHole = not States.BlackHole
    HoleButton.Text = "3. Физическая Дыра " .. (States.BlackHole and "[ВКЛ]" or "[ВЫКЛ]")
    HoleButton.BackgroundColor3 = States.BlackHole and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 50)
end)

AntiGrabButton.MouseButton1Click:Connect(function()
    States.AntiGrab = not States.AntiGrab
    AntiGrabButton.Text = "4. Anti-Grab " .. (States.AntiGrab and "[ВКЛ]" or "[ВЫКЛ]")
    AntiGrabButton.BackgroundColor3 = States.AntiGrab and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 50)
end)

FovPlusButton.MouseButton1Click:Connect(function()
    if Config.SilentAimFov < 600 then
        Config.SilentAimFov = Config.SilentAimFov + 25
    end
end)

FovMinusButton.MouseButton1Click:Connect(function()
    if Config.SilentAimFov > 50 then
        Config.SilentAimFov = Config.SilentAimFov - 25
    end
end)

print("[Delta iOS: Финальная сборка V8 успешно запущена!]")
