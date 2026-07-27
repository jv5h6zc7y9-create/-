-- file: main.lua
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local AimbotEnabled = true
local ESPEnabled = true
local FOVRadius = 150
local SnowEnabled = true

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TW_UI"
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
MenuTitle.Text = "TW HUB | Blox Strike"
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

    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        btn.Text = state and "ON" or "OFF"
        callback(state)
    end)
    btn.TouchTap:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        btn.Text = state and "ON" or "OFF"
        callback(state)
    end)
end

CreateToggle("Aimbot & No Recoil", 60, AimbotEnabled, function(s) AimbotEnabled = s end)
CreateToggle("ESP (Boxes, Info)", 110, ESPEnabled, function(s) ESPEnabled = s end)
CreateToggle("Snow Effect", 160, SnowEnabled, function(s) SnowEnabled = s end)

TWButton.MouseButton1Click:Connect(function() MainMenu.Visible = not MainMenu.Visible end)
TWButton.TouchTap:Connect(function() MainMenu.Visible = not MainMenu.Visible end)

local Dragging, DragInput, DragStart, StartPos
local function UpdateDrag(input)
    local delta = input.Position - DragStart
    MainMenu.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + delta.X, StartPos.Y.Scale, StartPos.Y.Offset + delta.Y)
end
MainMenu.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        Dragging = true
        DragStart = input.Position
        StartPos = MainMenu.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                Dragging = false
            end
        end)
    end
end)
MainMenu.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        DragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == DragInput and Dragging then
        UpdateDrag(input)
    end
end)

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
        BoxOutline = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        HealthBar = Drawing.new("Line"),
        HealthBarOutline = Drawing.new("Line")
    }
    
    esp.Box.Thickness = 1
    esp.Box.Filled = false
    esp.BoxOutline.Thickness = 3
    esp.BoxOutline.Filled = false
    esp.BoxOutline.Color = Color3.fromRGB(0, 0, 0)
    
    esp.Name.Size = 16
    esp.Name.Center = true
    esp.Name.Outline = true
    
    esp.HealthBar.Thickness = 2
    esp.HealthBarOutline.Thickness = 4
    esp.HealthBarOutline.Color = Color3.fromRGB(0, 0, 0)
    
    ESPCache[player] = esp
end

local function RemoveESP(player)
    if ESPCache[player] then
        for _, obj in pairs(ESPCache[player]) do
            obj:Remove()
        end
        ESPCache[player] = nil
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then CreateESP(player) end
end
Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then CreateESP(player) end
end)
Players.PlayerRemoving:Connect(RemoveESP)

local function IsVisible(targetPart)
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("Head") then return false end
    local origin = Camera.CFrame.Position
    local dir = (targetPart.Position - origin).Unit * (targetPart.Position - origin).Magnitude
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {LocalPlayer.Character}
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.IgnoreWater = true
    local rayResult = Workspace:Raycast(origin, dir, params)
    return not rayResult or rayResult.Instance:IsDescendantOf(targetPart.Parent)
end

local Snowflakes = {}
for i = 1, 50 do
    local flake = Instance.new("Frame")
    flake.Size = UDim2.new(0, 4, 0, 4)
    flake.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    flake.BorderSizePixel = 0
    flake.Position = UDim2.new(math.random(), 0, math.random(), 0)
    flake.Parent = ScreenGui
    table.insert(Snowflakes, {
        Frame = flake,
        Speed = math.random(50, 150),
        Sway = math.random(-20, 20)
    })
end

local function GetClosestToScreenCenter()
    local closestTarget = nil
    local shortestDist = FOVRadius
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local head = player.Character.Head
            local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
            if onScreen then
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                if dist < shortestDist and IsVisible(head) then
                    shortestDist = dist
                    closestTarget = head
                end
            end
        end
    end
    return closestTarget
end

RunService.RenderStepped:Connect(function(dt)
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FOVCircle.Visible = AimbotEnabled

    if SnowEnabled then
        for _, data in ipairs(Snowflakes) do
            data.Frame.Visible = true
            local newY = data.Frame.Position.Y.Scale + (data.Speed * dt) / Camera.ViewportSize.Y
            local newX = data.Frame.Position.X.Scale + (data.Sway * dt) / Camera.ViewportSize.X
            if newY > 1 then
                newY = -0.05
                newX = math.random()
            end
            data.Frame.Position = UDim2.new(newX, 0, newY, 0)
        end
    else
        for _, data in ipairs(Snowflakes) do data.Frame.Visible = false end
    end

    if AimbotEnabled then
        local target = GetClosestToScreenCenter()
        if target then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
        end
    end

    for player, esp in pairs(ESPCache) do
        local character = player.Character
        if ESPEnabled and character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 then
            local root = character.HumanoidRootPart
            local head = character:FindFirstChild("Head")
            
            local rootPos, onScreen = Camera:WorldToViewportPoint(root.Position)
            local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
            local legPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
            
            if onScreen then
                local height = math.abs(headPos.Y - legPos.Y)
                local width = height / 1.5
                local isVis = IsVisible(root)
                local color = isVis and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)

                esp.BoxOutline.Size = Vector2.new(width, height)
                esp.BoxOutline.Position = Vector2.new(rootPos.X - width / 2, headPos.Y)
                esp.BoxOutline.Visible = true
                
                esp.Box.Size = Vector2.new(width, height)
                esp.Box.Position = Vector2.new(rootPos.X - width / 2, headPos.Y)
                esp.Box.Color = color
                esp.Box.Visible = true

                esp.Name.Text = player.Name .. " [" .. tostring(math.floor((root.Position - Camera.CFrame.Position).Magnitude)) .. "m]"
                esp.Name.Position = Vector2.new(rootPos.X, headPos.Y - 20)
                esp.Name.Color = color
                esp.Name.Visible = true

                local health = character.Humanoid.Health
                local maxHealth = character.Humanoid.MaxHealth
                local healthScale = health / maxHealth

                esp.HealthBarOutline.From = Vector2.new(rootPos.X - width / 2 - 6, headPos.Y - 1)
                esp.HealthBarOutline.To = Vector2.new(rootPos.X - width / 2 - 6, headPos.Y + height + 1)
                esp.HealthBarOutline.Visible = true

                esp.HealthBar.From = Vector2.new(rootPos.X - width / 2 - 6, headPos.Y + height - (height * healthScale))
                esp.HealthBar.To = Vector2.new(rootPos.X - width / 2 - 6, headPos.Y + height)
                esp.HealthBar.Color = Color3.fromRGB(255 - (healthScale * 255), healthScale * 255, 0)
                esp.HealthBar.Visible = true
            else
                for _, obj in pairs(esp) do obj.Visible = false end
            end
        else
            for _, obj in pairs(esp) do obj.Visible = false end
        end
    end
end)

local hook
hook = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if AimbotEnabled then
        if method == "Raycast" or method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList" then
            local target = GetClosestToScreenCenter()
            if target then
                local origin
                if method == "Raycast" then
                    origin = args[1]
                    args[2] = (target.Position - origin).Unit * 1000
                else
                    origin = args[1].Origin
                    args[1] = Ray.new(origin, (target.Position - origin).Unit * 1000)
                end
                return hook(self, unpack(args))
            end
        end
        
        if tostring(self) == "Recoil" or tostring(self) == "Spread" or tostring(self) == "CameraShake" then
            return
        end
    end

    return hook(self, ...)
end)

local idxHook
idxHook = hookmetamethod(game, "__index", function(t, k)
    if AimbotEnabled and (tostring(k):lower():match("recoil") or tostring(k):lower():match("spread") or tostring(k):lower():match("shake")) then
        return 0
    end
    return idxHook(t, k)
end)
