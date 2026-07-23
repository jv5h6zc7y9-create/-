--!strict
--[[
    Полный монолитный скрипт без сокращений: Fully Streamable Silent Aim + 
    Многоуровневая фильтрация союзников (TikTok ESP) + 
    Полноценный Скинченджер оружия/ножа + Удаление отдачи и разброса (No-Recoil / No-Spread)
]]--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local DrawingSupported = (Drawing ~= nil and type(Drawing.new) == "function")

-- Глобальные настройки всех функций
_G.SilentAimEnabled = false
_G.NoSpreadEnabled = false
_G.SkinChangerEnabled = false
_G.FullBrightEnabled = false
_G.AimFOV = 140
_G.SelectedSkinColor = Color3.fromRGB(255, 100, 0)
_G.ESPTheme = "Green"
_G.FOVYOffset = 0

-- Создание графического интерфейса меню
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BlockStrikeFullMonolith"
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
MainMenu.Size = UDim2.new(0, 380, 0, 720)
MainMenu.Position = UDim2.new(0.5, -190, 0.5, -360)
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
TitleLabel.Size = UDim2.new(1, 0, 0, 50)
TitleLabel.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
TitleLabel.Text = "⚡ FULL MONOLITH: AIM + ESP + SKIN + NO-RECOIL ⚡"
TitleLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
TitleLabel.TextSize = 11
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.Parent = MainMenu

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0.2, 0)
TitleCorner.Parent = TitleLabel

local CloseButton = Instance.new("TextButton")
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
ContentFrame.Size = UDim2.new(1, -20, 1, -70)
ContentFrame.Position = UDim2.new(0, 10, 0, 60)
ContentFrame.BackgroundTransparency = 1
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 850)
ContentFrame.ScrollBarThickness = 4
ContentFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 150)
ContentFrame.Parent = MainMenu

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 12)
UIListLayout.Parent = ContentFrame

local function createButton(name, text, defaultColor)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(1, 0, 0, 45)
    btn.BackgroundColor3 = defaultColor or Color3.fromRGB(25, 25, 30)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 15
    btn.Font = Enum.Font.SourceSansBold
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.2, 0)
    corner.Parent = btn
    
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.Color = Color3.fromRGB(40, 40, 45)
    stroke.Parent = btn
    
    btn.Parent = ContentFrame
    return btn
end

-- Создаем все кнопки меню для полного функционала
local SilentAimButton = createButton("SilentAimButton", "Silent Aim (В голову): ВЫКЛ")
local NoSpreadButton = createButton("NoSpreadButton", "Удаление Отдачи/Разброса: ВЫКЛ")
local SkinButton = createButton("SkinButton", "Скинченджер (Оружие + Нож): ВЫКЛ")
local ESPToggle = createButton("ESPToggle", "TikTok ESP (Без союзников): ВКЛ", Color3.fromRGB(0, 100, 60))
local ThemeButton = createButton("ThemeButton", "Цвет ВХ: Зеленый")
local FullBrightButton = createButton("FullBrightButton", "Ночное Виденье: ВЫКЛ")

MenuButton.MouseButton1Click:Connect(function() MainMenu.Visible = not MainMenu.Visible end)
CloseButton.MouseButton1Click:Connect(function() MainMenu.Visible = false end)

local screenCenter = Vector2.new(0, 0)
local function updateCenter()
    local viewportSize = Camera.ViewportSize
    local guiInset = GuiService:GetGuiInset()
    screenCenter = Vector2.new(viewportSize.X / 2, ((viewportSize.Y + guiInset.Y) / 2) + _G.FOVYOffset)
    FOVCircle.Position = UDim2.new(0, screenCenter.X, 0, screenCenter.Y)
end
Camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateCenter)
updateCenter()

FOVCircle.Size = UDim2.new(0, _G.AimFOV * 2, 0, _G.AimFOV * 2)

-- =========================================================
-- МНОГОУРОВНЕВАЯ ФУНКЦИЯ ПРОВЕРКИ СОЮЗНИКОВ (TEAM CHECK)
-- =========================================================
local function isEnemy(targetPlayer)
    if not targetPlayer or targetPlayer == LocalPlayer then return false end
    
    -- 1. Стандартная проверка команд Roblox
    if targetPlayer.Team and LocalPlayer.Team then
        if targetPlayer.Team ~= LocalPlayer.Team then
            return true
        else
            return false
        end
    end
    
    -- 2. Кастомные атрибуты команд ("Team")
    local localTeamAttr = LocalPlayer:GetAttribute("Team")
    local targetTeamAttr = targetPlayer:GetAttribute("Team")
    if localTeamAttr ~= nil and targetTeamAttr ~= nil then
        if localTeamAttr ~= targetTeamAttr then
            return true
        else
            return false
        end
    end
    
    -- 3. Атрибуты сторон ("Side")
    local localSideAttr = LocalPlayer:GetAttribute("Side")
    local targetSideAttr = targetPlayer:GetAttribute("Side")
    if localSideAttr ~= nil and targetSideAttr ~= nil then
        if localSideAttr ~= targetSideAttr then
            return true
        else
            return false
        end
    end
    
    -- 4. Внутриигровые объекты значений ValueObject
    local teamValueObj = targetPlayer:FindFirstChild("Team")
    local myTeamValueObj = LocalPlayer:FindFirstChild("Team")
    if teamValueObj and myTeamValueObj and teamValueObj:IsA("ValueBase") and myTeamValueObj:IsA("ValueBase") then
        if teamValueObj.Value ~= myTeamValueObj.Value then
            return true
        else
            return false
        end
    end
    
    return true
end

local function getCharacter(player)
    if player == LocalPlayer then return player.Character end
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Head") then 
        return char 
    end
    for _, child in ipairs(Workspace:GetChildren()) do
        if child:IsA("Model") and child.Name == player.Name then
            if child:FindFirstChild("HumanoidRootPart") and child:FindFirstChild("Head") then
                return child
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
    
    local _, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
    if not onScreen then return false end
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {character, targetPart.Parent}
    raycastParams.IgnoreWater = true
    
    local origin = Camera.CFrame.Position
    local direction = targetPart.Position - origin
    local raycastResult = workspace:Raycast(origin, direction, raycastParams)
    
    if raycastResult == nil or raycastResult.Instance:IsDescendantOf(targetPart.Parent) then
        return true
    end
    return false
end

-- =========================================================
-- SILENT AIM (ПОЛНЫЙ ИСХОДНИК ИЗ ВАШЕГО СКРИНШОТА)
-- =========================================================
local Aiming = {
    Selected = nil,
    SelectedPart = nil
}

function Aiming.Check()
    if not _G.SilentAimEnabled then return false end
    
    local targetHead = nil
    local shortestDistance = _G.AimFOV

    for _, player in ipairs(Players:GetPlayers()) do
        if not isEnemy(player) then continue end
        
        local char = getCharacter(player)
        if char and char:FindFirstChild("Head") and char:FindFirstChildOfClass("Humanoid") then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid.Health > 0 then
                local headPart = char.Head
                local screenPos, onScreen = Camera:WorldToViewportPoint(headPart.Position)
                
                if onScreen then
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                    if distance < shortestDistance then
                        if IsVisibleFast(headPart) then
                            shortestDistance = distance
                            targetHead = headPart
                        end
                    end
                end
            end
        end
    end

    if targetHead then
        Aiming.SelectedPart = targetHead
        return true
    end
    
    Aiming.SelectedPart = nil
    return false
end

-- Точный хук метаметода для перехвата Mouse Hit и Mouse Target
local __index
__index = hookmetamethod(game, "__index", function(t, k)
    if _G.SilentAimEnabled and t:IsA("Mouse") and (k == "Hit" or k == "Target") then
        if Aiming.Check() and Aiming.SelectedPart then
            local SelectedPart = Aiming.SelectedPart
            local prediction = 0.165
            local Hit = SelectedPart.CFrame + (SelectedPart.AssemblyLinearVelocity * prediction)
            
            if k == "Hit" then
                return Hit
            elseif k == "Target" then
                return SelectedPart
            end
        end
    end
    return __index(t, k)
end)

-- Логика кнопок интерфейса
SilentAimButton.MouseButton1Click:Connect(function()
    _G.SilentAimEnabled = not _G.SilentAimEnabled
    SilentAimButton.BackgroundColor3 = _G.SilentAimEnabled and Color3.fromRGB(0, 100, 60) or Color3.fromRGB(25, 25, 30)
    SilentAimButton.Text = _G.SilentAimEnabled and "Silent Aim (В голову): ВКЛ" or "Silent Aim (В голову): ВЫКЛ"
end)

NoSpreadButton.MouseButton1Click:Connect(function()
    _G.NoSpreadEnabled = not _G.NoSpreadEnabled
    NoSpreadButton.BackgroundColor3 = _G.NoSpreadEnabled and Color3.fromRGB(0, 100, 60) or Color3.fromRGB(25, 25, 30)
    NoSpreadButton.Text = _G.NoSpreadEnabled and "Удаление Отдачи/Разброса: ВКЛ" or "Удаление Отдачи/Разброса: ВЫКЛ"
end)

SkinButton.MouseButton1Click:Connect(function()
    _G.SkinChangerEnabled = not _G.SkinChangerEnabled
    SkinButton.BackgroundColor3 = _G.SkinChangerEnabled and Color3.fromRGB(0, 100, 60) or Color3.fromRGB(25, 25, 30)
    SkinButton.Text = _G.SkinChangerEnabled and "Скинченджер (Оружие + Нож): ВКЛ" or "Скинченджер (Оружие + Нож): ВЫКЛ"
end)

FullBrightButton.MouseButton1Click:Connect(function()
    _G.FullBrightEnabled = not _G.FullBrightEnabled
    FullBrightButton.BackgroundColor3 = _G.FullBrightEnabled and Color3.fromRGB(0, 100, 60) or Color3.fromRGB(25, 25, 30)
    FullBrightButton.Text = _G.FullBrightEnabled and "Ночное Виденье: ВКЛ" or "Ночное Виденье: ВЫКЛ"
end)

ThemeButton.MouseButton1Click:Connect(function()
    if _G.ESPTheme == "Green" then
        _G.ESPTheme = "Blue"
        ThemeButton.Text = "Цвет ВХ: Синий киберпанк"
    elseif _G.ESPTheme == "Blue" then
        _G.ESPTheme = "Yellow"
        ThemeButton.Text = "Цвет ВХ: Жёлтый янтарь"
    else
        _G.ESPTheme = "Green"
        ThemeButton.Text = "Цвет ВХ: Зеленый"
    end
end)

local espEnabled = true
ESPToggle.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    ESPToggle.BackgroundColor3 = espEnabled and Color3.fromRGB(0, 100, 60) or Color3.fromRGB(160, 30, 30)
    ESPToggle.Text = espEnabled and "TikTok ESP (Без союзников): ВКЛ" or "TikTok ESP (Без союзников): ВЫКЛ"
end)

local cacheDrawingObjects = {}
local function removeNativeEsp(playerName)
    local data = cacheDrawingObjects[playerName]
    if data then
        pcall(function()
            if data.Box then data.Box.Visible = false end
            if data.HpBackground then data.HpBackground.Visible = false end
            if data.HpFill then data.HpFill.Visible = false end
            if data.Text then data.Text.Visible = false end
            if data.WeaponText then data.WeaponText.Visible = false end
        end)
    end
end

local function createPlayerDrawingObjects(playerName)
    if not DrawingSupported then return nil end
    if not cacheDrawingObjects[playerName] then
        local data = {}
        pcall(function()
            data.Box = Drawing.new("Square")
            data.Box.Thickness = 1.5
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
            data.Text.Size = 13
            data.Text.Center = true
            data.Text.Outline = true
            data.Text.Visible = false

            data.WeaponText = Drawing.new("Text")
            data.WeaponText.Size = 12
            data.WeaponText.Center = true
            data.WeaponText.Outline = true
            data.WeaponText.Color = Color3.fromRGB(200, 200, 200)
            data.WeaponText.Visible = false
        end)
        cacheDrawingObjects[playerName] = data
    end
    return cacheDrawingObjects[playerName]
end

-- =========================================================
-- УДАЛЕНИЕ ОТДАЧИ И РАЗБРОСА (NO-RECOIL / NO-SPREAD)
-- =========================================================
RunService.RenderStepped:Connect(function()
    if _G.SilentAimEnabled then
        if Aiming.Check() then
            FOVStroke.Color = Color3.fromRGB(0, 255, 150)
            FOVCircle.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
        else
            FOVStroke.Color = Color3.fromRGB(255, 0, 0)
            FOVCircle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        end
    end

    if _G.FullBrightEnabled then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    end

    -- Активная очистка отдачи, разброса и качки оружия
    if _G.NoSpreadEnabled and LocalPlayer.Character then
        pcall(function()
            for _, tool in ipairs(LocalPlayer.Character:GetChildren()) do
                if tool:IsA("Tool") then
                    tool:SetAttribute("Spread", 0)
                    tool:SetAttribute("Recoil", 0)
                    tool:SetAttribute("RecoilForce", 0)
                    tool:SetAttribute("SpreadIncrement", 0)
                    tool:SetAttribute("Inaccuracy", 0)
                    tool:SetAttribute("Kickback", 0)
                    tool:SetAttribute("Sway", 0)
                    
                    for _, descendant in ipairs(tool:GetDescendants()) do
                        if descendant:IsA("ModuleScript") then
                            pcall(function()
                                local config = require(descendant)
                                if type(config) == "table" then
                                    if config.Recoil then config.Recoil = 0 end
                                    if config.RecoilForce then config.RecoilForce = 0 end
                                    if config.Spread then config.Spread = 0 end
                                    if config.SpreadIncrement then config.SpreadIncrement = 0 end
                                    if config.Inaccuracy then config.Inaccuracy = 0 end
                                    if config.Sway then config.Sway = 0 end
                                end
                            end)
                        end
                    end
                end
            end
        end)
    end
end)

-- =========================================================
-- ПОЛНОЦЕННЫЙ СКИНЧЕНДЖЕР (ОРУЖИЕ + НОЖИ)
-- =========================================================
local lastSkinApplied = {}
RunService.RenderStepped:Connect(function()
    if not _G.SkinChangerEnabled or not LocalPlayer.Character then
        lastSkinApplied = {}
        return
    end
    pcall(function()
        for _, item in ipairs(LocalPlayer.Character:GetChildren()) do
            if item:IsA("Tool") then
                if not lastSkinApplied[item] then
                    for _, part in ipairs(item:GetDescendants()) do
                        if part:IsA("BasePart") or part:IsA("MeshPart") then
                            part.Color = _G.SelectedSkinColor
                            part.Material = Enum.Material.Neon
                            if part:IsA("MeshPart") then
                                part.TextureID = ""
                            end
                        end
                    end
                    lastSkinApplied[item] = true
                end
            end
        end
    end)
end)

-- =========================================================
-- РЕНДЕР ESP С ЗАЩИТОЙ ОТ ТИМЕЙТОВ
-- =========================================================
local lastEspUpdate = 0
RunService.RenderStepped:Connect(function()
    if not espEnabled then return end
    if tick() - lastEspUpdate < 0.03 then return end
    lastEspUpdate = tick()

    local baseThemeColor = Color3.fromRGB(0, 255, 150)
    if _G.ESPTheme == "Blue" then
        baseThemeColor = Color3.fromRGB(0, 180, 255)
    elseif _G.ESPTheme == "Yellow" then
        baseThemeColor = Color3.fromRGB(255, 220, 0)
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end

        local data = DrawingSupported and createPlayerDrawingObjects(player.Name) or nil
        
        -- Многоуровневый фильтр: если это союзник, ВХ на него не выводится
        local enemyCheck = isEnemy(player)
        
        if enemyCheck == true then
            local char = getCharacter(player)
            if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Head") and data and data.Box then
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
                        
                        local isVisible = IsVisibleFast(head)
                        local dynamicColor = isVisible and baseThemeColor or Color3.fromRGB(255, 40, 40)
                        
                        data.Box.Size = Vector2.new(width, height)
                        data.Box.Position = Vector2.new(rPos.X - width / 2, topPos.Y)
                        data.Box.Color = dynamicColor
                        data.Box.Visible = true
                        
                        local healthRatio = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
                        data.HpBackground.Size = Vector2.new(3, height)
                        data.HpBackground.Position = Vector2.new(rPos.X - width / 2 - 6, topPos.Y)
                        data.HpBackground.Visible = true
                        
                        local fillHeight = height * healthRatio
                        data.HpFill.Size = Vector2.new(3, fillHeight)
                        data.HpFill.Position = Vector2.new(rPos.X - width / 2 - 6, topPos.Y + (height - fillHeight))
                        data.HpFill.Color = Color3.fromRGB(255 * (1 - healthRatio), 255 * healthRatio, 0)
                        data.HpFill.Visible = true
                        
                        local distance = math.floor((root.Position - Camera.CFrame.Position).Magnitude)
                        data.Text.Text = player.Name .. "\n[" .. distance .. "m]"
                        data.Text.Position = Vector2.new(rPos.X, topPos.Y - 32)
                        data.Text.Color = dynamicColor
                        data.Text.Visible = true

                        local tool = char:FindFirstChildOfClass("Tool")
                        data.WeaponText.Text = tool and tool.Name or "Hands"
                        data.WeaponText.Position = Vector2.new(rPos.X, topPos.Y + height + 4)
                        data.WeaponText.Color = dynamicColor
                        data.WeaponText.Visible = true
                    else
                        removeNativeEsp(player.Name)
                    end
                else
                    removeNativeEsp(player.Name)
                end
            else
                removeNativeEsp(player.Name)
            end
        else
            removeNativeEsp(player.Name)
        end
    end
end)
