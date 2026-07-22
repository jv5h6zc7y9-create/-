-- BLOXSTRIKE ULTRA PERF-SUITE v4 (TOTAL BYPASS & OVERLAY INJECTION)-- Разработано специально для обхода блокировки TextureId и скрытых моделей врагов.
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
-- КОНФИГУРАЦИЯ И ЦВЕТОВАЯ БАЗА СКИНОВ
-- ==========================================
local ScriptConfig = {
    EspEnabled = false,
    SkinChangerEnabled = false,
    SelectedCategory = "Weapons",
    SelectedSkin = "Asimov"
}

local OriginalAssets = {}
local ActiveConnections = {}
local EspInstances = {}

local function RegisterConnection(connection)
    table.insert(ActiveConnections, connection)
    return connection
end

-- Из-за защиты игры переходим на систему генерации кастомных материалов и перекрытия цветов
local SkinDatabase = {
    Weapons = {
        ["Asimov"] = { Color = Color3.fromRGB(255, 110, 0), Material = Enum.Material.Neon },
        ["Dragon Lore"] = { Color = Color3.fromRGB(240, 190, 30), Material = Enum.Material.Glass },
        ["Hyper Beast"] = { Color = Color3.fromRGB(0, 255, 140), Material = Enum.Material.ForceField },
        ["Printstream"] = { Color = Color3.fromRGB(235, 235, 240), Material = Enum.Material.SmoothPlastic }
    },
    Knives = {
        ["Karambit"] = { Color = Color3.fromRGB(180, 0, 255), Material = Enum.Material.Neon },
        ["Butterfly Knife"] = { Color = Color3.fromRGB(255, 30, 30), Material = Enum.Material.ForceField }
    },
    Gloves = {
        ["Sport Vice"] = { Color = Color3.fromRGB(255, 0, 128), Material = Enum.Material.Neon },
        ["Pandora Box"] = { Color = Color3.fromRGB(60, 0, 120), Material = Enum.Material.Neon }
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

-- Сенсорное перетаскивание меню
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
TitleLabel.Text = "BLOXSTRIKE PERF-SUITE v4 (BYPASS)"
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
-- ТОТАЛЬНЫЙ АГРЕССИВНЫЙ ПОИСК ВРАГОВ ДЛЯ ESP
-- ==========================================
local function ClearAllEsp()
    for _, adornment in pairs(EspInstances) do
        if adornment then adornment:Destroy() end
    end
    table.clear(EspInstances)
end

local function InitEspWorker()
    RegisterConnection(RunService.Heartbeat:Connect(function()
        if not ScriptConfig.EspEnabled then 
            ClearAllEsp()
            return 
        end
        
        -- Сканируем всё пространство игры на скрытые модельки
        for _, model in ipairs(Workspace:GetDescendants()) do
            if model:IsA("Model") and model ~= LocalPlayer.Character and not model:IsDescendantOf(Camera) then
                -- Признак игрока в BloxStrike: наличие Humanoid или специфичных хитбоксов
                local hasHumanoid = model:FindFirstChildOfClass("Humanoid")
                local anyPart = model:FindFirstChildWhichIsA("BasePart")
                
                if anyPart and (hasHumanoid or model.Name:find("Player") or model:FindFirstChild("Head")) then
                    -- Проверка на тиммейта через поиск ника над головой или в таблице
                    local isFriendly = false
                    local p = Players:GetPlayerFromCharacter(model)
                    if p and (p.Team == LocalPlayer.Team or p.TeamColor == LocalPlayer.TeamColor) then
                        isFriendly = true
                    end
                    
                    if not isFriendly then
                        if not EspInstances[model] or not EspInstances[model].Parent then
                            if EspInstances[model] then EspInstances[model]:Destroy() end
                            
                            local boxAdornment = Instance.new("BoxHandleAdornment")
                            boxAdornment.Size = model:GetExtentsSize() + Vector3.new(0.3, 0.3, 0.3)
                            boxAdornment.AlwaysOnTop = true
                            boxAdornment.ZIndex = 10
                            boxAdornment.Adornee = anyPart
                            boxAdornment.Color3 = Color3.fromRGB(255, 35, 35)
                            boxAdornment.Transparency = 0.5
                            boxAdornment.Parent = ScreenGui
                            
                            EspInstances[model] = boxAdornment
                        end
                    end
                end
            end
        end
    end))
end

-- ==========================================
-- ОБХОД ЗАЩИТЫ ТЕКСТУР (ИНЖЕКЦИЯ СЛОЕВ)
-- ==========================================
local function ForceStyleInstance(obj, skinData)
    if obj:IsA("MeshPart") or obj:IsA("BasePart") then
        -- Вместо TextureId перекрашиваем сам физический слой и материал детали
        if not OriginalAssets[obj] then
            OriginalAssets[obj] = {
                Material = obj.Material,
                Color = obj.Color,
                Transparency = obj.Transparency
            }
        end
        
        -- Удаляем внутренние текстурные меши игры, если они блокируют цвет
        local tex = obj:FindFirstChildOfClass("Texture") or obj:FindFirstChildOfClass("SurfaceAppearance")
        if tex then tex:Destroy() end
        
        obj.Material = skinData.Material
        obj.Color = skinData.Color
        obj.Transparency = 0 -- Делаем скин видимым сквозь тени матча
    end
end

local function ScanAndApplySkins()
    if not ScriptConfig.SkinChangerEnabled then return end
    
    local currentSkinData = SkinDatabase[ScriptConfig.SelectedCategory][ScriptConfig.SelectedSkin]
    if not currentSkinData then return end
    
    -- Инжекция в пушку в руках от первого лица (Camera)
    for _, item in ipairs(Camera:GetDescendants()) do
        ForceStyleInstance(item, currentSkinData)
    end
    
    -- Инжекция в пушку на персонаже от третьего лица
    if LocalPlayer.Character then
        for _, item in ipairs(LocalPlayer.Character:GetDescendants()) do
            if item:IsA("Tool") or item.Name:find("Weapon") or item.Name:find("Knife") then
                for _, subItem in ipairs(item:GetDescendants()) do
                    ForceStyleInstance(subItem, currentSkinData)
                end
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
-- УПРАВЛЕНИЕ И СБРОС СИСТЕМЫ
-- ==========================================
CreateToggleButton("Hardware Box ESP", "EspEnabled", function(state)
    if not state then ClearAllEsp() end
end)

CreateToggleButton("Skin Changer Master", "SkinChangerEnabled", function(state)
    if not state then
        -- Полный откат к заводским ассетам BloxStrike
        for obj, data in pairs(OriginalAssets) do
            if obj and obj.Parent then
                obj.Material = data.Material
                obj.Color = data.Color
                obj.Transparency = data.Transparency
            end
        end
        table.clear(OriginalAssets)
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
    ClearAllEsp()
    ScreenGui:Destroy()
end

CloseButton.MouseButton1Click:Connect(TotalUnloadRegistry)

InitEspWorker()
InitSkinEngine()
