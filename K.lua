--[=[
    SYLENT Research: Absolute Zero-Lag Mobile ESP (Hardware Highlight)
    Платформа: Apple iPad (Все поколения)
    Назначение: Чистый ВХ на врагов сквозь стены (0% нагрузки на CPU)
--]=]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- НАСТРОЙКИ СТИЛЯ
local CONFIG = {
    EnemyColor = Color3.fromRGB(0, 255, 128),    -- Неоново-зеленый (как на скриншоте)
    FillTransparency = 0.6,                      -- Прозрачность заливки тела (0 - залито, 1 - только контур)
    OutlineTransparency = 0,                     -- Прозрачность контура силуэта (0 - максимальная видимость)
    TeamCheck = true                             -- Игнорировать союзников (ВХ только на врагов)
}

local Subscriptions = {}

-- НАДЁЖНАЯ ФУНКЦИЯ СОЗДАНИЯ НАДСТРОЙКИ ВХ
local function ApplyHardwareESP(player)
    if player == LocalPlayer then return end
    
    local function CharacterAdded(character)
        -- Очистка старой подсветки при респавне
        local oldHighlight = character:FindFirstChild("SylentHardwareESP")
        if oldHighlight then oldHighlight:Destroy() end
        
        -- Фильтрация по команде (TeamCheck)
        if CONFIG.TeamCheck and player.Team == LocalPlayer.Team then return end
        
        -- Создание нативного силуэта, обрабатываемого видеочипом iPad
        local highlight = Instance.new("Highlight")
        highlight.Name = "SylentHardwareESP"
        highlight.FillColor = CONFIG.EnemyColor
        highlight.FillTransparency = CONFIG.FillTransparency
        highlight.OutlineColor = CONFIG.EnemyColor
        highlight.OutlineTransparency = CONFIG.OutlineTransparency
        highlight.Adornee = character
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop -- Видимость сквозь стены
        highlight.Parent = character
    end

    -- Запуск для текущего персонажа и подписка на будущие респавны
    if player.Character then CharacterAdded(player.Character) end
    local conn = player.CharacterAdded:Connect(CharacterAdded)
    Subscriptions[player] = conn
end

-- Очистка памяти при выходе игрока с сервера
local function RemoveHardwareESP(player)
    if Subscriptions[player] then
        Subscriptions[player]:Disconnect()
        Subscriptions[player] = nil
    end
end

-- Мониторинг списка игроков
for _, p in ipairs(Players:GetPlayers()) do ApplyHardwareESP(p) end
Players.PlayerAdded:Connect(ApplyHardwareESP)
Players.PlayerRemoving:Connect(RemoveHardwareESP)
