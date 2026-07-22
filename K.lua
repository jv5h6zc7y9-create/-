-- ====================================================================
-- IPAD FLING THINGS AND PEOPLE SUPREMACY V27 (ULTIMATE TOTAL FIX)
-- NO SHORTCUTS - FULL EXPANDED SOURCE CODE FOR DELTA EXECUTOR iOS
-- ====================================================================

if not game:IsLoaded() then 
    game.Loaded:Wait() 
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Полная очистка старых окон во избежание наложения GUI
if CoreGui:FindFirstChild("FlingThingsUltimateGUI_V27") then
    CoreGui:FindFirstChild("FlingThingsUltimateGUI_V27"):Destroy()
end

-- СОЗДАНИЕ ИНТЕРФЕЙСА (Полностью на русском языке, фикс Draggable)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FlingThingsUltimateGUI_V27"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 260, 0, 390)
MainFrame.Position = UDim2.new(0.5, -120, 0.5, -195)
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
TitleLabel.Text = "  FT&P HARDCORE SUPREMACY V27"
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

-- НАСТРОЕЧНЫЕ ТАБЛИЦЫ ЧИТОВ И СОСТОЯНИЙ ФИЗИКИ
local Toggles = { 
    SilentAim = false, 
    MaxThrow = false, 
    BlackHole = false, 
    AntiGrab = false, 
    PushAura = false,
    ShowEsp = false
}

local Config = { 
    SilentAimFov = 350, 
    ThrowForce = 95000000, 
    HoleRadius = 12, 
    OrbitSpeed = 7, 
    PushRadius = 14,
    PredictionIntensity = 0.15
}

local GlobalTrackedGrab = { ActiveItem = nil, WasGrabbed = false }
local EspVisualObjects = {}
local OrbitAngle = 0
local ToyRemoteInstance = nil

-- БЕЗОПАСНОЕ ПЕРЕТАСКИВАНИЕ МЕНЮ НА IPAD (БЕЗ ВЫЛЕТОВ И КРАШЕЙ)
local dragging = false
local dragStart = nil
local startPos = nil

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
        MainFrame.Size = UDim2.new(0, 260, 0, 390)
        TitleLabel.Visible = true
        MinimizeBtn.Position = UDim2.new(1, -45, 0, 0)
        MinimizeBtn.Text = "—"
        MinimizeBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    end
end)

-- ДИНАМИЧЕСКИЙ АИМ-ЗАХВАТ БЛИЖАЙШЕГО ИГРОКА К ЦЕНТРУ СЕНСОРА
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

-- -------------------------------------------------------------------------------
-- МОДУЛЬ 1: ОБНОВЛЕННЫЙ СВЕРХСКОРОСТНОЙ ХУК АИМА (WALLBANG И ПРЕДСКАЗАНИЕ БЕГА)
-- -------------------------------------------------------------------------------
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if Toggles.SilentAim and not checkcaller() and (method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList" or method == "Raycast") then
        local activeTarget = GetClosestPlayerToCenter()
        if activeTarget and activeTarget.Character and activeTarget.Character:FindFirstChild("HumanoidRootPart") then
            local tRoot = activeTarget.Character.HumanoidRootPart
            -- Жесткое упреждение траектории луча сквозь любые стены
            local predictedPos = tRoot.Position + (tRoot.AssemblyLinearVelocity * Config.PredictionIntensity)
            
            if method == "Raycast" then
                args[2] = (predictedPos - args[1]).Unit * 15000
            else
                args[1] = Ray.new(args[1].Origin, (predictedPos - args[1].Origin).Unit * 15000)
            end
        end
    end
    return oldNamecall(self, unpack(args))
end)

local oldIndex
oldIndex = hookmetamethod(game, "__index", function(self, key)
    if Toggles.SilentAim and not checkcaller() and (key == "Hit" or key == "Target") then
        local activeTarget = GetClosestPlayerToCenter()
        if activeTarget and activeTarget.Character and activeTarget.Character:FindFirstChild("HumanoidRootPart") then
            local tRoot = activeTarget.Character.HumanoidRootPart
            local aimPos = tRoot.Position + (tRoot.AssemblyLinearVelocity * Config.PredictionIntensity)
            
            return key == "Hit" and CFrame.new(aimPos) or tRoot
        end
    end
    return oldIndex(self, key)
end)

-- -------------------------------------------------------------------------------
-- МОДУЛЬ 2: МЕГА-БРОСОК НА УСКОРИТЕЛЯХ BODYTHRUST (95,000,000) + ТРАМБОВКА ПОД ПОЛ
-- -------------------------------------------------------------------------------
local function applyMassiveVelocityThrow(obj)
    if not obj or not obj:IsA("BasePart") then return end
    
    pcall(function()
        obj.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
        obj.AssemblyMass = 0
        obj.Massless = true
    end)

    local throwDirection = Camera.CFrame.LookVector
    local activeTarget = GetClosestPlayerToCenter()
    
    if Toggles.SilentAim and activeTarget and activeTarget.Character and activeTarget.Character:FindFirstChild("HumanoidRootPart") then
        local tRoot = activeTarget.Character.HumanoidRootPart
        throwDirection = ((tRoot.Position + (tRoot.AssemblyLinearVelocity * Config.PredictionIntensity)) - obj.Position).Unit
    else
        throwDirection = (Camera.CFrame.LookVector + Vector3.new(0, 4, 0)).Unit
    end

    -- Принудительный разгон через BodyThrust (Абсолютный лимит мощности против лагов)
    local thrust = Instance.new("BodyThrust")
    thrust.Force = throwDirection * Config.ThrowForce
    thrust.Location = Vector3.new(0, 0, 0)
    thrust.Parent = obj
    
    obj:ApplyImpulse(throwDirection * Config.ThrowForce)
    obj.AssemblyLinearVelocity = throwDirection * Config.ThrowForce

    Debris:AddItem(thrust, 0.35)
end

-- Сканнер хвата: стирает старую историю предметов каждую миллисекунду
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
                -- Принудительное заталкивание удерживаемой жертвы/вещи под текстуры земли
                currentGrabbedPart.CanCollide = false
                currentGrabbedPart.AssemblyLinearVelocity = Vector3.new(currentGrabbedPart.AssemblyLinearVelocity.X, -160, currentGrabbedPart.AssemblyLinearVelocity.Z)
            end
        else
            -- Клик оригинальной кнопки броска игры: связь порвалась — даем мега-импульс
            if GlobalTrackedGrab.WasGrabbed and GlobalTrackedGrab.ActiveItem then
                if Toggles.MaxThrow then
                    applyMassiveVelocityThrow(GlobalTrackedGrab.ActiveItem)
                end
                GlobalTrackedGrab.ActiveItem = nil
                GlobalTrackedGrab.WasGrabbed = false
            end
        end
    end
end)

-- -------------------------------------------------------------------------------
-- МОДУЛЬ 3: ИСТИННАЯ ЧЕРНАЯ ДЫРА (СПАВН ИЗ ИНВЕНТАРЯ И ЗАПИХИВАНИЕ В МИКРОВОЛНОВКУ)
-- -------------------------------------------------------------------------------
local function scanAndSpawnMicrowave()
    local foundMachine = nil
    for _, item in pairs(workspace:GetDescendants()) do
        if item:IsA("Model") and (item.Name:lower():find("microwave") or item.Name:lower():find("machine")) then
            foundMachine = item
            break
        end
    end
    -- Нативный форумный Remote-пакет инвентаря игрушек, если ловушки нет на карте
    if not foundMachine then
        if not ToyRemoteInstance then
            ToyRemoteInstance = ReplicatedStorage:FindFirstChild("SpawnToy") or ReplicatedStorage:FindFirstChild("ToysRemote") or (ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("SpawnToy"))
        end
        if ToyRemoteInstance then
            ToyRemoteInstance:FireServer("Microwave") -- Спавним Микроволновку из вашего Toys инвентаря
        end
    end
    return foundMachine
end

RunService.Heartbeat:Connect(function()
    if not Toggles.BlackHole then return end
    
    local myChar = LocalPlayer.Character
    local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHrp then return end
    
    local currentMicrowave = scanAndSpawnMicrowave()
    
    -- Телепортируем микроволновку прямо под координаты вашего персонажа
    if currentMicrowave and currentMicrowave:IsA("Model") then
        local primary = currentMicrowave.PrimaryPart or currentMicrowave:FindFirstChildOfClass("BasePart")
        if primary then
            primary.CanCollide = false
            currentMicrowave:SetPrimaryPartCFrame(myHrp.CFrame * CFrame.new(0, -3.8, -1.5))
        end
    end
    
    OrbitAngle = OrbitAngle + math.rad(Config.OrbitSpeed)
    
    -- Сбор всех игроков и вещей сервера в жесткий принудительный CFrame-круг
    local index = 0
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            index = index + 1
            local tHrp = player.Character.HumanoidRootPart
            tHrp.CanCollide = false
            local spacing = (math.pi * 2) / #Players:GetPlayers()
            local offsetX = math.cos(OrbitAngle + (index * spacing)) * Config.HoleRadius
            local offsetZ = math.sin(OrbitAngle + (index * spacing)) * Config.HoleRadius
            -- Выстраиваем кольцо удержания и запихиваем глубоко внутрь ловушки
            tHrp.CFrame = CFrame.new(myHrp.Position + Vector3.new(offsetX, -4.2, offsetZ))
            tHrp.AssemblyLinearVelocity = Vector3.new(0, -90000, 0) -- Скорость засасывания в Void
        end
    end
    
    for _, part in pairs(workspace:GetChildren()) do
        if part:IsA("BasePart") and part.Anchored == false and part.Name ~= "Baseplate" then
            part.CanCollide = false
            part.CFrame = CFrame.new(myHrp.Position + Vector3.new(0, -4, 0))
            part.AssemblyLinearVelocity = Vector3.new(0, -60000, 0)
        end
    end
end)

-- -------------------------------------------------------------------------------
-- МОДУЛЬ 4: СЛЕДЯЩАЯ ПОДСВЕТКА НИКОВ И 3D БОКСЫ СКВОЗЬ СТЕНЫ (ESP)
-- -------------------------------------------------------------------------------
local function ApplyVisualEspSystem()
    local currentAimTarget = GetClosestPlayerToCenter()
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            if root and Toggles.ShowEsp then
                if not EspVisualObjects[player] then
                    -- Создание сквозного 3D Бокса
                    local box = Instance.new("BoxHandleAdornment")
                    box.Name = "Delta_Esp_Box_V27"
                    box.Size = player.Character:GetExtentsSize() + Vector3.new(0.4, 0.4, 0.4)
                    box.Color3 = Color3.fromRGB(255, 0, 0)
                    box.Transparency = 0.5
                    box.AlwaysOnTop = true
                    box.ZIndex = 6
                    box.Adornee = player.Character
                    box.Parent = player.Character
                    
                    -- Создание сквозного Ника над головой
                    local billboard = Instance.new("BillboardGui")
                    billboard.Name = "Delta_Esp_Name_V27"
                    billboard.Size = UDim2.new(0, 150, 0, 40)
                    billboard.AlwaysOnTop = true
                    billboard.StudsOffset = Vector3.new(0, 3, 0)
                    
                    local label = Instance.new("TextLabel")
                    label.Size = UDim2.new(1, 0, 1, 0)
                    label.BackgroundTransparency = 1
                    label.Text = player.Name
                    label.TextColor3 = Color3.fromRGB(255, 255, 255)
                    label.TextSize = 13
                    label.Font = Enum.Font.SourceSansBold
                    label.Parent = billboard
                    
                    billboard.Parent = player.Character:FindFirstChild("Head") or root
                    EspVisualObjects[player] = { Box = box, Gui = billboard }
                else
                    -- Если игрок выбран Аимом — бокс становится зеленым
                    if currentAimTarget == player then
                        EspVisualObjects[player].Box.Color3 = Color3.fromRGB(0, 255, 0)
                    else
                        EspVisualObjects[player].Box.Color3 = Color3.fromRGB(255, 0, 0)
                    end
                end
            else
                if EspVisualObjects[player] then
                    if EspVisualObjects[player].Box then EspVisualObjects[player].Box:Destroy() end
                    if EspVisualObjects[player].Gui then EspVisualObjects[player].Gui:Destroy() end
                    EspVisualObjects[player] = nil
                end
            end
        end
    end
end

-- -------------------------------------------------------------------------------
-- МОДУЛЬ 5: НАТИВНЫЙ АНТИ-ГРАБ + АУРА ОТКИДЫВАНИЯ НА 14 ЕДИНИЦ
-- -------------------------------------------------------------------------------
local function SecureCharacter(char)
    char.DescendantAdded:Connect(function(descendant)
        if Toggles.AntiGrab and (descendant:IsA("Weld") or descendant.Name:lower():find("weld") or descendant:IsA("Constraint") or descendant:IsA("MoverConstraint")) then
            task.wait(0.01)
            if descendant.Parent then
                local attackerChar = descendant.Parent
                if attackerChar ~= char and not descendant:IsDescendantOf(char) then
                    local enemyModel = descendant:FindFirstAncestorOfClass("Model")
                    if enemyModel and enemyModel:FindFirstChildOfClass("Humanoid") and enemyModel.Name ~= LocalPlayer.Name then
                        enemyModel:BreakJoints() -- Ломаем суставы врагу при попытке взятия
                        descendant:Destroy()
                    end
                end
            end
        end
    end)
end

if LocalPlayer.Character then SecureCharacter(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(SecureCharacter)

RunService.Heartbeat:Connect(function()
    local myChar = LocalPlayer.Character
    local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHrp then return end
    
    ApplyVisualEspSystem()
    
    if Toggles.AntiGrab then
        for _, force in pairs(myHrp:GetChildren()) do
            if force:IsA("BodyPosition") or force:IsA("AlignPosition") or force:IsA("BodyVelocity") or force:IsA("LinearVelocity") then
                force:Destroy()
            end
        end
    end
    
    -- Аура защиты: откидывает чужих игроков, если они подходят ближе 14 единиц
    if Toggles.PushAura then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local eHrp = player.Character.HumanoidRootPart
                local distance = (myHrp.Position - eHrp.Position).Magnitude
                if distance <= Config.PushRadius then
                    local pushDirection = (eHrp.Position - myHrp.Position).Unit
                    eHrp.AssemblyLinearVelocity = (pushDirection * 190) + Vector3.new(0, 50, 0)
                end
            end
        end
    end
end)

-- ГЕНЕРАТОР КНОПОК ПЕРЕКЛЮЧЕНИЯ ИНТЕРФЕЙСА GUI (ПРАВАЯ ПАНЕЛЬ)
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

CreateToggle("1. Сверх-Аим сквозь Текстуры", 10, function(v) Toggles.SilentAim = v end)
CreateToggle("2. Мега-Бросок + Трамобвка под Пол", 52, function(v) Toggles.MaxThrow = v end)
CreateToggle("3. Истинная Черная Дыра (Сбор)", 94, function(v) Toggles.BlackHole = v end)
CreateToggle("4. Нативный Анти-Хват рук", 136, function(v) Toggles.AntiGrab = v end)
CreateToggle("5. Аура Защитного Откидывания", 178, function(v) Toggles.PushAura = v end)
CreateToggle("6. Сквозные Ники и 3D Боксы (ESP)", 220, function(v) Toggles.ShowEsp = v end)

print("[Delta iOS Execution: Финальная сборка V27 успешно загружена!]")
