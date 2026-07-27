-- file: zero_lag_silent.lua
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local FOVRadius = 150
local SilentAimEnabled = true

local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(255, 0, 0)
FOVCircle.Thickness = 1
FOVCircle.Filled = false
FOVCircle.Radius = FOVRadius
FOVCircle.Visible = true

-- Оставляем в рендере ТОЛЬКО отрисовку круга, никакой логики поиска
RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
end)

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude
rayParams.IgnoreWater = true

local CachedTarget = nil
local LastTargetTick = 0

local function GetTargetOnShoot()
    -- Кэшируем цель на 0.1 секунды, чтобы при спрее из автомата не было микрофризов
    if tick() - LastTargetTick < 0.1 and CachedTarget and CachedTarget.Parent and CachedTarget.Parent:FindFirstChild("Humanoid") and CachedTarget.Parent.Humanoid.Health > 0 then
        return CachedTarget
    end

    local closestTarget = nil
    local shortestDist = FOVRadius
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local origin = Camera.CFrame.Position
    
    if LocalPlayer.Character then
        rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            if char then
                local head = char:FindFirstChild("Head")
                local hum = char:FindFirstChild("Humanoid")
                
                if head and hum and hum.Health > 0 then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                    
                    if onScreen then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                        if dist < shortestDist then
                            -- Проверяем видимость ТОЛЬКО для тех, кто в кругу и ближе всех
                            local dir = head.Position - origin
                            local result = Workspace:Raycast(origin, dir, rayParams)
                            
                            if not result or result.Instance:IsDescendantOf(char) then
                                shortestDist = dist
                                closestTarget = head
                            end
                        end
                    end
                end
            end
        end
    end
    
    CachedTarget = closestTarget
    LastTargetTick = tick()
    
    return closestTarget
end

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    if not SilentAimEnabled or checkcaller() then 
        return oldNamecall(self, ...) 
    end

    local method = getnamecallmethod()
    
    -- Вычисляем координаты врага ТОЛЬКО в момент фактического выстрела
    if method == "Raycast" or method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList" then
        local target = GetTargetOnShoot()
        
        if target then
            local args = {...}
            if method == "Raycast" then
                local origin = args[1]
                args[2] = (target.Position - origin).Unit * 1000
            else
                local origin = args[1].Origin
                args[1] = Ray.new(origin, (target.Position - origin).Unit * 1000)
            end
            return oldNamecall(self, unpack(args))
        end
    end
    
    -- Мгновенно подавляем отдачу без сложных вычислений
    if method == "Recoil" or method == "Spread" or method == "CameraShake" then
        return
    end

    return oldNamecall(self, ...)
end)

local oldIndex
oldIndex = hookmetamethod(game, "__index", function(t, k)
    if SilentAimEnabled and not checkcaller() then
        local key = tostring(k):lower()
        if key:match("recoil") or key:match("spread") then
            return 0
        end
    end
    return oldIndex(t, k)
end)
