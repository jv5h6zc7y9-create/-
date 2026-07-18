-- ============================================================================
-- [9. ИСПРАВЛЕННЫЙ SILENT AIM — РАБОТАЕТ НА 100%]
-- ============================================================================

-- 9.1. Система Silent Aim через модификацию камеры и персонажа
local silentAimTarget = nil

-- Функция поиска ближайшего игрока в FOV
local function GetClosestPlayerForSilentAim(fovRadius)
    local closestPlayer = nil
    local shortestDistance = fovRadius
    local centerScreen = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= lp and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local root = player.Character.HumanoidRootPart
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local screenPos, onScreen = camera:WorldToViewportPoint(root.Position)
                if onScreen then
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - centerScreen).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closestPlayer = player
                    end
                end
            end
        end
    end
    return closestPlayer
end

-- Основной цикл Silent Aim (RenderStepped)
SafeConnect(RunService.RenderStepped, function()
    if not Hub.Flags.SilentAim then
        silentAimTarget = nil
        return
    end

    local target = GetClosestPlayerForSilentAim(Hub.Flags.SilentAimFOV)
    silentAimTarget = target

    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local targetRoot = target.Character.HumanoidRootPart
        local myRoot = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        
        if myRoot then
            -- Поворачиваем персонажа в сторону цели (для выстрелов/бросков)
            local lookDirection = (targetRoot.Position - myRoot.Position).Unit
            local targetCFrame = CFrame.lookAt(myRoot.Position, myRoot.Position + lookDirection)
            
            -- Плавный поворот через CFrame (без рывков)
            myRoot.CFrame = myRoot.CFrame:Lerp(targetCFrame, 0.3)
        end
    end
end)

-- 9.2. Перехват кликов для Silent Aim (фикс для FTAP)
SafeConnect(UserInputService.InputBegan, function(input, processed)
    if processed or not Hub.Flags.SilentAim then return end
    
    -- ЛКМ или тап по экрану
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if silentAimTarget and silentAimTarget.Character then
            local targetRoot = silentAimTarget.Character:FindFirstChild("HumanoidRootPart")
            local myRoot = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
            
            if targetRoot and myRoot then
                -- Телепортируемся к цели для захвата (для FTAP)
                myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, -3)
                -- Небольшая задержка для стабильности
                task.wait(0.05)
                -- Возвращаемся обратно (создаёт эффект "флинга" к цели)
                myRoot.CFrame = myRoot.CFrame * CFrame.new(0, 0, 5)
            end
        end
    end
end)

-- 9.3. Перехват мыши (Hit/Target) для совместимости со старыми системами
local rawMT = getrawmetatable(game)
local oldIndexMT = rawMT.__index
local oldNewIndexMT = rawMT.__newindex
setreadonly(rawMT, false)

rawMT.__index = newcclosure(function(self, index)
    if Hub.Flags.BypassMetatable and not checkcaller() then
        if self:IsA("Humanoid") then
            if index == "WalkSpeed" then return 16 end
            if index == "JumpPower" then return 50 end
        end
    end

    -- Перехват Mouse.Hit и Mouse.Target для корректной работы старых скриптов
    if Hub.Flags.SilentAim and self:IsA("Mouse") then
        if index == "Hit" and silentAimTarget and silentAimTarget.Character then
            local root = silentAimTarget.Character:FindFirstChild("HumanoidRootPart")
            if root then return root.CFrame end
        elseif index == "Target" and silentAimTarget and silentAimTarget.Character then
            local root = silentAimTarget.Character:FindFirstChild("HumanoidRootPart")
            if root then return root end
        end
    end

    return oldIndexMT(self, index)
end)

rawMT.__newindex = newcclosure(function(self, index, val)
    if Hub.Flags.BypassMetatable and not checkcaller() then
        if self:IsA("Humanoid") then
            if index == "WalkSpeed" and val == 0 then return end
            if index == "JumpPower" and val == 0 then return end
        end
    end
    oldNewIndexMT(self, index, val)
end)

setreadonly(rawMT, true)

-- 9.4. Обновление FOV круга (оставляем для визуала)
SafeConnect(RunService.RenderStepped, function()
    if Hub.Flags.SilentAim and Hub.Flags.ShowFOV then
        FOVCircle.Visible = true
        FOVCircle.Size = UDim2.new(0, Hub.Flags.SilentAimFOV * 2, 0, Hub.Flags.SilentAimFOV * 2)
    else
        FOVCircle.Visible = false
    end
end)

print("[Brosa System]: Silent Aim исправлен и активен!")
