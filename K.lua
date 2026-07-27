--[[\
    Blox Strike Mobile Script - Delta (iPad Compatible)
    Monolithic and fully functional Lua script.
]]--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Clean up previous instances if any
if CoreGui:FindFirstChild("BloxStrikeHub") then
    CoreGui.BloxStrikeHub:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BloxStrikeHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local success, err = pcall(function()
    ScreenGui.Parent = CoreGui
end)
if not success then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- ==========================================
-- 1. FLOATING TOGGLE BUTTON ("TW")
-- ==========================================
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleTW"
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Position = UDim2.new(0, 20, 0.5, -25)
ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleButton.BorderColor3 = Color3.fromRGB(80, 80, 80)
ToggleButton.BorderSizePixel = 2
ToggleButton.Text = "TW"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 18
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Active = true
ToggleButton.Draggable = true
ToggleButton.Parent = ScreenGui

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 12)
ToggleCorner.Parent = ToggleButton

-- ==========================================
-- 2. INTERACTIVE MAIN MENU (Draggable Center)
-- ==========================================
local MainMenu = Instance.new("Frame")
MainMenu.Name = "MainMenu"
MainMenu.Size = UDim2.new(0, 340, 0, 260)
MainMenu.Position = UDim2.new(0.5, -170, 0.5, -130)
MainMenu.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainMenu.BorderColor3 = Color3.fromRGB(60, 60, 60)
MainMenu.BorderSizePixel = 2
MainMenu.Visible = false
MainMenu.Active = true
MainMenu.Draggable = true
MainMenu.Parent = ScreenGui

local MenuCorner = Instance.new("UICorner")
MenuCorner.CornerRadius = UDim.new(0, 8)
MenuCorner.Parent = MainMenu

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 0, 40)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "BLOX STRIKE - MOBILE HUB"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 16
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Parent = MainMenu

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 30)
StatusLabel.Position = UDim2.new(0, 10, 0, 50)
StatusLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
StatusLabel.TextSize = 14
StatusLabel.Font = Enum.Font.GothamMedium
StatusLabel.Text = "Status: All Systems Active"
StatusLabel.Parent = MainMenu

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 6)
StatusCorner.Parent = StatusLabel

local InfoDesc = Instance.new("TextLabel")
InfoDesc.Size = UDim2.new(1, -20, 0, 140)
InfoDesc.Position = UDim2.new(0, 10, 0, 95)
InfoDesc.BackgroundTransparency = 1
InfoDesc.Text = "Features Running:\n• FOV Circle (Center Fixed)\n• Advanced ESP (Boxes, Names, HP, Dynamic Vis)\n• Falling Snow Physics Engine\n\nUse 'TW' button to hide/show this menu."
InfoDesc.TextColor3 = Color3.fromRGB(180, 180, 180)
InfoDesc.TextSize = 13
InfoDesc.Font = Enum.Font.Gotham
InfoDesc.TextWrapped = true
InfoDesc.TextXAlignment = Enum.TextXAlignment.Left
InfoDesc.TextYAlignment = Enum.TextYAlignment.Top
InfoDesc.Parent = MainMenu

ToggleButton.MouseButton1Click:Connect(function()
    MainMenu.Visible = not MainMenu.Visible
end)

-- ==========================================
-- 3. FOV CIRCLE (Strictly Center Fixed)
-- ==========================================
local FOVRadius = 120

local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = true
FOVCircle.Radius = FOVRadius
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Thickness = 1.5
FOVCircle.Filled = false
FOVCircle.Transparency = 0.7

local function UpdateFOVCircle()
    local viewportSize = Camera.ViewportSize
    FOVCircle.Position = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
end

-- ==========================================
-- 4. ADVANCED ESP (Boxes, Names, HP, Vis Check)
-- ==========================================
local ESPStorage = {}

local function CreateESP(player)
    if ESPStorage[player] then return end
    
    local espData = {}
    
    espData.Box = Drawing.new("Square")
    espData.Box.Visible = false
    espData.Box.Thickness = 1.5
    espData.Box.Filled = false
    
    espData.Name = Drawing.new("Text")
    espData.Name.Visible = false
    espData.Name.Size = 14
    espData.Name.Center = true
    espData.Name.Outline = true
    espData.Name.Color = Color3.fromRGB(255, 255, 255)
    
    espData.HealthBar = Drawing.new("Line")
    espData.HealthBar.Visible = false
    espData.HealthBar.Thickness = 2.5
    
    ESPStorage[player] = espData
end

local function RemoveESP(player)
    if ESPStorage[player] then
        for _, obj in pairs(ESPStorage[player]) do
            pcall(function() obj:Remove() end)
        end
        ESPStorage[player] = nil
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        CreateESP(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        CreateESP(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    RemoveESP(player)
end)

local function IsVisible(targetPart)
    if not targetPart or not Camera then return false end
    local origin = Camera.CFrame.Position
    local direction = targetPart.Position - origin
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = RaycastType.Blacklist
    
    local ignoreList = {LocalPlayer.Character, Camera}
    if LocalPlayer.Character then
        table.insert(ignoreList, LocalPlayer.Character)
    end
    raycastParams.FilterDescendantsInstances = ignoreList
    
    local result = Workspace:Raycast(origin, direction, raycastParams)
    if not result then
        return true
    end
    if result.Instance:IsDescendantOf(targetPart.Parent) then
        return true
    end
    return false
end

local function UpdateESP()
    for player, esp in pairs(ESPStorage) do
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        local head = character and character:FindFirstChild("Head")
        
        if character and humanoid and rootPart and head and humanoid.Health > 0 then
            local vector, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
            
            if onScreen then
                local headVector = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                local legVector = Camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3, 0))
                
                local height = math.abs(headVector.Y - legVector.Y)
                local width = height / 2
                
                local boxPos = Vector2.new(vector.X - width / 2, headVector.Y)
                local boxSize = Vector2.new(width, height)
                
                -- Visibility color check
                local visible = IsVisible(head)
                local dynamicColor = visible and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
                
                -- Update Box
                esp.Box.Size = boxSize
                esp.Box.Position = boxPos
                esp.Box.Color = dynamicColor
                esp.Box.Visible = true
                
                -- Update Name & Health
                esp.Name.Text = player.Name
                esp.Name.Position = Vector2.new(vector.X, headVector.Y - 18)
                esp.Name.Visible = true
                
                -- Health Bar
                local healthPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
                local barHeight = height * healthPercent
                esp.HealthBar.From = Vector2.new(boxPos.X - 6, boxPos.Y + height)
                esp.HealthBar.To = Vector2.new(boxPos.X - 6, (boxPos.Y + height) - barHeight)
                esp.HealthBar.Color = Color3.fromRGB(0, 255, 0):Lerp(Color3.fromRGB(255, 0, 0), 1 - healthPercent)
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
end

-- ==========================================
-- 5. FALLING SNOW PHYSICS ENGINE
-- ==========================================
local SnowHolder = Instance.new("Folder")
SnowHolder.Name = "SnowParticlesFolder"
SnowHolder.Parent = ScreenGui

local SnowFlakes = {}
local MaxSnow = 45

for i = 1, MaxSnow do
    local flake = Instance.new("Frame")
    flake.Name = "Snow"
    local size = math.random(3, 6)
    flake.Size = UDim2.new(0, size, 0, size)
    flake.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    flake.BackgroundTransparency = math.random(20, 60) / 100
    flake.BorderSizePixel = 0
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = flake
    
    flake.Parent = SnowHolder
    
    table.insert(SnowFlakes, {
        Object = flake,
        X = math.random(0, 1000) / 1000,
        Y = math.random(0, 1000) / 1000,
        Speed = math.random(10, 30) / 10000,
        Size = size,
        Offset = math.random(0, 100)
    })
end

local function UpdateSnow(dt)
    local viewportSize = Camera.ViewportSize
    if viewportSize.X == 0 or viewportSize.Y == 0 then return end
    
    for _, flake in ipairs(SnowFlakes) do
        flake.Y = flake.Y + flake.Speed
        if flake.Y > 1.05 then
            flake.Y = -0.05
            flake.X = math.random(0, 1000) / 1000
        end
        
        local xPos = flake.X * viewportSize.X + math.sin(tick() * 2 + flake.Offset) * 15
        local yPos = flake.Y * viewportSize.Y
        
        flake.Object.Position = UDim2.new(0, xPos, 0, yPos)
    end
end

-- ==========================================
-- 6. INITIALIZATION & MAIN LOOP
-- ==========================================
RunService.RenderStepped:Connect(function(dt)
    UpdateFOVCircle()
    UpdateESP()
    UpdateSnow(dt)
end)
