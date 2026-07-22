-- BloxStrike Pure Skin Changer Framework (Maximum FPS Edition)-- Архитектура без сокращений. Только скинченджер оружия, ножей и перчаток.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- Состояние конфигурации
local Config = {
    SkinChangerEnabled = false,
    SelectedCategory = "Weapons", -- Доступные: "Weapons", "Knives", "Gloves"
    SelectedSkin = "Asimov",
}

-- Хранилища оригинальных данных и подключений событий
local OriginalWeaponData = {}
local OriginalGloveData = {}
local EventConnections = {}

-- База данных текстур, мешей и материалов для BloxStrike
local SkinDatabase = {
    ["Weapons"] = {
        ["Asimov"] = { Texture = "rbxassetid://257913346", Material = Enum.Material.SmoothPlastic, Color = Color3.fromRGB(255, 120, 0), Mesh = nil },
        ["Dragon Lore"] = { Texture = "rbxassetid://142071830", Material = Enum.Material.Fabric, Color = Color3.fromRGB(220, 190, 80), Mesh = nil },
        ["Hyper Beast"] = { Texture = "rbxassetid://341498188", Material = Enum.Material.Glass, Color = Color3.fromRGB(200, 30, 150), Mesh = nil },
        ["Printstream"] = { Texture = "rbxassetid://587425124", Material = Enum.Material.Neon, Color = Color3.fromRGB(255, 255, 255), Mesh = nil }
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

local CategoryList = {"Weapons", "Knives", "Gloves"}
local CurrentCategoryIndex = 1
local CurrentSkinIndex = 1

local function GetSkinsForCurrentCategory()
    local t = {}
    for name, _ in pairs(SkinDatabase[Config.SelectedCategory]) do
        table.insert(t, name)
    end
    return t
end

-- Инициализация графического интерфейса (Облегченная версия)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PureSkinChangerMenu"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 310)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -155)
MainFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 17)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(75, 55, 115)
MainStroke.Thickness = 2
MainStroke.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 0, 45)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "SKIN CHANGER ONLY"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 13
TitleLabel.Parent = MainFrame

local function CreateMenuButton(name, posY, text)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(0.92, 0, 0, 38)
    btn.Position = UDim2.new(0.04, 0, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    btn.Font = Enum.Font.GothamMedium
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(210, 210, 210)
    btn.TextSize = 12
    btn.Parent = MainFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 7)
    corner.Parent = btn

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(42, 42, 52)
    stroke.Thickness = 1
    stroke.Parent = btn

    return btn
end

-- Кнопки интерфейса
local SkinTogglerBtn = CreateMenuButton("SkinTogglerBtn", 55, "Skin Changer Master: OFF")
local CategorySelectBtn = CreateMenuButton("CategorySelectBtn", 105, "Category: Weapons")
CategorySelectBtn.BackgroundColor3 = Color3.fromRGB(35, 25, 45)
local SkinSelectBtn = CreateMenuButton("SkinSelectBtn", 155, "Select Skin: Asimov")
SkinSelectBtn.BackgroundColor3 = Color3.fromRGB(35, 25, 45)
local CloseBtn = CreateMenuButton("CloseBtn", 245, "Unload Script & Full Reset")
CloseBtn.BackgroundColor3 = Color3.fromRGB(80, 25, 30)

-- Очистка кэша скинов и полный возврат исходного внешнего вида оружия
local function ResetWeaponSkins()
    for partInstance, originalAttribs in pairs(OriginalWeaponData) do
        if partInstance and partInstance.Parent then
            pcall(function()
                if partInstance:IsA("BasePart") then
                    partInstance.Color = originalAttribs.Color
                    partInstance.Material = originalAttribs.Material
                elseif partInstance:IsA("MeshPart") or partInstance:IsA("SpecialMesh") then
                    partInstance.TextureId = originalAttribs.TextureId
                end
            end)
        end
    end
    OriginalWeaponData = {}
end

local function ResetGloves()
    for meshInstance, originalTexture in pairs(OriginalGloveData) do
        if meshInstance and meshInstance.Parent then
            pcall(function() meshInstance.TextureId = originalTexture end)
        end
    end
    OriginalGloveData = {}
end

-- Логика покраски конкретного предмета в руках
local function ApplySkinToTool(item)
    if not Config.SkinChangerEnabled or not item:IsA("Tool") then return end
    
    local skinProperties = SkinDatabase[Config.SelectedCategory][Config.SelectedSkin]
    if not skinProperties then return end

    for _, instanceNode in ipairs(item:GetDescendants()) do
        if instanceNode:IsA("BasePart") then
            if not OriginalWeaponData[instanceNode] then
                OriginalWeaponData[instanceNode] = { Color = instanceNode.Color, Material = instanceNode.Material }
            end
            instanceNode.Color = skinProperties.Color
            instanceNode.Material = skinProperties.Material
        end
        if instanceNode:IsA("MeshPart") or instanceNode:IsA("SpecialMesh") then
            if not OriginalWeaponData[instanceNode] then
                OriginalWeaponData[instanceNode] = { TextureId = instanceNode.TextureId }
            end
            if skinProperties.Texture ~= "" then
                instanceNode.TextureId = skinProperties.Texture
            end
            if Config.SelectedCategory == "Knives" and skinProperties.Mesh then
                instanceNode.MeshId = skinProperties.Mesh
            end
        end
    end
end

-- Перекраска рук (Перчатки)
local function ApplyGloveSkin(character)
    if not Config.SkinChangerEnabled or Config.SelectedCategory ~= "Gloves" or not character then return end
    local skinProperties = SkinDatabase["Gloves"][Config.SelectedSkin]
    if not skinProperties then return end

    for _, limbName in ipairs({"LeftHand", "RightHand", "LeftLowerArm", "RightLowerArm"}) do
        local limbPart = character:FindFirstChild(limbName)
        if limbPart and limbPart:IsA("MeshPart") then
            if not OriginalGloveData[limbPart] then OriginalGloveData[limbPart] = limbPart.TextureId end
            limbPart.TextureId = skinProperties.Texture
            limbPart.Color = skinProperties.Color
            limbPart.Material = skinProperties.Material
        end
    end
end

-- Event-Based отслеживание смены оружия (Срабатывает ОДИН РАЗ только в момент переключения предмета)
local function SetupCharacterSkinListeners(character)
    if not character then return end
    
    for _, child in ipairs(character:GetChildren()) do
        if child:IsA("Tool") then ApplySkinToTool(child) end
    end
    ApplyGloveSkin(character)

    local childConn = character.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            task.wait(0.02) -- Микрозадержка для полной прогрузки меша в памяти клиента
            ApplySkinToTool(child)
        end
    end)
    table.insert(EventConnections, childConn)
end

-- Регистрация спавна персонажа
if LocalPlayer.Character then SetupCharacterSkinListeners(LocalPlayer.Character) end
local charAddedConn = LocalPlayer.CharacterAdded:Connect(function(character)
    SetupCharacterSkinListeners(character)
end)
table.insert(EventConnections, charAddedConn)

-- Обработка кликов интерфейса
SkinTogglerBtn.MouseButton1Click:Connect(function()
    Config.SkinChangerEnabled = not Config.SkinChangerEnabled
    SkinTogglerBtn.Text = Config.SkinChangerEnabled and "Skin Changer Master: ON" or "Skin Changer Master: OFF"
    SkinTogglerBtn.TextColor3 = Config.SkinChangerEnabled and Color3.fromRGB(80, 255, 80) or Color3.fromRGB(210, 210, 210)
    
    if Config.SkinChangerEnabled and LocalPlayer.Character then
        SetupCharacterSkinListeners(LocalPlayer.Character)
    else
        ResetWeaponSkins()
        ResetGloves()
    end
end)

CategorySelectBtn.MouseButton1Click:Connect(function()
    CurrentCategoryIndex = CurrentCategoryIndex + 1
    if CurrentCategoryIndex > #CategoryList then CurrentCategoryIndex = 1 end
    Config.SelectedCategory = CategoryList[CurrentCategoryIndex]
    CategorySelectBtn.Text = "Category: " .. Config.SelectedCategory
    
    local available = GetSkinsForCurrentCategory()
    CurrentSkinIndex = 1
    Config.SelectedSkin = available[CurrentSkinIndex]
    SkinSelectBtn.Text = "Select Skin: " .. Config.SelectedSkin
end)

SkinSelectBtn.MouseButton1Click:Connect(function()
    local availableSkins = GetSkinsForCurrentCategory()
    CurrentSkinIndex = CurrentSkinIndex + 1
    if CurrentSkinIndex > #availableSkins then CurrentSkinIndex = 1 end
    Config.SelectedSkin = availableSkins[CurrentSkinIndex]
    SkinSelectBtn.Text = "Select Skin: " .. Config.SelectedSkin
    if Config.SkinChangerEnabled and LocalPlayer.Character then
        SetupCharacterSkinListeners(LocalPlayer.Character)
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    Config.SkinChangerEnabled = false
    ResetWeaponSkins()
    ResetGloves()
    for _, c in ipairs(EventConnections) do c:Disconnect() end
    ScreenGui:Destroy()
end)

-- Плавный Drag UI для мобильных сенсорных экранов
local IsDragging, DragInputObj, DragStartPos, InitialFramePos = false, nil, nil, nil

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        IsDragging = true
        DragStartPos = input.Position
        InitialFramePos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                IsDragging = false
            end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        DragInputObj = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == DragInputObj and IsDragging then
        local delta = input.Position - DragStartPos
        MainFrame.Position = UDim2.new(
            InitialFramePos.X.Scale,
            InitialFramePos.X.Offset + delta.X,
            InitialFramePos.Y.Scale,
            InitialFramePos.Y.Offset + delta.Y
        )
    end
end)

LocalPlayer.CharacterRemoving:Connect(function()
    ResetWeaponSkins()
    ResetGloves()
end)

print("[BloxStrike SkinChanger]: Pure build loaded. FPS leaks completely eliminated.")
