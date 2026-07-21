-- СОЗДАНИЕ ИНТЕРФЕЙСА (Сенсорное меню для iPad)
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local AimButton = Instance.new("TextButton")
local EspButton = Instance.new("TextButton")
local HoleButton = Instance.new("TextButton")

ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

MainFrame.Name = "iPadDeltaMenuUltimate"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Position = UDim2.new(0.05, 0, 0.25, 0)
MainFrame.Size = UDim2.new(0, 260, 0, 280)
MainFrame.Active = true
MainFrame.Draggable = true 

Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Title.Text = "IPAD FTP ULTIMATE v4"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.SourceSansBold

local function styleButton(btn, text, posY)
    btn.Parent = MainFrame
    btn.Size = UDim2.new(0.9, 0, 0, 50)
    btn.Position = UDim2.new(0.05, 0, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.Text = text .. " [ВЫКЛ]"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 15
    btn.Font = Enum.Font.SourceSansBold
end

styleButton(AimButton, "1. Сверх-Хват + Аим", 65)
styleButton(EspButton, "2. Подсветка (ESP)", 130)
styleButton(HoleButton, "3. BlackHole + Kill", 195)

-- СЕРВИСЫ ROBLOX
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- НАСТРОЙКИ ФУНКЦИЙ
local States = { SilentAim = false, ShowEsp = false, BlackHole = false }
-- Config.MaxTargetDistance — это радиус в пикселях, насколько близко нужно нажать к игроку, чтобы сработал Аим-Хват
local Config = { MaxTargetDistance = 350, ThrowForce = 999999, HoleSpeed = 160, HoleRadius = 250 }
local EspObjects = {}

-- 1. ДИНАМИЧЕСКИЙ ПОИСК БЛИЖАЙШЕЙ ЦЕЛИ РЯДОМ С ТАЧЕМ/ПРИЦЕЛОМ (БЕЗ ЗАЛИПАНИЙ)
local function GetCurrentClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = Config.MaxTargetDistance
    local touchPos = UserInputService:GetMouseLocation()

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            local human = player.Character:FindFirstChild("Humanoid")
            
            if root and human and human.Health > 0 then
                local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
                
                if onScreen then
                    -- Вычисляем расстояние от текущего места нажатия до игрока на экране
                    local distance = (Vector2.new(touchPos.X, touchPos.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                    
                    -- Если цель ближе, чем предыдущие найденные, выбираем её
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

-- 2. ДИНАМИЧЕСКОЕ ОБНОВЛЕНИЕ ПОДСВЕТКИ (HIGHLIGHT ESP)
local function UpdateEsp()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            if States.ShowEsp then
                if not EspObjects[player] then
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "FTP_DYNAMIC_ESP"
                    highlight.FillColor = Color3.fromRGB(255, 0, 0)
                    highlight.FillTransparency = 0.6
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.OutlineTransparency = 0.2
                    highlight.Adornee = player.Character
                    highlight.Parent = player.Character
                    EspObjects[player] = highlight
                else
                    -- Если игрок попал в зону Аима и стал главной целью для хвата — он подсвечивается зеленым
                    local activeTarget = GetCurrentClosestPlayer()
                    if activeTarget == player then
                        EspObjects[player].FillColor = Color3.fromRGB(0, 255, 0)
                    else
                        EspObjects[player].FillColor = Color3.fromRGB(255, 0, 0)
                    end
                end
            else
                if EspObjects[player] then
                    EspObjects[player]:Destroy()
                    EspObjects[player] = nil
                end
            end
        end
    end
end

Players.PlayerRemoving:Connect(function(player)
    if EspObjects[player] then
        EspObjects[player]:Destroy()
        EspObjects[player] = nil
    end
end)

-- 3. МОЩНЫЙ РУЧНОЙ БРОСОК ПО НАЖАТИЮ ОРИГИНАЛЬНОЙ КНОПКИ
UserInputService.InputBegan:Connect(function(input, processed)
    -- Перехватываем только реальное нажатие кнопки броска на iPad
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton2 then
        if States.SilentAim then
            local target = GetCurrentClosestPlayer()
            
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                local targetHrp = target.Character.HumanoidRootPart
                
                for _, part in pairs(target.Character:GetChildren()) do
                    if part:IsA("BasePart") then 
                        part.CanCollide = false 
                    end
                end
                
                local velocityInstance = Instance.new("LinearVelocity")
                local attachment = Instance.new("Attachment")
                
                attachment.Parent = targetHrp
                velocityInstance.MaxForce = math.huge
                velocityInstance.VectorVelocity = Camera.CFrame.LookVector * Config.ThrowForce
                velocityInstance.Attachment0 = attachment
                velocityInstance.Parent = targetHrp
                
                task.wait(0.2)
                velocityInstance:Destroy()
                attachment:Destroy()
            end
        end
    end
end)

-- 4. ХУК НА ХВАТАТЕЛЬНЫЕ ЛУЧИ (ИСПРАВЛЕНЫ ВСЕ БАГИ ПРИВЯЗКИ)
-- Этот блок заставляет игру думать, что ваш палец нажимает ТОЧНО на игрока, когда вы тапаете рядом
local oldIndex
oldIndex = hookmetamethod(game, "__index", function(self, key)
    if States.SilentAim and not checkcaller() then
        -- Хукаем свойства мыши/тача, которые игра использует для функции хватания (Grab)
        if key == "Hit" or key == "Target" then
            local dynamicTarget = GetCurrentClosestPlayer()
            
            if dynamicTarget and dynamicTarget.Character and dynamicTarget.Character:FindFirstChild("HumanoidRootPart") then
                if key == "Hit" then
                    return dynamicTarget.Character.HumanoidRootPart.CFrame
                elseif key == "Target" then
                    -- Возвращаем деталь игрока, чтобы игра успешно выполнила ХВАТ на расстоянии
                    return dynamicTarget.Character.HumanoidRootPart
                end
            end
        end
    end
    return oldIndex(self, key)
end)

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if States.SilentAim and (method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList" or method == "Raycast") then
        local dynamicTarget = GetCurrentClosestPlayer()
        if dynamicTarget and dynamicTarget.Character and dynamicTarget.Character:FindFirstChild("HumanoidRootPart") then
            local targetPart = dynamicTarget.Character.HumanoidRootPart
            if method == "Raycast" then
                args = (targetPart.Position - args).Unit * 1000
            else
                args = Ray.new(args.Origin, (targetPart.Position - args.Origin).Unit * 1000)
            end
        end
    end
    return oldNamecall(self, unpack(args))
end)

-- 5. АКТИВНЫЙ ЦИКЛ ЧЕРНОЙ ДЫРЫ И АВТО-УБИЙСТВА
RunService.Heartbeat:Connect(function()
    UpdateEsp() -- Постоянно обновляем маркеры подсветки игроков
    
    if not States.BlackHole then return end
    
    local myChar = LocalPlayer.Character
    local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHrp then return end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local tHrp = player.Character:FindFirstChild("HumanoidRootPart")
            local tHum = player.Character:FindFirstChild("Humanoid")
            
            if tHrp and tHum and tHum.Health > 0 then
                local distance = (myHrp.Position - tHrp.Position).Magnitude
                
                if distance < Config.HoleRadius then
                    if distance < 15 then
                        -- МГНОВЕННЫЙ КИЛЛ под текстуры в Void при затягивании
                        tHrp.CFrame = CFrame.new(tHrp.Position.X, -1500, tHrp.Position.Z)
                        tHrp.AssemblyLinearVelocity = Vector3.new(0, -500, 0)
                    else
                        -- Принудительное затягивание скоростным импульсом в эпицентр
                        local direction = (myHrp.Position - tHrp.Position).Unit
                        tHrp.AssemblyLinearVelocity = direction * Config.HoleSpeed
                    end
                end
            end
        end
    end
end)

-- ПОДКЛЮЧЕНИЕ НАЖАТИЙ НА КНОПКИ МЕНЮ ДЛЯ IPAD
AimButton.MouseButton1Click:Connect(function()
    States.SilentAim = not States.SilentAim
    AimButton.Text = "1. Сверх-Хват + Аим " .. (States.SilentAim and "[ВКЛ]" or "[ВЫКЛ]")
    AimButton.BackgroundColor3 = States.SilentAim and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 50)
end)

EspButton.MouseButton1Click:Connect(function()
    States.ShowEsp = not States.ShowEsp
    EspButton.Text = "2. Подсветка " .. (States.ShowEsp and "[ПОКАЗАТЬ]" or "[СКРЫТЬ]")
    EspButton.BackgroundColor3 = States.ShowEsp and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 50)
end)

HoleButton.MouseButton1Click:Connect(function()
    States.BlackHole = not States.BlackHole
    HoleButton.Text = "3. BlackHole + Kill " .. (States.BlackHole and "[ВКЛ]" or "[ВЫКЛ]")
    HoleButton.BackgroundColor3 = States.BlackHole and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 50)
end)

print("[Delta Ultimate iPad Script Loaded]")
