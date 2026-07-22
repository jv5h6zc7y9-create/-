--========================================================================================================--
--                                  CHAIRHUB ULTRA BYPASS FOR BLOXSTRIKE v4.0                             --
--                               DEVELOPED SPECIFICALLY FOR DELTA EXECUTOR (iOS)                          --
--                               PRODUCTION BUILD - MONOLITHIC CODEBASE - NO TRUNCATIONS                  --
--========================================================================================================--
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Состояние конфигурации ChairHub
local ChairHubConfig = {
    AimbotEnabled = false,
    TeamCheck = true,
    VisibleCheck = false,
    Smoothness = 0.20,
    MaxDistance = 250.00,
    PredictionScale = 0.045,
    
    ESPBoxes = false,
    ESPBoxesColor = Color3.fromRGB(255, 45, 45),
    ESPSkeletons = false,
    ESPSkeletonsColor = Color3.fromRGB(0, 255, 140),
    ESPDistance = false,
    
    FOVVisible = false,
    FOVValue = 130,
    FOVColor = Color3.fromRGB(0, 160, 255),
    
    SkinChangerEnabled = false,
    SelectedCategory = "Weapons",
    SelectedSkin = "Asimov"
}

-- Кэш-хранилища для минимизации нагрузки на процессор Apple
local MemoryCache = {
    ESPObjects = {},
    OriginalWeapons = {},
    Connections = {},
    UIVisible = true
}

-- Глобальная база данных скинов для BloxStrike
local GlobalSkinDatabase = {
    ["Weapons"] = {
        ["Asimov"] = { Texture = "rbxassetid://257913346", Material = Enum.Material.SmoothPlastic, Color = Color3.fromRGB(255, 120, 0) },
        ["Dragon Lore"] = { Texture = "rbxassetid://142071830", Material = Enum.Material.Fabric, Color = Color3.fromRGB(220, 190, 80) },
        ["Hyper Beast"] = { Texture = "rbxassetid://341498188", Material = Enum.Material.Glass, Color = Color3.fromRGB(200, 30, 150) },
        ["Printstream"] = { Texture = "rbxassetid://587425124", Material = Enum.Material.Neon, Color = Color3.fromRGB(255, 255, 255) }
    },
    ["Knives"] = {
        ["Karambit | Fade"] = { Texture = "rbxassetid://142071830", Material = Enum.Material.Glass, Color = Color3.fromRGB(255, 50, 150), Mesh = "rbxassetid://441991931" },
        ["Butterfly | Doppler"] = { Texture = "rbxassetid://341498188", Material = Enum.Material.Neon, Color = Color3.fromRGB(80, 0, 120), Mesh = "rbxassetid://540021626" }
    },
    ["Gloves"] = {
        ["Sport | Vice"] = { Texture = "rbxassetid://341498188", Material = Enum.Material.Fabric, Color = Color3.fromRGB(255, 0, 128) },
        ["Pandora Box"] = { Texture = "rbxassetid://142071830", Material = Enum.Material.Fabric, Color = Color3.fromRGB(100, 30, 220) }
    }
}

-- Валидация команд (Усиленный фикс под детекцию BloxStrike)
local function CalculateTeamRelation(targetModel)
    local targetPlayer = Players:GetPlayerFromCharacter(targetModel)
    if not targetPlayer then
        -- Фикс: Если модель лежит в кастомной папке рендеринга, ищем игрока по совпадению имени модели
        targetPlayer = Players:FindFirstChild(targetModel.Name)
    end
    
    if targetPlayer == LocalPlayer then return false end
    
    if ChairHubConfig.TeamCheck and targetPlayer then
        if LocalPlayer.Team and targetPlayer.Team and LocalPlayer.Team == targetPlayer.Team then return false end
        if LocalPlayer.TeamColor and targetPlayer.TeamColor and LocalPlayer.TeamColor == targetPlayer.TeamColor then return false end
    end
    return true
end

-- Мощный поисковик скрытых моделей персонажей BloxStrike во всех скрытых контейнерах
local function FetchAllGameCharacters()
    local characters = {}
    
    -- Проверка стандартного Workspace
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj:IsA("Model") and (obj:FindFirstChildOfClass("Humanoid") or obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Head")) then
            table.insert(characters, obj)
        end
    end
    
    -- Фикс для BloxStrike: Сканирование скрытых контейнеров и буферов рендеринга
    local ignoreBox = Workspace:FindFirstChild("IgnoreBox") or Workspace:FindFirstChild("Ignore")
    if ignoreBox then
        for _, obj in ipairs(ignoreBox:GetDescendants()) do
            if obj:IsA("Model") and (obj:FindFirstChildOfClass("Humanoid") or obj:FindFirstChild("Head")) then
                table.insert(characters, obj)
            end
        end
    end
    
    return characters
end

-- Инициализация GUI
local BaseScreenGui = Instance.new("ScreenGui")
BaseScreenGui.Name = "ChairHub_Bypass_Core"
BaseScreenGui.ResetOnSpawn = false
pcall(function() BaseScreenGui.Parent = CoreGui end)
if not BaseScreenGui.Parent then BaseScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- Железный Фикс круга аима: Рендеринг через Аппаратный UI вместо лагающего Drawing API
local HardwareFovFrame = Instance.new("Frame", BaseScreenGui)
HardwareFovFrame.Name = "HardwareFovRing"
HardwareFovFrame.AnchorPoint = Vector2.new(0.5, 0.5)
HardwareFovFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
HardwareFovFrame.BackgroundTransparency = 1
HardwareFovFrame.Visible = false

local FovStroke = Instance.new("UIStroke", HardwareFovFrame)
FovStroke.Color = ChairHubConfig.FOVColor
FovStroke.Thickness = ChairHubConfig.FOVThickness

local FovCorner = Instance.new("UICorner", HardwareFovFrame)
FovCorner.CornerRadius = UDim.new(1, 0)

local function SynchronizeFOVVisuals()
    HardwareFovFrame.Size = UDim2.new(0, ChairHubConfig.FOVValue * 2, 0, ChairHubConfig.FOVValue * 2)
    HardwareFovFrame.Visible = ChairHubConfig.FOVVisible and MemoryCache.UIVisible
    FovStroke.Color = ChairHubConfig.FOVColor
    FovStroke.Thickness = ChairHubConfig.FOVThickness
end

-- Сборка меню
local InterfaceFrame = Instance.new("Frame")
InterfaceFrame.Name = "InterfaceFrame"
InterfaceFrame.Size = UDim2.new(0, 420, 0, 360)
InterfaceFrame.Position = UDim2.new(0.5, -210, 0.5, -180)
InterfaceFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 27)
InterfaceFrame.BorderSizePixel = 0
InterfaceFrame.Active = true
InterfaceFrame.Parent = BaseScreenGui

Instance.new("UICorner", InterfaceFrame).CornerRadius = UDim.new(0, 8)

local InterfaceStroke = Instance.new("UIStroke", InterfaceFrame)
InterfaceStroke.Color = Color3.fromRGB(40, 44, 58)
InterfaceStroke.Thickness = 1.5

local SidebarContainer = Instance.new("Frame", InterfaceFrame)
SidebarContainer.Name = "SidebarContainer"
SidebarContainer.Size = UDim2.new(0, 120, 1, 0)
SidebarContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
SidebarContainer.BorderSizePixel = 0
Instance.new("UICorner", SidebarContainer).CornerRadius = UDim.new(0, 8)

local SidebarCover = Instance.new("Frame", SidebarContainer)
SidebarCover.Size = UDim2.new(0, 10, 1, 0)
SidebarCover.Position = UDim2.new(1, -10, 0, 0)
SidebarCover.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
SidebarCover.BorderSizePixel = 0

local LogoLabel = Instance.new("TextLabel", SidebarContainer)
LogoLabel.Size = UDim2.new(1, 0, 0, 45)
LogoLabel.BackgroundTransparency = 1
LogoLabel.Font = Enum.Font.GothamBold
LogoLabel.Text = "ChairHub."
LogoLabel.TextColor3 = Color3.fromRGB(0, 140, 255)
LogoLabel.TextSize = 15

local TabButtonsLayout = Instance.new("UIListLayout", SidebarContainer)
TabButtonsLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabButtonsLayout.Padding = UDim.new(0, 4)

local TabButtonsContainer = Instance.new("Frame", SidebarContainer)
TabButtonsContainer.Size = UDim2.new(1, 0, 1, -50)
TabButtonsContainer.Position = UDim2.new(0, 0, 0, 45)
TabButtonsContainer.BackgroundTransparency = 1
TabButtonsLayout.Parent = TabButtonsContainer

local DisplayContainer = Instance.new("Frame", InterfaceFrame)
DisplayContainer.Name = "DisplayContainer"
DisplayContainer.Size = UDim2.new(1, -130, 1, -15)
DisplayContainer.Position = UDim2.new(0, 125, 0, 10)
DisplayContainer.BackgroundTransparency = 1

local PagesRegistry = {}
local TabNavigationRegistry = {}

local function RegisterInterfacePage(pageName)
    local scrollingPage = Instance.new("ScrollingFrame", DisplayContainer)
    scrollingPage.Name = pageName .. "Page"
    scrollingPage.Size = UDim2.new(1, 0, 1, 0)
    scrollingPage.BackgroundTransparency = 1
    scrollingPage.Visible = false
    scrollingPage.ScrollBarThickness = 2
    scrollingPage.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    local listLayout = Instance.new("UIListLayout", scrollingPage)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 8)
    listLayout.Parent = scrollingPage
    
    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollingPage.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
    end)
    
    PagesRegistry[pageName] = scrollingPage
    
    local navButton = Instance.new("TextButton", TabButtonsContainer)
    navButton.Size = UDim2.new(0.9, 0, 0, 32)
    navButton.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
    navButton.BackgroundTransparency = 1
    navButton.Font = Enum.Font.GothamMedium
    navButton.Text = pageName
    navButton.TextColor3 = Color3.fromRGB(150, 152, 165)
    navButton.TextSize = 11
    Instance.new("UICorner", navButton).CornerRadius = UDim.new(0, 5)
    
    TabNavigationRegistry[pageName] = navButton
    
    navButton.MouseButton1Click:Connect(function()
        for pKey, pFrame in pairs(PagesRegistry) do
            pFrame.Visible = (pKey == pageName)
            if pKey == pageName then
                TweenService:Create(TabNavigationRegistry[pKey], TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0}):Play()
            else
                TweenService:Create(TabNavigationRegistry[pKey], TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(150, 152, 165), BackgroundTransparency = 1}):Play()
            end
        end
    end)
end

RegisterInterfacePage("Aimbot")
RegisterInterfacePage("ESP")
RegisterInterfacePage("FOV")
RegisterInterfacePage("Config")

PagesRegistry["Aimbot"].Visible = true
TabNavigationRegistry["Aimbot"].BackgroundTransparency = 0
TabNavigationRegistry["Aimbot"].TextColor3 = Color3.fromRGB(255, 255, 255)

local UI_Factory = {}

function UI_Factory.CreateSectionHeader(parentPage, headerTitle)
    local wrapper = Instance.new("Frame", parentPage)
    wrapper.Size = UDim2.new(0.96, 0, 0, 24)
    wrapper.BackgroundTransparency = 1
    
    local label = Instance.new("TextLabel", wrapper)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.Text = string.upper(headerTitle)
    label.TextColor3 = Color3.fromRGB(0, 140, 255)
    label.TextSize = 10
    label.TextXAlignment = Enum.TextXAlignment.Left
end

function UI_Factory.CreateFunctionalToggle(parentPage, textDescription, targetConfigKey)
    local toggleRow = Instance.new("Frame", parentPage)
    toggleRow.Size = UDim2.new(0.96, 0, 0, 36)
    toggleRow.BackgroundColor3 = Color3.fromRGB(26, 26, 36)
    Instance.new("UICorner", toggleRow).CornerRadius = UDim.new(0, 6)
    
    local rowStroke = Instance.new("UIStroke", toggleRow)
    rowStroke.Color = Color3.fromRGB(36, 40, 52)
    
    local description = Instance.new("TextLabel", toggleRow)
    description.Size = UDim2.new(0.7, 0, 1, 0)
    description.Position = UDim2.new(0.04, 0, 0, 0)
    description.BackgroundTransparency = 1
    description.Font = Enum.Font.GothamMedium
    description.Text = textDescription
    description.TextColor3 = Color3.fromRGB(220, 222, 235)
    description.TextSize = 11
    description.TextXAlignment = Enum.TextXAlignment.Left
    
    local switchButton = Instance.new("TextButton", toggleRow)
    switchButton.Size = UDim2.new(0, 42, 0, 20)
    switchButton.Position = UDim2.new(0.96, -42, 0.5, -10)
    switchButton.BackgroundColor3 = ChairHubConfig[targetConfigKey] and Color3.fromRGB(0, 140, 255) or Color3.fromRGB(48, 48, 60)
    switchButton.Text = ""
    Instance.new("UICorner", switchButton).CornerRadius = UDim.new(0, 10)
    
    local circularNode = Instance.new("Frame", switchButton)
    circularNode.Size = UDim2.new(0, 14, 0, 14)
    circularNode.Position = ChairHubConfig[targetConfigKey] and UDim2.new(1, -18, 0.5, -7) or UDim2.new(0, 4, 0.5, -7)
    circularNode.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", circularNode).CornerRadius = UDim.new(0, 7)
    
    switchButton.MouseButton1Click:Connect(function()
        ChairHubConfig[targetConfigKey] = not ChairHubConfig[targetConfigKey]
        local colorTarget = ChairHubConfig[targetConfigKey] and Color3.fromRGB(0, 140, 255) or Color3.fromRGB(48, 48, 60)
        local posTarget = ChairHubConfig[targetConfigKey] and UDim2.new(1, -18, 0.5, -7) or UDim2.new(0, 4, 0.5, -7)
        TweenService:Create(switchButton, TweenInfo.new(0.2), {BackgroundColor3 = colorTarget}):Play()
        TweenService:Create(circularNode, TweenInfo.new(0.2), {Position = posTarget}):Play()
        if targetConfigKey == "SkinChangerEnabled" and not ChairHubConfig.SkinChangerEnabled then
            ResetWeaponSkins()
        end
    end)
end

function UI_Factory.CreatePrecisionSlider(parentPage, textDescription, minimum, maximum, targetConfigKey, floatDecimalPoints)
    local sliderRow = Instance.new("Frame", parentPage)
    sliderRow.Size = UDim2.new(0.96, 0, 0, 46)
    sliderRow.BackgroundColor3 = Color3.fromRGB(26, 26, 36)
    Instance.new("UICorner", sliderRow).CornerRadius = UDim.new(0, 6)
    
    local rowStroke = Instance.new("UIStroke", sliderRow)
    rowStroke.Color = Color3.fromRGB(36, 40, 52)
    
    local description = Instance.new("TextLabel", sliderRow)
    description.Size = UDim2.new(0.8, 0, 0, 22)
    description.Position = UDim2.new(0.04, 0, 0, 2)
    description.BackgroundTransparency = 1
    description.Font = Enum.Font.GothamMedium
    description.Text = textDescription .. string.format(": %." .. floatDecimalPoints .. "f", ChairHubConfig[targetConfigKey])
    description.TextColor3 = Color3.fromRGB(220, 222, 235)
    description.TextSize = 11
    description.TextXAlignment = Enum.TextXAlignment.Left
    
    local trackButton = Instance.new("TextButton", sliderRow)
    trackButton.Size = UDim2.new(0.92, 0, 0, 4)
    trackButton.Position = UDim2.new(0.04, 0, 0, 32)
    trackButton.BackgroundColor3 = Color3.fromRGB(48, 48, 60)
    trackButton.Text = ""
    Instance.new("UICorner", trackButton).CornerRadius = UDim.new(0, 2)
    
    local fillNode = Instance.new("Frame", trackButton)
    local scaleFactor = (ChairHubConfig[targetConfigKey] - minimum) / (maximum - minimum)
    fillNode.Size = UDim2.new(scaleFactor, 0, 1, 0)
    fillNode.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
    Instance.new("UICorner", fillNode).CornerRadius = UDim.new(0, 2)
    
    local function ReevaluateFillPosition(absoluteInputX)
        local trackingDelta = absoluteInputX - trackButton.AbsolutePosition.X
        local clampedOffset = math.clamp(trackingDelta, 0, trackButton.AbsoluteWidth)
        local normalizedPercentage = clampedOffset / trackButton.AbsoluteWidth
        local calculation = minimum + (normalizedPercentage * (maximum - minimum))
        local scalarFactor = 10 ^ floatDecimalPoints
        ChairHubConfig[targetConfigKey] = math.round(calculation * scalarFactor) / scalarFactor
        
        description.Text = textDescription .. string.format(": %." .. floatDecimalPoints .. "f", ChairHubConfig[targetConfigKey])
        fillNode.Size = UDim2.new(normalizedPercentage, 0, 1, 0)
        if targetConfigKey == "FOVValue" then SynchronizeFOVVisuals() end
    end
    
    local dynamicMoveConnection = nil
    
    trackButton.InputBegan:Connect(function(inputEvent)
        if inputEvent.UserInputType == Enum.UserInputType.MouseButton1 or inputEvent.UserInputType == Enum.UserInputType.Touch then
            ReevaluateFillPosition(inputEvent.Position.X)
            dynamicMoveConnection = UserInputService.InputChanged:Connect(function(movementEvent)
                if movementEvent.UserInputType == Enum.UserInputType.MouseMovement or movementEvent.UserInputType == Enum.UserInputType.Touch then
                    ReevaluateFillPosition(movementEvent.Position.X)
                end
            end)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(releaseEvent)
        if releaseEvent.UserInputType == Enum.UserInputType.MouseButton1 or releaseEvent.UserInputType == Enum.UserInputType.Touch then
            if dynamicMoveConnection then dynamicMoveConnection:Disconnect() dynamicMoveConnection = nil end
        end
    end)
end

function UI_Factory.CreateCyclicSelector(parentPage, textDescription, valuesArray, targetConfigKey)
    local selectRow = Instance.new("Frame", parentPage)
    selectRow.Size = UDim2.new(0.96, 0, 0, 38)
    selectRow.BackgroundColor3 = Color3.fromRGB(26, 26, 36)
    Instance.new("UICorner", selectRow).CornerRadius = UDim.new(0, 6)
    
    local rowStroke = Instance.new("UIStroke", selectRow)
    rowStroke.Color = Color3.fromRGB(36, 40, 52)
    
    local description = Instance.new("TextLabel", selectRow)
    description.Size = UDim2.new(0.5, 0, 1, 0)
    description.Position = UDim2.new(0.04, 0, 0, 0)
    description.BackgroundTransparency = 1
    description.Font = Enum.Font.GothamMedium
    description.Text = textDescription
    description.TextColor3 = Color3.fromRGB(220, 222, 235)
    description.TextSize = 11
    description.TextXAlignment = Enum.TextXAlignment.Left
    
    local activeIndex = 1
    local triggerButton = Instance.new("TextButton", selectRow)
    triggerButton.Size = UDim2.new(0, 120, 0, 24)
    triggerButton.Position = UDim2.new(0.96, -120, 0.5, -12)
    triggerButton.BackgroundColor3 = Color3.fromRGB(38, 38, 50)
    triggerButton.Font = Enum.Font.GothamBold
    triggerButton.Text = tostring(ChairHubConfig[targetConfigKey])
    triggerButton.TextColor3 = Color3.fromRGB(0, 140, 255)
    triggerButton.TextSize = 10
    Instance.new("UICorner", triggerButton).CornerRadius = UDim.new(0, 5)
    
    triggerButton.MouseButton1Click:Connect(function()
        activeIndex = activeIndex + 1
        if activeIndex > #valuesArray then activeIndex = 1 end
        ChairHubConfig[targetConfigKey] = valuesArray[activeIndex]
        triggerButton.Text = tostring(valuesArray[activeIndex])
    end)
end

-- Сборка меню
UI_Factory.CreateSectionHeader(PagesRegistry["Aimbot"], "Core Weapon Aim Options")
UI_Factory.CreateFunctionalToggle(PagesRegistry["Aimbot"], "Aimbot Master Toggle", "AimbotEnabled")
UI_Factory.CreateFunctionalToggle(PagesRegistry["Aimbot"], "Team Filter Validation", "TeamCheck")
UI_Factory.CreatePrecisionSlider(PagesRegistry["Aimbot"], "Interp Smoothing Ratio", 0.05, 1.00, "Smoothness", 2)
UI_Factory.CreatePrecisionSlider(PagesRegistry["Aimbot"], "Maximum Target Distance", 50, 500, "MaxDistance", 1)

UI_Factory.CreateSectionHeader(PagesRegistry["ESP"], "Visual Identity Matrix")
UI_Factory.CreateFunctionalToggle(PagesRegistry["ESP"], "Aura Bounding Boxes", "ESPBoxes")
UI_Factory.CreateFunctionalToggle(PagesRegistry["ESP"], "Anatomical Skeletons", "ESPSkeletons")
UI_Factory.CreateFunctionalToggle(PagesRegistry["ESP"], "Metrical Distance Label", "ESPDistance")

UI_Factory.CreateSectionHeader(PagesRegistry["FOV"], "Mathematical Capture Zone")
UI_Factory.CreateFunctionalToggle(PagesRegistry["FOV"], "Display Boundary Ring", "FOVVisible")
UI_Factory.CreatePrecisionSlider(PagesRegistry["FOV"], "Boundary Radius Value", 20, 350, "FOVValue", 0)

UI_Factory.CreateSectionHeader(PagesRegistry["Config"], "Local Weapon Overrides")
UI_Factory.CreateFunctionalToggle(PagesRegistry["Config"], "Activate Skin Changer", "SkinChangerEnabled")
UI_Factory.CreateCyclicSelector(PagesRegistry["Config"], "Inventory Classification", {"Weapons", "Knives", "Gloves"}, "SelectedCategory")
UI_Factory.CreateCyclicSelector(PagesRegistry["Config"], "Target Asset Finish", {"Asimov", "Dragon Lore", "Hyper Beast", "Printstream"}, "SelectedSkin")

-- Ультра-оптимизированный Аппаратный ESP для BloxStrike (Глубокий поиск по скрытым моделям)
local function ProcessHardwareESPAllocation(characterModel)
    if MemoryCache.ESPObjects[characterModel] then return end
    
    local root = characterModel:FindFirstChild("HumanoidRootPart") or characterModel:FindFirstChildOfClass("BasePart")
    if not root then return end
    
    local billboard = Instance.new("BillboardGui", BaseScreenGui)
    billboard.Name = "ChairHub_Hardware_Instance"
    billboard.Size = UDim2.new(4.5, 0, 6, 0)
    billboard.AlwaysOnTop = true
    billboard.Adornee = root
    
    local outerBoxFrame = Instance.new("Frame", billboard)
    outerBoxFrame.Size = UDim2.new(1, 0, 1, 0)
    outerBoxFrame.BackgroundTransparency = 1
    
    local boxStroke = Instance.new("UIStroke", outerBoxFrame)
    boxStroke.Thickness = 1.4
    boxStroke.Color = ChairHubConfig.ESPBoxesColor
    
    local metricLabel = Instance.new("TextLabel", billboard)
    metricLabel.Size = UDim2.new(1, 0, 0, 12)
    metricLabel.Position = UDim2.new(0, 0, 1, 2)
    metricLabel.BackgroundTransparency = 1
    metricLabel.Font = Enum.Font.GothamBold
    metricLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    metricLabel.TextSize = 9
    
    local skeletonFolder = Instance.new("Folder", characterModel)
    skeletonFolder.Name = "HardwareSkeletonRegistry"
    
    local function ConnectJointBones(nodeA, nodeB)
        if not nodeA or not nodeB then return end
        
        local lineAdornment = Instance.new("LineHandleAdornment", skeletonFolder)
        lineAdornment.Thickness = 1.8
        lineAdornment.Color3 = ChairHubConfig.ESPSkeletonsColor
        lineAdornment.AlwaysOnTop = true
        lineAdornment.Adornee = nodeA
        
        local runtimeConnection = RunService.Heartbeat:Connect(function()
            if nodeA and nodeB and nodeA.Parent and nodeB.Parent and lineAdornment.Parent then
                lineAdornment.Length = (nodeA.Position - nodeB.Position).Magnitude
                lineAdornment.CFrame = CFrame.lookAt(Vector3.new(), nodeA.ToLocalSpace(nodeB).Position)
                lineAdornment.Visible = ChairHubConfig.ESPSkeletons
            end
        end)
        table.insert(MemoryCache.Connections, runtimeConnection)
    end
    
    local head = characterModel:FindFirstChild("Head") or characterModel:FindFirstChild("UpperTorso")
    if head and root and head ~= root then ConnectJointBones(head, root) end
    
    MemoryCache.ESPObjects[characterModel] = { Billboard = billboard, Box = outerBoxFrame, Label = metricLabel, Folder = skeletonFolder }
end

local function EraseHardwareESPAllocation(characterModel)
    local obj = MemoryCache.ESPObjects[characterModel]
    if obj then
        if obj.Billboard then obj.Billboard:Destroy() end
        if obj.Folder then obj.Folder:Destroy() end
        MemoryCache.ESPObjects[characterModel] = nil
    end
end

-- Мощный Клиентский Скинченджер BloxStrike (Сканирование Viewmodel в камере)
local function ApplySkinToInstance(subInstance, assetProperties)
    if subInstance:IsA("BasePart") then
        if not MemoryCache.OriginalWeapons[subInstance] then
            MemoryCache.OriginalWeapons[subInstance] = {Color = subInstance.Color, Material = subInstance.Material}
        end
        subInstance.Color = assetProperties.Color
        subInstance.Material = assetProperties.Material
    end
    
    if subInstance:IsA("MeshPart") or subInstance:IsA("SpecialMesh") then
        if not MemoryCache.OriginalWeapons[subInstance] then
            MemoryCache.OriginalWeapons[subInstance] = {TextureId = subInstance.TextureId}
        end
        if assetProperties.Texture ~= "" then subInstance.TextureId = assetProperties.Texture end
    end
end

local function ProcessGlobalSkinChanger()
    if not ChairHubConfig.SkinChangerEnabled then return end
    
    local assetProperties = GlobalSkinDatabase[ChairHubConfig.SelectedCategory][ChairHubConfig.SelectedSkin]
    if not assetProperties then return end
    
    -- 1. Перехват и замена текстур оружия от первого лица (Viewmodel в камере)
    for _, item in ipairs(Camera:GetDescendants()) do
        if item:IsA("BasePart") or item:IsA("MeshPart") or item:IsA("SpecialMesh") then
            ApplySkinToInstance(item, assetProperties)
        end
    end
    
    -- 2. Перехват и замена текстур оружия на самом персонаже
    if LocalPlayer.Character then
        for _, item in ipairs(LocalPlayer.Character:GetDescendants()) do
            if item:IsA("Tool") or item:IsA("BasePart") or item:IsA("MeshPart") then
                ApplySkinToInstance(item, assetProperties)
            end
        end
    end
end

function ResetWeaponSkins()
    for obj, data in pairs(MemoryCache.OriginalWeapons) do
        pcall(function()
            if obj:IsA("BasePart") then obj.Color = data.Color obj.Material = data.Material
            elseif obj:IsA("MeshPart") or obj:IsA("SpecialMesh") then obj.TextureId = data.TextureId end
        end)
    end
    MemoryCache.OriginalWeapons = {}
end

-- Поиск лучшей цели во всех папках рендеринга игры BloxStrike
local function GetClosestTarget()
    local trackingTarget = nil
    local shortestScreenDistance = ChairHubConfig.FOVValue
    local viewportCenterPoint = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    local allCharacters = FetchAllGameCharacters()
    for _, charModel in ipairs(allCharacters) do
        if CalculateTeamRelation(charModel) then
            local targetBone = charModel:FindFirstChild("Head") or charModel:FindFirstChild("UpperTorso") or charModel:FindFirstChildOfClass("BasePart")
            if targetBone then
                local vectorCoordinate, isWithinViewport = Camera:WorldToViewportPoint(targetBone.Position)
                if isWithinViewport then
                    local localRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    local worldDist = localRoot and (localRoot.Position - targetBone.Position).Magnitude or 0
                    if worldDist <= ChairHubConfig.MaxDistance or worldDist == 0 then
                        local flatScreenDistance = (Vector2.new(vectorCoordinate.X, vectorCoordinate.Y) - viewportCenterPoint).Magnitude
                        if flatScreenDistance < shortestScreenDistance then
                            shortestScreenDistance = flatScreenDistance
                            trackingTarget = targetBone
                        end
                    end
                end
            end
        end
    end
    return trackingTarget
end

-- Главный цикл обработки (Подключен к кадровой частоте)
local MainEngineLoop = RunService.RenderStepped:Connect(function()
    SynchronizeFOVVisuals()
    
    -- Плавный Legit Аимбот
    if ChairHubConfig.AimbotEnabled then
        local aimBone = GetClosestTarget()
        if aimBone then
            local velocity = aimBone:IsA("BasePart") and aimBone.AssemblyLinearVelocity or Vector3.new()
            local positionWithCorrection = aimBone.Position + (velocity * ChairHubConfig.PredictionScale)
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, positionWithCorrection), ChairHubConfig.Smoothness)
        end
    end
    
    -- Отрисовка ВХ
    local activeCharacters = FetchAllGameCharacters()
    local validModels = {}
    
    for _, charModel in ipairs(activeCharacters) do
        if CalculateTeamRelation(charModel) then
            validModels[charModel] = true
            if not MemoryCache.ESPObjects[charModel] then ProcessHardwareESPAllocation(charModel) end
            
            local data = MemoryCache.ESPObjects[charModel]
            if data then
                local root = charModel:FindFirstChild("HumanoidRootPart") or charModel:FindFirstChildOfClass("BasePart")
                if root then
                    local localRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    local distance = localRoot and (localRoot.Position - root.Position).Magnitude or 0
                    data.Box.Visible = ChairHubConfig.ESPBoxes
                    data.Label.Visible = ChairHubConfig.ESPDistance
                    data.Label.Text = string.format("DIST: %d", math.floor(distance))
                end
            end
        end
    end
    
    -- Стираем старый кэш ВХ умерших или вышедших игроков
    for cachedModel, _ in pairs(MemoryCache.ESPObjects) do
        if not validModels[cachedModel] or not cachedModel.Parent then
            EraseHardwareESPAllocation(cachedModel)
        end
    end
end)
table.insert(MemoryCache.Connections, MainEngineLoop)

-- Запуск скинченджера на низкоуровневом тике Heartbeat (Стабильный FPS)
local SkinChangerConnection = RunService.Heartbeat:Connect(function()
    if ChairHubConfig.SkinChangerEnabled then
        pcall(ProcessGlobalSkinChanger)
    end
end)
table.insert(MemoryCache.Connections, SkinChangerConnection)

-- Мобильный Drag UI для Delta
local IsDragging, DragInputObj, DragStartPos, InitialFramePos = false, nil, nil, nil

InterfaceFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        IsDragging = true
        DragStartPos = input.Position
        InitialFramePos = InterfaceFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then IsDragging = false end
        end)
    end
end)

InterfaceFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then DragInputObj = input end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == DragInputObj and IsDragging then
        local delta = input.Position - DragStartPos
        MainFrame.Position = UDim2.new(InitialFramePos.X.Scale, InitialFramePos.X.Offset + delta.X, InitialFramePos.Y.Scale, InitialFramePos.Y.Offset + delta.Y)
    end
end)

-- Поддержка кнопки закрытия (Бинд)
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.RightControl then
        MemoryCache.UIVisible = not MemoryCache.UIVisible
        InterfaceFrame.Visible = MemoryCache.UIVisible
    end
end)

print("[ChairHub Core Engine v4.0]: Fully Compiled and Injected under BloxStrike Custom Environment.")
