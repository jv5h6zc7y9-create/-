-- // Сервисы
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- // Настройки
local SilentAim = {
    Enabled = true,
    TeamCheck = true,
    FOV = 150,
    ScanRate = 0.05 -- Как часто искать цель (0.05 сек = 20 раз в секунду вместо 60+ кадров)
}

-- // Глобальная переменная для хранения текущей цели
local CurrentTargetPart = nil

-- // Оптимизированная функция проверки видимости
local function IsVisible(character, part)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    -- Игнорируем только себя и цель, чтобы не тратить память на сборку огромных таблиц
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, character}
    
    local origin = Camera.CFrame.Position
    local direction = (part.Position - origin)
    local raycastResult = Workspace:Raycast(origin, direction, raycastParams)
    
    return raycastResult == nil
end

-- // Вынос поиска цели в отдельный, контролируемый цикл (Убирает лаги)
task.spawn(function()
    while task.wait(SilentAim.ScanRate) do
        if not SilentAim.Enabled then 
            CurrentTargetPart = nil 
            continue 
        end

        local bestTarget = nil
        local shortestDistance = SilentAim.FOV
        local mouseLocation = UserInputService:GetMouseLocation()
        local myTeam = LocalPlayer.Team

        -- Быстрый проход по игрокам
        for _, player in ipairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end
            if SilentAim.TeamCheck and player.Team == myTeam then continue end
            
            local character = player.Character
            if not character then continue end
            
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if not humanoid or humanoid.Health <= 0 then continue end
            
            local part = character:FindFirstChild("Head")
            if not part then continue end
            
            local screenPoint, onScreen = Camera:WorldToViewportPoint(part.Position)
            if not onScreen then continue end
            
            local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - mouseLocation).Magnitude
            if distance < shortestDistance then
                -- Проверяем стену ТОЛЬКО если игрок подошел по дистанции FOV (Экономит 90% ресурсов)
                if IsVisible(character, part) then
                    shortestDistance = distance
                    bestTarget = part
                end
            end
        end
        
        CurrentTargetPart = bestTarget
    end
end)

-- // Перехват выстрелов — теперь работает моментально, так как цель уже найдена
local oldNameCall
oldNameCall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    -- Если цель кэширована, просто подменяем вектор без вычислений
    if CurrentTargetPart and self == Workspace then
        if method == "Raycast" and args[1] and args[2] then
            local origin = args[1]
            local originalDirection = args[2]
            
            args[2] = (CurrentTargetPart.Position - origin).Unit * originalDirection.Magnitude
            return oldNameCall(self, unpack(args))
            
        elseif (method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList") and args[1] then
            local origin = args[1].Origin
            local originalDirection = args[1].Direction
            
            args[1] = Ray.new(origin, (CurrentTargetPart.Position - origin).Unit * originalDirection.Magnitude)
            return oldNameCall(self, unpack(args))
        end
    end

    return oldNameCall(self, ...)
end))
