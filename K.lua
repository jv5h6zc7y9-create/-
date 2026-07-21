-- ====================================================================
-- IPAD FLING THINGS AND PEOPLE ABSOLUTE SUPREMAV V12 (IDEAL COMPLETE)
-- NO SHORTCUTS - FULL EXPANDED SOURCE CODE FOR DELTA EXECUTOR iOS
-- ====================================================================

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local AimButton = Instance.new("TextButton")
local HoleButton = Instance.new("TextButton")
local AntiGrabButton = Instance.new("TextButton")
local FlyButton = Instance.new("TextButton")
local ReschButton = Instance.new("TextButton")
local ThirdButton = Instance.new("TextButton")

ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

MainFrame.Name = "iPadDeltaUltimateSupremacyV12"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
MainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
MainFrame.Size = UDim2.new(0, 260, 0, 410)
MainFrame.Active = true
MainFrame.Draggable = true 

local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0, 10)
FrameCorner.Parent = MainFrame

Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
Title.Text = "FT&P HARDCORE SUPREMACY V12"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.Font = Enum.Font.SourceSansBold

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = Title

local function styleButton(btn, text, posY)
    btn.Parent = MainFrame
    btn.Size = UDim2.new(0.9, 0, 0, 45)
    btn.Position = UDim2.new(0.05, 0, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 13
    btn.Font = Enum.Font.SourceSansBold
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 8)
    BtnCorner.Parent = btn
end

styleButton(AimButton, "1. Сверх-Аим + Бросок [ВЫКЛ]", 60)
styleButton(HoleButton, "2. Истинная Черная Дыра [ВЫКЛ]", 115)
styleButton(AntiGrabButton, "3. Жесткий Анти-Граб [ВЫКЛ]", 170)
styleButton(FlyButton, "4. Сенсорный Fly [ВЫКЛ]", 225)
styleButton(ReschButton, "5. Растяг Экрана [ВЫКЛ]", 280)
styleButton(ThirdButton, "6. Мод 3-го Лица [ВЫКЛ]", 335)

-- СЕРВИСЫ
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- КОНФИГУРАЦИЯ
local States = { SilentAim = false, BlackHole = false, AntiGrab = false, Fly = false, Stretch = false, ThirdPerson = false }
local Config = { SilentAimFov = 350, ThrowForce = 12500000, HoleRadius = 18, OrbitSpeed = 6, PredictionFactor = 0.12 }
local GlobalTrackedGrab = { ActiveItem = nil, WasGrabbed = false }

-- ХРАНИЛИЩЕ ДЛЯ СВЯЗЕЙ И ТРАЕКТОРНЫХ ВИЗУАЛОВ
local ActiveBlackHoleForces = {}
local TargetMachineObj = nil

-- СЕНСОРНЫЙ FLY (АДАПТАЦИЯ ПОД IPAD)
local FlySpeed = 65
local BodyGyro = nil
local BodyVelocity = nil

local function StartFly()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    BodyGyro = Instance.new("BodyGyro")
    BodyGyro.P = 9e4
    BodyGyro.maxTorque = Vector3.new(9e9, 9e9, 9e9)
    BodyGyro.cframe = hrp.CFrame
    BodyGyro.Parent = hrp
    
    BodyVelocity = Instance.new("BodyVelocity")
    BodyVelocity.velocity = Vector3.new(0, 0.1, 0)
    BodyVelocity.maxForce = Vector3.new(9e9, 9e9, 9e9)
    BodyVelocity.Parent = hrp
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then hum.PlatformStand = true end
end

local function EndFly()
    if BodyGyro then BodyGyro:Destroy() BodyGyro = nil end
    if BodyVelocity then BodyVelocity:Destroy() BodyVelocity = nil end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.PlatformStand = false end
end

-- ВИЗУАЛЬНЫЕ ЭЛЕМЕНТЫ АИМА (ЛИНИИ СЛЕДОВАНИЯ И КРУГ)
local FovCircle = Drawing.new("Circle")
FovCircle.Visible = false
FovCircle.Thickness = 2
FovCircle.Color = Color3.fromRGB(0, 255, 255)
FovCircle.Radius = Config.SilentAimFov
FovCircle.Filled = false
FovCircle.NumSides = 64

local AimSnapLine = Drawing.new("Line")
AimSnapLine.Visible = false
AimSnapLine.Thickness = 2.5
AimSnapLine.Color = Color3.fromRGB(255, 0, 50)

local AimTargetDot = Drawing.new("Circle")
AimTargetDot.Visible = false
AimTargetDot.Thickness = 1
AimTargetDot.Color = Color3.fromRGB(255, 0, 50)
AimTargetDot.Radius = 7
AimTargetDot.Filled = true

-- СВЕРХСКОРОСТНОЙ ПОИСК ЦЕЛИ С УПРЕЖДЕНИЕМ ПО КООРДИНАТАМ
local function GetClosestTargetPlayer()
    local closestPlayer = nil
    local shortestDistance = Config.SilentAimFov
    local centerScreen = Camera.ViewportSize / 2

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            local human = player.Character:FindFirstChild("Humanoid")
            
            if root and human and human.Health > 0 then
                -- Добавление вектора упреждения на скорость движения цели
                local predictedPos = root.Position + (root.AssemblyLinearVelocity * Config.PredictionFactor)
                local screenPos, onScreen = Camera:WorldToViewportPoint(predictedPos)
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

-- СИСТЕМНЫЙ ХУК СЕТЕВЫХ СВЯЗЕЙ ДЛЯ СВЕРХ-НАВЕДЕНИЯ БРОСКА
local oldIndex
oldIndex = hookmetamethod(game, "__index", function(self, key)
    if States.SilentAim and not checkcaller() and (key == "Hit" or key == "Target") then
        local target = GetClosestTargetPlayer()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local tRoot = target.Character.HumanoidRootPart
            local predictedCFrame = CFrame.new(tRoot.Position + (tRoot.AssemblyLinearVelocity * Config.PredictionFactor))
            return key == "Hit" and predictedCFrame or tRoot
        end
    end
    return oldIndex(self, key)
end)

-- ОЧИСТКА ХВАТА ЧЕРНОЙ ДЫРЫ И СЛИВ ВСЕХ В БЕЗДНУ ПОСЛЕ ОТПУСКАНИЯ
local function ClearBlackHoleForces()
    for part, data in pairs(ActiveBlackHoleForces) do
        if data.AlignPos then data.AlignPos:Destroy() end
        if data.Attachment then data.Attachment:Destroy() end
        if data.CenterAttachment then data.CenterAttachment:Destroy() end
        
        if part and part.Parent then
            part.CanCollide = true
            -- Мощный финальный пинок строго вниз под карту (Void Килл)
            local force = Instance.new("LinearVelocity")
            local att = Instance.new("Attachment")
            att.Parent = part
            force.MaxForce = math.huge
            force.VectorVelocity = Vector3.new(0, -2000, 0)
            force.Attachment0 = att
            force.Parent = part
            game:GetService("Debris"):AddItem(force, 0.3)
            game:GetService("Debris"):AddItem(att, 0.3)
        end
    end
    table.clear(ActiveBlackHoleForces)
    if TargetMachineObj then
        TargetMachineObj:Destroy()
        TargetMachineObj = nil
    end
end

local OrbitAngle = 0

-- ГЛАВНЫЙ СИНХРОННЫЙ ЦИКЛ ПОТОКА ПО КАДРАМ
RunService.RenderStepped:Connect(function()
    local myChar = LocalPlayer.Character
    local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local centerScreen = Camera.ViewportSize / 2
    
    -- 1. СИНХРОНИЗАЦИЯ КРУГА FOV И ЛИНИЙ СЛЕДОВАНИЯ АИМА ЗА ИГРОКОМ
    if States.SilentAim then
        FovCircle.Position = centerScreen
        FovCircle.Radius = Config.SilentAimFov
        FovCircle.Visible = true
        
        local activeEnemy = GetClosestTargetPlayer()
        if activeEnemy and activeEnemy.Character and activeEnemy.Character:FindFirstChild("HumanoidRootPart") then
            local enemyRoot = activeEnemy.Character.HumanoidRootPart
            local enemyPos, onScreen = Camera:WorldToViewportPoint(enemyRoot.Position + (enemyRoot.AssemblyLinearVelocity * Config.PredictionFactor))
            
            if onScreen then
                AimSnapLine.From = centerScreen
                AimSnapLine.To = Vector2.new(enemyPos.X, enemyPos.Y)
                AimSnapLine.Visible = true
                
                AimTargetDot.Position = Vector2.new(enemyPos.X, enemyPos.Y)
                AimTargetDot.Visible = true
            else
                AimSnapLine.Visible = false
                AimTargetDot.Visible = false
            end
        else
            AimSnapLine.Visible = false
            AimTargetDot.Visible = false
        end
    else
        FovCircle.Visible = false
        AimSnapLine.Visible = false
        AimTargetDot.Visible = false
    end

    -- МОДЫ КАМЕРЫ (РАСТЯГ И ТРЕТЬЕ ЛИЦО)
    if States.Stretch then Camera.FieldOfView = 120 else Camera.FieldOfView = 70 end
    if States.ThirdPerson then
        LocalPlayer.CameraMaxZoomDistance = 100
        LocalPlayer.CameraMinZoomDistance = 15
        Camera.CameraSubject = myChar and myChar:FindFirstChild("Head")
    end

    -- ФЛАЙ УПРАВЛЕНИЕ
    if States.Fly and BodyVelocity and BodyGyro and myHrp then
        BodyGyro.cframe = Camera.CFrame
        local moveDirection = Vector3.new(0, 0, 0)
        if UserInputService.TouchEnabled then moveDirection = Camera.CFrame.LookVector end
        BodyVelocity.velocity = moveDirection * FlySpeed
    end
    
    if myChar then
        -- ЖЕСТКИЙ АНТИ-ГРАБ (ОЧИСТКА ХВАТА ВРАГОВ НА КОРНЕВОМ УРОВНЕ)
        if States.AntiGrab then
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("Weld") or v:IsA("ManualWeld") or v:IsA("Constraint") or v:IsA("MoverConstraint") or v:IsA("RopeConstraint") then
                    if v.Part0 and v.Part0:IsDescendantOf(myChar) or v.Part1 and v.Part1:IsDescendantOf(myChar) then
                        if not v:IsDescendantOf(myChar) then v:Destroy() end
                    end
                end
            end
            if myHrp then
                for _, f in pairs(myHrp:GetChildren()) do
                    if f:IsA("BodyPosition") or f:IsA("BodyVelocity") or f:IsA("LinearVelocity") or f:IsA("AlignPosition") then f:Destroy() end
                end
            end
        end
        
        -- СКАНИРОВАНИЕ СИСТЕМНОГО ХВАТА РУКИ ДЛЯ ДАЛЕКОГО БРОСКА
        local currentFrameObject = nil
        for _, object in pairs(myChar:GetDescendants()) do
            if object:IsA("Weld") or object:IsA("Constraint") or object:IsA("MoverConstraint") then
                if object.Part1 and not object.Part1:IsDescendantOf(myChar) then
                    currentFrameObject = object.Part1.Parent
                elseif object.Part0 and not object.Part0:IsDescendantOf(myChar) then
                    currentFrameObject = object.Part0.Parent
                end
            end
        end
        
        if currentFrameObject then
            GlobalTrackedGrab.ActiveItem = currentFrameObject
            GlobalTrackedGrab.WasGrabbed = true
            if States.SilentAim then
                for _, part in pairs(currentFrameObject:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                        part.AssemblyLinearVelocity = Vector3.new(0, -130, 0) -- Вжатие под пол
                    end
                end
            end
        else
            -- МОМЕНТ РАБОТЫ ИСПРАВЛЕННОГО ДАЛЕКОГО БРОСКА С КНОПКИ
            if GlobalTrackedGrab.WasGrabbed and GlobalTrackedGrab.ActiveItem and States.SilentAim then
                local tHrp = GlobalTrackedGrab.ActiveItem:FindFirstChild("HumanoidRootPart") or GlobalTrackedGrab.ActiveItem:FindFirstChildOfClass("BasePart")
                if tHrp then
                    for _, p in pairs(GlobalTrackedGrab.ActiveItem:GetChildren()) do if p:IsA("BasePart") then p.CanCollide = false end end
                    local targetEnemy = GetClosestTargetPlayer()
                    local throwVector = Camera.CFrame.LookVector
                    if targetEnemy and targetEnemy.Character and targetEnemy.Character:FindFirstChild("HumanoidRootPart") then
                        local rootEnemy = targetEnemy.Character.HumanoidRootPart
                        throwVector = ((rootEnemy.Position + (rootEnemy.AssemblyLinearVelocity * Config.PredictionFactor)) - tHrp.Position).Unit
                    else
                        -- Траектория катапультирования в небо (без коллизий сквозь потолки)
                        throwVector = (Camera.CFrame.LookVector + Vector3.new(0, 3.5, 0)).Unit
                    end
                    local velocityInstance = Instance.new("LinearVelocity")
                    local attachmentInstance = Instance.new("Attachment")
                    attachmentInstance.Parent = tHrp
                    velocityInstance.MaxForce = math.huge
                    velocityInstance.VectorVelocity = throwVector * Config.ThrowForce
                    velocityInstance.Attachment0 = attachmentInstance
                    velocityInstance.Parent = tHrp
                    game:GetService("Debris"):AddItem(velocityInstance, 0.25)
                    game:GetService("Debris"):AddItem(attachmentInstance, 0.25)
                end
                GlobalTrackedGrab.ActiveItem = nil
                GlobalTrackedGrab.WasGrabbed = false
            end
        end
        
        -- ИСТИННАЯ СВЕРХСКОРОСТНАЯ ЧЕРНАЯ ДЫРА: ТЕЛЕПОРТ-СБОР ВСЕХ ИГРОКОВ И СТИРАЛЬНОЙ МАШИНЫ В КОЛЬЦО РУК
        if States.BlackHole and myHrp then
            OrbitAngle = OrbitAngle + math.rad(Config.OrbitSpeed)
            
            -- Автоматический спавн/поиск Стиральной Машины или Крупного объекта для засасывания
            if not TargetMachineObj then
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj:IsA("Model") and (obj.Name:match("Machine") or obj.Name:match("Washing") or obj.Name:match("Microwave")) then
                        TargetMachineObj = obj
                        break
                    end
                end
                -- Если готового объекта нет, скрипт использует любую крупную локальную структуру
                if not TargetMachineObj then TargetMachineObj = workspace:FindFirstChildOfClass("Part") end
            end
            
            -- Телепортация Стиральной машины прямо под ваши координаты (В центр воронки)
            if TargetMachineObj and TargetMachineObj:IsA("Model") and TargetMachineObj.PrimaryPart then
                TargetMachineObj.PrimaryPart.CanCollide = false
                TargetMachineObj:SetPrimaryPartCFrame(myHrp.CFrame * CFrame.new(0, -3.5, -2))
            elseif TargetMachineObj and TargetMachineObj:IsA("BasePart") then
                TargetMachineObj.CanCollide = false
                TargetMachineObj.CFrame = myHrp.CFrame * CFrame.new(0, -3.5, -2)
            end
            
            local totalElements = {}
            
            -- Сбор абсолютно всех чужих игроков сервера через перебор таблиц
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    table.insert(totalElements, p.Character.HumanoidRootPart)
                end
            end
            
            -- Сбор абсолютно всех свободных вещей из окружения карты
            for _, item in pairs(workspace:GetChildren()) do
                if item:IsA("BasePart") and item.Anchored == false and item.Name ~= "Baseplate" then
                    table.insert(totalElements, item)
                elseif item:IsA("Model") and item:FindFirstChildOfClass("BasePart") and not item:FindFirstChild("Humanoid") then
                    local primary = item.PrimaryPart or item:FindFirstChildOfClass("BasePart")
                    if primary and primary.Anchored == false then table.insert(totalElements, primary) end
                end
            end
            
            -- Динамическое удержание и выстраивание кольца захвата
            if #totalElements > 0 then
                for index, element in pairs(totalElements) do
                    local spacing = (math.pi * 2) / #totalElements
                    local elementAngle = OrbitAngle + (index * spacing)
                    
                    -- Координаты кольца удержания рук (Вжато ровно в центр засасывающей Стиральной машины под пол)
                    local offsetX = math.cos(elementAngle) * Config.HoleRadius
                    local offsetZ = math.sin(elementAngle) * Config.HoleRadius
                    local targetPosition = myHrp.Position + Vector3.new(offsetX, -4, offsetZ)
                    
                    element.CanCollide = false
                    
                    -- Создание серверных физических замков удержания без сокращений функций
                    if not ActiveBlackHoleForces[element] then
                        local centerAtt = Instance.new("Attachment")
                        centerAtt.Name = "BlackHoleCenterAttV12"
                        centerAtt.Parent = myHrp
                        
                        local targetAtt = Instance.new("Attachment")
                        targetAtt.Name = "BlackHoleTargetAttV12"
                        targetAtt.Parent = element
                        
                        local alignPos = Instance.new("AlignPosition")
                        alignPos.MaxForce = math.huge
                        alignPos.MaxVelocity = math.huge
                        alignPos.Responsiveness = 300
                        alignPos.Attachment0 = targetAtt
                        alignPos.Attachment1 = centerAtt
                        alignPos.Parent = element
                        
                        ActiveBlackHoleForces[element] = {
                            AlignPos = alignPos,
                            Attachment = targetAtt,
                            CenterAttachment = centerAtt
                        }
                    end
                    
                    -- Мгновенное обновление координат физического замка удержания
                    local data = ActiveBlackHoleForces[element]
                    if data and data.CenterAttachment then
                        data.CenterAttachment.Position = Vector3.new(offsetX, -4, offsetZ)
                    end
                    
                    -- Постоянное силовое вдавливание объектов вниз внутрь текстур машины
                    element.AssemblyLinearVelocity = Vector3.new(0, -110, 0)
                end
            end
        else
            if next(ActiveBlackHoleForces) ~= nil then ClearBlackHoleForces() end
        end
    end
end)

-- ОБРАБОТЧИКИ НАЖАТИЙ КНОПОК МЕНЮ СЕНСОРА IPAD
AimButton.MouseButton1Click:Connect(function()
    States.SilentAim = not States.SilentAim
    AimButton.Text = "1. Сверх-Аим + Бросок " .. (States.SilentAim and "[ВКЛ]" or "[ВЫКЛ]")
    AimButton.BackgroundColor3 = States.SilentAim and Color3.fromRGB(0, 140, 60) or Color3.fromRGB(45, 45, 52)
end)

HoleButton.MouseButton1Click:Connect(function()
    States.BlackHole = not States.BlackHole
    HoleButton.Text = "2. Истинная Черная Дыра " .. (States.BlackHole and "[ВКЛ]" or "[ВЫКЛ]")
    HoleButton.BackgroundColor3 = States.BlackHole and Color3.fromRGB(0, 140, 60) or Color3.fromRGB(45, 45, 52)
    if not States.BlackHole then ClearBlackHoleForces() end
end)

AntiGrabButton.MouseButton1Click:Connect(function()
    States.AntiGrab = not States.AntiGrab
    AntiGrabButton.Text = "3. Жесткий Анти-Граб " .. (States.AntiGrab and "[ВКЛ]" or "[ВЫКЛ]")
    AntiGrabButton.BackgroundColor3 = States.AntiGrab and Color3.fromRGB(0, 140, 60) or Color3.fromRGB(45, 45, 52)
end)

FlyButton.MouseButton1Click:Connect(function()
    States.Fly = not States.Fly
    FlyButton.Text = "4. Сенсорный Fly " .. (States.Fly and "[ВКЛ]" or "[ВЫКЛ]")
    FlyButton.BackgroundColor3 = States.Fly and Color3.fromRGB(0, 140, 60) or Color3.fromRGB(45, 45, 52)
    if States.Fly then StartFly() else EndFly() end
end)

ReschButton.MouseButton1Click:Connect(function()
    States.Stretch = not States.Stretch
    ReschButton.Text = "5. Растяг Экрана " .. (States.Stretch and "[ВКЛ]" or "[ВЫКЛ]")
    ReschButton.BackgroundColor3 = States.Stretch and Color3.fromRGB(0, 140, 60) or Color3.fromRGB(45, 45, 52)
end)

ThirdButton.MouseButton1Click:Connect(function()
    States.ThirdPerson = not States.ThirdPerson
    ThirdButton.Text = "6. Мод 3-го Лица " .. (States.ThirdPerson and "[ВКЛ]" or "[ВЫКЛ]")
    ThirdButton.BackgroundColor3 = States.ThirdPerson and Color3.fromRGB(0, 140, 60) or Color3.fromRGB(45, 45, 52)
end)

print("[Delta iOS Setup Ideal Complete: V12 Loaded]")
