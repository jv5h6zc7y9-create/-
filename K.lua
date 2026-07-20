local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local TextChatService = game:GetService("TextChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Stats = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- [ GLOBAL STATE MANAGEMENT ] --
local State = {
    Movement = { WalkSpeed = 16, JumpPower = 50, UseWS = false, UseJP = false, InfJump = false, Fly = false, FlySpeed = 50, Noclip = false, Stabilizer = false, Ascend = false, Descend = false },
    Interaction = { AutoInteract = false, ClickGrab = false, TargetPart = "HumanoidRootPart", Prediction = 1, Momentum = false, MomentumForce = 50000, AntiGrab = false },
    Environment = { ESPBoxes = false, ESPTracers = false, ESPNames = false, ESPHealth = false, ESPThickness = 1, ESPTransparency = 0, Fullbright = false, Potato = false },
    Chaos = { CrownVortex = false, ThrowForce = 150000, FlingTarget = "", ChatSpam = false, ChatMessage = "Testing physics diagnostics..." },
    Connections = {},
    ESPInstances = {},
    CachedCFrame = CFrame.new(),
    OriginalLighting = { Ambient = Lighting.Ambient, OutdoorAmbient = Lighting.OutdoorAmbient, ClockTime = Lighting.ClockTime, FogEnd = Lighting.FogEnd, GlobalShadows = Lighting.GlobalShadows }
}

-- [ METATABLE HOOK: PREVENT RUBBERBANDING ] --
local rawmt = getrawmetatable(game)
if rawmt and setreadonly and newcclosure then
    setreadonly(rawmt, false)
    local oldIndex = rawmt.__index
    local oldNewIndex = rawmt.__newindex
    
    rawmt.__index = newcclosure(function(t, k)
        if not checkcaller() and t:IsA("Humanoid") then
            if k == "WalkSpeed" and State.Movement.UseWS then return 16 end
            if k == "JumpPower" and State.Movement.UseJP then return 50 end
        end
        return oldIndex(t, k)
    end)
    
    rawmt.__newindex = newcclosure(function(t, k, v)
        if not checkcaller() and t:IsA("Humanoid") then
            if k == "WalkSpeed" and State.Movement.UseWS then return end
            if k == "JumpPower" and State.Movement.UseJP then return end
        end
        return oldNewIndex(t, k, v)
    end)
    setreadonly(rawmt, true)
end

-- [ GITHUB DARK THEME CONSTANTS ] --
local Colors = {
    Background = Color3.fromRGB(13, 17, 23),
    Sidebar = Color3.fromRGB(22, 27, 34),
    Accent = Color3.fromRGB(31, 111, 235),
    Text = Color3.fromRGB(201, 209, 217),
    Border = Color3.fromRGB(48, 54, 61),
    Red = Color3.fromRGB(248, 81, 73),
    Green = Color3.fromRGB(63, 185, 80)
}

-- [ UI INSTANCE BUILDER ] --
local UI = Instance.new("ScreenGui")
UI.Name = "AdminPhysicsToolbox"
UI.ResetOnSpawn = false
UI.IgnoreGuiInset = true
pcall(function() UI.Parent = CoreGui end)
if not UI.Parent then UI.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local function ApplyCorner(inst, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = inst
end

local function ApplyStroke(inst)
    local stroke = Instance.new("UIStroke")
    stroke.Color = Colors.Border
    stroke.Thickness = 1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = inst
end

local function Create(className, properties)
    local inst = Instance.new(className)
    for k, v in pairs(properties) do inst[k] = v end
    return inst
end

-- [ DRAGGABLE WIDGET LAUNCHER ] --
local Launcher = Create("TextButton", {
    Name = "Launcher", Parent = UI, Size = UDim2.new(0, 48, 0, 48), Position = UDim2.new(0.05, 0, 0.4, 0),
    BackgroundColor3 = Colors.Sidebar, Text = "⚡", TextColor3 = Colors.Accent, Font = Enum.Font.GothamBold, TextSize = 24, ZIndex = 100
})
ApplyCorner(Launcher, 24)
ApplyStroke(Launcher)

local draggingWidget, dragStart, startPosWidget
Launcher.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingWidget = true
        dragStart = input.Position
        startPosWidget = Launcher.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then draggingWidget = false end
        end)
    end
end)
Launcher.InputChanged:Connect(function(input)
    if draggingWidget and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        Launcher.Position = UDim2.new(startPosWidget.X.Scale, startPosWidget.X.Offset + delta.X, startPosWidget.Y.Scale, startPosWidget.Y.Offset + delta.Y)
    end
end)

-- [ MAIN PANEL FRAME ] --
local MainPanel = Create("Frame", {
    Name = "MainPanel", Parent = UI, Size = UDim2.new(0, 600, 0, 400), Position = UDim2.new(0.5, -300, 0.5, -200),
    BackgroundColor3 = Colors.Background, Visible = false, ClipsDescendants = true
})
ApplyCorner(MainPanel, 8)
ApplyStroke(MainPanel)

Launcher.MouseButton1Click:Connect(function()
    if MainPanel.Visible then
        TweenService:Create(MainPanel, TweenInfo.new(0.2, Enum.EasingStyle.Sine), { Size = UDim2.new(0, 600, 0, 0) }):Play()
        task.wait(0.2)
        MainPanel.Visible = false
    else
        MainPanel.Size = UDim2.new(0, 600, 0, 0)
        MainPanel.Visible = true
        TweenService:Create(MainPanel, TweenInfo.new(0.2, Enum.EasingStyle.Sine), { Size = UDim2.new(0, 600, 0, 400) }):Play()
    end
end)

local Sidebar = Create("Frame", { Name = "Sidebar", Parent = MainPanel, Size = UDim2.new(0, 150, 1, 0), BackgroundColor3 = Colors.Sidebar, BorderSizePixel = 0 })
local SidebarList = Create("UIListLayout", { Parent = Sidebar, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4) })
Create("UIPadding", { Parent = Sidebar, PaddingTop = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) })

local ContentContainer = Create("Frame", { Name = "Content", Parent = MainPanel, Size = UDim2.new(1, -150, 1, 0), Position = UDim2.new(0, 150, 0, 0), BackgroundTransparency = 1 })

local Tabs = {}
local function CreateTab(name, icon)
    local page = Create("ScrollingFrame", { Parent = ContentContainer, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false, ScrollBarThickness = 4, ScrollBarImageColor3 = Colors.Border, CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y })
    Create("UIListLayout", { Parent = page, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8) })
    Create("UIPadding", { Parent = page, PaddingTop = UDim.new(0, 12), PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12) })
    
    local btn = Create("TextButton", { Parent = Sidebar, Size = UDim2.new(1, 0, 0, 35), BackgroundColor3 = Colors.Background, Text = icon .. " " .. name, TextColor3 = Colors.Text, Font = Enum.Font.GothamSemibold, TextSize = 13, AutoButtonColor = false })
    ApplyCorner(btn, 6)
    ApplyStroke(btn)
    
    btn.MouseButton1Click:Connect(function()
        for _, t in pairs(Tabs) do t.Page.Visible = false; t.Btn.BackgroundColor3 = Colors.Background end
        page.Visible = true
        btn.BackgroundColor3 = Colors.Accent
    end)
    Tabs[name] = { Page = page, Btn = btn }
    return page
end

local function UI_Section(parent, titleText)
    local lbl = Create("TextLabel", { Parent = parent, Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, Text = titleText, TextColor3 = Colors.Accent, Font = Enum.Font.GothamBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left })
end

local function UI_Toggle(parent, text, category, key, callback)
    local frame = Create("Frame", { Parent = parent, Size = UDim2.new(1, 0, 0, 35), BackgroundColor3 = Colors.Sidebar })
    ApplyCorner(frame, 6); ApplyStroke(frame)
    Create("TextLabel", { Parent = frame, Size = UDim2.new(1, -60, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = text, TextColor3 = Colors.Text, Font = Enum.Font.Gotham, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left })
    
    local btn = Create("TextButton", { Parent = frame, Size = UDim2.new(0, 40, 0, 20), Position = UDim2.new(1, -50, 0.5, -10), BackgroundColor3 = Colors.Background, Text = "" })
    ApplyCorner(btn, 10); ApplyStroke(btn)
    local indicator = Create("Frame", { Parent = btn, Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(0, 3, 0.5, -7), BackgroundColor3 = Colors.Text })
    ApplyCorner(indicator, 7)
    
    btn.MouseButton1Click:Connect(function()
        State[category][key] = not State[category][key]
        local active = State[category][key]
        TweenService:Create(indicator, TweenInfo.new(0.15), { Position = active and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7), BackgroundColor3 = active and Colors.Accent or Colors.Text }):Play()
        if callback then callback(active) end
    end)
end

local function UI_Slider(parent, text, min, max, current, category, key)
    local frame = Create("Frame", { Parent = parent, Size = UDim2.new(1, 0, 0, 50), BackgroundColor3 = Colors.Sidebar })
    ApplyCorner(frame, 6); ApplyStroke(frame)
    local lbl = Create("TextLabel", { Parent = frame, Size = UDim2.new(1, -20, 0, 20), Position = UDim2.new(0, 10, 0, 5), BackgroundTransparency = 1, Text = text .. ": " .. tostring(current), TextColor3 = Colors.Text, Font = Enum.Font.Gotham, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left })
    
    local track = Create("Frame", { Parent = frame, Size = UDim2.new(1, -20, 0, 6), Position = UDim2.new(0, 10, 0, 32), BackgroundColor3 = Colors.Background })
    ApplyCorner(track, 3); ApplyStroke(track)
    local fill = Create("Frame", { Parent = track, Size = UDim2.new((current - min)/(max - min), 0, 1, 0), BackgroundColor3 = Colors.Accent })
    ApplyCorner(fill, 3)
    local knob = Create("TextButton", { Parent = fill, Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(1, -6, 0.5, -6), BackgroundColor3 = Colors.Text, Text = "" })
    ApplyCorner(knob, 6)
    
    local sliding = false
    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliding = true end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliding = false end
    end)
    table.insert(State.Connections, RunService.RenderStepped:Connect(function()
        if sliding then
            local ratio = math.clamp((UserInputService:GetMouseLocation().X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            fill.Size = UDim2.new(ratio, 0, 1, 0)
            local val = math.floor(min + ((max - min) * ratio))
            State[category][key] = val
            lbl.Text = text .. ": " .. tostring(val)
        end
    end))
end

local function UI_Button(parent, text, color, callback)
    local btn = Create("TextButton", { Parent = parent, Size = UDim2.new(1, 0, 0, 35), BackgroundColor3 = color, Text = text, TextColor3 = Colors.Text, Font = Enum.Font.GothamBold, TextSize = 13 })
    ApplyCorner(btn, 6); ApplyStroke(btn)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local function UI_TextBox(parent, placeholder, category, key)
    local box = Create("TextBox", { Parent = parent, Size = UDim2.new(1, 0, 0, 35), BackgroundColor3 = Colors.Background, Text = State[category][key], PlaceholderText = placeholder, TextColor3 = Colors.Text, Font = Enum.Font.Gotham, TextSize = 13, ClearTextOnFocus = false })
    ApplyCorner(box, 6); ApplyStroke(box)
    box.FocusLost:Connect(function() State[category][key] = box.Text end)
end

local function UI_Selector(parent, text, options, category, key)
    local frame = Create("Frame", { Parent = parent, Size = UDim2.new(1, 0, 0, 35), BackgroundColor3 = Colors.Sidebar })
    ApplyCorner(frame, 6); ApplyStroke(frame)
    Create("TextLabel", { Parent = frame, Size = UDim2.new(0.5, 0, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = text, TextColor3 = Colors.Text, Font = Enum.Font.Gotham, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left })
    local btn = Create("TextButton", { Parent = frame, Size = UDim2.new(0.5, -10, 1, -10), Position = UDim2.new(0.5, 0, 0, 5), BackgroundColor3 = Colors.Background, Text = options[1], TextColor3 = Colors.Accent, Font = Enum.Font.GothamBold, TextSize = 12 })
    ApplyCorner(btn, 4); ApplyStroke(btn)
    
    local idx = 1
    btn.MouseButton1Click:Connect(function()
        idx = (idx % #options) + 1
        btn.Text = options[idx]
        State[category][key] = options[idx]
    end)
end

-- [ BUILD TAB CONTENT ] --
local tMove = CreateTab("Movement", "🏃‍♂️")
local tCombat = CreateTab("Interaction", "⚔️")
local tVisual = CreateTab("Environment", "👁️")
local tChaos = CreateTab("Chaos", "🤡")
local tProfile = CreateTab("Diagnostics", "📊")
local tSystem = CreateTab("System", "🛡️")

Tabs["Movement"].Page.Visible = true
Tabs["Movement"].Btn.BackgroundColor3 = Colors.Accent

-- MOVEMENT TAB
UI_Section(tMove, "Humanoid Modifiers")
UI_Toggle(tMove, "Override WalkSpeed", "Movement", "UseWS")
UI_Slider(tMove, "WalkSpeed Limit", 16, 300, 16, "Movement", "WalkSpeed")
UI_Toggle(tMove, "Override JumpPower", "Movement", "UseJP")
UI_Slider(tMove, "JumpPower Limit", 50, 400, 50, "Movement", "JumpPower")
UI_Toggle(tMove, "Infinite Airborne Jump", "Movement", "InfJump")
UI_Section(tMove, "Physics Flight")
UI_Toggle(tMove, "Enable Physics Flight", "Movement", "Fly")
UI_Slider(tMove, "Flight Velocity", 20, 300, 50, "Movement", "FlySpeed")
UI_Section(tMove, "World Collision")
UI_Toggle(tMove, "Noclip Entities", "Movement", "Noclip")
UI_Toggle(tMove, "Motion Stabilizer (Lock Velocity)", "Movement", "Stabilizer")

-- INTERACTION TAB
UI_Section(tCombat, "Automation")
UI_Toggle(tCombat, "Proximity Auto-Interact (5 Studs)", "Interaction", "AutoInteract")
UI_Section(tCombat, "Raycast Interception")
UI_Toggle(tCombat, "Click-To-Grab Selection", "Interaction", "ClickGrab")
UI_Selector(tCombat, "Target Alignment Joint", {"HumanoidRootPart", "Head", "Torso"}, "Interaction", "TargetPart")
UI_Slider(tCombat, "Velocity Look-Ahead Prediction", 0, 30, 1, "Interaction", "Prediction")
UI_Section(tCombat, "Kinetics")
UI_Toggle(tCombat, "Momentum Force Multiplier", "Interaction", "Momentum")
UI_Slider(tCombat, "Multiplier Force", 5000, 2000000, 50000, "Interaction", "MomentumForce")
UI_Toggle(tCombat, "Recovery Anchor (Anti-Grab Vector)", "Interaction", "AntiGrab")

-- ENVIRONMENT TAB
UI_Section(tVisual, "Tracking Frames (ESP)")
UI_Toggle(tVisual, "Render Bounding Boxes", "Environment", "ESPBoxes", function(state) if not state then for _, esp in pairs(State.ESPInstances) do if esp.Box then esp.Box.Visible = false end end end end)
UI_Toggle(tVisual, "Render Origin Tracers", "Environment", "ESPTracers", function(state) if not state then for _, esp in pairs(State.ESPInstances) do if esp.Tracer then esp.Tracer.Visible = false end end end end)
UI_Toggle(tVisual, "Render Identity Tags", "Environment", "ESPNames", function(state) if not state then for _, esp in pairs(State.ESPInstances) do if esp.NameLbl then esp.NameLbl.Visible = false end end end end)
UI_Toggle(tVisual, "Render Health Metrics", "Environment", "ESPHealth", function(state) if not state then for _, esp in pairs(State.ESPInstances) do if esp.HealthLbl then esp.HealthLbl.Visible = false end end end end)
UI_Slider(tVisual, "Stroke Thickness", 1, 5, 1, "Environment", "ESPThickness")
UI_Section(tVisual, "Atmosphere Override")
UI_Toggle(tVisual, "Global Fullbright Mode", "Environment", "Fullbright", function(state)
    if not state then
        Lighting.Ambient = State.OriginalLighting.Ambient
        Lighting.OutdoorAmbient = State.OriginalLighting.OutdoorAmbient
        Lighting.ClockTime = State.OriginalLighting.ClockTime
        Lighting.FogEnd = State.OriginalLighting.FogEnd
        Lighting.GlobalShadows = State.OriginalLighting.GlobalShadows
    end
end)
UI_Toggle(tVisual, "Potato PC Textures (SmoothPlastic)", "Environment", "Potato", function(state)
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then v.Material = state and Enum.Material.SmoothPlastic or Enum.Material.Plastic end
    end
end)

-- CHAOS TAB
UI_Section(tChaos, "Formation Control")
UI_Toggle(tChaos, "Trigonometric Halo (Crown Vortex)", "Chaos", "CrownVortex", function(state)
    if not state and LocalPlayer.Character then
        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then root.Anchored = false end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                p.Character.HumanoidRootPart.AssemblyLinearVelocity = Camera.CFrame.LookVector * State.Chaos.ThrowForce
            end
        end
    end
end)
UI_Slider(tChaos, "Vortex Release Force", 50000, 500000, 150000, "Chaos", "ThrowForce")
UI_Section(tChaos, "Target Operations")
UI_TextBox(tChaos, "Enter exact username to fling...", "Chaos", "FlingTarget")
UI_Button(tChaos, "Execute Target Fling", Colors.Red, function()
    local targetName = State.Chaos.FlingTarget:lower()
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Name:lower() == targetName or p.DisplayName:lower() == targetName then
            if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local myRoot = LocalPlayer.Character.HumanoidRootPart
                local tRoot = p.Character.HumanoidRootPart
                myRoot.CFrame = tRoot.CFrame
                myRoot.AssemblyAngularVelocity = Vector3.new(50000, 50000, 50000)
                myRoot.AssemblyLinearVelocity = Vector3.new(0, 500, 0)
            end
            break
        end
    end
end)
UI_Button(tChaos, "Execute Mass Weld", Colors.Accent, function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local myRoot = char.HumanoidRootPart
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and not v.Anchored and not v:IsDescendantOf(char) and not Players:GetPlayerFromCharacter(v.Parent) then
                v.CFrame = myRoot.CFrame
                local wc = Instance.new("WeldConstraint")
                wc.Part0 = myRoot
                wc.Part1 = v
                wc.Parent = myRoot
            end
        end
    end
end)
UI_Section(tChaos, "Network")
UI_TextBox(tChaos, "Message to broadcast...", "Chaos", "ChatMessage")
UI_Toggle(tChaos, "Automated Chat Tester", "Chaos", "ChatSpam")

-- PROFILE / DIAGNOSTICS TAB
local diagFrame = Create("Frame", { Parent = tProfile, Size = UDim2.new(1, 0, 0, 200), BackgroundColor3 = Colors.Sidebar })
ApplyCorner(diagFrame, 8); ApplyStroke(diagFrame)

local VF = Create("ViewportFrame", { Parent = diagFrame, Size = UDim2.new(0, 120, 1, -20), Position = UDim2.new(0, 10, 0, 10), BackgroundTransparency = 1, CurrentCamera = Instance.new("Camera", diagFrame) })
VF.CurrentCamera.FieldOfView = 50

local diagLbl = Create("TextLabel", { Parent = diagFrame, Size = UDim2.new(1, -150, 1, -20), Position = UDim2.new(0, 140, 0, 10), BackgroundTransparency = 1, Text = "", TextColor3 = Colors.Text, Font = Enum.Font.GothamSemibold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top })

local function SetupViewport()
    VF:ClearAllChildren()
    if LocalPlayer.Character then
        local charClone = LocalPlayer.Character:Clone()
        if charClone then
            charClone.Parent = VF
            local hrp = charClone:FindFirstChild("HumanoidRootPart")
            if hrp then
                VF.CurrentCamera.CFrame = CFrame.new(hrp.Position + (hrp.CFrame.LookVector * 5) + Vector3.new(0, 1, 0), hrp.Position)
            end
        end
    end
end
LocalPlayer.CharacterAdded:Connect(SetupViewport)
SetupViewport()

-- SYSTEM TAB
UI_Section(tSystem, "Emergency Override")
UI_Button(tSystem, "Force Unload (Destroys GUI & Tasks)", Colors.Red, function()
    for _, c in pairs(State.Connections) do c:Disconnect() end
    for _, e in pairs(State.ESPInstances) do 
        if e.Box then e.Box:Destroy() end
        if e.Tracer then e.Tracer:Destroy() end
        if e.NameLbl then e.NameLbl:Destroy() end
        if e.HealthLbl then e.HealthLbl:Destroy() end
    end
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.Anchored = false
    end
    Lighting.Ambient = State.OriginalLighting.Ambient
    Lighting.OutdoorAmbient = State.OriginalLighting.OutdoorAmbient
    Lighting.ClockTime = State.OriginalLighting.ClockTime
    Lighting.FogEnd = State.OriginalLighting.FogEnd
    Lighting.GlobalShadows = State.OriginalLighting.GlobalShadows
    if UI.Parent then UI:Destroy() end
end)

-- [ ON-SCREEN FLY CONTROLS FOR MOBILE ] --
local FlyUI = Create("Frame", { Parent = UI, Size = UDim2.new(0, 60, 0, 130), Position = UDim2.new(1, -80, 0.5, -65), BackgroundTransparency = 1, Visible = false })
local BtnUp = Create("TextButton", { Parent = FlyUI, Size = UDim2.new(1, 0, 0, 60), Position = UDim2.new(0, 0, 0, 0), BackgroundColor3 = Colors.Sidebar, Text = "▲\nAscend", TextColor3 = Colors.Text, Font = Enum.Font.GothamBold, TextSize = 12 })
ApplyCorner(BtnUp, 8); ApplyStroke(BtnUp)
local BtnDown = Create("TextButton", { Parent = FlyUI, Size = UDim2.new(1, 0, 0, 60), Position = UDim2.new(0, 0, 1, -60), BackgroundColor3 = Colors.Sidebar, Text = "▼\nDescend", TextColor3 = Colors.Text, Font = Enum.Font.GothamBold, TextSize = 12 })
ApplyCorner(BtnDown, 8); ApplyStroke(BtnDown)

BtnUp.InputBegan:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then State.Movement.Ascend = true end end)
BtnUp.InputEnded:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then State.Movement.Ascend = false end end)
BtnDown.InputBegan:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then State.Movement.Descend = true end end)
BtnDown.InputEnded:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then State.Movement.Descend = false end end)

-- [ CORE LOGIC LOOPS (MONOLITHIC) ] --
local espContainer = Create("ScreenGui", { Name = "ESPContainer", Parent = CoreGui })

local function GetESP(player)
    if not State.ESPInstances[player.Name] then
        local box = Create("Frame", { Parent = espContainer, BackgroundTransparency = 1, Visible = false, ZIndex = 2 })
        local boxStroke = Create("UIStroke", { Parent = box, Color = Colors.Red, Thickness = State.Environment.ESPThickness })
        
        local tracer = Create("Frame", { Parent = espContainer, BackgroundColor3 = Colors.Red, BorderSizePixel = 0, Visible = false, ZIndex = 1 })
        
        local nameLbl = Create("TextLabel", { Parent = espContainer, BackgroundTransparency = 1, Text = player.Name, TextColor3 = Color3.new(1,1,1), Font = Enum.Font.GothamBold, TextSize = 14, TextStrokeTransparency = 0, Visible = false, ZIndex = 3 })
        local healthLbl = Create("TextLabel", { Parent = espContainer, BackgroundTransparency = 1, Text = "[100]", TextColor3 = Colors.Green, Font = Enum.Font.GothamBold, TextSize = 12, TextStrokeTransparency = 0, Visible = false, ZIndex = 3 })
        
        State.ESPInstances[player.Name] = { Box = box, BoxStroke = boxStroke, Tracer = tracer, NameLbl = nameLbl, HealthLbl = healthLbl }
    end
    return State.ESPInstances[player.Name]
end

Players.PlayerRemoving:Connect(function(p)
    if State.ESPInstances[p.Name] then
        State.ESPInstances[p.Name].Box:Destroy()
        State.ESPInstances[p.Name].Tracer:Destroy()
        State.ESPInstances[p.Name].NameLbl:Destroy()
        State.ESPInstances[p.Name].HealthLbl:Destroy()
        State.ESPInstances[p.Name] = nil
    end
end)

table.insert(State.Connections, RunService.RenderStepped:Connect(function(dt)
    -- Diagnostics Update
    local pingStr = "N/A"
    pcall(function() pingStr = tostring(math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())) .. " ms" end)
    diagLbl.Text = string.format("Display Name: %s\nUsername: %s\nAccount Age: %d days\n\nFPS: %d\nPing: %s", LocalPlayer.DisplayName, LocalPlayer.Name, LocalPlayer.AccountAge, math.floor(1/dt), pingStr)
    
    -- ESP Logic (Standard GUI math for Tracers/Boxes without Drawing API)
    local screenSize = Camera.ViewportSize
    local origin = Vector2.new(screenSize.X / 2, screenSize.Y)
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") then
            local root = p.Character.HumanoidRootPart
            local hum = p.Character.Humanoid
            local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
            local headPos = Camera:WorldToViewportPoint(p.Character:FindFirstChild("Head") and p.Character.Head.Position + Vector3.new(0,0.5,0) or root.Position + Vector3.new(0,2,0))
            local legPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0,3,0))
            
            local esp = GetESP(p)
            local height = math.abs(headPos.Y - legPos.Y)
            local width = height * 0.65
            
            if onScreen then
                if State.Environment.ESPBoxes then
                    esp.Box.Visible = true
                    esp.Box.Size = UDim2.new(0, width, 0, height)
                    esp.Box.Position = UDim2.new(0, pos.X - (width/2), 0, headPos.Y)
                    esp.BoxStroke.Thickness = State.Environment.ESPThickness
                    esp.BoxStroke.Transparency = State.Environment.ESPTransparency
                else esp.Box.Visible = false end
                
                if State.Environment.ESPTracers then
                    esp.Tracer.Visible = true
                    local targetPos = Vector2.new(pos.X, legPos.Y)
                    local distance = (targetPos - origin).Magnitude
                    local angle = math.deg(math.atan2(targetPos.Y - origin.Y, targetPos.X - origin.X))
                    esp.Tracer.Size = UDim2.new(0, distance, 0, State.Environment.ESPThickness)
                    esp.Tracer.Position = UDim2.new(0, (origin.X + targetPos.X)/2 - (distance/2), 0, (origin.Y + targetPos.Y)/2)
                    esp.Tracer.Rotation = angle
                    esp.Tracer.BackgroundTransparency = State.Environment.ESPTransparency
                else esp.Tracer.Visible = false end
                
                if State.Environment.ESPNames then
                    esp.NameLbl.Visible = true
                    esp.NameLbl.Position = UDim2.new(0, pos.X - 50, 0, headPos.Y - 20)
                else esp.NameLbl.Visible = false end
                
                if State.Environment.ESPHealth then
                    esp.HealthLbl.Visible = true
                    esp.HealthLbl.Position = UDim2.new(0, pos.X - 50, 0, legPos.Y + 5)
                    esp.HealthLbl.Text = "[" .. math.floor(hum.Health) .. "]"
                else esp.HealthLbl.Visible = false end
            else
                esp.Box.Visible = false
                esp.Tracer.Visible = false
                esp.NameLbl.Visible = false
                esp.HealthLbl.Visible = false
            end
        else
            if State.ESPInstances[p.Name] then
                State.ESPInstances[p.Name].Box.Visible = false
                State.ESPInstances[p.Name].Tracer.Visible = false
                State.ESPInstances[p.Name].NameLbl.Visible = false
                State.ESPInstances[p.Name].HealthLbl.Visible = false
            end
        end
    end
    
    -- Crown Vortex Math
    if State.Chaos.CrownVortex and LocalPlayer.Character then
        local myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if myRoot then
            myRoot.Anchored = true
            local targets = {}
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    table.insert(targets, p.Character.HumanoidRootPart)
                end
            end
            local tCount = #targets
            if tCount > 0 then
                local cTime = tick() * 2
                for i, tRoot in ipairs(targets) do
                    local angle = cTime + (math.pi * 2 / tCount * i)
                    tRoot.CFrame = myRoot.CFrame * CFrame.new(math.cos(angle) * 10, 10, math.sin(angle) * 10)
                    tRoot.AssemblyLinearVelocity = Vector3.zero
                end
                local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool") or LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
                if tool then
                    if tool.Parent == LocalPlayer.Backpack then tool.Parent = LocalPlayer.Character end
                    tool:Activate()
                end
            end
        end
    end
end))

table.insert(State.Connections, RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    
    if hum then
        if State.Movement.UseWS then hum.WalkSpeed = State.Movement.WalkSpeed end
        if State.Movement.UseJP then hum.JumpPower = State.Movement.JumpPower end
    end
    
    FlyUI.Visible = State.Movement.Fly
    if State.Movement.Fly and root then
        local camCF = Camera.CFrame
        local moveVector = Vector3.zero
        if State.Movement.Ascend then moveVector = moveVector + Vector3.new(0, 1, 0) end
        if State.Movement.Descend then moveVector = moveVector + Vector3.new(0, -1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVector = moveVector + camCF.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVector = moveVector - camCF.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVector = moveVector - camCF.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVector = moveVector + camCF.RightVector end
        root.AssemblyLinearVelocity = moveVector * State.Movement.FlySpeed
        root.AssemblyAngularVelocity = Vector3.zero
    elseif not State.Movement.Fly and root and State.Movement.Ascend == true then
        root.AssemblyLinearVelocity = Vector3.zero
    end
    
    if State.Interaction.AntiGrab and root and hum then
        for _, obj in ipairs(char:GetDescendants()) do
            if obj:IsA("Weld") or obj:IsA("WeldConstraint") or obj:IsA("RopeConstraint") or obj:IsA("Motor6D") then
                local p0 = obj:IsA("Motor6D") and obj.Part0 or obj.Part0
                local p1 = obj:IsA("Motor6D") and obj.Part1 or obj.Part1
                if (p0 and not p0:IsDescendantOf(char)) or (p1 and not p1:IsDescendantOf(char)) then
                    obj:Destroy()
                end
            end
        end
        hum.PlatformStanding = false
        local s = hum:GetState()
        if s == Enum.HumanoidStateType.Ragdoll or s == Enum.HumanoidStateType.FallingDown or s == Enum.HumanoidStateType.Physics then
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
        
        if root.AssemblyLinearVelocity.Magnitude > 75 and State.CachedCFrame then
            root.CFrame = State.CachedCFrame
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
        else
            State.CachedCFrame = root.CFrame
        end
    end
    
    if State.Movement.Stabilizer and root then
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
    end
    
    if State.Environment.Fullbright then
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
        Lighting.ClockTime = 14
        Lighting.FogEnd = 999999
        Lighting.GlobalShadows = false
    end
end))

table.insert(State.Connections, RunService.Stepped:Connect(function()
    if State.Movement.Noclip and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end))

table.insert(State.Connections, UserInputService.JumpRequest:Connect(function()
    if State.Movement.InfJump and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end))

-- [ CLICK TO GRAB VIEWPORT LOGIC ] --
table.insert(State.Connections, Mouse.Button1Down:Connect(function()
    if State.Interaction.ClickGrab and LocalPlayer.Character then
        local mousePos = UserInputService:GetMouseLocation()
        local ray = Camera:ViewportPointToRay(mousePos.X, mousePos.Y)
        local params = RaycastParams.new()
        params.FilterDescendantsInstances = {LocalPlayer.Character}
        params.FilterType = Enum.RaycastFilterType.Exclude
        
        local result = workspace:Raycast(ray.Origin, ray.Direction * 10000, params)
        local targetModel = nil
        
        if result and result.Instance then
            local model = result.Instance:FindFirstAncestorOfClass("Model")
            if model and model:FindFirstChild("Humanoid") then targetModel = model end
        else
            -- Fallback tap detection using Screen bounds for mobile targeting anywhere near a player
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local root = p.Character.HumanoidRootPart
                    local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
                    if onScreen then
                        local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                        if dist < 150 then targetModel = p.Character; break end
                    end
                end
            end
        end
        
        if targetModel then
            local targetJoint = targetModel:FindFirstChild(State.Interaction.TargetPart)
            if targetJoint then
                local offset = (State.Interaction.TargetPart == "HumanoidRootPart") and Vector3.new(0, -0.5, 0) or Vector3.new(0,0,0)
                local predictedCF = CFrame.new(targetJoint.Position + offset + (targetJoint.AssemblyLinearVelocity * (State.Interaction.Prediction / 10)))
                local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool") or LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
                if tool then
                    if tool.Parent == LocalPlayer.Backpack then tool.Parent = LocalPlayer.Character end
                    local handle = tool:FindFirstChild("Handle")
                    if handle then handle.CFrame = predictedCF end
                    tool:Activate()
                    
                    if State.Interaction.Momentum then
                        task.delay(0.1, function() targetJoint.AssemblyLinearVelocity = targetJoint.AssemblyLinearVelocity + (Camera.CFrame.LookVector * State.Interaction.MomentumForce) end)
                    end
                end
            end
        end
    end
end))

-- [ PROXIMITY & CHAT TASKS ] --
task.spawn(function()
    while task.wait(0.1) do
        if State.Interaction.AutoInteract and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local myRoot = LocalPlayer.Character.HumanoidRootPart
            local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool") or LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
            if tool then
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        if (p.Character.HumanoidRootPart.Position - myRoot.Position).Magnitude <= 5 then
                            if tool.Parent == LocalPlayer.Backpack then tool.Parent = LocalPlayer.Character end
                            tool:Activate()
                        end
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(3) do
        if State.Chaos.ChatSpam then
            if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
                local channel = TextChatService:FindFirstChild("TextChannels") and TextChatService.TextChannels:FindFirstChild("RBXGeneral")
                if channel then channel:SendAsync(State.Chaos.ChatMessage) end
            else
                ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents").SayMessageRequest:FireServer(State.Chaos.ChatMessage, "All")
            end
        end
    end
end)
