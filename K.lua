-- ====================================================================
-- IPAD FLING THINGS AND PEOPLE SUPREMACY V23 (ORIGINAL STABLE GUI)
-- NO SHORTCUTS - FULL EXPANDED SOURCE CODE FOR DELTA EXECUTOR iOS
-- ====================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Полная очистка старых окон во избежание наложения GUI интерфейсов
if CoreGui:FindFirstChild("FlingThingsEliteGUI") then
    CoreGui:FindFirstChild("FlingThingsEliteGUI"):Destroy()
end

-- GUI Initialization (ОРИГИНАЛЬНОЕ СТАБИЛЬНОЕ МЕНЮ С ПЛАНШЕТА)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FlingThingsEliteGUI"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 420, 0, 360)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 0, 40)
TitleLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 16
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "Fling Things & People - Delta iOS"
TitleLabel.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleLabel

local ScrollingContainer = Instance.new("ScrollingFrame")
ScrollingContainer.Size = UDim2.new(0, 180, 0, 290)
ScrollingContainer.Position = UDim2.new(0, 10, 0, 55)
ScrollingContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
ScrollingContainer.BorderSizePixel = 0
ScrollingContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollingContainer.ScrollBarThickness = 4
ScrollingContainer.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ScrollingContainer
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 4)

-- State Variables (Переменные состояний и настроек физики)
local SelectedTarget = nil
local SilentAimEnabled = false
local MaxThrowEnabled = false
local BlackHoleEnabled = false
local AntiGrabEnabled = false
local FOVRadius = 250

local ActiveBlackHoleForces = {}
local GlobalTrackedGrab = { ActiveItem = nil, WasGrabbed = false }

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

-- ФУНКЦИЯ 1: Обновление выпадающего списка игроков из оригинального меню
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
            Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
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

-- Отрисовка динамической линии следования Аима до выбранного игрока
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
-- ХУК МЕТАМЕТОДОВ СЕТИ (ПРОБИТИЕ ТЕКСТУР, СТЕН И ХОЛМОВ)
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
                        local origin = args[1]
                        args[2] = (predictedPos - origin).Unit * 10000
                    end
                end
            end
        end
    end
    return oldNamecall(self, unpack(args))
end)

local OldIndex
OldIndex = hookmetamethod(game, "__index", function(self, k)
    if SilentAimEnabled and SelectedTarget and SelectedTarget.Character and not checkcaller() then
        local char = SelectedTarget.Character
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            local centerScreen = Camera.ViewportSize / 2
            local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
            
            if onScreen then
                local dist = (centerScreen - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                if dist <= FOVRadius then
                    local predictedCFrame = CFrame.new(getPredictedPosition(root))
                    if k == "Hit" then
                        return predictedCFrame
                    elseif k == "Target" then
                        return root
                    end
                end
            end
        end
    end
    return OldIndex(self, k)
end)

-- -------------------------------------------------------------------------------
-- ФУНКЦИЯ 3: ИСПРАВЛЕННЫЙ СУПЕР-БРОСОК И РУЧНОЕ ВЖАТИЕ ПОД ТЕКСТУРЫ ПОЛА
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

    -- Нативная очистка сопротивления и запуск импульса в космос сквозь потолки
    local bodyImpulse = throwVector * 35000000
    toolObject:ApplyImpulse(bodyImpulse)
    toolObject.AssemblyLinearVelocity = bodyImpulse
    
    local attachment = Instance.new("Attachment", toolObject)
    local lv = Instance.new("LinearVelocity", toolObject)
    lv.Attachment0 = attachment
    lv.VectorVelocity = throwVector * 750000
    lv.MaxForce = 35000000
    
    game:GetService("Debris"):AddItem(lv, 0.3)
    game:GetService("Debris"):AddItem(attachment, 0.3)
end

-- Непрерывный цикл сканирования рук, тотальный сброс кэша истории и заталкивание под пол
RunService.Stepped:Connect(function()
    local myChar = LocalPlayer.Character
    if myChar then
        local currentGrabbedPart = nil

        -- Сканируем активные связи удержания в персонаже прямо в текущий кадр
        for _, part in pairs(myChar:GetDescendants()) do
            if part:IsA("Weld") or part:IsA("ManualWeld") or part:IsA("Constraint") or part:IsA("MoverConstraint") then
                local weldedPart = (part.Part0 and not part.Part0:IsDescendantOf(myChar) and part.Part0) or (part.Part1 and not part.Part1:IsDescendantOf(myChar) and part.Part1)
                if weldedPart and weldedPart:IsA("BasePart") then
                    currentGrabbedPart = weldedPart
                    break -- Нашли актуальный предмет, прекращаем поиск
                end
            end
        end
        
        if currentGrabbedPart then
            GlobalTrackedGrab.ActiveItem = currentGrabbedPart
            GlobalTrackedGrab.WasGrabbed = true
            if MaxThrowEnabled then
                -- Полное вжимание под пол, в микроволновку или стиральную машину
                currentGrabbedPart.CanCollide = false
                currentGrabbedPart.AssemblyLinearVelocity = Vector3.new(currentGrabbedPart.AssemblyLinearVelocity.X, -150, currentGrabbedPart.AssemblyLinearVelocity.Z)
            end
        else
            -- Момент разрыва связи (Клик по оригинальной кнопке Throw броска)
            if GlobalTrackedGrab.WasGrabbed and GlobalTrackedGrab.ActiveItem then
                if MaxThrowEnabled then
                    applyMaxThrowPhysics(GlobalTrackedGrab.ActiveItem)
                end
                -- ОБНУЛЕНИЕ КЭША: Скрипт мгновенно забывает старый предмет и готов к новой цели
                GlobalTrackedGrab.ActiveItem = nil
                GlobalTrackedGrab.WasGrabbed = false
            end
        end
    end
end)

-- -------------------------------------------------------------------------------
-- ФУНКЦИЯ 4: ИСТИННАЯ СЕРВЕРНАЯ ЧЕРНАЯ ДЫРА НА ФИЗИЧЕСКИХ КОНСТРЕЙНТАХ
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
    
    OrbitAngle = OrbitAngle + math.rad(5)
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
            -- Выстраивание кольца орбиты рук с заталкиванием под пол на -4 единицы
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
            
            -- Огромная принудительная отрицательная скорость вжатия
            element.AssemblyLinearVelocity = Vector3.new(0, -45000, 0)
        end
    end
end)

-- -------------------------------------------------------------------------------
-- ФУНКЦИЯ 5: НАДЁЖНЫЙ НАТИВНЫЙ АНТИ-ГРАБ ПО МЕТОДАМ ЯДРА ФОРУМА
-- -------------------------------------------------------------------------------
local function SecureCharacter(char)
    char.DescendantAdded:Connect(function(descendant)
        if AntiGrabEnabled and (descendant:IsA("Weld") or descendant:IsA("ManualWeld") or descendant:IsA("Constraint") or descendant:IsA("MoverConstraint")) then
            task.wait(0.001)
            if descendant.Parent then
                local attackerChar = descendant.Parent
                -- Сверяем, что это чужой хват, и ломаем суставы ИМЕННО нападающему агрессору, а не себе
                if attackerChar ~= char and not descendant:IsDescendantOf(char) then
                    local enemyModel = descendant:FindFirstAncestorOfClass("Model")
                    if enemyModel and enemyModel:FindFirstChild("Humanoid") and enemyModel.Name ~= LocalPlayer.Name then
                        enemyModel:BreakJoints() -- Тотальный разрыв рук нападающему врагу
                        descendant:Destroy()
                    end
                end
            end
        end
    end)
end

if LocalPlayer.Character then SecureCharacter(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(SecureCharacter)

-- ОРИГИНАЛЬНЫЙ СТАБИЛЬНЫЙ ГЕНЕРАТОР КНОПОК ПЕРЕКЛЮЧЕНИЯ ИНТЕРФЕЙСА МЕНЮ
local function CreateToggle(name, pos, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 200, 0, 35)
    Btn.Position = pos
    Btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.TextSize = 12
    Btn.Font = Enum.Font.GothamBold
    Btn.Text = name .. ": OFF"
    Btn.Parent = MainFrame
    
    local active = false
    Btn.MouseButton1Click:Connect(function()
        active = not active
        Btn.Text = name .. (active and ": ON" or ": OFF")
        Btn.BackgroundColor3 = active and Color3.fromRGB(0, 140, 60) or Color3.fromRGB(45, 45, 55)
        callback(active)
    end)
end

CreateToggle("Silent Aim", UDim2.new(0, 200, 0, 55), function(v) SilentAimEnabled = v end)
CreateToggle("Max Throw", UDim2.new(0, 200, 0, 95), function(v) MaxThrowEnabled = v end)
CreateToggle("Black Hole", UDim2.new(0, 200, 0, 135), function(v) BlackHoleEnabled = v end)
CreateToggle("Anti Grab", UDim2.new(0, 200, 0, 175), function(v) AntiGrabEnabled = v end)

RefreshPlayerList()
print("[Delta iPad Script Setup Complete V23: Success Stable GUI]")
