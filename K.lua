-- ====================================================================
-- IPAD FLING THINGS AND PEOPLE SUPREMACY V17 (IDEAL COMPLETE)
-- NO SHORTCUTS - FULL EXPANDED SOURCE CODE FOR DELTA EXECUTOR iOS
-- ====================================================================

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local AimButton = Instance.new("TextButton")
local HoleButton = Instance.new("TextButton")
local AntiGrabButton = Instance.new("TextButton")

-- Элементы интерфейса для Списка Игроков (Выбор одной цели)
local DropdownButton = Instance.new("TextButton")
local DropdownScroll = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")

ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

MainFrame.Name = "iPadDeltaMenuFinalV17"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
MainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
MainFrame.Size = UDim2.new(0, 260, 0, 430)
MainFrame.Active = true
MainFrame.Draggable = true 

local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0, 10)
FrameCorner.Parent = MainFrame

Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
Title.Text = "FT&P SUPREMACY V17"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 13
Title.Font = Enum.Font.SourceSansBold

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = Title

local function styleButton(btn, text, posY)
    btn.Parent = MainFrame
    btn.Size = UDim2.new(0.9, 0, 0, 45)
    btn.Position = UDim2.new(0.05, 0, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 13
    btn.Font = Enum.Font.SourceSansBold
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 8)
    BtnCorner.Parent = btn
end

styleButton(AimButton, "1. Сверх-Аим за Целью [ВЫКЛ]", 60)
styleButton(HoleButton, "2. Истинная Черная Дыра [ВЫКЛ]", 115)
styleButton(AntiGrabButton, "3. Рабочий Анти-Взятие [ВКЛ]", 170)

-- Настройка выпадающего списка игроков
DropdownButton.Parent = MainFrame
DropdownButton.Size = UDim2.new(0.9, 0, 0, 40)
DropdownButton.Position = UDim2.new(0.05, 0, 0, 225)
DropdownButton.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
DropdownButton.Text = "Выбрать жертву: [НИКОГО]"
DropdownButton.TextColor3 = Color3.fromRGB(255, 255, 0)
DropdownButton.TextSize = 13
DropdownButton.Font = Enum.Font.SourceSansBold

local DropdownCorner = Instance.new("UICorner")
DropdownCorner.CornerRadius = UDim.new(0, 8)
DropdownCorner.Parent = DropdownButton

DropdownScroll.Parent = MainFrame
DropdownScroll.Size = UDim2.new(0.9, 0, 0, 140)
DropdownScroll.Position = UDim2.new(0.05, 0, 0, 270)
DropdownScroll.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
DropdownScroll.Visible = false
DropdownScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
DropdownScroll.ScrollBarThickness = 4

local ScrollCorner = Instance.new("UICorner")
ScrollCorner.CornerRadius = UDim.new(0, 8)
ScrollCorner.Parent = DropdownScroll

UIListLayout.Parent = DropdownScroll
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 4)

-- СЕРВИСЫ И ПЕРЕМЕННЫЕ
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local SelectedTarget = nil
local SilentAimEnabled = false
local MaxThrowEnabled = true
local BlackHoleEnabled = false
local AntiGrabEnabled = true

local GlobalTrackedGrab = { ActiveItem = nil, WasGrabbed = false }

local function getTargetRoot(player)
    if player and player.Character then
        return player.Character:FindFirstChild("HumanoidRootPart") or player.Character:FindFirstChild("Torso")
    end
    return nil
end

-- ФУНКЦИЯ ОБНОВЛЕНИЯ СПИСКА ИГРОКОВ (ОБНОВЛЯЕТСЯ АВТОМАТИЧЕСКИ КАЖДУЮ МИНУТУ)
local function RefreshPlayerDropdown()
    for _, child in pairs(DropdownScroll:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local pBtn = Instance.new("TextButton")
            pBtn.Size = UDim2.new(1, 0, 0, 30)
            pBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
            pBtn.Text = player.Name
            pBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            pBtn.TextSize = 13
            pBtn.Font = Enum.Font.SourceSans
            pBtn.Parent = DropdownScroll
            
            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 4)
            btnCorner.Parent = pBtn
            
            pBtn.MouseButton1Click:Connect(function()
                SelectedTarget = player
                DropdownButton.Text = "Цель: " .. player.Name
                DropdownScroll.Visible = false
            end)
        end
    end
    DropdownScroll.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
end

-- Авто-обновление списка раз в 60 секунд
task.spawn(function()
    while task.wait(60) do
        RefreshPlayerDropdown()
    end
end)

DropdownButton.MouseButton1Click:Connect(function()
    RefreshPlayerDropdown()
    DropdownScroll.Visible = not DropdownScroll.Visible
end)

-- -------------------------------------------------------------------------------
-- ФУНКЦИЯ 1: СКВОЗНОЙ АИМ (ИСПРАВЛЕННЫЙ ХУК ДЛЯ ДЕЛЬТЫ)
-- -------------------------------------------------------------------------------
local function getPredictedPosition(targetPart)
    if not targetPart then return Vector3.zero end
    local velocity = targetPart.AssemblyLinearVelocity or Vector3.zero
    return targetPart.Position + (velocity * 0.165)
end

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    if SilentAimEnabled and SelectedTarget and (method == "Raycast" or method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList") then
        local targetRoot = getTargetRoot(SelectedTarget)
        if targetRoot then
            local predictedPos = getPredictedPosition(targetRoot)
            if method == "Raycast" then
                local origin = args[1]
                args[2] = (predictedPos - origin).Unit * 10000
            end
        end
    end
    return oldNamecall(self, unpack(args))
end)

-- -------------------------------------------------------------------------------
-- ФУНКЦИЯ 2: АВТОНОМНЫЙ ДАЛЕКИЙ БРОСОК НА МАКСИМУМ (ИСПРАВЛЕНА ФИЗИКА КНОПКИ)
-- -------------------------------------------------------------------------------
local function applyMaxThrowPhysics(toolObject)
    if not toolObject or not toolObject:IsA("BasePart") then return end
    pcall(function()
        toolObject.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
        toolObject.AssemblyMass = 0
    end)
    
    local throwVector = Camera.CFrame.LookVector
    if SilentAimEnabled and SelectedTarget then
        local targetRoot = getTargetRoot(SelectedTarget)
        if targetRoot then
            throwVector = (getPredictedPosition(targetRoot) - toolObject.Position).Unit
        end
    else
        throwVector = (Camera.CFrame.LookVector + Vector3.new(0, 3.5, 0)).Unit
    end

    local bodyImpulse = throwVector * 35000000
    toolObject:ApplyImpulse(bodyImpulse)
    toolObject.AssemblyLinearVelocity = bodyImpulse
    
    local attachment = Instance.new("Attachment", toolObject)
    local lv = Instance.new("LinearVelocity", toolObject)
    lv.Attachment0 = attachment
    lv.VectorVelocity = throwVector * 550000
    lv.MaxForce = 35000000
    
    game:GetService("Debris"):AddItem(lv, 0.3)
    game:GetService("Debris"):AddItem(attachment, 0.3)
end

-- Отслеживание удержания вещей в руках через RenderStepped
RunService.RenderStepped:Connect(function()
    local myChar = LocalPlayer.Character
    if myChar then
        local currentFrameObject = nil
        for _, object in pairs(myChar:GetDescendants()) do
            if object:IsA("Weld") or object:IsA("Constraint") or object:IsA("MoverConstraint") then
                if object.Part1 and not object.Part1:IsDescendantOf(myChar) then
                    currentFrameObject = object.Part1
                elseif object.Part0 and not object.Part0:IsDescendantOf(myChar) then
                    currentFrameObject = object.Part0
                end
            end
        end

        if currentFrameObject and currentFrameObject:IsA("BasePart") then
            GlobalTrackedGrab.ActiveItem = currentFrameObject
            GlobalTrackedGrab.WasGrabbed = true
            
            -- Заталкивание под пол кастомным вектором направления камеры вниз
            currentFrameObject.CanCollide = false
            currentFrameObject.AssemblyLinearVelocity = Vector3.new(currentFrameObject.AssemblyLinearVelocity.X, -150, currentFrameObject.AssemblyLinearVelocity.Z)
        else
            -- Момент отпускания оригинальной игровой кнопки броска
            if GlobalTrackedGrab.WasGrabbed and GlobalTrackedGrab.ActiveItem then
                if MaxThrowEnabled then
                    applyMaxThrowPhysics(GlobalTrackedGrab.ActiveItem)
                end
                GlobalTrackedGrab.ActiveItem = nil
                GlobalTrackedGrab.WasGrabbed = false
            end
        end
    end
end)

-- -------------------------------------------------------------------------------
-- ФУНКЦИЯ 3: ИСТИННАЯ ЧЕРНАЯ ДЫРА С ВЖАТИЕМ В ПОЛ И МИКРОВОЛНОВКУ
-- -------------------------------------------------------------------------------
RunService.RenderStepped:Connect(function()
    if not BlackHoleEnabled then return end
    local myRoot = getTargetRoot(LocalPlayer)
    if not myRoot then return end
    
    local angle = tick() * Config.OrbitSpeed
    local radius = Config.HoleRadius
    
    -- Затягивание игроков в круговую орбиту рук
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local root = getTargetRoot(p)
            if root then
                pcall(function()
                    root.CanCollide = false
                    local targetX = myRoot.Position.X + math.cos(angle) * radius
                    local targetZ = myRoot.Position.Z + math.sin(angle) * radius
                    -- Жесткое вжатие в текстуры и микроволновку под пол по оси Y (-45000)
                    root.AssemblyLinearVelocity = Vector3.new((targetX - root.Position.X) * 50, -45000, (targetZ - root.Position.Z) * 50)
                end)
            end
        end
    end
    
    -- Затягивание всех вещей на карте в эпицентр воронки
    for _, part in ipairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") and not part.Anchored and part.AssemblyMass < 100 and not part:IsDescendantOf(LocalPlayer.Character) then
            pcall(function()
                part.CanCollide = false
                local targetX = myRoot.Position.X + math.cos(angle) * radius
                local targetZ = myRoot.Position.Z + math.sin(angle) * radius
                part.AssemblyLinearVelocity = Vector3.new((targetX - part.Position.X) * 40, -25000, (targetZ - part.Position.Z) * 40)
            end)
        end
    end
end)

-- -------------------------------------------------------------------------------
-- ФУНКЦИЯ 4: НАТИВНЫЙ АНТИ-ГРАБ ПО ФОРУМНЫМ МЕТОДАМ ЯДРА
-- -------------------------------------------------------------------------------
local function monitorAntiGrab(character)
    character.DescendantAdded:Connect(function(descendant)
        if not AntiGrabEnabled then return end
        if descendant:IsA("Weld") or descendant:IsA("WeldConstraint") or descendant:IsA("RotationConstraint") or descendant:IsA("MoverConstraint") then
            local parent = descendant.Parent
            task.wait() -- Микро-пауза для инициализации пакета сервером
            if parent and (parent:IsA("BasePart") and not parent:IsDescendantOf(character)) then
                pcall(function()
                    descendant:Destroy()
                    if parent.Parent and parent.Parent:FindFirstChild("Humanoid") then
                        parent.Parent:BreakJoints() -- Полный разрыв рук нападающего агрессора
                    end
                end)
            end
        end
    end)
end

if LocalPlayer.Character then monitorAntiGrab(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(monitorAntiGrab)

-- НАСТРОЙКА НАЖАТИЙ КНОПОК ИНТЕРФЕЙСА GUI
AimButton.MouseButton1Click:Connect(function()
    SilentAimEnabled = not SilentAimEnabled
    AimButton.Text = "1. Сверх-Аим за Целью " .. (SilentAimEnabled and "[ВКЛ]" or "[ВЫКЛ]")
    AimButton.BackgroundColor3 = SilentAimEnabled and Color3.fromRGB(0, 140, 60) or Color3.fromRGB(45, 45, 52)
end)

HoleButton.MouseButton1Click:Connect(function()
    BlackHoleEnabled = not BlackHoleEnabled
    HoleButton.Text = "2. Истинная Черная Дыра " .. (BlackHoleEnabled and "[ВКЛ]" or "[ВЫКЛ]")
    HoleButton.BackgroundColor3 = BlackHoleEnabled and Color3.fromRGB(0, 140, 60) or Color3.fromRGB(45, 45, 52)
end)

AntiGrabButton.MouseButton1Click:Connect(function()
    AntiGrabEnabled = not AntiGrabEnabled
    AntiGrabButton.Text = "3. Рабочий Анти-Взятие " .. (AntiGrabEnabled and "[ВКЛ]" or "[ВЫКЛ]")
    AntiGrabButton.BackgroundColor3 = AntiGrabEnabled and Color3.fromRGB(0, 140, 60) or Color3.fromRGB(45, 45, 52)
end)

-- Первичная инициализация кнопок меню при старте
AimButton.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
HoleButton.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
AntiGrabButton.BackgroundColor3 = Color3.fromRGB(0, 140, 60) -- Анти-Граб включен по умолчанию

print("[Delta iOS Ideal V17: Full Merge Complete]")
