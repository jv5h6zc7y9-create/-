local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local TextChatService = game:GetService("TextChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Stats = game:GetService("Stats")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- [ STATE MANAGEMENT ] --
local State = {
    Movement = { WalkSpeed = 16, JumpPower = 50, InfJump = false, Fly = false, FlySpeed = 50, Noclip = false, Stabilizer = false, Ascend = false, Descend = false },
    Interaction = { AutoInteract = false, ClickGrab = false, TargetPart = "HumanoidRootPart", Momentum = false, MomentumForce = 50000, AntiGrab = false, CachedCFrame = nil },
    Environment = { ESP = false, ESPThickness = 1, ESPTransparency = 0, Stretch = 1, Fullbright = false, Optimization = false },
    Chaos = { Halo = false, FlingTarget = "", MassWeld = false, ChatSpam = false, ChatMessage = "GitHub Admin Toolbox Active" },
    Connections = {},
    ESPObjects = {},
    OriginalLighting = { Ambient = Lighting.Ambient, OutdoorAmbient = Lighting.OutdoorAmbient, ClockTime = Lighting.ClockTime, FogEnd = Lighting.FogEnd, GlobalShadows = Lighting.GlobalShadows }
}

-- [ UI FRAMEWORK (GitHub Dark) ] --
local Colors = { Background = Color3.fromRGB(13, 17, 23), Panel = Color3.fromRGB(22, 27, 34), Accent = Color3.fromRGB(31, 111, 235), Text = Color3.fromRGB(201, 209, 217), Border = Color3.fromRGB(48, 54, 61) }

local UI = Instance.new("ScreenGui")
UI.Name = "GitHubAdminToolbox"
UI.ResetOnSpawn = false
UI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() UI.Parent = CoreGui end)
if UI.Parent == nil then UI.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local function Create(className, properties, children)
    local inst = Instance.new(className)
    for k, v in pairs(properties) do inst[k] = v end
    if children then for _, child in ipairs(children) do child.Parent = inst end end
    return inst
end

local function Corner(radius) return Create("UICorner", { CornerRadius = UDim.new(0, radius) }) end
local function Stroke(color) return Create("UIStroke", { Color = color, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }) end

-- Launcher
local Launcher = Create("TextButton", {
    Name = "Launcher", Parent = UI, Size = UDim2.new(0, 50, 0, 50), Position = UDim2.new(0.5, -25, 0, 20),
    BackgroundColor3 = Colors.Panel, Text = "⚡", TextSize = 24, TextColor3 = Colors.Accent, Font = Enum.Font.GothamBold,
    AutoButtonColor = false, Active = true, Draggable = true
}, { Corner(25), Stroke(Colors.Border) })

-- Main Panel
local MainPanel = Create("Frame", {
    Name = "MainPanel", Parent = UI, Size = UDim2.new(0, 600, 0, 400), Position = UDim2.new(0.5, -300, 0.5, -200),
    BackgroundColor3 = Colors.Background, Visible = false, ClipsDescendants = true
}, { Corner(8), Stroke(Colors.Border) })

-- Sidebar
local Sidebar = Create("Frame", {
    Name = "Sidebar", Parent = MainPanel, Size = UDim2.new(0, 150, 1, 0), Position = UDim2.new(0, 0, 0, 0),
    BackgroundColor3 = Colors.Panel, BorderSizePixel = 0
}, {
    Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5) }),
    Create("UIPadding", { PaddingTop = UDim.new(0, 10), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) })
})

local ContentContainer = Create("Frame", {
    Name = "Content", Parent = MainPanel, Size = UDim2.new(1, -150, 1, 0), Position = UDim2.new(0, 150, 0, 0),
    BackgroundTransparency = 1
})

-- UI Components Builder
local Tabs = {}
local function CreateTab(name, icon, order)
    local btn = Create("TextButton", {
        Name = name.."Btn", Parent = Sidebar, Size = UDim2.new(1, 0, 0, 35), BackgroundColor3 = Colors.Background,
        Text = icon .. " " .. name, TextColor3 = Colors.Text, Font = Enum.Font.GothamSemibold, TextSize = 14,
        LayoutOrder = order, AutoButtonColor = false
    }, { Corner(6), Stroke(Colors.Border) })
    
    local scroll = Create("ScrollingFrame", {
        Name = name.."Tab", Parent = ContentContainer, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
        ScrollBarThickness = 4, ScrollBarImageColor3 = Colors.Accent, Visible = false, CanvasSize = UDim2.new(0, 0, 0, 0)
    }, {
        Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10) }),
        Create("UIPadding", { PaddingTop = UDim.new(0, 15), PaddingBottom = UDim.new(0, 15), PaddingLeft = UDim.new(0, 15), PaddingRight = UDim.new(0, 15) })
    })
    
    btn.MouseButton1Click:Connect(function()
        for _, tab in pairs(Tabs) do tab.Scroll.Visible = false; tab.Btn.BackgroundColor3 = Colors.Background end
        scroll.Visible = true; btn.BackgroundColor3 = Colors.Accent
    end)
    
    Tabs[name] = { Scroll = scroll, Btn = btn }
    return scroll
end

local function CreateToggle(parent, text, stateCategory, stateKey, callback)
    local container = Create("Frame", { Parent = parent, Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1 })
    local label = Create("TextLabel", { Parent = container, Size = UDim2.new(1, -60, 1, 0), BackgroundTransparency = 1, Text = text, TextColor3 = Colors.Text, Font = Enum.Font.Gotham, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left })
    local btn = Create("TextButton", { Parent = container, Size = UDim2.new(0, 50, 0, 24), Position = UDim2.new(1, -50, 0, 3), BackgroundColor3 = Colors.Background, Text = "", AutoButtonColor = false }, { Corner(12), Stroke(Colors.Border) })
    local indicator = Create("Frame", { Parent = btn, Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(0, 2, 0, 2), BackgroundColor3 = Colors.Text }, { Corner(10) })
    
    btn.MouseButton1Click:Connect(function()
        State[stateCategory][stateKey] = not State[stateCategory][stateKey]
        local active = State[stateCategory][stateKey]
        TweenService:Create(indicator, TweenInfo.new(0.2), { Position = active and UDim2.new(1, -22, 0, 2) or UDim2.new(0, 2, 0, 2), BackgroundColor3 = active and Colors.Accent or Colors.Text }):Play()
        TweenService:Create(btn, TweenInfo.new(0.2), { BackgroundColor3 = active and Colors.Panel or Colors.Background }):Play()
        if callback then callback(active) end
    end)
end

local function CreateSlider(parent, text, min, max, stateCategory, stateKey)
    local container = Create("Frame", { Parent = parent, Size = UDim2.new(1, 0, 0, 45), BackgroundTransparency = 1 })
    local label = Create("TextLabel", { Parent = container, Size = UDim2.new(1, -50, 0, 20), BackgroundTransparency = 1, Text = text, TextColor3 = Colors.Text, Font = Enum.Font.Gotham, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left })
    local valLabel = Create("TextLabel", { Parent = container, Size = UDim2.new(0, 50, 0, 20), Position = UDim2.new(1, -50, 0, 0), BackgroundTransparency = 1, Text = tostring(State[stateCategory][stateKey]), TextColor3 = Colors.Accent, Font = Enum.Font.GothamBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Right })
    local track = Create("Frame", { Parent = container, Size = UDim2.new(1, 0, 0, 6), Position = UDim2.new(0, 0, 0, 25), BackgroundColor3 = Colors.Panel }, { Corner(3) })
    local fill = Create("Frame", { Parent = track, Size = UDim2.new((State[stateCategory][stateKey] - min)/(max - min), 0, 1, 0), BackgroundColor3 = Colors.Accent }, { Corner(3) })
    local knob = Create("TextButton", { Parent = fill, Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(1, -7, 0.5, -7), BackgroundColor3 = Colors.Text, Text = "" }, { Corner(7) })
    
    local dragging = false
    knob.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
    RunService.RenderStepped:Connect(function()
        if dragging then
            local pos = math.clamp((UserInputService:GetMouseLocation().X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            fill.Size = UDim2.new(pos, 0, 1, 0)
            local val = math.floor(min + (max - min) * pos)
            valLabel.Text = tostring(val)
            State[stateCategory][stateKey] = val
        end
    end)
end

local function CreateButton(parent, text, callback)
    local btn = Create("TextButton", { Parent = parent, Size = UDim2.new(1, 0, 0, 35), BackgroundColor3 = Colors.Panel, Text = text, TextColor3 = Colors.Text, Font = Enum.Font.GothamSemibold, TextSize = 14, AutoButtonColor = false }, { Corner(6), Stroke(Colors.Border) })
    btn.MouseButton1Click:Connect(callback)
    btn.MouseEnter:Connect(function() TweenService:Create(btn, TweenInfo.new(0.2), { BackgroundColor3 = Colors.Background }):Play() end)
    btn.MouseLeave:Connect(function() TweenService:Create(btn, TweenInfo.new(0.2), { BackgroundColor3 = Colors.Panel }):Play() end)
end

local function CreateTextBox(parent, placeholder, stateCategory, stateKey)
    local box = Create("TextBox", { Parent = parent, Size = UDim2.new(1, 0, 0, 35), BackgroundColor3 = Colors.Panel, Text = State[stateCategory][stateKey], PlaceholderText = placeholder, TextColor3 = Colors.Text, Font = Enum.Font.Gotham, TextSize = 14 }, { Corner(6), Stroke(Colors.Border) })
    box.FocusLost:Connect(function() State[stateCategory][stateKey] = box.Text end)
end

-- [ BUILD TABS ] --
local MoveTab = CreateTab("Movement", "🏃‍♂️", 1)
local InteractTab = CreateTab("Interaction", "⚔️", 2)
local EnvTab = CreateTab("Environment", "👁️", 3)
local ChaosTab = CreateTab("Chaos", "🤡", 4)
local DiagTab = CreateTab("Diagnostics", "📊", 5)
local SysTab = CreateTab("System", "🛡️", 6)

-- Movement UI
CreateSlider(MoveTab, "WalkSpeed", 16, 300, "Movement", "WalkSpeed")
CreateSlider(MoveTab, "JumpPower", 50, 400, "Movement", "JumpPower")
CreateToggle(MoveTab, "Infinite Jump", "Movement", "InfJump")
CreateToggle(MoveTab, "Physics Fly Mode", "Movement", "Fly", function(active)
    if not active and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    end
end)
CreateSlider(MoveTab, "Fly Speed", 20, 300, "Movement", "FlySpeed")
CreateToggle(MoveTab, "Noclip", "Movement", "Noclip")
CreateToggle(MoveTab, "Motion Stabilizer", "Movement", "Stabilizer")

-- Mobile Fly Controls
local AscendBtn = Create("TextButton", { Parent = UI, Size = UDim2.new(0, 60, 0, 60), Position = UDim2.new(1, -80, 0.5, 20), BackgroundColor3 = Colors.Panel, Text = "▲", TextColor3 = Colors.Accent, Font = Enum.Font.GothamBold, TextSize = 24, Visible = false, BackgroundTransparency = 0.5 }, { Corner(30), Stroke(Colors.Border) })
local DescendBtn = Create("TextButton", { Parent = UI, Size = UDim2.new(0, 60, 0, 60), Position = UDim2.new(1, -80, 0.5, 90), BackgroundColor3 = Colors.Panel, Text = "▼", TextColor3 = Colors.Accent, Font = Enum.Font.GothamBold, TextSize = 24, Visible = false, BackgroundTransparency = 0.5 }, { Corner(30), Stroke(Colors.Border) })
AscendBtn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then State.Movement.Ascend = true end end)
AscendBtn.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then State.Movement.Ascend = false end end)
DescendBtn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then State.Movement.Descend = true end end)
DescendBtn.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then State.Movement.Descend = false end end)

-- Interaction UI
CreateToggle(InteractTab, "Proximity Auto-Interact", "Interaction", "AutoInteract")
CreateToggle(InteractTab, "Enhanced Selection (Click-To-Grab)", "Interaction", "ClickGrab")
local BodyPartSelector = Create("TextButton", { Parent = InteractTab, Size = UDim2.new(1, 0, 0, 35), BackgroundColor3 = Colors.Panel, Text = "Target: HumanoidRootPart", TextColor3 = Colors.Text, Font = Enum.Font.GothamSemibold, TextSize = 14 }, { Corner(6), Stroke(Colors.Border) })
local parts = {"Head", "Torso", "HumanoidRootPart"}
local partIdx = 3
BodyPartSelector.MouseButton1Click:Connect(function()
    partIdx = (partIdx % 3) + 1
    State.Interaction.TargetPart = parts[partIdx]
    BodyPartSelector.Text = "Target: " .. parts[partIdx]
end)
CreateToggle(InteractTab, "Momentum Multiplier", "Interaction", "Momentum")
CreateSlider(InteractTab, "Multiplier Force", 5000, 2000000, "Interaction", "MomentumForce")
CreateToggle(InteractTab, "Recovery Anchor (Anti-Grab/Ragdoll)", "Interaction", "AntiGrab")

-- Environment UI
CreateToggle(EnvTab, "ESP (Boxes, Tracers, Names, Health)", "Environment", "ESP", function(active)
    if not active then
        for _, obj in pairs(State.ESPObjects) do obj:Destroy() end
        State.ESPObjects = {}
    end
end)
CreateSlider(EnvTab, "Tracking Line Thickness", 1, 5, "Environment", "ESPThickness")
CreateSlider(EnvTab, "Tracking Line Transparency", 0, 100, "Environment", "ESPTransparency")
CreateSlider(EnvTab, "Camera Stretch", 50, 250, "Environment", "Stretch") -- FOV based since AspectRatio is read-only on default camera
CreateToggle(EnvTab, "Fullbright", "Environment", "Fullbright", function(active)
    if not active then
        Lighting.Ambient = State.OriginalLighting.Ambient
        Lighting.OutdoorAmbient = State.OriginalLighting.OutdoorAmbient
        Lighting.ClockTime = State.OriginalLighting.ClockTime
        Lighting.FogEnd = State.OriginalLighting.FogEnd
        Lighting.GlobalShadows = State.OriginalLighting.GlobalShadows
    end
end)
CreateToggle(EnvTab, "Optimization (SmoothPlastic)", "Environment", "Optimization", function(active)
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            if active then
                v:SetAttribute("OriginalMaterial", v.Material)
                v.Material = Enum.Material.SmoothPlastic
            else
                local orig = v:GetAttribute("OriginalMaterial")
                if orig then v.Material = orig end
            end
        end
    end
end)

-- Chaos UI
CreateToggle(ChaosTab, "Trigonometric Halo Formation", "Chaos", "Halo")
CreateTextBox(ChaosTab, "Target Username", "Chaos", "FlingTarget")
CreateButton(ChaosTab, "Desync Fling Target", function()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and string.find(string.lower(p.Name), string.lower(State.Chaos.FlingTarget)) and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            hrp.CFrame = p.Character.HumanoidRootPart.CFrame
            hrp.AssemblyAngularVelocity = Vector3.new(0, 999999, 0)
            break
        end
    end
end)
CreateButton(ChaosTab, "Mass Weld Unanchored Items", function()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and not v.Anchored and not v:IsDescendantOf(char) then
            v.CFrame = hrp.CFrame
            local wc = Instance.new("WeldConstraint")
            wc.Part0 = hrp
            wc.Part1 = v
            wc.Parent = hrp
        end
    end
end)
CreateToggle(ChaosTab, "Automated Chat Tester", "Chaos", "ChatSpam")
CreateTextBox(ChaosTab, "Chat Message", "Chaos", "ChatMessage")

-- Diagnostics UI
local HUDContainer = Create("Frame", { Parent = DiagTab, Size = UDim2.new(1, 0, 0, 150), BackgroundColor3 = Colors.Panel }, { Corner(6), Stroke(Colors.Border) })
local VPF = Create("ViewportFrame", { Parent = HUDContainer, Size = UDim2.new(0, 100, 0, 100), Position = UDim2.new(0, 20, 0, 25), BackgroundTransparency = 1 })
local VPFCamera = Create("Camera", { Parent = VPF })
VPF.CurrentCamera = VPFCamera
local StatLabels = {
    Name = Create("TextLabel", { Parent = HUDContainer, Size = UDim2.new(0, 200, 0, 20), Position = UDim2.new(0, 140, 0, 25), BackgroundTransparency = 1, TextColor3 = Colors.Text, Font = Enum.Font.GothamBold, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left }),
    Age = Create("TextLabel", { Parent = HUDContainer, Size = UDim2.new(0, 200, 0, 20), Position = UDim2.new(0, 140, 0, 50), BackgroundTransparency = 1, TextColor3 = Colors.Text, Font = Enum.Font.Gotham, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left }),
    FPS = Create("TextLabel", { Parent = HUDContainer, Size = UDim2.new(0, 200, 0, 20), Position = UDim2.new(0, 140, 0, 75), BackgroundTransparency = 1, TextColor3 = Colors.Accent, Font = Enum.Font.GothamBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left }),
    Ping = Create("TextLabel", { Parent = HUDContainer, Size = UDim2.new(0, 200, 0, 20), Position = UDim2.new(0, 140, 0, 100), BackgroundTransparency = 1, TextColor3 = Colors.Accent, Font = Enum.Font.GothamBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left })
}
StatLabels.Name.Text = "User: " .. LocalPlayer.DisplayName .. " (@" .. LocalPlayer.Name .. ")"
StatLabels.Age.Text = "Account Age: " .. LocalPlayer.AccountAge .. " Days"

-- System UI
CreateButton(SysTab, "Force Unload (Reset)", function()
    for _, c in pairs(State.Connections) do c:Disconnect() end
    for _, obj in pairs(State.ESPObjects) do obj:Destroy() end
    Lighting.Ambient = State.OriginalLighting.Ambient
    Lighting.OutdoorAmbient = State.OriginalLighting.OutdoorAmbient
    Lighting.ClockTime = State.OriginalLighting.ClockTime
    Lighting.FogEnd = State.OriginalLighting.FogEnd
    Lighting.GlobalShadows = State.OriginalLighting.GlobalShadows
    Camera.FieldOfView = 70
    UI:Destroy()
end)

-- [ CORE LOGIC IMPLEMENTATION ] --

-- Launcher Toggle Logic
Launcher.MouseButton1Click:Connect(function()
    local targetVisible = not MainPanel.Visible
    if targetVisible then
        MainPanel.Visible = true
        MainPanel.Size = UDim2.new(0, 0, 0, 0)
        TweenService:Create(MainPanel, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Size = UDim2.new(0, 600, 0, 400) }):Play()
    else
        local tw = TweenService:Create(MainPanel, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), { Size = UDim2.new(0, 0, 0, 0) })
        tw:Play()
        tw.Completed:Connect(function() MainPanel.Visible = false end)
    end
end)

-- VPF Update Logic
task.spawn(function()
    if LocalPlayer.Character then
        local clone = LocalPlayer.Character:Clone()
        if clone then clone.Parent = VPF end
        if clone:FindFirstChild("HumanoidRootPart") then
            VPFCamera.CFrame = CFrame.new(clone.HumanoidRootPart.Position + clone.HumanoidRootPart.CFrame.LookVector * 4 + Vector3.new(0, 1.5, 0), clone.HumanoidRootPart.Position)
        end
    end
end)

-- Main RunService Loop
table.insert(State.Connections, RunService.Heartbeat:Connect(function(dt)
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    -- Movement Loops
    if hum then
        hum.WalkSpeed = State.Movement.WalkSpeed
        hum.JumpPower = State.Movement.JumpPower
    end
    
    if State.Movement.Fly and hrp then
        AscendBtn.Visible = true
        DescendBtn.Visible = true
        local vel = Vector3.new(0, 0, 0)
        local moveDir = hum and hum.MoveDirection or Vector3.new(0,0,0)
        
        if moveDir.Magnitude > 0 then
            vel = vel + (Camera.CFrame.LookVector * (moveDir:Dot(Camera.CFrame.LookVector)) + Camera.CFrame.RightVector * (moveDir:Dot(Camera.CFrame.RightVector))).Unit * State.Movement.FlySpeed
        end
        if State.Movement.Ascend or UserInputService:IsKeyDown(Enum.KeyCode.Space) then vel = vel + Vector3.new(0, State.Movement.FlySpeed, 0) end
        if State.Movement.Descend or UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then vel = vel + Vector3.new(0, -State.Movement.FlySpeed, 0) end
        
        hrp.AssemblyLinearVelocity = vel
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, 0, 0)
    else
        AscendBtn.Visible = false
        DescendBtn.Visible = false
    end
    
    if State.Movement.Stabilizer and hrp then
        if hrp.AssemblyAngularVelocity.Magnitude > 50 then hrp.AssemblyAngularVelocity = Vector3.new(0,0,0) end
        if hrp.AssemblyLinearVelocity.Magnitude > 250 and not State.Movement.Fly then hrp.AssemblyLinearVelocity = Vector3.new(0,0,0) end
    end
    
    -- Interaction Loops
    if State.Interaction.AutoInteract and hrp then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                if (p.Character.HumanoidRootPart.Position - hrp.Position).Magnitude <= 5 then
                    local tool = char:FindFirstChildOfClass("Tool")
                    if tool then tool:Activate() end
                end
            end
        end
    end
    
    if State.Interaction.AntiGrab and hrp and hum then
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("Weld") or v:IsA("WeldConstraint") or v:IsA("RopeConstraint") or v:IsA("Motor6D") then
                local p0 = v:IsA("Motor6D") and v.Part0 or (v.Part0)
                local p1 = v:IsA("Motor6D") and v.Part1 or (v.Part1)
                if (p0 and not p0:IsDescendantOf(char)) or (p1 and not p1:IsDescendantOf(char)) then
                    v:Destroy()
                end
            end
        end
        hum.PlatformStanding = false
        if hum:GetState() == Enum.HumanoidStateType.Ragdoll or hum:GetState() == Enum.HumanoidStateType.FallingDown then
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
        if hrp.AssemblyLinearVelocity.Magnitude > 75 and State.Interaction.CachedCFrame then
            hrp.CFrame = State.Interaction.CachedCFrame
            hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
            hrp.AssemblyAngularVelocity = Vector3.new(0,0,0)
        else
            State.Interaction.CachedCFrame = hrp.CFrame
        end
    end
    
    -- Environment Loops
    if State.Environment.ESP then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChildOfClass("Humanoid") then
                local e_hrp = p.Character.HumanoidRootPart
                local e_hum = p.Character:FindFirstChildOfClass("Humanoid")
                local pos, onScreen = Camera:WorldToViewportPoint(e_hrp.Position)
                
                if not State.ESPObjects[p.Name.."_Tracer"] then
                    local tracer = Drawing.new("Line")
                    State.ESPObjects[p.Name.."_Tracer"] = tracer
                end
                
                local tracer = State.ESPObjects[p.Name.."_Tracer"]
                if onScreen then
                    tracer.Visible = true
                    tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    tracer.To = Vector2.new(pos.X, pos.Y)
                    tracer.Color = Colors.Accent
                    tracer.Thickness = State.Environment.ESPThickness
                    tracer.Transparency = 1 - (State.Environment.ESPTransparency / 100)
                else
                    tracer.Visible = false
                end
                
                if not e_hrp:FindFirstChild("AdminESP") then
                    local bbg = Create("BillboardGui", { Name = "AdminESP", Parent = e_hrp, Size = UDim2.new(4, 0, 5.5, 0), AlwaysOnTop = true })
                    Create("Frame", { Name = "Box", Parent = bbg, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1 }, { Stroke(Colors.Accent) })
                    Create("TextLabel", { Name = "Name", Parent = bbg, Size = UDim2.new(1, 0, 0, 15), Position = UDim2.new(0, 0, 0, -15), BackgroundTransparency = 1, Text = p.Name, TextColor3 = Colors.Text, Font = Enum.Font.GothamBold, TextSize = 12 })
                    Create("TextLabel", { Name = "Health", Parent = bbg, Size = UDim2.new(1, 0, 0, 15), Position = UDim2.new(0, 0, 1, 0), BackgroundTransparency = 1, Text = tostring(math.floor(e_hum.Health)), TextColor3 = Color3.fromRGB(50, 255, 50), Font = Enum.Font.Gotham, TextSize = 10 })
                    State.ESPObjects[p.Name.."_BBG"] = bbg
                else
                    e_hrp.AdminESP.Health.Text = tostring(math.floor(e_hum.Health))
                    e_hrp.AdminESP.Box.UIStroke.Thickness = State.Environment.ESPThickness
                    e_hrp.AdminESP.Box.UIStroke.Transparency = State.Environment.ESPTransparency / 100
                end
            end
        end
    end
    
    if State.Environment.Stretch ~= 100 then
        Camera.FieldOfView = State.Environment.Stretch / 100 * 70
    else
        Camera.FieldOfView = 70
    end
    
    if State.Environment.Fullbright then
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        Lighting.ClockTime = 14
        Lighting.FogEnd = 999999
        Lighting.GlobalShadows = false
    end
    
    -- Chaos Loops
    if State.Chaos.Halo and hrp then
        hrp.Anchored = true
        local radius = 10
        local height = 10
        local others = {}
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                table.insert(others, p.Character.HumanoidRootPart)
            end
        end
        local count = #others
        for i, targetHrp in ipairs(others) do
            local angle = (tick() * 2) + (math.pi * 2 / count * i)
            local offset = Vector3.new(math.cos(angle) * radius, height, math.sin(angle) * radius)
            targetHrp.CFrame = hrp.CFrame + offset
            targetHrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
        end
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then tool:Activate() end
    elseif not State.Chaos.Halo and hrp and hrp.Anchored then
        hrp.Anchored = false
        local others = {}
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                p.Character.HumanoidRootPart.AssemblyLinearVelocity = Camera.CFrame.LookVector * State.Interaction.MomentumForce
            end
        end
    end
    
    -- Diagnostics Loop
    StatLabels.FPS.Text = "FPS: " .. tostring(math.floor(1 / dt))
    pcall(function() StatLabels.Ping.Text = "Ping: " .. tostring(math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())) .. " ms" end)
end))

-- Noclip Stepped Loop
table.insert(State.Connections, RunService.Stepped:Connect(function()
    if State.Movement.Noclip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end))

-- Infinite Jump
table.insert(State.Connections, UserInputService.JumpRequest:Connect(function()
    if State.Movement.InfJump and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end))

-- Enhanced Selection Interaction (Click-To-Grab)
table.insert(State.Connections, Mouse.Button1Down:Connect(function()
    if State.Interaction.ClickGrab then
        local target = Mouse.Target
        if target and target.Parent:FindFirstChildOfClass("Humanoid") then
            local targetPlayer = Players:GetPlayerFromCharacter(target.Parent)
            if targetPlayer then
                local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
                if tool then
                    local targetPart = target.Parent:FindFirstChild(State.Interaction.TargetPart)
                    if targetPart then
                        local predictedPos = targetPart.Position + (targetPart.AssemblyLinearVelocity * 0.1)
                        if tool:FindFirstChild("Handle") then
                            tool.Handle.CFrame = CFrame.new(predictedPos - Vector3.new(0, 0.5, 0))
                        end
                        tool:Activate()
                    end
                end
            end
        end
    end
end))

-- Momentum Multiplier
table.insert(State.Connections, LocalPlayer.CharacterAdded:Connect(function(char)
    char.ChildAdded:Connect(function(child)
        if State.Interaction.Momentum and child:IsA("Tool") then
            child.Activated:Connect(function()
                if child:FindFirstChild("Handle") then
                    child.Handle.AssemblyLinearVelocity = child.Handle.AssemblyLinearVelocity * (State.Interaction.MomentumForce / 1000)
                end
            end)
        end
    end)
end))

-- Automated Chat Tester
task.spawn(function()
    while task.wait(3) do
        if State.Chaos.ChatSpam then
            pcall(function()
                if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
                    TextChatService.TextChannels.RBXGeneral:SendAsync(State.Chaos.ChatMessage)
                else
                    ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(State.Chaos.ChatMessage, "All")
                end
            end)
        end
    end
end)

-- Initialize Tab State
Tabs["Movement"].Btn.BackgroundColor3 = Colors.Accent
Tabs["Movement"].Scroll.Visible = true
