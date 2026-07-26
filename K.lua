-- Block Strike iPad | Delta iOS
-- Trigger Aim / Aim While Firing / Hold-to-Aim / On Fire Aim / Conditional Aim
-- Тип: Триггер Аим — активируется ТОЛЬКО при зажатии кнопки огня
-- Голый аим. Без функций. Без настроек. Без ВХ. Без меню.
-- Просто ебашит в голову при зажатии огня.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

local IsHoldingFire = false
local CurrentTarget = nil

-- Анти-отдача один раз при загрузке
task.wait(3)
for _, object in pairs(getgc()) do
    if typeof(object) == "table" then
        if typeof(object.Recoil) == "number" then object.Recoil = 0 end
        if typeof(object.Spread) == "number" then object.Spread = 0 end
        if typeof(object.MaxSpread) == "number" then object.MaxSpread = 0 end
        if typeof(object.MinSpread) == "number" then object.MinSpread = 0 end
        if typeof(object.Kick) == "number" then object.Kick = 0 end
        if typeof(object.KickUp) == "number" then object.KickUp = 0 end
        if typeof(object.KickSide) == "number" then object.KickSide = 0 end
        if typeof(object.Bloom) == "number" then object.Bloom = 0 end
        if typeof(object.Accuracy) == "number" then object.Accuracy = 0 end
        if typeof(object.RecoilX) == "number" then object.RecoilX = 0 end
        if typeof(object.RecoilY) == "number" then object.RecoilY = 0 end
        if typeof(object.CameraRecoil) == "number" then object.CameraRecoil = 0 end
        if typeof(object.CurrentRecoil) == "Vector3" then object.CurrentRecoil = Vector3.zero end
        if typeof(object.CurrentSpread) == "number" then object.CurrentSpread = 0 end
        if typeof(object.RecoilTimer) == "number" then object.RecoilTimer = 0 end
        if typeof(object.Recoil) == "Vector3" then object.Recoil = Vector3.zero end
        if typeof(object.Spread) == "Vector3" then object.Spread = Vector3.zero end
    end
end

-- Ввод: Trigger Aim — активируется только при зажатии огня
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        IsHoldingFire = true
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessedEvent)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        IsHoldingFire = false
        CurrentTarget = nil
    end
end)

-- Trigger Aim цикл: ищет цель и мгновенно наводится только пока зажат огонь
RunService.RenderStepped:Connect(function()
    if not IsHoldingFire then
        CurrentTarget = nil
        return
    end

    local centerX = Camera.ViewportSize.X / 2
    local centerY = Camera.ViewportSize.Y / 2
    local cameraPosition = Camera.CFrame.Position
    local bestTarget = nil
    local bestDistance = 999999

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if player.Team == LocalPlayer.Team then continue end

        local character = player.Character
        if not character then continue end

        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then continue end

        local head = character:FindFirstChild("Head")
        if not head then continue end

        local screenPosition = Camera:WorldToViewportPoint(head.Position)
        if screenPosition.Z <= 0 then continue end

        local distanceFromCenter = math.abs(screenPosition.X - centerX) + math.abs(screenPosition.Y - centerY)
        if distanceFromCenter > 250 then continue end

        local distance3D = (head.Position - cameraPosition).Magnitude
        if distance3D > 600 then continue end

        if distanceFromCenter < bestDistance then
            bestDistance = distanceFromCenter
            bestTarget = head
        end
    end

    CurrentTarget = bestTarget

    if CurrentTarget and CurrentTarget.Parent then
        local humanoidRootPart = CurrentTarget.Parent:FindFirstChild("HumanoidRootPart")
        local velocity = Vector3.zero
        if humanoidRootPart then
            velocity = humanoidRootPart.Velocity
        end
        local aimPosition = CurrentTarget.Position + (velocity * 0.12)
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, aimPosition)
    end
end)

-- Хук пуль
local rawMetatable = getrawmetatable(game)
setreadonly(rawMetatable, false)
local originalNamecall = rawMetatable.__namecall

rawMetatable.__namecall = newcclosure(function(self, ...)
    local methodName = getnamecallmethod()
    local arguments = {...}

    if methodName == "FireServer" then
        local remoteName = tostring(self):lower()
        if remoteName:find("shoot") or remoteName:find("fire") or remoteName:find("bullet") or remoteName:find("hit") or remoteName:find("damage") or remoteName:find("gun") or remoteName:find("weapon") then
            if IsHoldingFire and CurrentTarget and CurrentTarget.Parent then
                local humanoidRootPart = CurrentTarget.Parent:FindFirstChild("HumanoidRootPart")
                local velocity = Vector3.zero
                if humanoidRootPart then
                    velocity = humanoidRootPart.Velocity
                end
                local aimPosition = CurrentTarget.Position + (velocity * 0.12)
                for index, argument in ipairs(arguments) do
                    if typeof(argument) == "Vector3" then
                        arguments[index] = aimPosition
                        break
                    elseif typeof(argument) == "CFrame" then
                        arguments[index] = CFrame.new(aimPosition)
                        break
                    elseif typeof(argument) == "Ray" then
                        arguments[index] = Ray.new(Camera.CFrame.Position, (aimPosition - Camera.CFrame.Position).Unit * 1000)
                        break
                    end
                end
            end
        end
    end

    return originalNamecall(self, unpack(arguments))
end)

setreadonly(rawMetatable, true)

print("4080 | Trigger Aim / Aim While Firing загружен | Зажми огонь — ебашит в голову")
