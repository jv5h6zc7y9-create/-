-- ====================================================================
-- IPAD FLING THINGS AND PEOPLE SUPREMACY V20 (PERFECT TARGET UPDATE)
-- NO SHORTCUTS - FULL EXPANDED SOURCE CODE FOR DELTA EXECUTOR iOS
-- ====================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- КОНФИГУРАЦИЯ (Все состояния включены по умолчанию для теста)
local SelectedTarget = nil
local SilentAimEnabled = true
local MaxThrowEnabled = true
local BlackHoleEnabled = false
local AntiGrabEnabled = true

-- Таблица для динамического отслеживания (Очищается каждый кадр)
local GlobalTrackedGrab = { ActiveItem = nil, WasGrabbed = false }

-- Поиск корневой части любого игрока
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
            if method == "Raycast" then
                local origin = args[1]
                args[2] = (predictedPos - origin).Unit * 10000
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
                        
                        -- Моментальный разрыв рук нападающему агрессору
                        attackerModel:BreakJoints()
                        
                        -- Очистка торса от вражеских сил притяжения
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
-- ФУНКЦИЯ 3: ИСПРАВЛЕННЫЙ СУПЕР-БРОСОК V20 (МГНОВЕННОЕ ОБНОВЛЕНИЕ ЦЕЛИ В РУКАХ)
-- -------------------------------------------------------------------------------
local function applyMaxThrowPhysics(toolObject)
    if not toolObject or not toolObject:IsA("BasePart") then return end
    pcall(function()
        toolObject.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
        toolObject.AssemblyMass = 0
        toolObject.Massless = true
    end)
    
    -- Вычисление траектории запуска
    local throwVector = Camera.CFrame.LookVector
    local inFovLimits = false
    
    if SilentAimEnabled and SelectedTarget and SelectedTarget.Character and SelectedTarget.Character:FindFirstChild("HumanoidRootPart") then
        local enemyRoot = SelectedTarget.Character.HumanoidRootPart
        inFovLimits = true
        throwVector = (getPredictedPosition(enemyRoot) - toolObject.Position).Unit
    else
        -- Если аим выключен, выстреливает в небо сквозь текстуры потолка
        throwVector = (Camera.CFrame.LookVector + Vector3.new(0, 3.5, 0)).Unit
    end

    -- Активация физического пакета броска на 35,000,000
    local lv = Instance.new("LinearVelocity")
    lv.MaxForce = math.huge
    lv.VectorVelocity = throwVector * 950000
    lv.Attachment0 = obj:FindFirstChildOfClass("Attachment") or Instance.new("Attachment", toolObject)
    lv.Parent = toolObject
    
    -- Тотальный сетевой пинок на уровне движка
    toolObject:ApplyImpulse(throwVector * 35000000)
    toolObject.AssemblyLinearVelocity = throwVector * 35000000
    
    game:GetService("Debris"):AddItem(lv, 0.3)
end

-- СВЕРХСКОРОСТНОЙ СКАНЕР: Полностью сбрасывает старый хват и обновляет его каждую миллисекунду
RunService.Stepped:Connect(function()
    local character = LocalPlayer.Character
    if not character then return end
    
    local currentGrabbedPart = nil

    -- Ищем активную связь удержания в персонаже прямо в этот кадр
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("Weld") or part:IsA("ManualWeld") or part:IsA("Constraint") or part:IsA("MoverConstraint") then
            local weldedPart = (part.Part0 and not part.Part0:IsDescendantOf(character) and part.Part0) or (part.Part1 and not part.Part1:IsDescendantOf(character) and part.Part1)
            
            if weldedPart and weldedPart:IsA("BasePart") then
                currentGrabbedPart = weldedPart
                break -- Нашли актуальный предмет, прекращаем поиск
            end
        end
    end

    -- Проверка состояния удержания
    if currentGrabbedPart then
        -- Если взяли новый предмет (или держим текущий) — обновляем переменную на него
        GlobalTrackedGrab.ActiveItem = currentGrabbedPart
        GlobalTrackedGrab.WasGrabbed = true

        -- Вжимание под пол и отключение коллизии (работает только на ТЕКУЩИЙ предмет)
        if MaxThrowEnabled then
            currentGrabbedPart.CanCollide = false
            currentGrabbedPart.AssemblyLinearVelocity = Vector3.new(currentGrabbedPart.AssemblyLinearVelocity.X, -150, currentGrabbedPart.AssemblyLinearVelocity.Z)
        end
    else
        -- МОМЕНТ БРОСКА КНОПКОЙ: если в этот кадр рук пуста, но в прошлый кадр вещь была
        if GlobalTrackedGrab.WasGrabbed and GlobalTrackedGrab.ActiveItem then
            if MaxThrowEnabled then
                applyMaxThrowPhysics(GlobalTrackedGrab.ActiveItem)
            end
            -- ТОТАЛЬНОЕ ОБНУЛЕНИЕ: Скрипт полностью забывает прошлый предмет и готов к новому хвату
            GlobalTrackedGrab.ActiveItem = nil
            GlobalTrackedGrab.WasGrabbed = false
        end
    end
end)

-- -------------------------------------------------------------------------------
-- ФУНКЦИЯ 4: ИСТИННАЯ СЕРВЕРНАЯ ЧЕРНАЯ ДЫРА
-- -------------------------------------------------------------------------------
local OrbitAngle = 0
local ActiveBlackHoleForces = {}

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

print("[Delta iOS: Версия V20 с полным фиксом авто-захвата успешно загружена!]")
