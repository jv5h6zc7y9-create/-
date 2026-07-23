--[[
    Block Strike Ultimate Engine - Safe Aim Assist, TikTok ESP & SkinChanger (Full Monolith for Delta / iPad)
]]--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local DrawingSupported = (Drawing ~= nil and type(Drawing.new) == "function")

-- Глобальные настройки читера
_G.AimAssistEnabled = false
_G.AimSmoothness = 0.18      -- Плавность (беспалевная под интерполяцию античита)
_G.AimFOV = 140              -- Радиус FOV
_G.TargetPart = "Head"       -- Цель: Head или HumanoidRootPart
_G.SkinChangerEnabled = false
_G.SelectedSkinColor = Color3.fromRGB(255, 100, 0) -- Цвет для скинченджера (Неоновый оранжевый)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BlockStrikeSafeEngineMaster"
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
MainMenu.Size = UDim2.new(0, 360, 0, 600)
MainMenu.Position = UDim2.new(0.5, -180, 0.5, -300)
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
TitleLabel.Text = "⚡ BLOCK STRIKE MOBILE ENGINE ⚡"
TitleLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
TitleLabel.TextSize = 16
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
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 500)
ContentFrame.ScrollBarThickness = 4
ContentFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 150)
ContentFrame.Parent = MainMenu

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 12)
UIListLayout.Parent = ContentFrame

local AimButton = Instance.new("TextButton")
AimButton.Name = "AimButton"
AimButton.Size = UDim2.new(1, 0, 0, 45)
AimButton.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
AimButton.Text = "Безопасный Aim Assist: ВЫКЛ"
AimButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AimButton.TextSize = 15
AimButton.Font = Enum.Font.SourceSansBold
local AimCorner = Instance.new("UICorner")
AimCorner.CornerRadius = UDim.new(0.2, 0)
AimCorner.Parent = AimButton
local AimStroke = Instance.new("UIStroke")
AimStroke.Thickness = 1
AimStroke.Color = Color3.fromRGB(40, 40, 45)
AimStroke.Parent = AimButton
AimButton.Parent = ContentFrame

local SkinButton = Instance.new("TextButton")
SkinButton.Name = "SkinButton"
SkinButton.Size = UDim2.new(1, 0, 0, 45)
SkinButton.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
SkinButton.Text = "Скинченджер (Оружие): ВЫКЛ"
SkinButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SkinButton.TextSize = 15
SkinButton.Font = Enum.Font.SourceSansBold
local SkinCorner = Instance.new("UICorner")
SkinCorner.CornerRadius = UDim.new(0.2, 0)
SkinCorner.Parent = SkinButton
local SkinStroke = Instance.new("UIStroke")
SkinStroke.Thickness = 1
SkinStroke.Color = Color3.fromRGB(40, 40, 45)
SkinStroke.Parent = SkinButton
SkinButton.Parent = ContentFrame

local ESPToggle = Instance.new("TextButton")
ESPToggle.Name = "ESPToggle"
ESPToggle.Size = UDim2.new(1, 0, 0, 45)
ESPToggle.BackgroundColor3 = Color3.fromRGB(0, 100, 60)
ESPToggle.Text = "TikTok ESP: ВКЛ"
ESPToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
ESPToggle.TextSize = 15
ESPToggle.Font = Enum.Font.SourceSansBold
local ESPCorner = Instance.new("UICorner")
ESPCorner.CornerRadius = UDim.new(0.2, 0)
ESPCorner.Parent = ESPToggle
local ESPStroke = Instance.new("UIStroke")
ESPStroke.Thickness = 1
ESPStroke.Color = Color3.fromRGB(40, 40, 45)
ESPStroke.Parent = ESPToggle
ESPToggle.Parent = ContentFrame

local SliderContainer = Instance.new("Frame")
SliderContainer.Name = "SliderContainer"
SliderContainer.Size = UDim2.new(1, 0, 0, 55)
SliderContainer.BackgroundTransparency = 1
SliderContainer.Parent = ContentFrame

local SliderLabel = Instance.new("TextLabel")
SliderLabel.Name = "SliderLabel"
SliderLabel.Size = UDim2.new(1, 0, 0, 20)
SliderLabel.BackgroundTransparency = 1
SliderLabel.Text = "Радиус FOV: 140 px"
SliderLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
SliderLabel.TextSize = 14
SliderLabel.Font = Enum.Font.SourceSansBold
SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
SliderLabel.Parent = SliderContainer

local SliderBar = Instance.new("Frame")
SliderBar.Name = "SliderBar"
SliderBar.Size = UDim2.new(1, 0, 0, 8)
SliderBar.Position = UDim2.new(0, 0, 0, 30)
SliderBar.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
SliderBar.BorderSizePixel = 0
SliderBar.Parent = SliderContainer

local SliderBarCorner = Instance.new("UICorner")
SliderBarCorner.CornerRadius = UDim.new(1, 0)
SliderBarCorner.Parent = SliderBar

local SliderBtn = Instance.new("TextButton")
SliderBtn.Name = "SliderBtn"
SliderBtn.Size = UDim2.new(0, 20, 0, 20)
SliderBtn.AnchorPoint = Vector2.new(0.5, 0.5)
SliderBtn.Position = UDim2.new(0.45, 0, 0.5, 0)
SliderBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
SliderBtn.Text = ""
SliderBtn.Parent = SliderBar

local SliderBtnCorner = Instance.new("UICorner")
SliderBtnCorner.CornerRadius = UDim.new(1, 0)
SliderBtnCorner.Parent = SliderBtn

local espEnabled = true
local draggingSlider = false
local colorVisible = Color3.fromRGB(0, 255, 150)
local colorHidden = Color3.fromRGB(255, 40, 40)
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
    if _G.AimAssistEnabled then
        AimButton.BackgroundColor3 = Color3.fromRGB(0, 100, 60)
        AimButton.Text = "Безопасный Aim Assist: ВКЛ"
    else
        AimButton.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
        AimButton.Text = "Безопасный Aim Assist: ВЫКЛ"
    end
end)

SkinButton.MouseButton1Click:Connect(function()
    _G.SkinChangerEnabled = not _G.SkinChangerEnabled
    if _G.SkinChangerEnabled then
        SkinButton.BackgroundColor3 = Color3.fromRGB(0, 100, 60)
        SkinButton.Text = "Скинченджер (Оружие): ВКЛ"
    else
        SkinButton.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
        SkinButton.Text = "Скинченджер (Оружие): ВЫКЛ"
    end
end)

ESPToggle.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    if espEnabled then
        ESPToggle.BackgroundColor3 = Color3.fromRGB(0, 100, 60)
        ESPToggle.Text = "TikTok ESP: ВКЛ"
    else
        ESPToggle.BackgroundColor3 = Color3.fromRGB(160, 30, 30)
        ESPToggle.Text = "TikTok ESP: ВЫКЛ"
        for _, data in pairs(cacheDrawingObjects) do
            if data.Box then data.Box.Visible = false end
            if data.HpBackground then data.HpBackground.Visible = false end
            if data.HpFill then data.HpFill.Visible = false end
            if data.Text then data.Text.Visible = false end
        end
    end
end)

local function getCharacter(player)
    if player == LocalPlayer then return player.Character end
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then return char end
    for _, name in ipairs({"Players", "Entities", "Characters", "Clients"}) do
        local c = Workspace:FindFirstChild(name)
        if c then
            local found = c:FindFirstChild(player.Name) or c:FindFirstChild(tostring(player.UserId))
            if found then return found end
        end
    end
    return nil
end

local function isEnemy(targetPlayer)
    if targetPlayer == LocalPlayer then return false end
    if targetPlayer.Team and LocalPlayer.Team then
        return targetPlayer.Team ~= LocalPlayer.Team
    end
    return true
end

local function IsVisible(target)
    local character = LocalPlayer.Character
    if not character then return false end
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {character, target.Parent}
    raycastParams.IgnoreWater = true
    
    local origin = Camera.CFrame.Position
    local direction = target.Position - origin
    local raycastResult = workspace:Raycast(origin, direction, raycastParams)
    
    return raycastResult == nil
end

local function GetClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = _G.AimFOV

    for _, player in pairs(Players:GetPlayers()) do
        if isEnemy(player) then
            local char = getCharacter(player)
            if char and char:FindFirstChild(_G.TargetPart) and char:FindFirstChildOfClass("Humanoid") then
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid.Health > 0 then
                    local targetPart = char[_G.TargetPart]
                    local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                    
                    if onScreen then
                        local distance = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                        if distance < shortestDistance then
                            if IsVisible(targetPart) then
                                shortestDistance = distance
                                closestPlayer = targetPart
                            end
                        end
                    end
                end
            end
        end
    end
    return closestPlayer
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

RunService.RenderStepped:Connect(function()
    -- 1. Безопасный Aim Assist
    if _G.AimAssistEnabled then
        local target = GetClosestPlayer()
        if target then
            FOVStroke.Color = Color3.fromRGB(0, 255, 150)
            FOVCircle.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
            local targetCFrame = CFrame.new(Camera.CFrame.Position, target.Position)
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, _G.AimSmoothness)
        else
            FOVStroke.Color = Color3.fromRGB(255, 0, 0)
            FOVCircle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        end
    end

    -- 2. Скинченджер (Окрашивает оружие в руках локального игрока)
    if _G.SkinChangerEnabled and LocalPlayer.Character then
        pcall(function()
            for _, item in ipairs(LocalPlayer.Character:GetChildren()) do
                if item:IsA("Tool") then
                    for _, part in ipairs(item:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.Color = _G.SelectedSkinColor
                            part.Material = Enum.Material.Neon
                        end
                    end
                end
            end
        end)
    end

    -- 3. TikTok ESP Отрисовка
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local data = DrawingSupported and createPlayerDrawingObjects(player.Name) or nil
            local char = getCharacter(player)
            
            if espEnabled and isEnemy(player) and char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Head") and data and data.Box then
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    local root = char.HumanoidRootPart
                    local head = char.Head
                    local rPos, onScreen = Camera:WorldToViewportPoint(root.Position)
                    
                    if onScreen then
                        local topPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                        local bottomPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 2.5, 0))
                        local height = math.abs(topPos.Y - bottomPos.Y)
                        local width = height * 0.55
                        local isVis = IsVisible(head)
                        local boxColor = isVis and colorVisible or colorHidden
                        
                        data.Box.Size = Vector2.new(width, height)
                        data.Box.Position = Vector2.new(rPos.X - width / 2, topPos.Y)
                        data.Box.Color = boxColor
                        data.Box.Visible = true
                        
                        local healthRatio = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
                        data.HpBackground.Size = Vector2.new(4, height)
                        data.HpBackground.Position = Vector2.new(rPos.X - width / 2 - 8, topPos.Y)
                        data.HpBackground.Visible = true
                        
                        local fillHeight = height * healthRatio
                        data.HpFill.Size = Vector2.new(4, fillHeight)
                        data.HpFill.Position = Vector2.new(rPos.X - width / 2 - 8, topPos.Y + (height - fillHeight))
                        data.HpFill.Color = Color3.fromRGB(255 * (1 - healthRatio), 255 * healthRatio, 0)
                        data.HpFill.Visible = true
                        
                        local distance = math.floor((root.Position - Camera.CFrame.Position).Magnitude)
                        data.Text.Text = player.Name .. " [" .. distance .. "м]"
                        data.Text.Position = Vector2.new(rPos.X, topPos.Y - 18)
                        data.Text.Color = boxColor
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
            elseif data and data.Box then
                data.Box.Visible = false
                data.HpBackground.Visible = false
                data.HpFill.Visible = false
                data.Text.Visible = false
            end
        end
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if cacheDrawingObjects[player.Name] then
        pcall(function()
            cacheDrawingObjects[player.Name].Box:Remove()
            cacheDrawingObjects[player.Name].HpBackground:Remove()
            cacheDrawingObjects[player.Name].HpFill:Remove()
            cacheDrawingObjects[player.Name].Text:Remove()
        end)
        cacheDrawingObjects[player.Name] = nil
    end
end)
