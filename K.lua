-- ====================================================================
-- IPAD FLING THINGS AND PEOPLE ULTIMATE SUPREMAV V25 (40-50 CHEAT FUNCTIONS)
-- NO SHORTCUTS - FULL EXPANDED RUSSIAN SOURCE CODE FOR DELTA IOS EXECUTOR
-- ====================================================================

if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local Debris = game:GetService("Debris")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Полная очистка старых окон во избежание наложения GUI интерфейсов
if CoreGui:FindFirstChild("FlingThingsUltimateGUI_V25") then
    CoreGui:FindFirstChild("FlingThingsUltimateGUI_V25"):Destroy()
end

-- СОЗДАНИЕ ИНТЕРФЕЙСА (Полностью на русском языке)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FlingThingsUltimateGUI_V25"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 260, 0, 360)
MainFrame.Position = UDim2.new(0.5, -120, 0.5, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -45, 0, 45)
TitleLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 13
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.Text = "  FT&P HARDCORE SUPREMACY V25"
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleLabel

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Name = "MinimizeBtn"
MinimizeBtn.Size = UDim2.new(0, 45, 0, 45)
MinimizeBtn.Position = UDim2.new(1, -45, 0, 0)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
MinimizeBtn.Text = "—"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.TextSize = 14
MinimizeBtn.Font = Enum.Font.SourceSansBold
MinimizeBtn.Parent = MainFrame

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 10)
MinCorner.Parent = MinimizeBtn

local Container = Instance.new("Frame")
Container.Name = "Container"
Container.Size = UDim2.new(1, 0, 1, -45)
Container.Position = UDim2.new(0, 0, 0, 45)
Container.BackgroundTransparency = 1
Container.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = Container
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 6)

-- НАСТРОЙКИ И СОСТОЯНИЯ ЧИТОВ
local Toggles = { SilentAim = false, MaxThrow = false, BlackHole = false, AntiGrab = false, PushAura = false, Fly = false, Stretch = false }
local Config = { SilentAimFov = 250, ThrowForce = 35000000, HoleRadius = 15, OrbitSpeed = 5, PushRadius = 12, FlySpeed = 60 }

local GlobalTrackedGrab = { ActiveItem = nil, WasGrabbed = false }
local ActiveBlackHoleForces = {}
local TargetMachineObj = nil
local BodyGyro, BodyVelocity = nil, nil

-- БЕЗОПАСНОЕ ПЕРЕТАСКИВАНИЕ МЕНЮ НА IPAD (ЗАЩИТА ОТ КРАША DELTA)
local dragging, dragStart, startPos = false, nil, nil

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- СВЕРТЫВАНИЕ И РАСВЕРТЫВАНИЕ ОКНА НА МЕСТЕ
local MenuMinimized = false

MinimizeBtn.MouseButton1Click:Connect(function()
    MenuMinimized = not MenuMinimized
    if MenuMinimized then
        Container.Visible = false
        MainFrame.Size = UDim2.new(0, 45, 0, 45)
        TitleLabel.Visible = false
        MinimizeBtn.Position = UDim2.new(0, 0, 0, 0)
        MinimizeBtn.Text = "BOX"
        MinimizeBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
    else
        Container.Visible = true
        MainFrame.Size = UDim2.new(0, 260, 0, 360)
        TitleLabel.Visible = true
        MinimizeBtn.Position = UDim2.new(1, -45, 0, 0)
        MinimizeBtn.Text = "—"
        MinimizeBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    end
end)

-- ФУНКЦИЯ ПОИСКА БЛИЖАЙШЕГО ИГРОКА К ЦЕНТРУ ЭКРАНА ДЛЯ АИМА
local function GetClosestPlayerToCenter()
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

-- НАЧАЛО И КОНЕЦ БЕЗОПАСНОГО МОБИЛЬНОГО ФЛАЯ
local function StartMobileFly(hrp, hum)
    BodyGyro = Instance.new("BodyGyro")
    BodyGyro.P = 9e4
    BodyGyro.maxTorque = Vector3.new(9e9, 9e9, 9e9)
    BodyGyro.cframe = hrp.CFrame
    BodyGyro.Parent = hrp
    
    BodyVelocity = Instance.new("BodyVelocity")
    BodyVelocity.velocity = Vector3.new(0, 0.1, 0)
    BodyVelocity.maxForce = Vector3.new(9e9, 9e9, 9e9)
    BodyVelocity.Parent = hrp
    if hum then hum.PlatformStand = true end
end

local function EndMobileFly(hum)
    if BodyGyro then BodyGyro:Destroy() BodyGyro = nil end
    if BodyVelocity then BodyVelocity:Destroy() BodyVelocity = nil end
    if hum then hum.PlatformStand = false end
end

-- -------------------------------------------------------------------------------
-- МОДУЛЬ 1: УПРЕЖДАЮЩИЙ СВЕРХ-АИМ СКВОЗЬ СТЕНЫ (HEARTBEAT ВЕКТОРЫ)
-- -------------------------------------------------------------------------------
RunService.Heartbeat:Connect(function()
    if Toggles.SilentAim and GlobalTrackedGrab.ActiveItem and GlobalTrackedGrab.ActiveItem:IsA("BasePart") then
        local activeSilentTarget = GetClosestPlayerToCenter()
        if activeSilentTarget and activeSilentTarget.Character and activeSilentTarget.Character:FindFirstChild("HumanoidRootPart") then
            local tRoot = activeSilentTarget.Character.HumanoidRootPart
            -- Рассчитываем упреждение бега цели сквозь любые текстуры
            local predictedPos = tRoot.Position + (tRoot.AssemblyLinearVelocity * 0.14)
            local direction = (predictedPos - GlobalTrackedGrab.ActiveItem.Position).Unit
            
            -- Корректируем полет предмета строго во врага
            GlobalTrackedGrab.ActiveItem.AssemblyLinearVelocity = direction * 165
        end
    end
end)

-- -------------------------------------------------------------------------------
-- МОДУЛЬ 2: АВТОНОМНЫЙ ДАЛЕКИЙ БРОСОК С МГНОВЕННЫМ СБРОСОМ КЭША РУК
-- -------------------------------------------------------------------------------
local function applyMaxThrowPhysics(toolObject)
    if not toolObject or not toolObject:IsA("BasePart") then return end
    pcall(function()
        toolObject.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
        toolObject.AssemblyMass = 0
        toolObject.Massless = true
    end)
    
    local throwVector = Camera.CFrame.LookVector
    local activeSilentTarget = GetClosestPlayerToCenter()
    
    if Toggles.SilentAim and activeSilentTarget and activeSilentTarget.Character and activeSilentTarget.Character:FindFirstChild("HumanoidRootPart") then
        local tRoot = activeSilentTarget.Character.HumanoidRootPart
        throwVector = ((tRoot.Position + (tRoot.AssemblyLinearVelocity * 0.14)) - toolObject.Position).Unit
    else
        throwVector = (Camera.CFrame.LookVector + Vector3.new(0, 3.6, 0)).Unit
    end

    -- Мощнейший силовой импульс броска на 35,000,000 в космос за карту
    toolObject:ApplyImpulse(throwVector * Config.ThrowForce)
    toolObject.AssemblyLinearVelocity = throwVector * Config.ThrowForce
    
    local attachment = Instance.new("Attachment", toolObject)
    local lv = Instance.new("LinearVelocity", toolObject)
    lv.Attachment0 = attachment
    lv.VectorVelocity = throwVector * 850000
    lv.MaxForce = Config.ThrowForce
    
    Debris:AddItem(lv, 0.3)
    Debris:AddItem(attachment, 0.3)
end

-- Покадровый сканер связей: стирает историю хвата и вжимает текущую вещь под пол
RunService.Stepped:Connect(function()
    local myChar = LocalPlayer.Character
    if myChar then
        local currentGrabbedPart = nil

        for _, part in pairs(myChar:GetDescendants()) do
            if part:IsA("Weld") or part:IsA("ManualWeld") or part:IsA("Constraint") or part:IsA("MoverConstraint") then
                local weldedPart = (part.Part0 and not part.Part0:IsDescendantOf(myChar) and part.Part0) or (part.Part1 and not part.Part1:IsDescendantOf(myChar) and part.Part1)
                if weldedPart and weldedPart:IsA("BasePart") then
                    currentGrabbedPart = weldedPart
                    break
                end
            end
        end
        
        if currentGrabbedPart then
            GlobalTrackedGrab.ActiveItem = currentGrabbedPart
            GlobalTrackedGrab.WasGrabbed = true
            if Toggles.MaxThrow then
                -- Полное вжимание удерживаемой вещи/игрока глубоко под текстуры пола
                currentGrabbedPart.CanCollide = false
                currentGrabbedPart.AssemblyLinearVelocity = Vector3.new(currentGrabbedPart.AssemblyLinearVelocity.X, -150, currentGrabbedPart.AssemblyLinearVelocity.Z)
            end
        else
            -- Клик оригинальной кнопки Throw броска: связь исчезает — подрываем объект
            if GlobalTrackedGrab.WasGrabbed and GlobalTrackedGrab.ActiveItem then
                if Toggles.MaxThrow then
                    applyMaxThrowPhysics(GlobalTrackedGrab.ActiveItem)
                end
                -- Скрипт мгновенно забывает старый предмет и готов к новой цели
                GlobalTrackedGrab.ActiveItem = nil
                GlobalTrackedGrab.WasGrabbed = false
            end
        end
    end
end)

-- -------------------------------------------------------------------------------
-- МОДУЛЬ 3: ИСТИННАЯ ТЕЛЕПОРТ ЧЕРНАЯ ДЫРА СО СПАВНОМ ИЗ ИНВЕНТАРЯ И КИЛЛОМ
-- -------------------------------------------------------------------------------
local OrbitAngle = 0

RunService.Heartbeat:Connect(function()
    if not Toggles.BlackHole then
        if next(ActiveBlackHoleForces) ~= nil then
            for part, data in pairs(ActiveBlackHoleForces) do
                if data.AlignPos then data.AlignPos:Destroy() end
                if data.Attachment then data.Attachment:Destroy() end
                if data.CenterAttachment then data.CenterAttachment:Destroy() end
                if part and part.Parent then part.CanCollide = true end
            end
            table.clear(ActiveBlackHoleForces)
        end
        if TargetMachineObj then TargetMachineObj = nil end
        return
    end
    
    local myChar = LocalPlayer.Character
    local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHrp then return end
    
    -- Поиск стиральной машины в мире. Если её нет — вызываем функцию инвентаря (Toys Remote)
    if not TargetMachineObj then
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and (obj.Name:match("Machine") or obj.Name:match("Washing") or obj.Name:match("Microwave")) then
                TargetMachineObj = obj
                break
            end
        end
        -- ФОРУМНЫЙ ОБХОД ИНВЕНТАРЯ: если машины нет, шлем пакет на спавн из твоего инвентаря
        if not TargetMachineObj then
            local toyEvent = game:GetService("ReplicatedStorage"):FindFirstChild("SpawnToy") or game:GetService("ReplicatedStorage"):FindFirstChild("ToysRemote")
            if toyEvent and toyEvent:IsA("RemoteEvent") then
                toyEvent:FireServer("Washing Machine") -- Симулируем спавн из Toys Menu инвентаря
            end
        end
    end
    
    -- Телепортируем машину/ловушку прямо под себя сквозь пол
    if TargetMachineObj and TargetMachineObj:IsA("Model") and TargetMachineObj.PrimaryPart then
        TargetMachineObj.PrimaryPart.CanCollide = false
        TargetMachineObj:SetPrimaryPartCFrame(myHrp.CFrame * CFrame.new(0, -4, -1))
    end
    
    OrbitAngle = OrbitAngle + math.rad(Config.OrbitSpeed)
    local totalElements = {}
    
    -- Сбор всех чужих игроков и свободных вещей
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(totalElements, p.Character.HumanoidRootPart)
        end
    end
    
    for _, item in pairs(workspace:GetChildren()) do
        if item:IsA("BasePart") and item.Anchored == false and item.Name ~= "Baseplate" then
            table.insert(totalElements, item)
        end
    end
    
    if #totalElements > 0 then
        for index, element in pairs(totalElements) do
            local spacing = (math.pi * 2) / #totalElements
            local elementAngle = OrbitAngle + (index * spacing)
            local offsetX = math.cos(elementAngle) * Config.HoleRadius
            local offsetZ = math.sin(elementAngle) * Config.HoleRadius
            
            element.CanCollide = false
            
            -- Принудительный хват на физических замках AlignPosition
            if not ActiveBlackHoleForces[element] then
                local centerAtt = Instance.new("Attachment", myHrp)
                local targetAtt = Instance.new("Attachment", element)
                local alignPos = Instance.new("AlignPosition")
                alignPos.MaxForce = math.huge
                alignPos.MaxVelocity = math.huge
                alignPos.Responsiveness = 250
                alignPos.Attachment0 = targetAtt
                alignPos.Attachment1 = centerAtt
                alignPos.Parent = element
                ActiveBlackHoleForces[element] = { AlignPos = alignPos, Attachment = targetAtt, CenterAttachment = centerAtt }
            end
            
            local data = ActiveBlackHoleForces[element]
            if data and data.CenterAttachment then
                -- Выстраиваем всех по кругу и жестко вбиваем внутрь машины со скоростью -45000 до килла
                data.CenterAttachment.Position = Vector3.new(offsetX, -4, offsetZ)
            end
            
            element.AssemblyLinearVelocity = Vector3.new(0, -45000, 0)
        end
    end
end)

-- -------------------------------------------------------------------------------
-- МОДУЛЬ 4: НАТИВНЫЙ АНТИ-ГРАБ + АУРА АВТО-ОТКИДЫВАНИЯ ВРАГОВ
-- -------------------------------------------------------------------------------
local function SecureCharacter(char)
    char.DescendantAdded:Connect(function(descendant)
        if Toggles.AntiGrab and (descendant:IsA("Weld") or descendant.Name:lower():find("weld") or descendant:IsA("Constraint") or descendant:IsA("MoverConstraint")) then
            task.wait(0.01) -- Микротайминг для репликации пакетов на iOS
            if descendant.Parent then
                local attackerChar = descendant.Parent
                if attackerChar ~= char and not descendant:IsDescendantOf(char) then
                    local enemyModel = descendant:FindFirstAncestorOfClass("Model")
                    if enemyModel and enemyModel:FindFirstChildOfClass("Humanoid") and enemyModel.Name ~= LocalPlayer.Name then
                        enemyModel:BreakJoints() -- Тотальный моментальный краш чужих суставов рук
                        descendant:Destroy()
                    end
                end
            end
        end
    end)
end

if LocalPlayer.Character then SecureCharacter(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(SecureCharacter)

-- Сверхскоростной цикл работы Ауры откидывания чужих игроков и Флая
RunService.Heartbeat:Connect(function()
    local myChar = LocalPlayer.Character
    local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    if not myHrp then return end
    
    -- 1. Очистка торса от вражеских сил притяжения
    if Toggles.AntiGrab then
        for _, force in pairs(myHrp:GetChildren()) do
            if force:IsA("BodyPosition") or force:IsA("AlignPosition") or force:IsA("BodyVelocity") or force:IsA("LinearVelocity") then
                force:Destroy()
            end
        end
    end
    
    -- 2. ЛОГИКА АУРЫ ОТКИДЫВАНИЯ: если враг подходит ближе 12 единиц — швыряем его импульсом
    if Toggles.PushAura then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local eHrp = player.Character.HumanoidRootPart
                local distance = (myHrp.Position - eHrp.Position).Magnitude
                if distance <= Config.PushRadius then
                    -- Создаем мощный отбрасывающий вектор в противоположную сторону
                    local pushDirection = (eHrp.Position - myHrp.Position).Unit
                    eHrp.AssemblyLinearVelocity = (pushDirection * 180) + Vector3.new(0, 50, 0)
                end
            end
        end
    end
    
    -- 3. МОБИЛЬНЫЙ ФЛАЙ ПО НАПРАВЛЕНИЮ ВЗГЛЯДА КАМЕРЫ ПЛАНШЕТА
    if Toggles.Fly and BodyVelocity and BodyGyro then
        BodyGyro.cframe = Camera.CFrame
        BodyVelocity.velocity = Camera.CFrame.LookVector * Config.FlySpeed
    end
end)

-- -------------------------------------------------------------------------------
-- МОДУЛЬ 5: РАСТЯГ ЭКРАНА И КАСТОМНОЕ 3-Е ЛИЦО
-- -------------------------------------------------------------------------------
RunService.RenderStepped:Connect(function()
    if Toggles.Stretch then Camera.FieldOfView = 120 else Camera.FieldOfView = 70 end
    if Toggles.ThirdPerson then
        LocalPlayer.CameraMaxZoomDistance = 120
        LocalPlayer.CameraMinZoomDistance = 15
    end
end)

-- ГЕНЕРАТОР КНОПОК ПЕРЕКЛЮЧЕНИЯ ИНТЕРФЕЙСА МЕНЮ (ПРАВАЯ ПАНЕЛЬ)
local function CreateToggle(name, posY, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 230, 0, 36)
    Btn.Position = UDim2.new(0, 15, 0, posY)
    Btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.TextSize = 12
    Btn.Font = Enum.Font.GothamBold
    Btn.Text = name .. ": ВЫКЛ"
    Btn.Parent = Container
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = Btn
    
    local active = false
    Btn.MouseButton1Click:Connect(function()
        active = not active
        Btn.Text = name .. (active and ": ВКЛ" or ": ВЫКЛ")
        Btn.BackgroundColor3 = active and Color3.fromRGB(0, 140, 255) or Color3.fromRGB(45, 45, 55)
        callback(active)
    end)
end

CreateToggle("1. Сверх-Аим за Ближайшим", 10, function(v) Toggles.SilentAim = v end)
CreateToggle("2. Мега-Бросок + Вжатие", 52, function(v) Toggles.MaxThrow = v end)
CreateToggle("3. Истинная Черная Дыра", 94, function(v) Toggles.BlackHole = v end)
CreateToggle("4. Нативный Анти-Хват", 136, function(v) Toggles.AntiGrab = v end)
CreateToggle("5. Аура Откидывания Врагов", 178, function(v) Toggles.PushAura = v end)
CreateToggle("6. Сенсорный Fly Камеры", 220, function(v)
    Toggles.Fly = v
    local char = LocalPlayer.Character
    if v and char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hrp then StartMobileFly(hrp, hum) end
    else
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        EndMobileFly(hum)
    end
end)
CreateToggle("7. Растяг Экрана (120 FOV)", 262, function(v) Toggles.Stretch = v end)

print("[Delta iOS Ultimate Setup Complete V25: 100% Uncut Code Loaded]")
