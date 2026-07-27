-- file: ultra_opt_tw.lua
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local AimbotEnabled = true
local ESPEnabled = true
local FOVRadius = 150
local SnowEnabled = true

local GlobalTarget = nil
local VisibilityCache = {}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TW_UI_Ultra"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui

local TWButton = Instance.new("TextButton")
TWButton.Name = "TWButton"
TWButton.Size = UDim2.new(0, 50, 0, 50)
TWButton.Position = UDim2.new(0, 50, 0, 50)
TWButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
TWButton.BorderColor3 = Color3.fromRGB(255, 0, 0)
TWButton.BorderSizePixel = 2
TWButton.Text = "TW"
TWButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TWButton.Font = Enum.Font.Code
TWButton.TextSize = 20
TWButton.Active = true
TWButton.Draggable = true
TWButton.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(1, 0)
UICorner.Parent = TWButton

local MainMenu = Instance.new("Frame")
MainMenu.Name = "MainMenu"
MainMenu.Size = UDim2.new(0, 300, 0, 400)
MainMenu.Position = UDim2.new(0.5, -150, 0.5, -200)
MainMenu.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainMenu.BorderColor3 = Color3.fromRGB(255, 0, 0)
MainMenu.BorderSizePixel = 2
MainMenu.Visible = false
MainMenu.Active = true
MainMenu.Draggable = true
MainMenu.Parent = ScreenGui

local MenuTitle = Instance.new("TextLabel")
MenuTitle.Size = UDim2.new(1, 0, 0, 40)
MenuTitle.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MenuTitle.Text = "TW HUB | NO LAG"
MenuTitle.TextColor3 = Color3.fromRGB(255, 0, 0)
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
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.Code
    label.TextSize = 16
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.3, 0, 0.8, 0)
    btn.Position = UDim2.new(0.7, 0, 0.1, 0)
    btn.BackgroundColor3 = state and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    btn.Text = state and "ON" or "OFF"
    btn.TextColor3 = Color3.fromRGB(0, 0, 0)
    btn.Font = Enum.Font.Code
    btn.TextSize = 14
    btn.Parent = frame

    local function toggle()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        btn.Text = state and "ON" or "OFF"
        callback(state)
    end
    btn.MouseButton1Click:Connect(toggle)
    btn.TouchTap:Connect(toggle)
end

CreateToggle("Aimbot & No Recoil", 60, AimbotEnabled, function(s) AimbotEnabled = s end)
CreateToggle("ESP (Boxes, Info)", 110, ESPEnabled, function(s) ESPEnabled = s end)
CreateToggle("Snow Effect", 160, SnowEnabled, function(s) 
    SnowEnabled = s
    for _, flake in ipairs(ScreenGui:GetChildren()) do
        if flake.Name == "Snowflake" then
            flake.Visible = s
        end
    end
end)

TWButton.MouseButton1Click:Connect(function() MainMenu.Visible = not MainMenu.Visible end)
TWButton.TouchTap:Connect(function() MainMenu.Visible = not MainMenu.Visible end)

local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(255, 0, 0)
FOVCircle.Thickness = 1
FOVCircle.Filled = false
FOVCircle.Radius = FOVRadius
FOVCircle.Visible = true

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

local function AnimateSnowflake(flake)
    flake.Position = UDim2.new(math.random(), 0, -0.05, 0)
    local endPos = UDim2.new(math.random(), 0, 1.05, 0)
    local duration = math.random(4, 10)
    local tween = TweenService:Create(flake, TweenInfo.new(duration, Enum.EasingStyle.Linear), {Position = endPos})
    tween.Completed:Connect(function()
        if flake.Parent then AnimateSnowflake(flake) end
    end)
    tween:Play()
end

for i = 1, 25 do
    local flake = Instance.new("Frame")
    flake.Name = "Snowflake"
    flake.Size = UDim2.new(0, 3, 0, 3)
    flake.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    flake.BorderSizePixel = 0
    flake.Parent = ScreenGui
    AnimateSnowflake(flake)
end

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude
rayParams.IgnoreWater = true

task.spawn(function()
    while task.wait(0.1) do
        if not LocalPlayer.Character then continue end
        rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
        
        local origin = Camera.CFrame.Position
        local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        local shortestDist = FOVRadius
        local newTarget = nil

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local char = player.Character
                if char then
                    local head = char:FindFirstChild("Head")
                    local root = char:FindFirstChild("HumanoidRootPart")
                    local hum = char:FindFirstChild("Humanoid")
                    
                    if head and root and hum and hum.Health > 0 then
                        local dir = head.Position - origin
                        local result = Workspace:Raycast(origin, dir, rayParams)
                        local isVis = not result or result.Instance:IsDescendantOf(char)
                        VisibilityCache[player] = isVis

                        if isVis and AimbotEnabled then
                            local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                            if onScreen then
                                local dist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                                if dist < shortestDist then
                                    shortestDist = dist
                                    newTarget = head
                                end
                            end
                        end
                    else
                        VisibilityCache[player] = false
                    end
                else
                    VisibilityCache[player] = false
                end
            end
        end
        GlobalTarget = newTarget
    end
end)

RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FOVCircle.Visible = AimbotEnabled

    if AimbotEnabled and GlobalTarget then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, GlobalTarget.Position)
    end

    if not ESPEnabled then
        for _, esp in pairs(ESPCache) do
            esp.Box.Visible = false
            esp.Name.Visible = false
            esp.HealthBar.Visible = false
        end
        return
    end

    local cPos = Camera.CFrame.Position
    for player, esp in pairs(ESPCache) do
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
            local root = char.HumanoidRootPart
            local rootPos, onScreen = Camera:WorldToViewportPoint(root.Position)
            
            if onScreen then
                local dist = (root.Position - cPos).Magnitude
                local height = 4000 / dist
                local width = height / 1.5
                local isVis = VisibilityCache[player]
                local color = isVis and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)

                esp.Box.Size = Vector2.new(width, height)
                esp.Box.Position = Vector2.new(rootPos.X - width / 2, rootPos.Y - height / 2)
                esp.Box.Color = color
                esp.Box.Visible = true

                esp.Name.Text = player.Name
                esp.Name.Position = Vector2.new(rootPos.X, rootPos.Y - height / 2 - 16)
                esp.Name.Color = color
                esp.Name.Visible = true

                local hpPercent = char.Humanoid.Health / char.Humanoid.MaxHealth
                esp.HealthBar.From = Vector2.new(rootPos.X - width / 2 - 4, rootPos.Y + height / 2 - (height * hpPercent))
                esp.HealthBar.To = Vector2.new(rootPos.X - width / 2 - 4, rootPos.Y + height / 2)
                esp.HealthBar.Color = Color3.fromRGB(255 - (hpPercent * 255), hpPercent * 255, 0)
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
    end
end)

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    if not AimbotEnabled or checkcaller() then return oldNamecall(self, ...) end
    
    local method = getnamecallmethod()
    if GlobalTarget and (method == "Raycast" or method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList") then
        local args = {...}
        if method == "Raycast" then
            args[2] = (GlobalTarget.Position - args[1]).Unit * 1000
        else
            args[1] = Ray.new(args[1].Origin, (GlobalTarget.Position - args[1].Origin).Unit * 1000)
        end
        return oldNamecall(self, unpack(args))
    end
    
    return oldNamecall(self, ...)
end)

local oldIndex
oldIndex = hookmetamethod(game, "__index", function(t, k)
    if AimbotEnabled and not checkcaller() then
        local key = tostring(k):lower()
        if key:match("recoil") or key:match("spread") then
            return 0
        end
    end
    return oldIndex(t, k)
end)
