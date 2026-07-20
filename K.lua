--===================================================================================--
-- ADMINISTRATIVE UTILITY SUITE - COMPREHENSIVE CONTROL ENGINE                       --
-- GAME: FLING THINGS AND PEOPLE (FTAP)                                              --
-- STYLE: GITHUB DARK MINIMALIST V2                                                  --
--===================================================================================--

-- [1. ENGINE SERVICES & VARIABLES]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local TextChatService = game:GetService("TextChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local Stats = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- [2. CORE CONFIGURATION DICTIONARY]
local Config = {
    Movement = {
        WalkSpeedToggle = false, WalkSpeed = 16,
        JumpPowerToggle = false, JumpPower = 50,
        InfiniteJump = false,
        FlyMode = false, FlySpeed = 50,
        Noclip = false,
        AntiFling = false
    },
    Combat = {
        ProximityGrab = false, GrabRadius = 5,
        SilentAim = false, FovCircle = false, FovRadius = 100,
        TargetPart = "HumanoidRootPart", Prediction = 1.0,
        MegaThrow = false, ThrowForce = 50000,
        AntiGrab = false
    },
    Visuals = {
        EspBoxes = false, EspTracers = false, EspNames = false, EspHealth = false,
        EspThickness = 1.5, EspTransparency = 1.0,
        Fullbright = false, AspectRatio = 1.0, PotatoMode = false
    },
    Chaos = {
        CrownVortex = false,
        ChatSpam = false, SpamMessage = "GitHub Dark Suite Active"
    }
}

-- [3. CACHE & STATE MANAGEMENT]
local Cache = {
    OriginalLighting = {
        Ambient = Lighting.Ambient,
        OutdoorAmbient = Lighting.OutdoorAmbient,
        ClockTime = Lighting.ClockTime,
        FogEnd = Lighting.FogEnd,
        GlobalShadows = Lighting.GlobalShadows
    },
    OriginalMaterials = {},
    Connections = {},
    EspDrawings = {},
    FovCircle = nil,
    PreGrabCFrame = CFrame.new(),
    FlyAscend = false,
    FlyDescend = false,
    FlingTarget = ""
}

-- Initialize FOV Circle (Drawing API)
if typeof(Drawing) ~= "nil" then
    Cache.FovCircle = Drawing.new("Circle")
    Cache.FovCircle.Color = Color3.fromRGB(31, 111, 235)
    Cache.FovCircle.Thickness = 1.5
    Cache.FovCircle.NumSides = 64
    Cache.FovCircle.Filled = false
    Cache.FovCircle.Visible = false
end

--===================================================================================--
-- [4. SECURITY BYPASS & METATABLE HOOKS]
--===================================================================================--
local function InitBypass()
    local rawMeta = getrawmetatable(game)
    if not rawMeta then return end
    
    setreadonly(rawMeta, false)
    local oldIndex = rawMeta.__index
    local oldNewIndex = rawMeta.__newindex
    local oldNamecall = rawMeta.__namecall

    rawMeta.__index = newcclosure(function(self, key)
        if not checkcaller() and self:IsA("Humanoid") then
            if key == "WalkSpeed" and Config.Movement.WalkSpeedToggle then return 16 end
            if key == "JumpPower" and Config.Movement.JumpPowerToggle then return 50 end
        end
        return oldIndex(self, key)
    end)

    rawMeta.__newindex = newcclosure(function(self, key, value)
        if not checkcaller() and self:IsA("Humanoid") then
            if key == "WalkSpeed" and Config.Movement.WalkSpeedToggle then return end
            if key == "JumpPower" and Config.Movement.JumpPowerToggle then return end
        end
        return oldNewIndex(self, key, value)
    end)

    rawMeta.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        -- Intercept Remotes for Silent Aim (FTAP specific adjustments)
        if method == "FireServer" and Config.Combat.SilentAim and typeof(self) == "Instance" and self:IsA("RemoteEvent") then
            -- Attempting to catch interaction/throw remotes dynamically based on args
            if typeof(args[1]) == "Vector3" then 
                local targetPart = nil
                local minDistance = Config.Combat.FovRadius
                local inset = GuiService:GetGuiInset()
                local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, (Camera.ViewportSize.Y - inset.Y) / 2)
                
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(Config.Combat.TargetPart) then
                        local part = player.Character[Config.Combat.TargetPart]
                        local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                        if onScreen then
                            local distance = (Vector2.new(pos.X, pos.Y) - screenCenter).Magnitude
                            if distance < minDistance then
                                minDistance = distance
                                targetPart = part
                            end
                        end
                    end
                end
                
                if targetPart then
                    local offset = (Config.Combat.TargetPart == "HumanoidRootPart") and Vector3.new(0, -0.5, 0) or Vector3.new(0,0,0)
                    local predictionOffset = targetPart.AssemblyLinearVelocity * (Config.Combat.Prediction / 10)
                    args[1] = targetPart.Position + offset + predictionOffset
                    return oldNamecall(self, unpack(args))
                end
            end
        end
        
        -- Mega-Throw Physics Override Interception
        if method == "FireServer" and Config.Combat.MegaThrow and typeof(self) == "Instance" and self.Name:lower():match("throw") then
            if typeof(args[1]) == "Instance" and args[1]:IsA("BasePart") then
                args[1].AssemblyLinearVelocity = args[1].AssemblyLinearVelocity.Unit * Config.Combat.ThrowForce
            end
        end
        
        return oldNamecall(self, ...)
    end)

    setreadonly(rawMeta, true)
end
pcall(InitBypass)

--===================================================================================--
-- [5. CORE SYSTEM LOOPS]
--===================================================================================--

-- Stepped Loop: Movement Physics
table.insert(Cache.Connections, RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    
    if humanoid then
        if Config.Movement.WalkSpeedToggle then humanoid.WalkSpeed = Config.Movement.WalkSpeed end
        if Config.Movement.JumpPowerToggle then humanoid.JumpPower = Config.Movement.JumpPower end
    end
    
    if Config.Movement.Noclip then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
    
    if hrp then
        if Config.Movement.AntiFling then
            hrp.AssemblyAngularVelocity = Vector3.zero
            if hrp.AssemblyLinearVelocity.Magnitude > 150 then
                hrp.AssemblyLinearVelocity = hrp.AssemblyLinearVelocity.Unit * 15
            end
        end
        
        if Config.Movement.FlyMode then
            local velocity = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then velocity += Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then velocity -= Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then velocity -= Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then velocity += Camera.CFrame.RightVector end
            if Cache.FlyAscend then velocity += Vector3.new(0, 1, 0) end
            if Cache.FlyDescend then velocity -= Vector3.new(0, 1, 0) end
            
            if velocity.Magnitude > 0 then
                hrp.AssemblyLinearVelocity = velocity.Unit * Config.Movement.FlySpeed
            else
                hrp.AssemblyLinearVelocity = Vector3.zero
            end
        end
    end
end))

-- Heartbeat Loop: Visuals & Anti-Grab
table.insert(Cache.Connections, RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    
    if Cache.FovCircle then
        local inset = GuiService:GetGuiInset()
        Cache.FovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, (Camera.ViewportSize.Y - inset.Y) / 2)
        Cache.FovCircle.Radius = Config.Combat.FovRadius
        Cache.FovCircle.Visible = Config.Combat.FovCircle and Config.Combat.SilentAim
    end
    
    if Config.Combat.AntiGrab and hrp and humanoid then
        for _, desc in pairs(char:GetDescendants()) do
            if desc:IsA("Weld") or desc:IsA("WeldConstraint") or desc:IsA("Motor6D") or desc:IsA("RopeConstraint") or desc:IsA("TouchTransmitter") then
                -- Check if it belongs natively to the player
                local internal = false
                for _, part in pairs(char:GetChildren()) do
                    if desc:IsDescendantOf(part) or desc.Parent == part then
                        if not desc.Parent:IsA("Tool") and not (desc.Parent.Parent and desc.Parent.Parent:IsA("Tool")) then
                            internal = true
                        end
                    end
                end
                if not internal then
                    pcall(function() desc:Destroy() end)
                end
            end
        end
        humanoid.PlatformStanding = false
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        if hrp.AssemblyLinearVelocity.Magnitude > 75 then
            hrp.CFrame = Cache.PreGrabCFrame
            hrp.AssemblyLinearVelocity = Vector3.zero
        else
            Cache.PreGrabCFrame = hrp.CFrame
        end
    end
    
    if Config.Visuals.Fullbright then
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        Lighting.ClockTime = 14
        Lighting.FogEnd = 999999
        Lighting.GlobalShadows = false
    end
    
    if Config.Visuals.AspectRatio ~= 1.0 then
        Camera.AspectRatio = Config.Visuals.AspectRatio
    end
end))

-- RenderStepped: ESP Drawing
local function CreateEsp(player)
    if player == LocalPlayer then return end
    Cache.EspDrawings[player] = {
        Box = Drawing.new("Square"),
        Tracer = Drawing.new("Line"),
        Name = Drawing.new("Text"),
        Health = Drawing.new("Line")
    }
    Cache.EspDrawings[player].Box.Filled = false
    Cache.EspDrawings[player].Name.Size = 13
    Cache.EspDrawings[player].Name.Center = true
    Cache.EspDrawings[player].Name.Outline = true
    Cache.EspDrawings[player].Name.Color = Color3.fromRGB(255, 255, 255)
    Cache.EspDrawings[player].Tracer.Color = Color3.fromRGB(255, 255, 255)
end

local function RemoveEsp(player)
    if Cache.EspDrawings[player] then
        for _, draw in pairs(Cache.EspDrawings[player]) do pcall(function() draw:Remove() end) end
        Cache.EspDrawings[player] = nil
    end
end

for _, p in pairs(Players:GetPlayers()) do CreateEsp(p) end
table.insert(Cache.Connections, Players.PlayerAdded:Connect(CreateEsp))
table.insert(Cache.Connections, Players.PlayerRemoving:Connect(RemoveEsp))

table.insert(Cache.Connections, RunService.RenderStepped:Connect(function()
    for player, drawings in pairs(Cache.EspDrawings) do
        local hasCharacter = player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid")
        if hasCharacter and player.Character.Humanoid.Health > 0 then
            local hrp = player.Character.HumanoidRootPart
            local hum = player.Character.Humanoid
            
            -- Tight Bounding Box Calculation
            local minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge
            local onScreen = false
            for _, part in pairs(player.Character:GetChildren()) do
                if part:IsA("BasePart") then
                    local pos, vis = Camera:WorldToViewportPoint(part.Position)
                    if vis then
                        onScreen = true
                        local size = part.Size
                        local corners = {
                            (part.CFrame * CFrame.new(size.X/2, size.Y/2, size.Z/2)).Position,
                            (part.CFrame * CFrame.new(-size.X/2, size.Y/2, size.Z/2)).Position,
                            (part.CFrame * CFrame.new(size.X/2, -size.Y/2, size.Z/2)).Position,
                            (part.CFrame * CFrame.new(-size.X/2, -size.Y/2, size.Z/2)).Position,
                            (part.CFrame * CFrame.new(size.X/2, size.Y/2, -size.Z/2)).Position,
                            (part.CFrame * CFrame.new(-size.X/2, size.Y/2, -size.Z/2)).Position,
                            (part.CFrame * CFrame.new(size.X/2, -size.Y/2, -size.Z/2)).Position,
                            (part.CFrame * CFrame.new(-size.X/2, -size.Y/2, -size.Z/2)).Position
                        }
                        for _, corner in pairs(corners) do
                            local cPos, _ = Camera:WorldToViewportPoint(corner)
                            minX = math.min(minX, cPos.X)
                            minY = math.min(minY, cPos.Y)
                            maxX = math.max(maxX, cPos.X)
                            maxY = math.max(maxY, cPos.Y)
                        end
                    end
                end
            end
            
            if onScreen then
                local width = maxX - minX
                local height = maxY - minY
                
                -- Box
                drawings.Box.Size = Vector2.new(width, height)
                drawings.Box.Position = Vector2.new(minX, minY)
                drawings.Box.Color = Color3.fromRGB(31, 111, 235)
                drawings.Box.Thickness = Config.Visuals.EspThickness
                drawings.Box.Transparency = Config.Visuals.EspTransparency
                drawings.Box.Visible = Config.Visuals.EspBoxes
                
                -- Tracer
                drawings.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                drawings.Tracer.To = Vector2.new(minX + width/2, maxY)
                drawings.Tracer.Thickness = Config.Visuals.EspThickness
                drawings.Tracer.Transparency = Config.Visuals.EspTransparency
                drawings.Tracer.Visible = Config.Visuals.EspTracers
                
                -- Name
                drawings.Name.Text = player.DisplayName
                drawings.Name.Position = Vector2.new(minX + width/2, minY - 15)
                drawings.Name.Visible = Config.Visuals.EspNames
                
                -- Health
                local healthScale = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                drawings.Health.From = Vector2.new(minX - 5, maxY)
                drawings.Health.To = Vector2.new(minX - 5, maxY - (height * healthScale))
                drawings.Health.Color = Color3.fromRGB(255 * (1 - healthScale), 255 * healthScale, 0)
                drawings.Health.Thickness = 2
                drawings.Health.Visible = Config.Visuals.EspHealth
            else
                for _, d in pairs(drawings) do d.Visible = false end
            end
        else
            for _, d in pairs(drawings) do d.Visible = false end
        end
    end
end))

-- Task Spawns (Auto-Grab, Chaos, Profile)
task.spawn(function()
    while task.wait(0.1) do
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then continue end
        local hrp = char.HumanoidRootPart
        
        -- Proximity Grab
        if Config.Combat.ProximityGrab then
            for _, obj in pairs(Workspace:GetChildren()) do
                if obj ~= char and obj:FindFirstChild("HumanoidRootPart") then
                    if (obj.HumanoidRootPart.Position - hrp.Position).Magnitude <= Config.Combat.GrabRadius then
                        local grabTool = char:FindFirstChildOfClass("Tool")
                        if grabTool then grabTool:Activate() end
                    end
                end
            end
        end
        
        -- Crown Vortex
        if Config.Chaos.CrownVortex then
            local targets = {}
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    table.insert(targets, p.Character.HumanoidRootPart)
                end
            end
            local count = #targets
            if count > 0 then
                local timeOffset = tick() * 2
                for i, targetHrp in ipairs(targets) do
                    local angle = ((i / count) * math.pi * 2) + timeOffset
                    local offset = Vector3.new(math.cos(angle) * 10, 10, math.sin(angle) * 10)
                    targetHrp.CFrame = hrp.CFrame * CFrame.new(offset)
                    targetHrp.AssemblyLinearVelocity = Vector3.zero
                    
                    local grabTool = char:FindFirstChildOfClass("Tool")
                    if grabTool and (targetHrp.Position - hrp.Position).Magnitude < 15 then
                        grabTool:Activate()
                    end
                end
            end
        end
    end
end)

table.insert(Cache.Connections, UserInputService.JumpRequest:Connect(function()
    if Config.Movement.InfiniteJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
    end
end))

task.spawn(function()
    while task.wait(3) do
        if Config.Chaos.ChatSpam then
            pcall(function()
                if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
                    TextChatService.TextChannels.RBXGeneral:SendAsync(Config.Chaos.SpamMessage)
                else
                    ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(Config.Chaos.SpamMessage, "All")
                end
            end)
        end
    end
end)

--===================================================================================--
-- [6. UI ARCHITECTURE (GITHUB DARK)]
--===================================================================================--
local Gui = Instance.new("ScreenGui")
Gui.Name = "GitHubDarkSuite"
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
local success = pcall(function() Gui.Parent = CoreGui end)
if not success then Gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- Mobile Flight Controls (Ascend/Descend)
local BtnAscend = Instance.new("TextButton", Gui)
BtnAscend.Size = UDim2.new(0, 80, 0, 50)
BtnAscend.Position = UDim2.new(0.85, -40, 0.6, -25)
BtnAscend.BackgroundColor3 = Color3.fromRGB(22, 27, 34)
BtnAscend.TextColor3 = Color3.fromRGB(201, 209, 217)
BtnAscend.Font = Enum.Font.SourceSansBold
BtnAscend.TextSize = 16
BtnAscend.Text = "Ascend"
BtnAscend.Visible = false
Instance.new("UICorner", BtnAscend).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", BtnAscend).Color = Color3.fromRGB(48, 54, 61)

local BtnDescend = Instance.new("TextButton", Gui)
BtnDescend.Size = UDim2.new(0, 80, 0, 50)
BtnDescend.Position = UDim2.new(0.85, -40, 0.75, -25)
BtnDescend.BackgroundColor3 = Color3.fromRGB(22, 27, 34)
BtnDescend.TextColor3 = Color3.fromRGB(201, 209, 217)
BtnDescend.Font = Enum.Font.SourceSansBold
BtnDescend.TextSize = 16
BtnDescend.Text = "Descend"
BtnDescend.Visible = false
Instance.new("UICorner", BtnDescend).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", BtnDescend).Color = Color3.fromRGB(48, 54, 61)

BtnAscend.InputBegan:Connect(function() Cache.FlyAscend = true end)
BtnAscend.InputEnded:Connect(function() Cache.FlyAscend = false end)
BtnDescend.InputBegan:Connect(function() Cache.FlyDescend = true end)
BtnDescend.InputEnded:Connect(function() Cache.FlyDescend = false end)

-- Draggable Widget
local Widget = Instance.new("TextButton", Gui)
Widget.Size = UDim2.new(0, 50, 0, 50)
Widget.Position = UDim2.new(0.05, 0, 0.1, 0)
Widget.BackgroundColor3 = Color3.fromRGB(31, 111, 235)
Widget.Text = "⚡"
Widget.TextColor3 = Color3.fromRGB(255, 255, 255)
Widget.TextSize = 24
Instance.new("UICorner", Widget).CornerRadius = UDim.new(1, 0)

local dragToggle, dragStart, startPos
Widget.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragToggle = true
        dragStart = input.Position
        startPos = Widget.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragToggle and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        Widget.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragToggle = false
    end
end)

-- Main Panel
local MainFrame = Instance.new("Frame", Gui)
MainFrame.Size = UDim2.new(0, 600, 0, 400)
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(13, 17, 23)
MainFrame.Visible = false
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
local Stroke = Instance.new("UIStroke", MainFrame)
Stroke.Color = Color3.fromRGB(48, 54, 61)
Stroke.Thickness = 1

Widget.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Sidebar
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 160, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(22, 27, 34)
Sidebar.BorderSizePixel = 0
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 8)

-- Tab Content Area
local ContentArea = Instance.new("Frame", MainFrame)
ContentArea.Size = UDim2.new(1, -170, 1, -20)
ContentArea.Position = UDim2.new(0, 165, 0, 10)
ContentArea.BackgroundTransparency = 1

local Tabs = {}
local NavButtons = {}

local function CreateTab(name, icon)
    local scroll = Instance.new("ScrollingFrame", ContentArea)
    scroll.Size = UDim2.new(1, 0, 1, 0)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 3
    scroll.Visible = false
    local layout = Instance.new("UIListLayout", scroll)
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local btn = Instance.new("TextButton", Sidebar)
    btn.Size = UDim2.new(1, -16, 0, 35)
    btn.Position = UDim2.new(0, 8, 0, #NavButtons * 45 + 10)
    btn.BackgroundColor3 = Color3.fromRGB(13, 17, 23)
    btn.TextColor3 = Color3.fromRGB(139, 148, 158)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14
    btn.Text = icon .. " " .. name
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", btn).Color = Color3.fromRGB(48, 54, 61)
    
    btn.MouseButton1Click:Connect(function()
        for tName, tFrame in pairs(Tabs) do tFrame.Visible = (tName == name) end
        for _, nBtn in pairs(NavButtons) do
            nBtn.BackgroundColor3 = Color3.fromRGB(13, 17, 23)
            nBtn.TextColor3 = Color3.fromRGB(139, 148, 158)
        end
        btn.BackgroundColor3 = Color3.fromRGB(31, 111, 235)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)
    
    Tabs[name] = scroll
    table.insert(NavButtons, btn)
    return scroll
end

local TabMovement = CreateTab("Movement", "🏃‍♂️")
local TabCombat = CreateTab("FTAP Combat", "⚔️")
local TabVisuals = CreateTab("Visuals", "👁️")
local TabChaos = CreateTab("Chaos", "🤡")
local TabProfile = CreateTab("Profile", "📊")
local TabCore = CreateTab("Core", "🛡️")

-- Auto-select first tab
NavButtons[1].BackgroundColor3 = Color3.fromRGB(31, 111, 235)
NavButtons[1].TextColor3 = Color3.fromRGB(255, 255, 255)
Tabs["Movement"].Visible = true

-- [UI Component Builders]
local function CreateToggle(parent, text, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -10, 0, 40)
    frame.BackgroundColor3 = Color3.fromRGB(33, 38, 45)
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", frame).Color = Color3.fromRGB(48, 54, 61)
    
    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(0.8, 0, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(201, 209, 217)
    lbl.Font = Enum.Font.SourceSans
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0, 40, 0, 20)
    btn.Position = UDim2.new(1, -50, 0, 10)
    btn.BackgroundColor3 = Color3.fromRGB(248, 81, 73)
    btn.Text = ""
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
    
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = state and Color3.fromRGB(35, 134, 54) or Color3.fromRGB(248, 81, 73)}):Play()
        callback(state)
    end)
end

local function CreateSlider(parent, text, min, max, default, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -10, 0, 50)
    frame.BackgroundColor3 = Color3.fromRGB(33, 38, 45)
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", frame).Color = Color3.fromRGB(48, 54, 61)
    
    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(0.5, 0, 0, 20)
    lbl.Position = UDim2.new(0, 10, 0, 5)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(201, 209, 217)
    lbl.Font = Enum.Font.SourceSans
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    
    local valLbl = Instance.new("TextLabel", frame)
    valLbl.Size = UDim2.new(0.5, -20, 0, 20)
    valLbl.Position = UDim2.new(0.5, 10, 0, 5)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = tostring(default)
    valLbl.TextColor3 = Color3.fromRGB(139, 148, 158)
    valLbl.Font = Enum.Font.SourceSans
    valLbl.TextSize = 13
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    
    local bar = Instance.new("Frame", frame)
    bar.Size = UDim2.new(1, -20, 0, 4)
    bar.Position = UDim2.new(0, 10, 0, 35)
    bar.BackgroundColor3 = Color3.fromRGB(13, 17, 23)
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)
    
    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new((default - min)/(max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(31, 111, 235)
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
    
    local dragging = false
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local pct = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            fill.Size = UDim2.new(pct, 0, 1, 0)
            local val = math.floor(min + ((max - min) * pct))
            valLbl.Text = tostring(val)
            callback(val)
        end
    end)
end

local function CreateDropdown(parent, text, options, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -10, 0, 40)
    frame.BackgroundColor3 = Color3.fromRGB(33, 38, 45)
    frame.ClipsDescendants = true
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", frame).Color = Color3.fromRGB(48, 54, 61)
    
    local mainBtn = Instance.new("TextButton", frame)
    mainBtn.Size = UDim2.new(1, 0, 0, 40)
    mainBtn.BackgroundTransparency = 1
    mainBtn.Text = text .. ": Option"
    mainBtn.TextColor3 = Color3.fromRGB(201, 209, 217)
    mainBtn.Font = Enum.Font.SourceSansBold
    mainBtn.TextSize = 14
    
    local open = false
    mainBtn.MouseButton1Click:Connect(function()
        open = not open
        TweenService:Create(frame, TweenInfo.new(0.2), {Size = UDim2.new(1, -10, 0, open and (40 + #options * 30) or 40)}):Play()
    end)
    
    for i, opt in ipairs(options) do
        local optBtn = Instance.new("TextButton", frame)
        optBtn.Size = UDim2.new(1, -10, 0, 25)
        optBtn.Position = UDim2.new(0, 5, 0, 40 + (i-1)*30)
        optBtn.BackgroundColor3 = Color3.fromRGB(13, 17, 23)
        optBtn.Text = opt
        optBtn.TextColor3 = Color3.fromRGB(139, 148, 158)
        optBtn.Font = Enum.Font.SourceSans
        optBtn.TextSize = 13
        Instance.new("UICorner", optBtn).CornerRadius = UDim.new(0, 4)
        
        optBtn.MouseButton1Click:Connect(function()
            mainBtn.Text = text .. ": " .. opt
            open = false
            TweenService:Create(frame, TweenInfo.new(0.2), {Size = UDim2.new(1, -10, 0, 40)}):Play()
            callback(opt)
        end)
    end
end

-- [7. POPULATING TABS]

-- Movement
CreateToggle(TabMovement, "Custom WalkSpeed", function(v) Config.Movement.WalkSpeedToggle = v end)
CreateSlider(TabMovement, "WalkSpeed Value", 16, 300, 16, function(v) Config.Movement.WalkSpeed = v end)
CreateToggle(TabMovement, "Custom JumpPower", function(v) Config.Movement.JumpPowerToggle = v end)
CreateSlider(TabMovement, "JumpPower Value", 50, 400, 50, function(v) Config.Movement.JumpPower = v end)
CreateToggle(TabMovement, "Infinite Jump", function(v) Config.Movement.InfiniteJump = v end)
CreateToggle(TabMovement, "Physics Fly Mode", function(v) 
    Config.Movement.FlyMode = v
    BtnAscend.Visible = v
    BtnDescend.Visible = v
end)
CreateSlider(TabMovement, "Fly Speed", 20, 300, 50, function(v) Config.Movement.FlySpeed = v end)
CreateToggle(TabMovement, "Noclip", function(v) Config.Movement.Noclip = v end)
CreateToggle(TabMovement, "Anti-Fling", function(v) Config.Movement.AntiFling = v end)

-- Combat
CreateToggle(TabCombat, "Proximity Auto-Grab", function(v) Config.Combat.ProximityGrab = v end)
CreateSlider(TabCombat, "Grab Radius", 5, 25, 5, function(v) Config.Combat.GrabRadius = v end)
CreateToggle(TabCombat, "Perfect Centered Silent Aim", function(v) Config.Combat.SilentAim = v end)
CreateToggle(TabCombat, "Draw FOV Circle", function(v) Config.Combat.FovCircle = v end)
CreateSlider(TabCombat, "FOV Radius", 30, 400, 100, function(v) Config.Combat.FovRadius = v end)
CreateDropdown(TabCombat, "Target Hitbox", {"Head", "Torso", "HumanoidRootPart"}, function(v) Config.Combat.TargetPart = v end)
CreateSlider(TabCombat, "Prediction Force", 0, 50, 10, function(v) Config.Combat.Prediction = v end)
CreateToggle(TabCombat, "Mega-Throw (Intercept)", function(v) Config.Combat.MegaThrow = v end)
CreateSlider(TabCombat, "Throw Force Scalar", 5000, 2000000, 50000, function(v) Config.Combat.ThrowForce = v end)
CreateToggle(TabCombat, "Unbreakable Anti-Grab", function(v) Config.Combat.AntiGrab = v end)

-- Visuals
CreateToggle(TabVisuals, "ESP Boxes", function(v) Config.Visuals.EspBoxes = v end)
CreateToggle(TabVisuals, "ESP Tracers", function(v) Config.Visuals.EspTracers = v end)
CreateToggle(TabVisuals, "ESP Names", function(v) Config.Visuals.EspNames = v end)
CreateToggle(TabVisuals, "ESP Health Bar", function(v) Config.Visuals.EspHealth = v end)
CreateSlider(TabVisuals, "ESP Thickness", 1, 5, 1.5, function(v) Config.Visuals.EspThickness = v end)
CreateToggle(TabVisuals, "Fullbright", function(v) 
    Config.Visuals.Fullbright = v
    if not v then
        Lighting.Ambient = Cache.OriginalLighting.Ambient
        Lighting.OutdoorAmbient = Cache.OriginalLighting.OutdoorAmbient
        Lighting.ClockTime = Cache.OriginalLighting.ClockTime
        Lighting.FogEnd = Cache.OriginalLighting.FogEnd
        Lighting.GlobalShadows = Cache.OriginalLighting.GlobalShadows
    end
end)
CreateSlider(TabVisuals, "Screen Stretch (Aspect)", 5, 25, 10, function(v) Config.Visuals.AspectRatio = v / 10 end)
CreateToggle(TabVisuals, "Potato PC Mode", function(v) 
    Config.Visuals.PotatoMode = v
    if v then
        for _, desc in pairs(Workspace:GetDescendants()) do
            if desc:IsA("BasePart") and not desc:IsDescendantOf(LocalPlayer.Character) then
                Cache.OriginalMaterials[desc] = desc.Material
                desc.Material = Enum.Material.SmoothPlastic
            end
        end
    else
        for part, mat in pairs(Cache.OriginalMaterials) do
            if part and part.Parent then part.Material = mat end
        end
        table.clear(Cache.OriginalMaterials)
    end
end)

-- Chaos
CreateToggle(TabChaos, "Crown Vortex / Hurricane", function(v) 
    Config.Chaos.CrownVortex = v 
    if not v then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                p.Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 2000000, 0)
            end
        end
    end
end)

local FlingBox = Instance.new("TextBox", TabChaos)
FlingBox.Size = UDim2.new(1, -10, 0, 35)
FlingBox.BackgroundColor3 = Color3.fromRGB(33, 38, 45)
FlingBox.TextColor3 = Color3.fromRGB(255, 255, 255)
FlingBox.PlaceholderText = "Target Username to Fling"
Instance.new("UICorner", FlingBox).CornerRadius = UDim.new(0, 6)

local FlingBtn = Instance.new("TextButton", TabChaos)
FlingBtn.Size = UDim2.new(1, -10, 0, 35)
FlingBtn.BackgroundColor3 = Color3.fromRGB(31, 111, 235)
FlingBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FlingBtn.Text = "Execute Clash Fling"
Instance.new("UICorner", FlingBtn).CornerRadius = UDim.new(0, 6)

FlingBtn.MouseButton1Click:Connect(function()
    local targetName = string.lower(FlingBox.Text)
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and string.find(string.lower(p.Name), targetName) then
            if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local myHrp = LocalPlayer.Character.HumanoidRootPart
                local oldCf = myHrp.CFrame
                myHrp.AssemblyAngularVelocity = Vector3.new(0, 999999, 0)
                myHrp.CFrame = p.Character.HumanoidRootPart.CFrame
                task.wait(0.2)
                myHrp.AssemblyAngularVelocity = Vector3.zero
                myHrp.CFrame = oldCf
            end
        end
    end
end)

local WeldBtn = Instance.new("TextButton", TabChaos)
WeldBtn.Size = UDim2.new(1, -10, 0, 35)
WeldBtn.BackgroundColor3 = Color3.fromRGB(186, 54, 46)
WeldBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
WeldBtn.Text = "Mass Weld Map Items to Self"
Instance.new("UICorner", WeldBtn).CornerRadius = UDim.new(0, 6)

WeldBtn.MouseButton1Click:Connect(function()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    local myHrp = LocalPlayer.Character.HumanoidRootPart
    for _, item in pairs(Workspace:GetChildren()) do
        if item:IsA("BasePart") and not item.Anchored and item.Name ~= "HumanoidRootPart" then
            local w = Instance.new("WeldConstraint")
            w.Part0 = myHrp
            w.Part1 = item
            w.Parent = myHrp
        end
    end
end)

local SpamBox = Instance.new("TextBox", TabChaos)
SpamBox.Size = UDim2.new(1, -10, 0, 35)
SpamBox.BackgroundColor3 = Color3.fromRGB(33, 38, 45)
SpamBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SpamBox.Text = "GitHub Dark Suite Active"
Instance.new("UICorner", SpamBox).CornerRadius = UDim.new(0, 6)
SpamBox.Changed:Connect(function() Config.Chaos.SpamMessage = SpamBox.Text end)
CreateToggle(TabChaos, "Chat Spammer", function(v) Config.Chaos.ChatSpam = v end)

-- Profile
local ProfileFrame = Instance.new("Frame", TabProfile)
ProfileFrame.Size = UDim2.new(1, -10, 0, 150)
ProfileFrame.BackgroundColor3 = Color3.fromRGB(33, 38, 45)
Instance.new("UICorner", ProfileFrame).CornerRadius = UDim.new(0, 8)

local VPF = Instance.new("ViewportFrame", ProfileFrame)
VPF.Size = UDim2.new(0, 120, 1, -10)
VPF.Position = UDim2.new(0, 5, 0, 5)
VPF.BackgroundTransparency = 1

local StatsLabel = Instance.new("TextLabel", ProfileFrame)
StatsLabel.Size = UDim2.new(1, -140, 1, -10)
StatsLabel.Position = UDim2.new(0, 130, 0, 5)
StatsLabel.BackgroundTransparency = 1
StatsLabel.TextColor3 = Color3.fromRGB(201, 209, 217)
StatsLabel.TextXAlignment = Enum.TextXAlignment.Left
StatsLabel.Font = Enum.Font.Code
StatsLabel.TextSize = 14
StatsLabel.Text = "Loading..."

task.spawn(function()
    pcall(function()
        LocalPlayer.Character.Archivable = true
        local clone = LocalPlayer.Character:Clone()
        clone.Parent = VPF
        local cam = Instance.new("Camera")
        cam.CFrame = CFrame.new(clone.HumanoidRootPart.Position + Vector3.new(0, 2, 5), clone.HumanoidRootPart.Position)
        VPF.CurrentCamera = cam
        cam.Parent = VPF
    end)
    
    local frames, lastTick = 0, tick()
    local fps = 60
    while task.wait(0.5) do
        frames += 1
        local current = tick()
        if current - lastTick >= 1 then
            fps = math.floor(frames / (current - lastTick))
            frames = 0
            lastTick = current
        end
        local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
        StatsLabel.Text = string.format("Display: %s\nUser: @%s\nAge: %d Days\nFPS: %d\nPing: %dms", 
            LocalPlayer.DisplayName, LocalPlayer.Name, LocalPlayer.AccountAge, fps, ping)
    end
end)

-- Core / Unload
local UnloadBtn = Instance.new("TextButton", TabCore)
UnloadBtn.Size = UDim2.new(1, -10, 0, 45)
UnloadBtn.BackgroundColor3 = Color3.fromRGB(186, 54, 46)
UnloadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
UnloadBtn.Font = Enum.Font.SourceSansBold
UnloadBtn.TextSize = 16
UnloadBtn.Text = "FORCE UNLOAD SCRIPT"
Instance.new("UICorner", UnloadBtn).CornerRadius = UDim.new(0, 6)

UnloadBtn.MouseButton1Click:Connect(function()
    for _, con in pairs(Cache.Connections) do if con.Connected then con:Disconnect() end end
    table.clear(Cache.Connections)
    
    for p, _ in pairs(Cache.EspDrawings) do RemoveEsp(p) end
    if Cache.FovCircle then pcall(function() Cache.FovCircle:Remove() end) end
    
    Lighting.Ambient = Cache.OriginalLighting.Ambient
    Lighting.OutdoorAmbient = Cache.OriginalLighting.OutdoorAmbient
    Lighting.ClockTime = Cache.OriginalLighting.ClockTime
    Lighting.FogEnd = Cache.OriginalLighting.FogEnd
    Lighting.GlobalShadows = Cache.OriginalLighting.GlobalShadows
    Camera.AspectRatio = 1.0
    
    for part, mat in pairs(Cache.OriginalMaterials) do if part and part.Parent then part.Material = mat end end
    
    pcall(function()
        local h = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        h.WalkSpeed = 16
        h.JumpPower = 50
    end)
    
    Gui:Destroy()
end)
