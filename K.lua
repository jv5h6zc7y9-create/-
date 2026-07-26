-- Block Strike iPad | Delta iOS
-- Триггер аим: при нажатии на стрельбу запоминает координаты прицела,
-- резко целится в голову противника, стреляет, убирает отдачу и разброс,
-- после убийства возвращает прицел на исходную позицию.
-- ВХ: боксы за стенами, скелет, здоровье, имя, дистанция.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

-- ============================================
-- НАСТРОЙКИ
-- ============================================

local Config = {
    TriggerAimEnabled = true,
    TriggerAimFieldOfView = 140,
    TriggerAimTeamCheck = true,
    TriggerAimHitPart = "Head",
    TriggerAimPrediction = 0.08,
    TriggerAimRestoreDelay = 0.35,
    TriggerAimRestoreSpeed = 0.15,
    TriggerAimMaxDistance = 400,
    TriggerAimWallCheck = false,

    WallhackEnabled = true,
    WallhackBoxes = true,
    WallhackSkeleton = true,
    WallhackHealthBar = true,
    WallhackName = true,
    WallhackDistance = true,
    WallhackMaxDistance = 500,
    WallhackBoxColor = Color3.fromRGB(255, 50, 50),
    WallhackBoxVisibleColor = Color3.fromRGB(50, 255, 50),
    WallhackSkeletonColor = Color3.fromRGB(180, 180, 180),
    WallhackSkeletonVisibleColor = Color3.fromRGB(255, 255, 255),
    WallhackTextSize = 12,
    WallhackUpdateRate = 2,
    WallhackRaycastRate = 6
}

-- ============================================
-- СОСТОЯНИЕ ТРИГГЕР АИМА
-- ============================================

local OriginalCameraCFrame = nil
local IsCurrentlyAiming = false
local LastTargetHead = nil
local LastFireTime = 0

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
    if not Config.TriggerAimTeamCheck then
        return false
    end
    if player.Team == LocalPlayer.Team then
        return true
    end
    return false
end

-- ============================================
-- ПОИСК ЦЕЛИ ДЛЯ ТРИГГЕР АИМА
-- ============================================

local function GetNearestTargetHead()
    local centerOfScreen = GetCenterOfScreen()
    local cameraPosition = Camera.CFrame.Position
    local bestTarget = nil
    local bestDistance = Config.TriggerAimFieldOfView

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

        local head = character:FindFirstChild(Config.TriggerAimHitPart)
        if not head then
            continue
        end

        local screenPosition, depth = WorldToScreen(head.Position)
        if depth <= 0 then
            continue
        end

        local distanceFromCenter = (screenPosition - centerOfScreen).Magnitude
        if distanceFromCenter >= bestDistance then
            continue
        end

        if Config.TriggerAimWallCheck then
            local raycastParams = RaycastParams.new()
            raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, character}
            raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
            local raycastResult = Workspace:Raycast(cameraPosition, (head.Position - cameraPosition).Unit * 1000, raycastParams)
            if raycastResult then
                continue
            end
        end

        local distance3D = (head.Position - cameraPosition).Magnitude
        if distance3D > Config.TriggerAimMaxDistance then
            continue
        end

        bestDistance = distanceFromCenter
        bestTarget = head
    end

    return bestTarget
end

-- ============================================
-- ВОЗВРАТ ПРИЦЕЛА
-- ============================================

local function RestoreCameraToOriginal()
    if not OriginalCameraCFrame then
        return
    end
    IsCurrentlyAiming = false

    local tweenInfo = TweenInfo.new(Config.TriggerAimRestoreSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(Camera, tweenInfo, {
        CFrame = OriginalCameraCFrame
    })
    tween:Play()

    OriginalCameraCFrame = nil
    LastTargetHead = nil
end

local function ForceRestoreCamera()
    if not IsCurrentlyAiming then
        return
    end
    RestoreCameraToOriginal()
end

-- ============================================
-- ОТСЛЕЖИВАНИЕ УБИЙСТВА
-- ============================================

local function WatchTargetForDeath(targetHead)
    if not targetHead or not targetHead.Parent then
        task.delay(Config.TriggerAimRestoreDelay, ForceRestoreCamera)
        return
    end

    local humanoid = targetHead.Parent:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        task.delay(Config.TriggerAimRestoreDelay, ForceRestoreCamera)
        return
    end

    local healthConnection = nil
    healthConnection = humanoid.HealthChanged:Connect(function(health)
        if health <= 0 then
            if healthConnection then
                healthConnection:Disconnect()
            end
            RestoreCameraToOriginal()
        end
    end)

    task.delay(Config.TriggerAimRestoreDelay + 0.2, function()
        if healthConnection and healthConnection.Connected then
            healthConnection:Disconnect()
            ForceRestoreCamera()
        end
    end)
end

-- ============================================
-- ОБРАБОТКА ВЫСТРЕЛА
-- ============================================

local function OnPlayerFire()
    if not Config.TriggerAimEnabled then
        return
    end
    if IsCurrentlyAiming then
        return
    end

    local targetHead = GetNearestTargetHead()
    if not targetHead then
        return
    end

    IsCurrentlyAiming = true
    OriginalCameraCFrame = Camera.CFrame
    LastTargetHead = targetHead
    LastFireTime = tick()

    local humanoidRootPart = targetHead.Parent:FindFirstChild("HumanoidRootPart")
    local velocity = Vector3.zero
    if humanoidRootPart then
        velocity = humanoidRootPart.Velocity
    end
    local aimPosition = targetHead.Position + (velocity * Config.TriggerAimPrediction)

    Camera.CFrame = CFrame.new(Camera.CFrame.Position, aimPosition)

    WatchTargetForDeath(targetHead)
end

-- ============================================
-- ХУК ВВОДА (тач + мышь)
-- ============================================

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then
        return
    end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        OnPlayerFire()
    end
end)

-- ============================================
-- ХУК УДАЛЁННЫХ ВЫЗОВОВ (перехват пуль)
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

            if IsCurrentlyAiming and LastTargetHead and LastTargetHead.Parent then
                local humanoidRootPart = LastTargetHead.Parent:FindFirstChild("HumanoidRootPart")
                local velocity = Vector3.zero
                if humanoidRootPart then
                    velocity = humanoidRootPart.Velocity
                end
                local aimPosition = LastTargetHead.Position + (velocity * Config.TriggerAimPrediction)

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
-- УБИРАНИЕ ОТДАЧИ И РАЗБРОСА
-- ============================================

task.spawn(function()
    task.wait(2)

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
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if not Config.TriggerAimEnabled then
        return
    end

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
end)

-- ============================================
-- ВХ (WALLHACK) — БОКСЫ, СКЕЛЕТ, ЗДОРОВЬЕ
-- ============================================

local DrawingPool = {}
local function GetDrawingFromPool(drawingType)
    for index, drawingObject in ipairs(DrawingPool) do
        if not drawingObject.InUse and drawingObject.DrawingType == drawingType then
            drawingObject.InUse = true
            drawingObject.Visible = false
            return drawingObject
        end
    end
    local newDrawing = Drawing.new(drawingType)
    newDrawing.DrawingType = drawingType
    newDrawing.InUse = true
    table.insert(DrawingPool, newDrawing)
    return newDrawing
end

local function ReleaseDrawingToPool(drawingObject)
    if drawingObject then
        drawingObject.Visible = false
        drawingObject.InUse = false
    end
end

local SkeletonBones = {
    {"Head", "UpperTorso"},
    {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"},
    {"UpperTorso", "LeftUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"},
    {"LowerTorso", "HumanoidRootPart"}
}

local PlayerWallhackCache = {}

local function GetPlayerWallhackCache(player)
    if not PlayerWallhackCache[player] then
        PlayerWallhackCache[player] = {
            Box = GetDrawingFromPool("Square"),
            BoxOutline = GetDrawingFromPool("Square"),
            HealthBar = GetDrawingFromPool("Square"),
            HealthOutline = GetDrawingFromPool("Square"),
            NameText = GetDrawingFromPool("Text"),
            DistanceText = GetDrawingFromPool("Text"),
            SkeletonLines = {},
            LastRaycast = 0,
            IsTargetVisible = true,
            CachedCharacter = nil,
            CachedHumanoid = nil,
            CachedHumanoidRootPart = nil,
            CachedHead = nil
        }
        for boneIndex = 1, #SkeletonBones do
            table.insert(PlayerWallhackCache[player].SkeletonLines, GetDrawingFromPool("Line"))
        end
    end
    return PlayerWallhackCache[player]
end

local function ClearPlayerWallhackCache(player)
    local cache = PlayerWallhackCache[player]
    if not cache then
        return
    end
    ReleaseDrawingToPool(cache.Box)
    ReleaseDrawingToPool(cache.BoxOutline)
    ReleaseDrawingToPool(cache.HealthBar)
    ReleaseDrawingToPool(cache.HealthOutline)
    ReleaseDrawingToPool(cache.NameText)
    ReleaseDrawingToPool(cache.DistanceText)
    for _, line in ipairs(cache.SkeletonLines) do
        ReleaseDrawingToPool(line)
    end
    PlayerWallhackCache[player] = nil
end

local FrameCounter = 0

RunService.RenderStepped:Connect(function()
    FrameCounter = FrameCounter + 1

    if not Config.WallhackEnabled then
        return
    end
    if FrameCounter % Config.WallhackUpdateRate ~= 0 then
        return
    end

    local cameraPosition = Camera.CFrame.Position
    local shouldPerformRaycast = FrameCounter % Config.WallhackRaycastRate == 0

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then
            continue
        end
        if Config.TriggerAimTeamCheck and player.Team == LocalPlayer.Team then
            continue
        end

        local character = player.Character
        if not IsCharacterAlive(character) then
            ClearPlayerWallhackCache(player)
            continue
        end

        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        local head = character:FindFirstChild("Head")
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoidRootPart or not head or not humanoid then
            ClearPlayerWallhackCache(player)
            continue
        end

        local distance3D = (humanoidRootPart.Position - cameraPosition).Magnitude
        if distance3D > Config.WallhackMaxDistance then
            ClearPlayerWallhackCache(player)
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

        AddBoundingBoxPoint(head)
        AddBoundingBoxPoint(humanoidRootPart)
        AddBoundingBoxPoint(character:FindFirstChild("RightUpperArm"))
        AddBoundingBoxPoint(character:FindFirstChild("LeftUpperArm"))
        AddBoundingBoxPoint(character:FindFirstChild("RightUpperLeg"))
        AddBoundingBoxPoint(character:FindFirstChild("LeftUpperLeg"))

        if not anyPartOnScreen then
            ClearPlayerWallhackCache(player)
            continue
        end

        local boxWidth = maximumX - minimumX
        local boxHeight = maximumY - minimumY
        if boxWidth < 5 or boxHeight < 5 then
            ClearPlayerWallhackCache(player)
            continue
        end

        local cache = GetPlayerWallhackCache(player)

        if shouldPerformRaycast then
            local raycastParams = RaycastParams.new()
            raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, character}
            raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
            local raycastResult = Workspace:Raycast(cameraPosition, (head.Position - cameraPosition).Unit * 1000, raycastParams)
            cache.IsTargetVisible = raycastResult == nil
        end

        local boxColor = cache.IsTargetVisible and Config.WallhackBoxVisibleColor or Config.WallhackBoxColor
        local skeletonColor = cache.IsTargetVisible and Config.WallhackSkeletonVisibleColor or Config.WallhackSkeletonColor

        if Config.WallhackBoxes then
            cache.BoxOutline.Visible = true
            cache.BoxOutline.Position = Vector2.new(minimumX, minimumY)
            cache.BoxOutline.Size = Vector2.new(boxWidth, boxHeight)
            cache.BoxOutline.Color = Color3.new(0, 0, 0)
            cache.BoxOutline.Thickness = 2
            cache.BoxOutline.Filled = false

            cache.Box.Visible = true
            cache.Box.Position = Vector2.new(minimumX, minimumY)
            cache.Box.Size = Vector2.new(boxWidth, boxHeight)
            cache.Box.Color = boxColor
            cache.Box.Thickness = 1
            cache.Box.Filled = false
        else
            cache.Box.Visible = false
            cache.BoxOutline.Visible = false
        end

        if Config.WallhackHealthBar then
            local healthPercent = humanoid.Health / humanoid.MaxHealth
            local barHeight = boxHeight * healthPercent
            local barX = minimumX - 5
            local barY = minimumY + boxHeight - barHeight

            cache.HealthOutline.Visible = true
            cache.HealthOutline.Position = Vector2.new(barX - 1, minimumY - 1)
            cache.HealthOutline.Size = Vector2.new(4, boxHeight + 2)
            cache.HealthOutline.Color = Color3.new(0, 0, 0)
            cache.HealthOutline.Filled = true

            cache.HealthBar.Visible = true
            cache.HealthBar.Position = Vector2.new(barX, barY)
            cache.HealthBar.Size = Vector2.new(2, barHeight)
            cache.HealthBar.Color = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)
            cache.HealthBar.Filled = true
        else
            cache.HealthBar.Visible = false
            cache.HealthOutline.Visible = false
        end

        if Config.WallhackName then
            cache.NameText.Visible = true
            cache.NameText.Position = Vector2.new(minimumX + boxWidth / 2, minimumY - 14)
            cache.NameText.Text = player.Name
            cache.NameText.Size = Config.WallhackTextSize
            cache.NameText.Center = true
            cache.NameText.Outline = true
            cache.NameText.Color = boxColor
        else
            cache.NameText.Visible = false
        end

        if Config.WallhackDistance then
            cache.DistanceText.Visible = true
            cache.DistanceText.Position = Vector2.new(minimumX + boxWidth / 2, maximumY + 2)
            cache.DistanceText.Text = math.floor(distance3D) .. "m"
            cache.DistanceText.Size = Config.WallhackTextSize
            cache.DistanceText.Center = true
            cache.DistanceText.Outline = true
            cache.DistanceText.Color = Color3.fromRGB(200, 200, 200)
        else
            cache.DistanceText.Visible = false
        end

        if Config.WallhackSkeleton then
            for boneIndex, boneConnection in ipairs(SkeletonBones) do
                local firstPart = character:FindFirstChild(boneConnection[1])
                local secondPart = character:FindFirstChild(boneConnection[2])
                local line = cache.SkeletonLines[boneIndex]

                if firstPart and secondPart and line then
                    local firstScreen, firstDepth = WorldToScreen(firstPart.Position)
                    local secondScreen, secondDepth = WorldToScreen(secondPart.Position)

                    if firstDepth > 0 and secondDepth > 0 then
                        line.Visible = true
                        line.From = firstScreen
                        line.To = secondScreen
                        line.Color = skeletonColor
                        line.Thickness = 1
                    else
                        line.Visible = false
                    end
                elseif line then
                    line.Visible = false
                end
            end
        else
            for _, line in ipairs(cache.SkeletonLines) do
                line.Visible = false
            end
        end
    end
end)

Players.PlayerRemoving:Connect(function(player)
    ClearPlayerWallhackCache(player)
end)

-- ============================================
-- КРУГ ПОЛЯ ЗРЕНИЯ (FOV)
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
    FieldOfViewCircle.Radius = Config.TriggerAimFieldOfView
    if IsCurrentlyAiming then
        FieldOfViewCircle.Color = Color3.fromRGB(0, 255, 100)
    else
        FieldOfViewCircle.Color = Color3.fromRGB(255, 255, 255)
    end
end)

-- ============================================
-- МЕНЮ НАСТРОЕК
-- ============================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

local SettingsFrame = Instance.new("Frame")
SettingsFrame.Size = UDim2.new(0, 200, 0, 320)
SettingsFrame.Position = UDim2.new(1, -210, 0, 10)
SettingsFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
SettingsFrame.BorderSizePixel = 0
SettingsFrame.Parent = ScreenGui
Instance.new("UICorner", SettingsFrame).CornerRadius = UDim.new(0, 6)

local SettingsTitle = Instance.new("TextLabel")
SettingsTitle.Size = UDim2.new(1, 0, 0, 26)
SettingsTitle.Text = "4080 | Block Strike"
SettingsTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
SettingsTitle.BackgroundTransparency = 1
SettingsTitle.Font = Enum.Font.GothamBold
SettingsTitle.TextSize = 12
SettingsTitle.Parent = SettingsFrame

local function CreateToggleButton(buttonText, positionY, configKey)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.9, 0, 0, 26)
    button.Position = UDim2.new(0.05, 0, 0, positionY)
    button.Text = buttonText .. ": " .. (Config[configKey] and "ON" or "OFF")
    button.TextColor3 = Color3.fromRGB(200, 200, 200)
    button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    button.Font = Enum.Font.Gotham
    button.TextSize = 11
    button.Parent = SettingsFrame
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 4)
    button.MouseButton1Click:Connect(function()
        Config[configKey] = not Config[configKey]
        button.Text = buttonText .. ": " .. (Config[configKey] and "ON" or "OFF")
    end)
    return button
end

CreateToggleButton("Trigger Aim", 32, "TriggerAimEnabled")
CreateToggleButton("Wallhack", 64, "WallhackEnabled")
CreateToggleButton("Boxes", 96, "WallhackBoxes")
CreateToggleButton("Skeleton", 128, "WallhackSkeleton")
CreateToggleButton("Health Bar", 160, "WallhackHealthBar")
CreateToggleButton("Team Check", 192, "TriggerAimTeamCheck")
CreateToggleButton("Wall Check", 224, "TriggerAimWallCheck")

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0.9, 0, 0, 26)
CloseButton.Position = UDim2.new(0.05, 0, 0, 256)
CloseButton.Text = "Close Menu"
CloseButton.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
CloseButton.Font = Enum.Font.Gotham
CloseButton.TextSize = 11
CloseButton.Parent = SettingsFrame
Instance.new("UICorner", CloseButton).CornerRadius = UDim.new(0, 4)
CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

print("4080 Block Strike iPad loaded | Trigger Aim + Wallhack + No Recoil | Full Build")
