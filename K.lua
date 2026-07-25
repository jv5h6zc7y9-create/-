-- // Сервисы
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- // Настройки
getgenv().SilentAim = {
    Enabled = true,
    HeadOnly = true,    -- Всегда целиться в голову
    TeamCheck = true,   -- Не стрелять по союзникам
    NoSpread = true     -- Убрать разброс пуль
}

-- // Функция поиска ближайшей цели для Silent Aim
local function GetTarget()
    local target = nil
    local shortestDistance = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if not SilentAim.TeamCheck or player.Team ~= LocalPlayer.Team then
                local character = player.Character
                if character and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 then
                    local part = character:FindFirstChild("Head") -- Всегда выбираем голову
                    if part then
                        local screenPoint, onScreen = Camera:WorldToViewportPoint(part.Position)
                        local mouseLocation = game:GetService("UserInputService"):GetMouseLocation()
                        local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - mouseLocation).Magnitude

                        if distance < shortestDistance then
                            shortestDistance = distance
                            target = part
                        end
                    end
                end
            end
        end
    end
    return target
end

-- // Перехват выстрелов (No Spread + Silent Aim через HookMetaMethod)
local oldNameCall
oldNameCall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    -- Проверяем вызовы отправки лучей (Raycast) или сетевых событий выстрела
    if SilentAim.Enabled and (method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList" or method == "Raycast") then
        local targetPart = GetTarget()
        if targetPart then
            if method == "FindPartOnRay" then
                -- Меняем направление луча прямо на голову врага (убираем разброс)
                local origin = args[1].Origin
                args[1] = Ray.new(origin, (targetPart.Position - origin).Unit * 1000)
            elseif method == "Raycast" then
                local origin = args[1]
                args[2] = (targetPart.Position - origin).Unit * 1000
            end
        end
    end

    return oldNameCall(self, unpack(args))
end)

-- // Дополнительный метод для игр с кастомным оружием (изменение вектора пули)
local mt = getrawmetatable(game)
setreadonly(mt, false)
local oldIndex = mt.__index

mt.__index = newcclosure(function(self, k)
    if SilentAim.NoSpread and k == "Spread" or k == "Recoil" then
        return 0 -- Принудительно обнуляем разброс и отдачу у оружия
    end
    return oldIndex(self, k)
end)
setreadonly(mt, true)
