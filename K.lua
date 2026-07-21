-- ====================================================================
-- IPAD FLING THINGS AND PEOPLE ULTIMATE EXPLOIT V9 (OVER 500 LINES)
-- OPTIMIZED FOR DELTA EXECUTOR (iOS / iPAD)
-- ====================================================================

-- СЕРВИСЫ ROBLOX
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ТАБЛИЦА НАСТРОЕК И СОСТОЯНИЙ (ГЛОБАЛЬНЫЙ КОНФИГ)
local Settings = {
    SilentAim = false,
    ShowFov = false,
    BlackHole = false,
    AntiGrab = false,
    
    SilentAimFov = 220,
    ThrowForce = 5000000,
    HoleSpeed = 160,
    HoleRadius = 320,
    PredictionIntensity = 0.145,
    FloorGlitchDepth = -3.5
}

-- УДАЛЕНИЕ СТАРЫХ ИНСТАНСОВ СКРИПТА ДЛЯ ИЗБЕЖАНИЯ ДУБЛИРОВАНИЯ И ЛАГОВ
if CoreGui:FindFirstChild("iPadDeltaMenuUltimateV9") then
    CoreGui:FindFirstChild("iPadDeltaMenuUltimateV9"):Destroy()
end

-- ====================================================================
-- МОДУЛЬ СЛУЖЕБНЫХ ФУНКЦИЙ ГРАФИКИ И СТИЛИЗАЦИИ GUI
-- ====================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "iPadDeltaMenuUltimateV9"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
MainFrame.Position = UDim2.new(0.08, 0, 0.22, 0)
MainFrame.Size = UDim2.new(0, 280, 0, 440)
MainFrame.Active = true
MainFrame.Draggable = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 2
MainStroke.Color = Color3.fromRGB(45, 45, 55)
MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
MainStroke.Parent = MainFrame

local MainGradient = Instance.new("UIGradient")
MainGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(22, 22, 28)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(14, 14, 18))
})
MainGradient.Rotation = 45
MainGradient.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
Title.Text = "FT&P SUPREMACY V9"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.SourceSansBold

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = Title

local TitleBottomLine = Instance.new("Frame")
TitleBottomLine.Size = UDim2.new(1, 0, 0, 2)
TitleBottomLine.Position = UDim2.new(0, 0, 1, -2)
TitleBottomLine.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
TitleBottomLine.BorderSizePixel = 0
TitleBottomLine.Parent = Title

-- ФУНКЦИЯ СОЗДАНИЯ СТИЛИЗОВАННЫХ КНОПОК С СЕНСОРНЫМ ОТКЛИКОМ
local function CreateMenuButton(name, text, posY)
    local Button = Instance.new("TextButton")
    Button.Name = name
    Button.Parent = MainFrame
    Button.Size = UDim2.new(0.9, 0, 0, 45)
    Button.Position = UDim2.new(0.05, 0, 0, posY)
    Button.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    Button.Text = text .. " [ВЫКЛ]"
    Button.TextColor3 = Color3.fromRGB(200, 200, 200)
    Button.TextSize = 14
    Button.Font = Enum.Font.SourceSansBold
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 8)
    BtnCorner.Parent = Button
    
    local BtnStroke = Instance.new("UIStroke")
    BtnStroke.Thickness = 1
    BtnStroke.Color = Color3.fromRGB(50, 50, 65)
    BtnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    BtnStroke.Parent = Button
    
    Button.MouseButton1Down:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(40, 40, 50)}):Play()
    end)
    
    return Button
end

local AimBtn = CreateMenuButton("AimBtn", "1. УПРЕЖДАЮЩИЙ АИМ", 65)
local FovBtn = CreateMenuButton("FovBtn", "2. ГРАНИЦЫ FOV (КРУГ)", 125)
local HoleBtn = CreateMenuButton("HoleBtn", "3. ФИЗИЧЕСКАЯ ДЫРА", 185)
local AntiGrabBtn = CreateMenuButton("AntiGrabBtn", "4. АНТИ-ХВАТ (БАГ ПОЛА)", 245)

-- ЭЛЕМЕНТЫ УПРАВЛЕНИЯ РАДИУСОМ FOV
local FovContainer = Instance.new("Frame")
FovContainer.Size = UDim2.new(0.9, 0, 0, 45)
FovContainer.Position = UDim2.new(0.05, 0, 0, 305)
FovContainer.BackgroundTransparency = 1
FovContainer.Parent = MainFrame

local FovLabel = Instance.new("TextLabel")
FovLabel.Size = UDim2.new(0.4, 0, 1, 0)
FovLabel.Position = UDim2.new(0.3, 0, 0, 0)
FovLabel.BackgroundTransparency = 1
FovLabel.Text = "FOV: " .. tostring(Settings.SilentAimFov)
FovLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
FovLabel.TextSize = 14
FovLabel.Font = Enum.Font.SourceSansBold
FovLabel.Parent = FovContainer

local function CreateFovAdjuster(text, posX, offset)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0.25, 0, 1, 0)
    Btn.Position = UDim2.new(posX, 0, 0, 0)
    Btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.TextSize = 16
    Btn.Font = Enum.Font.SourceSansBold
    Btn.Parent = FovContainer
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Btn
    
    Btn.MouseButton1Click:Connect(function()
        Settings.SilentAimFov = math.clamp(Settings.SilentAimFov + offset, 50, 600)
        FovLabel.Text = "FOV: " .. tostring(Settings.SilentAimFov)
    end)
end

CreateFovAdjuster("-", 0, -25)
CreateFovAdjuster("+", 0.75, 25)

-- ИНДИКАТОР ТЕКУЩЕГО СТАТУСА НАД ПАНЕЛЬЮ
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0.9, 0, 0, 25)
StatusLabel.Position = UDim2.new(0.05, 0, 0, 365)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Скрипт готов к тесту на iPad"
StatusLabel.TextColor3 = Color3.fromRGB(120, 130, 150)
StatusLabel.TextSize = 13
StatusLabel.Font = Enum.Font.SourceSansItalic
StatusLabel.Parent = MainFrame

-- ====================================================================
-- МОДУЛЬ ОТРИСОВКИ ДИНАМИЧЕСКИХ ГРАНИЦ И ПОДПИСЕЙ (FOV)
-- ====================================================================
local FovCircle = Drawing.new("Circle")
FovCircle.Visible = false
FovCircle.Thickness = 2
FovCircle.Color = Color3.fromRGB(0, 160, 255)
FovCircle.Radius = Settings.SilentAimFov
FovCircle.Filled = false
FovCircle.NumSides = 64

local TargetDot = Drawing.new("Circle")
TargetDot.Visible = false
TargetDot.Thickness = 1
TargetDot.Color = Color3.fromRGB(255, 0, 50)
TargetDot.Radius = 6
TargetDot.Filled = true
TargetDot.NumSides = 16

-- ====================================================================
-- МАТЕМАТИЧЕСКИЙ МОДУЛЬ СЛЕДОВАНИЯ И ПРЕДСКАЗАНИЯ ДЛЯ АИМА
-- ====================================================================
local function GetClosestTargetWithPrediction()
    local closestPlayer = nil
    local shortestDistance = Settings.SilentAimFov
    local centerScreen = Camera.ViewportSize / 2

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            local human = player.Character:FindFirstChild("Humanoid")
            
            if root and human and human.Health > 0 then
                -- Алгоритм упреждения на основе вектора текущей скорости цели
                local predictedPosition = root.Position + (root.AssemblyLinearVelocity * Settings.PredictionIntensity)
                local screenPos, onScreen = Camera:WorldToViewportPoint(predictedPosition)
                
                if onScreen then
                    local distance = (Vector2.new(centerScreen.X, centerScreen.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                    if distance < shortestDistance then
                        closestPlayer = player
                        shortestDistance = distance
                    end
                end
            end
        end
    end
    return closestPlayer
end

-- ====================================================================
-- МОДУЛЬ ХУКОВ МЕТАМЕТОДОВ СЕТИ (ДЛЯ ПОДМЕНЫ ТРАЕКТОРИЙ В DELTA)
-- ====================================================================
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if Settings.SilentAim and not checkcaller() then
        if method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList" or method == "Raycast" then
            local target = GetClosestTargetWithPrediction()
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                local rootPart = target.Character.HumanoidRootPart
                local aimPos = rootPart.Position + (rootPart.AssemblyLinearVelocity * Settings.PredictionIntensity)
                
                if method == "Raycast" then
                    args[2] = (aimPos - args[1]).Unit * 1000
                else
                    args[1] = Ray.new(args[1].Origin, (aimPos - args[1].Origin).Unit * 1000)
                end
            end
        end
    end
    return oldNamecall(self, unpack(args))
end)

local oldIndex
oldIndex = hookmetamethod(game, "__index", function(self, key)
    if Settings.SilentAim and not checkcaller() then
        if key == "Hit" or key == "Target" then
            local target = GetClosestTargetWithPrediction()
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                local rootPart = target.Character.HumanoidRootPart
                if key == "Hit" then
                    -- Подмена CFrame виртуального прицела с учетом вектора упреждения
                    local aimPos = rootPart.Position + (rootPart.AssemblyLinearVelocity * Settings.PredictionIntensity)
                    return CFrame.new(aimPos)
                elseif key == "Target" then
                    return rootPart
                end
            end
        end
    end
    return oldIndex(self, key)
end)

-- ====================================================================
-- ЯДРО СВЕРХСКОРОСТНОЙ ФИЗИКИ (ОБНОВЛЕНИЕ КАЖДЫЙ КАДР ДО РЕНДЕРА)
-- ====================================================================
local CurrentGrabbedItem = nil

RunService.RenderStepped:Connect(function()
    local myChar = LocalPlayer.Character
    local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local centerScreen = Camera.ViewportSize / 2
    
    -- Синхронизация визуальных кругов FOV
    if Settings.ShowFov then
        FovCircle.Position = Vector2.new(centerScreen.X, centerScreen.Y)
        FovCircle.Radius = Settings.SilentAimFov
        FovCircle.Visible = true
    else
        FovCircle.Visible = false
    end
    
    -- Визуальная точка слежения Аима за бегущей целью
    if Settings.SilentAim then
        local activeTarget = GetClosestTargetWithPrediction()
        if activeTarget and activeTarget.Character and activeTarget.Character:FindFirstChild("HumanoidRootPart") then
            local tRoot = activeTarget.Character.HumanoidRootPart
            local predPos = tRoot.Position + (tRoot.AssemblyLinearVelocity * Settings.PredictionIntensity)
            local sPos, onScreen = Camera:WorldToViewportPoint(predPos)
            if onScreen then
                TargetDot.Position = Vector2.new(sPos.X, sPos.Y)
                TargetDot.Visible = true
            else
                TargetDot.Visible = false
            end
        else
            TargetDot.Visible = false
        end
    else
        TargetDot.Visible = false
    end
    
    -- ВЫЧИСЛЕНИЕ И ОБРАБОТКА ТЕКУЩЕГО ХВАТА В РУКАХ И ПРОВАЛ СКВОЗЬ ПОЛ
    if myChar then
        CurrentGrabbedItem = nil
        for _, obj in pairs(myChar:GetDescendants()) do
            if (obj:IsA("Weld") or obj:IsA("Constraint") or obj:IsA("MoverConstraint")) then
                if obj.Part1 and not obj.Part1:IsDescendantOf(myChar) then
                    CurrentGrabbedItem = obj.Part1.Parent
                elseif obj.Part0 and not obj.Part0:IsDescendantOf(myChar) then
                    CurrentGrabbedItem = obj.Part0.Parent
                end
            end
        end
        
        -- Если мы держим игрока или вещь — принудительно гасим коллизию и топим вниз
        if CurrentGrabbedItem then
            for _, p in pairs(CurrentGrabbedItem:GetChildren()) do
                if p:IsA("BasePart") then
                    p.CanCollide = false
                    -- Силовой вектор проталкивания объекта сквозь пол при повороте камеры вниз
                    p.AssemblyLinearVelocity = Vector3.new(p.AssemblyLinearVelocity.X, -65, p.AssemblyLinearVelocity.Z)
                end
            end
        end
        
        -- МОДУЛЬ АБСОЛЮТНОГО АНТИ-ХВАТА С БАГОМ ПОЛОВИННОГО ПРОВАЛА В ПОЛ
        if Settings.AntiGrab and myHrp then
            local beingGrabbed = false
            for _, globalObj in pairs(Workspace:GetDescendants()) do
                if (globalObj:IsA("Weld") or globalObj:IsA("Constraint") or globalObj:IsA("MoverConstraint")) then
                    if globalObj.Part0 and globalObj.Part0:IsDescendantOf(myChar) and not globalObj.Part1:IsDescendantOf(myChar) then
                        beingGrabbed = true
                        globalObj:Destroy()
                    elseif globalObj.Part1 and globalObj.Part1:IsDescendantOf(myChar) and not globalObj.Part0:IsDescendantOf(myChar) then
                        beingGrabbed = true
                        globalObj:Destroy()
                    end
                end
            end
            
            -- Если обнаружен чужой захват — багаем физику персонажа наполовину в пол
            if beingGrabbed then
                StatusLabel.Text = "Анти-Хват: Попытка захвата заблокирована!"
                StatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
                myHrp.CFrame = myHrp.CFrame * CFrame.new(0, Settings.FloorGlitchDepth, 0)
                myHrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                for _, force in pairs(myHrp:GetChildren()) do
                    if force:IsA("BodyPosition") or force:IsA("BodyVelocity") or force:IsA("LinearVelocity") or force:IsA("VectorForce") then
                        force:Destroy()
                    end
                end
            end
        end
    end
end)

-- ====================================================================
-- МОДУЛЬ ПЕРЕХВАТА ОРИГИНАЛЬНОЙ КНОПКИ БРОСКА ДЛЯ СУПЕР-ИМПУЛЬСА В НЕБО
-- ====================================================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    -- Срабатывает при физическом тапе по экрану iPad (Игровая кнопка броска вызывает Touch)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton2 then
        if Settings.SilentAim and CurrentGrabbedItem then
            local tRoot = CurrentGrabbedItem:FindFirstChild("HumanoidRootPart") or CurrentGrabbedItem:FindFirstChildOfClass("BasePart")
            if tRoot then
                -- Полное и жесткое уничтожение удерживающих сил игры перед супер-пинком
                for _, childForce in pairs(tRoot:GetChildren()) do
                    if childForce:IsA("BodyPosition") or childForce:IsA("BodyVelocity") or childForce:IsA("LinearVelocity") or childForce:IsA("MoverConstraint") then
                        childForce:Destroy()
                    end
                end
                
                for _, bodyPart in pairs(CurrentGrabbedItem:GetChildren()) do
                    if bodyPart:IsA("BasePart") then
                        bodyPart.CanCollide = false
                    end
                end
                
                -- Определение направления броска
                local targetPlayer = GetClosestTargetWithPrediction()
                local finalVector = Camera.CFrame.LookVector
                if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    -- Если цель в FOV — кидаем наводкой со сверх-скоростью в неё
                    local targetRoot = targetPlayer.Character.HumanoidRootPart
                    local predictedAimPos = targetRoot.Position + (targetRoot.AssemblyLinearVelocity * Settings.PredictionIntensity)
                    finalVector = (predictedAimPos - tRoot.Position).Unit
                else
                    -- Если FOV пустой — выстреливаем под углом вверх в небо (без коллизии сквозь крыши)
                    finalVector = (Camera.CFrame.LookVector + Vector3.new(0, 2.2, 0)).Unit
                end
                
                -- Генерация колоссального физического импульса
                local velocityConstraint = Instance.new("LinearVelocity")
                local forceAttachment = Instance.new("Attachment")
                forceAttachment.Parent = tRoot
                velocityConstraint.MaxForce = math.huge
                velocityConstraint.VectorVelocity = finalVector * Settings.ThrowForce
                velocityConstraint.Attachment0 = forceAttachment
                velocityConstraint.Parent = tRoot
                
                -- Короткий импульс для сохранения бесконечной скорости полета за карту
                Debris:AddItem(velocityConstraint, 0.18)
                Debris:AddItem(forceAttachment, 0.18)
                StatusLabel.Text = "Супер-бросок: Предмет запущен в космос!"
                StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
                CurrentGrabbedItem = nil
            end
        end
    end
end)

-- ====================================================================
-- ФИЗИЧЕСКИЙ ЦИКЛ ПОСТОЯННОЙ ЧЕРНОЙ ДЫРЫ И АВТО-КИЛЛА ПОД ТЕКСТУРЫ
-- ====================================================================
RunService.Heartbeat:Connect(function()
    local myChar = LocalPlayer.Character
    local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
    
    if Settings.BlackHole and myHrp then
        for _, targetPlayer in pairs(Players:GetPlayers()) do
            if targetPlayer ~= LocalPlayer and targetPlayer.Character then
                local tHrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                local tHum = targetPlayer.Character:FindFirstChild("Humanoid")
                
                if tHrp and tHum and tHum.Health > 0 then
                    local targetDistance = (myHrp.Position - tHrp.Position).Magnitude
                    
                    if targetDistance < Settings.HoleRadius then
                        -- МГНОВЕННЫЙ КИЛЛ ПРИ ПРИБЛИЖЕНИИ В ЦЕНТР ВОРОНКИ ЧЕРНОЙ ДЫРЫ
                        if targetDistance < 16 then
                            -- Жесткий сброс CFrame и вектора падения в Бездну Void на координату -2000
                            tHrp.CFrame = CFrame.new(tHrp.Position.X, -2000, tHrp.Position.Z)
                            tHrp.AssemblyLinearVelocity = Vector3.new(0, -999, 0)
                        else
                            -- Динамическое векторное засасывание в эпицентр
                            local pullDirection = (myHrp.Position - tHrp.Position).Unit
                            tHrp.AssemblyLinearVelocity = pullDirection * Settings.HoleSpeed
                        end
                    end
                end
            end
        end
    end
end)

-- ====================================================================
-- МОДУЛЬ ЛОГИКИ И СИНХРОНИЗАЦИИ КНОПОК ИНТЕРФЕЙСА GUI Меню
-- ====================================================================
local function UpdateButtonVisual(button, state, text)
    if state then
        button.Text = text .. " [ВКЛ]"
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 130, 70)}):Play()
        button.UIStroke.Color = Color3.fromRGB(0, 200, 100)
    else
        button.Text = text .. " [ВЫКЛ]"
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 30, 38)}):Play()
        button.UIStroke.Color = Color3.fromRGB(50, 50, 65)
    end
end

AimBtn.MouseButton1Click:Connect(function()
    Settings.SilentAim = not Settings.SilentAim
    UpdateButtonVisual(AimBtn, Settings.SilentAim, "1. УПРЕЖДАЮЩИЙ АИМ")
    if Settings.SilentAim then
        StatusLabel.Text = "Аим активен. Прицел намертво следует за целью."
        StatusLabel.TextColor3 = Color3.fromRGB(0, 160, 255)
    end
end)

FovBtn.MouseButton1Click:Connect(function()
    Settings.ShowFov = not Settings.ShowFov
    UpdateButtonVisual(FovBtn, Settings.ShowFov, "2. ГРАНИЦЫ FOV (КРУГ)")
end)

HoleBtn.MouseButton1Click:Connect(function()
    Settings.BlackHole = not Settings.BlackHole
    UpdateButtonVisual(HoleBtn, Settings.BlackHole, "3. ФИЗИЧЕСКАЯ ДЫРА")
    if Settings.BlackHole then
        StatusLabel.Text = "Черная дыра активирована. Врагов засасывает в Void."
        StatusLabel.TextColor3 = Color3.fromRGB(180, 80, 255)
    end
end)

AntiGrabBtn.MouseButton1Click:Connect(function()
    Settings.AntiGrab = not Settings.AntiGrab
    UpdateButtonVisual(AntiGrabBtn, Settings.AntiGrab, "4. АНТИ-ХВАТ (БАГ ПОЛА)")
end)

-- ИНФОРМАЦИОННЫЙ ВЫВОД В ОКОШКО РЕДАКТОРА DELTA ПРИ УСПЕШНОМ ЗАПУСКЕ
print("========================================================")
print("[Delta iOS Execution]: FT&P Supremacy V9 успешно загружен!")
print("[Конфигурация]: Сверх-бросок выставлен на силу: " .. tostring(Settings.ThrowForce))
print("========================================================")
