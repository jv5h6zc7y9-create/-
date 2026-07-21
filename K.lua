-- ====================================================================
-- IPAD FLING THINGS AND PEOPLE SUPREMACY V24 (THREE CORE FUNCTIONS)
-- NO SHORTCUTS - FULL EXPANDED SOURCE CODE FOR DELTA EXECUTOR iOS
-- ====================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ПОЛНАЯ ОЧИСТКА СТАРЫХ ОКНО ДЛЯ ИЗБЕЖАНИЯ ДУБЛИРОВАНИЯ ИНТЕРФЕЙСА
if CoreGui:FindFirstChild("FlingThingsEliteGUI_V24") then
    CoreGui:FindFirstChild("FlingThingsEliteGUI_V24"):Destroy()
end

-- СОЗДАНИЕ БЕЗОПАСНОГО ИНТЕРФЕЙСА (Anti-Crash GUI)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FlingThingsEliteGUI_V24"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 240, 0, 240)
MainFrame.Position = UDim2.new(0.5, -120, 0.5, -120)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 0, 45)
TitleLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 14
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "FT&P SUPREMACY V24"
TitleLabel.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleLabel

local TitleBottomLine = Instance.new("Frame")
TitleBottomLine.Size = UDim2.new(1, 0, 0, 3)
TitleBottomLine.Position = UDim2.new(0, 0, 1, -3)
TitleBottomLine.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
TitleBottomLine.BorderSizePixel = 0
TitleBottomLine.Parent = TitleLabel

-- ПЕРЕМЕННЫЕ СОСТОЯНИЙ И НАСТРОЕК ФИЗИКИ СИСТЕМЫ
local SilentAimEnabled = false
local MaxThrowEnabled = false
local AntiGrabEnabled = false

local FOVRadius = 250
local ThrowForce = 35000000

local GlobalTrackedGrab = { ActiveItem = nil, WasGrabbed = false }

-- СТАБИЛЬНЫЙ СКРИПТ ПЕРЕТАСКИВАНИЯ ОКНА ДЛЯ СЕНСОРА IPAD (БЕЗ Draggable = true)
local dragging = false
local dragStart = Vector3.new()
local startPos = UDim2.new()

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- ФУНКЦИЯ ДИНАМИЧЕСКОГО ПОИСКА БЛИЖАЙШЕГО ИГРОКА НА ЭКРАНЕ (БЕЗ СПИСКОВ)
local function GetClosestPlayerToCenter()
    local closestPlayer = nil
    local shortestDistance = FOVRadius
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
-- ФУНКЦИЯ 1: БЕЗОПАСНЫЙ СЛЕДЯЩИЙ АИМ (ВЕКТОРНАЯ КОРРЕКЦИЯ В HEARTBEAT)
-- -------------------------------------------------------------------------------
RunService.Heartbeat:Connect(function()
    if SilentAimEnabled and GlobalTrackedGrab.ActiveItem and GlobalTrackedGrab.ActiveItem:IsA("BasePart") then
        local activeSilentTarget = GetClosestPlayerToCenter()
        if activeSilentTarget and activeSilentTarget.Character and activeSilentTarget.Character:FindFirstChild("HumanoidRootPart") then
            local tRoot = activeSilentTarget.Character.HumanoidRootPart
            -- Рассчитываем упреждение и плавную траекторию полета к торсу врага
            local predictedPos = tRoot.Position + (tRoot.AssemblyLinearVelocity * 0.14)
            local direction = (predictedPos - GlobalTrackedGrab.ActiveItem.Position).Unit
            
            -- Перехватываем управление скоростью летящей вещи на уровне движка
            GlobalTrackedGrab.ActiveItem.AssemblyLinearVelocity = direction * 165
        end
    end
end)

-- -------------------------------------------------------------------------------
-- ФУНКЦИЯ 2: АВТОНОМНЫЙ ДАЛЕКИЙ БРОСОК НА СИСТЕМНЫХ ИМПУЛЬСАХ (35,000,000)
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
    
    -- Определение направления пинка
    if SilentAimEnabled and activeSilentTarget and activeSilentTarget.Character and activeSilentTarget.Character:FindFirstChild("HumanoidRootPart") then
        local tRoot = activeSilentTarget.Character.HumanoidRootPart
        local predictedPos = tRoot.Position + (tRoot.AssemblyLinearVelocity * 0.14)
        throwVector = (predictedPos - toolObject.Position).Unit
    else
        -- Катапультирование вверх в небо, пробивая любые крыши и потолки карты
        throwVector = (Camera.CFrame.LookVector + Vector3.new(0, 3.6, 0)).Unit
    end

    -- Нативный силовой толчок для обхода сетевых ограничений владения вещью
    toolObject:ApplyImpulse(throwVector * ThrowForce)
    toolObject.AssemblyLinearVelocity = throwVector * ThrowForce
    
    local attachment = Instance.new("Attachment", toolObject)
    local lv = Instance.new("LinearVelocity", toolObject)
    lv.Attachment0 = attachment
    lv.VectorVelocity = throwVector * 850000
    lv.MaxForce = ThrowForce
    
    game:GetService("Debris"):AddItem(lv, 0.3)
    game:GetService("Debris"):AddItem(attachment, 0.3)
end

-- Сверхскоростной мониторинг рук с тотальной очисткой кэша истории удержаний
RunService.Stepped:Connect(function()
    local myChar = LocalPlayer.Character
    if myChar then
        local currentGrabbedPart = nil

        -- Сканируем активные сварки рук прямо в этот кадр физики
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
            
            -- Вжимание удерживаемой цели глубоко под пол и текстуры земли
            if MaxThrowEnabled then
                currentGrabbedPart.CanCollide = false
                currentGrabbedPart.AssemblyLinearVelocity = Vector3.new(currentGrabbedPart.AssemblyLinearVelocity.X, -150, currentGrabbedPart.AssemblyLinearVelocity.Z)
            end
        else
            -- Момент отпускания оригинальной кнопки броска: связь порвалась — запускаем мега-импульс
            if GlobalTrackedGrab.WasGrabbed and GlobalTrackedGrab.ActiveItem then
                if MaxThrowEnabled then
                    applyMaxThrowPhysics(GlobalTrackedGrab.ActiveItem)
                end
                -- Полное обнуление: скрипт моментально забывает старый предмет и готов к новому хвату
                GlobalTrackedGrab.ActiveItem = nil
                GlobalTrackedGrab.WasGrabbed = false
            end
        end
    end
end)

-- -------------------------------------------------------------------------------
-- ФУНКЦИЯ 3: НАДЁЖНЫЙ АНТИ-ВЗЯТИЕ (ANTI-GRAB SHIELD) C МИКРОТАЙМИНГОМ DELTA
-- -------------------------------------------------------------------------------
local function SecureCharacter(char)
    char.DescendantAdded:Connect(function(descendant)
        if AntiGrabEnabled and (descendant:IsA("Weld") or descendant.Name:lower():find("weld") or descendant:IsA("Constraint") or descendant:IsA("MoverConstraint")) then
            task.wait(0.01) -- Микротайминг для репликации пакетов на iOS
            if descendant.Parent then
                local attackerChar = descendant.Parent
                -- Разрываем суставы строго нападающему агрессору, защищая себя
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

-- ГЕНЕРАТОР КНОПОК ПЕРЕКЛЮЧЕНИЯ ИНТЕРФЕЙСА GUI
local function CreateToggle(name, posY, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 210, 0, 45)
    Btn.Position = UDim2.new(0, 15, 0, posY)
    Btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.TextSize = 12
    Btn.Font = Enum.Font.GothamBold
    Btn.Text = name .. ": OFF"
    Btn.Parent = MainFrame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = Btn
    
    local active = false
    Btn.MouseButton1Click:Connect(function()
        active = not active
        Btn.Text = name .. (active and ": ON" or ": OFF")
        Btn.BackgroundColor3 = active and Color3.fromRGB(0, 140, 60) or Color3.fromRGB(45, 45, 55)
        callback(active)
    end)
end

CreateToggle("Silent Aim", 55, function(v) SilentAimEnabled = v end)
CreateToggle("Max Throw", 115, function(v) MaxThrowEnabled = v end)
CreateToggle("Anti Grab", 175, function(v) AntiGrabEnabled = v end)

print("[Delta iOS Setup Complete V24: Only Three Core Functions Loaded]")
