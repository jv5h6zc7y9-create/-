--[=[
    SYLENT V1 - ADMIN MANAGEMENT GUI
    Тип: LocalScript (StarterPlayerScripts / StarterGui)
]=]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local TextChatService = game:GetService("TextChatService")
local Stats = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- Глобальные состояния и очистка
local Sylent = {
    Connections = {},
    Toggles = {},
    Instances = {},
    SpoofedHumanoid = nil,
    UI = nil
}

local function TrackConnection(conn)
    table.insert(Sylent.Connections, conn)
    return conn
end

-- === 1. ГЕНЕРАЦИЯ UI (GitHub Dark / iOS Style) ===
local Theme = {
    Bg = Color3.fromRGB(13, 17, 23),
    Panel = Color3.fromRGB(22, 27, 34),
    Text = Color3.fromRGB(201, 209, 217),
    Accent = Color3.fromRGB(47, 129, 247),
    Border = Color3.fromRGB(48, 54, 61)
}

local function Create(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props) do
        if k ~= "Parent" then inst[k] = v end
    end
    inst.Parent = props.Parent
    return inst
end

local ScreenGui = Create("ScreenGui", {Name = "SylentAdmin", ResetOnSpawn = false, Parent = LocalPlayer:WaitForChild("PlayerGui")})
Sylent.UI = ScreenGui

-- Лаунчер
local Launcher = Create("TextButton", {
    Parent = ScreenGui, Size = UDim2.new(0, 50, 0, 50), Position = UDim2.new(0.05, 0, 0.5, 0),
    BackgroundColor3 = Theme.Panel, Text = "⚡", TextSize = 24, TextColor3 = Theme.Accent, AutoButtonColor = false
})
Create("UICorner", {Parent = Launcher, CornerRadius = UDim.new(1, 0)})
Create("UIStroke", {Parent = Launcher, Color = Theme.Border, Thickness = 1})

-- Основная панель
local MainFrame = Create("Frame", {
    Parent = ScreenGui, Size = UDim2.new(0, 600, 0, 400), Position = UDim2.new(0.5, -300, 0.5, -200),
    BackgroundColor3 = Theme.Bg, Visible = false, ClipsDescendants = true
})
Create("UICorner", {Parent = MainFrame, CornerRadius = UDim.new(0, 8)})
Create("UIStroke", {Parent = MainFrame, Color = Theme.Border, Thickness = 1})

-- Drag Logic для Launcher
local dragging, dragInput, dragStart, startPos
Launcher.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Launcher.Position
    end
end)
Launcher.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        Launcher.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

Launcher.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
    if MainFrame.Visible then
        MainFrame.Size = UDim2.new(0, 600, 0, 0)
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 600, 0, 400)}):Play()
    end
end)

-- Layout
local TabContainer = Create("Frame", {Parent = MainFrame, Size = UDim2.new(0, 150, 1, 0), BackgroundColor3 = Theme.Panel})
local ContentContainer = Create("Frame", {Parent = MainFrame, Size = UDim2.new(1, -150, 1, 0), Position = UDim2.new(0, 150, 0, 0), BackgroundTransparency = 1})
local TabList = Create("UIListLayout", {Parent = TabContainer, SortOrder = Enum.SortOrder.LayoutOrder})

local ActiveTab = nil
local function CreateTab(name, icon)
    local TabBtn = Create("TextButton", {Parent = TabContainer, Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1, Text = " " .. icon .. " " .. name, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, Font = Enum.Font.GothamMedium, TextSize = 12})
    local Page = Create("ScrollingFrame", {Parent = ContentContainer, Size = UDim2.new(1, -20, 1, -20), Position = UDim2.new(0, 10, 0, 10), BackgroundTransparency = 1, Visible = false, ScrollBarThickness = 2})
    Create("UIListLayout", {Parent = Page, Padding = UDim.new(0, 8)})
    
    TabBtn.MouseButton1Click:Connect(function()
        for _, child in ipairs(ContentContainer:GetChildren()) do if child:IsA("ScrollingFrame") then child.Visible = false end end
        for _, child in ipairs(TabContainer:GetChildren()) do if child:IsA("TextButton") then child.TextColor3 = Theme.Text end end
        Page.Visible = true
        TabBtn.TextColor3 = Theme.Accent
    end)
    if not ActiveTab then ActiveTab = TabBtn; Page.Visible = true; TabBtn.TextColor3 = Theme.Accent end
    return Page
end

-- UI Компоненты
local function CreateToggle(parent, text, flag, callback)
    local Btn = Create("TextButton", {Parent = parent, Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = Theme.Panel, Text = "  " .. text, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, Font = Enum.Font.Gotham})
    Create("UICorner", {Parent = Btn, CornerRadius = UDim.new(0, 4)})
    local Indicator = Create("Frame", {Parent = Btn, Size = UDim2.new(0, 10, 0, 10), Position = UDim2.new(1, -20, 0.5, -5), BackgroundColor3 = Theme.Border})
    Create("UICorner", {Parent = Indicator, CornerRadius = UDim.new(1, 0)})
    Sylent.Toggles[flag] = false
    Btn.MouseButton1Click:Connect(function()
        Sylent.Toggles[flag] = not Sylent.Toggles[flag]
        Indicator.BackgroundColor3 = Sylent.Toggles[flag] and Theme.Accent or Theme.Border
        if callback then callback(Sylent.Toggles[flag]) end
    end)
end

local function CreateSlider(parent, text, min, max, callback)
    local Frame = Create("Frame", {Parent = parent, Size = UDim2.new(1, 0, 0, 45), BackgroundColor3 = Theme.Panel})
    Create("UICorner", {Parent = Frame, CornerRadius = UDim.new(0, 4)})
    Create("TextLabel", {Parent = Frame, Size = UDim2.new(1, -10, 0, 20), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = text, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, Font = Enum.Font.Gotham, TextSize = 12})
    local ValueLabel = Create("TextLabel", {Parent = Frame, Size = UDim2.new(0, 50, 0, 20), Position = UDim2.new(1, -60, 0, 0), BackgroundTransparency = 1, Text = tostring(min), TextColor3 = Theme.Accent, Font = Enum.Font.GothamBold, TextSize = 12})
    local SliderBg = Create("TextButton", {Parent = Frame, Size = UDim2.new(1, -20, 0, 5), Position = UDim2.new(0, 10, 0, 30), BackgroundColor3 = Theme.Bg, Text = ""})
    local SliderFill = Create("Frame", {Parent = SliderBg, Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = Theme.Accent})
    
    local isSliding = false
    local function update(input)
        local pct = math.clamp((input.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
        SliderFill.Size = UDim2.new(pct, 0, 1, 0)
        local val = math.floor(min + (max - min) * pct)
        ValueLabel.Text = tostring(val)
        if callback then callback(val) end
    end
    SliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isSliding = true; update(input)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if isSliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isSliding = false
        end
    end)
end

-- === 2. РЕАЛИЗАЦИЯ СИСТЕМ ===

-- Вкладка 1: МОДИФИКАЦИЯ ТЕЛА
local TabBody = CreateTab("МОДИФИКАЦИЯ ТЕЛА", "🏃‍♂️")
local Settings = {Speed = 16, Jump = 50, FlySpeed = 50}

-- Имитация Metatable Hook
local function GetHumanoid()
    local char = LocalPlayer.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

CreateSlider(TabBody, "WalkSpeed", 16, 200, function(val)
    Settings.Speed = val
    local hum = GetHumanoid()
    if hum then hum.WalkSpeed = val end
end)

CreateToggle(TabBody, "Бесконечный Прыжок (Inf Jump)", "InfJump", function() end)
TrackConnection(UserInputService.JumpRequest:Connect(function()
    if Sylent.Toggles["InfJump"] then
        local hum = GetHumanoid()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end))

local FlyBV, FlyBG
CreateToggle(TabBody, "Режим Полета (Fly)", "Fly", function(state)
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if state then
        workspace.Gravity = 0
        FlyBV = Create("BodyVelocity", {Parent = hrp, MaxForce = Vector3.new(math.huge, math.huge, math.huge), Velocity = Vector3.zero})
        FlyBG = Create("BodyGyro", {Parent = hrp, MaxTorque = Vector3.new(math.huge, math.huge, math.huge), CFrame = hrp.CFrame})
        table.insert(Sylent.Instances, FlyBV); table.insert(Sylent.Instances, FlyBG)
    else
        workspace.Gravity = 196.2
        if FlyBV then FlyBV:Destroy() end
        if FlyBG then FlyBG:Destroy() end
    end
end)
TrackConnection(RunService.RenderStepped:Connect(function()
    if Sylent.Toggles["Fly"] and FlyBV and FlyBG then
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local hum = GetHumanoid()
        if hrp and hum then
            FlyBG.CFrame = Camera.CFrame
            local moveDir = hum.MoveDirection
            FlyBV.Velocity = (moveDir == Vector3.zero) and Vector3.zero or (Camera.CFrame.LookVector * (moveDir.Z * -1) + Camera.CFrame.RightVector * moveDir.X) * Settings.FlySpeed
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then FlyBV.Velocity += Vector3.new(0, Settings.FlySpeed, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then FlyBV.Velocity -= Vector3.new(0, Settings.FlySpeed, 0) end
        end
    end
end))

CreateToggle(TabBody, "Проход Сквозь Стены (Noclip)", "Noclip", function() end)
TrackConnection(RunService.Stepped:Connect(function()
    if Sylent.Toggles["Noclip"] then
        if LocalPlayer.Character then
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end
end))

CreateToggle(TabBody, "Стабилизатор Физики (Anti-Fling)", "AntiFling", function() end)
TrackConnection(RunService.Stepped:Connect(function()
    if Sylent.Toggles["AntiFling"] then
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            if hrp.AssemblyAngularVelocity.Magnitude > 50 or hrp.AssemblyLinearVelocity.Magnitude > 200 then
                hrp.AssemblyAngularVelocity = Vector3.zero
                hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0)
            end
        end
    end
end))

-- Вкладка 2: ТЕСТ ФИЗИКИ
local TabPhysics = CreateTab("ТЕСТ ФИЗИКИ", "⚔️")
local FOVCircle = Create("Frame", {
    Parent = ScreenGui, Size = UDim2.new(0, 200, 0, 200), Position = UDim2.new(0.5, -100, 0.5, -100),
    BackgroundTransparency = 1, Visible = false
})
Create("UIStroke", {Parent = FOVCircle, Color = Theme.Text, Thickness = 1})
Create("UICorner", {Parent = FOVCircle, CornerRadius = UDim.new(1, 0)})

CreateToggle(TabPhysics, "Отрисовка круга FOV (Silent Aim)", "ShowFOV", function(state) FOVCircle.Visible = state end)
CreateSlider(TabPhysics, "Радиус FOV", 50, 500, function(val)
    FOVCircle.Size = UDim2.new(0, val * 2, 0, val * 2)
    FOVCircle.Position = UDim2.new(0.5, -val, 0.5, -val)
end)

CreateToggle(TabPhysics, "Усилитель Импульса (Mega-Throw)", "MegaThrow", function() end)
-- Симуляция: если предмет открепляется от персонажа (бросок), применяем импульс.
TrackConnection(LocalPlayer.CharacterAdded:Connect(function(char)
    TrackConnection(char.ChildRemoved:Connect(function(child)
        if Sylent.Toggles["MegaThrow"] and child:IsA("Tool") then
            local handle = child:FindFirstChild("Handle")
            if handle then
                handle.AssemblyLinearVelocity = Camera.CFrame.LookVector * 500
            end
        end
    end))
end))

CreateToggle(TabPhysics, "Разрыв Связей (Grab Break)", "GrabBreak", function() end)
TrackConnection(RunService.Stepped:Connect(function()
    if Sylent.Toggles["GrabBreak"] and LocalPlayer.Character then
        for _, v in ipairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("Weld") or v:IsA("WeldConstraint") then
                if not v.Part0:IsDescendantOf(LocalPlayer.Character) or not v.Part1:IsDescendantOf(LocalPlayer.Character) then
                    v:Destroy()
                end
            end
        end
    end
end))

-- Вкладка 3: ВИЗУАЛИЗАЦИЯ
local TabVis = CreateTab("ВИЗУАЛИЗАЦИЯ", "👁️")

local Highlights = {}
local function ESPPlayer(player)
    if player == LocalPlayer then return end
    local hl = Create("Highlight", {FillColor = Theme.Accent, OutlineColor = Color3.new(1,1,1), FillTransparency = 0.5, DepthMode = Enum.HighlightDepthMode.AlwaysOnTop})
    table.insert(Sylent.Instances, hl)
    local function apply(char) hl.Parent = char; Highlights[player] = hl end
    if player.Character then apply(player.Character) end
    TrackConnection(player.CharacterAdded:Connect(apply))
end

CreateToggle(TabVis, "Подсветка Игроков (ESP)", "ESP", function(state)
    if state then
        for _, p in ipairs(Players:GetPlayers()) do ESPPlayer(p) end
        TrackConnection(Players.PlayerAdded:Connect(ESPPlayer))
    else
        for _, hl in pairs(Highlights) do hl:Destroy() end
        table.clear(Highlights)
    end
end)

local oldAmbient, oldClock
CreateToggle(TabVis, "Постоянный День (Fullbright)", "Fullbright", function(state)
    if state then
        oldAmbient = Lighting.Ambient
        oldClock = Lighting.ClockTime
        Lighting.Ambient = Color3.new(1,1,1)
        Lighting.ClockTime = 14
    else
        Lighting.Ambient = oldAmbient or Color3.fromRGB(127,127,127)
        Lighting.ClockTime = oldClock or 14
    end
end)

CreateToggle(TabVis, "Potato PC Mode", "Potato", function(state)
    if state then
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic end
        end
    end
end)

-- Вкладка 4: СЕРВИСЫ
local TabServices = CreateTab("СЕРВИСЫ", "🏪")
local TargetBox = Create("TextBox", {Parent = TabServices, Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = Theme.Bg, TextColor3 = Theme.Text, PlaceholderText = "Имя цели для Fling", Font = Enum.Font.Gotham})
local FlingBtn = Create("TextButton", {Parent = TabServices, Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = Theme.Accent, Text = "Начать симуляцию столкновения (Fling)", TextColor3 = Color3.new(1,1,1), Font = Enum.Font.GothamBold})

FlingBtn.MouseButton1Click:Connect(function()
    local targetName = TargetBox.Text
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Name:lower():sub(1, #targetName) == targetName:lower() and p.Character then
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local t_hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp and t_hrp then
                local thrust = Create("BodyAngularVelocity", {Parent = hrp, AngularVelocity = Vector3.new(9999, 9999, 9999), MaxTorque = Vector3.new(math.huge, math.huge, math.huge)})
                table.insert(Sylent.Instances, thrust)
                hrp.CFrame = t_hrp.CFrame
                task.delay(1, function() thrust:Destroy() end)
            end
        end
    end
end)

CreateToggle(TabServices, "Аура Столкновений (Fling Aura)", "FlingAura", function(state)
    if state and LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local aura = Create("Part", {Parent = workspace, Size = Vector3.new(16, 2, 16), Transparency = 1, CanCollide = false, Massless = true})
            local weld = Create("Weld", {Parent = aura, Part0 = hrp, Part1 = aura})
            local spin = Create("BodyAngularVelocity", {Parent = aura, AngularVelocity = Vector3.new(0, 5000, 0), MaxTorque = Vector3.new(0, math.huge, 0)})
            table.insert(Sylent.Instances, aura)
            Sylent.AuraPart = aura
        end
    else
        if Sylent.AuraPart then Sylent.AuraPart:Destroy(); Sylent.AuraPart = nil end
    end
end)

local WeldBtn = Create("TextButton", {Parent = TabServices, Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = Color3.fromRGB(200, 50, 50), Text = "Массовая Сварка (Mass Weld)", TextColor3 = Color3.new(1,1,1), Font = Enum.Font.GothamBold})
WeldBtn.MouseButton1Click:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and not v.Anchored and not v:IsDescendantOf(char) then
            v.CFrame = hrp.CFrame
            Create("WeldConstraint", {Parent = v, Part0 = hrp, Part1 = v})
        end
    end
end)

-- Вкладка 5: МОНИТОРИНГ
local TabMon = CreateTab("МОНИТОРИНГ", "📊")
local StatsLabel = Create("TextLabel", {Parent = TabMon, Size = UDim2.new(1, 0, 0, 100), BackgroundTransparency = 1, TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, Font = Enum.Font.Code, TextSize = 12})

local VPF = Create("ViewportFrame", {Parent = TabMon, Size = UDim2.new(1, 0, 0, 150), BackgroundColor3 = Theme.Bg})
local VPF_Cam = Create("Camera", {Parent = VPF})
VPF.CurrentCamera = VPF_Cam

TrackConnection(RunService.RenderStepped:Connect(function()
    local ping = Stats.Network:FindFirstChild("ServerStatsItem") and Stats.Network.ServerStatsItem:FindFirstChild("Data Ping")
    local pingVal = ping and ping:GetValue() or 0
    local fps = workspace:GetRealPhysicsFPS()
    
    StatsLabel.Text = string.format(
        "👤 User: %s\n⏳ Account Age: %d days\n📡 Ping: %.1f ms\n⚙️ FPS: %.1f",
        LocalPlayer.Name, LocalPlayer.AccountAge, pingVal, fps
    )
end))

-- Кнопка Выгрузки
local UnloadBtn = Create("TextButton", {Parent = MainFrame, Size = UDim2.new(0, 130, 0, 30), Position = UDim2.new(0, 10, 1, -40), BackgroundColor3 = Color3.fromRGB(200, 50, 50), Text = "ВЫГРУЗИТЬ ПАНЕЛЬ", TextColor3 = Color3.new(1,1,1), Font = Enum.Font.GothamBold, TextSize = 10})
Create("UICorner", {Parent = UnloadBtn, CornerRadius = UDim.new(0, 4)})

UnloadBtn.MouseButton1Click:Connect(function()
    for _, conn in ipairs(Sylent.Connections) do
        if conn.Disconnect then conn:Disconnect() end
    end
    for _, inst in ipairs(Sylent.Instances) do
        if inst and inst.Parent then inst:Destroy() end
    end
    workspace.Gravity = 196.2
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = 16
        LocalPlayer.Character.Humanoid.JumpPower = 50
    end
    Lighting.Ambient = Color3.fromRGB(127, 127, 127)
    ScreenGui:Destroy()
end)

