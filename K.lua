--[=[
    SYLENT Research: Clean Visual ESP & Perfect Weapon Stabilization (No Fake Teleportation)
    Платформа: iPad / Mobile / PC
    Компоненты: ESP (Киберпанк-боксы) + NoRecoil/NoSpread/NoSway. БЕЗ АИМА (0% лагов).
--]=]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ЦВЕТОВАЯ ПАЛИТРА И НАСТРОЙКИ (КОПИЯ СКРИНШОТА)
local SETTINGS = {
    BoxColor = Color3.fromRGB(0, 255, 128),      -- Неоново-зеленый (как STIZZY1488 на скрине)
    TextColor = Color3.fromRGB(200, 200, 200),   -- Светло-серый/белый текст
    TextSize = 13,
    Font = 2,                                    -- Системный моноширинный шрифт
    UpdateInterval = 0.01                        -- Стабильный фреймрейт без просадок FPS
}

local Cache = {}
local LastUpdate = 0

-- Создание графики для ESP
local function CreateESP(player)
    if Cache[player] then return end
    
    local data = {
        Box = Drawing.new("Square"),
        HealthOutline = Drawing.new("Square"),
        HealthBar = Drawing.new("Square"),
        TopText = Drawing.new("Text"),
        BottomText = Drawing.new("Text")
    }
    
    -- Параметры контура бокса
    data.Box.Color = SETTINGS.BoxColor
    data.Box.Thickness = 1.5
    data.Box.Filled = false
    data.Box.Visible = false
    
    -- Параметры полоски здоровья
    data.HealthOutline.Color = Color3.fromRGB(0, 0, 0)
    data.HealthOutline.Thickness = 1
    data.HealthOutline.Filled = true
    data.HealthOutline.Visible = false
    
    data.HealthBar.Filled = true
    data.HealthBar.Visible = false
    
    -- Текст сверху (Ник + Дистанция)
    data.TopText.Color = SETTINGS.TextColor
    data.TopText.Size = SETTINGS.TextSize
    data.TopText.Center = true
    data.TopText.Outline = true
    data.TopText.Font = SETTINGS.Font
    data.TopText.Visible = false
    
    -- Текст снизу (Оружие)
    data.BottomText.Color = SETTINGS.TextColor
    data.BottomText.Size = SETTINGS.TextSize
    data.BottomText.Center = true
    data.BottomText.Outline = true
    data.BottomText.Font = SETTINGS.Font
    data.BottomText.Visible = false
    
    Cache[player] = data
end

-- Очистка памяти при выходе игрока
local function RemoveESP(player)
    if Cache[player] then
        for _, drawingObj in pairs(Cache[player]) do
            drawingObj:Remove()
        end
        Cache[player] = nil
    end
end

-- Инициализация игроков
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then CreateESP(p) end
end
Players.PlayerAdded:Connect(function(p)
    if p ~= LocalPlayer then CreateESP(p) end
end)
Players.PlayerRemoving:Connect(RemoveESP)

-- СТАБИЛИЗАЦИЯ ОРУЖИЯ (БЕЗ ОТДАЧИ, БЕЗ РАЗБРОСА, БЕЗ УВОДА СТВОЛА ВВЕРХ)
local function StabilizeWeapon(tool)
    if not tool:IsA("Tool") then return end
    
    -- Полный список параметров, отвечающих за увод прицела вверх, тряску и разброс
    local AntiRecoilProperties = {
        "Recoil", "Spread", "Inaccuracy", "Kickback", "MaxSpread", "MinSpread",
        "VisualRecoil", "Sway", "CameraShake", "RecoilForce", "UpwardRecoil"
    }
    
    -- Сброс через внутренние атрибуты Roblox движка
    for _, prop in ipairs(AntiRecoilProperties) do
        if tool:GetAttribute(prop) ~= nil then
            tool:SetAttribute(prop, 0)
        end
        pcall(function() tool[prop] = 0 end)
    end
    
    -- Сброс через конфигурационные таблицы внутри оружия
    for _, child in ipairs(tool:GetDescendants()) do
        if child:IsA("ModuleScript") then
            local success, module = pcall(require, child)
            if success and type(module) == "table" then
                for key, val in pairs(module) do
                    if type(val) == "number" then
                        local lowerKey = key:lower()
                        -- Полное уничтожение любых упоминаний отдачи, разброса и увода камеры вверх
                        if lowerKey:find("recoil") or lowerKey:find("spread") or lowerKey:find("inacc") or 
                           lowerKey:find("kick") or lowerKey:find("sway") or lowerKey:find("shake") or 
                           lowerKey:find("upward") then
                            module[key] = 0
                        end
                    end
                end
            end
        end
    end
end

-- Слежение за сменой оружия персонажа и инвентаря
local function TrackCharacter(char)
    char.ChildAdded:Connect(StabilizeWeapon)
    for _, child in ipairs(char:GetChildren()) do StabilizeWeapon(child) end
end

LocalPlayer.CharacterAdded:Connect(TrackCharacter)
if LocalPlayer.Character then TrackCharacter(LocalPlayer.Character) end
LocalPlayer.Backpack.ChildAdded:Connect(StabilizeWeapon)
for _, item in ipairs(LocalPlayer.Backpack:GetChildren()) do StabilizeWeapon(item) end

-- ЦИКЛ ОТРЕСОВКИ ВХ БЕЗ НАГРУЗКИ НА ПРОЦЕССОР
RunService.RenderStepped:Connect(function()
    local now = os.clock()
    if now - LastUpdate < SETTINGS.UpdateInterval then return end
    LastUpdate = now

    for player, esp in pairs(Cache) do
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        
        -- Показ элементов только если враг жив и не в вашей команде
        if character and humanoid and rootPart and humanoid.Health > 0 and player.Team ~= LocalPlayer.Team then
            local pos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
            
            if onScreen then
                -- Динамическое масштабирование коробки под расстояние (как на скриншоте)
                local distance = (Camera.CFrame.Position - rootPart.Position).Magnitude
                local factor = 1 / (distance * math.tan(math.rad(Camera.FieldOfView / 2))) * 1000
                local width, height = 4.2 * factor, 5.5 * factor
                
                local boxX = pos.X - width / 2
                local boxY = pos.Y - height / 2
                
                -- 1. Рисуем 2D Бокс вокруг врага
                esp.Box.Size = Vector2.new(width, height)
                esp.Box.Position = Vector2.new(boxX, boxY)
                esp.Box.Visible = true
                
                -- 2. Вертикальная полоска здоровья (Health Bar) слева от бокса
                local healthPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
                local barHeight = height
                local barWidth = 2.5
                local barX = boxX - 6
                
                esp.HealthOutline.Size = Vector2.new(barWidth + 2, barHeight + 2)
                esp.HealthOutline.Position = Vector2.new(barX - 1, boxY - 1)
                esp.HealthOutline.Visible = true
                
                esp.HealthBar.Size = Vector2.new(barWidth, barHeight * healthPercent)
                esp.HealthBar.Position = Vector2.new(barX, boxY + (barHeight * (1 - healthPercent)))
                -- Градиент здоровья: от зеленого (100% HP) к красному (0% HP)
                esp.HealthBar.Color = Color3.fromHSV(healthPercent * 0.33, 1, 1) 
                esp.HealthBar.Visible = true
                
                -- 3. Верхний текст (Ник + Расстояние в метрах)
                esp.TopText.Text = string.format("%s\n%dm", player.Name, math.floor(distance))
                esp.TopText.Position = Vector2.new(pos.X, boxY - 30)
                esp.TopText.Visible = true
                
                -- 4. Нижний текст (Название оружия в руках)
                local activeWeapon = "Hands"
                local weaponTool = character:FindFirstChildOfClass("Tool")
                if weaponTool then activeWeapon = weaponTool.Name end
                
                esp.BottomText.Text = activeWeapon
                esp.BottomText.Position = Vector2.new(pos.X, boxY + height + 6)
                esp.BottomText.Visible = true
            else
                -- Скрытие элементов за экраном
                esp.Box.Visible = false
                esp.HealthOutline.Visible = false
                esp.HealthBar.Visible = false
                esp.TopText.Visible = false
                esp.BottomText.Visible = false
            end
        else
            -- Скрытие элементов мертвых игроков
            esp.Box.Visible = false
            esp.HealthOutline.Visible = false
            esp.HealthBar.Visible = false
            esp.TopText.Visible = false
            esp.BottomText.Visible = false
        end
    end
end)
