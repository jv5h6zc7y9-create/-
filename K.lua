--!strict
--[[
    Block Strike Ultimate Engine - Fully Loaded Monolith (Fixed Safe Version for Mobile/Delta)
    Полностью исправленный и оптимизированный монолитный код без сокращений.
]]--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local DrawingSupported = (Drawing ~= nil and type(Drawing.new) == "function")

-- Глобальные настройки читов
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
ScreenGui.Name = "BlockStrikeUltimateMonolithNamecall"
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
TitleLabel.Text = "⚡ NAMECALL SILENT AIM ENGINE ⚡"
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

local AimButton = Instance.new("TextButton")
AimButton.Name = "AimButton"
AimButton.Size = UDim2.new(1, 0, 0, 45)
AimButton.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
AimButton.Text = "Простой Aim Assist: ВЫКЛ"
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

local SilentAimButton = Instance.new("TextButton")
SilentAimButton.Name = "SilentAimButton"
SilentAimButton.Size = UDim2.new(1, 0, 0, 45)
SilentAimButton.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
SilentAimButton.Text = "Namecall Silent Aim (В голову): ВЫКЛ"
SilentAimButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SilentAimButton.TextSize = 15
SilentAimButton.Font = Enum.Font.SourceSansBold
local SilentCorner = Instance.new("UICorner")
SilentCorner.CornerRadius = UDim.new(0.2, 0)
SilentCorner.Parent = SilentAimButton
local SilentStroke = Instance.new("UIStroke")
SilentStroke.Thickness = 1
SilentStroke.Color = Color3.fromRGB(40, 40, 45)
SilentStroke.Parent = SilentAimButton
SilentAimButton.Parent = ContentFrame

local NoSpreadButton = Instance.new("TextButton")
NoSpreadButton.Name = "NoSpreadButton"
NoSpreadButton.Size = UDim2.new(1, 0, 0, 45)
NoSpreadButton.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
NoSpreadButton.Text = "Анти-Отдача / Разброс: ВЫКЛ"
NoSpreadButton.TextColor3 = Color3.fromRGB(255, 255, 255)
NoSpreadButton.TextSize = 15
NoSpreadButton.Font = Enum.Font.SourceSansBold
local NoSpreadCorner = Instance.new("UICorner")
NoSpreadCorner.CornerRadius = UDim.new(0.2, 0)
NoSpreadCorner.Parent = NoSpreadButton
local NoSpreadStroke = Instance.new("UIStroke")
NoSpreadStroke.Thickness = 1
NoSpreadStroke.Color = Color3.fromRGB(40, 40, 45)
NoSpreadStroke.Parent = NoSpreadButton
NoSpreadButton.Parent = ContentFrame

local TracersButton = Instance.new("TextButton")
TracersButton.Name = "TracersButton"
TracersButton.Size = UDim2.new(1, 0, 0, 45)
TracersButton.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
TracersButton.Text = "Трассеры Пуль (Текстуры/Лучи): ВЫКЛ"
TracersButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TracersButton.TextSize = 15
TracersButton.Font = Enum.Font.SourceSansBold
local TracersCorner = Instance.new("UICorner")
TracersCorner.CornerRadius = UDim.new(0.2, 0)
TracersCorner.Parent = TracersButton
local TracersStroke = Instance.new("UIStroke")
TracersStroke.Thickness = 1
TracersStroke.Color = Color3.fromRGB(40, 40, 45)
TracersStroke.Parent = TracersButton
TracersButton.Parent = ContentFrame

local SkinButton = Instance.new("TextButton")
SkinButton.Name = "SkinButton"
SkinButton.Size = UDim2.new(1, 0, 0, 45)
SkinButton.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
SkinButton.Text = "Скинченджер (Оружие + Нож): ВЫКЛ"
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
ESPToggle.Text = "TikTok ESP (Строго без тиммейтов): ВКЛ"
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
    AimButton.BackgroundColor3 = _G.AimAssistEnabled and Color3.fromRGB(0, 100, 60) or Color3.fromRGB(25, 25, 30)
    AimButton.Text = _G.AimAssistEnabled and "Простой Aim Assist: ВКЛ" or "Простой Aim Assist: ВЫКЛ"
end)

SilentAimButton.MouseButton1Click:Connect(function()
    _G.SilentAimEnabled = not _G.SilentAimEnabled
    SilentAimButton.BackgroundColor3 = _G.SilentAimEnabled and Color3.fromRGB(0, 100, 60) or Color3.fromRGB(25, 25, 30)
    SilentAimButton.Text = _G.SilentAimEnabled and "Namecall Silent Aim (В голову): ВКЛ" or "Namecall Silent Aim (В голову): ВЫКЛ"
end)

NoSpreadButton.MouseButton1Click:Connect(function()
    _G.NoSpreadEnabled = not _G.NoSpreadEnabled
    NoSpreadButton.BackgroundColor3 = _G.NoSpreadEnabled and Color3.fromRGB(0, 100, 60) or Color3.fromRGB(25, 25, 30)
    NoSpreadButton.Text = _G.NoSpreadEnabled and "Анти-Отдача / Разброс: ВКЛ" or "Анти-Отдача / Разброс: ВЫКЛ"
end)

TracersButton.MouseButton1Click:Connect(function()
    _G.BulletTracersEnabled = not _G.BulletTracersEnabled
    TracersButton.BackgroundColor3 = _G.BulletTracersEnabled and Color3.fromRGB(0, 100, 60) or Color3.fromRGB(25, 25, 30)
    TracersButton.Text = _G.BulletTracersEnabled and "Трассеры Пуль (Текстуры/Лучи): ВКЛ" or "Трассеры Пуль (Текстуры/Лучи): ВЫКЛ"
end)

SkinButton.MouseButton1Click:Connect(function()
    _G.SkinChangerEnabled = not _G.SkinChangerEnabled
    SkinButton.BackgroundColor3 = _G.SkinChangerEnabled and Color3.fromRGB(0, 100, 60) or Color3.fromRGB(25, 25, 30)
    SkinButton.Text = _G.SkinChangerEnabled and "Скинченджер (Оружие + Нож): ВКЛ" or "Скинченджер (Оружие + Нож): ВЫКЛ"
end)

ESPToggle.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    if espEnabled then
        ESPToggle.BackgroundColor3 = Color3.fromRGB(0, 100, 60)
        ESPToggle.Text = "TikTok ESP (Строго без тиммейтов): ВКЛ"
    else
        ESPToggle.BackgroundColor3 = Color3.fromRGB(160, 30, 30)
        ESPToggle.Text = "TikTok ESP (Строго без тиммейтов): ВЫКЛ"
        for _, data in pairs(cacheDrawingObjects) do
            if data.Box then data.Box.Visible = false end
            if data.HpBackground then data.HpBackground.Visible = false end
            if data.HpFill then data.HpFill.Visible = false end
            if data.Text then data.Text.Visible = false end
        end
    end
end)

local function removeEsp(playerName)
    local data = cacheDrawingObjects[playerName]
    if data then
        pcall(function()
            if data.Box then data.Box.Visible = false end
            if data.HpBackground then data.HpBackground.Visible = false end
            if data.HpFill then data.HpFill.Visible = false end
            if data.Text then data.Text.Visible = false end
        end)
    end
end

local function isEnemy(targetPlayer)
    if not targetPlayer or targetPlayer == LocalPlayer then 
        return false 
    end

    if targetPlayer.Team and LocalPlayer.Team then
        if targetPlayer.Team == LocalPlayer.Team then
            return false
        else
            return true
        end
    end

    local attrTeam = targetPlayer:GetAttribute("Team") or targetPlayer:GetAttribute("Side")
    local localAttrTeam = LocalPlayer:GetAttribute("Team") or LocalPlayer:GetAttribute("Side")
    if attrTeam ~= nil and localAttrTeam ~= nil then
        if attrTeam == localAttrTeam then
            return false
        else
            return true
        end
    end

    local teamObj = targetPlayer:FindFirstChild("Team")
    local localTeamObj = LocalPlayer:FindFirstChild("Team")
    if teamObj and localTeamObj and (teamObj:IsA("StringValue") or teamObj:IsA("IntValue")) and (localTeamObj:IsA("StringValue") or localTeamObj:IsA("IntValue")) then
        if teamObj.Value == localTeamObj.Value then
            return false
        else
            return true
        end
    end

    if targetPlayer.TeamColor and LocalPlayer.TeamColor then
        if targetPlayer.TeamColor == BrickColor.new("White") or LocalPlayer.TeamColor == BrickColor.new("White") then
            return true
        end
        if targetPlayer.TeamColor == LocalPlayer.TeamColor then
            return false
        else
            return true
        end
    end

    return true
end

local function getCharacter(player)
    if player == LocalPlayer then 
        return player.Character 
    end
    
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Head") then 
        return char 
    end

    for _, descendant in ipairs(Workspace:GetDescendants()) do
        if descendant:IsA("Model") and descendant.Name == player.Name then
            if descendant:FindFirstChild("HumanoidRootPart") and descendant:FindFirstChild("Head") then
                return descendant
            end
        end
    end

    return nil
end

local function IsVisibleFast(targetPart)
    local character = LocalPlayer.Character
    if not character then return false end
    
    local head = character:FindFirstChild("Head")
    if not head then return false end
    
    local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
    if not onScreen then return false end
    
    local distance = (targetPart.Position - head.Position).Magnitude
    if distance < 50 then
        local raycastParams = RaycastParams.new()
        raycastParams.FilterType = Enum.RaycastFilterType.Exclude
        raycastParams.FilterDescendantsInstances = {character, targetPart.Parent}
        raycastParams.IgnoreWater = true
        
        local origin = Camera.CFrame.Position
        local direction = targetPart.Position - origin
        local raycastResult = workspace:Raycast(origin, direction, raycastParams)
        return raycastResult == nil or raycastResult.Instance:IsDescendantOf(targetPart.Parent)
    end
    
    return true
end

local cachedTarget = nil
local lastTargetUpdate = 0
local TARGET_UPDATE_INTERVAL = 0.1

local function GetUnifiedTarget()
    if tick() - lastTargetUpdate > TARGET_UPDATE_INTERVAL then
        cachedTarget = nil
        local closestTarget = nil
        local shortestDistance = _G.AimFOV

        for _, player in ipairs(Players:GetPlayers()) do
            if not isEnemy(player) then
                continue
            end

            local char = getCharacter(player)
            if char and char:FindFirstChild(_G.TargetPart) and char:FindFirstChildOfClass("Humanoid") then
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid.Health > 0 then
                    local targetPart = char[_G.TargetPart]
                    local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                    
                    if onScreen then
                        local distance = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                        if distance < shortestDistance then
                            if IsVisibleFast(targetPart) then
                                shortestDistance = distance
                                closestTarget = targetPart
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

local function CreateBulletTracer(originPos, targetPos)
    pcall(function()
        local partA = Instance.new("Part")
        partA.Size = Vector3.new(0.1, 0.1, 0.1)
        partA.Position = originPos
        partA.Transparency = 1
        partA.Anchored = true
        partA.CanCollide = false
        partA.Parent = Workspace

        local partB = Instance.new("Part")
        partB.Size = Vector3.new(0.1, 0.1, 0.1)
        partB.Position = targetPos
        partB.Transparency = 1
        partB.Anchored = true
        partB.CanCollide = false
        partB.Parent = Workspace

        local attachmentA = Instance.new("Attachment", partA)
        local attachmentB = Instance.new("Attachment", partB)

        local beam = Instance.new("Beam")
        beam.Attachment0 = attachmentA
        beam.Attachment1 = attachmentB
        beam.Color = ColorSequence.new(_G.TracerColor)
        beam.Width0 = 0.12
        beam.Width1 = 0.12
        beam.Texture = "rbxassetid://6079958617" 
        beam.TextureMode = Enum.TextureMode.Wrap
        beam.TextureSpeed = 5
        beam.LightEmission = 1
        beam.LightInfluence = 0
        beam.Parent = partA

        task.delay(0.08, function()
            pcall(function()
                partA:Destroy()
                partB:Destroy()
            end)
        end)
    end)
end

local isShooting = false

-- ИСПРАВЛЕНИЕ ЛАГОВ В МЕНЮ: игнорируем клики, если нажатие перехвачено интерфейсом (processed)
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    local inputType = input.UserInputType
    if inputType == Enum.UserInputType.MouseButton1 or inputType == Enum.UserInputType.Touch then
        isShooting = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    local inputType = input.UserInputType
    if inputType == Enum.UserInputType.MouseButton1 or inputType == Enum.UserInputType.Touch then
        isShooting = false
    end
end)

-- Таблица для быстрой проверки методов без лишних условий
local validMethods = {
    ["FindPartOnRayWithIgnoreList"] = true,
    ["FindPartOnRay"] = true,
    ["FindPartOnRayWithWhitelist"] = true
}

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local Method = getnamecallmethod()
    
    -- Сверхбыстрый ранний выход: если не стреляем или функция не связана с лучами стрельбы, код даже не думает
    if not (_G.SilentAimEnabled and isShooting and validMethods[Method]) then
        return oldNamecall(self, ...)
    end
    
    local Arguments = {...}
    local target = GetUnifiedTarget()
    
    if target and target.Position then
        local rayIndex = (Method == "FindPartOnRay") and 1 or 2
        local originalRay = Arguments[rayIndex]
        
        if originalRay then
            local origin = originalRay.Origin
            local direction = (target.Position - origin).Unit * originalRay.Direction.Magnitude
            
            Arguments[rayIndex] = Ray.new(origin, direction)
            
            return oldNamecall(self, table.unpack(Arguments))
        end
    end
    
    return oldNamecall(self, ...)
end)

local lastShotTick = 0

RunService.RenderStepped:Connect(function()
    if _G.AimAssistEnabled then
        local target = GetUnifiedTarget()
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

    if _G.BulletTracersEnabled then
        if isShooting and (tick() - lastShotTick > 0.08) then
            lastShotTick = tick()
            pcall(function()
                local gunOrigin = Camera.CFrame.Position
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool") then
                    local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                    local handle = tool:FindFirstChild("Handle") or tool:FindFirstChild("Muzzle")
                    if handle then gunOrigin = handle.Position end
                end
                local target = GetUnifiedTarget()
                local targetPos = target and target.Position or (gunOrigin + (Camera.CFrame.LookVector * 300))
                CreateBulletTracer(gunOrigin, targetPos)
            end)
        end
    end

    if _G.NoSpreadEnabled and LocalPlayer.Character then
        pcall(function()
            for _, tool in ipairs(LocalPlayer.Character:GetChildren()) do
                if tool:IsA("Tool") then
                    tool:SetAttribute("Spread", 0)
                    tool:SetAttribute("Recoil", 0)
                    tool:SetAttribute("Inaccuracy", 0)
                    tool:SetAttribute("Kickback", 0)
                end
            end
            local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
            if backpack then
                for _, tool in ipairs(backpack:GetChildren()) do
                    if tool:IsA("Tool") then
                        tool:SetAttribute("Spread", 0)
                        tool:SetAttribute("Recoil", 0)
                        tool:SetAttribute("Inaccuracy", 0)
                        tool:SetAttribute("Kickback", 0)
                    end
                end
            end
        end)
    end

    if _G.SkinChangerEnabled and LocalPlayer.Character then
        pcall(function()
            for _, item in ipairs(LocalPlayer.Character:GetChildren()) do
                if item:IsA("Tool") then
                    for _, part in ipairs(item:GetDescendants()) do
                        if part:IsA("BasePart") or part:IsA("MeshPart") then
                            part.Color = _G.SelectedSkinColor
                            part.Material = Enum.Material.Neon
                            if part:IsA("MeshPart") then
                                part.TextureID = ""
                            end
                        end
                    end
                end
            end
        end)
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then
            continue
        end

        local data = DrawingSupported and createPlayerDrawingObjects(player.Name) or nil

        if not isEnemy(player) then
            removeEsp(player.Name)
            continue
        end

        local char = getCharacter(player)
        
        if espEnabled and char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Head") and data and data.Box then
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
                    local isVis = IsVisibleFast(head)
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
                    removeEsp(player.Name)
                end
            else
                removeEsp(player.Name)
            end
        else
            removeEsp(player.Name)
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
