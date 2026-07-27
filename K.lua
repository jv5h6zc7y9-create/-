--[[
    TRIPLEWARE - FULL MOBILE & IPAD READY SCRIPT (NO CUTS)
    Includes: Floating Menu Toggle Button, FOV Circle, CS-Style ESP with Color Palette, Physics Snow
]]

local genv = getgenv()
print("Tripleware Mobile Loader Initialized...")

loadstring([=[
local allowedPlaces = {114234929420007, 108194354348181, 135434213652028}
if not table.find(allowedPlaces, game.PlaceId) then 
    game:GetService("Players").LocalPlayer:Kick("Неверная игра! Запускайте скрипт только в Blox Strike.")
    return 
end

game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Tripleware", Text = "Загружено успешно (iPad / Delta Mode)", Duration = 5})

local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local Players = game:GetService("Players")
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
    for _, c in pairs(Conn) do pcall(function() c:Disconnect() end) end
    for _, d in pairs(Drws) do pcall(function() if type(d) ~= "number" then d:Remove() end end) end
    table.clear(Conn)
    table.clear(Drws)
    pcall(function() if game:GetService("CoreGui"):FindFirstChild("TriplewareUI") then game:GetService("CoreGui").TriplewareUI:Destroy() end end)
    pcall(function() if game:GetService("CoreGui"):FindFirstChild("ESP_Highlight_Container") then game:GetService("CoreGui").ESP_Highlight_Container:Destroy() end end)
end

-- Конфигурация с запрошенными функциями
local Config = {
    Aimbot = {Enabled = true, FOV = 100, TeamCheck = true, DrawFOV = true, Smoothness = 5},
    VisualFX = {SnowEnabled = true, SnowColor = Color3.fromRGB(255, 255, 255), SnowIntensity = 40},
    ESP = {
        Enabled = true, 
        Box = true, 
        Name = true, 
        Health = true, 
        TeamCheck = true,
        VisibleColor = Color3.fromRGB(0, 255, 0),    -- Цвет, когда враг виден
        HiddenColor = Color3.fromRGB(255, 0, 0),     -- Цвет, когда враг за стеной
    }
}

-- Создание GUI интерфейса и плавающей кнопки для управления на iPad
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TriplewareUI"
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = game:GetService("CoreGui")

-- Плавающая кнопка для открытия/закрытия меню на экране планшета
local FloatBtn = Instance.new("TextButton")
FloatBtn.Name = "FloatingMenuToggle"
FloatBtn.Size = UDim2.new(0, 50, 0, 50)
FloatBtn.Position = UDim2.new(0, 20, 0, 100)
FloatBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
FloatBtn.BorderColor3 = Color3.fromRGB(0, 200, 255)
FloatBtn.TextColor3 = Color3.fromRGB(0, 200, 255)
FloatBtn.TextSize = 18
FloatBtn.Font = Enum.Font.SourceSansBold
FloatBtn.Text = "TW"
FloatBtn.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(1, 0)
UICorner.Parent = FloatBtn

-- Логика перетаскивания кнопки пальцем на мобильном / планшете
local dragging, dragInput, dragStart, startPos
FloatBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = FloatBtn.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

FloatBtn.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        FloatBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Главная панель меню (скрывается/показывается при нажатии на плавающую кнопку)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 400)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderColor3 = Color3.fromRGB(0, 200, 255)
MainFrame.Visible = true
MainFrame.Parent = ScreenGui

local MFCorner = Instance.new("UICorner")
MFCorner.CornerRadius = UDim.new(0, 8)
MFCorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "TRIPLEWARE | MOBILE HUB"
Title.TextColor3 = Color3.fromRGB(0, 200, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16
Title.Parent = MainFrame

FloatBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Создание круга Аима (FOV Circle) по центру экрана
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = Config.Aimbot.DrawFOV
FOVCircle.Radius = Config.Aimbot.FOV
FOVCircle.Color = Color3.fromRGB(0, 200, 255)
FOVCircle.Thickness = 1
FOVCircle.Filled = false
AD(FOVCircle)

RS.RenderStepped:Connect(function()
    local vpSize = Camera.ViewportSize
    FOVCircle.Position = Vector2.new(vpSize.X / 2, vpSize.Y / 2)
end)

-- Система падающего снега с физикой
local SnowParticles = {}
RS.RenderStepped:Connect(function()
    if Config.VisualFX.SnowEnabled then
        if #SnowParticles < Config.VisualFX.SnowIntensity then
            local snowflake = Drawing.new("Circle")
            snowflake.Radius = math.random(2, 5)
            snowflake.Filled = true
            snowflake.Color = Config.VisualFX.SnowColor
            snowflake.Transparency = math.random(4, 9) / 10
            snowflake.Visible = true
            local p = Vector2.new(math.random(0, Camera.ViewportSize.X), -10)
            table.insert(SnowParticles, {Obj = snowflake, Pos = p, Speed = math.random(40, 120)})
        end
        
        for i = #SnowParticles, 1, -1 do
            local snow = SnowParticles[i]
            -- Физика падения с легким покачиванием (синусоида)
            snow.Pos = snow.Pos + Vector2.new(math.sin(tick() + i) * 0.8, snow.Speed * 0.016)
            snow.Obj.Position = snow.Pos
            if snow.Pos.Y > Camera.ViewportSize.Y + 10 then
                snow.Obj:Remove()
                table.remove(SnowParticles, i)
            end
        end
    end
end)

-- Проверка на врагов для ESP и Аима
local function is_enemy(plr)
    if plr == LP then return false end
    if plr.Team and LP.Team then return plr.Team ~= LP.Team end
    return true
end

-- Простой и производительный ESP (ВХ) с цветами видимости
local ESPCache = {}
RS.RenderStepped:Connect(function()
    if not Config.ESP.Enabled then
        for _, obj in pairs(ESPCache) do
            if obj.Box then obj.Box:Remove() end
            if obj.Name then obj.Name:Remove() end
        end
        table.clear(ESPCache)
        return
    end

    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Humanoid") then
            if not Config.ESP.TeamCheck or is_enemy(plr) then
                local char = plr.Character
                local hrp = char.HumanoidRootPart
                local hum = char.Humanoid
                
                if hum.Health > 0 then
                    local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                    if onScreen then
                        if not ESPCache[plr] then
                            local box = Drawing.new("Square")
                            box.Visible = false
                            box.Thickness = 1
                            box.Filled = false
                            AD(box)
                            
                            local name = Drawing.new("Text")
                            name.Visible = false
                            name.Size = 13
                            name.Center = true
                            name.Outline = true
                            AD(name)
                            
                            ESPCache[plr] = {Box = box, Name = name}
                        end
                        
                        local data = ESPCache[plr]
                        local head = char:FindFirstChild("Head")
                        if head then
                            local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                            local legPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                            local height = math.abs(headPos.Y - legPos.Y)
                            local width = height / 2
                            
                            data.Box.Size = Vector2.new(width, height)
                            data.Box.Position = Vector2.new(headPos.X - width / 2, headPos.Y)
                            
                            -- Проверка видимости для переключения цветов палитры (Виден / Скрыт)
                            local parts = Camera:GetPartsObscuringTarget({head.Position}, {Camera.CFrame.Position, head.Position})
                            local isVisible = (#parts == 0)
                            
                            local chosenColor = isVisible and Config.ESP.VisibleColor or Config.ESP.HiddenColor
                            data.Box.Color = chosenColor
                            data.Box.Visible = Config.ESP.Box
                            
                            data.Name.Text = plr.Name .. " [" .. math.floor(hum.Health) .. "HP]"
                            data.Name.Position = Vector2.new(headPos.X, headPos.Y - 18)
                            data.Name.Color = chosenColor
                            data.Name.Visible = Config.ESP.Name
                        end
                    else
                        if ESPCache[plr] then
                            ESPCache[plr].Box.Visible = false
                            ESPCache[plr].Name.Visible = false
                        end
                    end
                else
                    if ESPCache[plr] then
                        ESPCache[plr].Box.Visible = false
                        ESPCache[plr].Name.Visible = false
                    end
                end
            end
        end
    end
end)

print("Tripleware Mobile Script Fully Loaded & Running!")
]=])
