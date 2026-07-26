-- Block Strike iPad | Delta iOS
-- Полностью оптимизированный скрипт
-- Убран getgc() из Heartbeat — главный убийца FPS
-- Кэш частей персонажа, переиспользуемый RaycastParams, троттлинг ESP
-- Меню на русском языке

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- ============================================
-- НАСТРОЙКИ АИМА
-- ============================================

local AimConfig = {
    Enabled = true,
    Speed = 0.18,
    FieldOfView = 200,
    TeamCheck = true,
    HitPart = "Head",
    Prediction = 0.12,
    MaxDistance = 500,
    TargetSearchInterval = 0.15
}

-- ============================================
-- НАСТРОЙКИ ВХ
-- ============================================

local WallhackConfig = {
    Enabled = true,
    Boxes = true,
    Skeleton = false,
    HealthBar = true,
    Name = true,
    Distance = true,
    MaxDistance = 400,
    BoxColor = Color3.fromRGB(255, 50, 50),
    BoxVisibleColor = Color3.fromRGB(50, 255, 50),
    SkeletonColor = Color3.fromRGB(180, 180, 180),
    SkeletonVisibleColor = Color3.fromRGB(255, 255, 255),
    TextSize = 12,
    UpdateInterval = 0.08
}

-- ============================================
-- СОСТОЯНИЕ АИМА
-- ============================================

local IsHoldingFire = false
local CurrentTarget = nil
local LastTargetSearchTime = 0

-- ============================================
-- УТИЛИТЫ
-- ============================================

local function WorldToScreen(position)
    local screenPosition = Camera:WorldToViewportPoint(position)
    return Vector2.new(screenPosition.X, screenPosition.Y), screenPosition.Z
end

local function GetCenterOfScreen()
    local viewportSize = Camera.ViewportSize
    return Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
end

local function IsCharacterAlive(character)
    if not character then
        return false
    end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.Health > 0 then
        return true
    end
    return false
end

local function IsPlayerTeammate(player)
    if not AimConfig.TeamCheck then
        return false
    end
    if player.Team == LocalPlayer.Team then
        return true
    end
    return false
end

-- ============================================
-- КЭШ ЧАСТЕЙ ПЕРСОНАЖА (один раз при появлении)
-- ============================================

local CharacterPartCache = {}

local function CacheCharacterParts(character)
    if not character then
        return nil
    end
    local cache = {
        Head = character:WaitForChild("Head", 1),
        HumanoidRootPart = character:WaitForChild("HumanoidRootPart", 1),
        UpperTorso = character:FindFirstChild("UpperTorso"),
        LowerTorso = character:FindFirstChild("LowerTorso"),
        RightUpperArm = character:FindFirstChild("RightUpperArm"),
        RightLowerArm = character:FindFirstChild("RightLowerArm"),
        LeftUpperArm = character:FindFirstChild("LeftUpperArm"),
        LeftLowerArm = character:FindFirstChild("LeftLowerArm"),
        RightUpperLeg = character:FindFirstChild("RightUpperLeg"),
        LeftUpperLeg = character:FindFirstChild("LeftUpperLeg"),
        Humanoid = character:FindFirstChildOfClass("Humanoid")
    }
    return cache
end

local function GetCachedCharacterParts(character)
    if not CharacterPartCache[character] then
        CharacterPartCache[character] = CacheCharacterParts(character)
    end
    return CharacterPartCache[character]
end

local function ClearCharacterPartCache(character)
    CharacterPartCache[character] = nil
end

-- ============================================
-- ПЕРЕИСПОЛЬЗУЕМЫЙ RAYCASTPARAMS
-- ============================================

local SharedRaycastParams = RaycastParams.new()
SharedRaycastParams.FilterType = Enum.RaycastFilterType.Blacklist

-- ============================================
-- ПОИСК ЦЕЛИ ДЛЯ АИМА (с интервалом)
-- ============================================

local function FindNearestEnemyHead()
    local centerOfScreen = GetCenterOfScreen()
    local cameraPosition = Camera.CFrame.Position
    local bestTarget = nil
    local bestDistance = AimConfig.FieldOfView

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then
            continue
        end
        if IsPlayerTeammate(player) then
            continue
        end

        local character = player.Character
        if not IsCharacterAlive(character) then
            continue
        end

        local parts = GetCachedCharacterParts(character)
        if not parts or not parts.Head then
            continue
        end

        local screenPosition, depth = WorldToScreen(parts.Head.Position)
        if depth <= 0 then
            continue
        end

        local distanceFromCenter = (screenPosition - centerOfScreen).Magnitude
        if distanceFromCenter >= bestDistance then
            continue
        end

        local distance3D = (parts.Head.Position - cameraPosition).Magnitude
        if distance3D > AimConfig.MaxDistance then
            continue
        end

        bestDistance = distanceFromCenter
        bestTarget = parts.Head
    end

    return bestTarget
end

-- ============================================
-- СГЛАЖЕННАЯ НАВОДКА
-- ============================================

local function SmoothAimAtTarget(targetHead, deltaTime)
    if not targetHead or not targetHead.Parent then
        CurrentTarget = nil
        return
    end

    local parts = GetCachedCharacterParts(targetHead.Parent)
    local velocity = Vector3.zero
    if parts and parts.HumanoidRootPart then
        velocity = parts.HumanoidRootPart.Velocity
    end

    local predictedPosition = targetHead.Position + (velocity * AimConfig.Prediction)
    local targetCFrame = CFrame.new(Camera.CFrame.Position, predictedPosition)

    local speed = AimConfig.Speed
    if deltaTime then
        speed = speed * (deltaTime * 60)
    end

    Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, math.min(speed, 1))
end

-- ============================================
-- ОБРАБОТКА ВВОДА
-- ============================================

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then
        return
    end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if not AimConfig.Enabled then
            return
        end
        IsHoldingFire = true
        CurrentTarget = FindNearestEnemyHead()
        LastTargetSearchTime = tick()
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessedEvent)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        IsHoldingFire = false
        CurrentTarget = nil
    end
end)

-- ============================================
-- ГЛАВНЫЙ ЦИКЛ АИМА (с интервалом поиска цели)
-- ============================================

RunService.RenderStepped:Connect(function(deltaTime)
    if not IsHoldingFire then
        return
    end

    local currentTime = tick()
    if not CurrentTarget or (currentTime - LastTargetSearchTime) > AimConfig.TargetSearchInterval then
        CurrentTarget = FindNearestEnemyHead()
        LastTargetSearchTime = currentTime
    end

    if CurrentTarget then
        SmoothAimAtTarget(CurrentTarget, deltaTime)
    end
end)

-- ============================================
-- ХУК УДАЛЁННЫХ ВЫЗОВОВ
-- ============================================

local rawMetatable = getrawmetatable(game)
setreadonly(rawMetatable, false)
local originalNamecall = rawMetatable.__namecall

rawMetatable.__namecall = newcclosure(function(self, ...)
    local methodName = getnamecallmethod()
    local arguments = {...}

    if methodName == "FireServer" then
        local remoteName = tostring(self):lower()

        if remoteName:find("shoot") or remoteName:find("fire") or remoteName:find("bullet") or remoteName:find("hit") or remoteName:find("damage") or remoteName:find("gun") or remoteName:find("weapon") then

            if IsHoldingFire and CurrentTarget and CurrentTarget.Parent then
                local parts = GetCachedCharacterParts(CurrentTarget.Parent)
                local velocity = Vector3.zero
                if parts and parts.HumanoidRootPart then
                    velocity = parts.HumanoidRootPart.Velocity
                end
                local aimPosition = CurrentTarget.Position + (velocity * AimConfig.Prediction)

                for index, argument in ipairs(arguments) do
                    if typeof(argument) == "Vector3" then
                        arguments[index] = aimPosition
                        break
                    elseif typeof(argument) == "CFrame" then
                        arguments[index] = CFrame.new(aimPosition)
                        break
                    elseif typeof(argument) == "Ray" then
                        arguments[index] = Ray.new(Camera.CFrame.Position, (aimPosition - Camera.CFrame.Position).Unit * 1000)
                        break
                    end
                end
            end
        end
    end

    return originalNamecall(self, unpack(arguments))
end)

setreadonly(rawMetatable, true)

-- ============================================
-- АНТИ-ОТДАЧА (один раз при загрузке, НЕ в Heartbeat)
-- ============================================

task.spawn(function()
    task.wait(3)

    for _, garbageCollectedObject in pairs(getgc()) do
        if typeof(garbageCollectedObject) == "table" then
            local recoilFields = {"Recoil", "Spread", "CameraRecoil", "MaxSpread", "MinSpread", "RecoilX", "RecoilY", "Kick", "KickUp", "KickSide", "Bloom", "Accuracy"}
            for _, fieldName in ipairs(recoilFields) do
                if garbageCollectedObject[fieldName] ~= nil and typeof(garbageCollectedObject[fieldName]) == "number" then
                    garbageCollectedObject[fieldName] = 0
                elseif garbageCollectedObject[fieldName] ~= nil and typeof(garbageCollectedObject[fieldName]) == "table" then
                    for key, _ in pairs(garbageCollectedObject[fieldName]) do
                        if typeof(garbageCollectedObject[fieldName][key]) == "number" then
                            garbageCollectedObject[fieldName][key] = 0
                        end
                    end
                end
            end

            if garbageCollectedObject.Recoil and typeof(garbageCollectedObject.Recoil) == "Vector3" then
                garbageCollectedObject.Recoil = Vector3.zero
            end
            if garbageCollectedObject.Spread and typeof(garbageCollectedObject.Spread) == "Vector3" then
                garbageCollectedObject.Spread = Vector3.zero
            end
            if garbageCollectedObject.CurrentRecoil and typeof(garbageCollectedObject.CurrentRecoil) == "Vector3" then
                garbageCollectedObject.CurrentRecoil = Vector3.zero
            end
            if garbageCollectedObject.CurrentSpread and typeof(garbageCollectedObject.CurrentSpread) == "number" then
                garbageCollectedObject.CurrentSpread = 0
            end
        end
    end

    -- Периодическая проверка раз в 5 секунд (не каждый кадр)
    while true do
        task.wait(5)
        for _, garbageCollectedObject in pairs(getgc()) do
            if typeof(garbageCollectedObject) == "table" then
                if garbageCollectedObject.CurrentRecoil and typeof(garbageCollectedObject.CurrentRecoil) == "Vector3" then
                    garbageCollectedObject.CurrentRecoil = Vector3.zero
                end
                if garbageCollectedObject.CurrentSpread and typeof(garbageCollectedObject.CurrentSpread) == "number" then
                    garbageCollectedObject.CurrentSpread = 0
                end
                if garbageCollectedObject.RecoilTimer and typeof(garbageCollectedObject.RecoilTimer) == "number" then
                    garbageCollectedObject.RecoilTimer = 0
                end
            end
        end
    end
end)

-- ============================================
-- ВХ — КЭШ РИСОВАНИЯ (лёгкий)
-- ============================================

local SkeletonBones = {
    {"Head", "UpperTorso"},
    {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"},
    {"UpperTorso", "LeftUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"},
    {"LowerTorso", "HumanoidRootPart"}
}

local PlayerDrawingCache = {}

local function CreatePlayerDrawings(player)
    local drawings = {
        Box = Drawing.new("Square"),
        BoxOutline = Drawing.new("Square"),
        HealthBar = Drawing.new("Square"),
        HealthOutline = Drawing.new("Square"),
        NameText = Drawing.new("Text"),
        DistanceText = Drawing.new("Text"),
        SkeletonLines = {},
        IsVisible = true,
        LastRaycast = 0
    }

    drawings.Box.Thickness = 1
    drawings.Box.Filled = false
    drawings.BoxOutline.Thickness = 2
    drawings.BoxOutline.Filled = false
    drawings.BoxOutline.Color = Color3.new(0, 0, 0)
    drawings.HealthBar.Filled = true
    drawings.HealthOutline.Filled = true
    drawings.HealthOutline.Color = Color3.new(0, 0, 0)
    drawings.NameText.Size = WallhackConfig.TextSize
    drawings.NameText.Center = true
    drawings.NameText.Outline = true
    drawings.DistanceText.Size = WallhackConfig.TextSize
    drawings.DistanceText.Center = true
    drawings.DistanceText.Outline = true

    for boneIndex = 1, #SkeletonBones do
        local line = Drawing.new("Line")
        line.Thickness = 1
        table.insert(drawings.SkeletonLines, line)
    end

    return drawings
end

local function GetPlayerDrawings(player)
    if not PlayerDrawingCache[player] then
        PlayerDrawingCache[player] = CreatePlayerDrawings(player)
    end
    return PlayerDrawingCache[player]
end

local function HidePlayerDrawings(player)
    local drawings = PlayerDrawingCache[player]
    if not drawings then
        return
    end
    drawings.Box.Visible = false
    drawings.BoxOutline.Visible = false
    drawings.HealthBar.Visible = false
    drawings.HealthOutline.Visible = false
    drawings.NameText.Visible = false
    drawings.DistanceText.Visible = false
    for _, line in ipairs(drawings.SkeletonLines) do
        line.Visible = false
    end
end

local function RemovePlayerDrawings(player)
    local drawings = PlayerDrawingCache[player]
    if not drawings then
        return
    end
    drawings.Box:Remove()
    drawings.BoxOutline:Remove()
    drawings.HealthBar:Remove()
    drawings.HealthOutline:Remove()
    drawings.NameText:Remove()
    drawings.DistanceText:Remove()
    for _, line in ipairs(drawings.SkeletonLines) do
        line:Remove()
    end
    PlayerDrawingCache[player] = nil
end

-- ============================================
-- ВХ — ГЛАВНЫЙ ЦИКЛ (с троттлингом, не каждый кадр)
-- ============================================

local LastWallhackUpdate = 0

RunService.Heartbeat:Connect(function()
    local currentTime = tick()
    if currentTime - LastWallhackUpdate < WallhackConfig.UpdateInterval then
        return
    end
    LastWallhackUpdate = currentTime

    if not WallhackConfig.Enabled then
        for player, _ in pairs(PlayerDrawingCache) do
            HidePlayerDrawings(player)
        end
        return
    end

    local cameraPosition = Camera.CFrame.Position
    local shouldPerformRaycast = math.floor(currentTime * 10) % 3 == 0

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then
            continue
        end
        if AimConfig.TeamCheck and player.Team == LocalPlayer.Team then
            HidePlayerDrawings(player)
            continue
        end

        local character = player.Character
        if not IsCharacterAlive(character) then
            HidePlayerDrawings(player)
            continue
        end

        local parts = GetCachedCharacterParts(character)
        if not parts or not parts.HumanoidRootPart or not parts.Head or not parts.Humanoid then
            HidePlayerDrawings(player)
            continue
        end

        local distance3D = (parts.HumanoidRootPart.Position - cameraPosition).Magnitude
        if distance3D > WallhackConfig.MaxDistance then
            HidePlayerDrawings(player)
            continue
        end

        local minimumX, minimumY = math.huge, math.huge
        local maximumX, maximumY = -math.huge, -math.huge
        local anyPartOnScreen = false

        local function AddBoundingBoxPoint(bodyPart)
            if not bodyPart then
                return
            end
            local screenPosition, depth = WorldToScreen(bodyPart.Position)
            if depth > 0 then
                anyPartOnScreen = true
                minimumX = math.min(minimumX, screenPosition.X)
                minimumY = math.min(minimumY, screenPosition.Y)
                maximumX = math.max(maximumX, screenPosition.X)
                maximumY = math.max(maximumY, screenPosition.Y)
            end
        end

        AddBoundingBoxPoint(parts.Head)
        AddBoundingBoxPoint(parts.HumanoidRootPart)
        AddBoundingBoxPoint(parts.RightUpperArm)
        AddBoundingBoxPoint(parts.LeftUpperArm)
        AddBoundingBoxPoint(parts.RightUpperLeg)
        AddBoundingBoxPoint(parts.LeftUpperLeg)

        if not anyPartOnScreen then
            HidePlayerDrawings(player)
            continue
        end

        local boxWidth = maximumX - minimumX
        local boxHeight = maximumY - minimumY
        if boxWidth < 5 or boxHeight < 5 then
            HidePlayerDrawings(player)
            continue
        end

        local drawings = GetPlayerDrawings(player)

        if shouldPerformRaycast then
            SharedRaycastParams.FilterDescendantsInstances = {LocalPlayer.Character, character}
            local raycastResult = Workspace:Raycast(cameraPosition, (parts.Head.Position - cameraPosition).Unit * 1000, SharedRaycastParams)
            drawings.IsVisible = raycastResult == nil
        end

        local boxColor = drawings.IsVisible and WallhackConfig.BoxVisibleColor or WallhackConfig.BoxColor
        local skeletonColor = drawings.IsVisible and WallhackConfig.SkeletonVisibleColor or WallhackConfig.SkeletonColor

        if WallhackConfig.Boxes then
            drawings.BoxOutline.Visible = true
            drawings.BoxOutline.Position = Vector2.new(minimumX, minimumY)
            drawings.BoxOutline.Size = Vector2.new(boxWidth, boxHeight)

            drawings.Box.Visible = true
            drawings.Box.Position = Vector2.new(minimumX, minimumY)
            drawings.Box.Size = Vector2.new(boxWidth, boxHeight)
            drawings.Box.Color = boxColor
        else
            drawings.Box.Visible = false
            drawings.BoxOutline.Visible = false
        end

        if WallhackConfig.HealthBar then
            local healthPercent = parts.Humanoid.Health / parts.Humanoid.MaxHealth
            local barHeight = boxHeight * healthPercent
            local barX = minimumX - 5
            local barY = minimumY + boxHeight - barHeight

            drawings.HealthOutline.Visible = true
            drawings.HealthOutline.Position = Vector2.new(barX - 1, minimumY - 1)
            drawings.HealthOutline.Size = Vector2.new(4, boxHeight + 2)

            drawings.HealthBar.Visible = true
            drawings.HealthBar.Position = Vector2.new(barX, barY)
            drawings.HealthBar.Size = Vector2.new(2, barHeight)
            drawings.HealthBar.Color = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)
        else
            drawings.HealthBar.Visible = false
            drawings.HealthOutline.Visible = false
        end

        if WallhackConfig.Name then
            drawings.NameText.Visible = true
            drawings.NameText.Position = Vector2.new(minimumX + boxWidth / 2, minimumY - 14)
            drawings.NameText.Text = player.Name
            drawings.NameText.Color = boxColor
        else
            drawings.NameText.Visible = false
        end

        if WallhackConfig.Distance then
            drawings.DistanceText.Visible = true
            drawings.DistanceText.Position = Vector2.new(minimumX + boxWidth / 2, maximumY + 2)
            drawings.DistanceText.Text = math.floor(distance3D) .. "м"
            drawings.DistanceText.Color = Color3.fromRGB(200, 200, 200)
        else
            drawings.DistanceText.Visible = false
        end

        if WallhackConfig.Skeleton then
            for boneIndex, boneConnection in ipairs(SkeletonBones) do
                local firstPartName = boneConnection[1]
                local secondPartName = boneConnection[2]
                local firstPart = character:FindFirstChild(firstPartName)
                local secondPart = character:FindFirstChild(secondPartName)
                local line = drawings.SkeletonLines[boneIndex]

                if firstPart and secondPart and line then
                    local firstScreen, firstDepth = WorldToScreen(firstPart.Position)
                    local secondScreen, secondDepth = WorldToScreen(secondPart.Position)

                    if firstDepth > 0 and secondDepth > 0 then
                        line.Visible = true
                        line.From = firstScreen
                        line.To = secondScreen
                        line.Color = skeletonColor
                    else
                        line.Visible = false
                    end
                elseif line then
                    line.Visible = false
                end
            end
        else
            for _, line in ipairs(drawings.SkeletonLines) do
                line.Visible = false
            end
        end
    end
end)

-- ============================================
-- ОЧИСТКА ПРИ ВЫХОДЕ ИГРОКА
-- ============================================

Players.PlayerRemoving:Connect(function(player)
    RemovePlayerDrawings(player)
    if player.Character then
        ClearCharacterPartCache(player.Character)
    end
end)

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        CharacterPartCache[character] = CacheCharacterParts(character)
    end)
    if player.Character then
        CharacterPartCache[player.Character] = CacheCharacterParts(player.Character)
    end
end)

-- Кэширование существующих персонажей
for _, player in ipairs(Players:GetPlayers()) do
    if player.Character then
        CharacterPartCache[player.Character] = CacheCharacterParts(player.Character)
    end
    player.CharacterAdded:Connect(function(character)
        CharacterPartCache[character] = CacheCharacterParts(character)
    end)
end

-- ============================================
-- КРУГ ПОЛЯ ЗРЕНИЯ
-- ============================================

local FieldOfViewCircle = Drawing.new("Circle")
FieldOfViewCircle.Visible = true
FieldOfViewCircle.Thickness = 1
FieldOfViewCircle.Color = Color3.fromRGB(255, 255, 255)
FieldOfViewCircle.Transparency = 0.4
FieldOfViewCircle.NumSides = 32
FieldOfViewCircle.Filled = false

RunService.RenderStepped:Connect(function()
    local viewportSize = Camera.ViewportSize
    FieldOfViewCircle.Position = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
    FieldOfViewCircle.Radius = AimConfig.FieldOfView
    if IsHoldingFire and CurrentTarget then
        FieldOfViewCircle.Color = Color3.fromRGB(0, 255, 100)
    else
        FieldOfViewCircle.Color = Color3.fromRGB(255, 255, 255)
    end
end)

-- ============================================
-- МЕНЮ НАСТРОЕК (НА РУССКОМ)
-- ============================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 230, 0, 400)
MainFrame.Position = UDim2.new(1, -240, 0, 10)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 0, 32)
TitleLabel.Text = "4080 | БЛОК СТРАЙК"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 14
TitleLabel.Parent = MainFrame

local function CreateToggleButton(buttonText, positionY, configTable, configKey)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.9, 0, 0, 28)
    button.Position = UDim2.new(0.05, 0, 0, positionY)
    button.Text = buttonText .. ": " .. (configTable[configKey] and "ВКЛ" or "ВЫКЛ")
    button.TextColor3 = Color3.fromRGB(220, 220, 220)
    button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    button.Font = Enum.Font.Gotham
    button.TextSize = 12
    button.Parent = MainFrame
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 4)
    button.MouseButton1Click:Connect(function()
        configTable[configKey] = not configTable[configKey]
        button.Text = buttonText .. ": " .. (configTable[configKey] and "ВКЛ" or "ВЫКЛ")
    end)
    return button
end

CreateToggleButton("Аим", 40, AimConfig, "Enabled")
CreateToggleButton("Проверка Команды", 74, AimConfig, "TeamCheck")
CreateToggleButton("ВХ", 108, WallhackConfig, "Enabled")
CreateToggleButton("Боксы", 142, WallhackConfig, "Boxes")
CreateToggleButton("Скелет", 176, WallhackConfig, "Skeleton")
CreateToggleButton("Полоска Здоровья", 210, WallhackConfig, "HealthBar")
CreateToggleButton("Имя", 244, WallhackConfig, "Name")
CreateToggleButton("Дистанция", 278, WallhackConfig, "Distance")

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0.9, 0, 0, 28)
CloseButton.Position = UDim2.new(0.05, 0, 0, 316)
CloseButton.Text = "Закрыть Меню"
CloseButton.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
CloseButton.Font = Enum.Font.Gotham
CloseButton.TextSize = 12
CloseButton.Parent = MainFrame
Instance.new("UICorner", CloseButton).CornerRadius = UDim.new(0, 4)
CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

print("4080 Блок Страйк iPad | Оптимизирован | getgc() убран из Heartbeat | FPS должен быть стабильным")
