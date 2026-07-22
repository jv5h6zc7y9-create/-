-- MONOLITHIC PASSIVE OPTIMIZED SCRIPT FOR BLOXSTRIKE (MOBILE EXECUTORS)-- Architected for maximum hardware efficiency, zero camera manipulation, and strict memory management.
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = CoreGui:FindFirstChild("RobloxGui") or LocalPlayer:WaitForChild("PlayerGui")

-- ==========================================
-- FEATURE REGISTRIES & CLEANUP SYSTEMS
-- ==========================================
local ScriptConfig = {
    EspEnabled = false,
    SkinChangerEnabled = false,
    SelectedCategory = "Weapons",
    SelectedSkin = "Asimov"
}

local OriginalAssets = {
    WeaponTextures = {},
    DefaultHands = {}
}

local ActiveConnections = {}
local EspInstances = {}

local function RegisterConnection(connection)
    table.insert(ActiveConnections, connection)
    return connection
end

-- ==========================================
-- INVENTORY CONFIGURATION DATABASE
-- ==========================================
local SkinDatabase = {
    Weapons = {
        ["Asimov"] = { TextureId = "rbxassetid://123456789", Material = Enum.Material.SmoothPlastic, Color = Color3.fromRGB(255, 120, 0) },
        ["Dragon Lore"] = { TextureId = "rbxassetid://987654321", Material = Enum.Material.Glass, Color = Color3.fromRGB(230, 185, 40) },
        ["Hyper Beast"] = { TextureId = "rbxassetid://543216789", Material = Enum.Material.Neon, Color = Color3.fromRGB(0, 255, 150) },
        ["Printstream"] = { TextureId = "rbxassetid://112233445", Material = Enum.Material.SmoothPlastic, Color = Color3.fromRGB(240, 240, 245) }
    },
    Knives = {
        ["Karambit"] = { MeshId = "rbxassetid://135792468", TextureId = "rbxassetid://246813579" },
        ["Butterfly Knife"] = { MeshId = "rbxassetid://864209753", TextureId = "rbxassetid://975310864" }
    },
    Gloves = {
        ["Sport Vice"] = { LeftColor = Color3.fromRGB(255, 0, 128), RightColor = Color3.fromRGB(0, 191, 255), Material = Enum.Material.Neon },
        ["Pandora Box"] = { LeftColor = Color3.fromRGB(75, 0, 130), RightColor = Color3.fromRGB(75, 0, 130), Material = Enum.Material.Fabric }
    }
}

-- ==========================================
-- PREMIUM DARK MOBILE UI INFRASTRUCTURE
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BloxStrikeHardwareOptimizedUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 340, 0, 260)
MainFrame.Position = UDim2.new(0.5, -170, 0.5, -130)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 22)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = false -- Enforcing manual UserInputService Touch processing for consistency across executors
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 1.5
MainStroke.Color = Color3.fromRGB(45, 45, 50)
MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
MainStroke.Parent = MainFrame

-- Mobile Touch Drag Handling
local Dragging = false
local DragInput, DragStart, StartPosition

local function UpdateDrag(input)
    local delta = input.Position - DragStart
    MainFrame.Position = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + delta.Y)
end

RegisterConnection(MainFrame.InputBegan:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        Dragging = true
        DragStart = input.Position
        StartPosition = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                Dragging = false
            end
        end)
    end
end))

RegisterConnection(MainFrame.InputChanged:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        DragInput = input
    end
end))

RegisterConnection(UserInputService.InputChanged:Connect(function(input)
    if input == DragInput and Dragging then
        UpdateDrag(input)
    end
end))

-- Top Bar UI Elements
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -40, 0, 35)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "BLOXSTRIKE EXTERNAL PERF-SUITE"
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 13
TitleLabel.TextColor3 = Color3.fromRGB(230, 230, 235)
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = MainFrame

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 25, 0, 25)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
CloseButton.Text = "X"
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextColor3 = Color3.fromRGB(240, 80, 80)
CloseButton.TextSize = 12
CloseButton.Parent = MainFrame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseButton

-- Content Area
local Container = Instance.new("ScrollingFrame")
Container.Size = UDim2.new(1, -20, 1, -50)
Container.Position = UDim2.new(0, 10, 0, 45)
Container.BackgroundTransparency = 1
Container.CanvasSize = UDim2.new(0, 0, 0, 320)
Container.ScrollBarThickness = 2
Container.ScrollBarImageColor3 = Color3.fromRGB(50, 50, 55)
Container.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.Parent = Container

-- Dynamic Component Constructors
local function CreateToggleButton(name, configKey, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 40)
    Frame.BackgroundColor3 = Color3.fromRGB(26, 26, 28)
    Frame.Parent = Container
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Frame
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -60, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 12
    Label.TextColor3 = Color3.fromRGB(200, 200, 205)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame
    
    local Switch = Instance.new("TextButton")
    Switch.Size = UDim2.new(0, 40, 0, 22)
    Switch.Position = UDim2.new(1, -52, 0.5, -11)
    Switch.BackgroundColor3 = ScriptConfig[configKey] and Color3.fromRGB(0, 180, 110) or Color3.fromRGB(45, 45, 50)
    Switch.Text = ""
    Switch.Parent = Frame
    
    local SwitchCorner = Instance.new("UICorner")
    SwitchCorner.CornerRadius = UDim.new(1, 0)
    SwitchCorner.Parent = Switch
    
    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.new(0, 16, 0, 16)
    Indicator.Position = ScriptConfig[configKey] and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
    Indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Indicator.Parent = Switch
    
    local IndicatorCorner = Instance.new("UICorner")
    IndicatorCorner.CornerRadius = UDim.new(1, 0)
    IndicatorCorner.Parent = Indicator
    
    Switch.MouseButton1Click:Connect(function()
        ScriptConfig[configKey] = not ScriptConfig[configKey]
        local active = ScriptConfig[configKey]
        
        TweenService:Create(Switch, TweenInfo.new(0.2), {BackgroundColor3 = active and Color3.fromRGB(0, 180, 110) or Color3.fromRGB(45, 45, 50)}):Play()
        TweenService:Create(Indicator, TweenInfo.new(0.2), {Position = active and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)}):Play()
        
        callback(active)
    end)
end

local function CreateDropdown(name, options, onSelect)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 40)
    Frame.BackgroundColor3 = Color3.fromRGB(26, 26, 28)
    Frame.Parent = Container
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Frame
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0, 110, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.Font = Enum.Font.GothamSemibold
    Label.TextSize = 12
    Label.TextColor3 = Color3.fromRGB(200, 200, 205)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame
    
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -135, 0, 26)
    Button.Position = UDim2.new(0, 123, 0.5, -13)
    Button.BackgroundColor3 = Color3.fromRGB(36, 36, 40)
    Button.Text = options[1] or "None"
    Button.Font = Enum.Font.Gotham
    Button.TextSize = 11
    Button.TextColor3 = Color3.fromRGB(230, 230, 235)
    Button.Parent = Frame
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 4)
    ButtonCorner.Parent = Button
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Thickness = 1
    Stroke.Color = Color3.fromRGB(50, 50, 55)
    Stroke.Parent = Button
    
    local CurrentIndex = 1
    Button.MouseButton1Click:Connect(function()
        CurrentIndex = CurrentIndex + 1
        if CurrentIndex > #options then CurrentIndex = 1 end
        Button.Text = options[CurrentIndex]
        onSelect(options[CurrentIndex])
    end)
    
    return function(newOptions)
        options = newOptions
        CurrentIndex = 1
        Button.Text = options[1] or "None"
        onSelect(options[1])
    end
end

-- ==========================================
-- HIGH-PERFORMANCE HARDWARE BOX ESP SYSTEM
-- ==========================================
local function IsTeammate(player)
    if player.Team == LocalPlayer.Team then return true end
    if player.TeamColor == LocalPlayer.TeamColor then return true end
    return false
end

local function RemoveHardwareEsp(player)
    if EspInstances[player] then
        for _, obj in ipairs(EspInstances[player]) do
            obj:Destroy()
        end
        EspInstances[player] = nil
    end
end

local function ApplyHardwareEsp(player)
    RemoveHardwareEsp(player)
    if not ScriptConfig.EspEnabled or IsTeammate(player) then return end
    
    local character = player.Character
    if not character then return end
    
    local targetPart = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
    if not targetPart then return end
    
    local boxAdornment = Instance.new("BoxHandleAdornment")
    boxAdornment.Size = character:GetExtentsSize() + Vector3.new(0.2, 0.2, 0.2)
    boxAdornment.AlwaysOnTop = true
    boxAdornment.ZIndex = 5
    boxAdornment.Adornee = targetPart
    boxAdornment.Color3 = Color3.fromRGB(255, 60, 60)
    boxAdornment.Transparency = 0.65
    boxAdornment.Parent = ScreenGui
    
    EspInstances[player] = { boxAdornment }
end

local function InitEspWorker()
    RegisterConnection(Players.PlayerAdded:Connect(function(player)
        RegisterConnection(player.CharacterAdded:Connect(function()
            task.wait(0.5) -- Small delay for character assembly instantiation
            if ScriptConfig.EspEnabled then ApplyHardwareEsp(player) end
        end))
    end))
    
    RegisterConnection(Players.PlayerRemoving:Connect(function(player)
        RemoveHardwareEsp(player)
    end))
    
    RegisterConnection(RunService.Heartbeat:Connect(function()
        if not ScriptConfig.EspEnabled then return end
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and not IsTeammate(player) then
                local instances = EspInstances[player]
                if not instances or #instances == 0 or not instances[1].Adornee or not instances[1].Parent then
                    ApplyHardwareEsp(player)
                end
            elseif IsTeammate(player) and EspInstances[player] then
                RemoveHardwareEsp(player)
            end
        end
    end))
end

-- ==========================================
-- COMPACT EVENT-BASED SKIN ENGINE
-- ==========================================
local function SkinChangerWorker(tool)
    if not ScriptConfig.SkinChangerEnabled or not tool:IsA("Tool") then return end
    
    if not OriginalAssets.WeaponTextures[tool] then
        OriginalAssets.WeaponTextures[tool] = {}
        for _, part in ipairs(tool:GetDescendants()) do
            if part:IsA("MeshPart") or part:IsA("SpecialMesh") then
                OriginalAssets.WeaponTextures[tool][part] = {
                    TextureId = part.TextureId,
                    Material = part:IsA("MeshPart") and part.Material or nil,
                    Color = part:IsA("MeshPart") and part.Color or nil
                }
            end
        end
    end
    
    local currentSkinData = SkinDatabase[ScriptConfig.SelectedCategory][ScriptConfig.SelectedSkin]
    if not currentSkinData then return end
    
    if ScriptConfig.SelectedCategory == "Weapons" then
        for _, part in ipairs(tool:GetDescendants()) do
            if part:IsA("MeshPart") or part:IsA("SpecialMesh") then
                part.TextureId = currentSkinData.TextureId
                if part:IsA("MeshPart") then
                    part.Material = currentSkinData.Material
                    part.Color = currentSkinData.Color
                end
            end
        end
    elseif ScriptConfig.SelectedCategory == "Knives" then
        for _, part in ipairs(tool:GetDescendants()) do
            if part:IsA("MeshPart") or part:IsA("SpecialMesh") then
                part.MeshId = currentSkinData.MeshId
                part.TextureId = currentSkinData.TextureId
            end
        end
    end
end

local function GLOVE_MODULE_PROCESS(character)
    if not ScriptConfig.SkinChangerEnabled or ScriptConfig.SelectedCategory ~= "Gloves" then return end
    local config = SkinDatabase.Gloves[ScriptConfig.SelectedSkin]
    if not config then return end
    
    for _, limbName in ipairs({"LeftArm", "RightArm", "LeftHand", "RightHand"}) do
        local limb = character:FindFirstChild(limbName)
        if limb and limb:IsA("BasePart") then
            if not OriginalAssets.DefaultHands[limb] then
                OriginalAssets.DefaultHands[limb] = { Material = limb.Material, Color = limb.Color }
            end
            limb.Material = config.Material
            limb.Color = limbName:find("Left") and config.LeftColor or config.RightColor
        end
    end
end

local function ListenToCharacter(character)
    if not character then return end
    
    RegisterConnection(character.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            task.wait()
            SkinChangerWorker(child)
        end
    end))
    
    RegisterConnection(RunService.Heartbeat:Connect(function()
        if ScriptConfig.SkinChangerEnabled and ScriptConfig.SelectedCategory == "Gloves" then
            GLOVE_MODULE_PROCESS(character)
        end
    end))
end

local function InitSkinEngine()
    if LocalPlayer.Character then ListenToCharacter(LocalPlayer.Character) end
    RegisterConnection(LocalPlayer.CharacterAdded:Connect(ListenToCharacter))
end

-- ==========================================
-- REGISTRATION AND CONTROL WIREFRAME
-- ==========================================
CreateToggleButton("Hardware Box ESP", "EspEnabled", function(state)
    if not state then
        for _, player in ipairs(Players:GetPlayers()) do RemoveHardwareEsp(player) end
    else
        for _, player in ipairs(Players:GetPlayers()) do ApplyHardwareEsp(player) end
    end
end)

CreateToggleButton("Skin Changer Master", "SkinChangerEnabled", function(state)
    if not state then
        for tool, parts in pairs(OriginalAssets.WeaponTextures) do
            if tool and tool.Parent then
                for part, data in pairs(parts) do
                    part.TextureId = data.TextureId
                    if part:IsA("MeshPart") then
                        part.Material = data.Material
                        part.Color = data.Color
                    end
                end
            end
        end
        for limb, data in pairs(OriginalAssets.DefaultHands) do
            if limb and limb.Parent then
                limb.Material = data.Material
                limb.Color = data.Color
            end
        end
    else
        local char = LocalPlayer.Character
        if char then
            local currentTool = char:FindFirstChildOfClass("Tool")
            if currentTool then SkinChangerWorker(currentTool) end
        end
    end
end)

local SkinDropdownUpdater
local SkinCategoryDropdown = CreateDropdown("Category", {"Weapons", "Knives", "Gloves"}, function(category)
    ScriptConfig.SelectedCategory = category
    local newOptions = {}
    for name, _ in pairs(SkinDatabase[category]) do
        table.insert(newOptions, name)
    end
    if SkinDropdownUpdater then
        SkinDropdownUpdater(newOptions)
    end
end)

SkinDropdownUpdater = CreateDropdown("Select Skin", {"Asimov", "Dragon Lore", "Hyper Beast", "Printstream"}, function(skinName)
    ScriptConfig.SelectedSkin = skinName
    if ScriptConfig.SkinChangerEnabled and LocalPlayer.Character then
        local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if tool then SkinChangerWorker(tool) end
    end
end)

-- ==========================================
-- COMPREHENSIVE REGISTRY CLEANUP
-- ==========================================
local function TotalUnloadRegistry()
    for _, connection in ipairs(ActiveConnections) do
        if connection then connection:Disconnect() end
    end
    
    for _, player in ipairs(Players:GetPlayers()) do
        RemoveHardwareEsp(player)
    end
    
    for tool, parts in pairs(OriginalAssets.WeaponTextures) do
        if tool and tool.Parent then
            for part, data in pairs(parts) do
                part.TextureId = data.TextureId
                if part:IsA("MeshPart") then
                    part.Material = data.Material
                    part.Color = data.Color
                end
            end
        end
    end
    
    for limb, data in pairs(OriginalAssets.DefaultHands) do
        if limb and limb.Parent then
            limb.Material = data.Material
            limb.Color = data.Color
        end
    end
    
    ScreenGui:Destroy()
end

CloseButton.MouseButton1Click:Connect(TotalUnloadRegistry)

-- Initialization Hooks
InitEspWorker()
InitSkinEngine()
