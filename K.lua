-- ====================================================================
-- IPAD FLING THINGS AND PEOPLE SUPREMACY V21 (GUI MENU TOTAL FIX)
-- NO SHORTCUTS - FULL EXPANDED SOURCE CODE FOR DELTA EXECUTOR iOS
-- ====================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ПОЛНАЯ ОЧИСТКА СТАРЫХ ОКОН ДЛЯ ИЗБЕЖАНИЯ ДУБЛИРОВАНИЯ ИНТЕРФЕЙСА
if CoreGui:FindFirstChild("FlingThingsSupremeGUI_V21") then
    CoreGui:FindFirstChild("FlingThingsSupremeGUI_V21"):Destroy()
end

-- СОЗДАНИЕ ГРАФИЧЕСКОГО ИНТЕРФЕЙСА (Кастомное меню для iPad)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FlingThingsSupremeGUI_V21"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 440, 0, 380)
MainFrame.Position = UDim2.new(0.5, -220, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 0, 45)
TitleLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 16
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "FT&P HARDCORE SUPREMACY V21"
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

-- Контейнер со списком игроков для Аима (Левая панель)
local ScrollingContainer = Instance.new("ScrollingFrame")
ScrollingContainer.Size = UDim2.new(0, 190, 0, 310)
ScrollingContainer.Position = UDim2.new(0, 12, 0, 55)
ScrollingContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
ScrollingContainer.BorderSizePixel = 0
ScrollingContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollingContainer.ScrollBarThickness = 4
ScrollingContainer.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ScrollingContainer
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)

-- ПЕРЕМЕННЫЕ СОСТОЯНИЙ И НАСТРОЕК Физики
local SelectedTarget = nil
local SilentAimEnabled = false
local MaxThrowEnabled = false
local BlackHoleEnabled = false
local AntiGrabEnabled = false
local FOVRadius = 250

local GlobalTrackedGrab = { ActiveItem = nil, WasGrabbed = false }
local ActiveBlackHoleForces = {}

local function getTargetRoot(player)
    if player and player.Character then
        return player.Character:FindFirstChild("HumanoidRootPart") or player.Character:FindFirstChild("Torso")
    end
    return nil
end

local function getPredictedPosition(targetPart)
    if not targetPart then return Vector3.zero end
    local velocity = targetPart.AssemblyLinearVelocity or Vector3.zero
    return targetPart.Position + (velocity * 0.165)
end

-- ФУНКЦИЯ ОБНОВЛЕНИЯ ТАБЛИЦЫ ЖЕРТВ (АВТО-ОБНОВЛЕНИЕ РАЗ В МИНУТУ)
local function RefreshPlayerList()
    for _, child in ipairs(ScrollingContainer:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1, 0, 0, 35)
            Btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
            Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            Btn.TextSize = 12
            Btn.Font = Enum.Font.Gotham
            Btn.Text = player.Name
            Btn.Parent = ScrollingContainer
            
            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 6)
            btnCorner.Parent = Btn
            
            Btn.MouseButton1Click:Connect(function()
                SelectedTarget = player
                TitleLabel.Text = "Target: " .. player.Name
            end)
        end
    end
    ScrollingContainer.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
end

task.spawn(function()
    while true do
        RefreshPlayerList()
        task.wait(60)
    end
end)

-- Визуальная линия прицеливания (ESP линия)
local AimSnapLine = Drawing.new("Line")
AimSnapLine.Visible = false
AimSnapLine.Thickness = 2.5
AimSnapLine.Color = Color3.fromRGB(255, 0, 0)

RunService.RenderStepped:Connect(function()
    if SilentAimEnabled and SelectedTarget and SelectedTarget.Character and SelectedTarget.Character:FindFirstChild("HumanoidRootPart") then
        local TargetRoot = SelectedTarget.Character.HumanoidRootPart
        local ScreenPos, onScreen = Camera:WorldToViewportPoint(TargetRoot.Position)
        local ScreenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        local DistToCenter = (Vector2.new(ScreenPos.X, ScreenPos.Y) - ScreenCenter).Magnitude

        if DistToCenter <= FOVRadius and onScreen then
            AimSnapLine.Visible = true
            AimSnapLine.From = ScreenCenter
            AimSnapLine.To = Vector2.new(ScreenPos.X, ScreenPos.Y)
        else
            AimSnapLine.Visible = false
        end
    else
        AimSnapLine.Visible = false
    end
end)

-- -------------------------------------------------------------------------------
-- ФУНКЦИЯ 1: СКВОЗНОЙ АИМ (RAYCAST WALLBANG BYPASS)
-- -------------------------------------------------------------------------------
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    if SilentAimEnabled and SelectedTarget and (method == "Raycast" or method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList") then
        local targetRoot = getTargetRoot(SelectedTarget)
        if targetRoot then
            local predictedPos = getPredictedPosition(targetRoot)
            local centerScreen = Camera.ViewportSize / 2
            local screenPos, onScreen = Camera:WorldToViewportPoint(predictedPos)
            
            if onScreen then
                local dist = (centerScreen - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                if dist <= FOVRadius then
                    if method == "Raycast" then
                        local origin = args
                        args = (predictedPos - origin).Unit * 10000
                    end
                end
            end
        end
    end
    return oldNamecall(self, unpack(args))
end)

-- -------------------------------------------------------------------------------
-- ФУНКЦИЯ 2: НАДЁЖНЫЙ НАТИВНЫЙ АНТИ-ГРАБ (ЯДРО ФОРУМА)
-- -------------------------------------------------------------------------------
local function setupAntiGrab(character)
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 5)
    if not humanoidRootPart then return end

    character.DescendantAdded:Connect(function(descendant)
        if not AntiGrabEnabled then return end
        if descendant:IsA("Weld") or descendant:IsA("ManualWeld") or descendant:IsA("MoverConstraint") or descendant:IsA("WeldConstraint") then
            local part0 = descendant.Part0
            local part1 = descendant.Part1
            
            local targetPart = (part0 and part0:IsDescendantOf(character) and part1 and not part1:IsDescendantOf(character) and part1) or (part1 and part1:IsDescendantOf(character) and part0 and not part0:IsDescendantOf(character) and part0)
            
            if targetPart and targetPart.Parent and targetPart.Parent ~= character then
                local attackerModel = targetPart:FindFirstAncestorOfClass("Model")
                if attackerModel and attackerModel:FindFirstChildOfClass("Humanoid") and attackerModel.Name ~= LocalPlayer.Name then
                    task.spawn(function()
                        task.wait(0.001)
                        
                        -- Разрыв рук агрессору
                        attackerModel:BreakJoints()
                        
                        -- Очистка торса от чужих физических сил
                        for _, child in ipairs(humanoidRootPart:GetChildren()) do
                            if child:IsA("BodyPosition") or child:IsA("AlignPosition") or child:IsA("BodyVelocity") or child:IsA("LinearVelocity") then
                                child:Destroy()
                            end
                        end
                        
                        pcall(function()
                            descendant:Destroy()
                        end)
                    end)
                end
            end
        end
    end)
end

if LocalPlayer.Character then setupAntiGrab(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(setupAntiGrab)

-- -------------------------------------------------------------------------------
-- ФУНКЦИЯ 3: ИСПРАВЛЕННЫЙ ДАЛЁКИЙ БРОСОК V21 (ТОЧНОЕ ОБНОВЛЕНИЕ РУК КЛИКОМ КНОПКИ)
-- -------------------------------------------------------------------------------
local function applyMaxThrowPhysics(toolObject)
    if not toolObject or not toolObject:IsA("BasePart") then return end
    pcall(function()
        toolObject.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
        toolObject.AssemblyMass = 0
        toolObject.Massless = true
    end)
    
    local throwVector = Camera.CFrame.LookVector
    local inFovLimits = false
    
    if SilentAimEnabled and SelectedTarget and SelectedTarget.Character and SelectedTarget.Character:FindFirstChild("HumanoidRootPart") then
        local enemyRoot = SelectedTarget.Character.HumanoidRootPart
        local centerScreen = Camera.ViewportSize / 2
        local screenPos, onScreen = Camera:WorldToViewportPoint(enemyRoot.Position)
        
        if onScreen then
            local dist = (centerScreen - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
            if dist <= FOVRadius then
                inFovLimits = true
                throwVector = (getPredictedPosition(enemyRoot) - toolObject.Position).Unit
            end
        end
    end
    
    if not inFovLimits then
        throwVector = (Camera.CFrame.LookVector + Vector3.new(0, 3.5, 0)).Unit
    end
    
    local lv = Instance.new("LinearVelocity")
    lv.MaxForce = math.huge
    lv.VectorVelocity = throwVector * 950000
    lv.Attachment0 = Instance.new("Attachment", toolObject)
    lv.Parent = toolObject
    
    -- Сетевой силовой импульс на 35,000,000
    toolObject:ApplyImpulse(throwVector * 35000000)
    toolObject.AssemblyLinearVelocity = throwVector * 35000000
    
    game:GetService("Debris"):AddItem(lv, 0.3)
end

-- Постоянное сканирование связей в руках и тотальная очистка истории хвата
RunService.Stepped:Connect(function()
    local character = LocalPlayer.Character
    if not character then return end
    
    local currentGrabbedPart = nil
    
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("Weld") or part:IsA("ManualWeld") or part:IsA("Constraint") or part:IsA("MoverConstraint") then
            local weldedPart = (part.Part0 and not part.Part0:IsDescendantOf(character) and part.Part0) or (part.Part1 and not part.Part1:IsDescendantOf(character) and part.Part1)
            if weldedPart and weldedPart:IsA("BasePart") then
                currentGrabbedPart = weldedPart
                break
            end
        end
    end
    
    if currentGrabbedPart then
        GlobalTrackedGrab.ActiveItem = currentGrabbedPart
        GlobalTrackedGrab.WasGrabbed = true
        
        -- Вжимание под пол удерживаемой вещи/игрока
        if MaxThrowEnabled then
            currentGrabbedPart.CanCollide = false
            currentGrabbedPart.AssemblyLinearVelocity = Vector3.new(currentGrabbedPart.AssemblyLinearVelocity.X, -150, currentGrabbedPart.AssemblyLinearVelocity.Z)
        end
    else
        -- Момент клика по оригинальной кнопке броска: связь исчезает — срабатывает триггер
        if GlobalTrackedGrab.WasGrabbed and GlobalTrackedGrab.ActiveItem then
            if MaxThrowEnabled then
                applyMaxThrowPhysics(GlobalTrackedGrab.ActiveItem)
            end
            
            -- Очищаем кэш: скрипт моментально забывает старый предмет и готов к новой цели
            GlobalTrackedGrab.ActiveItem = nil
            GlobalTrackedGrab.WasGrabbed = false
        end
    end
end)

-- -------------------------------------------------------------------------------
-- ФУНКЦИЯ 4: ИСТИННАЯ СЕРВЕРНАЯ ЧЕРНАЯ ДЫРА
-- -------------------------------------------------------------------------------
local OrbitAngle = 0

RunService.Heartbeat:Connect(function()
    if not BlackHoleEnabled then
        if next(ActiveBlackHoleForces) ~= nil then
            for part, data in pairs(ActiveBlackHoleForces) do
                if data.AlignPos then data.AlignPos:Destroy() end
                if data.Attachment then data.Attachment:Destroy() end
                if data.CenterAttachment then data.CenterAttachment:Destroy() end
                if part and part.Parent then part.CanCollide = true end
            end
            table.clear(ActiveBlackHoleForces)
        end
        return
    end
    
    local myChar = LocalPlayer.Character
    local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHrp then return end
    
    OrbitAngle = OrbitAngle + math.rad(6)
    local totalElements = {}
    
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
            local offsetX = math.cos(elementAngle) * 15
            local offsetZ = math.sin(elementAngle) * 15
            
            element.CanCollide = false
            
            if not ActiveBlackHoleForces[element] then
                local centerAtt = Instance.new("Attachment")
                centerAtt.Parent = myHrp
                local targetAtt = Instance.new("Attachment")
                targetAtt.Parent = element
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
                data.CenterAttachment.Position = Vector3.new(offsetX, -4, offsetZ)
            end
            
            element.AssemblyLinearVelocity = Vector3.new(0, -45000, 0)
        end
    end
end)

-- ГЕНЕРАТОР КНОПОК ПЕРЕКЛЮЧЕНИЯ ИНТЕРФЕЙСА МЕНЮ (ПРАВАЯ ПАНЕЛЬ)
local function CreateToggle(name, posY, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 210, 0, 45)
    Btn.Position = UDim2.new(0, 215, 0, posY)
    Btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.TextSize = 13
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
CreateToggle("Black Hole", 175, function(v) BlackHoleEnabled = v end)
CreateToggle("Anti Grab", 235, function(v) AntiGrabEnabled = v end)

RefreshPlayerList()
print("[Delta iOS: Версия V21 с рабочим GUI меню полностью запущена!]")
