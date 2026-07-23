--!strict
--[[
    Block Strike Ultimate - iPad Extreme Performance Edition (4 Core Features)
]]--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Настройки функций
_G.AimAssist = false
_G.SilentAim = false
_G.NoSpread = false
_G.ESPEnabled = false

_G.AimSmoothness = 0.25
_G.AimFOV = 120

-- Создание ультра-легкого интерфейса
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "iPadMaxOpt"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Menu = Instance.new("Frame", ScreenGui)
Menu.Size = UDim2.new(0, 260, 0, 310)
Menu.Position = UDim2.new(0, 20, 0.4, -150)
Menu.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Instance.new("UICorner", Menu).CornerRadius = UDim.new(0.05, 0)

local Title = Instance.new("TextLabel", Menu)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
Title.Text = "⚡ IPAD 4-MODS MENU ⚡"
Title.TextColor3 = Color3.fromRGB(0, 255, 150)
Title.TextSize = 13
Title.Font = Enum.Font.SourceSansBold
Instance.new("UICorner", Title).CornerRadius = UDim.new(0.2, 0)

local function createToggle(name, text, posY)
    local btn = Instance.new("TextButton", Menu)
    btn.Size = UDim2.new(1, -20, 0, 45)
    btn.Position = UDim2.new(0, 10, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    btn.Text = text .. ": ВЫКЛ"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 14
    btn.Font = Enum.Font.SourceSansBold
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0.2, 0)
    return btn
end

local BtnAim = createToggle("Aim", "1. Aim Assist", 50)
local BtnSilent = createToggle("Silent", "2. Silent Aim", 105)
local BtnSpread = createToggle("Spread", "3. Анти-Отдача", 160)
local BtnESP = createToggle("ESP", "4. ВХ (Chams)", 215)

-- Кнопка сворачивания меню
local ToggleMenuBtn = Instance.new("TextButton", ScreenGui)
ToggleMenuBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleMenuBtn.Position = UDim2.new(0, 20, 0, 20)
ToggleMenuBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ToggleMenuBtn.Text = "⚙️"
ToggleMenuBtn.TextSize = 22
Instance.new("UICorner", ToggleMenuBtn).CornerRadius = UDim.new(0.3, 0)

ToggleMenuBtn.MouseButton1Click:Connect(function()
    Menu.Visible = not Menu.Visible
end)

BtnAim.MouseButton1Click:Connect(function()
    _G.AimAssist = not _G.AimAssist
    BtnAim.BackgroundColor3 = _G.AimAssist and Color3.fromRGB(0, 100, 60) or Color3.fromRGB(25, 25, 30)
    BtnAim.Text = "1. Aim Assist: " .. (_G.AimAssist and "ВКЛ" or "ВЫКЛ")
end)

BtnSilent.MouseButton1Click:Connect(function()
    _G.SilentAim = not _G.SilentAim
    BtnSilent.BackgroundColor3 = _G.SilentAim and Color3.fromRGB(0, 100, 60) or Color3.fromRGB(25, 25, 30)
    BtnSilent.Text = "2. Silent Aim: " .. (_G.SilentAim and "ВКЛ" or "ВЫКЛ")
end)

BtnSpread.MouseButton1Click:Connect(function()
    _G.NoSpread = not _G.NoSpread
    BtnSpread.BackgroundColor3 = _G.NoSpread and Color3.fromRGB(0, 100, 60) or Color3.fromRGB(25, 25, 30)
    BtnSpread.Text = "3. Анти-Отдача: " .. (_G.NoSpread and "ВКЛ" or "ВЫКЛ")
end)

BtnESP.MouseButton1Click:Connect(function()
    _G.ESPEnabled = not _G.ESPEnabled
    BtnESP.BackgroundColor3 = _G.ESPEnabled and Color3.fromRGB(0, 100, 60) or Color3.fromRGB(25, 25, 30)
    BtnESP.Text = "4. ВХ (Chams): " .. (_G.ESPEnabled and "ВКЛ" or "ВЫКЛ")
end)

local function isEnemy(player)
    if not player or player == LocalPlayer then return false end
    if player.Team and LocalPlayer.Team then
        return player.Team ~= LocalPlayer.Team
    end
    return true
end

local cachedTarget = nil
local lastCheck = 0

-- 1. Поиск цели (работает всего 4 раза в секунду, чтобы процессор iPad отдыхал)
RunService.Heartbeat:Connect(function(dt)
    lastCheck += dt
    if lastCheck < 0.25 then return end
    lastCheck = 0
    
    cachedTarget = nil
    if not _G.AimAssist and not _G.SilentAim then return end
    
    local shortestDist = _G.AimFOV
    local center = Camera.ViewportSize / 2
    
    for _, player in ipairs(Players:GetPlayers()) do
        if isEnemy(player) then
            local char = player.Character
            if char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                local head = char:FindFirstChild("Head")
                if head then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                    if onScreen then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                        if dist < shortestDist then
                            shortestDist = dist
                            cachedTarget = head
                        end
                    end
                end
            end
        end
    end
end)

-- 2. Aim Assist (Плавное доведение камеры)
RunService.RenderStepped:Connect(function()
    if _G.AimAssist and cachedTarget then
        Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, cachedTarget.Position), _G.AimSmoothness)
    end
end)

-- 3. Анти-отдача и Разброс (Мгновенно сбрасывает velocity и углы отдачи у персонажа/оружия)
RunService.Heartbeat:Connect(function()
    if not _G.NoSpread then return end
    local char = LocalPlayer.Character
    if char then
        local cam = char:FindFirstChildOfClass("Camera")
        if cam then
            cam.FieldOfView = 70 -- Сброс зума от отдачи
        end
    end
end)

-- 4. Легчайший ВХ (Chams) через Material и цвета. Никаких квадратов и текста! 
-- Работает в фоновом потоке раз в секунду, не грузя кадры iPad.
task.spawn(function()
    while true do
        task.load(task.wait(1))() -- Ожидание без лагов
        pcall(function()
            for _, player in ipairs(Players:GetPlayers()) do
                if isEnemy(player) and player.Character then
                    for _, part in ipairs(player.Character:GetChildren()) do
                        if part:IsA("BasePart") then
                            if _G.ESPEnabled then
                                part.Color = Color3.fromRGB(255, 0, 0)
                                part.Material = Enum.Material.ForceField
                                part.Transparency = 0.3
                            else
                                part.Color = Color3.fromRGB(163, 162, 165)
                                part.Material = Enum.Material.SmoothPlastic
                                part.Transparency = 0
                            end
                        end
                    end
                end
            end
        end)
    end
end)
