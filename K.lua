--[[
    SYLENT AUTOMATION HUB V1
    Target: Brookhaven RP (Auto-Farm Quests & Ball Thrower)
    Status: Functional / Self-Contained
--]]

-- Защита от повторного запуска (Anti-MultiRun)
if _G.SylentFarmActivated then 
    _G.SylentFarmActivated = false
    print("[SYLENT] Скрипт деактивирован")
    return 
end

_G.SylentFarmActivated = true
print("[SYLENT] Активация авто-фермы...")

-- Инициализация основных сервисов Roblox
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- Проверка доступности персонажа
local function getCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

-- 1. СЕТЕВОЙ СПАМ ДЛЯ БРОСКОВ МЯЧА И КВЕСТОВ
-- Автоматический поиск Remote-событий, отвечающих за броски/квесты в ивентах
task.spawn(function()
    while _G.SylentFarmActivated do
        pcall(function()
            -- Универсальный поиск ивентовых эвентов (подстраивается под Brookhaven)
            for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
                if obj:IsA("RemoteEvent") then
                    -- Паттерны названий функций для бросков, балета и квестов
                    if string.find(string.lower(obj.Name), "ball") or 
                       string.find(string.lower(obj.Name), "throw") or 
                       string.find(string.lower(obj.Name), "quest") or
                       string.find(string.lower(obj.Name), "event") then
                        
                        -- Посылка пакета действия на сервер без задержки анимации
                        obj:FireServer(true)
                        obj:FireServer("Throw")
                        obj:FireServer("CompleteQuest")
                    end
                end
            end
        end)
        task.wait(0.05) -- Безопасный интервал для защиты от сетевого кика (Rate-Limit)
    end
end)

-- 2. ТЕЛЕПОРТАЦИЯ И СБОР ИВЕНТОВЫХ ПРЕДМЕТОВ (БАЛЕТНЫЕ БИЛЕТЫ/МЯЧИ)
task.spawn(function()
    while _G.SylentFarmActivated do
        pcall(function()
            local char = getCharacter()
            local root = char:FindFirstChild("HumanoidRootPart")
            
            if root then
                -- Поиск физических предметов квеста на карте (Workspace)
                for _, item in ipairs(workspace:GetDescendants()) do
                    if item:IsA("TouchTransmitter") and item.Parent then
                        local parent = item.Parent
                        -- Определение ивентовых сущностей
                        if string.find(string.lower(parent.Name), "ticket") or 
                           string.find(string.lower(parent.Name), "ball") or 
                           string.find(string.lower(parent.Name), "quest") then
                            
                            -- Мгновенное перемещение к предмету для симуляции сбора
                            root.CFrame = parent.CFrame
                            task.wait(0.1)
                        end
                    end
                end
            end
        end)
        task.wait(0.5)
    end
end)

-- 3. БЕЗУСЛОВНЫЙ INF-JUMP ДЛЯ СКОРОСТИ
local UserInputService = game:GetService("UserInputService")
UserInputService.JumpRequest:Connect(function()
    if _G.SylentFarmActivated then
        local char = getCharacter()
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

print("[SYLENT] Авто-фарм успешно запущен и работает в фоне.")
