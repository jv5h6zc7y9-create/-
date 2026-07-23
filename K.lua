--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

--// Target Object Selection for Mobile CoreGui Insertion
local TargetParent = nil
local success, err = pcall(function()
    if getparentsyn then 
        TargetParent = getparentsyn()
    elseif typeof(gethui) == "function" then 
        TargetParent = gethui()
    else 
        TargetParent = CoreGui
    end
end)
if not success or not TargetParent then
    TargetParent = CoreGui
end

--// Prevent Duplicate Executions safely
if TargetParent:FindFirstChild("MobileMultiCheatGui") then
    TargetParent.MobileMultiCheatGui:Destroy()
end

--// Configuration State Tree
local Config = {
    ESPEnabled = false,
    TracersEnabled = false,
    TeamCheck = true,
    AimbotMode = "Off", -- "Off", "Regular Aimbot", "Silent Aim"
    AimbotTargetPart = "Head",
    FOV = 120,
    Smoothness = 3,
    SpeedMultiplier = 1,
    BunnyHop = false,
    ThirdPerson = false,
    LightingMode = "Standard"
}

--// GUI Object Hierarchy Creation
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MobileMultiCheatGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = TargetParent

--// Floating Draggable Menu Toggle Button
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "ToggleMenuBtn"
ToggleBtn.Size = UDim2.new(0, 45, 0, 45)
ToggleBtn.Position = UDim2.new(0, 20, 0, 60)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
ToggleBtn.Text = "⚙️"
ToggleBtn.TextSize = 22
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.Parent = ScreenGui

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 12)
ToggleCorner.Parent = ToggleBtn

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Color = Color3.fromRGB(60, 60, 60)
ToggleStroke.Thickness = 1.5
ToggleStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
ToggleStroke.Parent = ToggleBtn

--// Mobile Fluid Touch Drag Implementation
local dragging = false
local dragInput = nil
local dragStart = nil
local startPos = nil

ToggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = ToggleBtn.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

ToggleBtn.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        ToggleBtn.Position = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X, 
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )
    end
end)

--// Main Control Dashboard Panel
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 360, 0, 400)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(40, 40, 40)
MainStroke.Thickness = 1.5
MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
MainStroke.Parent = MainFrame

--// Frame Title Styling
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -20, 0, 45)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "PRIME MULTI-HACK"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 16
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = MainFrame

--// Feature Container Scrolling Frame
local Container = Instance.new("ScrollingFrame")
Container.Size = UDim2.new(1, -20, 1, -60)
Container.Position = UDim2.new(0, 10, 0, 50)
Container.BackgroundTransparency = 1
Container.CanvasSize = UDim2.new(0, 0, 0, 520)
Container.ScrollBarThickness = 3
Container.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
Container.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 6)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = Container

--// Open/Close Visibility Connection
ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

--// Component UI Rendering Helper Functions
local function CreateSection(name)
    local sectionFrame = Instance.new("Frame")
    sectionFrame.Size = UDim2.new(1, 0, 0, 25)
    sectionFrame.BackgroundTransparency = 1
    sectionFrame.Parent = Container

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = name:upper()
    lbl.TextColor3 = Color3.fromRGB(150, 75, 255)
    lbl.TextSize = 11
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = sectionFrame
end

local function CreateToggle(text, startState, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -6, 0, 38)
    btn.BackgroundColor3 = startState and Color3.fromRGB(35, 30, 60) or Color3.fromRGB(24, 24, 24)
    btn.Text = "  " .. text
    btn.TextColor3 = startState and Color3.fromRGB(200, 150, 255) or Color3.fromRGB(200, 200, 200)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamMedium
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = Container
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn

    local stroke = Instance.new("UIStroke")
    stroke.Color = startState and Color3.fromRGB(100, 50, 200) or Color3.fromRGB(35, 35, 35)
    stroke.Thickness = 1
    stroke.Parent = btn
    
    local state = startState
    btn.MouseButton1Click:Connect(function()
        state = not state
        stroke.Color = state and Color3.fromRGB(100, 50, 200) or Color3.fromRGB(35, 35, 35)
        btn.BackgroundColor3 = state and Color3.fromRGB(35, 30, 60) or Color3.fromRGB(24, 24, 24)
        btn.TextColor3 = state and Color3.fromRGB(200, 150, 255) or Color3.fromRGB(200, 200, 200)
        callback(state)
    end)
end

local function CreateDropdown(text, options, defaultIndex, callback)
    local currentIndex = defaultIndex
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -6, 0, 38)
    btn.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
    btn.Text = "  " .. text .. ": " .. options[currentIndex]
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamMedium
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = Container
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(35, 35, 35)
    stroke.Thickness = 1
    stroke.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        currentIndex = currentIndex % #options + 1
        btn.Text = "  " .. text .. ": " .. options[currentIndex]
        callback(options[currentIndex])
    end)
end

local function CreateSlider(text, min, max, default, callback)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, -6, 0, 45)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
    sliderFrame.Parent = Container

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = sliderFrame

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(35, 35, 35)
    stroke.Thickness = 1
    stroke.Parent = sliderFrame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 20)
    label.Position = UDim2.new(0, 10, 0, 4)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. tostring(default)
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextSize = 12
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = sliderFrame

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -20, 0, 4)
    track.Position = UDim2.new(0, 10, 0, 30)
    track.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    track.Parent = sliderFrame

    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(0, 2)
    trackCorner.Parent = track

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(150, 75, 255)
    fill.Parent = track

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 2)
    fillCorner.Parent = fill

    local function updateValue(inputObject)
        local totalWidth = track.AbsoluteSize.X
        local relativeX = math.clamp(inputObject.Position.X - track.AbsolutePosition.X, 0, totalWidth)
        local ratio = relativeX / totalWidth
        local value = math.floor(min + (ratio * (max - min)))
        
        fill.Size = UDim2.new(ratio, 0, 1, 0)
        label.Text = text .. ": " .. tostring(value)
        callback(value)
    end

    local isMoving = false

    sliderFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            isMoving = true
            updateValue(input)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if isMoving and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            updateValue(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            isMoving = false
        end
    end)
end

--// Constructing Control Menus
CreateSection("Visuals (ESP Engine)")
CreateToggle("Enable Master ESP", Config.ESPEnabled, function(v) Config.ESPEnabled = v end)
CreateToggle("Render Snap Tracers", Config.TracersEnabled, function(v) Config.TracersEnabled = v end)
CreateToggle("Apply Team Filter Check", Config.TeamCheck, function(v) Config.TeamCheck = v end)

CreateSection("Combat (Target Optimization)")
CreateDropdown("Targeting Strategy Mode", {"Off", "Regular Aimbot", "Silent Aim"}, 1, function(v) Config.AimbotMode = v end)
CreateDropdown("Preferred Targeting Joint", {"Head", "HumanoidRootPart"}, 1, function(v) Config.AimbotTargetPart = v end)
CreateSlider("Aimbot Field of View Radius", 30, 400, 120, function(v) Config.FOV = v end)
CreateSlider("Target Tracking Smoothness", 1, 20, 3, function(v) Config.Smoothness = v end)

CreateSection("Movement Utilities")
CreateSlider("WalkSpeed Force Multiplier", 1, 10, 1, function(v) Config.SpeedMultiplier = v end)
CreateToggle("Continuous Jump (BunnyHop)", Config.BunnyHop, function(v) Config.BunnyHop = v end)
CreateToggle("Enforce Third-Person View", Config.ThirdPerson, function(v)
    Config.ThirdPerson = v
    LocalPlayer.CameraMode = v and Enum.CameraMode.Classic or Enum.CameraMode.LockFirstPerson
end)

CreateSection("Atmospheric Control")
CreateDropdown("Lighting Environment", {"Standard", "Midnight", "Sunset"}, 1, function(v)
    Config.LightingMode = v
    if v == "Midnight" then
        Lighting.ClockTime = 0
        Lighting.Brightness = 0
        Lighting.GlobalShadows = true
    elseif v == "Sunset" then
        Lighting.ClockTime = 18.5
        Lighting.Brightness = 1.2
        Lighting.GlobalShadows = true
    else
        Lighting.ClockTime = 14
        Lighting.Brightness = 2
        Lighting.GlobalShadows = true
    end
end)

--// FOV Vector Overlay Drawing Context
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.NumSides = 64
FOVCircle.Filled = false
FOVCircle.Transparency = 0.8
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Visible = false

--// Global Multi-Cheat Processing Repositories
local ESPStorage = {}
local OriginalIndexHook = nil

local function IsValidEnemy(plr)
    if plr == LocalPlayer then return false end
    if not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then return false end
    local hum = plr.Character:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    if Config.TeamCheck and plr.Team and LocalPlayer.Team and plr.Team == LocalPlayer.Team then
        return false
    end
    return true
end

local function ClearIndividualESP(plr)
    if ESPStorage[plr] then
        if ESPStorage[plr].Highlight then
            ESPStorage[plr].Highlight:Destroy()
        end
        if ESPStorage[plr].Tracer then
            ESPStorage[plr].Tracer:Remove()
        end
        if ESPStorage[plr].Billboard then
            ESPStorage[plr].Billboard:Destroy()
        end
        ESPStorage[plr] = nil
    end
end

--// Algorithmic Closest Player Evaluation inside Field of View
local function DiscoverClosestScreenTarget()
    local targetCharacterPart = nil
    local shortestPixelDistance = Config.FOV
    local viewportCenterPosition = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if IsValidEnemy(plr) then
            local trackingPart = plr.Character:FindFirstChild(Config.AimbotTargetPart) or plr.Character.HumanoidRootPart
            if trackingPart then
                local screenVector, isRenderedOnScreen = Camera:WorldToViewportPoint(trackingPart.Position)
                if isRenderedOnScreen then
                    local calculatedDistance = (Vector2.new(screenVector.X, screenVector.Y) - viewportCenterPosition).Magnitude
                    if calculatedDistance < shortestPixelDistance then
                        shortestPixelDistance = calculatedDistance
                        targetCharacterPart = trackingPart
                    end
                end
            end
        end
    end
    return targetCharacterPart
end

--// High-Velocity Execution Runtime Hooks (RenderStepped Sub-Loop)
RunService.RenderStepped:Connect(function()
    local screenCenterPosition = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local currentValidTarget = nil
    
    -- Combat Verification Matrix Processing
    if Config.AimbotMode ~= "Off" then
        currentValidTarget = DiscoverClosestScreenTarget()
        FOVCircle.Visible = true
        FOVCircle.Radius = Config.FOV
        FOVCircle.Position = screenCenterPosition
        FOVCircle.Color = currentValidTarget and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(255, 255, 255)
        
        if Config.AimbotMode == "Regular Aimbot" and currentValidTarget then
            local lookAtRotationCFrame = CFrame.new(Camera.CFrame.Position, currentValidTarget.Position)
            Camera.CFrame = Camera.CFrame:Lerp(lookAtRotationCFrame, (1 / (Config.Smoothness * 1.5)))
        end
    else
        FOVCircle.Visible = false
    end
    
    -- Visual Framework Graphics Management Engine
    for _, plr in ipairs(Players:GetPlayers()) do
        if Config.ESPEnabled and IsValidEnemy(plr) then
            local characterInstance = plr.Character
            local primaryPart = characterInstance.HumanoidRootPart
            local coreHumanoid = characterInstance:FindFirstChildOfClass("Humanoid")
            
            if not ESPStorage[plr] then
                ESPStorage[plr] = {}
                
                -- Dynamic Mesh Highlighting Creation
                local highlight = Instance.new("Highlight")
                highlight.Adornee = characterInstance
                highlight.FillColor = Color3.fromRGB(150, 50, 255)
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.FillTransparency = 0.4
                highlight.OutlineTransparency = 0.1
                highlight.Parent = characterInstance
                ESPStorage[plr].Highlight = highlight
                
                -- Drawing API 2D Canvas Tracers Configuration
                local linearTracer = Drawing.new("Line")
                linearTracer.Thickness = 1.5
                linearTracer.Color = Color3.fromRGB(150, 50, 255)
                linearTracer.Transparency = 0.75
                ESPStorage[plr].Tracer = linearTracer
                
                -- Spatial Vector Heads-Up Display Setup
                local billboard = Instance.new("BillboardGui")
                billboard.Size = UDim2.new(0, 130, 0, 45)
                billboard.StudsOffset = Vector3.new(0, 3.2, 0)
                billboard.AlwaysOnTop = true
                billboard.Parent = primaryPart
                
                local frame = Instance.new("Frame")
                frame.Size = UDim2.new(1, 0, 1, 0)
                frame.BackgroundTransparency = 1
                frame.Parent = billboard
                
                local infoLabel = Instance.new("TextLabel")
                infoLabel.Size = UDim2.new(1, 0, 0, 26)
                infoLabel.BackgroundTransparency = 1
                infoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                infoLabel.TextStrokeTransparency = 0.3
                infoLabel.TextSize = 11
                infoLabel.Font = Enum.Font.GothamBold
                infoLabel.Parent = frame
                
                local healthTrack = Instance.new("Frame")
                healthTrack.Size = UDim2.new(0, 70, 0, 4)
                healthTrack.Position = UDim2.new(0.5, -35, 0, 28)
                healthTrack.BackgroundColor3 = Color3.fromRGB(40, 10, 10)
                healthTrack.BorderSizePixel = 0
                healthTrack.Parent = frame
                
                local healthFill = Instance.new("Frame")
                healthFill.Size = UDim2.new(1, 0, 1, 0)
                healthFill.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
                healthFill.BorderSizePixel = 0
                healthFill.Parent = healthTrack
                
                ESPStorage[plr].BillboardText = infoLabel
                ESPStorage[plr].BillboardHealthFill = healthFill
                ESPStorage[plr].Billboard = billboard
            end
            
            -- High-Frequency Metric Rendering Computations
            local spatialDistanceMeters = math.floor((Camera.CFrame.Position - primaryPart.Position).Magnitude * 0.28)
            local currentHealthRatio = math.clamp(coreHumanoid.Health / coreHumanoid.MaxHealth, 0, 1)
            
            local infoTextLabel = ESPStorage[plr].BillboardText
            if infoTextLabel then
                infoTextLabel.Text = plr.Name .. " (" .. tostring(spatialDistanceMeters) .. "m)"
            end
            
            local fillingGraphic = ESPStorage[plr].BillboardHealthFill
            if fillingGraphic then
                fillingGraphic.Size = UDim2.new(currentHealthRatio, 0, 1, 0)
                fillingGraphic.BackgroundColor3 = Color3.fromRGB(255 - (currentHealthRatio * 205), currentHealthRatio * 255, 50)
            end
            
            local structuralTracer = ESPStorage[plr].Tracer
            if structuralTracer and Config.TracersEnabled then
                local vectorCoordinate, partIsVisibleOnScreen = Camera:WorldToViewportPoint(primaryPart.Position)
                if partIsVisibleOnScreen then
                    structuralTracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    structuralTracer.To = Vector2.new(vectorCoordinate.X, vectorCoordinate.Y)
                    structuralTracer.Visible = true
                else
                    structuralTracer.Visible = false
                end
            elseif structuralTracer then
                structuralTracer.Visible = false
            end
        else
            ClearIndividualESP(plr)
        end
    end
    
    -- Physics Execution Optimization Modules
    if Config.BunnyHop and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        local targetHumanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if targetHumanoid.FloorMaterial ~= Enum.Material.Air then
            targetHumanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
    
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        local targetHumanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if Config.SpeedMultiplier > 1 then
            targetHumanoid.WalkSpeed = 16 * Config.SpeedMultiplier
        else
            if targetHumanoid.WalkSpeed > 16 then
                targetHumanoid.WalkSpeed = 16
            end
        end
    end
end)

--// High-End Environment Memory Interception for Engine Silent Aim Redirects
local function InitializeSilentAimRedirection()
    local gameMetatable = nil
    local metatableFetchSuccess, metatableError = pcall(function()
        return getrawmetatable(game)
    end)
    
    if metatableFetchSuccess and metatableError then
        gameMetatable = metatableError
        local unprotectMetatableMetamethod = setreadonly or make_writeable
        if unprotectMetatableMetamethod then
            unprotectMetatableMetamethod(gameMetatable, false)
        end
    else
        return
    end
    
    OriginalIndexHook = gameMetatable.__index
    local originalNamecallHook = gameMetatable.__namecall
    
    gameMetatable.__index = newcclosure(function(self, indexParameter)
        if not typeof(self) == "Instance" or not indexParameter then
            return OriginalIndexHook(self, indexParameter)
        end
        
        if Config.AimbotMode == "Silent Aim" and tostring(indexParameter) == "Hit" or tostring(indexParameter) == "Target" then
            local activeSilentTarget = DiscoverClosestScreenTarget()
            if activeSilentTarget then
                if tostring(indexParameter) == "Hit" then
                    return activeSilentTarget.CFrame
                elseif tostring(indexParameter) == "Target" then
                    return activeSilentTarget
                end
            end
        end
        return OriginalIndexHook(self, indexParameter)
    end)
    
    if setreadonly then
        setreadonly(gameMetatable, true)
    end
end

--// Immediate Thread Optimization Execution Instantiation
task.spawn(InitializeSilentAimRedirection)

--// Disconnection Event Garbage Collectors
Players.PlayerRemoving:Connect(ClearIndividualESP)
