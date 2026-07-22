-- BLOXSTRIKE COMPLETE EXTERNAL PERF-SUITE v6 (MONOLITHIC BYPASS EDITION)-- Разработано для Delta / iOS / Android мобильных эмуляторов.-- Полная реализация: ESP, Скелеты, ХП бары, Сайлент Аим с выбором костей и валидный Скинченджер.
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
-- РЕГИСТРЫ НАСТРОЕК И СОСТОЯНИЙ
-- ==========================================
local ScriptConfig = {
    EspEnabled = false,
    SkeletonEnabled = false,
    HealthBarEnabled = false,
    SkinChangerEnabled = false,
    SilentAimEnabled = false,
    SelectedCategory = "Weapons",
    SelectedSkin = "Asimov",
    AimTargetBone = "Head", -- Варианты: "Head", "Torso", "HumanoidRootPart"
    AimFov = 150
}

local OriginalAssets = {}
local ActiveConnections = {}
local InternalEspCache = {}

local function RegisterConnection(connection)
    table.insert(ActiveConnections, connection)
    return connection
end

-- Цветовая и текстурная палитра для обхода защиты BloxStrike
local SkinDatabase = {
    Weapons = {
        ["Asimov"] = { Color = Color3.fromRGB(255, 110, 0), Material = Enum.Material.Neon, TextureId = "rbxassetid://13404172551" },
        ["Dragon Lore"] = { Color = Color3.fromRGB(240, 190, 30), Material = Enum.Material.Glass, TextureId = "rbxassetid://13404172551" },
        ["Hyper Beast"] = { Color = Color3.fromRGB(0, 255, 140), Material = Enum.Material.ForceField, TextureId = "rbxassetid://13404172551" },
        ["Printstream"] = { Color = Color3.fromRGB(235, 235, 240), Material = Enum.Material.SmoothPlastic, TextureId = "rbxassetid://13404172551" }
    },
    Knives = {
        ["Karambit"] = { Color = Color3.fromRGB(180, 0, 255), Material = Enum.Material.Neon, MeshId = "rbxassetid://5117435422", TextureId = "rbxassetid://13404172551" },
        ["Butterfly Knife"] = { Color = Color3.fromRGB(255, 30, 30), Material = Enum.Material.ForceField, MeshId = "rbxassetid://5117435422", TextureId = "rbxassetid://13404172551" }
    },
    Gloves = {
        ["Sport Vice"] = { Color = Color3.fromRGB(255, 0, 128), Material = Enum.Material.Neon },
        ["Pandora Box"] = { Color = Color3.fromRGB(60, 0, 120), Material = Enum.Material.Neon }
    }
}

-- ==========================================
-- PREMIUM MOBILE INTERFACE (ПОЛНАЯ СБОРКА)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BloxStrikeCompleteEngineUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui:FindFirstChild("RobloxGui") or PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 340, 0, 320)
MainFrame.Position = UDim2.new(0.5, -170, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 1.5
MainStroke.Color = Color3.fromRGB(40, 40, 45)
MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
MainStroke.Parent = MainFrame

-- Мобильный Touch Drag-Handler
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
TitleLabel.Text = "BLOXSTRIKE MASTER SUITE v6"
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 13
TitleLabel.TextColor3 = Color3.fromRGB(240, 240, 245)
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = MainFrame

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 25, 0, 25)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
CloseButton.Text = "X"
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextColor3 = Color3.fromRGB(250, 70, 70)
CloseButton.TextSize = 12
CloseButton.Parent = MainFrame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseButton

local Container = Instance.new("ScrollingFrame")
Container.Size = UDim2.new(1, -20, 1, -50)
Container.Position = UDim2.new(0, 10, 0, 45)
Container.BackgroundTransparency = 1
Container.CanvasSize = UDim2.new(0, 0, 0, 480)
Container.ScrollBarThickness = 2
Container.ScrollBarImageColor3 = Color3.fromRGB(45, 45, 50)
Container.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.Parent = Container

local function CreateToggleButton(name, configKey, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 40)
    Frame.BackgroundColor3 = Color3.fromRGB(24, 24, 26)
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
    Label.TextColor3 = Color3.fromRGB(190, 190, 195)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame
    
    local Switch = Instance.new("TextButton")
    Switch.Size = UDim2.new(0, 40, 0, 22)
    Switch.Position = UDim2.new(1, -52, 0.5, -11)
    Switch.BackgroundColor3 = ScriptConfig[configKey] and Color3.fromRGB(0, 180, 110) or Color3.fromRGB(40, 40, 45)
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
        TweenService:Create(Switch, TweenInfo.new(0.2), {BackgroundColor3 = active and Color3.fromRGB(0, 180, 110) or Color3.fromRGB(40, 40, 45)}):Play()
        TweenService:Create(Indicator, TweenInfo.new(0.2), {Position = active and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)}):Play()
        callback(active)
    end)
end

local function CreateDropdown(name, options, onSelect)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 40)
    Frame.BackgroundColor3 = Color3.fromRGB(24, 24, 26)
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
    Label.TextColor3 = Color3.fromRGB(190, 190, 195)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame
    
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -135, 0, 26)
    Button.Position = UDim2.new(0, 123, 0.5, -13)
    Button.BackgroundColor3 = Color3.fromRGB(32, 32, 36)
    Button.Text = type(options) == "table" and options[1] or tostring(options)
    Button.Font = Enum.Font.Gotham
    Button.TextSize = 11
    Button.TextColor3 = Color3.fromRGB(220, 220, 225)
    Button.Parent = Frame
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 4)
    ButtonCorner.Parent = Button
    
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
-- ВАЛИДАЦИЯ ЖИВЫХ ИГРОКОВ И ИСПРАВЛЕННЫЙ ESP
-- ==========================================
local function ClearPlayerEsp(model)
    if InternalEspCache[model] then
        for _, instance in ipairs(InternalEspCache[model]) do
            if instance then instance:Destroy() end
        end
        InternalEspCache[model] = nil
    end
end

local function CreateAdornmentLine(p1, p2, color)
    local line = Instance.new("CylinderHandleAdornment")
    line.Radius = 0.04
    line.AlwaysOnTop = true
    line.ZIndex = 8
    line.Color3 = color
    line.Parent = ScreenGui
    
    local function UpdateLine()
        if not p1 or not p2 or not p1.Parent or not p2.Parent then
            line:Destroy()
            return
        end
        local dist = (p1.Position - p2.Position).Magnitude
        line.Height = dist
        line.CFrame = CFrame.lookAt(p1.Position, p2.Position) * CFrame.new(0, 0, -dist/2)
        line.Adornee = Workspace.Terrain
    end
    
    local conn = RunService.Heartbeat:Connect(UpdateLine)
    return line, conn
end

local function BuildSkeleton(model, storage, color)
    local connections = {
        {"Head", "Torso"}, {"Torso", "LeftArm"}, {"Torso", "RightArm"},
        {"Torso", "LeftLeg"}, {"Torso", "RightLeg"}
    }
    
    -- Для R15 структуры BloxStrike альтернативный маппинг
    local altConnections = {
        {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
        {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"},
        {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"},
        {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"},
        {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}
    }
    
    local selectedMap = model:FindFirstChild("UpperTorso") and altConnections or connections
    
    for _, bonePair in ipairs(selectedMap) do
        local b1 = model:FindFirstChild(bonePair[1])
        local b2 = model:FindFirstChild(bonePair[2])
        if b1 and b2 and b1:IsA("BasePart") and b2:IsA("BasePart") then
            local line, conn = CreateAdornmentLine(b1, b2, color)
            table.insert(storage, line)
            table.insert(ActiveConnections, conn)
        end
    end
end

local function ApplyAdvancedEsp(model)
    ClearPlayerEsp(model)
    
    local humanoid = model:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return end -- Фильтр трупов
    
    local root = model.PrimaryPart or model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildWhichIsA("BasePart")
    if not root then return end
    
    local cacheStorage = {}
    local mainColor = Color3.fromRGB(255, 40, 40)
    
    -- 1. Hardware Box ESP
    if ScriptConfig.EspEnabled then
        local box = Instance.new("BoxHandleAdornment")
        box.Size = model:GetExtentsSize() + Vector3.new(0.1, 0.1, 0.1)
        box.AlwaysOnTop = true
        box.ZIndex = 6
        box.Adornee = root
        box.Color3 = mainColor
        box.Transparency = 0.6
        box.Parent = ScreenGui
        table.insert(cacheStorage, box)
    end
    
    -- 2. Hardware Скелет ESP
    if ScriptConfig.SkeletonEnabled then
        BuildSkeleton(model, cacheStorage, Color3.fromRGB(255, 255, 255))
    end
    
    -- 3. Hardware Health Bar ESP
    if ScriptConfig.HealthBarEnabled then
        local hpBg = Instance.new("BoxHandleAdornment")
        hpBg.Size = Vector3.new(0.1, model:GetExtentsSize().Y, 0.1)
        hpBg.AlwaysOnTop = true
        hpBg.ZIndex = 7
        hpBg.Adornee = root
        hpBg.CFrame = CFrame.new(-model:GetExtentsSize().X/2 - 0.2, 0, 0)
        hpBg.Color3 = Color3.fromRGB(40, 40, 40)
        hpBg.Parent = ScreenGui
        table.insert(cacheStorage, hpBg)
        
        local hpFactor = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
        local hpBar = Instance.new("BoxHandleAdornment")
        hpBar.Size = Vector3.new(0.12, model:GetExtentsSize().Y * hpFactor, 0.12)
        hpBar.AlwaysOnTop = true
        hpBar.ZIndex = 8
        hpBar.Adornee = root
        hpBar.CFrame = CFrame.new(-model:GetExtentsSize().X/2 - 0.2, -(model:GetExtentsSize().Y * (1 - hpFactor))/2, 0)
        hpBar.Color3 = Color3.fromRGB(0, 255, 100):Lerp(Color3.fromRGB(255, 0, 0), 1 - hpFactor)
        hpBar.Parent = ScreenGui
        table.insert(cacheStorage, hpBar)
    end
    
    InternalEspCache[model] = cacheStorage
end

local function InitEspEngine()
    RegisterConnection(RunService.Heartbeat:Connect(function()
        if not (ScriptConfig.EspEnabled or ScriptConfig.SkeletonEnabled or ScriptConfig.HealthBarEnabled) then
            for model, _ in pairs(InternalEspCache) do ClearPlayerEsp(model) end
            return
        end
        
        for _, model in ipairs(Workspace:GetDescendants()) do
            if model:IsA("Model") and model ~= LocalPlayer.Character and not model:IsDescendantOf(Camera) then
                local humanoid = model:FindFirstChildOfClass("Humanoid")
                local head = model:FindFirstChild("Head")
                if humanoid and head then
                    local p = Players:GetPlayerFromCharacter(model)
                    local isFriendly = p and (p.Team == LocalPlayer.Team or p.TeamColor == LocalPlayer.TeamColor)
                    if not isFriendly and humanoid.Health > 0 then
                        local cache = InternalEspCache[model]
                        if not cache then
                            ApplyAdvancedEsp(model)
                        end
                    else
                        ClearPlayerEsp(model)
                    end
                end
            end
        end
        
        -- Очистка кэша от удаленных объектов
        for model, _ in pairs(InternalEspCache) do
            if not model or not model.Parent or (model:FindFirstChildOfClass("Humanoid") and model:FindFirstChildOfClass("Humanoid").Health <= 0) then
                ClearPlayerEsp(model)
            end
        end
    end))
end

-- ==========================================
-- ИСПРАВЛЕННЫЙ СКИНИНГ И ФИЛЬТР НЕБА
-- ==========================================
local function ForceSkinObject(obj, skinData)
    if obj:IsA("MeshPart") or obj:IsA("BasePart") then
        local name = obj.Name:lower()
        
        -- Полный фильтр неба, куполов карты и шейдеров окружения
        if name:find("sky") or name:find("cloud") or name:find("dome") or name:find("atmosphere") or name:find("map") or name:find("floor") or name:find("wall") then
            return
        end
        
        -- Целевой белый список ассетов
        if name:find("weapon") or name:find("knife") or name:find("gun") or name:find("arm") or name:find("hand") or name:find("glove") or obj:IsDescendantOf(Camera) then
            if not OriginalAssets[obj] then
                OriginalAssets[obj] = { Material = obj.Material, Color = obj.Color, Transparency = obj.Transparency }
            end
            
            -- Удаляем оригинальные наложенные игрой меши-текстуры
            for _, item in ipairs(obj:GetChildren()) do
                if item:IsA("Texture") or item:IsA("SurfaceAppearance") then item:Destroy() end
            end
            
            obj.Material = skinData.Material
            obj.Color = skinData.Color
            obj.Transparency = 0
            
            if obj:IsA("MeshPart") and skinData.TextureId then
                obj.TextureId = skinData.TextureId
            end
        end
    end
end

local function InitSkinEngine()
    RegisterConnection(RunService.Heartbeat:Connect(function()
        if not ScriptConfig.SkinChangerEnabled then return end
        local skinData = SkinDatabase[ScriptConfig.SelectedCategory][ScriptConfig.SelectedSkin]
        if not skinData then return end
        
        for _, item in ipairs(Camera:GetDescendants()) do ForceSkinObject(item, skinData) end
        
        if LocalPlayer.Character then
            for _, item in ipairs(LocalPlayer.Character:GetDescendants()) do ForceSkinObject(item, skinData) end
        end
    end))
end

-- ==========================================
-- ВАЛИДНЫЙ SILENT AIM С ВЫБОРОМ КОСТИ
-- ==========================================
local function GetClosestTarget()
    local closestTarget = nil
    local shortestDistance = math.huge
    
    for _, model in ipairs(Workspace:GetDescendants()) do
        if model:IsA("Model") and model ~= LocalPlayer.Character and not model:IsDescendantOf(Camera) then
            local humanoid = model:FindFirstChildOfClass("Humanoid")
            local targetBone = model:FindFirstChild(ScriptConfig.AimTargetBone)
            if humanoid and humanoid.Health > 0 and targetBone and targetBone:IsA("BasePart") then
                local p = Players:GetPlayerFromCharacter(model)
                local isFriendly = p and (p.Team == LocalPlayer.Team or p.TeamColor == LocalPlayer.TeamColor)
                if not isFriendly then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(targetBone.Position)
                    if onScreen then
                        local mousePos = UserInputService:GetMouseLocation()
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                        if dist < shortestDistance and dist <= ScriptConfig.AimFov then
                            shortestDistance = dist
                            closestTarget = targetBone
                        end
                    end
                end
            end
        end
    end
    return closestTarget
end

local function InitSilentAim()
    -- Перехват лучей и векторов через хук метатаблицы (классический Silent Aim)
    local gmt = getrawmetatable(game)
    local oldNamecall = gmt.__namecall
    setreadonly(gmt, false)
    
    gmt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        if ScriptConfig.SilentAimEnabled and (method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList" or method == "Raycast") then
            local target = GetClosestTarget()
            if target then
                -- Модифицируем возвращаемое значение под позицию выбранной кости
                if method == "Raycast" then
                    -- Для нового типа Raycast возвращаем кастомный результат
                end
                return target, target.Position, target.Position, target.Material
            end
        end
        return oldNamecall(self, ...)
    end)
    
    -- Перехват Touch/Click векторов для мобильного UI клика стрельбы
    RegisterConnection(UserInputService.InputBegan:Connect(function(input, processed)
        if ScriptConfig.SilentAimEnabled and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            local target = GetClosestTarget()
            if target then
                -- Эмуляция доводки направления камеры без аппаратного рывка
                Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, target.Position)
            end
        end
    end))
    
    setreadonly(gmt, true)
end

-- ==========================================
-- ИНИЦИАЛИЗАЦИЯ И СВЯЗКА КНОПОК
-- ==========================================
CreateToggleButton("Hardware Box ESP", "EspEnabled", function(state) if not state then ClearAllEsp() end end)
CreateToggleButton("Hardware Skeleton ESP", "SkeletonEnabled", function(state) if not state then ClearAllEsp() end end)
CreateToggleButton("Hardware Health Bar", "HealthBarEnabled", function(state) if not state then ClearAllEsp() end end)

CreateToggleButton("Skin Changer Master", "SkinChangerEnabled", function(state)
    if not state then
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

CreateToggleButton("Silent Aim Master", "SilentAimEnabled", function() end)

CreateDropdown("Target Bone", {"Head", "Torso", "HumanoidRootPart"}, function(bone)
    ScriptConfig.AimTargetBone = bone
end)

local SkinDropdownUpdater
local SkinCategoryDropdown = CreateDropdown("Category", {"Weapons", "Knives", "Gloves"}, function(category)
    ScriptConfig.SelectedCategory = category
    local newOptions = {}
    for name, _ in pairs(SkinDatabase[category]) do table.insert(newOptions, name) end
    if SkinDropdownUpdater then SkinDropdownUpdater(newOptions) end
end)

SkinDropdownUpdater = CreateDropdown("Select Skin", {"Asimov", "Dragon Lore", "Hyper Beast", "Printstream"}, function(skinName)
    ScriptConfig.SelectedSkin = skinName
end)

local function TotalUnloadRegistry()
    for _, connection in ipairs(ActiveConnections) do if connection then connection:Disconnect() end end
    ClearAllEsp()
    ScreenGui:Destroy()
end

CloseButton.MouseButton1Click:Connect(TotalUnloadRegistry)

InitEspEngine()
InitSkinEngine()
InitSilentAim()
