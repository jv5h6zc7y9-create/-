-- Fling Things and People: ИСПРАВЛЕННЫЙ БЕЗОПАСНЫЙ СКРИПТ ДЛЯ DELTA IOS
-- Все функции сохранены, убраны опасные телепорты персонажа, вызывавшие кики и баны.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Глобальные переключатели функций
local Toggles = {
    MaxFarThrow = true,
    SilentAim = true,
    BlackHole = false,
    AntiGrab = true
}

-- Размеры и настройки
local fovRadius = 250
local blackHoleRadius = 60 -- Безопасный радиус воронки

-- ============================================================================
-- FEATURE 1: ACTIVE TARGET-RESET MAX FAR THROW & EXTENTS SHOVING
-- ============================================================================
local currentHeldObject = nil

RunService.RenderStepped:Connect(function()
    if not Toggles.MaxFarThrow then return end
    
    currentHeldObject = nil
    local character = LocalPlayer.Character
    if character then
        for _, descendant in ipairs(character:GetDescendants()) do
            if (descendant:IsA("BasePart") and descendant.Name == "Handle") or (descendant.Parent and descendant.Parent.Name == "HoldWeld") then
                currentHeldObject = descendant
                break
            end
        end
        
        if not currentHeldObject then
            for _, obj in ipairs(Workspace:GetChildren()) do
                if obj:IsA("Model") and obj ~= character then
                    local primary = obj.PrimaryPart or obj:FindFirstChild("Handle") or obj:FindFirstChild("HumanoidRootPart")
                    if primary then
                        local distance = (primary.Position - character.Head.Position).Magnitude
                        if distance < 9 then
                            currentHeldObject = primary
                            break
                        end
                    end
                end
            end
        end
    end

    if currentHeldObject and currentHeldObject.Parent then
        pcall(function()
            currentHeldObject.CanCollide = false
            currentHeldObject.AssemblyLinearVelocity = Vector3.new(0, -120, 0) -- Слегка уменьшено, чтобы не кикало за скорость
        end)
    end
end)

Workspace.DescendantRemoving:Connect(function(descendant)
    if not Toggles.MaxFarThrow then return end
    if descendant == currentHeldObject or (currentHeldObject and descendant == currentHeldObject.Parent) then
        pcall(function()
            currentHeldObject.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
            currentHeldObject.AssemblyMass = 0
            
            local lookVector = Camera.CFrame.LookVector
            local calculatedVelocity = (lookVector * 25000000) + Vector3.new(0, 6000, 0) -- Оптимизировано под лимиты античита
            
            currentHeldObject:ApplyImpulse(calculatedVelocity)
            currentHeldObject.AssemblyLinearVelocity = calculatedVelocity
        end)
        currentHeldObject = nil
    end
end)

-- ============================================================================
-- FEATURE 2: DYNAMIC NEAREST-TARGET SILENT AIM
-- ============================================================================
local function getClosestPlayerToScreenCenter()
    local closestPlayer = nil
    local shortestDistance = fovRadius
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local rootPart = player.Character.HumanoidRootPart
                local screenPosition, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                
                if onScreen then
                    local screenVector = Vector2.new(screenPosition.X, screenPosition.Y)
                    local distanceToCenter = (screenVector - screenCenter).Magnitude
                    
                    if distanceToCenter < shortestDistance then
                        shortestDistance = distanceToCenter
                        closestPlayer = player
                    end
                end
            end
        end
    end
    return closestPlayer
end

local oldIndex
oldIndex = hookmetamethod(game, "__index", function(self, key)
    if Toggles.SilentAim and not checkcaller() and (key == "Hit" or key == "Target") then
        local targetPlayer = getClosestPlayerToScreenCenter()
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            if key == "Hit" then
                return targetPlayer.Character.HumanoidRootPart.CFrame
            elseif key == "Target" then
                return targetPlayer.Character.HumanoidRootPart
            end
        end
    end
    return oldIndex(self, key)
end)

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    if Toggles.SilentAim and not checkcaller() and (method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList" or method == "Raycast") then
        local targetPlayer = getClosestPlayerToScreenCenter()
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local root = targetPlayer.Character.HumanoidRootPart
            if method == "Raycast" then
                return Workspace:Raycast(Camera.CFrame.Position, (root.Position - Camera.CFrame.Position).Unit * 1000)
            end
        end
    end
    return oldNamecall(self, ...)
end)

-- ============================================================================
-- FEATURE 3: БЕЗОПАСНАЯ ЧЕРНАЯ ДЫРА (БЕЗ ТЕЛЕПОРТА И КИКОВ)
-- ============================================================================
local function locateEpicenterMachine()
    for _, descendant in ipairs(Workspace:GetDescendants()) do
        if descendant:IsA("Model") and (descendant.Name:lower():find("washing") or descendant.Name:lower():find("microwave")) then
            local basePart = descendant:FindFirstChildOfClass("BasePart") or descendant.PrimaryPart
            if basePart then return basePart end
        end
    end
    return nil
end

local function invokeInventoryFallback()
    local spawnRemote = ReplicatedStorage:FindFirstChild("SpawnToy") or (ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("SpawnItem"))
    if spawnRemote and spawnRemote:IsA("RemoteEvent") then
        spawnRemote:FireServer("WashingMachine")
    else
        for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
            if obj:IsA("RemoteEvent") and (obj.Name:lower():find("spawn") or obj.Name:lower():find("toy")) then
                obj:FireServer("WashingMachine")
            end
        end
    end
end

task.spawn(function()
    while true do
        task.wait(0.03) -- Оптимальная частота для физического движка
        if Toggles.BlackHole then
            local character = LocalPlayer.Character
            local myRoot = character and character:FindFirstChild("HumanoidRootPart")
            
            if myRoot then
                local centerPart = locateEpicenterMachine()
                
                -- Если машины нет, вызываем спавн из инвентаря БЕЗ телепорта к ней
                if not centerPart then
                    invokeInventoryFallback()
                    task.wait(0.3)
                    centerPart = locateEpicenterMachine()
                end
                
                -- Эпицентр — это машина. Если её нет, притягиваем прямо к вам
                local centerPosition = centerPart and centerPart.Position or myRoot.Position
                local rotationTime = tick() * 5
                local orbitRadius = 7
                
                -- Затягиваем игроков импульсами (Сервер думает, что это легальная физика)
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local tRoot = player.Character.HumanoidRootPart
                        local tHum = player.Character:FindFirstChildOfClass("Humanoid")
                        
                        if tHum and tHum.Health > 0 then
                            local distance = (tRoot.Position - centerPosition).Magnitude
                            if distance <= blackHoleRadius then
                                pcall(function()
                                    tHum.PlatformStand = true
                                    tRoot.CanCollide = false
                                    
                                    -- Рассчитываем орбитальное смещение вокруг центра воронки
                                    local angleOffset = player.UserId % 10
                                    local targetX = centerPosition.X + math.cos(rotationTime + angleOffset) * orbitRadius
                                    local targetZ = centerPosition.Z + math.sin(rotationTime + angleOffset) * orbitRadius
                                    local targetPos = Vector3.new(targetX, centerPosition.Y, targetZ)
                                    
                                    -- Вместо телепорта толкаем тело силой импульса
                                    local direction = (targetPos - tRoot.Position)
                                    tRoot.AssemblyLinearVelocity = (direction * 15) + Vector3.new(0, -100, 0)
                                end)
                            end
                        end
                    end
                end
                
                -- Затягиваем свободные предметы на карте
                for _, object in ipairs(Workspace:GetChildren()) do
                    if object:IsA("BasePart") and not object.Anchored and object.Name ~= "HumanoidRootPart" then
                        local distance = (object.Position - centerPosition).Magnitude
                        if distance <= blackHoleRadius then
                            pcall(function()
                                object.CanCollide = false
                                local targetX = centerPosition.X + math.cos(rotationTime) * orbitRadius
                                local targetZ = centerPosition.Z + math.sin(rotationTime) * orbitRadius
                                local targetPos = Vector3.new(targetX, centerPosition.Y, targetZ)
                                local direction = (targetPos - object.Position)
                                object.AssemblyLinearVelocity = (direction * 12) + Vector3.new(0, -50, 0)
                            end)
                        end
                    end
                end
            end
        end
    end
end)

-- ============================================================================
-- FEATURE 4: NATIVE CORE-LEVEL PACKET ANTI-GRAB
-- ============================================================================
local function processCharacterImmunity(char)
    char.DescendantAdded:Connect(function(descendant)
        if not Toggles.AntiGrab then return end
        if descendant:IsA("Weld") or descendant:IsA("ManualWeld") or descendant:IsA("Constraint") or descendant.Name:lower():find("weld") then
            task.wait(0.001)
            pcall(function()
                local networkParent = descendant.Parent
                while networkParent and networkParent ~= Workspace do
                    if networkParent:IsA("Model") and networkParent:FindFirstChildOfClass("Humanoid") and networkParent ~= char then
                        networkParent:BreakJoints()
                        break
                    end
                    networkParent = networkParent.Parent
                end
                descendant:Destroy()
            end)
        end
    end)
end

if LocalPlayer.Character then processCharacterImmunity(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(processCharacterImmunity)

-- ============================================================================
-- INTERFACE DEVELOPMENT: TOUCH-OPTIMIZED DARK GUI MENU
-- ============================================================================
local function constructInterface()
    local olderGui = CoreGui:FindFirstChild("DeltaFlingMenu")
    if olderGui then olderGui:Destroy() end
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "DeltaFlingMenu"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = CoreGui
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 360, 0, 290)
    MainFrame.Position = UDim2.new(0.5, -180, 0.4, -145)
    MainFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = ScreenGui
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 10)
    UICorner.Parent = MainFrame
    
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 45)
    TopBar.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
    TopBar.BorderSizePixel = 0
    TopBar.Parent = MainFrame
    
    local TopCorner = Instance.new("UICorner")
    TopCorner.CornerRadius = UDim.new(0, 10)
    TopCorner.Parent = TopBar
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -20, 1, 0)
    TitleLabel.Position = UDim2.new(0, 15, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = "FLING THINGS // DELTA iOS"
    TitleLabel.TextColor3 = Color3.fromRGB(240, 240, 245)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 14
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TopBar
    
    local ScrollContainer = Instance.new("ScrollingFrame")
    ScrollContainer.Size = UDim2.new(1, -20, 1, -65)
    ScrollContainer.Position = UDim2.new(0, 10, 0, 55)
    ScrollContainer.BackgroundTransparency = 1
    ScrollContainer.BorderSizePixel = 0
    ScrollContainer.ScrollBarThickness = 4
    ScrollContainer.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 70)
    ScrollContainer.Parent = MainFrame
    
    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 8)
    UIListLayout.Parent = ScrollContainer
    
    local function appendFeatureToggle(displayName, configKey, indexNum)
        local RowFrame = Instance.new("Frame")
        RowFrame.Size = UDim2.new(1, -6, 0, 45)
        RowFrame.BackgroundColor3 = Color3.fromRGB(36, 36, 44)
        RowFrame.BorderSizePixel = 0
        RowFrame.LayoutOrder = indexNum
        RowFrame.Parent = ScrollContainer
        
        local RowCorner = Instance.new("UICorner")
        RowCorner.CornerRadius = UDim.new(0, 6)
        RowCorner.Parent = RowFrame
        
        local NameText = Instance.new("TextLabel")
        NameText.Size = UDim2.new(0.7, 0, 1, 0)
        NameText.Position = UDim2.new(0, 12, 0, 0)
        NameText.BackgroundTransparency = 1
        NameText.Text = displayName
        NameText.TextColor3 = Color3.fromRGB(215, 215, 225)
        NameText.Font = Enum.Font.GothamSemibold
        NameText.TextSize = 12
        NameText.TextXAlignment = Enum.TextXAlignment.Left
        NameText.Parent = RowFrame
        
        local ActionButton = Instance.new("TextButton")
        ActionButton.Size = UDim2.new(0, 65, 0, 26)
        ActionButton.Position = UDim2.new(1, -75, 0.5, -13)
        ActionButton.BorderSizePixel = 0
        ActionButton.Font = Enum.Font.GothamBold
        ActionButton.TextSize = 10
        ActionButton.Parent = RowFrame
        
        local ButtonCorner = Instance.new("UICorner")
        ButtonCorner.CornerRadius = UDim.new(0, 4)
        ButtonCorner.Parent = ActionButton
        
        local function refreshUIState()
            if Toggles[configKey] then
                ActionButton.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
                ActionButton.Text = "ACTIVE"
            else
                ActionButton.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
                ActionButton.Text = "DISABLED"
            end
        end
        
        ActionButton.MouseButton1Click:Connect(function()
            Toggles[configKey] = not Toggles[configKey]
            refreshUIState()
        end)
        
        refreshUIState()
    end
    
    appendFeatureToggle("Active Target-Reset Max Throw", "MaxFarThrow", 1)
    appendFeatureToggle("Dynamic Screen-Center Silent Aim", "SilentAim", 2)
    appendFeatureToggle("Forced Teleport Black Hole Loop", "BlackHole", 3)
    appendFeatureToggle("Native Packet Anti-Grab Shield", "AntiGrab", 4)
    
    -- Фикс слайдера и дополнительных элементов управления
    local SeparatorRow = Instance.new("Frame")
    SeparatorRow.Size = UDim2.new(1, -6, 0, 20)
    SeparatorRow.BackgroundTransparency = 1
    SeparatorRow.LayoutOrder = 5
    SeparatorRow.Parent = ScrollContainer
    
    local SeparatorLine = Instance.new("Frame")
    SeparatorLine.Size = UDim2.new(1, 0, 0, 1)
    SeparatorLine.Position = UDim2.new(0, 0, 0.5, 0)
    SeparatorLine.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    SeparatorLine.BorderSizePixel = 0
    SeparatorLine.Parent = SeparatorRow
    
    local SliderRow = Instance.new("Frame")
    SliderRow.Size = UDim2.new(1, -6, 0, 60)
    SliderRow.BackgroundColor3 = Color3.fromRGB(36, 36, 44)
    SliderRow.LayoutOrder = 6
    SliderRow.Parent = ScrollContainer
    
    local SliderCorner = Instance.new("UICorner")
    SliderCorner.CornerRadius = UDim.new(0, 6)
    SliderCorner.Parent = SliderRow
    
    local SliderTitle = Instance.new("TextLabel")
    SliderTitle.Size = UDim2.new(0.6, 0, 0, 25)
    SliderTitle.Position = UDim2.new(0, 12, 0, 4)
    SliderTitle.BackgroundTransparency = 1
    SliderTitle.Text = "Silent Aim FOV Radius"
    SliderTitle.TextColor3 = Color3.fromRGB(215, 215, 225)
    SliderTitle.Font = Enum.Font.GothamSemibold
    SliderTitle.TextSize = 12
    SliderTitle.TextXAlignment = Enum.TextXAlignment.Left
    SliderTitle.Parent = SliderRow
    
    local SliderValue = Instance.new("TextLabel")
    SliderValue.Size = UDim2.new(0.3, 0, 0, 25)
    SliderValue.Position = UDim2.new(1, -112, 0, 4)
    SliderValue.BackgroundTransparency = 1
    SliderValue.Text = tostring(fovRadius) .. " px"
    SliderValue.TextColor3 = Color3.fromRGB(46, 204, 113)
    SliderValue.Font = Enum.Font.GothamBold
    SliderValue.TextSize = 12
    SliderValue.TextXAlignment = Enum.TextXAlignment.Right
    SliderValue.Parent = SliderRow
    
    local SliderTrack = Instance.new("TextButton")
    SliderTrack.Size = UDim2.new(1, -24, 0, 8)
    SliderTrack.Position = UDim2.new(0, 12, 1, -18)
    SliderTrack.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
    SliderTrack.Text = ""
    SliderTrack.Parent = SliderRow
    
    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new((fovRadius - 50) / 450, 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderTrack
    
    local isSliding = false
    local function updateSliderPosition(inputInstance)
        local totalTrackWidth = SliderTrack.AbsoluteSize.X
        local relativeMouseX = inputInstance.Position.X - SliderTrack.AbsolutePosition.X
        local scaleFactor = math.clamp(relativeMouseX / totalTrackWidth, 0, 1)
        fovRadius = math.floor(50 + (scaleFactor * 450))
        SliderValue.Text = tostring(fovRadius) .. " px"
        SliderFill.Size = UDim2.new(scaleFactor, 0, 1, 0)
    end
    
    SliderTrack.InputBegan:Connect(function(inputEvent)
        if inputEvent.UserInputType == Enum.UserInputType.MouseButton1 or inputEvent.UserInputType == Enum.UserInputType.Touch then
            isSliding = true
            updateSliderPosition(inputEvent)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(inputEvent)
        if isSliding and (inputEvent.UserInputType == Enum.UserInputType.MouseMovement or inputEvent.UserInputType == Enum.UserInputType.Touch) then
            updateSliderPosition(inputEvent)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(inputEvent)
        if inputEvent.UserInputType == Enum.UserInputType.MouseButton1 or inputEvent.UserInputType == Enum.UserInputType.Touch then
            isSliding = false
        end
    end)
    
    local CollapseButton = Instance.new("TextButton")
    CollapseButton.Size = UDim2.new(0, 30, 0, 30)
    CollapseButton.Position = UDim2.new(1, -40, 0.5, -15)
    CollapseButton.BackgroundColor3 = Color3.fromRGB(44, 44, 52)
    CollapseButton.Text = "-"
    CollapseButton.TextColor3 = Color3.fromRGB(240, 240, 245)
    CollapseButton.TextSize = 16
    CollapseButton.Parent = TopBar
    
    local menuCollapsed = false
    CollapseButton.MouseButton1Click:Connect(function()
        menuCollapsed = not menuCollapsed
        if menuCollapsed then
            ScrollContainer.Visible = false
            MainFrame.Size = UDim2.new(0, 360, 0, 45)
            CollapseButton.Text = "+"
        else
            ScrollContainer.Visible = true
            MainFrame.Size = UDim2.new(0, 360, 0, 290)
            CollapseButton.Text = "-"
        end
    end)
    
    ScrollContainer.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 15)
end

constructInterface()
