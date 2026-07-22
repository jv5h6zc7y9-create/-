-- ====================================================================
-- IPAD FLING THINGS AND PEOPLE SUPREMACY V28 (FINAL ABSOLUTE MERGE)
-- NO SHORTCUTS - FULL EXPANDED SOURCE CODE FOR DELTA EXECUTOR iOS
-- ====================================================================

if not game:IsLoaded() then 
    game.Loaded:Wait() 
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Очистка старых окон во избежание наложения GUI интерфейсов
if CoreGui:FindFirstChild("FlingThingsEliteGUI_V28") then
    CoreGui:FindFirstChild("FlingThingsEliteGUI_V28"):Destroy()
end

-- СОЗДАНИЕ ИНТЕРФЕЙСА (Полностью на русском языке)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FlingThingsEliteGUI_V28"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 260, 0, 280)
MainFrame.Position = UDim2.new(0.5, -120, 0.5, -140)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -45, 0, 45)
TitleLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 13
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.Text = "  FT&P HARDCORE SUPREMACY V28"
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleLabel

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Name = "MinimizeBtn"
MinimizeBtn.Size = UDim2.new(0, 45, 0, 45)
MinimizeBtn.Position = UDim2.new(1, -45, 0, 0)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
MinimizeBtn.Text = "—"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.TextSize = 14
MinimizeBtn.Font = Enum.Font.SourceSansBold
MinimizeBtn.Parent = MainFrame

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 10)
MinCorner.Parent = MinimizeBtn

local Container = Instance.new("Frame")
Container.Name = "Container"
Container.Size = UDim2.new(1, 0, 1, -45)
Container.Position = UDim2.new(0, 0, 0, 45)
Container.BackgroundTransparency = 1
Container.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = Container
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 6)

-- ГЛОБАЛЬНЫЙ КОНФИГУРАТОР ТУМБЛЕРОВ ЧИТА
local toggles = { 
    silentAim = false, 
    maxVel = false, 
    blackHole = false, 
    antiGrab = false 
}

-- РУЧНОЕ СЕНСОРНОЕ ПЕРЕТАСКИВАНИЕ МЕНЮ ДЛЯ IPAD (ЗАЩИТА ОТ КРАША ПАМЯТИ IOS)
local dragging = false
local dragStart = nil
local startPos = nil

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- СКРЫТИЕ И РАСВЕРТЫВАНИЕ МЕНЮ В ОДНУ КНОПКУ НА ТОМ ЖЕ МЕСТЕ
local MenuMinimized = false

MinimizeBtn.MouseButton1Click:Connect(function()
    MenuMinimized = not MenuMinimized
    if MenuMinimized then
        Container.Visible = false
        MainFrame.Size = UDim2.new(0, 45, 0, 45)
        TitleLabel.Visible = false
        MinimizeBtn.Position = UDim2.new(0, 0, 0, 0)
        MinimizeBtn.Text = "MENU"
        MinimizeBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
    else
        Container.Visible = true
        MainFrame.Size = UDim2.new(0, 260, 0, 280)
        TitleLabel.Visible = true
        MinimizeBtn.Position = UDim2.new(1, -45, 0, 0)
        MinimizeBtn.Text = "—"
        MinimizeBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    end
end)

-- -------------------------------------------------------------------------------
-- МОДУЛЬ 1: ИСПРАВЛЕННЫЙ АНТИ-ЗАХВАТ (УДАЛЕНИЕ СВЯЗЕЙ И КРАШ РУК АГРЕССОРА)
-- -------------------------------------------------------------------------------
local function secure(char)
    char.DescendantAdded:Connect(function(d)
        if toggles.antiGrab and (d:IsA("Weld") or d:IsA("ManualWeld") or d:IsA("WeldConstraint") or d:IsA("MoverConstraint")) then
            task.delay(0.01, function()
                pcall(function()
                    if d.Parent then
                        local attackerModel = d.Parent:FindFirstAncestorOfClass("Model")
                        if attackerModel and attackerModel:FindFirstChildOfClass("Humanoid") and attackerModel.Name ~= LocalPlayer.Name then
                            attackerModel:BreakJoints() -- Тотальный срыв суставов нападающему врагу
                            d:Destroy()
                        end
                    end
                end)
            end)
        end
    end)
end

LocalPlayer.CharacterAdded:Connect(secure)
if LocalPlayer.Character then secure(LocalPlayer.Character) end

RunService.Stepped:Connect(function()
    if not toggles.antiGrab then return end
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root then
        for _, v in ipairs(root:GetChildren()) do
            if v:IsA("BodyPosition") or v:IsA("AlignPosition") or v:IsA("BodyVelocity") or v:IsA("LinearVelocity") then 
                v:Destroy() 
            end
        end
    end
end)

-- -------------------------------------------------------------------------------
-- МОДУЛЬ 2: САЙЛЕНТ АИМБОТ СКВОЗЬ СТЕНЫ (АВТО-ПОИСК БЛИЖАЙШЕГО И КРУГ ГРАНИЦ)
-- -------------------------------------------------------------------------------
local function getTarget()
    local target, min = nil, 260 -- Расстояние круга FOV на прицеливание
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            local pos, ok = Camera:WorldToScreenPoint(p.Character.HumanoidRootPart.Position)
            if ok then
                local d = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                if d < min then 
                    min = d
                    target = p.Character 
                end
            end
        end
    end
    return target
end

local old
old = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    if toggles.silentAim and getnamecallmethod() == "Raycast" then
        local t = getTarget()
        if t and t:FindFirstChild("HumanoidRootPart") then
            -- Жесткий сквозной вектор упреждения бега цели сквозь текстуры стен
            args[2] = ((t.HumanoidRootPart.Position + t.HumanoidRootPart.AssemblyLinearVelocity * 0.14) - args[1]).Unit * 15000
        end
    end
    return old(self, unpack(args))
end)

local oldIndex
oldIndex = hookmetamethod(game, "__index", function(self, k)
    if toggles.silentAim and not checkcaller() and (k == "Hit" or k == "Target") then
        local t = getTarget()
        if t and t:FindFirstChild("HumanoidRootPart") then
            local aimPos = t.HumanoidRootPart.Position + (t.HumanoidRootPart.AssemblyLinearVelocity * 0.14)
            return k == "Hit" and CFrame.new(aimPos) or t.HumanoidRootPart
        end
    end
    return oldIndex(self, k)
end)

-- -------------------------------------------------------------------------------
-- МОДУЛЬ 3: МОЛНИЕНОСНЫЙ МЕГА-БРОСОК (35,000,000) И ТРАМБОВКА ПОД ПОЛ
-- -------------------------------------------------------------------------------
RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = p.Character.HumanoidRootPart
            
            -- Находим оригинальный Weld удержания, проверяя привязку суставов к нашему персонажу
            local isWeld = hrp:FindFirstChildWhichIsA("Weld") or hrp:FindFirstChildWhichIsA("WeldConstraint") or hrp:FindFirstChildWhichIsA("MoverConstraint")
            local isGrabbedByMe = false
            
            if isWeld then
                if (isWeld.Part0 and isWeld.Part0:IsDescendantOf(char)) or (isWeld.Part1 and isWeld.Part1:IsDescendantOf(char)) then
                    isGrabbedByMe = true
                end
            end
            
            if toggles.maxVel and isGrabbedByMe then
                hrp:SetAttribute("Held", true)
                -- Трамбовка и выдавливание под пол, пока объект находится в руках
                hrp.CanCollide = false
                hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -150, hrp.AssemblyLinearVelocity.Z)
            elseif hrp:GetAttribute("Held") then
                -- МОМЕНТ БРОСКА: если кнопка прожата и связь порвалась — даем сокрушительный импульс
                pcall(function()
                    hrp.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
                    hrp.Massless = true
                    local throwVector = Camera.CFrame.LookVector
                    local t = getTarget()
                    if toggles.silentAim and t and t:FindFirstChild("HumanoidRootPart") then
                        throwVector = ((t.HumanoidRootPart.Position + t.HumanoidRootPart.AssemblyLinearVelocity * 0.14) - hrp.Position).Unit
                    else
                        throwVector = (Camera.CFrame.LookVector + Vector3.new(0, 3.5, 0)).Unit
                    end
                    hrp:ApplyImpulse(throwVector * 35000000)
                    hrp.AssemblyLinearVelocity = throwVector * 35000000
                end)
                hrp:SetAttribute("Held", nil) -- Полный сброс кэша: скрипт моментально забывает старую цель
            end
        end
    end
end)

-- -------------------------------------------------------------------------------
-- МОДУЛЬ 4: СКОРОСТНАЯ ТЕЛЕПОРТ ЧЕРНАЯ ДЫРА СО СПАВНОМ МИКРОВОЛНОВКИ И КИЛЛОМ
-- -------------------------------------------------------------------------------
task.spawn(function()
    while task.wait(0.03) do
        if toggles.blackHole and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local root = LocalPlayer.Character.HumanoidRootPart
            -- Вызов Remote-пакета инвентаря игрушек для мгновенного призыва Микроволновки
            local rem = ReplicatedStorage:FindFirstChild("SpawnToy", true) or ReplicatedStorage:FindFirstChild("ToysRemote", true) or (ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("SpawnToy"))
            if rem and rem:IsA("RemoteEvent") then
                rem:FireServer("Microwave")
            end
            -- Сверхбыстрый облет всех игроков сервера для принудительного захвата руками
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    pcall(function()
                        -- Телепортируемся к жертве, заставляя игру сделать хват
                        root.CFrame = p.Character.HumanoidRootPart.CFrame
                        p.Character.HumanoidRootPart.CanCollide = false
                        -- Вжимаем в вызванную ловушку и пол со скоростью -90000 до моментальной смерти
                        p.Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, -90000, 0)
                    end)
                    task.wait(0.01) -- Микро-пауза для предотвращения кика античитом Roblox
                end
            end
        end
    end
end)

-- ГЕНЕРАТОР ТУМБЛЕРОВ КНОПОК ИНТЕРФЕЙСА GUI НА РУССКОМ ЯЗЫКЕ
local function CreateToggle(name, posY, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 230, 0, 42)
    Btn.Position = UDim2.new(0, 15, 0, posY)
    Btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.TextSize = 12
    Btn.Font = Enum.Font.GothamBold
    Btn.Text = name .. ": ВЫКЛ"
    Btn.Parent = Container
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = Btn
    
    local active = false
    Btn.MouseButton1Click:Connect(function()
        active = not active
        Btn.Text = name .. (active and ": ВКЛ" or ": ВЫКЛ")
        Btn.BackgroundColor3 = active and Color3.fromRGB(0, 140, 255) or Color3.fromRGB(45, 45, 55)
        callback(active)
    end)
end

CreateToggle("1. Авто-Аим по Ближайшему", 10, function(v) toggles.silentAim = v end)
CreateToggle("2. Молниеносный Бросок + Трамбовка", 58, function(v) toggles.maxVel = v end)
CreateToggle("3. Истинная Черная Дыра (Сбор)", 106, function(v) toggles.blackHole = v end)
CreateToggle("4. Нативный Анти-Захват рук", 154, function(v) toggles.antiGrab = v end)

print("[Delta iOS Setup Supreme V28: All modules successfully combined and executed!]")
