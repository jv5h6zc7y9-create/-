--[[
    SYLENT AUTOMATION HUB V1
    Target: Brookhaven RP (Dart Balloon Popper Only)
    Status: Functional / Self-Contained
--]]

-- Защита от повторного запуска (Anti-MultiRun)
if _G.SylentDartActivated then 
    _G.SylentDartActivated = false
    print("[SYLENT] Авто-дартс деактивирован")
    return 
end

_G.SylentDartActivated = true
print("[SYLENT] Активация авто-дартса (лопание шариков)...")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

-- Поиск сетевого эвента, отвечающего за дартс / броски
local DartRemote = nil
for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
    if obj:IsA("RemoteEvent") and (string.find(string.lower(obj.Name), "dart") or string.find(string.lower(obj.Name), "balloon")) then
        DartRemote = obj
        break
    end
end

-- Основной цикл автоматического лопания
task.spawn(function()
    while _G.SylentDartActivated do
        pcall(function()
            -- Перебор объектов в поиске шариков на игровой панели дартса
            for _, target in ipairs(Workspace:GetDescendants()) do
                if target:IsA("BasePart") or target:IsA("MeshPart") then
                    local name = string.lower(target.Name)
                    
                    -- Фильтр объектов: ищем только шары (Balloon / Target)
                    if string.find(name, "balloon") or string.find(name, "sharik") or string.find(name, "darttarget") then
                        
                        if DartRemote then
                            -- Вариант 1: Прямой вызов серверного эвента с передачей цели
                            DartRemote:FireServer(target, target.Position)
                        else
                            -- Вариант 2: Универсальный триггер клика/попадания, если эвент скрыт в самом объекте
                            local clickDetector = target:FindFirstChildOfClass("ClickDetector")
                            if clickDetector then
                                fireclickdetector(clickDetector)
                            end
                        end
                        
                    end
                end
            end
        end)
        task.wait(0.01) -- Минимальная задержка для моментального уничтожения целей
    end
end)

print("[SYLENT] Скрипт запущен. Ожидание появления шариков...")
