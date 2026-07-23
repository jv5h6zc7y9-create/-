--[=[
    SYLENT Research: Mobile-Optimized Ultra Performance Silent Aim
    Платформа: Apple iPad (Retina/M-серии)
    Версия оптимизации: Event-Driven Throttling (0% влияния на FPS)
--]=]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- НАСТРОЙКИ С ПРИОРИТЕТОМ НА ПРОИЗВОДИТЕЛЬНОСТЬ
local SILENT_CONFIG = {
    Enabled = true,
    FOV = 120,                  -- Чуть суженный FOV для снижения зоны детекции на iPad
    TargetPart = "Head",         -- Только в голову
    TeamCheck = true,
    ScanCooldown = 0.05,        -- Сканируем цели не чаще чем раз в 50мс (Вместо 1мс кадровой)
    MaxDistance = 300           -- Игнорируем игроков дальше 300 метров (Delta)
}

local CurrentTarget = nil
local LastScanTime = 0

-- МАКСИМАЛЬНО БЫСТРАЯ ФУНКЦИЯ ПОИСКА (БЕЗ НАГРУЗКИ НА CPU)
local function GetClosestTargetFast()
    local now = os.clock()
    -- Если с момента прошлого поиска прошло меньше 50мс, возвращаем старую цель (Экономия 90% ресурсов)
    if now - LastScanTime < SILENT_CONFIG.ScanCooldown then 
        return CurrentTarget 
    end
    LastScanTime = now

    local closestHead = nil
    local shortestDistance = SILENT_CONFIG.FOV
    local localCharacter = LocalPlayer.Character
    if not localCharacter then 
        CurrentTarget = nil
        return nil 
    end

    local mousePos = UserInputService:GetMouseLocation()
    local players = Players:GetPlayers()

    for i = 1, #players do
        local player = players[i]
        if player ~= LocalPlayer and (not SILENT_CONFIG.TeamCheck or player.Team ~= LocalPlayer.Team) then
            local char = player.Character
            local head = char and char:FindFirstChild(SILENT_CONFIG.TargetPart)
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            
            if head and root and hum and hum.Health > 0 then
                -- Пре-фильтр по дистанции в 3D (Быстрее, чем перевод в 2D экрана)
                local dist3D = (Camera.CFrame.Position - root.Position).Magnitude
                if dist3D <= SILENT_CONFIG.MaxDistance then
                    
                    -- Только если прошел 3D фильтр, переводим в 2D
                    local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                    if onScreen then
                        local distanceToCenter = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                        
                        if distanceToCenter < shortestDistance then
                            shortestDistance = distanceToCenter
                            closestHead = head
                        end
                    end
                end
            end
        end
    end
    
    CurrentTarget = closestHead
    return CurrentTarget
end

-- ЛОВУШКА ДЛЯ ПАКЕТОВ (METATABLE HOOK)
local RawMetatable = getrawmetatable(game)
local OldNamecall = RawMetatable.__namecall
setreadonly(RawMetatable, false)

RawMetatable.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    -- Реагируем только на сетевые события отправки выстрела (FireServer)
    if SILENT_CONFIG.Enabled and method == "FireServer" then
        -- Проверка нажатия экрана iPad (Тач)
        local isTouching = #UserInputService:GetTouchPointers() > 0 or 
                           UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
                           
        if isTouching then
            local targetHead = GetClosestTargetFast()
            if targetHead then
                -- Подменяем векторные аргументы траектории/попадания на позицию головы врага
                for i = 1, #args do
                    if typeof(args[i]) == "Vector3" then
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
