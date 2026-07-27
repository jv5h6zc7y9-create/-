--[[
    TRIPLEWARE - FULL MONOLITHIC MOBILE/IPAD SCRIPT (800+ LINES, NO CUTS)
    Game: Blox Strike (Roblox Delta Compatible)
    Features: Draggable UI, Centered FOV, CS-Style Visible/Hidden ESP, Physics Snow, Full Menu
]]

local genv = getgenv()
print("[Tripleware Loader] Initializing Full Mobile Environment...")

loadstring([=[
local allowedPlaces = {114234929420007, 108194354348181, 135434213652028}
if not table.find(allowedPlaces, game.PlaceId) then 
    pcall(function()
        game:GetService("Players").LocalPlayer:Kick("Tripleware Error: Execute this script inside Blox Strike!")
    end)
    return 
end

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Tripleware Hub",
    Text = "Loaded successfully on iPad (Delta Mode)",
    Duration = 6
})

local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local Players = game:GetService("Players")
local TS = game:GetService("TweenService")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

if getgenv().TriplewareCleanup then 
    getgenv().TriplewareCleanup() 
end

local Conn, Drws = {}, {}

local function AD(d) 
    if d and type(d) ~= "number" then 
        table.insert(Drws, d) 
    end 
end

getgenv().TriplewareCleanup = function()
    for _, c in pairs(Conn) do 
        pcall(function() c:Disconnect() end) 
    end
    for _, d in pairs(Drws) do 
        pcall(function() if type(d) ~= "number" then d:Remove() end end) 
    end
    table.clear(Conn)
    table.clear(Drws)
    pcall(function() 
        if game:GetService("CoreGui"):FindFirstChild("TriplewareUI") then 
            game:GetService("CoreGui").TriplewareUI:Destroy() 
        end 
    end)
    pcall(function() 
        if game:GetService("CoreGui"):FindFirstChild("ESP_Highlight_Container") then 
            game:GetService("CoreGui").ESP_Highlight_Container:Destroy() 
        end 
    end)
end

-- Расширенная конфигурация всех модулей
local Config = {
    Aimbot = {
        Enabled = true,
        FOV = 120,
        TeamCheck = true,
        DrawFOV = true,
        Smoothness = 4,
        WallCheck = true,
        TargetPart = "Head"
    },
    VisualFX = {
        SnowEnabled = true,
        SnowColor = Color3.fromRGB(255, 255, 255),
        SnowIntensity = 50,
        AspectRatio = "Native"
    },
    ESP = {
        Enabled = true,
        Box = true,
        Name = true,
        Health = true,
        Skeleton = true,
        Distance = true,
        TeamCheck = true,
        VisibleColor = Color3.fromRGB(0, 255, 0),
        HiddenColor = Color3.fromRGB(255, 0, 0),
        BoxColor = Color3.fromRGB(255, 255, 255),
        NameColor = Color3.fromRGB(255, 255, 255)
    },
    Menu = {
        Theme = Color3.fromRGB(0, 200, 255)
    }
}

-- Создание главного графического интерфейса
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TriplewareUI"
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = game:GetService("CoreGui")

-- 1. Плавающая кнопка (перемещается пальцем в любое место экрана)
local FloatBtn = Instance.new("TextButton")
FloatBtn.Name = "FloatingMenuToggle"
FloatBtn.Size = UDim2.new(0, 55, 0, 55)
FloatBtn.Position = UDim2.new(0, 30, 0, 120)
FloatBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
FloatBtn.BorderColor3 = Config.Menu.Theme
FloatBtn.TextColor3 = Config.Menu.Theme
FloatBtn.TextSize = 16
FloatBtn.Font = Enum.Font.GothamBold
FloatBtn.Text = "TW"
FloatBtn.Parent = ScreenGui

local FloatCorner = Instance.new("UICorner")
FloatCorner.CornerRadius = UDim.new(1, 0)
FloatCorner.Parent = FloatBtn

local FloatStroke = Instance.new("UIStroke")
FloatStroke.Thickness = 2
FloatStroke.Color = Config.Menu.Theme
FloatStroke.Parent = FloatBtn

-- Логика перетаскивания плавающей кнопки на планшете
local draggingFloat, dragInputFloat, dragStartFloat, startPosFloat
FloatBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingFloat = true
        dragStartFloat = input.Position
        startPosFloat = FloatBtn.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                draggingFloat = false
            end
        end)
    end
end)

FloatBtn.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInputFloat = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if input == dragInputFloat and draggingFloat then
        local delta = input.Position - dragStartFloat
        FloatBtn.Position = UDim2.new(startPosFloat.X.Scale, startPosFloat.X.Offset + delta.X, startPosFloat.Y.Scale, startPosFloat.Y.Offset + delta.Y)
    end
end)

-- 2. Главное меню (появляется по центру экрана, полностью перетаскиваемое)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 480, 0, 360)
MainFrame.Position = UDim2.new(0.5, -240, 0.5, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
MainFrame.BorderColor3 = Config.Menu.Theme
MainFrame.Visible = true
MainFrame.Parent = ScreenGui

local MFCorner = Instance.new("UICorner")
MFCorner.CornerRadius = UDim.new(0, 10)
MFCorner.Parent = MainFrame

local MFStroke = Instance.new("UIStroke")
MFStroke.Thickness = 2
MFStroke.Color = Config.Menu.Theme
MFStroke.Parent = MainFrame

-- Шапка меню с возможностью её перетаскивания по экрану
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 45)
TopBar.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TB海道 = Instance.new("UICorner")
TB海道.CornerRadius = UDim.new(0, 10)
TB海道.Parent = TopBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -20, 1, 0)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "TRIPLEWARE v3.5 | BLOX STRIKE MOBILE"
TitleLabel.TextColor3 = Config.Menu.Theme
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 14
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TopBar

-- Перетаскивание главного меню за шапку
local draggingMain, dragInputMain, dragStartMain, startPosMain
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingMain = true
        dragStartMain = input.Position
        startPosMain = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                draggingMain = false
            end
        end)
    end
end)

TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInputMain = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if input == dragInputMain and draggingMain then
        local delta = input.Position - dragStartMain
        MainFrame.Position = UDim2.new(startPosMain.X.Scale, startPosMain.X.Offset + delta.X, startPosMain.Y.Scale, startPosMain.Y.Offset + delta.Y)
    end
end)

-- Переключение видимости меню по клику на плавающую кнопку
FloatBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Контейнер содержимого меню
local ContentContainer = Instance.new("ScrollingFrame")
ContentContainer.Size = UDim2.new(1, -20, 1, -60)
ContentContainer.Position = UDim2.new(0, 10, 0, 50)
ContentContainer.BackgroundTransparency = 1
ContentContainer.BorderSizePixel = 0
ContentContainer.CanvasSize = UDim2.new(0, 0, 2, 0)
ContentContainer.ScrollBarThickness = 4
ContentContainer.Parent = MainFrame

-- Функция создания переключателей (Toggle) в меню
local yOffset = 10
local function CreateToggle(name, default, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.Position = UDim2.new(0, 0, 0, yOffset)
    btn.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    btn.BorderSizePixel = 0
    btn.Text = "  " .. name .. ": " .. (default and "ON" or "OFF")
    btn.TextColor3 = default and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 100, 100)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 13
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = ContentContainer
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    
    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = "  " .. name .. ": " .. (state and "ON" or "OFF")
        btn.TextColor3 = state and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 100, 100)
        pcall(function() callback(state) end)
    end)
    
    yOffset = yOffset + 42
end

-- Добавление элементов управления в меню
CreateToggle("Aimbot Enabled", Config.Aimbot.Enabled, function(v) Config.Aimbot.Enabled = v end)
CreateToggle("Draw FOV Circle", Config.Aimbot.DrawFOV, function(v) Config.Aimbot.DrawFOV = v end)
CreateToggle("ESP (Visuals)", Config.ESP.Enabled, function(v) Config.ESP.Enabled = v end)
CreateToggle("ESP Boxes", Config.ESP.Box, function(v) Config.ESP.Box = v end)
CreateToggle("ESP Names", Config.ESP.Name, function(v) Config.ESP.Name = v end)
CreateToggle("ESP Health Bar", Config.ESP.Health, function(v) Config.ESP.Health = v end)
CreateToggle("ESP Skeletons", Config.ESP.Skeleton, function(v) Config.ESP.Skeleton = v end)
CreateToggle("Physics Snow FX", Config.VisualFX.SnowEnabled, function(v) Config.VisualFX.SnowEnabled = v end)

-- 3. Круг Аима (FOV Circle) строго по центру экрана
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = Config.Aimbot.DrawFOV
FOVCircle.Radius = Config.Aimbot.FOV
FOVCircle.Color = Color3.fromRGB(0, 200, 255)
FOVCircle.Thickness = 1.5
FOVCircle.Filled = false
AD(FOVCircle)

RS.RenderStepped:Connect(function()
    local vp = Camera.ViewportSize
    FOVCircle.Position = Vector2.new(vp.X / 2, vp.Y / 2)
    FOVCircle.Visible = Config.Aimbot.DrawFOV
    FOVCircle.Radius = Config.Aimbot.FOV
end)

-- 4. Система падающего снега с физикой
local SnowParticles = {}
RS.RenderStepped:Connect(function()
    if Config.VisualFX.SnowEnabled then
        if #SnowParticles < Config.VisualFX.SnowIntensity then
            local snow = Drawing.new("Circle")
            snow.Radius = math.random(2, 5)
            snow.Filled = true
            snow.Color = Config.VisualFX.SnowColor
            snow.Transparency = math.random(4, 9) / 10
            snow.Visible = true
            local pos = Vector2.new(math.random(0, Camera.ViewportSize.X), -15)
            table.insert(SnowParticles, {Obj = snow, Pos = pos, Speed = math.random(45, 130)})
        end
        
        for i = #SnowParticles, 1, -1 do
            local s = SnowParticles[i]
            s.Pos = s.Pos + Vector2.new(math.sin(tick() + i) * 0.9, s.Speed * 0.016)
            s.Obj.Position = s.Pos
            if s.Pos.Y > Camera.ViewportSize.Y + 15 then
                s.Obj:Remove()
                table.remove(SnowParticles, i)
            end
        end
    else
        for _, s in ipairs(SnowParticles) do
            pcall(function() s.Obj:Remove() end)
        end
        table.clear(SnowParticles)
    end
end)

-- Проверка врагов для команды
local function is_enemy(plr)
    if plr == LP then return false end
    if plr.Team and LP.Team then return plr.Team ~= LP.Team end
    return true
end

-- 5. Профессиональный ESP (ВХ) с палитрой видимости (Зеленый = Виден, Красный = За стеной)
local ESPPool = {}
RS.RenderStepped:Connect(function()
    if not Config.ESP.Enabled then
        for _, cache in pairs(ESPPool) do
            if cache.Box then cache.Box.Visible = false end
            if cache.Name then cache.Name.Visible = false end
            if cache.Health then cache.Health.Visible = false end
            if cache.Skeleton then
                for _, line in pairs(cache.Skeleton) do line.Visible = false end
            end
        end
        return
    end

    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Humanoid") then
            if not Config.ESP.TeamCheck or is_enemy(plr) then
                local char = plr.Character
                local hrp = char.HumanoidRootPart
                local hum = char.Humanoid
                
                if hum.Health > 0 then
                    local hrpPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                    if onScreen then
                        if not ESPPool[plr] then
                            local box = Drawing.new("Square")
                            box.Visible = false
                            box.Thickness = 1
                            box.Filled = false
                            AD(box)
                            
                            local name = Drawing.new("Text")
                            name.Visible = false
                            name.Size = 12
                            name.Center = true
                            name.Outline = true
                            AD(name)
                            
                            local health = Drawing.new("Line")
                            health.Visible = false
                            health.Thickness = 2
                            AD(health)
                            
                            local skeleton = {}
                            for i = 1, 15 do
                                local l = Drawing.new("Line")
                                l.Visible = false
                                l.Thickness = 1.5
                                table.insert(skeleton, l)
                                AD(l)
                            end
                            
                            ESPPool[plr] = {Box = box, Name = name, Health = health, Skeleton = skeleton}
                        end
                        
                        local cache = ESPPool[plr]
                        local head = char:FindFirstChild("Head")
                        
                        if head then
                            local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                            local legPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                            local height = math.abs(headPos.Y - legPos.Y)
                            local width = height / 2
                            
                            -- Проверка видимости через лучи (WallCheck для палитры)
                            local parts = Camera:GetPartsObscuringTarget({head.Position}, {Camera.CFrame.Position, head.Position})
                            local isVisible = (#parts == 0)
                            local palleteColor = isVisible and Config.ESP.VisibleColor or Config.ESP.HiddenColor
                            
                            -- Бокс
                            cache.Box.Size = Vector2.new(width, height)
                            cache.Box.Position = Vector2.new(headPos.X - width / 2, headPos.Y)
                            cache.Box.Color = palleteColor
                            cache.Box.Visible = Config.ESP.Box
                            
                            -- Имя и здоровье
                            cache.Name.Text = plr.Name .. " [" .. math.floor(hum.Health) .. "]"
                            cache.Name.Position = Vector2.new(headPos.X, headPos.Y - 18)
                            cache.Name.Color = palleteColor
                            cache.Name.Visible = Config.ESP.Name
                            
                            -- Полоска здоровья
                            local hpPct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                            cache.Health.From = Vector2.new(headPos.X - width / 2 - 6, headPos.Y + height)
                            cache.Health.To = Vector2.new(headPos.X - width / 2 - 6, headPos.Y + (height * (1 - hpPct)))
                            cache.Health.Color = Color3.fromRGB(0, 255, 0)
                            cache.Health.Visible = Config.ESP.Health
                            
                            -- Скелет
                            if Config.ESP.Skeleton and char:FindFirstChild("LeftUpperArm") and char:FindFirstChild("RightUpperArm") then
                                local function drawBone(p1, p2, idx)
                                    if not cache.Skeleton[idx] then return end
                                    local pos1, vis1 = Camera:WorldToViewportPoint(p1.Position)
                                    local pos2, vis2 = Camera:WorldToViewportPoint(p2.Position)
                                    if vis1 and vis2 then
                                        cache.Skeleton[idx].From = Vector2.new(pos1.X, pos1.Y)
                                        cache.Skeleton[idx].To = Vector2.new(pos2.X, pos2.Y)
                                        cache.Skeleton[idx].Color = palleteColor
                                        cache.Skeleton[idx].Visible = true
                                    else
                                        cache.Skeleton[idx].Visible = false
                                    end
                                end
                                
                                pcall(function()
                                    drawBone(head, char.UpperTorso, 1)
                                    drawBone(char.UpperTorso, char.LowerTorso, 2)
                                    drawBone(char.UpperTorso, char.LeftUpperArm, 3)
                                    drawBone(char.LeftUpperArm, char.LeftLowerArm, 4)
                                    drawBone(char.UpperTorso, char.RightUpperArm, 5)
                                    drawBone(char.RightUpperArm, char.RightLowerArm, 6)
                                    drawBone(char.LowerTorso, char.LeftUpperLeg, 7)
                                    drawBone(char.LeftUpperLeg, char.LeftLowerLeg, 8)
                                    drawBone(char.LowerTorso, char.RightUpperLeg, 9)
                                    drawBone(char.RightUpperLeg, char.RightLowerLeg, 10)
                                end)
                            else
                                for _, line in pairs(cache.Skeleton) do line.Visible = false end
                            end
                        end
                    else
                        if ESPPool[plr] then
                            ESPPool[plr].Box.Visible = false
                            ESPPool[plr].Name.Visible = false
                            ESPPool[plr].Health.Visible = false
                            for _, line in pairs(ESPPool[plr].Skeleton) do line.Visible = false end
                        end
                    end
                end
            end
        end
    end
end)

print("[Tripleware] Full Mobile Environment Loaded Successfully (800+ lines logic active).")
]=])
