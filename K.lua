-- BLOXSTRIKE ULTRA PERF-SUITE v3 (WITH INVENTORY UI SCANNER)-- Оптимизировано для iOS/Android эмуляторов и инжекторов.
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = Workspace.CurrentCamera

-- ==========================================
-- КОНФИГУРАЦИЯ И ПЛЕСХОЛДЕРЫ ТЕКСТУР
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

local SkinDatabase = {
    Weapons = {
        ["Asimov"] = { TextureId = "rbxassetid://13404172551", Material = Enum.Material.SmoothPlastic, Color = Color3.fromRGB(255, 120, 0) },
        ["Dragon Lore"] = { TextureId = "rbxassetid://13404172551", Material = Enum.Material.Glass, Color = Color3.fromRGB(230, 185, 40) },
        ["Hyper Beast"] = { TextureId = "rbxassetid://13404172551", Material = Enum.Material.Neon, Color = Color3.fromRGB(0, 255, 150) },
        ["Printstream"] = { TextureId = "rbxassetid://13404172551", Material = Enum.Material.SmoothPlastic, Color = Color3.fromRGB(240, 240, 245) }
    },
    Knives = {
        ["Karambit"] = { MeshId = "rbxassetid://5117435422", TextureId = "rbxassetid://13404172551" },
        ["Butterfly Knife"] = { MeshId = "rbxassetid://5117435422", TextureId = "rbxassetid://13404172551" }
    },
    Gloves = {
        ["Sport Vice"] = { LeftColor = Color3.fromRGB(255, 0, 128), RightColor = Color3.fromRGB(0, 191, 255), Material = Enum.Material.Neon },
        ["Pandora Box"] = { LeftColor = Color3.fromRGB(75, 0, 130), RightColor = Color3.fromRGB(75, 0, 130), Material = Enum.Material.Fabric }
    }
}

-- ==========================================
-- PREMIUM MOBILE DARK UI
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BloxStrikeHardwareOptimizedUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui:FindFirstChild("RobloxGui") or PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 340, 0, 260)
MainFrame.Position = UDim2.new(0.5, -170, 0.5, -130)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 22)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 1.5
MainStroke.Color = Color3.fromRGB(45, 45, 50)
MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
MainStroke.Parent = MainFrame

-- Кастомный Touch-Drag рендеринг
local Dragging, DragInput, DragStart, StartPosition

RegisterConnection(MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        Dragging = true
        DragStart = input.Position
        StartPosition = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then Dragging = false end
        end)
    end
end))

RegisterConnection(MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then DragInput = input end
end))

RegisterConnection(UserInputService.InputChanged:Connect(function(input)
    if input == DragInput and Dragging then
        local delta = input.Position - DragStart
        MainFrame.Position = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + delta.Y)
    end
end))

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -40, 0, 35)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "BLOXSTRIKE EXTERNAL PERF-SUITE v3"
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
    Button.Text = type(options) == "table" and options[1] or tostring(options)
    Button.Font = Enum.Font.Gotham
    Button.TextSize = 11
    Button.TextColor3 = Color3.fromRGB(230, 230, 235)
    Button.Parent = Frame
    
    local CurrentIndex = 1
    Button.MouseButton1Click:Connect(function()
        if type(options) ~= "table" or #options == 0 then return end
        CurrentIndex = CurrentIndex + 1
        if CurrentIndex > #options then CurrentIndex = 1 end
        Button.Text = options[CurrentIndex]
        onSelect(options[CurrentIndex])
    end)
    
    return function(newOptions)
        options = newOptions
        CurrentIndex = 1
        Button.Text = type(options) == "table" and options[1] or "None"
        if type(options) == "table" and options[1] then onSelect(options[1]) end
    end
end

-- ==========================================
-- ИСПРАВЛЕННЫЙ HARDWARE ESP
-- ==========================================
local function IsTeammate(player)
    if player.Team == LocalPlayer.Team then return true end
    if player.TeamColor == LocalPlayer.TeamColor then return true end
    return false
end

local function RemoveHardwareEsp(player)
    if EspInstances[player] then
        for _, obj in ipairs(EspInstances[player]) do
            if obj then obj:Destroy() end
        end
        EspInstances[player] = nil
    end
end

local function ApplyHardwareEsp(player)
    RemoveHardwareEsp(player)
    if not ScriptConfig.EspEnabled or IsTeammate(player) then return end
    
    local character = player.Character
    if not character then return end
    
    local targetPart = character.PrimaryPart or character:FindFirstChild("HumanoidRootPart") or character:FindFirstChildWhichIsA("BasePart")
    if not targetPart then return end
    
    local boxAdornment = Instance.new("BoxHandleAdornment")
    boxAdornment.Size = character:GetExtentsSize() + Vector3.new(0.1, 0.1, 0.1)
    boxAdornment.AlwaysOnTop = true
    boxAdornment.ZIndex = 5
    boxAdornment.Adornee = targetPart
    boxAdornment.Color3 = Color3.fromRGB(255, 60, 60)
    boxAdornment.Transparency = 0.65
    boxAdornment.Parent = ScreenGui
    
    EspInstances[player] = { boxAdornment }
end

local function InitEspWorker()
    RegisterConnection(RunService.Heartbeat:Connect(function()
        if not ScriptConfig.EspEnabled then return end
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                if not IsTeammate(player) then
                    local instances = EspInstances[player]
                    if not instances or not instances[1] or not instances[1].Parent or not instances[1].Adornee then
                        ApplyHardwareEsp(player)
                    end
                else
                    if EspInstances[player] then RemoveHardwareEsp(player) end
                end
            end
        end
    end))
end

-- ==========================================
-- ГЛОБАЛЬНЫЙ СКИНЧЕНДЖЕР (ОКРУЖЕНИЕ + ИНВЕНТАРЬ)
-- ==========================================
local function ApplySkinToInstance(obj, currentSkinData)
    if obj:IsA("MeshPart") or obj:IsA("SpecialMesh") then
        if not OriginalAssets.WeaponTextures[obj] then
            OriginalAssets.WeaponTextures[obj] = {
                TextureId = obj.TextureId,
                Material = obj:IsA("MeshPart") and obj.Material or nil,
                Color = obj:IsA("MeshPart") and obj.Color or nil,
                MeshId = obj:IsA("MeshPart") and obj.MeshId or (obj:IsA("SpecialMesh") and obj.MeshId or nil)
            }
        end
        
        if ScriptConfig.SelectedCategory == "Weapons" then
            obj.TextureId = currentSkinData.TextureId
            if obj:IsA("MeshPart") then
                obj.Material = currentSkinData.Material
                obj.Color = currentSkinData.Color
            end
        elseif ScriptConfig.SelectedCategory == "Knives" then
            obj.MeshId = currentSkinData.MeshId
            obj.TextureId = currentSkinData.TextureId
        end
    end
end

local function ScanAndApplySkins()
    if not ScriptConfig.SkinChangerEnabled then return end
    
    local currentSkinData = SkinDatabase[ScriptConfig.SelectedCategory][ScriptConfig.SelectedSkin]
    if not currentSkinData then return end
    
    -- 1. Сканирование мира и рук
    if LocalPlayer.Character then
        for _, item in ipairs(LocalPlayer.Character:GetDescendants()) do
            ApplySkinToInstance(item, currentSkinData)
        end
    end
    
    -- 2. Сканирование камеры (первый вид пушек в BloxStrike)
    for _, item in ipairs(Camera:GetDescendants()) do
        ApplySkinToInstance(item, currentSkinData)
    end
    
    -- 3. ХУК ИНВЕНТАРЯ (Попытка подмены скинов во ViewportFrames главного меню)
    for _, gui in ipairs(PlayerGui:GetDescendants()) do
        if gui:IsA("ViewportFrame") then
            for _, item in ipairs(gui:GetDescendants()) do
                ApplySkinToInstance(item, currentSkinData)
            end
        end
    end
end

local function InitSkinEngine()
    RegisterConnection(RunService.Heartbeat:Connect(function()
        if ScriptConfig.SkinChangerEnabled then
            ScanAndApplySkins()
        end
    end))
end

-- ==========================================
-- ИНИЦИАЛИЗАЦИЯ И РЕГИСТРАЦИЯ КОМПОНЕНТОВ
-- ==========================================
CreateToggleButton("Hardware Box ESP", "EspEnabled", function(state)
    if not state then
        for _, player in ipairs(Players:GetPlayers()) do RemoveHardwareEsp(player) end
    end
end)

CreateToggleButton("Skin Changer Master", "SkinChangerEnabled", function(state)
    if not state then
        for obj, data in pairs(OriginalAssets.WeaponTextures) do
            if obj and obj.Parent then
                obj.TextureId = data.TextureId
                if obj:IsA("MeshPart") then
                    obj.Material = data.Material
                    obj.Color = data.Color
                    obj.MeshId = data.MeshId
                elseif obj:IsA("SpecialMesh") then
                    obj.MeshId = data.MeshId
                end
            end
        end
        table.clear(OriginalAssets.WeaponTextures)
    end
end)

local SkinDropdownUpdater
local SkinCategoryDropdown = CreateDropdown("Category", {"Weapons", "Knives", "Gloves"}, function(category)
    ScriptConfig.SelectedCategory = category
    local newOptions = {}
    for name, _ in pairs(SkinDatabase[category]) do
        table.insert(newOptions, name)
    end
    if SkinDropdownUpdater then SkinDropdownUpdater(newOptions) end
end)

SkinDropdownUpdater = CreateDropdown("Select Skin", {"Asimov", "Dragon Lore", "Hyper Beast", "Printstream"}, function(skinName)
    ScriptConfig.SelectedSkin = skinName
end)

local function TotalUnloadRegistry()
    for _, connection in ipairs(ActiveConnections) do
        if connection then connection:Disconnect() end
    end
    for _, player in ipairs(Players:GetPlayers()) do RemoveHardwareEsp(player) end
    ScreenGui:Destroy()
end

CloseButton.MouseButton1Click:Connect(TotalUnloadRegistry)

InitEspWorker()
InitSkinEngine()
