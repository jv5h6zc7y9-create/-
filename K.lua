-- BloxStrike Premium Mega Edition Framework-- Архитектура без сокращений, со всеми функциями, глубоким инвентарем и авто-сбросом при выходе
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Глобальное состояние
local Config = {
    ESPBoxes = false,
    ESPSkeletons = false,
    SilentAimEnabled = false,
    SkinChangerEnabled = false,
    SelectedCategory = "Weapons", -- Доступные: "Weapons", "Knives", "Gloves"
    SelectedSkin = "Asimov",
    FOVValue = 120,
}

-- Хранилища оригинальных данных и объектов отрисовки
local OriginalWeaponData = {}
local OriginalGloveData = {}
local CacheESP = {}
local InternalConnections = {}

-- Глубокая база данных текстур, мешей и материалов для BloxStrike
local SkinDatabase = {
    ["Weapons"] = {
        ["Asimov"] = { Texture = "rbxassetid://257913346", Material = Enum.Material.SmoothPlastic, Color = Color3.fromRGB(255, 120, 0), Mesh = nil },
        ["Dragon Lore"] = { Texture = "rbxassetid://142071830", Material = Enum.Material.Fabric, Color = Color3.fromRGB(220, 190, 80), Mesh = nil },
        ["Hyper Beast"] = { Texture = "rbxassetid://341498188", Material = Enum.Material.Glass, Color = Color3.fromRGB(200, 30, 150), Mesh = nil },
        ["Printstream"] = { Texture = "rbxassetid://587425124", Material = Enum.Material.Neon, Color = Color3.fromRGB(255, 255, 255), Mesh = nil },
        ["Gold-Line"] = { Texture = "", Material = Enum.Material.Metal, Color = Color3.fromRGB(255, 215, 0), Mesh = nil }
    },
    ["Knives"] = {
        ["Karambit | Fade"] = { Texture = "rbxassetid://142071830", Material = Enum.Material.Glass, Color = Color3.fromRGB(255, 50, 150), Mesh = "rbxassetid://441991931" },
        ["Butterfly | Doppler"] = { Texture = "rbxassetid://341498188", Material = Enum.Material.Neon, Color = Color3.fromRGB(80, 0, 120), Mesh = "rbxassetid://540021626" },
        ["M9 Bayonet | Lore"] = { Texture = "rbxassetid://257913346", Material = Enum.Material.Metal, Color = Color3.fromRGB(240, 200, 70), Mesh = "rbxassetid://942204271" },
        ["Hunting | Crimson"] = { Texture = "", Material = Enum.Material.SmoothPlastic, Color = Color3.fromRGB(180, 10, 20), Mesh = "rbxassetid://441991210" }
    },
    ["Gloves"] = {
        ["Sport | Vice"] = { Texture = "rbxassetid://341498188", Material = Enum.Material.Fabric, Color = Color3.fromRGB(255, 0, 128) },
        ["Pandora Box"] = { Texture = "rbxassetid://142071830", Material = Enum.Material.Fabric, Color = Color3.fromRGB(100, 30, 220) },
        ["Driver | King Snake"] = { Texture = "", Material = Enum.Material.SmoothPlastic, Color = Color3.fromRGB(245, 245, 245) },
        ["Slick | Gold Core"] = { Texture = "", Material = Enum.Material.Metal, Color = Color3.fromRGB(230, 180, 40) }
    }
}

-- Поиск списков для циклического переключения в интерфейсе
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

-- Построение кастомного мобильного UI меню
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BloxStrikeMegaMenu"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 310, 0, 490)
MainFrame.Position = UDim2.new(0.5, -155, 0.5, -245)
MainFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 17)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(60, 55, 75)
MainStroke.Thickness = 2
MainStroke.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 0, 45)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "BLOXSTRIKE MASTER MULTIHACK"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 13
TitleLabel.Parent = MainFrame

local function CreateMenuButton(name, posY, text)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(0.92, 0, 0, 36)
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

-- Элементы управления на форме
local BoxBtn = CreateMenuButton("BoxBtn", 50, "Box ESP: OFF")
local SkeletonBtn = CreateMenuButton("SkeletonBtn", 92, "Skeleton ESP: OFF")
local AimBtn = CreateMenuButton("AimBtn", 134, "Perfect Silent Aim: OFF")
local SkinTogglerBtn = CreateMenuButton("SkinTogglerBtn", 176, "Skin Changer Master: OFF")

local CategorySelectBtn = CreateMenuButton("CategorySelectBtn", 225, "Category: Weapons")
CategorySelectBtn.BackgroundColor3 = Color3.fromRGB(30, 25, 40)

local SkinSelectBtn = CreateMenuButton("SkinSelectBtn", 267, "Select Skin: Asimov")
SkinSelectBtn.BackgroundColor3 = Color3.fromRGB(30, 25, 40)

-- Контейнер масштабирования круга FOV
local FovContainer = Instance.new("Frame")
FovContainer.Size = UDim2.new(0.92, 0, 0, 40)
FovContainer.Position = UDim2.new(0.04, 0, 0, 315)
FovContainer.BackgroundTransparency = 1
FovContainer.Parent = MainFrame

local FovLabel = Instance.new("TextLabel")
FovLabel.Size = UDim2.new(0.4, 0, 1, 0)
FovLabel.BackgroundTransparency = 1
FovLabel.Font = Enum.Font.GothamMedium
FovLabel.Text = "FOV Radius: 120"
FovLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
FovLabel.TextSize = 12
FovLabel.Parent = FovContainer

local MinusBtn = Instance.new("TextButton")
MinusBtn.Size = UDim2.new(0, 34, 0, 34)
MinusBtn.Position = UDim2.new(0.52, 0, 0.08, 0)
MinusBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
MinusBtn.Text = "-"
MinusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinusBtn.Parent = FovContainer
Instance.new("UICorner", MinusBtn)

local PlusBtn = Instance.new("TextButton")
PlusBtn.Size = UDim2.new(0, 34, 0, 34)
PlusBtn.Position = UDim2.new(0.78, 0, 0.08, 0)
PlusBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
PlusBtn.Text = "+"
PlusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
PlusBtn.Parent = FovContainer
Instance.new("UICorner", PlusBtn)

local CloseBtn = CreateMenuButton("CloseBtn", 420, "Unload Script & Full Reset")
CloseBtn.BackgroundColor3 = Color3.fromRGB(80, 25, 30)

-- Создание геометрического круга FOV
local FovCircle = Drawing.new("Circle")
FovCircle.Visible = true
FovCircle.Filled = false
FovCircle.Color = Color3.fromRGB(255, 50, 50)
FovCircle.Transparency = 0.8
FovCircle.Thickness = 1.5
FovCircle.Radius = Config.FOVValue

-- Функция верификации врага
local function CheckIsEnemy(playerTarget)
    if playerTarget == LocalPlayer then return false end
    if LocalPlayer.Team and playerTarget.Team == LocalPlayer.Team then return false end
    return true
end

-- Генерация линий через встроенный Drawing API
local function AllocateLine()
    local l = Drawing.new("Line")
    l.Visible = false
    l.Color = Color3.fromRGB(255, 50, 50)
    l.Thickness = 1.5
    l.Transparency = 1
    return l
end

-- Конфигурация кэша ESP для игрока
local function SetupPlayerESPCache(player)
    if CacheESP[player] then return end
    CacheESP[player] = {
        Box = {
            Top = AllocateLine(),
            Bottom = AllocateLine(),
            Left = AllocateLine(),
            Right = AllocateLine()
        },
        Skeleton = {
            Spine = AllocateLine(),
            LeftArm = AllocateLine(),
            RightArm = AllocateLine(),
            LeftLeg = AllocateLine(),
            RightLeg = AllocateLine()
        }
    }
end

-- Деаллокация графических линий игрока
local function RemovePlayerESPCache(player)
    if CacheESP[player] then
        for _, line in pairs(CacheESP[player].Box) do line:Remove() end
        for _, line in pairs(CacheESP[player].Skeleton) do line:Remove() end
        CacheESP[player] = nil
    end
end

-- Извлечение ключевых узлов суставов скелета
local function FetchJoints(charModel)
    local head = charModel:FindFirstChild("Head")
    local torso = charModel:FindFirstChild("UpperTorso") or charModel:FindFirstChild("Torso")
    local leftArm = charModel:FindFirstChild("LeftUpperArm") or charModel:FindFirstChild("Left Arm")
    local rightArm = charModel:FindFirstChild("RightUpperArm") or charModel:FindFirstChild("Right Arm")
    local leftLeg = charModel:FindFirstChild("LeftUpperLeg") or charModel:FindFirstChild("Left Leg")
    local rightLeg = charModel:FindFirstChild("RightUpperLeg") or charModel:FindFirstChild("Right Leg")
    return head, torso, leftArm, rightArm, leftLeg, rightLeg
end

-- Обработка вычислений экранных 2D Box и Скелетов
local function PerformESPDrawing()
    for _, player in ipairs(Players:GetPlayers()) do
        if CheckIsEnemy(player) and player.Character then
            local character = player.Character
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            local humanoid = character:FindFirstChildOfClass("Humanoid")

            if rootPart and humanoid and humanoid.Health > 0 then
                SetupPlayerESPCache(player)
                local visualData = CacheESP[player]
                local rPos, isOnScreen = Camera:WorldToViewportPoint(rootPart.Position)

                if isOnScreen then
                    if Config.ESPBoxes then
                        local multiplier = 1 / (rPos.Z * math.tan(math.rad(Camera.FieldOfView / 2))) * 1000
                        local boxW, boxH = multiplier * 4.4, multiplier * 5.8
                        local posX, posY = rPos.X - boxW / 2, rPos.Y - boxH / 2

                        visualData.Box.Top.From = Vector2.new(posX, posY)
                        visualData.Box.Top.To = Vector2.new(posX + boxW, posY)
                        visualData.Box.Bottom.From = Vector2.new(posX, posY + boxH)
                        visualData.Box.Bottom.To = Vector2.new(posX + boxW, posY + boxH)
                        visualData.Box.Left.From = Vector2.new(posX, posY)
                        visualData.Box.Left.To = Vector2.new(posX, posY + boxH)
                        visualData.Box.Right.From = Vector2.new(posX + boxW, posY)
                        visualData.Box.Right.To = Vector2.new(posX + boxW, posY + boxH)

                        for _, line in pairs(visualData.Box) do line.Visible = true end
                    else
                        for _, line in pairs(visualData.Box) do line.Visible = false end
                    end

                    if Config.ESPSkeletons then
                        local head, torso, lArm, rArm, lLeg, rLeg = FetchJoints(character)
                        if head and torso then
                            local sHead = Camera:WorldToViewportPoint(head.Position)
                            local sTorso = Camera:WorldToViewportPoint(torso.Position)

                            visualData.Skeleton.Spine.From = Vector2.new(sHead.X, sHead.Y)
                            visualData.Skeleton.Spine.To = Vector2.new(sTorso.X, sTorso.Y)
                            visualData.Skeleton.Spine.Visible = true

                            if lArm then
                                local sLArm = Camera:WorldToViewportPoint(lArm.Position)
                                visualData.Skeleton.LeftArm.From = Vector2.new(sTorso.X, sTorso.Y)
                                visualData.Skeleton.LeftArm.To = Vector2.new(sLArm.X, sLArm.Y)
                                visualData.Skeleton.LeftArm.Visible = true
                            else visualData.Skeleton.LeftArm.Visible = false end

                            if rArm then
                                local sRArm = Camera:WorldToViewportPoint(rArm.Position)
                                visualData.Skeleton.RightArm.From = Vector2.new(sTorso.X, sTorso.Y)
                                visualData.Skeleton.RightArm.To = Vector2.new(sRArm.X, sRArm.Y)
                                visualData.Skeleton.RightArm.Visible = true
                            else visualData.Skeleton.RightArm.Visible = false end

                            if lLeg then
                                local sLLeg = Camera:WorldToViewportPoint(lLeg.Position)
                                visualData.Skeleton.LeftLeg.From = Vector2.new(sTorso.X, sTorso.Y)
                                visualData.Skeleton.LeftLeg.To = Vector2.new(sLLeg.X, sLLeg.Y)
                                visualData.Skeleton.LeftLeg.Visible = true
                            else visualData.Skeleton.LeftLeg.Visible = false end

                            if rLeg then
                                local sRLeg = Camera:WorldToViewportPoint(rLeg.Position)
                                visualData.Skeleton.RightLeg.From = Vector2.new(sTorso.X, sTorso.Y)
                                visualData.Skeleton.RightLeg.To = Vector2.new(sRLeg.X, sRLeg.Y)
                                visualData.Skeleton.RightLeg.Visible = true
                            else visualData.Skeleton.RightLeg.Visible = false end
                        else
                            for _, line in pairs(visualData.Skeleton) do line.Visible = false end
                        end
                    else
                        for _, line in pairs(visualData.Skeleton) do line.Visible = false end
                    end
                else
                    for _, line in pairs(visualData.Box) do line.Visible = false end
                    for _, line in pairs(visualData.Skeleton) do line.Visible = false end
                end
            else
                RemovePlayerESPCache(player)
            end
        else
            RemovePlayerESPCache(player)
        end
    end
end

-- Алгоритм поиска ближайшей головы противника в FOV
local function AcquireAimbotTarget()
    local closestHead = nil
    local currentMinDistance = Config.FOVValue
    local screenCenterPoint = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, player in ipairs(Players:GetPlayers()) do
        if CheckIsEnemy(player) and player.Character then
            local character = player.Character
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            local headJoint = character:FindFirstChild("Head")

            if humanoid and humanoid.Health > 0 and headJoint then
                local convertedPos, onScreenView = Camera:WorldToViewportPoint(headJoint.Position)
                if onScreenView then
                    local calculatedDistance = (Vector2.new(convertedPos.X, convertedPos.Y) - screenCenterPoint).Magnitude
                    if calculatedDistance < currentMinDistance then
                        currentMinDistance = calculatedDistance
                        closestHead = headJoint
                    end
                end
            end
        end
    end
    return closestHead
end

-- Низкоуровневые хуки движка через метатаблицу
local OriginalIndex
OriginalIndex = hookmetamethod(game, "__index", function(self, indexKey)
    if Config.SilentAimEnabled and not checkcaller() then
        if indexKey == "Hit" or indexKey == "Target" then
            local targetBone = AcquireAimbotTarget()
            if targetBone then
                local leadPrediction = targetBone.Position + (targetBone.AssemblyLinearVelocity * 0.048)
                if indexKey == "Hit" then return CFrame.new(leadPrediction) else return targetBone end
            end
        end
    end
    return OriginalIndex(self, indexKey)
end)

local OriginalNamecall
OriginalNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local namecallMethod = getnamecallmethod()
    if Config.SilentAimEnabled and not checkcaller() then
        if namecallMethod == "FindPartOnRay" or namecallMethod == "Raycast" then
            local standardArgs = {...}
            local targetBone = AcquireAimbotTarget()
            if targetBone and standardArgs then
                local vectorOrigin = standardArgs[1]
                if typeof(vectorOrigin) == "Vector3" then
                    local leadPrediction = targetBone.Position + (targetBone.AssemblyLinearVelocity * 0.048)
                    local calculatedDirection = (leadPrediction - vectorOrigin).Unit * 1000
                    if namecallMethod == "FindPartOnRay" then
                        standardArgs[1] = Ray.new(vectorOrigin, calculatedDirection)
                    elseif namecallMethod == "Raycast" then
                        standardArgs[2] = calculatedDirection
                    end
                    return OriginalNamecall(self, unpack(standardArgs))
                end
            end
        end
    end
    return OriginalNamecall(self, ...)
end)

-- Функция возвращения оригинальных скинов оружия в исходный вид
local function ResetWeaponSkins()
    for partInstance, originalAttribs in pairs(OriginalWeaponData) do
        if partInstance and partInstance.Parent then
            pcall(function()
                if partInstance:IsA("BasePart") then
                    partInstance.Color = originalAttribs.Color
                    partInstance.Material = originalAttribs.Material
                elseif partInstance:IsA("MeshPart") or partInstance:IsA("SpecialMesh") then
                    partInstance.TextureId = originalAttribs.TextureId
                    if originalAttribs.MeshId then
                        partInstance.MeshId = originalAttribs.MeshId
                    end
                end
            end)
        end
    end
    OriginalWeaponData = {}
end

-- Функция возвращения перчаток рук в исходный вид
local function ResetGloves()
    for meshInstance, originalTexture in pairs(OriginalGloveData) do
        if meshInstance and meshInstance.Parent then
            pcall(function()
                meshInstance.TextureId = originalTexture
            end)
        end
    end
    OriginalGloveData = {}
end

-- Комплексный движок Скинченджера (Оружие + Ножи + Перчатки)
local function ProcessSkinChangerCycle()
    if not Config.SkinChangerEnabled then
        ResetWeaponSkins()
        ResetGloves()
        return
    end

    local skinProperties = SkinDatabase[Config.SelectedCategory][Config.SelectedSkin]
    if not skinProperties then return end

    local character = LocalPlayer.Character
    if not character then return end

    -- Обработка оружия и ножей (Tools в инвентаре/руках)
    for _, item in ipairs(character:GetChildren()) do
        if item:IsA("Tool") then
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
                        OriginalWeaponData[instanceNode] = {
                            TextureId = instanceNode.TextureId,
                            MeshId = instanceNode:IsA("MeshPart") and instanceNode.MeshId or instanceNode.MeshId
                        }
                    end
                    if skinProperties.Texture and skinProperties.Texture ~= "" then
                        instanceNode.TextureId = skinProperties.Texture
                    end
                    -- Кастомная подмена формы лезвия, если выбран раздел Ножей ("Knives")
                    if Config.SelectedCategory == "Knives" and skinProperties.Mesh then
                        instanceNode.MeshId = skinProperties.Mesh
                    end
                end
            end
        end
    end

    -- Перекраска перчаток (Локальная замена мешей рук персонажа)
    if Config.SelectedCategory == "Gloves" then
        for _, limbName in ipairs({"LeftHand", "RightHand", "LeftLowerArm", "RightLowerArm"}) do
            local limbPart = character:FindFirstChild(limbName)
            if limbPart and limbPart:IsA("MeshPart") then
                if not OriginalGloveData[limbPart] then
                    OriginalGloveData[limbPart] = limbPart.TextureId
                end
                limbPart.TextureId = skinProperties.Texture
                limbPart.Color = skinProperties.Color
                limbPart.Material = skinProperties.Material
            end
        end
    end
end

-- Асинхронный поток для циклической проверки оружия игрока
local SkinLoopThread = task.spawn(function()
    while task.wait(0.25) do
        if Config.SkinChangerEnabled then
            pcall(ProcessSkinChangerCycle)
        end
    end
end)

-- Подключение к кадру обновления экрана через RenderStepped
local RenderStepConnection = RunService.RenderStepped:Connect(function()
    FovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FovCircle.Radius = Config.FOVValue
    FovCircle.Visible = Config.SilentAimEnabled
    PerformESPDrawing()
end)

-- Маршрутизация кликов интерфейса
BoxBtn.MouseButton1Click:Connect(function()
    Config.ESPBoxes = not Config.ESPBoxes
    BoxBtn.Text = Config.ESPBoxes and "Box ESP: ON" or "Box ESP: OFF"
    BoxBtn.TextColor3 = Config.ESPBoxes and Color3.fromRGB(80, 255, 80) or Color3.fromRGB(210, 210, 210)
end)

SkeletonBtn.MouseButton1Click:Connect(function()
    Config.ESPSkeletons = not Config.ESPSkeletons
    SkeletonBtn.Text = Config.ESPSkeletons and "Skeleton ESP: ON" or "Skeleton ESP: OFF"
    SkeletonBtn.TextColor3 = Config.ESPSkeletons and Color3.fromRGB(80, 255, 80) or Color3.fromRGB(210, 210, 210)
end)

AimBtn.MouseButton1Click:Connect(function()
    Config.SilentAimEnabled = not Config.SilentAimEnabled
    AimBtn.Text = Config.SilentAimEnabled and "Perfect Silent Aim: ON" or "Perfect Silent Aim: OFF"
    AimBtn.TextColor3 = Config.SilentAimEnabled and Color3.fromRGB(80, 255, 80) or Color3.fromRGB(210, 210, 210)
end)

SkinTogglerBtn.MouseButton1Click:Connect(function()
    Config.SkinChangerEnabled = not Config.SkinChangerEnabled
    SkinTogglerBtn.Text = Config.SkinChangerEnabled and "Skin Changer Master: ON" or "Skin Changer Master: OFF"
    SkinTogglerBtn.TextColor3 = Config.SkinChangerEnabled and Color3.fromRGB(80, 255, 80) or Color3.fromRGB(210, 210, 210)
    pcall(ProcessSkinChangerCycle)
end)

-- Переключение категории инвентаря
CategorySelectBtn.MouseButton1Click:Connect(function()
    CurrentCategoryIndex = CurrentCategoryIndex + 1
    if CurrentCategoryIndex > #CategoryList then CurrentCategoryIndex = 1 end
    Config.SelectedCategory = CategoryList[CurrentCategoryIndex]
    CategorySelectBtn.Text = "Category: " .. Config.SelectedCategory

    -- Сброс индекса скинов под новую категорию
    local available = GetSkinsForCurrentCategory()
    CurrentSkinIndex = 1
    Config.SelectedSkin = available[CurrentSkinIndex]
    SkinSelectBtn.Text = "Select Skin: " .. Config.SelectedSkin
    if Config.SkinChangerEnabled then pcall(ProcessSkinChangerCycle) end
end)

-- Переключение конкретного скина внутри выбранной категории
SkinSelectBtn.MouseButton1Click:Connect(function()
    local availableSkins = GetSkinsForCurrentCategory()
    CurrentSkinIndex = CurrentSkinIndex + 1
    if CurrentSkinIndex > #availableSkins then CurrentSkinIndex = 1 end
    Config.SelectedSkin = availableSkins[CurrentSkinIndex]
    SkinSelectBtn.Text = "Select Skin: " .. Config.SelectedSkin
    if Config.SkinChangerEnabled then pcall(ProcessSkinChangerCycle) end
end)

PlusBtn.MouseButton1Click:Connect(function()
    Config.FOVValue = math.min(Config.FOVValue + 15, 360)
    FovLabel.Text = "FOV Radius: " .. tostring(Config.FOVValue)
end)

MinusBtn.MouseButton1Click:Connect(function()
    Config.FOVValue = math.max(Config.FOVValue - 15, 30)
    FovLabel.Text = "FOV Radius: " .. tostring(Config.FOVValue)
end)

-- Кнопка деактивации и полного удаления скрипта
CloseBtn.MouseButton1Click:Connect(function()
    Config.ESPBoxes = false
    Config.ESPSkeletons = false
    Config.SilentAimEnabled = false
    Config.SkinChangerEnabled = false

    -- Полный откат изменений текстур и мешей рук/оружия
    ResetWeaponSkins()
    ResetGloves()

    for _, targetPlayer in ipairs(Players:GetPlayers()) do
        RemovePlayerESPCache(targetPlayer)
    end

    if RenderStepConnection then RenderStepConnection:Disconnect() end
    if SkinLoopThread then task.cancel(SkinLoopThread) end
    FovCircle:Remove()
    ScreenGui:Destroy()
end)

-- Реализация Drag & Drop для экранов iPhone/iPad
local IsUIBarsDragging = false
local DragInputData = nil
local DragInitialStart = nil
local FrameStartPosition = nil

MainFrame.InputBegan:Connect(function(uiInput)
    if uiInput.UserInputType == Enum.UserInputType.MouseButton1 or uiInput.UserInputType == Enum.UserInputType.Touch then
        IsUIBarsDragging = true
        DragInitialStart = uiInput.Position
        FrameStartPosition = MainFrame.Position
        uiInput.Changed:Connect(function()
            if uiInput.UserInputState == Enum.UserInputState.End then
                IsUIBarsDragging = false
            end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(uiInput)
    if uiInput.UserInputType == Enum.UserInputType.MouseMovement or uiInput.UserInputType == Enum.UserInputType.Touch then
        DragInputData = uiInput
    end
end)

UserInputService.InputChanged:Connect(function(uiInput)
    if uiInput == DragInputData and IsUIBarsDragging then
        local deltaPos = uiInput.Position - DragInitialStart
        MainFrame.Position = UDim2.new(
            FrameStartPosition.X.Scale,
            FrameStartPosition.X.Offset + deltaPos.X,
            FrameStartPosition.Y.Scale,
            FrameStartPosition.Y.Offset + deltaPos.Y
        )
    end
end)

-- Системная очистка при дисконнекте игроков или смерти персонажа
Players.PlayerRemoving:Connect(function(exitedPlayer)
    RemovePlayerESPCache(exitedPlayer)
end)

LocalPlayer.CharacterRemoving:Connect(function()
    ResetWeaponSkins()
    ResetGloves()
end)

print("[BloxStrike Production Script]: All parameters initiated without exclusions.")
