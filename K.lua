--[=[
    SYLENT Research: Optimized Silent Aim & Performance Weapon Script
    Платформа: iPad / Mobile / PC Executor (Level 7)
    Оптимизация: Событийный триггер (вычисления только при стрельбе)
--]=]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- РАСШИРЕННЫЙ КОНФИГ
local CONFIG = {
    SilentAimEnabled = true,
    SilentAimFOV = 150,          -- Радиус захвата цели в пикселях
    TargetPart = "Head",         -- Строго в голову
    TeamCheck = true,            -- Игнорировать тиммейтов
    MaxTargetsPerScan = 3,       -- Лимит обработки игроков за один проход для iPad
}

-- Вспомогательная функция поиска ближайшей головы в FOV (Оптимизированная)
local function GetClosestEnemyHead()
    local closestTarget = nil
    local shortestDistance = CONFIG.SilentAimFOV
    local localCharacter = LocalPlayer.Character
    if not localCharacter then return nil end

    local playersList = Players:GetPlayers()
    local scanned = 0

    for i = 1, #playersList do
        -- Лимитируем количество проверок за кадр во избежание микрофризов на мобильных CPU
        if scanned >= CONFIG.MaxTargetsPerScan then break end
        
        local player = playersList[i]
        if player ~= LocalPlayer and (not CONFIG.TeamCheck or player.Team ~= LocalPlayer.Team) then
            local char = player.Character
            local head = char and char:FindFirstChild(CONFIG.TargetPart)
            local humanoid = char and char:FindFirstChildOfClass("Humanoid")
            
            if head and humanoid and humanoid.Health > 0 then
                scanned = scanned + 1
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                
                if onScreen then
                    -- Расстояние от центра экрана (прицела) до головы врага
                    local mousePos = UserInputService:GetMouseLocation()
                    local distanceToCenter = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    
                    if distanceToCenter < shortestDistance then
                        shortestDistance = distanceToCenter
                        closestTarget = head
                    end
                end
            end
        end
    end
    
    return closestTarget
end

-- Перехват сетевых событий выстрела (Универсальный хук под большинство движков в Roblox)
local RawMetatable = getrawmetatable(game)
local OldNamecall = RawMetatable.__namecall
setreadonly(RawMetatable, false)

RawMetatable.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    -- Активация хука только если вызван удаленный выстрел (FireServer)
    if CONFIG.SilentAimEnabled and method == "FireServer" then
        -- Проверяем, что игрок действительно совершает действие атаки/выстрела
        local isShooting = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or 
                           #UserInputService:GetTouchPointers() > 0 -- Поддержка тач-скрина iPad
                           
        if isShooting then
            local targetHead = GetClosestEnemyHead()
            if targetHead then
                -- Динамический перехват аргументов вектора направления пули/позиции попадания
                -- Сканируем аргументы на наличие Vector3 структур, отправляемых серверу
                for i, arg in ipairs(args) do
                    if typeof(arg) == "Vector3" then
                        -- Подменяем траекторию: пуля летит строго в позицию головы
                        args[i] = targetHead.Position
                    end
                end
                return OldNamecall(self, unpack(args))
            end
        end
    end
    
    return OldNamecall(self, ...)
end)

setreadonly(RawMetatable, true)

-- ПРИНУДИТЕЛЬНОЕ ОБНУЛЕНИЕ ОТДАЧИ И РАЗБРОСА ДЛЯ ВСЕХ ПУШЕК В ИНВЕНТАРЕ И ПЕРСОНАЖЕ
local function StripRecoilAndSpread(tool)
    if not tool:IsA("Tool") then return end
    
    -- Память под стандартные и кастомные переменные разброса
    local Properties = {
        "Recoil", "Spread", "Inaccuracy", "Kickback", "MaxSpread", "MinSpread",
        "VisualRecoil", "Sway", "AccuracyDecrease", "CrosshairExpand"
    }
    
    -- Метод 1: Прямые атрибуты движка
    for _, prop in ipairs(Properties) do
        if tool:GetAttribute(prop) then tool:SetAttribute(prop, 0) end
        pcall(function() tool[prop] = 0 end)
    end
    
    -- Метод 2: Модули конфигурации внутри пушки
    for _, child in ipairs(tool:GetDescendants()) do
        if child:IsA("ModuleScript") then
            local success, mod = pcall(require, child)
            if success and type(mod) == "table" then
                for key, val in pairs(mod) do
                    if type(val) == "number" then
                        local lKey = key:lower()
                        if lKey:find("recoil") or lKey:find("spread") or lKey:find("inacc") or lKey:find("kick") or lKey:find("sway") then
                            mod[key] = 0
                        end
                    end
                end
            end
        end
    end
end

-- Мониторинг экипировки
local function SetupCharacter(char)
    char.ChildAdded:Connect(StripRecoilAndSpread)
    for _, child in ipairs(char:GetChildren()) do StripRecoilAndSpread(child) end
end

LocalPlayer.CharacterAdded:Connect(SetupCharacter)
if LocalPlayer.Character then SetupCharacter(LocalPlayer.Character) end

-- Сканирование инвентаря (Backpack) для превентивного удаления отдачи
LocalPlayer.Backpack.ChildAdded:Connect(StripRecoilAndSpread)
for _, item in ipairs(LocalPlayer.Backpack:GetChildren()) do StripRecoilAndSpread(item) end
