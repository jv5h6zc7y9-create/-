--===================================================================================--
-- APPLE / IOS MINIMALIST ADMINISTRATIVE SUITE v3                                    --
-- TARGET ARCHITECTURE: ROBLOX "FLING THINGS AND PEOPLE" (FTAP)                      --
-- PLATFORM OPTIMIZATION: MOBILE / DELTA EXECUTOR                                    --
--===================================================================================--

-- [1. GLOBAL SERVICES & FRAMEWORK SETUP]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- [2. GLOBAL MUTABLE ENGINE STATES]
local SystemConfig = {
    Movement = {
        WalkSpeedToggle = false, WalkSpeed = 16,
        JumpPowerToggle = false, JumpPower = 50,
        InfiniteJump = false,
        FlyMode = false, FlySpeed = 50,
        Noclip = false, AntiFling = false
    },
    Combat = {
        ClickToGrab = false,
        AntiGrab = false,
        MegaThrow = false, ThrowForce = 50000
    },
    Visuals = {
        EspEnabled = false, EspNames = false, EspHealth = false, EspBoxes = false,
        AspectRatio = 1.0, Fullbright = false, PotatoMode = false
    },
    World = {
        GravityToggle = false, GravityValue = 196.2
    },
    Chaos = {
        CrownVortex = false, ThrowForceSlider = 100000
    }
}

local EngineCache = {
    OriginalLighting = {
        Ambient = Lighting.Ambient,
        OutdoorAmbient = Lighting.OutdoorAmbient,
        ClockTime = Lighting.ClockTime,
        FogEnd = Lighting.FogEnd,
        GlobalShadows = Lighting.GlobalShadows
    },
    OriginalMaterials = {},
    Connections = {},
    SafeCFrame = CFrame.new(),
    FlyAscend = false,
    FlyDescend = false,
    EspObjects = {},
    CapturedVortexTargets = {}
}

-- [3. SECURE PHANTOM METATABLE HOOKS]
local function InitializeBypass()
    local MetaTable = getrawmetatable(game)
    if not MetaTable then return end
    
    setreadonly(MetaTable, false)
    local OriginalIndex = MetaTable.__index
    local OriginalNewIndex = MetaTable.__newindex
    
    MetaTable.__index = newcclosure(function(Self, Key)
        if not checkcaller() and typeof(Self) == "Instance" and Self:IsA("Humanoid") then
            if Key == "WalkSpeed" and SystemConfig.Movement.WalkSpeedToggle then return 16 end
            if Key == "JumpPower" and SystemConfig.Movement.JumpPowerToggle then return 50 end
        end
        return OriginalIndex(Self, Key)
    end)
    
    MetaTable.__newindex = newcclosure(function(Self, Key, Value)
        if not checkcaller() and typeof(Self) == "Instance" and Self:IsA("Humanoid") then
            if Key == "WalkSpeed" and SystemConfig.Movement.WalkSpeedToggle then return end
            if Key == "JumpPower" and SystemConfig.Movement.JumpPowerToggle then return end
        end
        return OriginalNewIndex(Self, Key, Value)
    end)
    
    setreadonly(MetaTable, true)
end
pcall(InitializeBypass)

-- [4. STABLE NATIVE EXPLOIT SYSTEMS LOGIC]

-- Continuous Physics & Character Loop
table.insert(EngineCache.Connections, RunService.Stepped:Connect(function()
    local Character = LocalPlayer.Character
    if not Character then return end
    
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Character:FindFirstChild("HumanoidRootPart")
    
    if Humanoid then
        if SystemConfig.Movement.WalkSpeedToggle then Humanoid.WalkSpeed = SystemConfig.Movement.WalkSpeed end
        if SystemConfig.Movement.JumpPowerToggle then Humanoid.JumpPower = SystemConfig.Movement.JumpPower end
    end
    
    if SystemConfig.Movement.Noclip then
        for _, Part in pairs(Character:GetDescendants()) do
            if Part:IsA("BasePart") then Part.CanCollide = false end
        end
    end
    
    if RootPart then
        if SystemConfig.Movement.AntiFling then
            RootPart.AssemblyAngularVelocity = Vector3.zero
            if RootPart.AssemblyLinearVelocity.Magnitude > 120 then
                RootPart.AssemblyLinearVelocity = RootPart.AssemblyLinearVelocity.Unit * 12
            end
        end
        
        if SystemConfig.Movement.FlyMode then
            local FlyVelocity = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then FlyVelocity += Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then FlyVelocity -= Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then FlyVelocity -= Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then FlyVelocity += Camera.CFrame.RightVector end
            if EngineCache.FlyAscend then FlyVelocity += Vector3.new(0, 1, 0) end
            if EngineCache.FlyDescend then FlyVelocity -= Vector3.new(0, 1, 0) end
            
            if FlyVelocity.Magnitude > 0 then
                RootPart.AssemblyLinearVelocity = FlyVelocity.Unit * SystemConfig.Movement.FlySpeed
            else
                RootPart.AssemblyLinearVelocity = Vector3.zero
            end
        end
    end
end))

-- Post-Physics Interception & Memory Caching Loop
table.insert(EngineCache.Connections, RunService.Heartbeat:Connect(function()
    local Character = LocalPlayer.Character
    if not Character then return end
    
    local RootPart = Character:FindFirstChild("HumanoidRootPart")
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    
    if SystemConfig.Combat.AntiGrab and RootPart and Humanoid then
        for _, Object in pairs(Character:GetDescendants()) do
            if Object:IsA("Weld") or Object:IsA("WeldConstraint") or Object:IsA("Motor6D") or Object:IsA("RopeConstraint") then
                local IsNative = false
                for _, NativePart in pairs(Character:GetChildren()) do
                    if Object:IsDescendantOf(NativePart) or Object.Parent == NativePart then
                        if not Object.Parent:IsA("Tool") then IsNative = true end
                    end
                end
                if not IsNative then pcall(function() Object:Destroy() end) end
            end
        end
        
        Humanoid.PlatformStanding = false
        Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        
        if RootPart.AssemblyLinearVelocity.Magnitude > 75 then
            RootPart.CFrame = EngineCache.SafeCFrame
            RootPart.AssemblyLinearVelocity = Vector3.zero
        else
            EngineCache.SafeCFrame = RootPart.CFrame
        end
    end
    
    if SystemConfig.Visuals.Fullbright then
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        Lighting.ClockTime = 14
        Lighting.FogEnd = 999999
        Lighting.GlobalShadows = false
    end
    
    if SystemConfig.Visuals.AspectRatio ~= 1.0 then
        Camera.AspectRatio = SystemConfig.Visuals.AspectRatio
    end
    
    if SystemConfig.World.GravityToggle then
        Workspace.Gravity = SystemConfig.World.GravityValue
    end
end))

-- Stable Bulletproof Click-To-Grab Logic
local Mouse = LocalPlayer:GetMouse()
table.insert(EngineCache.Connections, Mouse.Button1Down:Connect(function()
    if not SystemConfig.Combat.ClickToGrab then return end
    local Target = Mouse.Target
    if Target and Target.Parent and Target.Parent:FindFirstChild("Humanoid") then
        local EnemyRoot = Target.Parent:FindFirstChild("HumanoidRootPart")
        if EnemyRoot and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local Tool = LocalPlayer.Character:FindFirstChildOfClass("Tool") or LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
            if Tool then
                -- Temporarily snap the target to the player's immediate grab radius
                local TargetOriginalCF = EnemyRoot.CFrame
                EnemyRoot.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)
                task.wait(0.01)
                Tool:Activate()
            end
        end
    end
end))

-- Dynamic Halo Vortex Processing Loop
task.spawn(function()
    while task.wait(0.01) do
        if SystemConfig.Chaos.CrownVortex then
            local Character = LocalPlayer.Character
            if Character and Character:FindFirstChild("HumanoidRootPart") then
                local RootPart = Character.HumanoidRootPart
                RootPart.Anchored = true
                
                table.clear(EngineCache.CapturedVortexTargets)
                for _, Player in pairs(Players:GetPlayers()) do
                    if Player ~= LocalPlayer and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                        table.insert(EngineCache.CapturedVortexTargets, Player.Character.HumanoidRootPart)
                    end
                end
                
                local TargetCount = #EngineCache.CapturedVortexTargets
                if TargetCount > 0 then
                    local RadialIndex = tick() * 3
                    for PositionIndex, TargetRoot in ipairs(EngineCache.CapturedVortexTargets) do
                        local Angle = ((PositionIndex / TargetCount) * math.pi * 2) + RadialIndex
                        local PositionOffset = Vector3.new(math.cos(Angle) * 10, 25, math.sin(Angle) * 10)
                        TargetRoot.CFrame = RootPart.CFrame * CFrame.new(PositionOffset)
                        TargetRoot.AssemblyLinearVelocity = Vector3.zero
                        
                        local GrabTool = Character:FindFirstChildOfClass("Tool")
                        if GrabTool then GrabTool:Activate() end
                    end
                end
            end
        end
    end
end)

-- Infinite Jump Request Core Trigger
table.insert(EngineCache.Connections, UserInputService.JumpRequest:Connect(function()
    if SystemConfig.Movement.InfiniteJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
    end
end))

-- Native Throw Hooking Module (Mega Throw)
local MetatableBackup = getrawmetatable(game)
if MetatableBackup then
    setreadonly(MetatableBackup, false)
    local NamecallBackup = MetatableBackup.__namecall
    MetatableBackup.__namecall = newcclosure(function(Self, ...)
        local RemoteMethod = getnamecallmethod()
        local Arguments = {...}
        if RemoteMethod == "FireServer" and SystemConfig.Combat.MegaThrow and typeof(Self) == "Instance" and Self.Name:lower():match("throw") then
            if typeof(Arguments[1]) == "Instance" and Arguments[1]:IsA("BasePart") then
                Arguments[1].AssemblyLinearVelocity = Arguments[1].AssemblyLinearVelocity.Unit * SystemConfig.Combat.ThrowForce
            end
        end
        return NamecallBackup(Self, unpack(Arguments))
    end)
    setreadonly(MetatableBackup, true)
end

-- [5. HIGH-PERFORMANCE NATIVE ESP PIPELINE]
local function ConstructPlayerEsp(TargetPlayer)
    if TargetPlayer == LocalPlayer then return end
    
    local Billboard = Instance.new("BillboardGui")
    Billboard.Name = "iOS_Core_Esp"
    Billboard.Size = UDim2.new(4, 0, 5.5, 0)
    Billboard.AlwaysOnTop = true
    Billboard.ResetOnSpawn = false
    
    local BoxFrame = Instance.new("Frame", Billboard)
    BoxFrame.Size = UDim2.new(1, 0, 1, 0)
    BoxFrame.BackgroundTransparency = 1
    local Stroke = Instance.new("UIStroke", BoxFrame)
    Stroke.Color = Color3.fromRGB(10, 132, 255)
    Stroke.Thickness = 1.5
    Stroke.Enabled = false
    
    local HeaderLabel = Instance.new("TextLabel", Billboard)
    HeaderLabel.Size = UDim2.new(1, 0, 0, 15)
    HeaderLabel.Position = UDim2.new(0, 0, 0, -18)
    HeaderLabel.BackgroundTransparency = 1
    HeaderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    HeaderLabel.Font = Enum.Font.SourceSansBold
    HeaderLabel.TextSize = 13
    HeaderLabel.TextVisible = false
    
    local InternalHealthBar = Instance.new("Frame", BoxFrame)
    InternalHealthBar.Size = UDim2.new(0, 3, 1, 0)
    InternalHealthBar.Position = UDim2.new(0, -8, 0, 0)
    InternalHealthBar.BackgroundColor3 = Color3.fromRGB(48, 209, 88)
    InternalHealthBar.BorderSizePixel = 0
    InternalHealthBar.Visible = false
    
    EngineCache.EspObjects[TargetPlayer] = {
        Gui = Billboard,
        Box = Stroke,
        Text = HeaderLabel,
        Health = InternalHealthBar
    }
    
    local function BindCharacter(Char)
        if Char then
            local Root = Char:WaitForChild("HumanoidRootPart", 5)
            if Root then Billboard.Adornee = Root; Billboard.Parent = CoreGui end
        end
    end
    
    TargetPlayer.CharacterAdded:Connect(BindCharacter)
    BindCharacter(TargetPlayer.Character)
end

local function CleanPlayerEsp(TargetPlayer)
    if EngineCache.EspObjects[TargetPlayer] then
        pcall(function() EngineCache.EspObjects[TargetPlayer].Gui:Destroy() end)
        EngineCache.EspObjects[TargetPlayer] = nil
    end
end

for _, P in pairs(Players:GetPlayers()) do ConstructPlayerEsp(P) end
table.insert(EngineCache.Connections, Players.PlayerAdded:Connect(ConstructPlayerEsp))
table.insert(EngineCache.Connections, Players.PlayerRemoving:Connect(CleanPlayerEsp))

table.insert(EngineCache.Connections, RunService.RenderStepped:Connect(function()
    if not SystemConfig.Visuals.EspEnabled then
        for _, Assets in pairs(EngineCache.EspObjects) do
            Assets.Box.Enabled = false
            Assets.Text.Visible = false
            Assets.Health.Visible = false
        end
        return
    end
    
    for Plr, Assets in pairs(EngineCache.EspObjects) do
        if Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart") and Plr.Character:FindFirstChildOfClass("Humanoid") then
            local Hum = Plr.Character:FindFirstChildOfClass("Humanoid")
            Assets.Box.Enabled = SystemConfig.Visuals.EspBoxes
            
            if SystemConfig.Visuals.EspNames then
                Assets.Text.Text = Plr.DisplayName .. " (@" .. Plr.Name .. ")"
                Assets.Text.Visible = true
            else
                Assets.Text.Visible = false
            end
            
            if SystemConfig.Visuals.EspHealth and Hum.MaxHealth > 0 then
                local Scale = math.clamp(Hum.Health / Hum.MaxHealth, 0, 1)
                Assets.Health.Size = UDim2.new(0, 3, Scale, 0)
                Assets.Health.Position = UDim2.new(0, -8, 1 - Scale, 0)
                Assets.Health.BackgroundColor3 = Color3.fromRGB(255 * (1 - Scale), 214 * Scale, 0)
                Assets.Health.Visible = true
            else
                Assets.Health.Visible = false
            end
        else
            Assets.Box.Enabled = false
            Assets.Text.Visible = false
            Assets.Health.Visible = false
        end
    end
end))

-- [6. UI ENGINE DESIGN: APPLE DARK MINIMALIST]
local MainGui = Instance.new("ScreenGui")
MainGui.Name = "AppleCoreSuite"
MainGui.ResetOnSpawn = false
MainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
if not pcall(function() MainGui.Parent = CoreGui end) then MainGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- Flight Mobile Anchors
local FlyControlAscend = Instance.new("TextButton", MainGui)
FlyControlAscend.Size = UDim2.new(0, 75, 0, 50)
FlyControlAscend.Position = UDim2.new(0.88, -40, 0.55, -25)
FlyControlAscend.BackgroundColor3 = Color3.fromRGB(28, 28, 30)
FlyControlAscend.TextColor3 = Color3.fromRGB(255, 255, 255)
FlyControlAscend.Font = Enum.Font.SourceSansBold
FlyControlAscend.TextSize = 15
FlyControlAscend.Text = "Ascend"
FlyControlAscend.Visible = false
Instance.new("UICorner", FlyControlAscend).CornerRadius = UDim.new(0, 14)
local ControlStroke1 = Instance.new("UIStroke", FlyControlAscend)
ControlStroke1.Color = Color3.fromRGB(58, 58, 60)
ControlStroke1.Thickness = 1

local FlyControlDescend = Instance.new("TextButton", MainGui)
FlyControlDescend.Size = UDim2.new(0, 75, 0, 50)
FlyControlDescend.Position = UDim2.new(0.88, -40, 0.65, 0)
FlyControlDescend.BackgroundColor3 = Color3.fromRGB(28, 28, 30)
FlyControlDescend.TextColor3 = Color3.fromRGB(255, 255, 255)
FlyControlDescend.Font = Enum.Font.SourceSansBold
FlyControlDescend.TextSize = 15
FlyControlDescend.Text = "Descend"
FlyControlDescend.Visible = false
Instance.new("UICorner", FlyControlDescend).CornerRadius = UDim.new(0, 14)
local ControlStroke2 = Instance.new("UIStroke", FlyControlDescend)
ControlStroke2.Color = Color3.fromRGB(58, 58, 60)
ControlStroke2.Thickness = 1

FlyControlAscend.InputBegan:Connect(function() EngineCache.FlyAscend = true end)
FlyControlAscend.InputEnded:Connect(function() EngineCache.FlyAscend = false end)
FlyControlDescend.InputBegan:Connect(function() EngineCache.FlyDescend = true end)
FlyControlDescend.InputEnded:Connect(function() EngineCache.FlyDescend = false end)

-- Smooth Apple Interceptor Widget Button
local FloatingWidget = Instance.new("TextButton", MainGui)
FloatingWidget.Size = UDim2.new(0, 55, 0, 55)
FloatingWidget.Position = UDim2.new(0.05, 0, 0.15, 0)
FloatingWidget.BackgroundColor3 = Color3.fromRGB(28, 28, 30)
FloatingWidget.Text = "⚡"
FloatingWidget.TextColor3 = Color3.fromRGB(10, 132, 255)
FloatingWidget.TextSize = 24
Instance.new("UICorner", FloatingWidget).CornerRadius = UDim.new(1, 0)
local WidgetStroke = Instance.new("UIStroke", FloatingWidget)
WidgetStroke.Color = Color3.fromRGB(58, 58, 60)
WidgetStroke.Thickness = 1.5

local IsDraggingWidget, PositionDragStart, InitialWidgetPosition
FloatingWidget.InputBegan:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
        IsDraggingWidget = true
        PositionDragStart = Input.Position
        InitialWidgetPosition = FloatingWidget.Position
    end
end)
UserInputService.InputChanged:Connect(function(Input)
    if IsDraggingWidget and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
        local OffsetDelta = Input.Position - PositionDragStart
        FloatingWidget.Position = UDim2.new(InitialWidgetPosition.X.Scale, InitialWidgetPosition.X.Offset + OffsetDelta.X, InitialWidgetPosition.Y.Scale, InitialWidgetPosition.Y.Offset + OffsetDelta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
        IsDraggingWidget = false
    end
end)

-- Main Settings Glass Window Frame
local MainViewFrame = Instance.new("Frame", MainGui)
MainViewFrame.Size = UDim2.new(0, 620, 0, 420)
MainViewFrame.Position = UDim2.new(0.5, -310, 0.5, -210)
MainViewFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 30)
MainViewFrame.BackgroundTransparency = 0.05
MainViewFrame.Visible = false
Instance.new("UICorner", MainViewFrame).CornerRadius = UDim.new(0, 16)
local PanelStroke = Instance.new("UIStroke", MainViewFrame)
PanelStroke.Color = Color3.fromRGB(58, 58, 60)
PanelStroke.Thickness = 1.5

FloatingWidget.MouseButton1Click:Connect(function()
    MainViewFrame.Visible = not MainViewFrame.Visible
end)

-- Left Side Apple System Sidebar Menu List
local LeftNavigationFrame = Instance.new("Frame", MainViewFrame)
LeftNavigationFrame.Size = UDim2.new(0, 180, 1, 0)
LeftNavigationFrame.BackgroundColor3 = Color3.fromRGB(44, 44, 46)
LeftNavigationFrame.BackgroundTransparency = 0.3
LeftNavigationFrame.BorderSizePixel = 0
Instance.new("UICorner", LeftNavigationFrame).CornerRadius = UDim.new(0, 16)
local SeparatorLine = Instance.new("Frame", LeftNavigationFrame)
SeparatorLine.Size = UDim2.new(0, 1, 1, 0)
SeparatorLine.Position = UDim2.new(1, 0, 0, 0)
SeparatorLine.BackgroundColor3 = Color3.fromRGB(58, 58, 60)
SeparatorLine.BorderSizePixel = 0

local ContentDisplayFrame = Instance.new("Frame", MainViewFrame)
ContentDisplayFrame.Size = UDim2.new(1, -195, 1, -20)
ContentDisplayFrame.Position = UDim2.new(0, 190, 0, 10)
ContentDisplayFrame.BackgroundTransparency = 1

local ActiveViewTabs = {}
local NavigationSelectionButtons = {}

local function InsertiOSMenuTab(TabName, IdentityIcon)
    local ScrollerCellContainer = Instance.new("ScrollingFrame", ContentDisplayFrame)
    ScrollerCellContainer.Size = UDim2.new(1, 0, 1, 0)
    ScrollerCellContainer.BackgroundTransparency = 1
    ScrollerCellContainer.ScrollBarThickness = 0
    ScrollerCellContainer.Visible = false
    
    local ListConfig = Instance.new("UIListLayout", ScrollerCellContainer)
    ListConfig.Padding = UDim.new(0, 12)
    ListConfig.SortOrder = Enum.SortOrder.LayoutOrder
    
    local TabSelectionButton = Instance.new("TextButton", LeftNavigationFrame)
    TabSelectionButton.Size = UDim2.new(1, -20, 0, 42)
    TabSelectionButton.Position = UDim2.new(0, 10, 0, #NavigationSelectionButtons * 50 + 15)
    TabSelectionButton.BackgroundColor3 = Color3.fromRGB(44, 44, 46)
    TabSelectionButton.BackgroundTransparency = 1
    TabSelectionButton.TextColor3 = Color3.fromRGB(235, 235, 245)
    TabSelectionButton.Font = Enum.Font.SourceSansBold
    TabSelectionButton.TextSize = 16
    TabSelectionButton.Text = IdentityIcon .. "  " .. TabName
    TabSelectionButton.TextXAlignment = Enum.TextXAlignment.Left
    
    local PaddingOffset = Instance.new("UIPadding", TabSelectionButton)
    PaddingOffset.PaddingLeft = UDim.new(0, 15)
    Instance.new("UICorner", TabSelectionButton).CornerRadius = UDim.new(0, 12)
    
    TabSelectionButton.MouseButton1Click:Connect(function()
        for RegistryName, RegisteredView in pairs(ActiveViewTabs) do RegisteredView.Visible = (RegistryName == TabName) end
        for _, NavigationButton in pairs(NavigationSelectionButtons) do
            NavigationButton.BackgroundColor3 = Color3.fromRGB(44, 44, 46)
            NavigationButton.BackgroundTransparency = 1
            NavigationButton.TextColor3 = Color3.fromRGB(235, 235, 245)
        end
        TabSelectionButton.BackgroundColor3 = Color3.fromRGB(10, 132, 255)
        TabSelectionButton.BackgroundTransparency = 0
        TabSelectionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)
    
    ActiveViewTabs[TabName] = ScrollerCellContainer
    table.insert(NavigationSelectionButtons, TabSelectionButton)
    return ScrollerCellContainer
end

local TabMovement = InsertiOSMenuTab("Movement", "🏃‍♂️")
local TabCombat = InsertiOSMenuTab("FTAP Combat", "⚔️")
local TabVisuals = InsertiOSMenuTab("Visuals", "👁️")
local TabWorld = InsertiOSMenuTab("World", "🏪")
local TabChaos = InsertiOSMenuTab("Chaos", "🤡")
local TabSystem = InsertiOSMenuTab("System", "🛡️")

NavigationSelectionButtons[1].BackgroundColor3 = Color3.fromRGB(10, 132, 255)
NavigationSelectionButtons[1].BackgroundTransparency = 0
NavigationSelectionButtons[1].TextColor3 = Color3.fromRGB(255, 255, 255)
ActiveViewTabs["Movement"].Visible = true

-- [7. STABLE COMPONENT GRAPHICS BUILDERS]
local function AppendAppleToggle(ParentCell, LabelString, TriggerCallback)
    local FrameCell = Instance.new("Frame", ParentCell)
    FrameCell.Size = UDim2.new(1, -10, 0, 50)
    FrameCell.BackgroundColor3 = Color3.fromRGB(44, 44, 46)
    Instance.new("UICorner", FrameCell).CornerRadius = UDim.new(0, 12)
    
    local Label = Instance.new("TextLabel", FrameCell)
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Position = UDim2.new(0, 15, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = LabelString
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.Font = Enum.Font.SourceSansSemibold
    Label.TextSize = 16
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local ToggleHousing = Instance.new("TextButton", FrameCell)
    ToggleHousing.Size = UDim2.new(0, 51, 0, 31)
    ToggleHousing.Position = UDim2.new(1, -66, 0, 9)
    ToggleHousing.BackgroundColor3 = Color3.fromRGB(58, 58, 60)
    ToggleHousing.Text = ""
    Instance.new("UICorner", ToggleHousing).CornerRadius = UDim.new(1, 0)
    
    local ToggleSliderBall = Instance.new("Frame", ToggleHousing)
    ToggleSliderBall.Size = UDim2.new(0, 27, 0, 27)
    ToggleSliderBall.Position = UDim2.new(0, 2, 0, 2)
    ToggleSliderBall.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", ToggleSliderBall).CornerRadius = UDim.new(1, 0)
    
    local InternalState = false
    ToggleHousing.MouseButton1Click:Connect(function()
        InternalState = not InternalState
        TweenService:Create(ToggleHousing, TweenInfo.new(0.2), {BackgroundColor3 = InternalState and Color3.fromRGB(48, 209, 88) or Color3.fromRGB(58, 58, 60)}):Play()
        TweenService:Create(ToggleSliderBall, TweenInfo.new(0.2), {Position = InternalState and UDim2.new(1, -29, 0, 2) or UDim2.new(0, 2, 0, 2)}):Play()
        TriggerCallback(InternalState)
    end)
end

local function AppendAppleSlider(ParentCell, LabelString, MinimumValue, MaximumValue, InitialDefault, TriggerCallback)
    local FrameCell = Instance.new("Frame", ParentCell)
    FrameCell.Size = UDim2.new(1, -10, 0, 65)
    FrameCell.BackgroundColor3 = Color3.fromRGB(44, 44, 46)
    Instance.new("UICorner", FrameCell).CornerRadius = UDim.new(0, 12)
    
    local Label = Instance.new("TextLabel", FrameCell)
    Label.Size = UDim2.new(0.5, 0, 0, 30)
    Label.Position = UDim2.new(0, 15, 0, 5)
    Label.BackgroundTransparency = 1
    Label.Text = LabelString
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.Font = Enum.Font.SourceSansSemibold
    Label.TextSize = 16
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local IndicatorLabel = Instance.new("TextLabel", FrameCell)
    IndicatorLabel.Size = UDim2.new(0.4, 0, 0, 30)
    IndicatorLabel.Position = UDim2.new(0.6, -15, 0, 5)
    IndicatorLabel.BackgroundTransparency = 1
    IndicatorLabel.Text = tostring(InitialDefault)
    IndicatorLabel.TextColor3 = Color3.fromRGB(235, 235, 245)
    IndicatorLabel.TextTransparency = 0.4
    IndicatorLabel.Font = Enum.Font.SourceSansSemibold
    IndicatorLabel.TextSize = 16
    IndicatorLabel.TextXAlignment = Enum.TextXAlignment.Right
    
    local SliderRail = Instance.new("Frame", FrameCell)
    SliderRail.Size = UDim2.new(1, -30, 0, 4)
    SliderRail.Position = UDim2.new(0, 15, 0, 45)
    SliderRail.BackgroundColor3 = Color3.fromRGB(58, 58, 60)
    Instance.new("UICorner", SliderRail).CornerRadius = UDim.new(1, 0)
    
    local SliderFill = Instance.new("Frame", SliderRail)
    SliderFill.Size = UDim2.new((InitialDefault - MinimumValue)/(MaximumValue - MinimumValue), 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(10, 132, 255)
    Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(1, 0)
    
    local ContinuousDragState = false
    SliderRail.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then ContinuousDragState = true end
    end)
    UserInputService.InputEnded:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then ContinuousDragState = false end
    end)
    UserInputService.InputChanged:Connect(function(Input)
        if ContinuousDragState and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
            local PercentPosition = math.clamp((Input.Position.X - SliderRail.AbsolutePosition.X) / SliderRail.AbsoluteSize.X, 0, 1)
            SliderFill.Size = UDim2.new(PercentPosition, 0, 1, 0)
            local RealValue = math.floor(MinimumValue + ((MaximumValue - MinimumValue) * PercentPosition))
            IndicatorLabel.Text = tostring(RealValue)
            TriggerCallback(RealValue)
        end
    end)
end

-- [8. CONFIGURING THE DATA CELLS]

-- Movement Settings Tab
AppendAppleToggle(TabMovement, "Modify WalkSpeed Spoofer", function(V) SystemConfig.Movement.WalkSpeedToggle = V end)
AppendAppleSlider(TabMovement, "Target Speed Value", 16, 300, 16, function(V) SystemConfig.Movement.WalkSpeed = V end)
AppendAppleToggle(TabMovement, "Modify JumpPower Spoofer", function(V) SystemConfig.Movement.JumpPowerToggle = V end)
AppendAppleSlider(TabMovement, "Target Jump Value", 50, 400, 50, function(V) SystemConfig.Movement.JumpPower = V end)
AppendAppleToggle(TabMovement, "Enable Infinite Airborne Jumps", function(V) SystemConfig.Movement.InfiniteJump = V end)
AppendAppleToggle(TabMovement, "Stable Engine Flight Mode", function(V) 
    SystemConfig.Movement.FlyMode = V
    FlyControlAscend.Visible = V
    FlyControlDescend.Visible = V
    if not V and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
    end
end)
AppendAppleSlider(TabMovement, "Flight Control Speed Factor", 20, 300, 50, function(V) SystemConfig.Movement.FlySpeed = V end)
AppendAppleToggle(TabMovement, "Bypass Collision Matrix (Noclip)", function(V) SystemConfig.Movement.Noclip = V end)
AppendAppleToggle(TabMovement, "Prevent Phase Forces (AntiFling)", function(V) SystemConfig.Movement.AntiFling = V end)

-- Combat Target Tab
AppendAppleToggle(TabCombat, "Raycast Screen Click-To-Grab", function(V) SystemConfig.Combat.ClickToGrab = V end)
AppendAppleToggle(TabCombat, "Instant Anchor Break (AntiGrab)", function(V) SystemConfig.Combat.AntiGrab = V end)
AppendAppleToggle(TabCombat, "Amplify Velocity (MegaThrow)", function(V) SystemConfig.Combat.MegaThrow = V end)
AppendAppleSlider(TabCombat, "Launch Force Projection Factor", 5000, 500000, 50000, function(V) SystemConfig.Combat.ThrowForce = V end)

-- Render Visuals Tab
AppendAppleToggle(TabVisuals, "Activate Structural HUD ESP Master", function(V) SystemConfig.Visuals.EspEnabled = V end)
AppendAppleToggle(TabVisuals, "Show Identity Text (Names)", function(V) SystemConfig.Visuals.EspNames = V end)
AppendAppleToggle(TabVisuals, "Render Relative Vital Metrics (Health)", function(V) SystemConfig.Visuals.EspHealth = V end)
AppendAppleToggle(TabVisuals, "Draw Solid Targeting Bounds (Boxes)", function(V) SystemConfig.Visuals.EspBoxes = V end)
AppendAppleSlider(TabVisuals, "Camera Aspect Wide-Stretch Ratio", 5, 25, 10, function(V) SystemConfig.Visuals.AspectRatio = V / 10 end)
AppendAppleToggle(TabVisuals, "Luminescence Correction (Fullbright)", function(V) 
    SystemConfig.Visuals.Fullbright = V 
    if not V then
        Lighting.Ambient = EngineCache.OriginalLighting.Ambient
        Lighting.OutdoorAmbient = EngineCache.OriginalLighting.OutdoorAmbient
        Lighting.ClockTime = EngineCache.OriginalLighting.ClockTime
        Lighting.FogEnd = EngineCache.OriginalLighting.FogEnd
        Lighting.GlobalShadows = EngineCache.OriginalLighting.GlobalShadows
    end
end)
AppendAppleToggle(TabVisuals, "Maximize Mobile FPS (Potato Mode)", function(V)
    SystemConfig.Visuals.PotatoMode = V
    if V then
        for _, AssetPart in pairs(Workspace:GetDescendants()) do
            if AssetPart:IsA("BasePart") and not AssetPart:IsDescendantOf(LocalPlayer.Character) then
                EngineCache.OriginalMaterials[AssetPart] = AssetPart.Material
                AssetPart.Material = Enum.Material.SmoothPlastic
            end
        end
    else
        for TrackedPart, CoreMaterial in pairs(EngineCache.OriginalMaterials) do
            if TrackedPart and TrackedPart.Parent then TrackedPart.Material = CoreMaterial end
        end
        table.clear(EngineCache.OriginalMaterials)
    end
end)

-- World Engine Manipulator
AppendAppleToggle(TabWorld, "Override Gravitational Constant", function(V) 
    SystemConfig.World.GravityToggle = V 
    if not V then Workspace.Gravity = 196.2 end
end)
AppendAppleSlider(TabWorld, "System Gravity Acceleration Value", 0, 196, 196, function(V) SystemConfig.World.GravityValue = V end)

-- Chaos Disruption Module
AppendAppleToggle(TabChaos, "Activate Orbital Crown Vortex Aura", function(V) 
    SystemConfig.Chaos.CrownVortex = V 
    if not V then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.Anchored = false
        end
        -- Launch targets based on view direction
        for _, TargetRoot in ipairs(EngineCache.CapturedVortexTargets) do
            if TargetRoot and TargetRoot.Parent then
                TargetRoot.AssemblyLinearVelocity = Camera.CFrame.LookVector * SystemConfig.Chaos.ThrowForceSlider
            end
        end
        table.clear(EngineCache.CapturedVortexTargets)
    end
end)
AppendAppleSlider(TabChaos, "Vortex Release Launch Force", 50000, 2000000, 100000, function(V) SystemConfig.Chaos.ThrowForceSlider = V end)

-- System Workspace Controller
local DestructionTriggerButton = Instance.new("TextButton", TabSystem)
DestructionTriggerButton.Size = UDim2.new(1, -10, 0, 50)
DestructionTriggerButton.BackgroundColor3 = Color3.fromRGB(255, 69, 58)
DestructionTriggerButton.TextColor3 = Color3.fromRGB(255, 255, 255)
DestructionTriggerButton.Font = Enum.Font.SourceSansBold
DestructionTriggerButton.TextSize = 16
DestructionTriggerButton.Text = "FORCE UNLOAD EXECUTIVE SUITE"
Instance.new("UICorner", DestructionTriggerButton).CornerRadius = UDim.new(0, 12)

DestructionTriggerButton.MouseButton1Click:Connect(function()
    SystemConfig.Visuals.EspEnabled = false
    task.wait(0.1)
    
    for _, CurrentConnection in pairs(EngineCache.Connections) do 
        if CurrentConnection.Connected then CurrentConnection:Disconnect() end 
    end
    table.clear(EngineCache.Connections)
    
    for Plr, _ in pairs(EngineCache.EspObjects) do CleanPlayerEsp(Plr) end
    
    Lighting.Ambient = EngineCache.OriginalLighting.Ambient
    Lighting.OutdoorAmbient = EngineCache.OriginalLighting.OutdoorAmbient
    Lighting.ClockTime = EngineCache.OriginalLighting.ClockTime
    Lighting.FogEnd = EngineCache.OriginalLighting.FogEnd
    Lighting.GlobalShadows = EngineCache.OriginalLighting.GlobalShadows
    Camera.AspectRatio = 1.0
    Workspace.Gravity = 196.2
    
    for TrackedPart, CoreMaterial in pairs(EngineCache.OriginalMaterials) do
        if TrackedPart and TrackedPart.Parent then TrackedPart.Material = CoreMaterial end
    end
    
    pcall(function()
        local Character = LocalPlayer.Character
        if Character then
            local Humanoid = Character:FindFirstChildOfClass("Humanoid")
            local RootPart = Character:FindFirstChild("HumanoidRootPart")
            if Humanoid then
                Humanoid.WalkSpeed = 16
                Humanoid.JumpPower = 50
            end
            if RootPart then RootPart.Anchored = false end
        end
    end)
    
    MainGui:Destroy()
end)
