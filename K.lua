-- Fling Things and People: Full Monolithic Production Script Optimized for Delta iOS
-- No shortcuts, no abbreviations, no omissions. Completely written from scratch.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Global Feature Toggles (Controlled by UI)
local Toggles = {
    MaxFarThrow = true,
    SilentAim = true,
    BlackHole = false,
    AntiGrab = true
}

-- ============================================================================
-- FEATURE 1: ACTIVE TARGET-RESET MAX FAR THROW & EXTENTS SHOVING
-- ============================================================================
local currentHeldObject = nil
local lastCacheFrameTime = 0

RunService.RenderStepped:Connect(function()
    if not Toggles.MaxFarThrow then return end
    
    -- Instant dynamic tracking cache reset every frame
    currentHeldObject = nil
    
    local character = LocalPlayer.Character
    if character then
        -- Scan character descendants for structural holding tools or welds
        for _, descendant in ipairs(character:GetDescendants()) do
            if (descendant:IsA("BasePart") and descendant.Name == "Handle") or (descendant.Parent and descendant.Parent.Name == "HoldWeld") then
                currentHeldObject = descendant
                break
            end
        end
        
        -- Fallback scan for objects physically welded to character hands via game system
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

    -- Process dynamic cramming while holding
    if currentHeldObject and currentHeldObject.Parent then
        pcall(function()
            currentHeldObject.CanCollide = false
            currentHeldObject.AssemblyLinearVelocity = Vector3.new(0, -150, 0)
        end)
    end
end)

-- Capture structural break to apply maximum physical force vector instantly
Workspace.DescendantRemoving:Connect(function(descendant)
    if not Toggles.MaxFarThrow then return end
    
    if descendant == currentHeldObject or (currentHeldObject and descendant == currentHeldObject.Parent) then
        pcall(function()
            currentHeldObject.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
            currentHeldObject.AssemblyMass = 0
            
            local lookVector = Camera.CFrame.LookVector
            local calculatedVelocity = (lookVector * 35000000) + Vector3.new(0, 7500, 0)
            
            -- Combine physical Impulse with hard-coded Linear Velocity parameters
            currentHeldObject:ApplyImpulse(calculatedVelocity)
            currentHeldObject.AssemblyLinearVelocity = calculatedVelocity
        end)
        currentHeldObject = nil
    end
end)

-- ============================================================================
-- FEATURE 2: DYNAMIC NEAREST-TARGET SILENT AIM
-- ============================================================================
local fovRadius = 250

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

-- Hook Engine Metamethods to bypass geometry barriers and redirect inputs
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
    local args = {...}
    
    if Toggles.SilentAim and not checkcaller() and (method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList" or method == "Raycast") then
        local targetPlayer = getClosestPlayerToScreenCenter()
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            -- Override raycast results to ignore walls and pass right to target root
            local root = targetPlayer.Character.HumanoidRootPart
            if method == "Raycast" then
                return Workspace:Raycast(Camera.CFrame.Position, (root.Position - Camera.CFrame.Position).Unit * 1000)
            end
        end
    end
    return oldNamecall(self, ...)
end)

-- ============================================================================
-- FEATURE 3: FORCED TELEPORT-GRAB ASSEMBLY BLACK HOLE WITH INVENTORY FALLBACK
-- ============================================================================
local function locateEpicenterMachine()
    for _, descendant in ipairs(Workspace:GetDescendants()) do
        if descendant:IsA("Model") and (descendant.Name:lower():find("washing") or descendant.Name:lower():find("microwave")) then
            local basePart = descendant:FindFirstChildOfClass("BasePart") or descendant.PrimaryPart
            if basePart then
                return basePart
            end
        end
    end
    return nil
end

local function invokeInventoryFallback()
    -- Look for standard game remote setups for toy/item deployment
    local spawnRemote = ReplicatedStorage:FindFirstChild("SpawnToy") or ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("SpawnItem")
    if spawnRemote and spawnRemote:IsA("RemoteEvent") then
        spawnRemote:FireServer("WashingMachine")
    elseif spawnRemote and spawnRemote:IsA("RemoteFunction") then
        pcall(function() spawnRemote:InvokeServer("WashingMachine") end)
    else
        -- Fallback loop over all ReplicatedStorage remotes to force trigger structural inventories
        for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
            if obj:IsA("RemoteEvent") and (obj.Name:lower():find("spawn") or obj.Name:lower():find("toy") or obj.Name:lower():find("item")) then
                obj:FireServer("WashingMachine")
                obj:FireServer("Washing Machine")
                obj:FireServer(1) 
            end
        end
    end
end

task.spawn(function()
    while true do
        task.wait(0.05)
        if Toggles.BlackHole then
            local character = LocalPlayer.Character
            local myRoot = character and character:FindFirstChild("HumanoidRootPart")
            
            if myRoot then
                local centerPart = locateEpicenterMachine()
                
                if not centerPart then
                    invokeInventoryFallback()
                    task.wait(0.2)
                    centerPart = locateEpicenterMachine()
                end
                
                local centerPosition = centerPart and centerPart.Position or myRoot.Position
                if centerPart and (centerPart.Position - myRoot.Position).Magnitude > 500 then
                    pcall(function() centerPart.CFrame = myRoot.CFrame * CFrame.new(0, -2, -5) end)
                end
                
                local rotationTime = tick() * 6
                local radius = 6
                
                -- Seize players and unanchored parts across the server space
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        pcall(function()
                            local tRoot = player.Character.HumanoidRootPart
                            local tHum = player.Character:FindFirstChildOfClass("Humanoid")
                            
                            if tHum and tHum.Health > 0 then
                                -- Break structural joints, force into ragdoll status, and disable collision
                                tHum.PlatformStand = true
                                tRoot.CanCollide = false
                                -- Math coordinate circle formulas to force objects into spinning orbit
                                local angleOffset = player.UserId % 10
                                local targetX = centerPosition.X + math.cos(rotationTime + angleOffset) * radius
                                local targetZ = centerPosition.Z + math.sin(rotationTime + angleOffset) * radius
                                tRoot.CFrame = CFrame.new(targetX, centerPosition.Y, targetZ)
                                tRoot.AssemblyLinearVelocity = Vector3.new(0, -45000, 0)
                            end
                            pcall(function()
                                -- Network claim trigger loop: Teleport local hand frames directly to seize them natively
                                local grabTool = character:FindFirstChildOfClass("Tool") or character:FindFirstChild("GripWeld")
                                if not grabTool then
                                    myRoot.CFrame = tRoot.CFrame
                                end
                            end)
                        end)
                    end
                end
                
                -- Seize loose items on the map
                for _, object in ipairs(Workspace:GetChildren()) do
                    if object:IsA("BasePart") and not object.Anchored and object.Name ~= "HumanoidRootPart" then
                        pcall(function()
                            object.CanCollide = false
                            local targetX = centerPosition.X + math.cos(rotationTime) * radius
                            local targetZ = centerPosition.Z + math.sin(rotationTime) * radius
                            object.CFrame = CFrame.new(targetX, centerPosition.Y, targetZ)
                            object.AssemblyLinearVelocity = Vector3.new(0, -45000, 0)
                        end)
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
        -- Watch for attachment packets, welds, or structural layout changes triggered by hostiles
        if descendant:IsA("Weld") or descendant:IsA("ManualWeld") or descendant:IsA("Constraint") or descendant:IsA("MoverConstraint") or descendant.Name:lower():find("weld") or descendant:IsA("AlignPosition") then
            task.wait(0.001) -- Network structural replication delay
            pcall(function()
                -- Trace upward parent hierarchies to pinpoint hostile actor
                local networkParent = descendant.Parent
                while networkParent and networkParent ~= Workspace do
                    if networkParent:IsA("Model") and networkParent:FindFirstChildOfClass("Humanoid") and networkParent ~= char then
                        -- Instantly break their character layout joints to drop grip
                        networkParent:BreakJoints()
                        break
                    end
                    networkParent = networkParent.Parent
                end
                -- Erase grab node instances from local space
                descendant:Destroy()
                -- Wipe leftover constraint residue forces out of root parameters
                local rootPart = char:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    for _, child in ipairs(rootPart:GetChildren()) do
                        if child:IsA("JointInstance") or child:IsA("Constraint") or child:IsA("BodyMover") then
                            child:Destroy()
                        end
                    end
                end
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
    -- Safely clear pre-existing GUI elements
    local olderGui = CoreGui:FindFirstChild("DeltaFlingMenu")
    if olderGui then olderGui:Destroy() end
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "DeltaFlingMenu"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = CoreGui
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UIDimensions or UDim2.new(0, 360, 0, 290)
    MainFrame.Position = UIPosition or UDim2.new(0.5, -180, 0.4, -145)
    MainFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true -- Standard engine-supported draggable protocol
    MainFrame.Parent = ScreenGui
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 10)
    UICorner.Parent = MainFrame
    
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
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
    
    -- Build Content Scrolling Layout for Tablet Touch Interactivity
    local ScrollContainer = Instance.new("ScrollingFrame")
    ScrollContainer.Size = UDim2.new(1, -20, 1, -65)
    ScrollContainer.Position = UDim2.new(0, 10, 0, 55)
    ScrollContainer.BackgroundTransparency = 1
    ScrollContainer.BorderSizePixel = 0
    ScrollContainer.CanvasSize = UDim2.new(0, 0, 0, 240)
    ScrollContainer.ScrollBarThickness = 4
    ScrollContainer.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 70)
    ScrollContainer.Parent = MainFrame
    
    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 8)
    UIListLayout.Parent = ScrollContainer
    
    -- Generic Toggle Configuration Module Loop
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
        ActionButton.AutoButtonColor = true
        ActionButton.Parent = RowFrame
        
        local ButtonCorner = Instance.new("UICorner")
        ButtonCorner.CornerRadius = UDim.new(0, 4)
        ButtonCorner.Parent = ActionButton
        
        local function refreshUIState()
            if Toggles[configKey] then
                ActionButton.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
                ActionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                ActionButton.Text = "ACTIVE"
            else
                ActionButton.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
                ActionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                ActionButton.Text = "DISABLED"
            end
        end
        
        ActionButton.MouseButton1Click:Connect(function()
            Toggles[configKey] = not Toggles[configKey]
            refreshUIState()
        end)
        
        refreshUIState()
    end
    
    -- Construct rows in layout hierarchy
    appendFeatureToggle("Active Target-Reset Max Throw", "MaxFarThrow", 1)
    appendFeatureToggle("Dynamic Screen-Center Silent Aim", "SilentAim", 2)
    appendFeatureToggle("Forced Teleport Black Hole Loop", "BlackHole", 3)
    appendFeatureToggle("Native Packet Anti-Grab Shield", "AntiGrab", 4)

    -- ============================================================================
    -- ДОПОЛНИТЕЛЬНЫЕ НАСТРОЙКИ И ДИНАМИЧЕСКИЕ ЭЛЕМЕНТЫ ИНТЕРФЕЙСА (ПРОДОЛЖЕНИЕ)
    -- ============================================================================
    
    -- Разделитель в меню
    local SeparatorRow = Instance.new("Frame")
    SeparatorRow.Size = UDim2.new(1, -6, 0, 20)
    SeparatorRow.BackgroundTransparency = 1
    SeparatorRow.BorderSizePixel = 0
    SeparatorRow.LayoutOrder = 5
    SeparatorRow.Parent = ScrollContainer

    local SeparatorLine = Instance.new("Frame")
    SeparatorLine.Size = UDim2.new(1, 0, 0, 1)
    SeparatorLine.Position = UDim2.new(0, 0, 0.5, 0)
    SeparatorLine.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    SeparatorLine.BorderSizePixel = 0
    SeparatorLine.Parent = SeparatorRow

    -- Слайдер изменения радиуса FOV для Silent Aim (удобно для сенсорных экранов iPad)
    local SliderRow = Instance.new("Frame")
    SliderRow.Size = UDim2.new(1, -6, 0, 60)
    SliderRow.BackgroundColor3 = Color3.fromRGB(36, 36, 44)
    SliderRow.BorderSizePixel = 0
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
    SliderTrack.Name = "SliderTrack"
    SliderTrack.Size = UDim2.new(1, -24, 0, 8)
    SliderTrack.Position = UDim2.new(0, 12, 1, -18)
    SliderTrack.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
    SliderTrack.BorderSizePixel = 0
    SliderTrack.Text = ""
    SliderTrack.AutoButtonColor = false
    SliderTrack.Parent = SliderRow

    local TrackCorner = Instance.new("UICorner")
    TrackCorner.CornerRadius = UDim.new(0, 4)
    TrackCorner.Parent = SliderTrack

    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new((fovRadius - 50) / 450, 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderTrack

    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(0, 4)
    FillCorner.Parent = SliderFill

    -- Логика перетаскивания ползунка пальцем на планшете
    local isSliding = false
    local function updateSliderPosition(inputInstance)
        local totalTrackWidth = SliderTrack.AbsoluteSize.X
        local relativeMouseX = inputInstance.Position.X - SliderTrack.AbsolutePosition.X
        local scaleFactor = math.clamp(relativeMouseX / totalTrackWidth, 0, 1)
        
        -- Диапазон радиуса FOV: от 50px до 500px
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

    -- Кнопка полного уничтожения скрипта и очистки памяти (Self-Destruct)
    local DestroyRow = Instance.new("Frame")
    DestroyRow.Size = UDim2.new(1, -6, 0, 45)
    DestroyRow.BackgroundColor3 = Color3.fromRGB(36, 36, 44)
    DestroyRow.BorderSizePixel = 0
    DestroyRow.LayoutOrder = 7
    DestroyRow.Parent = ScrollContainer

    local DestroyCorner = Instance.new("UICorner")
    DestroyCorner.CornerRadius = UDim.new(0, 6)
    DestroyCorner.Parent = DestroyRow

    local DestroyText = Instance.new("TextLabel")
    DestroyText.Size = UDim2.new(0.7, 0, 1, 0)
    DestroyText.Position = UDim2.new(0, 12, 0, 0)
    DestroyText.BackgroundTransparency = 1
    DestroyText.Text = "Unload Script Completely"
    DestroyText.TextColor3 = Color3.fromRGB(215, 215, 225)
    DestroyText.Font = Enum.Font.GothamSemibold
    DestroyText.TextSize = 12
    DestroyText.TextXAlignment = Enum.TextXAlignment.Left
    DestroyText.Parent = DestroyRow

    local UnloadButton = Instance.new("TextButton")
    UnloadButton.Size = UDim2.new(0, 65, 0, 26)
    UnloadButton.Position = UDim2.new(1, -75, 0.5, -13)
    UnloadButton.BackgroundColor3 = Color3.fromRGB(44, 62, 80)
    UnloadButton.BorderSizePixel = 0
    UnloadButton.Font = Enum.Font.GothamBold
    UnloadButton.TextSize = 10
    UnloadButton.Text = "UNLOAD"
    UnloadButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    UnloadButton.AutoButtonColor = true
    UnloadButton.Parent = DestroyRow

    local UnloadCorner = Instance.new("UICorner")
    UnloadCorner.CornerRadius = UDim.new(0, 4)
    UnloadCorner.Parent = UnloadButton

    UnloadButton.MouseButton1Click:Connect(function()
        Toggles.MaxFarThrow = false
        Toggles.SilentAim = false
        Toggles.BlackHole = false
        Toggles.AntiGrab = false
        ScreenGui:Destroy()
    end)

    -- Кнопка Свернуть/Развернуть меню (Toggle Visibility Button)
    local CollapseButton = Instance.new("TextButton")
    CollapseButton.Size = UDim2.new(0, 30, 0, 30)
    CollapseButton.Position = UDim2.new(1, -40, 0.5, -15)
    CollapseButton.BackgroundColor3 = Color3.fromRGB(44, 44, 52)
    CollapseButton.BorderSizePixel = 0
    CollapseButton.Font = Enum.Font.GothamBold
    CollapseButton.Text = "-"
    CollapseButton.TextColor3 = Color3.fromRGB(240, 240, 245)
    CollapseButton.TextSize = 16
    CollapseButton.Parent = TopBar

    local CollapseCorner = Instance.new("UICorner")
    CollapseCorner.CornerRadius = UDim.new(0, 6)
    CollapseCorner.Parent = CollapseButton

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

    -- Масштабирование CanvasSize под контент scrolling-фрейма
    ScrollContainer.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 15)
    UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ScrollContainer.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 15)
    end)
end

constructInterface()
