-- file: optimized_tw.lua
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local math_abs = math.abs
local Vector2_new = Vector2.new
local Vector3_new = Vector3.new
local CFrame_new = CFrame.new
local Color3_fromRGB = Color3.fromRGB

local AimbotEnabled = true
local ESPEnabled = true
local FOVRadius = 150
local SnowEnabled = true

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TW_UI_Opt"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui

local TWButton = Instance.new("TextButton")
TWButton.Name = "TWButton"
TWButton.Size = UDim2.new(0, 50, 0, 50)
TWButton.Position = UDim2.new(0, 50, 0, 50)
TWButton.BackgroundColor3 = Color3_fromRGB(20, 20, 20)
TWButton.BorderColor3 = Color3_fromRGB(255, 0, 0)
TWButton.BorderSizePixel = 2
TWButton.Text = "TW"
TWButton.TextColor3 = Color3_fromRGB(255, 255, 255)
TWButton.Font = Enum.Font.Code
TWButton.TextSize = 20
TWButton.Parent = ScreenGui
TWButton.Active = true
TWButton.Draggable = true

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(1, 0)
UICorner.Parent = TWButton

local MainMenu = Instance.new("Frame")
MainMenu.Name = "MainMenu"
MainMenu.Size = UDim2.new(0, 300, 0, 400)
MainMenu.Position = UDim2.new(0.5, -150, 0.5, -200)
MainMenu.BackgroundColor3 = Color3_fromRGB(15, 15, 15)
MainMenu.BorderColor3 = Color3_fromRGB(255, 0, 0)
MainMenu.BorderSizePixel = 2
MainMenu.Visible = false
MainMenu.Active = true
MainMenu.Draggable = true
MainMenu.Parent = ScreenGui

local MenuTitle = Instance.new("TextLabel")
MenuTitle.Size = UDim2.new(1, 0, 0, 40)
MenuTitle.BackgroundColor3 = Color3_fromRGB(25, 25, 25)
MenuTitle.Text = "TW HUB | Opt"
MenuTitle.TextColor3 = Color3_fromRGB(255, 0, 0)
MenuTitle.Font = Enum.Font.Code
MenuTitle.TextSize = 18
MenuTitle.Parent = MainMenu

local function CreateToggle(name, yPos, state, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 40)
    frame.Position = UDim2.new(0, 10, 0, yPos)
    frame.BackgroundTransparency = 1
    frame.Parent = MainMenu

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3_fromRGB(255, 255, 255)
    label.Font = Enum.Font.Code
    label.TextSize = 16
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.3, 0, 0.8, 0)
    btn.Position = UDim2.new(0.7, 0, 0.1, 0)
    btn.BackgroundColor3 = state and Color3_fromRGB(0, 255, 0) or Color3_fromRGB(255, 0, 0)
    btn.Text = state and "ON" or "OFF"
    btn.TextColor3 = Color3_fromRGB(0, 0, 0)
    btn.Font = Enum.Font.Code
    btn.TextSize = 14
    btn.Parent = frame

    local function toggle()
        state = not state
        btn.BackgroundColor3 = state and Color3_fromRGB(0, 255, 0) or Color3_fromRGB(255, 0, 0)
        btn.Text = state and "ON" or "OFF"
        callback(state)
    end
    btn.MouseButton1Click:Connect(toggle)
    btn.TouchTap:Connect(toggle)
end

CreateToggle("Aimbot & No Recoil", 60, AimbotEnabled, function(s) AimbotEnabled = s end)
CreateToggle("ESP (Boxes, Info)", 110, ESPEnabled, function(s) ESPEnabled = s end)
CreateToggle("Snow Effect", 160, SnowEnabled, function(s) SnowEnabled = s end)

TWButton.MouseButton1Click:Connect(function() MainMenu.Visible = not MainMenu.Visible end)
TWButton.TouchTap:Connect(function() MainMenu.Visible = not MainMenu.Visible end)

local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3_fromRGB(255, 0, 0)
FOVCircle.Thickness = 1
FOVCircle.Filled = false
FOVCircle.Radius = FOVRadius
FOVCircle.Visible = true

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude
rayParams.IgnoreWater = true

local function IsVisible(targetPart)
    if not LocalPlayer.Character then return false end
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
    local origin = Camera.CFrame.Position
    local dir = targetPart.Position - origin
    local result = Workspace:Raycast(origin, dir, rayParams)
    return not result or result.Instance:IsDescendantOf(targetPart.Parent)
end

local function GetClosestTarget()
    local closestTarget = nil
    local shortestDist = FOVRadius
    local screenCenter = Vector2_new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            if char then
                local head = char:FindFirstChild("Head")
                local hum = char:FindFirstChild("Humanoid")
                if head and hum and hum.Health > 0 then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                    if onScreen then
                        local dist = (Vector2_new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                        if dist < shortestDist then
                            shortestDist = dist
                            closestTarget = head
                        end
                    end
                end
            end
        end
    end

    if closestTarget and IsVisible(closestTarget) then
        return closestTarget
    end
    return nil
end

local ESPCache = {}
local function CreateESP(player)
    local esp = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        HealthBar = Drawing.new("Line")
    }
    esp.Box.Thickness = 1
    esp.Box.Filled = false
    esp.Name.Size = 14
    esp.Name.Center = true
    esp.Name.Outline = true
    esp.HealthBar.Thickness = 2
    ESPCache[player] = esp
end

local function RemoveESP(player)
    if ESPCache[player] then
        for _, obj in pairs(ESPCache[player]) do obj:Remove() end
        ESPCache[player] = nil
    end
end

for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then CreateESP(p) end end
Players.PlayerAdded:Connect(function(p) if p ~= LocalPlayer then CreateESP(p) end end)
Players.PlayerRemoving:Connect(RemoveESP)

local Snowflakes = {}
for i = 1, 20 do
    local flake = Instance.new("Frame")
    flake.Size = UDim2.new(0, 3, 0, 3)
    flake.BackgroundColor3 = Color3_fromRGB(255, 255, 255)
    flake.BorderSizePixel = 0
    flake.Position = UDim2.new(math.random(), 0, math.random(), 0)
    flake.Parent = ScreenGui
    Snowflakes[i] = {
        Frame = flake,
        Speed = math.random(40, 100),
        Sway = math.random(-15, 15),
        X = math.random(),
        Y = math.random()
    }
end

RunService.RenderStepped:Connect(function(dt)
    local viewportSize = Camera.ViewportSize
    local screenCenter = Vector2_new(viewportSize.X / 2, viewportSize.Y / 2)
    FOVCircle.Position = screenCenter
    FOVCircle.Visible = AimbotEnabled

    if SnowEnabled then
        for i = 1, #Snowflakes do
            local sf = Snowflakes[i]
            sf.Frame.Visible = true
            sf.Y = sf.Y + (sf.Speed * dt) / viewportSize.Y
            sf.X = sf.X + (sf.Sway * dt) / viewportSize.X
            if sf.Y > 1 then
                sf.Y = -0.02
                sf.X = math.random()
            end
            sf.Frame.Position = UDim2.new(sf.X, 0, sf.Y, 0)
        end
    else
        for i = 1, #Snowflakes do Snowflakes[i].Frame.Visible = false end
    end

    local currentTarget = nil
    if AimbotEnabled then
        currentTarget = GetClosestTarget()
        if currentTarget then
            Camera.CFrame = CFrame_new(Camera.CFrame.Position, currentTarget.Position)
        end
    end

    if ESPEnabled then
        for player, esp in pairs(ESPCache) do
            local char = player.Character
            if char then
                local root = char:FindFirstChild("HumanoidRootPart")
                local head = char:FindFirstChild("Head")
                local hum = char:FindFirstChild("Humanoid")

                if root and head and hum and hum.Health > 0 then
                    local rootPos, onScreen = Camera:WorldToViewportPoint(root.Position)
                    if onScreen then
                        local headPos = Camera:WorldToViewportPoint(head.Position + Vector3_new(0, 0.5, 0))
                        local legPos = Camera:WorldToViewportPoint(root.Position - Vector3_new(0, 3, 0))
                        local height = math_abs(headPos.Y - legPos.Y)
                        local width = height / 1.5
                        local isVis = (currentTarget and currentTarget.Parent == char) or IsVisible(root)
                        local color = isVis and Color3_fromRGB(0, 255, 0) or Color3_fromRGB(255, 0, 0)

                        esp.Box.Size = Vector2_new(width, height)
                        esp.Box.Position = Vector2_new(rootPos.X - width / 2, headPos.Y)
                        esp.Box.Color = color
                        esp.Box.Visible = true

                        esp.Name.Text = player.Name
                        esp.Name.Position = Vector2_new(rootPos.X, headPos.Y - 16)
                        esp.Name.Color = color
                        esp.Name.Visible = true

                        local hpPercent = hum.Health / hum.MaxHealth
                        esp.HealthBar.From = Vector2_new(rootPos.X - width / 2 - 4, headPos.Y + height - (height * hpPercent))
                        esp.HealthBar.To = Vector2_new(rootPos.X - width / 2 - 4, headPos.Y + height)
                        esp.HealthBar.Color = Color3_fromRGB(255 - (hpPercent * 255), hpPercent * 255, 0)
                        esp.HealthBar.Visible = true
                    else
                        esp.Box.Visible = false
                        esp.Name.Visible = false
                        esp.HealthBar.Visible = false
                    end
                else
                    esp.Box.Visible = false
                    esp.Name.Visible = false
                    esp.HealthBar.Visible = false
                end
            else
                esp.Box.Visible = false
                esp.Name.Visible = false
                esp.HealthBar.Visible = false
            end
        end
    else
        for _, esp in pairs(ESPCache) do
            esp.Box.Visible = false
            esp.Name.Visible = false
            esp.HealthBar.Visible = false
        end
    end
end)

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    if AimbotEnabled and not checkcaller() then
        if method == "Raycast" or method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList" then
            local target = GetClosestTarget()
            if target then
                local args = {...}
                if method == "Raycast" then
                    args[2] = (target.Position - args[1]).Unit * 1000
                else
                    args[1] = Ray.new(args[1].Origin, (target.Position - args[1].Origin).Unit * 1000)
                end
                return oldNamecall(self, unpack(args))
            end
        end
        if tostring(self) == "Recoil" or tostring(self) == "Spread" or tostring(self) == "CameraShake" then
            return
        end
    end
    return oldNamecall(self, ...)
end)

local oldIndex
oldIndex = hookmetamethod(game, "__index", function(t, k)
    if AimbotEnabled and not checkcaller() and (tostring(k):lower():match("recoil") or tostring(k):lower():match("spread")) then
        return 0
    end
    return oldIndex(t, k)
end)
