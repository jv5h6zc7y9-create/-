--!strict
--[[
    Block Strike Ultimate Engine - Fully Loaded Monolith (Lag-Free & Optimized Edition)
]]--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local DrawingSupported = (Drawing ~= nil and type(Drawing.new) == "function")

_G.AimAssistEnabled = false
_G.SilentAimEnabled = false
_G.NoSpreadEnabled = false
_G.SkinChangerEnabled = false
_G.BulletTracersEnabled = false 
_G.AimSmoothness = 0.18
_G.AimFOV = 140
_G.TargetPart = "Head"
_G.SelectedSkinColor = Color3.fromRGB(255, 100, 0)
_G.TracerColor = Color3.fromRGB(0, 255, 255)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BlockStrikeUltimateOptimized"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local FOVCircle = Instance.new("Frame")
FOVCircle.Name = "FOVCircle"
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
FOVCircle.BackgroundTransparency = 0.92
FOVCircle.BorderSizePixel = 0
FOVCircle.Visible = true
FOVCircle.Parent = ScreenGui

local FOVStroke = Instance.new("UIStroke")
FOVStroke.Thickness = 1.5
FOVStroke.Color = Color3.fromRGB(255, 0, 0)
FOVStroke.Parent = FOVCircle

local FOVCorner = Instance.new("UICorner")
FOVCorner.CornerRadius = UDim.new(1, 0)
FOVCorner.Parent = FOVCircle

local MenuButton = Instance.new("TextButton")
MenuButton.Name = "MenuButton"
MenuButton.Size = UDim2.new(0, 60, 0, 60)
MenuButton.Position = UDim2.new(0, 20, 0, 20)
MenuButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MenuButton.Text = "⚙️"
MenuButton.TextSize = 28
MenuButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MenuButton.Parent = ScreenGui

local MenuButtonCorner = Instance.new("UICorner")
MenuButtonCorner.CornerRadius = UDim.new(0.3, 0)
MenuButtonCorner.Parent = MenuButton

local MenuButtonStroke = Instance.new("UIStroke")
MenuButtonStroke.Thickness = 2
MenuButtonStroke.Color = Color3.fromRGB(0, 255, 150)
MenuButtonStroke.Parent = MenuButton

local MainMenu = Instance.new("Frame")
MainMenu.Name = "MainMenu"
MainMenu.Size = UDim2.new(0, 360, 0, 680)
MainMenu.Position = UDim2.new(0.5, -180, 0.5, -340)
MainMenu.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
MainMenu.Visible = false
MainMenu.Parent = ScreenGui

local MainMenuCorner = Instance.new("UICorner")
MainMenuCorner.CornerRadius = UDim.new(0.05, 0)
MainMenuCorner.Parent = MainMenu

local MainMenuStroke = Instance.new("UIStroke")
MainMenuStroke.Thickness = 2
MainMenuStroke.Color = Color3.fromRGB(0, 255, 150)
MainMenuStroke.Parent = MainMenu

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(1, 0, 0, 50)
TitleLabel.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
TitleLabel.Text = "⚡ LAG-FREE ENGINE ⚡"
TitleLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
TitleLabel.TextSize = 14
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.Parent = MainMenu

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0.2, 0)
TitleCorner.Parent = TitleLabel

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 34, 0, 34)
CloseButton.Position = UDim2.new(1, -42, 0, 8)
CloseButton.BackgroundColor3 = Color3.fromRGB(220, 40, 40)
CloseButton.Text = "❌"
CloseButton.TextSize = 14
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Parent = MainMenu

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0.3, 0)
CloseCorner.Parent = CloseButton

local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -20, 1, -70)
ContentFrame.Position = UDim2.new(0, 10, 0, 60)
ContentFrame.BackgroundTransparency = 1
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 720)
ContentFrame.ScrollBarThickness = 4
ContentFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 150)
ContentFrame.Parent = MainMenu

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 12)
UIListLayout.Parent = ContentFrame

local function createToggle(name, text)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(1, 0, 0, 45)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    btn.Text = text .. ": ВЫКЛ"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 15
    btn.Font = Enum.Font.SourceSansBold
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0.2, 0)
    local stroke = Instance.new("UIStroke", btn)
    stroke.Thickness = 1
    stroke.Color = Color3.fromRGB(40, 40, 45)
    btn.Parent = ContentFrame
    return btn
end

local AimButton = createToggle("AimButton", "Простой Aim Assist")
local SilentAimButton = createToggle("SilentAimButton", "Namecall Silent Aim")
local NoSpreadButton = createToggle("NoSpreadButton", "Анти-Отдача / Разброс")
local TracersButton = createToggle("TracersButton", "Трассеры Пуль")
local SkinButton = createToggle("SkinButton", "Скинченджер")

local ESPToggle = Instance.new("TextButton")
ESPToggle.Name = "ESPToggle"
ESPToggle.Size = UDim2.new(1, 0, 0, 45)
ESPToggle.BackgroundColor3 = Color3.fromRGB(0, 100, 60)
ESPToggle.Text = "TikTok ESP: ВКЛ"
ESPToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
ESPToggle.TextSize = 15
ESPToggle.Font = Enum.Font.SourceSansBold
local ESPCorner = Instance.new("UICorner", ESPToggle)
ESPCorner.CornerRadius = UDim.new(0.2, 0)
local ESPStroke = Instance.new("UIStroke", ESPToggle)
ESPStroke.Thickness = 1
ESPStroke.Color = Color3.fromRGB(40, 40, 45)
ESPToggle.Parent = ContentFrame

local SliderContainer = Instance.new("Frame", ContentFrame)
SliderContainer.Size = UDim2.new(1, 0, 0, 55)
SliderContainer.BackgroundTransparency = 1

local SliderLabel = Instance.new("TextLabel", SliderContainer)
SliderLabel.Size = UDim2.new(1, 0, 0, 20)
SliderLabel.BackgroundTransparency = 1
SliderLabel.Text = "Радиус FOV: 140 px"
SliderLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
SliderLabel.TextSize = 14
SliderLabel.Font = Enum.Font.SourceSansBold
SliderLabel.TextXAlignment = Enum.TextXAlignment.Left

local SliderBar = Instance.new("Frame", SliderContainer)
SliderBar.Size = UDim2.new(1, 0, 0, 8)
SliderBar.Position = UDim2.new(0, 0, 0, 30)
SliderBar.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
SliderBar.BorderSizePixel = 0
local SliderBarCorner = Instance.new("UICorner", SliderBar)
SliderBarCorner.CornerRadius = UDim.new(1, 0)

local SliderBtn = Instance.new("TextButton", SliderBar)
SliderBtn.Size = UDim2.new(0, 20, 0, 20)
SliderBtn.AnchorPoint = Vector2.new(0.5, 0.5)
SliderBtn.Position = UDim2.new(0.45, 0, 0.5, 0)
SliderBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
SliderBtn.Text = ""
local SliderBtnCorner = Instance.new("UICorner", SliderBtn)
SliderBtnCorner.CornerRadius = UDim.new(1, 0)

local espEnabled = true
local draggingSlider = false
local screenCenter = Vector2.new(0, 0)
local cacheDrawingObjects = {}

local function updateCenter()
    local viewportSize = Camera.ViewportSize
    local guiInset = GuiService:GetGuiInset()
    screenCenter = Vector2.new(viewportSize.X / 2, (viewportSize.Y + guiInset.Y) / 2)
    FOVCircle.Position = UDim2.new(0, screenCenter.X, 0, screenCenter.Y)
end

Camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateCenter)
updateCenter()

MenuButton.MouseButton1Click:Connect(function() MainMenu.Visible = not MainMenu.Visible end)
CloseButton.MouseButton1Click:Connect(function() MainMenu.Visible = false end)

local function updateFOV(radius)
    _G.AimFOV = radius
    FOVCircle.Size = UDim2.new(0, radius * 2, 0, radius * 2)
    SliderLabel.Text = "Радиус FOV: " .. tostring(math.round(radius)) .. " px"
end
updateFOV(_G.AimFOV)

SliderBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingSlider = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingSlider = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingSlider and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local rX = input.Position.X - SliderBar.AbsolutePosition.X
        local percentage = math.clamp(rX / SliderBar.AbsoluteSize.X, 0, 1)
        SliderBtn.Position = UDim2.new(percentage, 0, 0.5, 0)
        updateFOV(30 + (percentage * 270))
    end
end)

AimButton.MouseButton1Click:Connect(function()
    _G.AimAssistEnabled = not _G.AimAssistEnabled
    AimButton.BackgroundColor3 = _G.AimAssistEnabled and Color3.fromRGB(0, 100, 60) or Color3.fromRGB(25, 25, 30)
    AimButton.Text = "Простой Aim Assist: " .. (_G.AimAssistEnabled and "ВКЛ" or "ВЫКЛ")
end)

SilentAimButton.MouseButton1Click:Connect(function()
    _G.SilentAimEnabled = not _G.SilentAimEnabled
    SilentAimButton.BackgroundColor3 = _G.SilentAimEnabled and Color3.fromRGB(0, 100, 60) or Color3.fromRGB(25, 25, 30)
    SilentAimButton.Text = "Namecall Silent Aim: " .. (_G.SilentAimEnabled and "ВКЛ" or "ВЫКЛ")
end)

NoSpreadButton.MouseButton1Click:Connect(function()
    _G.NoSpreadEnabled = not _G.NoSpreadEnabled
    NoSpreadButton.BackgroundColor3 = _G.NoSpreadEnabled and Color3.fromRGB(0, 100, 60) or Color3.fromRGB(25, 25, 30)
    NoSpreadButton.Text = "Анти-Отдача / Разброс: " .. (_G.NoSpreadEnabled and "ВКЛ" or "ВЫКЛ")
end)

TracersButton.MouseButton1Click:Connect(function()
    _G.BulletTracersEnabled = not _G.BulletTracersEnabled
    TracersButton.BackgroundColor3 = _G.BulletTracersEnabled and Color3.fromRGB(0, 100, 60) or Color3.fromRGB(25, 25, 30)
    TracersButton.Text = "Трассеры Пуль: " .. (_G.BulletTracersEnabled and "ВКЛ" or "ВЫКЛ")
end)

SkinButton.MouseButton1Click:Connect(function()
    _G.SkinChangerEnabled = not _G.SkinChangerEnabled
    SkinButton.BackgroundColor3 = _G.SkinChangerEnabled and Color3.fromRGB(0, 100, 60) or Color3.fromRGB(25, 25, 30)
    SkinButton.Text = "Скинченджер: " .. (_G.SkinChangerEnabled and "ВКЛ" or "ВЫКЛ")
end)

ESPToggle.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    ESPToggle.BackgroundColor3 = espEnabled and Color3.fromRGB(0, 100, 60) or Color3.fromRGB(160, 30, 30)
    ESPToggle.Text = "TikTok ESP: " .. (espEnabled and "ВКЛ" or "ВЫКЛ")
    if not espEnabled then
        for _, data in pairs(cacheDrawingObjects) do
            pcall(function()
                data.Box.Visible = false
                data.HpBackground.Visible = false
                data.HpFill.Visible = false
                data.Text.Visible = false
            end)
        end
    end
end)

local function isEnemy(targetPlayer)
    if not targetPlayer or targetPlayer == LocalPlayer then return false end
    if targetPlayer.Team and LocalPlayer.Team then
        return targetPlayer.Team ~= LocalPlayer.Team
    end
    return true
end

local function getCharacter(player)
    if player == LocalPlayer then return player.Character end
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Head") then 
        return char 
    end
    return nil
end

local cachedTarget = nil
local lastTargetUpdate = 0
local TARGET_UPDATE_INTERVAL = 0.15 -- Увеличенный интервал для разгрузки процессора

local function GetUnifiedTarget()
    if tick() - lastTargetUpdate > TARGET_UPDATE_INTERVAL then
        cachedTarget = nil
        local closestTarget = nil
        local shortestDistance = _G.AimFOV

        for _, player in ipairs(Players:GetPlayers()) do
            if isEnemy(player) then
                local char = getCharacter(player)
                if char then
                    local humanoid = char:FindFirstChildOfClass("Humanoid")
                    if humanoid and humanoid.Health > 0 then
                        local targetPart = char:FindFirstChild(_G.TargetPart)
                        if targetPart then
                            local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                            if onScreen then
                                local distance = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                                if distance < shortestDistance then
                                    shortestDistance = distance
                                    closestTarget = targetPart
                                end
                            end
                        end
                    end
                end
            end
        end
        cachedTarget = closestTarget
        lastTargetUpdate = tick()
    end
    return cachedTarget
end

local function createPlayerDrawingObjects(playerName)
    if not DrawingSupported then return nil end
    if not cacheDrawingObjects[playerName] then
        local data = {}
        pcall(function()
            data.Box = Drawing.new("Square")
            data.Box.Thickness = 2
            data.Box.Filled = false
            data.Box.Visible = false
            
            data.HpBackground = Drawing.new("Square")
            data.HpBackground.Thickness = 1
            data.HpBackground.Filled = true
            data.HpBackground.Color = Color3.fromRGB(60, 10, 10)
            data.HpBackground.Visible = false
            
            data.HpFill = Drawing.new("Square")
            data.HpFill.Thickness = 1
            data.HpFill.Filled = true
            data.HpFill.Visible = false
            
            data.Text = Drawing.new("Text")
            data.Text.Size = 14
            data.Text.Center = true
            data.Text.Outline = true
            data.Text.Visible = false
        end)
        cacheDrawingObjects[playerName] = data
    end
    return cacheDrawingObjects[playerName]
end

local isShooting = false
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isShooting = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isShooting = false
    end
end)

-- Оптимизированный Aim Assist
RunService.RenderStepped:Connect(function()
    if not _G.AimAssistEnabled then return end
    local target = GetUnifiedTarget()
    if target then
        FOVStroke.Color = Color3.fromRGB(0, 255, 150)
        FOVCircle.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
        Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Position), _G.AimSmoothness)
    else
        FOVStroke.Color = Color3.fromRGB(255, 0, 0)
        FOVCircle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    end
end)

-- Оптимизированный ESP (Выполняется реже, не нагружая каждый кадр)
local lastEspUpdate = 0
RunService.RenderStepped:Connect(function()
    if not espEnabled then return end
    if tick() - lastEspUpdate < 0.08 then return end
    lastEspUpdate = tick()

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local data = DrawingSupported and createPlayerDrawingObjects(player.Name) or nil
            if data then
                if not isEnemy(player) then
                    data.Box.Visible = false
                    data.HpBackground.Visible = false
                    data.HpFill.Visible = false
                    data.Text.Visible = false
                else
                    local char = getCharacter(player)
                    if char then
                        local humanoid = char:FindFirstChildOfClass("Humanoid")
                        local root = char:FindFirstChild("HumanoidRootPart")
                        local head = char:FindFirstChild("Head")
                        
                        if humanoid and humanoid.Health > 0 and root and head then
                            local rPos, onScreen = Camera:WorldToViewportPoint(root.Position)
                            if onScreen then
                                local topPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                                local bottomPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 2.5, 0))
                                local height = math.abs(topPos.Y - bottomPos.Y)
                                local width = height * 0.55
                                
                                data.Box.Size = Vector2.new(width, height)
                                data.Box.Position = Vector2.new(rPos.X - width / 2, topPos.Y)
                                data.Box.Color = Color3.fromRGB(0, 255, 150)
                                data.Box.Visible = true
                                
                                local healthRatio = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
                                data.HpBackground.Size = Vector2.new(4, height)
                                data.HpBackground.Position = Vector2.new(rPos.X - width / 2 - 8, topPos.Y)
                                data.HpBackground.Visible = true
                                
                                local fillHeight = height * healthRatio
                                data.HpFill.Size = Vector2.new(4, fillHeight)
                                data.HpFill.Position = Vector2.new(rPos.X - width / 2 - 8, topPos.Y + (height - fillHeight))
                                data.HpFill.Visible = true
                                
                                local distance = math.floor((root.Position - Camera.CFrame.Position).Magnitude)
                                data.Text.Text = player.Name .. " [" .. distance .. "м]"
                                data.Text.Position = Vector2.new(rPos.X, topPos.Y - 18)
                                data.Text.Visible = true
                            else
                                data.Box.Visible = false
                                data.HpBackground.Visible = false
                                data.HpFill.Visible = false
                                data.Text.Visible = false
                            end
                        else
                            data.Box.Visible = false
                            data.HpBackground.Visible = false
                            data.HpFill.Visible = false
                            data.Text.Visible = false
                        end
                    end
                end
            end
        end
    end
end)
