-- ====================================================================
-- BLOXSTRIKE ONLY WALLHACK (ESP) — ULTRA LIGHT VERSION
-- OPTIMIZED FOR DELTA EXECUTOR (iOS / iPAD) — NO LAGS
-- ====================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local EspActive = false
local ActiveHighlights = {}

-- Очистка старой панели при перезапуске скрипта
if CoreGui:FindFirstChild("BloxStrikeOnlyEsp") then
    CoreGui:FindFirstChild("BloxStrikeOnlyEsp"):Destroy()
end

-- ====================================================================
-- СОЗДАНИЕ ИНТЕРФЕЙСА (Одна крупная кнопка под палец)
-- ====================================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BloxStrikeOnlyEsp"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
MainFrame.Position = UDim2.new(0.05, 0, 0.4, 0) -- Удобное расположение сбоку экрана
MainFrame.Size = UDim2.new(0, 220, 0, 110)
MainFrame.Active = true
MainFrame.Draggable = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 2
MainStroke.Color = Color3.fromRGB(50, 50, 60)
MainStroke.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
Title.Text = "BLOXSTRIKE WALLHACK"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 13
Title.Font = Enum.Font.SourceSansBold

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = Title

local EspBtn = Instance.new("TextButton")
EspBtn.Parent = MainFrame
EspBtn.Size = UDim2.new(0.9, 0, 0, 45)
EspBtn.Position = UDim2.new(0.05, 0, 0, 50)
EspBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
EspBtn.Text = "ВКЛЮЧИТЬ ВХ [ВЫКЛ]"
EspBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
EspBtn.TextSize = 14
EspBtn.Font = Enum.Font.SourceSansBold

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 8)
BtnCorner.Parent = EspBtn

local BtnStroke = Instance.new("UIStroke")
BtnStroke.Thickness = 1
BtnStroke.Color = Color3.fromRGB(55, 55, 70)
BtnStroke.Parent = EspBtn

-- ====================================================================
-- ЯДРО БЕЗЛАГОВОГО ВХ (ОБНОВЛЕНИЕ СТРОГО СПИСКА ИГРОКОВ)
-- ====================================================================

RunService.Heartbeat:Connect(function()
    if not EspActive then
        -- Если кнопка выключена, мгновенно стираем все силуэты из памяти iPad
        for player, hl in pairs(ActiveHighlights) do
            if hl then hl:Destroy() end
            ActiveHighlights[player] = nil
        end
        return
    end

    -- Перебираем только активную таблицу игроков на сервере (без сканирования карты)
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team then
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                
                -- Создание высокопроизводительного силуэта сквозь стены
                if not ActiveHighlights[player] then
                    local hl = Instance.new("Highlight")
                    hl.Name = "BloxStrike_Pure_ESP"
                    hl.FillColor = Color3.fromRGB(255, 0, 50) -- Красный цвет силуэта врага
                    hl.FillTransparency = 0.45
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255) -- Белый контур обводки
                    hl.OutlineTransparency = 0.1
                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop -- Видимость сквозь стены Mirage
                    hl.Adornee = char
                    hl.Parent = char
                    ActiveHighlights[player] = hl
                end
            else
                -- Убираем силуэт, если враг погиб
                if ActiveHighlights[player] then
                    ActiveHighlights[player]:Destroy()
                    ActiveHighlights[player] = nil
                end
            end
        else
            -- Убираем силуэт, если игрок перешел в вашу команду
            if ActiveHighlights[player] then
                ActiveHighlights[player]:Destroy()
                ActiveHighlights[player] = nil
            end
        end
    end
end)

-- Очистка кэша ВХ при выходе игрока с сервера Mirage
Players.PlayerRemoving:Connect(function(player)
    if ActiveHighlights[player] then
        ActiveHighlights[player]:Destroy()
        ActiveHighlights[player] = nil
    end
end)

-- ====================================================================
-- ОБРАБОТКА НАЖАТИЯ КНОПКИ ТАЧПАДА IPAD
-- ====================================================================

EspBtn.MouseButton1Click:Connect(function()
    EspActive = not EspActive
    if EspActive then
        EspBtn.Text = "ВКЛЮЧИТЬ ВХ [ВКЛ]"
        TweenService:Create(EspBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 130, 70)}):Play()
        EspBtn.UIStroke.Color = Color3.fromRGB(0, 200, 100)
    else
        EspBtn.Text = "ВКЛЮЧИТЬ ВХ [ВЫКЛ]"
        TweenService:Create(EspBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 45)}):Play()
        EspBtn.UIStroke.Color = Color3.fromRGB(55, 55, 70)
    end
end)

print("[Delta Pure Wallhack Loaded Successfully!]")
