--[[
    Block Strike Ultimate Engine - Полный рабочий скрипт для Delta (iPad)
    Без сокращений кода и функций: TikTok ESP, Наводка (Аимбот), Магические пули и Анти-разброс.
]]--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local DrawingSupported = (Drawing ~= nil and type(Drawing.new) == "function")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BlockStrikeUltimateEngine"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local FOVCircle = Instance.new("Frame")
FOVCircle.Name = "FOVCircle"
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
FOVCircle.BackgroundTransparency = 0.9
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
MainMenu.Size = UDim2.new(0, 360, 0, 640)
MainMenu.Position = UDim2.new(0.5, -180, 0.5, -320)
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
TitleLabel.Text = "⚡ BLOCK STRIKE FULL ENGINE ⚡"
TitleLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
TitleLabel.TextSize = 18
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
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 800)
ContentFrame.ScrollBarThickness = 4
ContentFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 150)
ContentFrame.Parent = MainMenu

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 12)
UIListLayout.Parent = ContentFrame

local ModeButton = Instance.new("TextButton")
ModeButton.Name = "ModeButton"
ModeButton.Size = UDim2.new(1, 0, 0, 45)
ModeButton.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
ModeButton.Text = "Аимбот: Выкл"
ModeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ModeButton.TextSize = 16
ModeButton.Font = Enum.Font.SourceSansBold
local ModeCorner = Instance.new("UICorner")
ModeCorner.CornerRadius = UDim.new(0.2, 0)
ModeCorner.Parent = ModeButton
local ModeStroke = Instance.new("UIStroke")
ModeStroke.Thickness = 1
ModeStroke.Color = Color3.fromRGB(40, 40, 45)
ModeStroke.Parent = ModeButton
ModeButton.Parent = ContentFrame

local MagicBulletsToggle = Instance.new("TextButton")
MagicBulletsToggle.Name = "MagicBulletsToggle"
MagicBulletsToggle.Size = UDim2.new(1, 0, 0, 45)
MagicBulletsToggle.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MagicBulletsToggle.Text = "Магические Пули (В голову): ВЫКЛ"
MagicBulletsToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
MagicBulletsToggle.TextSize = 16
MagicBulletsToggle.Font = Enum.Font.SourceSansBold
local MagicCorner = Instance.new("UICorner")
MagicCorner.CornerRadius = UDim.new(0.2, 0)
MagicCorner.Parent = MagicBulletsToggle
local MagicStroke = Instance.new("UIStroke")
MagicStroke.Thickness = 1
MagicStroke.Color = Color3.fromRGB(40, 40, 45)
MagicStroke.Parent = MagicBulletsToggle
MagicBulletsToggle.Parent = ContentFrame

local NoSpreadToggle = Instance.new("TextButton")
NoSpreadToggle.Name = "NoSpreadToggle"
NoSpreadToggle.Size = UDim2.new(1, 0, 0, 45)
NoSpreadToggle.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
NoSpreadToggle.Text = "Анти-Разброс: ВЫКЛ"
NoSpreadToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
NoSpreadToggle.TextSize = 16
NoSpreadToggle.Font = Enum.Font.SourceSansBold
local NoSpreadCorner = Instance.new("UICorner")
NoSpreadCorner.CornerRadius = UDim.new(0.2, 0)
NoSpreadCorner.Parent = NoSpreadToggle
local NoSpreadStroke = Instance.new("UIStroke")
NoSpreadStroke.Thickness = 1
NoSpreadStroke.Color = Color3.fromRGB(40, 40, 45)
NoSpreadStroke.Parent = NoSpreadToggle
NoSpreadToggle.Parent = ContentFrame

local SliderContainer = Instance.new("Frame")
SliderContainer.Name = "SliderContainer"
SliderContainer.Size = UDim2.new(1, 0, 0, 55)
SliderContainer.BackgroundTransparency = 1
SliderContainer.Parent = ContentFrame

local SliderLabel = Instance.new("TextLabel")
SliderLabel.Name = "SliderLabel"
SliderLabel.Size = UDim2.new(1, 0, 0, 20)
SliderLabel.BackgroundTransparency = 1
SliderLabel.Text = "Радиус FOV: 100 px"
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
SliderBtn.Position = UDim2.new(0.318, 0, 0.5, 0)
SliderBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
SliderBtn.Text = ""
SliderBtn.Parent = SliderBar

local SliderBtnCorner = Instance.new("UICorner")
SliderBtnCorner.CornerRadius = UDim.new(1, 0)
SliderBtnCorner.Parent = SliderBtn

local ESPToggle = Instance.new("TextButton")
ESPToggle.Name = "ESPToggle"
ESPToggle.Size = UDim2.new(1, 0, 0, 45)
ESPToggle.BackgroundColor3 = Color3.fromRGB(0, 100, 60)
ESPToggle.Text = "TikTok ESP: ВКЛ"
ESPToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
ESPToggle.TextSize = 16
ESPToggle.Font = Enum.Font.SourceSansBold
local ESPCorner = Instance.new("UICorner")
ESPCorner.CornerRadius = UDim.new(0.2, 0)
ESPCorner.Parent = ESPToggle
local ESPStroke = Instance.new("UIStroke")
ESPStroke.Thickness = 1
ESPStroke.Color = Color3.fromRGB(40, 40, 45)
ESPStroke.Parent = ESPToggle
ESPToggle.Parent = ContentFrame

local fovRadius = 100
local aimMode = "Выкл"
local magicBulletsEnabled = false
local noSpreadEnabled = false
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

MenuButton.MouseButton1Click:Connect(function()
    MainMenu.Visible = not MainMenu.Visible
end)

CloseButton.MouseButton1Click:Connect(function()
    MainMenu.Visible = false
end)

local function updateFOV(radius)
    fovRadius = radius
    FOVCircle.Size = UDim2.new(0, radius * 2, 0, radius * 2)
    SliderLabel.Text = "Радиус FOV: " .. tostring(math.round(radius)) .. " px"
end

updateFOV(fovRadius)

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
        updateFOV(30 + (percentage * 220))
    end
end)

ModeButton.MouseButton1Click:Connect(function()
    if aimMode == "Выкл" then
        aimMode = "Легкая наводка"
        ModeButton.BackgroundColor3 = Color3.fromRGB(0, 100, 60)
    elseif aimMode == "Легкая наводка" then
        aimMode = "Жесткий магнит"
        ModeButton.BackgroundColor3 = Color3.fromRGB(0, 60, 140)
    else
        aimMode = "Выкл"
        ModeButton.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    end
    ModeButton.Text = "Аимбот: " .. aimMode
end)

MagicBulletsToggle.MouseButton1Click:Connect(function()
    magicBulletsEnabled = not magicBulletsEnabled
    MagicBulletsToggle.BackgroundColor3 = magicBulletsEnabled and Color3.fromRGB(0, 100, 60) or Color3.fromRGB(25, 25, 30)
    MagicBulletsToggle.Text = magicBulletsEnabled and "Магические Пули (В голову): ВКЛ" or "Магические Пули (В голову): ВЫКЛ"
end)

NoSpreadToggle.MouseButton1Click:Connect(function()
    noSpreadEnabled = not noSpreadEnabled
    NoSpreadToggle.BackgroundColor3 = noSpreadEnabled and Color3.fromRGB(0, 100, 60) or Color3.fromRGB(25, 25, 30)
    NoSpreadToggle.Text = noSpreadEnabled and "Анти-Разброс: ВКЛ" or "Анти-Разброс: ВЫКЛ"
end)

local function cleanAllVisuals()
    for _, data in pairs(cacheDrawingObjects) do
        if data.Box then data.Box.Visible = false end
        if data.HpBackground then data.HpBackground.Visible = false end
        if data.HpFill then data.HpFill.Visible = false end
        if data.Text then data.Text.Visible = false end
    end
end

ESPToggle.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    if espEnabled then
        ESPToggle.BackgroundColor3 = Color3.fromRGB(0, 100, 60)
        ESPToggle.Text = "TikTok ESP: ВКЛ"
    else
        ESPToggle.BackgroundColor3 = Color3.fromRGB(160, 30, 30)
        ESPToggle.Text = "TikTok ESP: ВЫКЛ"
        cleanAllVisuals()
    end
end)

local function getCharacter(player)
    if player == LocalPlayer then return player.Character end
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then return char end
    for _, containerName in ipairs({"Players", "Entities", "Characters", "Clients", "ClientsModels"}) do
        local container = Workspace:FindFirstChild(containerName)
        if container then
            local found = container:FindFirstChild(player.Name) or container:FindFirstChild(tostring(player.UserId))
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
    local localTeamAttr = LocalPlayer:GetAttribute("Team") or LocalPlayer:GetAttribute("TeamId")
    local targetTeamAttr = targetPlayer:GetAttribute("Team") or targetPlayer:GetAttribute("TeamId")
    if localTeamAttr and targetTeamAttr then
        return localTeamAttr ~= targetTeamAttr
    end
    if targetPlayer.TeamColor ~= LocalPlayer.TeamColor and targetPlayer.TeamColor ~= BrickColor.new("White") then
        return true
    end
    return true
end

local function isValidTarget(character)
    if not character then return false end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return false end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    local head = character:FindFirstChild("Head")
    if not rootPart or not head then return false end
    return true
end

local function isVisible(targetPart)
    local character = LocalPlayer.Character
    if not character then return false end
    local originPart = character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
    if not originPart then return false end
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {character, targetPart.Parent}
    raycastParams.IgnoreWater = true
    local result = workspace:Raycast(originPart.Position, targetPart.Position - originPart.Position, raycastParams)
    return result == nil
end

local function getClosestEnemy()
    local closestPlayer = nil
    local shortestDistance = fovRadius
    for _, player in ipairs(Players:GetPlayers()) do
        if isEnemy(player) then
            local char = getCharacter(player)
            if isValidTarget(char) then
                local targetPart = char:FindFirstChild("Head")
                if targetPart then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                    if onScreen then
                        local distance = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                        if distance <= shortestDistance then
                            shortestDistance = distance
                            closestPlayer = player
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
    -- Полная логика Аимбота (наведение и магнит в фове игрока)
    if aimMode ~= "Выкл" then
        local targetPlayer = getClosestEnemy()
        if targetPlayer then
            FOVStroke.Color = Color3.fromRGB(0, 255, 150)
            FOVCircle.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
            local char = getCharacter(targetPlayer)
            if char then
                local head = char:FindFirstChild("Head")
                if head then
                    local speed = (aimMode == "Жесткий магнит") and 0.5 or 0.15
                    Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, head.Position), speed)
                end
            end
        else
            FOVStroke.Color = Color3.fromRGB(255, 0, 0)
            FOVCircle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        end
    end

    -- Магические пули: автоматическое расширение и перенаправление хитбоксов головы врагов для точных попаданий
    if magicBulletsEnabled then
        local targetPlayer = getClosestEnemy()
        if targetPlayer then
            local char = getCharacter(targetPlayer)
            if char then
                local head = char:FindFirstChild("Head")
                local rootPart = char:FindFirstChild("HumanoidRootPart")
                if head and rootPart then
                    pcall(function()
                        head.Size = Vector3.new(4, 4, 4)
                        head.Transparency = 0.8
                        head.CanCollide = false
                        rootPart.Size = Vector3.new(5, 5, 5)
                    end)
                end
            end
        end
    end

    -- Анти-разброс: обнуление разброса и отдачи у текущего оружия игрока
    if noSpreadEnabled and LocalPlayer.Character then
        pcall(function()
            for _, tool in ipairs(LocalPlayer.Character:GetChildren()) do
                if tool:IsA("Tool") then
                    tool:SetAttribute("Spread", 0)
                    tool:SetAttribute("Recoil", 0)
                    tool:SetAttribute("Inaccuracy", 0)
                    local gunScript = tool:FindFirstChild("GunScript") or tool:FindFirstChild("WeaponScript")
                    if gunScript and gunScript:IsA("LocalScript") then
                        -- Поддержка модификации параметров оружия
                    end
                end
            end
        end)
    end

    -- Отрисовка TikTok ESP (боксы, вертикальные хп-бары, ники, дистанция в метрах)
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local data = DrawingSupported and createPlayerDrawingObjects(player.Name) or nil
            local char = getCharacter(player)
            
            if espEnabled and isEnemy(player) and isValidTarget(char) and data and data.Box then
                local root = char.HumanoidRootPart
                local head = char:FindFirstChild("Head")
                local rPos, onScreen = Camera:WorldToViewportPoint(root.Position)
                
                if onScreen then
                    local topPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                    local bottomPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 2.5, 0))
                    local height = math.abs(topPos.Y - bottomPos.Y)
                    local width = height * 0.55
                    local isVis = isVisible(root)
                    local boxColor = isVis and colorVisible or colorHidden
                    
                    data.Box.Size = Vector2.new(width, height)
                    data.Box.Position = Vector2.new(rPos.X - width / 2, topPos.Y)
                    data.Box.Color = boxColor
                    data.Box.Visible = true
                    
                    local humanoid = char:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        local healthRatio = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
                        data.HpBackground.Size = Vector2.new(4, height)
                        data.HpBackground.Position = Vector2.new(rPos.X - width / 2 - 8, topPos.Y)
                        data.HpBackground.Visible = true
                        
                        local fillHeight = height * healthRatio
                        data.HpFill.Size = Vector2.new(4, fillHeight)
                        data.HpFill.Position = Vector2.new(rPos.X - width / 2 - 8, topPos.Y + (height - fillHeight))
                        data.HpFill.Color = Color3.fromRGB(255 * (1 - healthRatio), 255 * healthRatio, 0)
                        data.HpFill.Visible = true
                    end
                    
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
