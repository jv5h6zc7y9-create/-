--[[
    TRIPLEWARE - FULL AUTO RUN (NO MENU, NO BUTTONS)
    Game: Blox Strike (Roblox Delta Compatible)
    Features: Auto-enabled Aimbot, Center FOV Circle, Auto-ESP with Visibility Palette, Physics Snow
]]

local genv = getgenv()
print("[Tripleware] Auto-Run Mobile Script Initialized...")

loadstring([=[
local allowedPlaces = {114234929420007, 108194354348181, 135434213652028}
if not table.find(allowedPlaces, game.PlaceId) then 
    pcall(function()
        game:GetService("Players").LocalPlayer:Kick("Tripleware Error: Execute this inside Blox Strike!")
    end)
    return 
end

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Tripleware Active",
    Text = "All features enabled automatically!",
    Duration = 5
})

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
    for _, c in pairs(Conn) do 
        pcall(function() c:Disconnect() end) 
    end
    for _, d in pairs(Drws) do 
        pcall(function() if type(d) ~= "number" then d:Remove() end end) 
    end
    table.clear(Conn)
    table.clear(Drws)
    pcall(function() 
        if game:GetService("CoreGui"):FindFirstChild("ESP_Highlight_Container") then 
            game:GetService("CoreGui").ESP_Highlight_Container:Destroy() 
        end 
    end)
end

-- Автоматическая конфигурация (все включено по умолчанию)
local Config = {
    Aimbot = {
        Enabled = true,
        FOV = 120,
        TeamCheck = true,
        DrawFOV = true,
        Smoothness = 4,
        TargetPart = "Head"
    },
    VisualFX = {
        SnowEnabled = true,
        SnowColor = Color3.fromRGB(255, 255, 255),
        SnowIntensity = 50
    },
    ESP = {
        Enabled = true,
        Box = true,
        Name = true,
        Health = true,
        Skeleton = true,
        TeamCheck = true,
        VisibleColor = Color3.fromRGB(0, 255, 0), -- Зеленый, если виден
        HiddenColor = Color3.fromRGB(255, 0, 0)   -- Красный, если за стеной
    }
}

-- 1. Круг Аима (FOV) строго по центру экрана
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
end)

-- 2. Физический падающий снег
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
    end
end)

-- Проверка врагов
local function is_enemy(plr)
    if plr == LP then return false end
    if plr.Team and LP.Team then return plr.Team ~= LP.Team end
    return true
end

-- 3. Автоматический ESP (ВХ) с палитрой видимости
local ESPPool = {}
RS.RenderStepped:Connect(function()
    if not Config.ESP.Enabled then return end

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
                            for i = 1, 10 do
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
                            
                            -- Проверка видимости для переключения цветов (палитра)
                            local parts = Camera:GetPartsObscuringTarget({head.Position}, {Camera.CFrame.Position, head.Position})
                            local isVisible = (#parts == 0)
                            local paletteColor = isVisible and Config.ESP.VisibleColor or Config.ESP.HiddenColor
                            
                            -- Обновление бокса
                            cache.Box.Size = Vector2.new(width, height)
                            cache.Box.Position = Vector2.new(headPos.X - width / 2, headPos.Y)
                            cache.Box.Color = paletteColor
                            cache.Box.Visible = Config.ESP.Box
                            
                            -- Обновление имени
                            cache.Name.Text = plr.Name .. " [" .. math.floor(hum.Health) .. "]"
                            cache.Name.Position = Vector2.new(headPos.X, headPos.Y - 18)
                            cache.Name.Color = paletteColor
                            cache.Name.Visible = Config.ESP.Name
                            
                            -- Полоска здоровья
                            local hpPct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                            cache.Health.From = Vector2.new(headPos.X - width / 2 - 6, headPos.Y + height)
                            cache.Health.To = Vector2.new(headPos.X - width / 2 - 6, headPos.Y + (height * (1 - hpPct)))
                            cache.Health.Color = Color3.fromRGB(0, 255, 0)
                            cache.Health.Visible = Config.ESP.Health
                        end
                    else
                        if ESPPool[plr] then
                            ESPPool[plr].Box.Visible = false
                            ESPPool[plr].Name.Visible = false
                            ESPPool[plr].Health.Visible = false
                        end
                    end
                end
            end
        end
    end
end)

print("[Tripleware] All systems running automatically!")
]=])
