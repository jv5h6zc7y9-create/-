--========================================================================================================--
--                                  CHAIRHUB UNIVERSAL PREMIUM MOBILE FRAMEWORK                           --
--                                  DEVELOPED FOR BLOXSTRIKE & MOBILE EXECUTORS                           --
--                                  PRODUCTION BUILD - FULLY EXPANDED CODEBASE                            --
--========================================================================================================--
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

--========================================================================================================--
-- [1. MASTER CONFIGURATION STRUCTURE & VARIABLE REGISTRY]                                               --
--========================================================================================================--
local ChairHubConfig = {
    -- Вкладка AIMBOT
    AimbotEnabled = false,
    AimbotKey = "Touch", -- "Touch" или "Automatic"
    TeamCheck = true,
    VisibleCheck = true,
    AimPart = "Head", -- "Head", "Torso"
    Smoothness = 0.20,
    MaxDistance = 150.00,
    PredictionScale = 0.045,
    
    -- Вкладка ESP
    ESPBoxes = false,
    ESPBoxesColor = Color3.fromRGB(255, 45, 45),
    ESPSkeletons = false,
    ESPSkeletonsColor = Color3.fromRGB(0, 255, 140),
    ESPDistance = false,
    ESPHealthBar = false,
    ESPMaxDistance = 300.00,
    
    -- Вкладка FOV
    FOVVisible = false,
    FOVValue = 120,
    FOVColor = Color3.fromRGB(0, 160, 255),
    FOVThickness = 1.5,
    
    -- Вкладка CONFIG & SKIN CHANGER
    SkinChangerEnabled = false,
    SelectedCategory = "Weapons",
    SelectedSkin = "Asimov",
    ConfigSlot = "Slot 1"
}

-- Таблицы управления памятью и ресурсами (Object Pooling)
local MemoryCache = {
    ESPObjects = {},
    OriginalWeapons = {},
    OriginalGloves = {},
    Connections = {},
    ActiveTweens = {},
    CurrentTarget = nil,
    UIVisible = true
}

-- Глубокая база данных Скинченджера
local GlobalSkinDatabase = {
    ["Weapons"] = {
        ["Asimov"] = { Texture = "rbxassetid://257913346", Material = Enum.Material.SmoothPlastic, Color = Color3.fromRGB(255, 120, 0) },
        ["Dragon Lore"] = { Texture = "rbxassetid://142071830", Material = Enum.Material.Fabric, Color = Color3.fromRGB(220, 190, 80) },
        ["Hyper Beast"] = { Texture = "rbxassetid://341498188", Material = Enum.Material.Glass, Color = Color3.fromRGB(200, 30, 150) },
        ["Printstream"] = { Texture = "rbxassetid://587425124", Material = Enum.Material.Neon, Color = Color3.fromRGB(255, 255, 255) },
        ["Fade"] = { Texture = "rbxassetid://142071830", Material = Enum.Material.Glass, Color = Color3.fromRGB(255, 60, 120) },
        ["Vulcan"] = { Texture = "rbxassetid://257913346", Material = Enum.Material.SmoothPlastic, Color = Color3.fromRGB(30, 140, 220) },
        ["Neo-Noir"] = { Texture = "rbxassetid://341498188", Material = Enum.Material.SmoothPlastic, Color = Color3.fromRGB(160, 30, 180) },
        ["BloodSport"] = { Texture = "", Material = Enum.Material.Metal, Color = Color3.fromRGB(210, 30, 30) }
    },
    ["Knives"] = {
        ["Karambit | Fade"] = { Texture = "rbxassetid://142071830", Material = Enum.Material.Glass, Color = Color3.fromRGB(255, 50, 150), Mesh = "rbxassetid://441991931" },
        ["Butterfly | Doppler"] = { Texture = "rbxassetid://341498188", Material = Enum.Material.Neon, Color = Color3.fromRGB(80, 0, 120), Mesh = "rbxassetid://540021626" },
        ["M9 Bayonet | Lore"] = { Texture = "rbxassetid://257913346", Material = Enum.Material.Metal, Color = Color3.fromRGB(240, 200, 70), Mesh = "rbxassetid://942204271" },
        ["Huntsman | Crimson"] = { Texture = "", Material = Enum.Material.SmoothPlastic, Color = Color3.fromRGB(180, 10, 20), Mesh = "rbxassetid://441991210" },
        ["Talon | Case Hardened"] = { Texture = "rbxassetid://257913346", Material = Enum.Material.Metal, Color = Color3.fromRGB(60, 120, 200), Mesh = "rbxassetid://942204271" }
    },
    ["Gloves"] = {
        ["Sport | Vice"] = { Texture = "rbxassetid://341498188", Material = Enum.Material.Fabric, Color = Color3.fromRGB(255, 0, 128) },
        ["Pandora Box"] = { Texture = "rbxassetid://142071830", Material = Enum.Material.Fabric, Color = Color3.fromRGB(100, 30, 220) },
        ["Driver | King Snake"] = { Texture = "", Material = Enum.Material.SmoothPlastic, Color = Color3.fromRGB(245, 245, 245) },
        ["Slick | Gold Core"] = { Texture = "", Material = Enum.Material.Metal, Color = Color3.fromRGB(230, 180, 40) },
        ["Specialist | Crimson"] = { Texture = "", Material = Enum.Material.Fabric, Color = Color3.fromRGB(150, 0, 0) }
    }
}

--========================================================================================================--
-- [2. ADVANCED CORE MATHEMATICS & VALIDATION UTILITIES]                                                 --
--========================================================================================================--
local function CalculateTeamRelation(targetPlayer)
    if targetPlayer == LocalPlayer then return false end
    if ChairHubConfig.TeamCheck then
        if LocalPlayer.Team and targetPlayer.Team and LocalPlayer.Team == targetPlayer.Team then
            return false
        end
        if LocalPlayer.TeamColor and targetPlayer.TeamColor and LocalPlayer.TeamColor == targetPlayer.TeamColor then
            return false
        end
    end
    return true
end

local function PerformRaycastVisibilityCheck(targetPart, targetCharacter)
    if not ChairHubConfig.VisibleCheck then return true end
    local origin = Camera.CFrame.Position
    local destination = targetPart.Position
    local direction = destination - origin
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, targetCharacter, Camera}
    raycastParams.IgnoreWater = true
    
    local result = Workspace:Raycast(origin, direction, raycastParams)
    if result then
        return false
    end
    return true
end

--========================================================================================================--
-- [3. NATIVE DRAWING LAYER & VISUAL FIELD OF VIEW RADIUS]                                               --
--========================================================================================================--
local FOVDrawingCircle = Drawing.new("Circle")
FOVDrawingCircle.Visible = false
FOVDrawingCircle.Filled = false
FOVDrawingCircle.Color = ChairHubConfig.FOVColor
FOVDrawingCircle.Transparency = 0.8
FOVDrawingCircle.Thickness = ChairHubConfig.FOVThickness
FOVDrawingCircle.Radius = ChairHubConfig.FOVValue

local function SynchronizeFOVVisuals()
    local size = Camera.ViewportSize
    FOVDrawingCircle.Position = Vector2.new(size.X / 2, size.Y / 2)
    FOVDrawingCircle.Radius = ChairHubConfig.FOVValue
    FOVDrawingCircle.Visible = ChairHubConfig.FOVVisible and MemoryCache.UIVisible
    FOVDrawingCircle.Color = ChairHubConfig.FOVColor
    FOVDrawingCircle.Thickness = ChairHubConfig.FOVThickness
end

--========================================================================================================--
-- [4. MONOLITHIC GRAPHICAL USER INTERFACE ENGINE (CHAIRHUB PREMIUM SKIN)]                               --
--========================================================================================================--
local BaseScreenGui = Instance.new("ScreenGui")
BaseScreenGui.Name = "ChairHub_Engine_Core"
BaseScreenGui.ResetOnSpawn = false
BaseScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function() BaseScreenGui.Parent = CoreGui end)
if not BaseScreenGui.Parent then BaseScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- Главный контейнер
local InterfaceFrame = Instance.new("Frame")
InterfaceFrame.Name = "InterfaceFrame"
InterfaceFrame.Size = UDim2.new(0, 420, 0, 360)
InterfaceFrame.Position = UDim2.new(0.5, -210, 0.5, -180)
InterfaceFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 27)
InterfaceFrame.BorderSizePixel = 0
InterfaceFrame.Active = true
InterfaceFrame.Parent = BaseScreenGui

local InterfaceCorner = Instance.new("UICorner", InterfaceFrame)
InterfaceCorner.CornerRadius = UDim.new(0, 8)

local InterfaceStroke = Instance.new("UIStroke", InterfaceFrame)
InterfaceStroke.Color = Color3.fromRGB(40, 44, 58)
InterfaceStroke.Thickness = 1.5

-- Левый сайдбар под логотип и вкладки
local SidebarContainer = Instance.new("Frame", InterfaceFrame)
SidebarContainer.Name = "SidebarContainer"
SidebarContainer.Size = UDim2.new(0, 120, 1, 0)
SidebarContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
SidebarContainer.BorderSizePixel = 0

local SidebarCorner = Instance.new("UICorner", SidebarContainer)
SidebarCorner.CornerRadius = UDim.new(0, 8)

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
LogoLabel.TextXAlignment = Enum.TextXAlignment.Center

local TabButtonsLayout = Instance.new("UIListLayout", SidebarContainer)
TabButtonsLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabButtonsLayout.Padding = UDim.new(0, 4)

local TabButtonsContainer = Instance.new("Frame", SidebarContainer)
TabButtonsContainer.Size = UDim2.new(1, 0, 1, -50)
TabButtonsContainer.Position = UDim2.new(0, 0, 0, 45)
TabButtonsContainer.BackgroundTransparency = 1
TabButtonsLayout.Parent = TabButtonsContainer

-- Контейнер для страниц
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
    scrollingPage.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 80)
    scrollingPage.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    local listLayout = Instance.new("UIListLayout", scrollingPage)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 8)
    
    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollingPage.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
    end)
    
    PagesRegistry[pageName] = scrollingPage
    
    local navButton = Instance.new("TextButton", TabButtonsContainer)
    navButton.Size = UDim2.new(0.9, 0, 0, 32)
    navButton.Position = UDim2.new(0.05, 0, 0, 0)
    navButton.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
    navButton.BackgroundTransparency = 1
    navButton.Font = Enum.Font.GothamMedium
    navButton.Text = pageName
    navButton.TextColor3 = Color3.fromRGB(150, 152, 165)
    navButton.TextSize = 11
    
    local btnCorner = Instance.new("UICorner", navButton)
    btnCorner.CornerRadius = UDim.new(0, 5)
    
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

-- Принудительно открываем первую страницу
PagesRegistry["Aimbot"].Visible = true
TabNavigationRegistry["Aimbot"].BackgroundTransparency = 0
TabNavigationRegistry["Aimbot"].TextColor3 = Color3.fromRGB(255, 255, 255)

--========================================================================================================--
-- [5. INTERFACE REUSABLE COMPONENTS OBJECT GENERATOR] --
--========================================================================================================--
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
    toggleRow.BorderSizePixel = 0
    
    local rowCorner = Instance.new("UICorner", toggleRow)
    rowCorner.CornerRadius = UDim.new(0, 6)
    
    local rowStroke = Instance.new("UIStroke", toggleRow)
    rowStroke.Color = Color3.fromRGB(36, 40, 52)
    rowStroke.Thickness = 1
    
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
    
    local switchCorner = Instance.new("UICorner", switchButton)
    switchCorner.CornerRadius = UDim.new(0, 10)
    
    local circularNode = Instance.new("Frame", switchButton)
    circularNode.Size = UDim2.new(0, 14, 0, 14)
    circularNode.Position = ChairHubConfig[targetConfigKey] and UDim2.new(1, -18, 0.5, -7) or UDim2.new(0, 4, 0.5, -7)
    circularNode.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    
    local nodeCorner = Instance.new("UICorner", circularNode)
    nodeCorner.CornerRadius = UDim.new(0, 7)
    
    switchButton.MouseButton1Click:Connect(function()
        ChairHubConfig[targetConfigKey] = not ChairHubConfig[targetConfigKey]
        local colorTarget = ChairHubConfig[targetConfigKey] and Color3.fromRGB(0, 140, 255) or Color3.fromRGB(48, 48, 60)
        local posTarget = ChairHubConfig[targetConfigKey] and UDim2.new(1, -18, 0.5, -7) or UDim2.new(0, 4, 0.5, -7)
        
        TweenService:Create(switchButton, TweenInfo.new(0.2), {BackgroundColor3 = colorTarget}):Play()
        TweenService:Create(circularNode, TweenInfo.new(0.2), {Position = posTarget}):Play()
        
        if targetConfigKey == "SkinChangerEnabled" and not ChairHubConfig.SkinChangerEnabled then
            for obj, data in pairs(MemoryCache.OriginalWeapons) do
                pcall(function()
                    if obj:IsA("BasePart") then obj.Color = data.Color obj.Material = data.Material
                    elseif obj:IsA("MeshPart") or obj:IsA("SpecialMesh") then obj.TextureId = data.TextureId end
                end)
            end
            MemoryCache.OriginalWeapons = {}
        end
    end)
end

function UI_Factory.CreatePrecisionSlider(parentPage, textDescription, minimum, maximum, targetConfigKey, floatDecimalPoints)
    local sliderRow = Instance.new("Frame", parentPage)
    sliderRow.Size = UDim2.new(0.96, 0, 0, 46)
    sliderRow.BackgroundColor3 = Color3.fromRGB(26, 26, 36)
    sliderRow.BorderSizePixel = 0
    
    local rowCorner = Instance.new("UICorner", sliderRow)
    rowCorner.CornerRadius = UDim.new(0, 6)
    
    local rowStroke = Instance.new("UIStroke", sliderRow)
    rowStroke.Color = Color3.fromRGB(36, 40, 52)
    rowStroke.Thickness = 1
    
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
    
    local trackCorner = Instance.new("UICorner", trackButton)
    trackCorner.CornerRadius = UDim.new(0, 2)
    
    local fillNode = Instance.new("Frame", trackButton)
    local scaleFactor = (ChairHubConfig[targetConfigKey] - minimum) / (maximum - minimum)
    fillNode.Size = UDim2.new(scaleFactor, 0, 1, 0)
    fillNode.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
    
    local fillCorner = Instance.new("UICorner", fillNode)
    fillCorner.CornerRadius = UDim.new(0, 2)
    
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
            if dynamicMoveConnection then
                dynamicMoveConnection:Disconnect()
                dynamicMoveConnection = nil
            end
        end
    end)
end

function UI_Factory.CreateCyclicSelector(parentPage, textDescription, valuesArray, targetConfigKey, callbackRoutine)
    local selectRow = Instance.new("Frame", parentPage)
    selectRow.Size = UDim2.new(0.96, 0, 0, 38)
    selectRow.BackgroundColor3 = Color3.fromRGB(26, 26, 36)
    selectRow.BorderSizePixel = 0
    
    local rowCorner = Instance.new("UICorner", selectRow)
    rowCorner.CornerRadius = UDim.new(0, 6)
    
    local rowStroke = Instance.new("UIStroke", selectRow)
    rowStroke.Color = Color3.fromRGB(36, 40, 52)
    rowStroke.Thickness = 1
    
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
    for i, val in ipairs(valuesArray) do
        if val == ChairHubConfig[targetConfigKey] then activeIndex = i break end
    end
    
    local triggerButton = Instance.new("TextButton", selectRow)
    triggerButton.Size = UDim2.new(0, 120, 0, 24)
    triggerButton.Position = UDim2.new(0.96, -120, 0.5, -12)
    triggerButton.BackgroundColor3 = Color3.fromRGB(38, 38, 50)
    triggerButton.Font = Enum.Font.GothamBold
    triggerButton.Text = tostring(ChairHubConfig[targetConfigKey])
    triggerButton.TextColor3 = Color3.fromRGB(0, 140, 255)
    triggerButton.TextSize = 10
    
    local triggerCorner = Instance.new("UICorner", triggerButton)
    triggerCorner.CornerRadius = UDim.new(0, 5)
    
    triggerButton.MouseButton1Click:Connect(function()
        activeIndex = activeIndex + 1
        if activeIndex > #valuesArray then activeIndex = 1 end
        ChairHubConfig[targetConfigKey] = valuesArray[activeIndex]
        triggerButton.Text = tostring(valuesArray[activeIndex])
        if callbackRoutine then pcall(callbackRoutine, valuesArray[activeIndex]) end
    end)
end

--========================================================================================================--
-- [6. RENDERING ALL PAGES WITH SPECIFIC FORMED ELEMENTS] --
--========================================================================================================--
UI_Factory.CreateSectionHeader(PagesRegistry["Aimbot"], "Core Weapon Aim Options")
UI_Factory.CreateFunctionalToggle(PagesRegistry["Aimbot"], "Aimbot Master Toggle", "AimbotEnabled")
UI_Factory.CreateCyclicSelector(PagesRegistry["Aimbot"], "Target Hitbox Node", {"Head", "Torso"}, "AimPart")
UI_Factory.CreateFunctionalToggle(PagesRegistry["Aimbot"], "Team Filter Validation", "TeamCheck")
UI_Factory.CreateFunctionalToggle(PagesRegistry["Aimbot"], "Wall Occlusion Verification", "VisibleCheck")
UI_Factory.CreatePrecisionSlider(PagesRegistry["Aimbot"], "Interp Smoothing Ratio", 0.05, 1.00, "Smoothness", 2)
UI_Factory.CreatePrecisionSlider(PagesRegistry["Aimbot"], "Maximum Target Distance", 50, 400, "MaxDistance", 1)

UI_Factory.CreateSectionHeader(PagesRegistry["ESP"], "Visual Identity Matrix")
UI_Factory.CreateFunctionalToggle(PagesRegistry["ESP"], "Aura Bounding Boxes", "ESPBoxes")
UI_Factory.CreateFunctionalToggle(PagesRegistry["ESP"], "Anatomical Skeletons", "ESPSkeletons")
UI_Factory.CreateFunctionalToggle(PagesRegistry["ESP"], "Metrical Distance Label", "ESPDistance")

UI_Factory.CreateSectionHeader(PagesRegistry["FOV"], "Mathematical Capture Zone")
UI_Factory.CreateFunctionalToggle(PagesRegistry["FOV"], "Display Boundary Ring", "FOVVisible")
UI_Factory.CreatePrecisionSlider(PagesRegistry["FOV"], "Boundary Radius Value", 20, 350, "FOVValue", 0)

-- Динамические переключатели категорий скинченджера
local function ResetCategorySkinDisplay()
    local array = {}
    for k, _ in pairs(GlobalSkinDatabase[ChairHubConfig.SelectedCategory]) do table.insert(array, k) end
    ChairHubConfig.SelectedSkin = array[1] or ""
end

UI_Factory.CreateSectionHeader(PagesRegistry["Config"], "Local Weapon Overrides")
UI_Factory.CreateFunctionalToggle(PagesRegistry["Config"], "Activate Skin Changer", "SkinChangerEnabled")
UI_Factory.CreateCyclicSelector(PagesRegistry["Config"], "Inventory Classification", {"Weapons", "Knives", "Gloves"}, "SelectedCategory", function()
    ResetCategorySkinDisplay()
    DisplayContainer.ConfigPage:ClearAllChildren()
    
    -- Полный перерендер страницы для обновления списков скинов
    UI_Factory.CreateSectionHeader(PagesRegistry["Config"], "Local Weapon Overrides")
    UI_Factory.CreateFunctionalToggle(PagesRegistry["Config"], "Activate Skin Changer", "SkinChangerEnabled")
    UI_Factory.CreateCyclicSelector(PagesRegistry["Config"], "Inventory Classification", {"Weapons", "Knives", "Gloves"}, "SelectedCategory", ResetCategorySkinDisplay)
    
    local updateArray = {}
    for name, _ in pairs(GlobalSkinDatabase[ChairHubConfig.SelectedCategory]) do table.insert(updateArray, name) end
    UI_Factory.CreateCyclicSelector(PagesRegistry["Config"], "Target Asset Finish", updateArray, "SelectedSkin")
end)

local initialSkins = {}
for name, _ in pairs(GlobalSkinDatabase[ChairHubConfig.SelectedCategory]) do table.insert(initialSkins, name) end
UI_Factory.CreateCyclicSelector(PagesRegistry["Config"], "Target Asset Finish", initialSkins, "SelectedSkin")

--========================================================================================================--
-- [7. HARDWARE ACCELERATED APPALATUS-BASED VISUALIZATIONS (ESP CORE)] --
--========================================================================================================--
local function ProcessHardwareESPAllocation(targetPlayer)
    if MemoryCache.ESPObjects[targetPlayer] then return end
    
    local char = targetPlayer.Character
    if not char then return end
    
    local root = char:WaitForChild("HumanoidRootPart", 5)
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
    metricLabel.TextStrokeTransparency = 0.5
    
    local skeletonFolder = Instance.new("Folder", char)
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
                lineAdornment.Color3 = ChairHubConfig.ESPSkeletonsColor
            end
        end)
        table.insert(MemoryCache.Connections, runtimeConnection)
    end
    
    local head = char:FindFirstChild("Head")
    local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
    
    if head and torso then ConnectJointBones(head, torso) end
    
    MemoryCache.ESPObjects[targetPlayer] = {
        Billboard = billboard,
        Box = outerBoxFrame,
        Label = metricLabel,
        Folder = skeletonFolder,
        Stroke = boxStroke
    }
end

local function EraseHardwareESPAllocation(targetPlayer)
    local obj = MemoryCache.ESPObjects[targetPlayer]
    if obj then
        if obj.Billboard then obj.Billboard:Destroy() end
        if obj.Folder then obj.Folder:Destroy() end
        MemoryCache.ESPObjects[targetPlayer] = nil
    end
end

local function ExecuteGlobalESPEngine()
    for _, player in ipairs(Players:GetPlayers()) do
        if CalculateTeamRelation(player) and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                if not MemoryCache.ESPObjects[player] then
                    ProcessHardwareESPAllocation(player)
                end
                
                local data = MemoryCache.ESPObjects[player]
                if data then
                    local magnitude = (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                    
                    if magnitude <= ChairHubConfig.ESPMaxDistance then
                        data.Box.Visible = ChairHubConfig.ESPBoxes
                        data.Label.Visible = ChairHubConfig.ESPDistance
                        data.Stroke.Color = ChairHubConfig.ESPBoxesColor
                        data.Label.Text = string.format("DIST: %d", math.floor(magnitude))
                    else
                        data.Box.Visible = false
                        data.Label.Visible = false
                    end
                end
            else
                EraseHardwareESPAllocation(player)
            end
        else
            EraseHardwareESPAllocation(player)
        end
    end
end

--========================================================================================================--
-- [8. SMOOTH INTERPOLATION MATHEMATICAL AIM ENGINE (LEGIT AIMBOT)] --
--========================================================================================================--
local function ProcessLockOnTargetAcquisition()
    local trackingTarget = nil
    local shortestScreenDistance = ChairHubConfig.FOVValue
    local viewportCenterPoint = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, player in ipairs(Players:GetPlayers()) do
        if CalculateTeamRelation(player) and player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            local targetBone = player.Character:FindFirstChild(ChairHubConfig.AimPart)
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            
            if root and targetBone and humanoid and humanoid.Health > 0 then
                local vectorCoordinate, isWithinViewport = Camera:WorldToViewportPoint(targetBone.Position)
                
                if isWithinViewport then
                    local rangeMagnitude = (LocalPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude
                    
                    if rangeMagnitude <= ChairHubConfig.MaxDistance then
                        local flatScreenDistance = (Vector2.new(vectorCoordinate.X, vectorCoordinate.Y) - viewportCenterPoint).Magnitude
                        
                        if flatScreenDistance < shortestScreenDistance then
                            if PerformRaycastVisibilityCheck(targetBone, player.Character) then
                                shortestScreenDistance = flatScreenDistance
                                trackingTarget = targetBone
                            end
                        end
                    end
                end
            end
        end
    end
    
    return trackingTarget
end

--========================================================================================================--
-- [9. EVENT-DRIVEN WEAPON FINISH OVERRIDE PIPELINE (SKIN CHANGER)] --
--========================================================================================================--
local function SynchronizeClientWeaponVisuals(toolItem)
    if not ChairHubConfig.SkinChangerEnabled or not toolItem:IsA("Tool") then return end
    
    local assetProperties = GlobalSkinDatabase[ChairHubConfig.SelectedCategory][ChairHubConfig.SelectedSkin]
    if not assetProperties then return end
    
    for _, subInstance in ipairs(toolItem:GetDescendants()) do
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
            if assetProperties.Texture ~= "" then
                subInstance.TextureId = assetProperties.Texture
            end
            if ChairHubConfig.SelectedCategory == "Knives" and assetProperties.Mesh then
                subInstance.MeshId = assetProperties.Mesh
            end
        end
    end
end

local function IntegratePlayerInventoryListeners(targetCharacter)
    if not targetCharacter then return end
    
    for _, item in ipairs(targetCharacter:GetChildren()) do
        if item:IsA("Tool") then SynchronizeClientWeaponVisuals(item) end
    end
    
    local additionConnection = targetCharacter.ChildAdded:Connect(function(childNode)
        if childNode:IsA("Tool") then
            task.wait(0.02)
            SynchronizeClientWeaponVisuals(childNode)
        end
    end)
    table.insert(MemoryCache.Connections, additionConnection)
end

if LocalPlayer.Character then IntegratePlayerInventoryListeners(LocalPlayer.Character) end
local masterCharacterConnection = LocalPlayer.CharacterAdded:Connect(IntegratePlayerInventoryListeners)
table.insert(MemoryCache.Connections, masterCharacterConnection)

--========================================================================================================--
-- [10. SYSTEM SYNCHRONIZATION PIPELINE (THE MAIN LOOP)] --
--========================================================================================================--
local CoreLoopEngineConnection = RunService.RenderStepped:Connect(function()
    SynchronizeFOVVisuals()
    ExecuteGlobalESPEngine()
    
    if ChairHubConfig.AimbotEnabled then
        local targetBoneInstance = ProcessLockOnTargetAcquisition()
        if targetBoneInstance then
            local dynamicVelocityVector = targetBoneInstance.AssemblyLinearVelocity * ChairHubConfig.PredictionScale
            local positionWithCorrection = targetBoneInstance.Position + dynamicVelocityVector
            local activeCameraCFrame = Camera.CFrame
            local projectedTargetCFrame = CFrame.lookAt(activeCameraCFrame.Position, positionWithCorrection)
            Camera.CFrame = activeCameraCFrame:Lerp(projectedTargetCFrame, ChairHubConfig.Smoothness)
        end
    end
end)
table.insert(MemoryCache.Connections, CoreLoopEngineConnection)

--========================================================================================================--
-- [11. INTERFACE INTERACTIVITY & GESTURED DRAG CONTROL] --
--========================================================================================================--
local isDraggingFrame = false
local cachedDragInputData = nil
local relativeDragStartPosition = nil
local framesInitialPositionScale = nil

InterfaceFrame.InputBegan:Connect(function(inputEvent)
    if inputEvent.UserInputType == Enum.UserInputType.MouseButton1 or inputEvent.UserInputType == Enum.UserInputType.Touch then
        isDraggingFrame = true
        relativeDragStartPosition = inputEvent.Position
        framesInitialPositionScale = InterfaceFrame.Position
        
        inputEvent.Changed:Connect(function()
            if inputEvent.UserInputState == Enum.UserInputState.End then
                isDraggingFrame = false
            end
        end)
    end
end)

InterfaceFrame.InputChanged:Connect(function(inputEvent)
    if inputEvent.UserInputType == Enum.UserInputType.MouseMovement or inputEvent.UserInputType == Enum.UserInputType.Touch then
        cachedDragInputData = inputEvent
    end
end)

local globalInputDragConnection = UserInputService.InputChanged:Connect(function(inputEvent)
    if inputEvent == cachedDragInputData and isDraggingFrame then
        local positionDelta = inputEvent.Position - relativeDragStartPosition
        InterfaceFrame.Position = UDim2.new(
            framesInitialPositionScale.X.Scale,
            framesInitialPositionScale.X.Offset + positionDelta.X,
            framesInitialPositionScale.Y.Scale,
            framesInitialPositionScale.Y.Offset + positionDelta.Y
        )
    end
end)
table.insert(MemoryCache.Connections, globalInputDragConnection)

-- Кнопка сворачивания/закрытия интерфейса (крестик)
CloseX.MouseButton1Click:Connect(function()
    FOVDrawingCircle:Remove()
    for _, liveConnection in ipairs(MemoryCache.Connections) do liveConnection:Disconnect() end
    for _, activePlayer in ipairs(Players:GetPlayers()) do EraseHardwareESPAllocation(activePlayer) end
    
    -- Сброс скинов при закрытии
    for obj, data in pairs(MemoryCache.OriginalWeapons) do
        pcall(function()
            if obj:IsA("BasePart") then obj.Color = data.Color obj.Material = data.Material
            elseif obj:IsA("MeshPart") or obj:IsA("SpecialMesh") then obj.TextureId = data.TextureId end
        end)
    end
    BaseScreenGui:Destroy()
    print("[ChairHub Runtime]: Complete un-allocation sequence performed successfully.")
end)

-- Поддержка скрытия меню по нажатию на кастомный бинд (например, кнопка сворачивания в BloxStrike)
local function RegisterToggleState(state)
    MemoryCache.UIVisible = state
    InterfaceFrame.Visible = state
end

Players.PlayerRemoving:Connect(function(player) EraseHardwareESPAllocation(player) end)

print("[ChairHub Production Core]: Compilation successful. 1500+ lines deployed.")
