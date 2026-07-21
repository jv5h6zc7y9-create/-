-- ============================================================================
-- FLING THINGS AND PEOPLE: FULL MONOLITHIC PRODUCTION SCRIPT FOR DELTA IOS
-- PLAYERGUI INTERFACE REWRITE - STABLE TOUCH DETECTOR & PHYSICS IMMUNITY
-- ============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
-- Перенаправление интерфейса в безопасную директорию для обхода блокировок Delta
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = Workspace.CurrentCamera

-- Глобальная таблица конфигурации и переключателей
local Toggles = {
    MaxFarThrow = true,
    SilentAim = true,
    BlackHole = false,
    AntiGrab = true
}

-- Физические и координатные настройки
local fovRadius = 250
local blackHoleRadius = 55
local currentHeldObject = nil
local activeSilentTarget = nil

-- Защитные таймеры (Debounce) для предотвращения крашей памяти Delta
local AntiGrabCooldown = 0
local LastScanTime = 0

-- ============================================================================
-- MODULE 1: ACTIVE TARGET-RESET MAX FAR THROW & EXTENTS SHOVING
-- ============================================================================
local function safeProcessHeldVelocity(part)
    if not part or not part.Parent then return end
    pcall(function()
        part.CanCollide = false
        part.AssemblyLinearVelocity = Vector3.new(0, -85, 0)
    end)
end

RunService.RenderStepped:Connect(function()
    if not Toggles.MaxFarThrow then 
        currentHeldObject = nil
        return 
    end
    
    currentHeldObject = nil
    local character = LocalPlayer.Character
    if not character then return end
    
    -- Легковесный итератор по инвентарю и структуре персонажа (Защита ОЗУ)
    local activeTool = character:FindFirstChildOfClass("Tool")
    if activeTool and activeTool:FindFirstChild("Handle") then
        currentHeldObject = activeTool.Handle
    else
        for _, child in ipairs(character:GetChildren()) do
            if child:IsA("BasePart") and (child.Name == "Handle" or child.Name == "LeftHand" or child.Name == "RightHand") then
                local holdWeld = child:FindFirstChild("HoldWeld") or child:FindFirstChild("GrabWeld")
                if holdWeld and holdWeld.Part1 then
                    currentHeldObject = holdWeld.Part1
                    break
                end
            end
        end
    end
    
    -- Динамический поиск объектов в радиусе подхвата рук
    if not currentHeldObject then
        local root = character:FindFirstChild("HumanoidRootPart")
        if root then
            local now = tick()
            if now - LastScanTime > 0.1 then -- Сканируем окружение не чаще 10 раз в секунду
                LastScanTime = now
                for _, obj in ipairs(Workspace:GetChildren()) do
                    if obj:IsA("Model") and obj ~= character then
                        local primary = obj.PrimaryPart or obj:FindFirstChild("Handle")
                        if primary and (primary.Position - root.Position).Magnitude < 10 then
                            currentHeldObject = primary
                            break
                        end
                    end
                end
            end
        end
    end

    if currentHeldObject then
        safeProcessHeldVelocity(currentHeldObject)
    end
end)

Workspace.DescendantRemoving:Connect(function(descendant)
    if not Toggles.MaxFarThrow then return end
    if descendant == currentHeldObject or (currentHeldObject and descendant == currentHeldObject.Parent) then
        pcall(function()
            if currentHeldObject:IsA("BasePart") then
                currentHeldObject.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
                currentHeldObject.AssemblyMass = 0
                
                local cameraLook = Camera.CFrame.LookVector
                local ImpulseForce = (cameraLook * 17500000) + Vector3.new(0, 4200, 0)
                
                currentHeldObject:ApplyImpulse(ImpulseForce)
                currentHeldObject.AssemblyLinearVelocity = ImpulseForce
            end
        end)
        currentHeldObject = nil
    end
end)

-- ============================================================================
-- MODULE 2: DYNAMIC NEAREST-TARGET SILENT AIM (TOUCH DEPLOYMENT)
-- ============================================================================
local function findNearestLivingPlayer()
    if not Toggles.SilentAim then return nil end
    
    local target = nil
    local maxDistance = fovRadius
    local viewportCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local rootPart = player.Character.HumanoidRootPart
                local screenPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                
                if onScreen then
                    local screenVector = Vector2.new(screenPos.X, screenPos.Y)
                    local distanceToCenter = (screenVector - viewportCenter).Magnitude
                    
                    if distanceToCenter < maxDistance then
                        maxDistance = distanceToCenter
                        target = player
                    end
                end
            end
        end
    end
    return target
end

RunService.Heartbeat:Connect(function()
    activeSilentTarget = findNearestLivingPlayer()
    if Toggles.SilentAim and activeSilentTarget and activeSilentTarget.Character and currentHeldObject then
        local enemyRoot = activeSilentTarget.Character:FindFirstChild("HumanoidRootPart")
        if enemyRoot and currentHeldObject.Parent then
            pcall(function()
                local aimDirection = (enemyRoot.Position - currentHeldObject.Position).Unit
                currentHeldObject.AssemblyLinearVelocity = aimDirection * 160
            end)
        end
    end
end)

-- ============================================================================
-- MODULE 3: FORCED ASSEMBLY BLACK HOLE WITH REMOTE FALLBACK
-- ============================================================================
local function findWashingMachineEpicenter()
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj:IsA("Model") and (obj.Name:lower():find("washing") or obj.Name:lower():find("microwave")) then
            local base = obj:FindFirstChildOfClass("BasePart") or obj.PrimaryPart
            if base then return base end
        end
    end
    return nil
end

local function executeInventoryRemoteRequest()
    local targetRemote = ReplicatedStorage:FindFirstChild("SpawnToy") or (ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("SpawnItem"))
    if targetRemote and targetRemote:IsA("RemoteEvent") then
        targetRemote:FireServer("WashingMachine")
    end
end

task.spawn(function()
    while true do
        task.wait(0.06) -- Оптимальная задержка для сохранения стабильности процессора iPad
        if Toggles.BlackHole then
            local char = LocalPlayer.Character
            local myRoot = char and char:FindFirstChild("HumanoidRootPart")
            
            if myRoot then
                local epicenter = findWashingMachineEpicenter()
                if not epicenter then
                    executeInventoryRemoteRequest()
                    task.wait(0.5)
                    epicenter = findWashingMachineEpicenter()
                end
                
                local centerPos = epicenter and epicenter.Position or myRoot.Position
                local globalTime = tick() * 3.8
                local orbitDist = 6.5
                
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local eRoot = player.Character.HumanoidRootPart
                        local eHum = player.Character:FindFirstChildOfClass("Humanoid")
                        
                        if eHum and eHum.Health > 0 then
                            local separation = (eRoot.Position - centerPos).Magnitude
                            if separation <= blackHoleRadius then
                                pcall(function()
                                    eHum.PlatformStand = true
                                    eRoot.CanCollide = false
                                    
                                    local offsetId = player.UserId % 10
                                    local calculatedX = centerPos.X + math.cos(globalTime + offsetId) * orbitDist
                                    local calculatedZ = centerPos.Z + math.sin(globalTime + offsetId) * orbitDist
                                    local targetVector = Vector3.new(calculatedX, centerPos.Y, calculatedZ)
                                    
                                    local pullForce = (targetVector - eRoot.Position)
                                    eRoot.AssemblyLinearVelocity = (pullForce * 9.5) + Vector3.new(0, -75, 0)
                                end)
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- ============================================================================
-- MODULE 4: NATIVE ANTI-GRAB (СТАБИЛИЗИРОВАННАЯ СЕТЕВАЯ ЗАЩИТА)
-- ============================================================================
local function configureImmunityListener(character)
    character.DescendantAdded:Connect(function(descendant)
        if not Toggles.AntiGrab then return end
        -- Смягченная маска триггеров: реагируем только на швы удержания
        if descendant:IsA("Weld") or descendant:IsA("ManualWeld") or descendant.Name:lower():find("weld") or descendant.Name == "HoldWeld" then
            local currentTime = tick()
            if currentTime - AntiGrabCooldown > 0.1 then -- Лимитер частоты выполнения (Rate-Limiter) против крашей
                AntiGrabCooldown = currentTime
                task.wait(0.015) -- Увеличенный безопасный пинг-тайминг для репликации Delta
                pcall(function()
                    local structureParent = descendant.Parent
                    local enemyCharacter = nil
                    -- Поиск модели противника вверх по иерархии
                    while structureParent and structureParent ~= Workspace do
                        if structureParent:IsA("Model") and structureParent:FindFirstChildOfClass("Humanoid") and structureParent ~= character then
                            enemyCharacter = structureParent
                            break
                        end
                        structureParent = structureParent.Parent
                    end
                    if enemyCharacter then
                        -- Сбиваем захват противнику, заставляя его упасть (Безопасно для сервера)
                        local enemyHumanoid = enemyCharacter:FindFirstChildOfClass("Humanoid")
                        if enemyHumanoid then
                            enemyHumanoid.PlatformStand = true
                        end
                    end
                    -- Безвозвратное уничтожение узла захвата в нашем персонаже
                    descendant:Destroy()
                    -- Принудительное удаление остаточных физических сил из RootPart
                    local myRoot = character:FindFirstChild("HumanoidRootPart")
                    if myRoot then
                        for _, element in ipairs(myRoot:GetChildren()) do
                            if element:IsA("BodyMover") or element:IsA("Constraint") then
                                element:Destroy()
                            end
                        end
                    end
                end)
            end
        end
    end)
end

if LocalPlayer.Character then configureImmunityListener(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(configureImmunityListener)

-- ============================================================================
-- INTERFACE DEVELOPMENT: ANTI-CRASH STABLE DARK MENU FOR iPAD (PLAYERGUI FIX)
-- ============================================================================
local function createMobileSafeInterface()
    local existingGui = PlayerGui:FindFirstChild("DeltaFlingMenu")
    if existingGui then existingGui:Destroy() end
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "DeltaFlingMenu"
    ScreenGui.ResetOnSpawn = false
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 350, 0, 280)
    MainFrame.Position = UDim2.new(0.5, -175, 0.4, -140)
    MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    
    -- КАСТОМНЫЙ МОБИЛЬНЫЙ СКРИПТ ПЕРЕТАСКИВАНИЯ (ЗАМЕНА DRAGGABLE = TRUE)
    local isDraggingMenu = false
    local dragInputData, dragStartVector, startPositionVector
    local function updateMenuPosition(inputObj)
        local deltaVector = inputObj.Position - dragStartVector
        MainFrame.Position = UDim2.new(startPositionVector.X.Scale, startPositionVector.X.Offset + deltaVector.X, startPositionVector.Y.Scale, startPositionVector.Y.Offset + deltaVector.Y)
    end
    
    MainFrame.InputBegan:Connect(function(inputObj)
        if inputObj.UserInputType == Enum.UserInputType.MouseButton1 or inputObj.UserInputType == Enum.UserInputType.Touch then
            isDraggingMenu = true
            dragStartVector = inputObj.Position
            startPositionVector = MainFrame.Position
            inputObj.Changed:Connect(function()
                if inputObj.UserInputState == Enum.UserInputState.End then
                    isDraggingMenu = false
                end
            end)
        end
    end)
    
    MainFrame.InputChanged:Connect(function(inputObj)
        if inputObj.UserInputType == Enum.UserInputType.MouseMovement or inputObj.UserInputType == Enum.UserInputType.Touch then
            dragInputData = inputObj
        end
    end)
    
    UserInputService.InputChanged:Connect(function(inputObj)
        if inputObj == dragInputData and isDraggingMenu then
            updateMenuPosition(inputObj)
        end
    end)
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = MainFrame
    
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 40)
    TopBar.BackgroundColor3 = Color3.fromRGB(26, 26, 32)
    TopBar.BorderSizePixel = 0
    TopBar.Parent = MainFrame
    
    local TopCorner = Instance.new("UICorner")
    TopCorner.CornerRadius = UDim.new(0, 8)
    TopCorner.Parent = TopBar
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -50, 1, 0)
    TitleLabel.Position = UDim2.new(0, 12, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = "FLING THINGS // CRASH SHIELD v4"
    TitleLabel.TextColor3 = Color3.fromRGB(245, 245, 250)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 13
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TopBar
    
    local ScrollContainer = Instance.new("ScrollingFrame")
    ScrollContainer.Size = UDim2.new(1, -16, 1, -55)
    ScrollContainer.Position = UDim2.new(0, 8, 0, 50)
    ScrollContainer.BackgroundTransparency = 1
    ScrollContainer.BorderSizePixel = 0
    ScrollContainer.ScrollBarThickness = 2
    ScrollContainer.ScrollBarImageColor3 = Color3.fromRGB(55, 55, 65)
    ScrollContainer.Parent = MainFrame
    
    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 6)
    UIListLayout.Parent = ScrollContainer
    
    local function generateMenuRow(textName, mapKey, layoutIndex)
        local RowFrame = Instance.new("Frame")
        RowFrame.Size = UDim2.new(1, -4, 0, 40)
        RowFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
        RowFrame.BorderSizePixel = 0
        RowFrame.LayoutOrder = layoutIndex
        RowFrame.Parent = ScrollContainer
        
        local RowCorner = Instance.new("UICorner")
        RowCorner.CornerRadius = UDim.new(0, 6)
        RowCorner.Parent = RowFrame
        
        local RowText = Instance.new("TextLabel")
        RowText.Size = UDim2.new(0.7, 0, 1, 0)
        RowText.Position = UDim2.new(0, 10, 0, 0)
        RowText.BackgroundTransparency = 1
        RowText.Text = textName
        RowText.TextColor3 = Color3.fromRGB(215, 215, 225)
        RowText.Font = Enum.Font.GothamSemibold
        RowText.TextSize = 11
        RowText.TextXAlignment = Enum.TextXAlignment.Left
        RowText.Parent = RowFrame
        
        local ButtonObj = Instance.new("TextButton")
        ButtonObj.Size = UDim2.new(0, 65, 0, 22)
        ButtonObj.Position = UDim2.new(1, -75, 0.5, -11)
        ButtonObj.BorderSizePixel = 0
        ButtonObj.Font = Enum.Font.GothamBold
        ButtonObj.TextSize = 9
        ButtonObj.Parent = RowFrame
        
        local ButtonCorner = Instance.new("UICorner")
        ButtonCorner.CornerRadius = UDim.new(0, 4)
        ButtonCorner.Parent = ButtonObj
        
        local function updateVisualState()
            if Toggles[mapKey] then
                ButtonObj.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
                ButtonObj.TextColor3 = Color3.fromRGB(255, 255, 255)
                ButtonObj.Text = "ACTIVE"
            else
                ButtonObj.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
                ButtonObj.TextColor3 = Color3.fromRGB(255, 255, 255)
                ButtonObj.Text = "DISABLED"
            end
        end
        
        ButtonObj.MouseButton1Click:Connect(function()
            Toggles[mapKey] = not Toggles[mapKey]
            updateVisualState()
        end)
        
        updateVisualState()
    end
    
    generateMenuRow("Active Target-Reset Max Throw", "MaxFarThrow", 1)
    generateMenuRow("Dynamic Screen-Center Silent Aim", "SilentAim", 2)
    generateMenuRow("Forced Teleport Black Hole Loop", "BlackHole", 3)
    generateMenuRow("Native Packet Anti-Grab Shield", "AntiGrab", 4)
    
    local SeparationRow = Instance.new("Frame")
    SeparationRow.Size = UDim2.new(1, -4, 0, 15)
    SeparationRow.BackgroundTransparency = 1
    SeparationRow.LayoutOrder = 5
    SeparationRow.Parent = ScrollContainer
    
    local SeparationLine = Instance.new("Frame")
    SeparationLine.Size = UDim2.new(1, 0, 0, 1)
    SeparationLine.Position = UDim2.new(0, 0, 0.5, 0)
    SeparationLine.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    SeparationLine.BorderSizePixel = 0
    SeparationLine.Parent = SeparationRow
    
    local SliderRow = Instance.new("Frame")
    SliderRow.Size = UDim2.new(1, -4, 0, 50)
    SliderRow.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
    SliderRow.LayoutOrder = 6
    SliderRow.Parent = ScrollContainer
    
    local SliderCorner = Instance.new("UICorner")
    SliderCorner.CornerRadius = UDim.new(0, 6)
    SliderCorner.Parent = SliderRow
    
    local SliderTitle = Instance.new("TextLabel")
    SliderTitle.Size = UDim2.new(0.6, 0, 0, 20)
    SliderTitle.Position = UDim2.new(0, 10, 0, 4)
    SliderTitle.BackgroundTransparency = 1
    SliderTitle.Text = "Silent Aim FOV Radius"
    SliderTitle.TextColor3 = Color3.fromRGB(215, 215, 225)
    SliderTitle.Font = Enum.Font.GothamSemibold
    SliderTitle.TextSize = 11
    SliderTitle.TextXAlignment = Enum.TextXAlignment.Left
    SliderTitle.Parent = SliderRow
    
    local SliderValue = Instance.new("TextLabel")
    SliderValue.Size = UDim2.new(0.3, 0, 0, 20)
    SliderValue.Position = UDim2.new(1, -105, 0, 4)
    SliderValue.BackgroundTransparency = 1
    SliderValue.Text = tostring(fovRadius) .. " px"
    SliderValue.TextColor3 = Color3.fromRGB(46, 204, 113)
    SliderValue.Font = Enum.Font.GothamBold
    SliderValue.TextSize = 11
    SliderValue.TextXAlignment = Enum.TextXAlignment.Right
    SliderValue.Parent = SliderRow
    
    local SliderTrack = Instance.new("TextButton")
    SliderTrack.Size = UDim2.new(1, -20, 0, 6)
    SliderTrack.Position = UDim2.new(0, 10, 1, -14)
    SliderTrack.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
    SliderTrack.Text = ""
    SliderTrack.Parent = SliderRow
    
    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new((fovRadius - 50) / 450, 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderTrack
    
    local isSliding = false
    local function updateSliderTrackFill(inputObj)
        local trackWidth = SliderTrack.AbsoluteSize.X
        local relativePositionX = inputObj.Position.X - SliderTrack.AbsolutePosition.X
        local scalingFactor = math.clamp(relativePositionX / trackWidth, 0, 1)
        fovRadius = math.floor(50 + (scalingFactor * 450))
        SliderValue.Text = tostring(fovRadius) .. " px"
        SliderFill.Size = UDim2.new(scalingFactor, 0, 1, 0)
    end
    
    SliderTrack.InputBegan:Connect(function(inputObj)
        if inputObj.UserInputType == Enum.UserInputType.MouseButton1 or inputObj.UserInputType == Enum.UserInputType.Touch then
            isSliding = true
            updateSliderTrackFill(inputObj)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(inputObj)
        if isSliding and (inputObj.UserInputType == Enum.UserInputType.MouseMovement or inputObj.UserInputType == Enum.UserInputType.Touch) then
            updateSliderTrackFill(inputObj)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(inputObj)
        if inputObj.UserInputType == Enum.UserInputType.MouseButton1 or inputObj.UserInputType == Enum.UserInputType.Touch then
            isSliding = false
        end
    end)
    
    local CollapseButton = Instance.new("TextButton")
    CollapseButton.Size = UDim2.new(0, 26, 0, 26)
    CollapseButton.Position = UDim2.new(1, -34, 0.5, -13)
    CollapseButton.BackgroundColor3 = Color3.fromRGB(36, 36, 44)
    CollapseButton.Text = "-"
    CollapseButton.TextColor3 = Color3.fromRGB(240, 240, 245)
    CollapseButton.TextSize = 14
    CollapseButton.Parent = TopBar
    
    local menuCollapsed = false
    CollapseButton.MouseButton1Click:Connect(function()
        menuCollapsed = not menuCollapsed
        if menuCollapsed then
            ScrollContainer.Visible = false
            MainFrame.Size = UDim2.new(0, 350, 0, 40)
            CollapseButton.Text = "+"
        else
            ScrollContainer.Visible = true
            MainFrame.Size = UDim2.new(0, 350, 0, 280)
            CollapseButton.Text = "-"
        end
    end)
    
    ScrollContainer.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
    ScreenGui.Parent = PlayerGui
end

createMobileSafeInterface()
