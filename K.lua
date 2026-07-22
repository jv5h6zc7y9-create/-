-- Production-Ready Script for "Fling Things and People"
-- Fully Optimized for Delta iOS Executor on iPad
-- Features: Custom Mobile Dragging GUI, Silent Aim, Max Far Throw & Floor Shove, Anti-Grab Shield

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Global Feature Toggles
local Toggles = {
    SilentAim = false,
    FloorShoveMaxThrow = false,
    AntiGrab = false
}

-- Target Cache for Silent Aim
local CurrentTarget = nil

-- Clean up existing instances of this script to prevent overlay bugs
local ExistingGui = CoreGui:FindFirstChild("FTP_Delta_Premium")
if ExistingGui then ExistingGui:Destroy() end

-- ==========================================
-- [UI SETUP & CUSTOM MOBILE DRAGGING SYSTEM]
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FTP_Delta_Premium"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui

-- Main Container (Frame)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 340, 0, 260)
MainFrame.Position = UDim2.new(0.5, -170, 0.4, -130)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(45, 45, 55)
MainStroke.Thickness = 2
MainStroke.Parent = MainFrame

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleBar

-- Hide bottom corners of TitleBar to look clean
local TitleHide = Instance.new("Frame")
TitleHide.Size = UDim2.new(1, 0, 0, 10)
TitleHide.Position = UDim2.new(0, 0, 1, -10)
TitleHide.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
TitleHide.BorderSizePixel = 0
TitleHide.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(0.7, 0, 1, 0)
TitleText.Position = UDim2.new(0, 15, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "FTP PREMIUM — DELTA IOS"
TitleText.TextColor3 = Color3.fromRGB(240, 240, 245)
TitleText.TextSize = 16
TitleText.Font = Enum.Font.GothamBold
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

-- Minimize Button
local MinButton = Instance.new("TextButton")
MinButton.Name = "MinButton"
MinButton.Size = UDim2.new(0, 30, 0, 30)
MinButton.Position = UDim2.new(1, -40, 0, 5)
MinButton.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
MinButton.Text = "—"
MinButton.TextColor3 = Color3.fromRGB(220, 220, 225)
MinButton.TextSize = 14
MinButton.Font = Enum.Font.GothamBold
MinButton.AutoButtonColor = true
MinButton.Parent = TitleBar

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 6)
MinCorner.Parent = MinButton

-- Compact Toggle Icon (Hidden initially)
local CompactToggle = Instance.new("TextButton")
CompactToggle.Name = "CompactToggle"
CompactToggle.Size = UDim2.new(0, 50, 0, 50)
CompactToggle.Visible = false
CompactToggle.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
CompactToggle.Text = "FTP"
CompactToggle.TextColor3 = Color3.fromRGB(0, 180, 255)
CompactToggle.TextSize = 14
CompactToggle.Font = Enum.Font.GothamBold
CompactToggle.AutoButtonColor = true
CompactToggle.Parent = ScreenGui

local CompactCorner = Instance.new("UICorner")
CompactCorner.CornerRadius = UDim.new(0, 25)
CompactCorner.Parent = CompactToggle

local CompactStroke = Instance.new("UIStroke")
CompactStroke.Color = Color3.fromRGB(0, 180, 255)
CompactStroke.Thickness = 2
CompactStroke.Parent = CompactToggle

-- Content Layout
local ButtonLayout = Instance.new("UIListLayout")
ButtonLayout.Padding = UDim.new(0, 12)
ButtonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
ButtonLayout.VerticalAlignment = Enum.VerticalAlignment.Top
ButtonLayout.SortOrder = Enum.SortOrder.LayoutOrder

local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, 0, 1, -50)
ContentFrame.Position = UDim2.new(0, 0, 0, 50)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame
ButtonLayout.Parent = ContentFrame

-- Helper function to generate standardized modern menu buttons
local function CreateToggleButton(name, text, layoutOrder)
    local Btn = Instance.new("TextButton")
    Btn.Name = name
    Btn.Size = UDim2.new(0, 300, 0, 48)
    Btn.BackgroundColor3 = Color3.fromRGB(32, 32, 40)
    Btn.Text = text .. " : OFF"
    Btn.TextColor3 = Color3.fromRGB(180, 180, 190)
    Btn.TextSize = 14
    Btn.Font = Enum.Font.GothamBold
    Btn.LayoutOrder = layoutOrder
    Btn.AutoButtonColor = true
    Btn.Parent = ContentFrame

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 8)
    BtnCorner.Parent = Btn

    local BtnStroke = Instance.new("UIStroke")
    BtnStroke.Color = Color3.fromRGB(45, 45, 55)
    BtnStroke.Thickness = 1
    BtnStroke.Parent = Btn

    return Btn, BtnStroke
end

local AimBtn, AimStroke = CreateToggleButton("AimButton", "DYNAMIC SILENT AIM", 1)
local ShoveBtn, ShoveStroke = CreateToggleButton("ShoveButton", "FLOOR SHOVE & MAX THROW", 2)
local ShieldBtn, ShieldStroke = CreateToggleButton("ShieldButton", "ANTI-GRAB SHIELD", 3)

-- IOS Touch Dragging Implementation (Completely replaces Frame.Draggable to eliminate executor crashes)
local function SetupDragging(targetFrame, dragHandle)
    local dragging = false
    local dragInput = nil
    local dragStart = nil
    local startPos = nil

    dragHandle.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            dragging = true
            dragStart = input.Position
            startPos = targetFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    dragHandle.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            targetFrame.Position = UDim2.new(
                startPos.X.Scale, 
                startPos.X.Offset + delta.X, 
                startPos.Y.Scale, 
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

SetupDragging(MainFrame, TitleBar)
SetupDragging(CompactToggle, CompactToggle)

-- Minimize & Restore Window Logic
MinButton.MouseButton1Click:Connect(function()
    CompactToggle.Position = UDim2.new(0, MainFrame.AbsolutePosition.X + 145, 0, MainFrame.AbsolutePosition.Y + 5)
    MainFrame.Visible = false
    CompactToggle.Visible = true
end)

CompactToggle.MouseButton1Click:Connect(function()
    MainFrame.Position = UDim2.new(0, CompactToggle.AbsolutePosition.X - 145, 0, CompactToggle.AbsolutePosition.Y - 5)
    CompactToggle.Visible = false
    MainFrame.Visible = true
end)

-- Button Visual Toggles Handler
local function UpdateButtonVisual(btn, stroke, state, text)
    if state then
        btn.BackgroundColor3 = Color3.fromRGB(25, 45, 35)
        btn.TextColor3 = Color3.fromRGB(0, 225, 140)
        stroke.Color = Color3.fromRGB(0, 180, 100)
        btn.Text = text .. " : ACTIVE"
    else
        btn.BackgroundColor3 = Color3.fromRGB(32, 32, 40)
        btn.TextColor3 = Color3.fromRGB(180, 180, 190)
        stroke.Color = Color3.fromRGB(45, 45, 55)
        btn.Text = text .. " : OFF"
    end
end

AimBtn.MouseButton1Click:Connect(function()
    Toggles.SilentAim = not Toggles.SilentAim
    UpdateButtonVisual(AimBtn, AimStroke, Toggles.SilentAim, "DYNAMIC SILENT AIM")
end)

ShoveBtn.MouseButton1Click:Connect(function()
    Toggles.FloorShoveMaxThrow = not Toggles.FloorShoveMaxThrow
    UpdateButtonVisual(ShoveBtn, ShoveStroke, Toggles.FloorShoveMaxThrow, "FLOOR SHOVE & MAX THROW")
end)

ShieldBtn.MouseButton1Click:Connect(function()
    Toggles.AntiGrab = not Toggles.AntiGrab
    UpdateButtonVisual(ShieldBtn, ShieldStroke, Toggles.AntiGrab, "ANTI-GRAB SHIELD")
end)

-- ==========================================
-- [FEATURE 1: DYNAMIC SILENT AIM SYSTEM]
-- ==========================================
local function GetClosestPlayerToCenter()
    local closestPlayer = nil
    local shortestDistance = math.huge
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local hrp = player.Character.HumanoidRootPart
                local vector, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                
                if onScreen then
                    local distance = (Vector2.new(vector.X, vector.Y) - screenCenter).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closestPlayer = player
                    end
                end
            end
        end
    end
    return closestPlayer
end

-- Screen Center Nearest Tracking Loop
RunService.Heartbeat:Connect(function()
    if Toggles.SilentAim then
        CurrentTarget = GetClosestPlayerToCenter()
    else
        CurrentTarget = nil
    end
end)

-- ==========================================
-- [FEATURE 2: SHOVE & OVERRIDE PHYSICS]
-- ==========================================
-- Verifies if an item is being held by checking standard joint or naming structures in Fling Things and People
local function IsHeldByLocalPlayer(part)
    if not part or not LocalPlayer.Character then return false end
    -- Check for direct structural connection to character parts
    for _, descendant in ipairs(LocalPlayer.Character:GetDescendants()) do
        if descendant:IsA("Weld") or descendant:IsA("ManualWeld") or descendant:IsA("Motor6D") then
            if descendant.Part0 == part or descendant.Part1 == part then
                return true
            end
        end
    end
    -- Native Game Check: held objects are often reparented, given specific tags or put inside a local tool/container
    if part:IsDescendantOf(LocalPlayer.Character) then
        return true
    end
    return false
end

-- Core Physics Interceptor Loop
RunService.Stepped:Connect(function()
    if not Toggles.FloorShoveMaxThrow then return end
    if not LocalPlayer.Character then return end
    
    -- Scan workspace for parts dynamically held by the character
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj:IsDescendantOf(LocalPlayer.Character) then
            if IsHeldByLocalPlayer(obj) then
                -- Custom Physics Shoving Properties Applied Instantly
                obj.CanCollide = false
                -- Apply downward vector velocity to submerge underneath floor textures cleanly
                obj.AssemblyLinearVelocity = Vector3.new(0, -150, 0)
                
                -- Sniffs for when the weld breaks (indicating a game throw event)
                obj.AncestryChanged:Connect(function(_, newParent)
                    if not newParent then return end
                    -- Reset tracking instantly to handle next frames safely
                    task.spawn(function()
                        -- Completely nullify structural mass definitions to prevent vector damping
                        obj.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
                        if obj:IsA("BasePart") then obj.AssemblyMass = 0 end
                        
                        -- Erase conflicting physical structures
                        for _, child in ipairs(obj:GetChildren()) do
                            if child:IsA("LinearVelocity") or child:IsA("BodyVelocity") or child:IsA("VectorForce") then
                                child:Destroy()
                            end
                        end
                        
                        -- Compile Velocity Trajectory Base
                        local LaunchDirection = Camera.CFrame.LookVector
                        if Toggles.SilentAim and CurrentTarget and CurrentTarget.Character and CurrentTarget.Character:FindFirstChild("HumanoidRootPart") then
                            -- Target Prediction Trajectory Calculation
                            local targetHrp = CurrentTarget.Character.HumanoidRootPart
                            local targetVel = targetHrp.AssemblyLinearVelocity
                            local distance = (targetHrp.Position - obj.Position).Magnitude
                            local travelTime = distance / 350
                            local PredictedPosition = targetHrp.Position + (targetVel * travelTime)
                            LaunchDirection = (PredictedPosition - obj.Position).Unit
                        else
                            -- Standalone Max Force Launch with custom elevation compensation
                            LaunchDirection = (LaunchDirection + Vector3.new(0, 0.15, 0)).Unit
                        end
                        
                        -- Set extreme direct physical impulse acceleration
                        obj.AssemblyLinearVelocity = LaunchDirection * 2500
                        
                        -- Constant LinearVelocity Driver to permanently enforce cross-map ejection bypassing engine friction
                        local ForceDriver = Instance.new("LinearVelocity")
                        ForceDriver.Name = "FTP_MaxDriver"
                        ForceDriver.MaxForce = 35000000
                        ForceDriver.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
                        ForceDriver.VectorVelocity = LaunchDirection * 3500
                        
                        local Attachment = Instance.new("Attachment")
                        Attachment.Parent = obj
                        ForceDriver.Attachment0 = Attachment
                        ForceDriver.Parent = obj
                        
                        -- Debris lifecycle cleanup of external force definitions
                        game:GetService("Debris"):AddItem(ForceDriver, 2)
                        game:GetService("Debris"):AddItem(Attachment, 2)
                    end)
                end)
            end
        end
    end
end)

-- ==========================================
-- [FEATURE 3: ANTI-GRAB PACKET SHIELD]
-- ==========================================
local function HandleDescendant(descendant)
    if not Toggles.AntiGrab then return end
    -- Filter structural constraints that handle picking up mechanisms
    if descendant:IsA("Weld") or descendant:IsA("ManualWeld") or descendant:IsA("MoverConstraint") then
        task.delay(0.01, function() -- Micro-timing interval optimized for mobile replication delay
            if not descendant or not descendant.Parent then return end
            -- Detect hostile opponent connection signatures
            local AttackerCharacter = nil
            if descendant:IsA("Weld") or descendant:IsA("ManualWeld") then
                local p0 = descendant.Part0
                local p1 = descendant.Part1
                if p0 and not p0:IsDescendantOf(LocalPlayer.Character) then
                    AttackerCharacter = p0.Parent
                elseif p1 and not p1:IsDescendantOf(LocalPlayer.Character) then
                    AttackerCharacter = p1.Parent
                end
            end
            -- Enforce absolute severance if opponent signature matches criteria
            if AttackerCharacter and AttackerCharacter:FindFirstChildOfClass("Humanoid") then
                if AttackerCharacter.Name ~= LocalPlayer.Name then
                    -- Break joints on attacker character layout to detach them entirely
                    AttackerCharacter:BreakJoints()
                    descendant:Destroy()
                    -- Fully purge remaining force vectors from own root system
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        for _, obj in ipairs(LocalPlayer.Character.HumanoidRootPart:GetChildren()) do
                            if obj:IsA("BodyVelocity") or obj:IsA("BodyPosition") or obj:IsA("LinearVelocity") then
                                obj:Destroy()
                            end
                        end
                    end
                end
            end
        end)
    end
end

-- Initialize character monitoring mechanisms
local function SetupCharacterShield(char)
    if not char then return end
    char.DescendantAdded:Connect(HandleDescendant)
end

if LocalPlayer.Character then SetupCharacterShield(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(SetupCharacterShield)
