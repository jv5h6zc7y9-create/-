--[[
    SYLENT AUTOMATION HUB V1
    Target: Brookhaven RP — "Взрыв шариков" (Auto-Pop & Auto-Restart)
    Status: Functional / Self-Contained
--]]

-- Защита от повторного запуска (Anti-MultiRun)
if _G.SylentBalloonPopper then 
    _G.SylentBalloonPopper = false
    print("[SYLENT] Авто-взрыв шариков деактивирован")
    return 
end

_G.SylentBalloonPopper = true
print("[SYLENT] Активация авто-фермы для игры 'Взрыв шариков'...")

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Функция имитации клика по объекту (через ClickDetector или симуляцию нажатия)
local function popTarget(object)
    if not object then return end
    
    -- Способ 1: Если на шарике есть ClickDetector
    local cd = object:FindFirstChildOfClass("ClickDetector")
    if cd then
        fireclickdetector(cd)
        return
    end
    
    -- Способ 2: Имитация клика через Raycast/Сетевой эвент (если используется универсальный триггер)
    local event = Workspace:FindFirstChild("BurstEvent") or game:GetService("ReplicatedStorage"):FindFirstChild("BalloonEvent")
    if event and event:IsA("RemoteEvent") then
        event:FireServer(object)
    end
end

-- Основной рабочий поток скрипта
task.spawn(function()
    while _G.SylentBalloonPopper do
        pcall(function()
            -- 1. СКАНИРОВАНИЕ И ЛОПАНИЕ ШАРИКОВ
            -- Ищем стенд "Взрыв шариков" в Workspace по характерным элементам
            for _, v in ipairs(Workspace:GetDescendants()) do
                if v:IsA("BasePart") or v:IsA("MeshPart") or v:IsA("ImageLabel") then
                    local name = string.lower(v.Name)
                    -- Ищем шарики по имени или текстуре
                    if string.find(name, "balloon") or string.find(name, "sharik") or v.Name == "Ball" then
                        -- Проверяем, что шарик виден на панели (не лопнут)
                        if v:IsA("BasePart") and v.Transparency < 1 then
                            popTarget(v)
                        elseif v:IsA("ImageLabel") and v.Visible == true then
                            -- Если это UI на экране/поверхности стенда
                            local guiButton = v:FindFirstAncestorOfClass("GuiButton") or v.Parent:IsA("GuiButton") and v.Parent
                            if guiButton then
                               -- Симулируем клик по UI-кнопке шарика
                               for _, connection in pairs(getconnections(guiButton.MouseButton1Click)) do
                                   connection:Fire()
                               end
                            end
                        end
                    end
                end
            end
            
            -- 2. АВТОМАТИЧЕСКИЙ ПЕРЕЗАПУСК (НАЧАЛО НОВОЙ ИГРЫ)
            -- Ищем кнопку старта/крестика/повтора, которая появляется на стенде или экране
            for _, btn in ipairs(Workspace:GetDescendants()) do
                if btn:IsA("ClickDetector") and (string.find(string.lower(btn.Parent.Name), "start") or string.find(string.lower(btn.Parent.Name), "play")) then
                    fireclickdetector(btn)
                end
            end
            
            -- Проверка UI-кнопок на экране LocalPlayer (если кнопка "Играть еще раз" появляется в GUI)
            if LocalPlayer:FindFirstChild("PlayerGui") then
                for _, guiElement in ipairs(LocalPlayer.PlayerGui:GetDescendants()) do
                    if guiElement:IsA("TextButton") or guiElement:IsA("ImageButton") then
                        local text = string.lower(guiElement.Name)
                        if string.find(text, "restart") or string.find(text, "again") or string.find(text, "play") then
                            if guiElement.AbsoluteSize.X > 0 and guiElement.Visible then
                                for _, connection in pairs(getconnections(guiElement.MouseButton1Click)) do
                                    connection:Fire()
                                end
                            end
                        end
                    end
                end
            end
            
        end)
        task.wait(0.05) -- Пауза между проверками для стабильности и исключения лагов
    end
end)

print("[SYLENT] Скрипт успешно запущен. Шарики будут лопаться, игра — перезапускаться.")
